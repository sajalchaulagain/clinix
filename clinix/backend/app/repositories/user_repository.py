from datetime import datetime, timezone

from app.repositories.base import COLLECTIONS, MEMORY, Repository, doc_to_dict, utcnow
from app.schemas.user import UserProfileOut, UserProfileUpdate


class UserRepository(Repository):
    col = COLLECTIONS["users"]

    async def upsert_initial(self, uid: str, email: str, name: str, role: str,
                             email_verified: bool) -> dict:
        """Create the profile doc on first login (idempotent)."""
        if self.db is not None:
            ref = self.db.collection(self.col).document(uid)

            def _tx() -> dict:
                snap = ref.get()
                if snap.exists:
                    data = doc_to_dict(snap)
                    # keep server-stored fields fresh but never trust client role
                    data["email"] = email or data.get("email", "")
                    data["email_verified"] = email_verified
                    if name and not data.get("full_name"):
                        data["full_name"] = name
                    ref.set(data, merge=True)
                    return data
                data = {
                    "id": uid, "full_name": name or "", "email": email or "",
                    "role": role, "phone": None, "date_of_birth": None,
                    "blood_group": None, "emergency_contact": None,
                    "photo_url": None, "email_verified": email_verified,
                    "created_at": utcnow(),
                }
                ref.set(data)
                return data

            return await self.run(_tx)

        user = MEMORY.users.get(uid)
        if user is None:
            user = {
                "id": uid, "full_name": name or "", "email": email or "",
                "role": role, "phone": None, "date_of_birth": None,
                "blood_group": None, "emergency_contact": None,
                "photo_url": None, "email_verified": email_verified,
                "created_at": utcnow(),
            }
            MEMORY.users[uid] = user
        return user

    async def get(self, uid: str) -> dict | None:
        if self.db is not None:
            snap = await self.run(self.db.collection(self.col).document(uid).get)
            return doc_to_dict(snap) if snap.exists else None
        return MEMORY.users.get(uid)

    async def update(self, uid: str, patch: UserProfileUpdate) -> dict | None:
        updates = {k: v for k, v in patch.model_dump().items() if v is not None}
        if not updates:
            return await self.get(uid)
        if self.db is not None:
            ref = self.db.collection(self.col).document(uid)

            def _tx() -> dict | None:
                snap = ref.get()
                if not snap.exists:
                    return None
                ref.set(updates, merge=True)
                return doc_to_dict(ref.get())

            return await self.run(_tx)
        user = MEMORY.users.get(uid)
        if user is None:
            return None
        user.update(updates)
        return user

    async def count(self) -> int:
        if self.db is not None:
            snaps = await self.run(lambda: list(self.db.collection(self.col).stream()))
            return len(snaps)
        return len(MEMORY.users)

    async def all_profiles(self) -> list[UserProfileOut]:
        if self.db is not None:
            snaps = await self.run(lambda: list(self.db.collection(self.col).stream()))
            return [UserProfileOut(**doc_to_dict(s)) for s in snaps]
        return [UserProfileOut(**{**u, "created_at": u.get("created_at") or utcnow()})
                for u in MEMORY.users.values()]


# Imported for potential date normalization by callers.
_ = datetime, timezone
