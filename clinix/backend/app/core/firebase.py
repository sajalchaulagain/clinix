"""Firebase Admin initialization.

Initialized once in the app lifespan. When credentials are absent and
MOCK_EXTERNAL_SERVICES=true the app runs against an in-memory store instead
(local development without any Google account). In production, missing
credentials make every Firebase call fail loudly — we never fabricate auth.
"""
import logging

import firebase_admin
from firebase_admin import credentials, firestore

from app.core.config import Settings

logger = logging.getLogger("clinix.firebase")

_app: firebase_admin.App | None = None
_db = None


def init_firebase(settings: Settings) -> None:
    global _app, _db
    if _db is not None:
        return
    if not settings.firebase_configured:
        if settings.mock_external_services:
            logger.info("Firebase not configured — using in-memory dev store.")
        else:
            logger.warning(
                "Firebase Admin credentials are MISSING and mock mode is off. "
                "Authenticated requests will fail until .env is configured."
            )
        return

    private_key = settings.firebase_private_key.replace("\\n", "\n")
    cred = credentials.Certificate(
        {
            "type": "service_account",
            "project_id": settings.firebase_project_id,
            "client_email": settings.firebase_client_email,
            "private_key": private_key,
            "token_uri": "https://oauth2.googleapis.com/token",
        }
    )
    _app = firebase_admin.initialize_app(cred, {"projectId": settings.firebase_project_id})
    _db = firestore.client()
    logger.info("Firebase Admin initialized for project %s", settings.firebase_project_id)


def get_db():
    """Firestore client, or None when running the in-memory dev store."""
    return _db


def firebase_ready() -> bool:
    return _db is not None
