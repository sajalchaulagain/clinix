from app.integrations import firebase as fcm
from app.repositories.notification_repository import NotificationRepository


class NotificationService:
    def __init__(self, repo: NotificationRepository) -> None:
        self.repo = repo

    async def notify_user(self, uid: str, type_: str, title: str, body: str,
                          payload: dict | None = None, send_fcm: bool = True) -> dict:
        row = await self.repo.create(uid, {"type": type_, "title": title,
                                           "body": body, "payload": payload})
        if send_fcm:
            tokens = await self.repo.tokens_for_users([uid])
            await fcm.send_push(tokens, title, body, {"notification_id": row["id"]})
        return row

    async def broadcast(self, title: str, body: str) -> int:
        tokens = await self.repo.tokens_for_users(None)
        sent = await fcm.send_push(tokens, title, body, {"kind": "broadcast"})
        return max(sent, len(tokens)) if tokens else 0
