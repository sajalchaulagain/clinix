from datetime import datetime

from app.repositories.base import MEMORY, Repository, doc_to_dict, new_id, utcnow


class NotificationRepository(Repository):
    """Per-user subcollections: users/{uid}/notifications and device_tokens."""

    def _ref(self, uid: str, sub: str):
        return self.db.collection("users").document(uid).collection(sub)

    async def list_for(self, uid: str) -> list[dict]:
        if self.db is not None:
            snaps = await self.run(lambda: list(
                self._ref(uid, "notifications").order_by("created_at", direction=None).limit(100).stream()
            ))
            rows = [doc_to_dict(s) for s in snaps]
        else:
            rows = list(MEMORY.notifications.get(uid, {}).values())
        return sorted(rows, key=lambda r: r.get("created_at") or datetime.min.replace().astimezone(),
                      reverse=True)

    async def create(self, uid: str, data: dict) -> dict:
        notif_id = data.get("id") or new_id()
        data = {**data, "id": notif_id, "is_read": False,
                "created_at": data.get("created_at") or utcnow()}
        if self.db is not None:
            await self.run(self._ref(uid, "notifications").document(notif_id).set, data)
        else:
            MEMORY.notifications.setdefault(uid, {})[notif_id] = data
        return data

    async def mark_read(self, uid: str, notification_id: str) -> dict | None:
        patch = {"is_read": True}
        if self.db is not None:
            ref = self._ref(uid, "notifications").document(notification_id)
            snap = await self.run(ref.get)
            if not snap.exists:
                return None
            await self.run(ref.set, patch, merge=True)
            return doc_to_dict(await self.run(ref.get))
        row = MEMORY.notifications.get(uid, {}).get(notification_id)
        if row is None:
            return None
        row.update(patch)
        return row

    async def mark_all_read(self, uid: str) -> int:
        rows = [r for r in await self.list_for(uid) if not r.get("is_read")]
        if self.db is not None:
            batch = self.db.batch()
            for row in rows:
                batch.set(self._ref(uid, "notifications").document(row["id"]),
                          {"is_read": True}, merge=True)
            if rows:
                await self.run(batch.commit)
        else:
            for row in rows:
                MEMORY.notifications[uid][row["id"]]["is_read"] = True
        return len(rows)

    # ------------------------------------------------------------- tokens
    async def register_token(self, uid: str, token: str, platform: str) -> None:
        if self.db is not None:
            await self.run(
                self._ref(uid, "device_tokens").document(token[-32:]).set,
                {"token": token, "platform": platform, "updated_at": utcnow()},
            )
        else:
            MEMORY.device_tokens.setdefault(uid, set()).add(token)

    async def tokens_for_users(self, uids: list[str] | None = None) -> list[str]:
        if self.db is not None:
            user_ids = uids or [u.id for u in await self.run(
                lambda: list(self.db.collection("users").stream()))]
            tokens: list[str] = []
            for user_id in user_ids:
                snaps = await self.run(lambda uid=user_id: list(
                    self.db.collection("users").document(uid)
                          .collection("device_tokens").stream()))
                tokens.extend(doc_to_dict(s).get("token", "") for s in snaps)
            return [t for t in tokens if t]
        if uids:
            return sorted({t for uid in uids for t in MEMORY.device_tokens.get(uid, set())})
        return sorted({t for tokens in MEMORY.device_tokens.values() for t in tokens})
