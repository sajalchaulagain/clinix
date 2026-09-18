from app.repositories.base import COLLECTIONS, MEMORY, Repository, doc_to_dict, utcnow


class DonorRepository(Repository):
    col = COLLECTIONS["donors"]

    async def list_donors(self, blood_group: str | None, location: str | None) -> list[dict]:
        if self.db is not None:
            snaps = await self.run(lambda: list(self.db.collection(self.col).stream()))
            rows = [doc_to_dict(s) for s in snaps]
        else:
            rows = list(MEMORY.donors.values())
        def match(row: dict) -> bool:
            if blood_group and row.get("blood_group", "").lower() != blood_group.lower():
                return False
            if location and location.lower() not in row.get("location", "").lower():
                return False
            return True
        return [r for r in rows if match(r)]

    async def get(self, donor_id: str) -> dict | None:
        if self.db is not None:
            snap = await self.run(self.db.collection(self.col).document(donor_id).get)
            return doc_to_dict(snap) if snap.exists else None
        return MEMORY.donors.get(donor_id)

    async def upsert_profile(self, uid: str, name: str, patch: dict) -> dict:
        """donors/{uid} — doc id ties the donor profile to the account."""
        data = {
            "id": uid, "name": name or "CliniX donor", "is_available": True,
            "last_donation_date": None, "total_donations": 0, **patch,
            "updated_at": utcnow(),
        }
        if self.db is not None:
            await self.run(self.db.collection(self.col).document(uid).set, data, merge=True)
            snap = await self.run(self.db.collection(self.col).document(uid).get)
            return doc_to_dict(snap)
        MEMORY.donors[uid] = {**MEMORY.donors.get(uid, {"id": uid, "name": name or "CliniX donor",
                                                        "total_donations": 0}), **data}
        return MEMORY.donors[uid]

    async def update_availability(self, uid: str, is_available: bool,
                                  last_donation_date=None) -> dict | None:
        patch = {"is_available": is_available, "updated_at": utcnow()}
        if last_donation_date is not None:
            patch["last_donation_date"] = last_donation_date
        if self.db is not None:
            ref = self.db.collection(self.col).document(uid)
            snap = await self.run(ref.get)
            if not snap.exists:
                return None
            await self.run(ref.set, patch, merge=True)
            return doc_to_dict(await self.run(ref.get))
        row = MEMORY.donors.get(uid)
        if row is None:
            return None
        row.update(patch)
        return row

    async def count(self) -> int:
        if self.db is not None:
            snaps = await self.run(lambda: list(self.db.collection(self.col).stream()))
            return len(snaps)
        return len(MEMORY.donors)

    async def delete(self, donor_id: str) -> dict | None:
        if self.db is not None:
            ref = self.db.collection(self.col).document(donor_id)
            snap = await self.run(ref.get)
            if not snap.exists:
                return None
            row = doc_to_dict(snap)
            await self.run(ref.delete)
            return row
        return MEMORY.donors.pop(donor_id, None)
