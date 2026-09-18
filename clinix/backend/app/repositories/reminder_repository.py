from app.repositories.base import MEMORY, Repository, doc_to_dict, new_id, utcnow


class ReminderRepository(Repository):
    """users/{uid}/reminders — optional cloud copy of the offline-first
    schedules so they can be restored on new devices."""

    def _ref(self, uid: str):
        return self.db.collection("users").document(uid).collection("reminders")

    async def list_all(self, uid: str) -> list[dict]:
        if self.db is not None:
            snaps = await self.run(lambda: list(self._ref(uid).stream()))
            return [doc_to_dict(s) for s in snaps]
        return list(MEMORY.reminders.get(uid, {}).values())

    async def create(self, uid: str, data: dict) -> dict:
        reminder_id = new_id()
        data = {**data, "id": reminder_id, "created_at": utcnow()}
        if self.db is not None:
            await self.run(self._ref(uid).document(reminder_id).set, data)
        else:
            MEMORY.reminders.setdefault(uid, {})[reminder_id] = data
        return data

    async def update(self, uid: str, reminder_id: str, patch: dict) -> dict | None:
        if self.db is not None:
            ref = self._ref(uid).document(reminder_id)
            snap = await self.run(ref.get)
            if not snap.exists:
                return None
            await self.run(ref.set, patch, merge=True)
            return doc_to_dict(await self.run(ref.get))
        row = MEMORY.reminders.get(uid, {}).get(reminder_id)
        if row is None:
            return None
        row.update(patch)
        return row

    async def delete(self, uid: str, reminder_id: str) -> bool:
        if self.db is not None:
            ref = self._ref(uid).document(reminder_id)
            snap = await self.run(ref.get)
            if not snap.exists:
                return False
            await self.run(ref.delete)
            return True
        return MEMORY.reminders.get(uid, {}).pop(reminder_id, None) is not None
