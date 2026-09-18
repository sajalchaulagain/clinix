from app.repositories.base import COLLECTIONS, MEMORY, Repository, doc_to_dict, new_id, utcnow


class HospitalRepository(Repository):
    col = COLLECTIONS["hospitals"]

    async def list_hospitals(self, location: str | None) -> list[dict]:
        rows = await self._all()
        if location:
            rows = [r for r in rows if location.lower() in r.get("location", "").lower()]
        return rows

    async def get(self, hospital_id: str) -> dict | None:
        if self.db is not None:
            snap = await self.run(self.db.collection(self.col).document(hospital_id).get)
            return doc_to_dict(snap) if snap.exists else None
        return MEMORY.hospitals.get(hospital_id)

    async def create(self, data: dict) -> dict:
        hospital_id = new_id()
        data = {**data, "id": hospital_id, "blood_units_by_group": {}, "last_updated": utcnow()}
        if self.db is not None:
            await self.run(self.db.collection(self.col).document(hospital_id).set, data)
        else:
            MEMORY.hospitals[hospital_id] = data
        return data

    async def update(self, hospital_id: str, patch: dict) -> dict | None:
        patch = {k: v for k, v in patch.items() if v is not None}
        patch["last_updated"] = utcnow()
        if self.db is not None:
            ref = self.db.collection(self.col).document(hospital_id)
            snap = await self.run(ref.get)
            if not snap.exists:
                return None
            await self.run(ref.set, patch, merge=True)
            return doc_to_dict(await self.run(ref.get))
        row = MEMORY.hospitals.get(hospital_id)
        if row is None:
            return None
        row.update(patch)
        return row

    async def delete(self, hospital_id: str) -> dict | None:
        if self.db is not None:
            ref = self.db.collection(self.col).document(hospital_id)
            snap = await self.run(ref.get)
            if not snap.exists:
                return None
            row = doc_to_dict(snap)
            await self.run(ref.delete)
            return row
        return MEMORY.hospitals.pop(hospital_id, None)

    async def count(self) -> int:
        return len(await self._all())

    async def _all(self) -> list[dict]:
        if self.db is not None:
            snaps = await self.run(lambda: list(self.db.collection(self.col).stream()))
            return [doc_to_dict(s) for s in snaps]
        return list(MEMORY.hospitals.values())
