"""Authentication & authorization dependencies.

The ONLY source of identity is a verified Firebase ID token
(`Authorization: Bearer <token>` sent by the Flutter ApiClient). We never
trust any uid/role that arrives in a request body or query parameter.
"""
import logging
from dataclasses import dataclass, field

from fastapi import Depends, Header, HTTPException

from app.core.config import Settings, get_settings
from app.core.firebase import firebase_ready

logger = logging.getLogger("clinix.security")


@dataclass(slots=True)
class CurrentUser:
    uid: str
    email: str = ""
    name: str = ""
    email_verified: bool = False
    claims: dict = field(default_factory=dict)

    @property
    def role(self) -> str:
        # Role comes from Firebase custom claims, set server-side only.
        return str(self.claims.get("role", "patient"))

    @property
    def is_admin(self) -> bool:
        return self.role == "admin"


def _dev_user(token: str) -> CurrentUser:
    """Development-only identity from plain dev tokens, e.g. Authorization:
    Bearer dev-user | dev-admin | dev-anything (patient)."""
    claims = {"role": "admin"} if token.startswith("dev-admin") else {}
    return CurrentUser(
        uid=token,
        email=f"{token.removeprefix('dev-')}@dev.clinix.local",
        name="Dev Admin" if token.startswith("dev-admin") else "Dev User",
        email_verified=True,
        claims=claims,
    )


async def get_current_user(
    authorization: str | None = Header(default=None),
    settings: Settings = Depends(get_settings),
) -> CurrentUser:
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Authentication required. Please sign in.")

    token = authorization.removeprefix("Bearer ").strip()
    if not token:
        raise HTTPException(status_code=401, detail="Authentication required. Please sign in.")

    if firebase_ready():
        # Real path: verify the Firebase ID token with the Admin SDK.
        from firebase_admin import auth as firebase_auth

        try:
            decoded = firebase_auth.verify_id_token(token)
        except Exception as exc:  # expired / malformed / revoked
            logger.info("token verification failed: %s", type(exc).__name__)
            raise HTTPException(
                status_code=401,
                detail="Your session has expired. Please sign in again.",
            ) from exc
        return CurrentUser(
            uid=decoded["uid"],
            email=decoded.get("email", ""),
            name=decoded.get("name", ""),
            email_verified=bool(decoded.get("email_verified", False)),
            claims=dict(decoded.get("claims", decoded)) if "claims" in decoded else dict(decoded),
        )

    if settings.mock_external_services:
        return _dev_user(token)

    # Real mode without Firebase credentials: fail loudly, never fabricate.
    raise HTTPException(
        status_code=503,
        detail="Authentication is not configured on the server.",
    )


async def require_admin(user: CurrentUser = Depends(get_current_user)) -> CurrentUser:
    """Admin routes verify the custom claim INDEPENDENTLY of anything the
    Flutter client hides or shows — UI guards are not security."""
    if not user.is_admin:
        raise HTTPException(status_code=403, detail="Admin access required.")
    return user
