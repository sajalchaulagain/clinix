from app.repositories.base import COLLECTIONS, MEMORY, Repository, doc_to_dict, utcnow


class DoctorRepository(Repository):
    col = COLLECTIONS["doctors"]

    async def list_doctors(self, specialty: str | None, location: str | None,
                           available_today: bool = False) -> list[dict]:
        rows = await self._all()
        def match(row: dict) -> bool:
            if specialty and specialty.lower() not in row.get("specialty", "").lower():
                return False
            if location and location.lower() not in row.get("location", "").lower():
                return False
            if available_today and not row.get("is_available_today", False):
                return False
            return True
        return [r for r in rows if match(r)]

    async def recommended(self, limit: int = 5) -> list[dict]:
        rows = await self._all()
        rows.sort(key=lambda r: (-r.get("rating", 0), -r.get("is_available_today", False)))
        return rows[:limit]

    async def get(self, doctor_id: str) -> dict | None:
        if self.db is not None:
            snap = await self.run(self.db.collection(self.col).document(doctor_id).get)
            return doc_to_dict(snap) if snap.exists else None
        return MEMORY.doctors.get(doctor_id)

    async def _all(self) -> list[dict]:
        if self.db is not None:
            snaps = await self.run(lambda: list(self.db.collection(self.col).stream()))
            return [doc_to_dict(s) for s in snaps]
        return list(MEMORY.doctors.values())


_ = utcnow
