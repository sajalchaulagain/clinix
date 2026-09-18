"""FCM delivery (server-side push via Firebase Admin).

Notifications are persisted in Firestore for the in-app center; FCM delivers
the push. In dev/mock mode this is a logged no-op so nothing crashes.
"""
import logging

from app.core.firebase import firebase_ready

logger = logging.getLogger("clinix.fcm")


async def send_push(tokens: list[str], title: str, body: str, data: dict | None = None) -> int:
    """Send a push to the given device tokens. Returns successful send count."""
    tokens = [t for t in tokens if t]
    if not tokens:
        return 0
    if not firebase_ready():
        logger.info("[mock-fcm] would push to %d devices: %s", len(tokens), title)
        return 0

    from firebase_admin import messaging

    message = messaging.MulticastMessage(
        notification=messaging.Notification(title=title, body=body),
        data={k: str(v) for k, v in (data or {}).items()},
        tokens=tokens,
    )
    try:
        response = messaging.send_each_for_multicast(message)
        return response.success_count
    except Exception as exc:  # FCM is best-effort; never break the request flow
        logger.warning("FCM send failed: %s", exc)
        return 0
