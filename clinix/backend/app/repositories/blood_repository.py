"""Blood stock + request persistence.

Business invariants enforced here (not by the client): units never negative,
status transitions validated by the service, and hospital availability maps are
recomputed from stock after every unit change.
"""
from datetime import datetime

from app.repositories.base import COLLECTIONS, MEMORY, Repository, doc_to_dict, new_id, utcnow


class BloodRepository(Repository):
    stock_col = COLLECTIONS["blood_stock"]
    req_col = COLLECTIONS["blood_requests"]
    hosp_col = COLLECTIONS["hospitals"]

    # ------------------------------------------------------------------ stock
    async def list_stock(self, blood_group: str | None, location: str | None,
                         low_stock: bool = False) -> list[dict]:
        def match(row: dict) -> bool:
            if blood_group and row.get("blood_group", "").lower() != blood_group.lower():
                return False
            if location and location.lower() not in row.get("location", "").lower():
                return False
            if low_stock and row.get("units_available", 0) > 5:
                return False
            return True

        rows = await self._all(self.stock_col, MEMORY.blood_stock)
        return sorted((r for r in rows if match(r)),
                      key=lambda r: (r["blood_group"], -r.get("units_available", 0)))

    async def all_stock(self) -> list[dict]:
        return await self._all(self.stock_col, MEMORY.blood_stock)

    async def get_stock(self, stock_id: str) -> dict | None:
        if self.db is not None:
            snap = await self.run(self.db.collection(self.stock_col).document(stock_id).get)
            return doc_to_dict(snap) if snap.exists else None
        return MEMORY.blood_stock.get(stock_id)

    async def create_stock(self, data: dict) -> dict:
        stock_id = data.pop("id", None) or new_id()
        data = {**data, "id": stock_id, "last_updated": utcnow()}
        if self.db is not None:
            await self.run(self.db.collection(self.stock_col).document(stock_id).set, data)
        else:
            MEMORY.blood_stock[stock_id] = data
        await self._recompute_hospital_units(data.get("hospital_id"))
        return data

    async def update_stock(self, stock_id: str, patch: dict) -> dict | None:
        patch = {k: v for k, v in patch.items() if v is not None}
        patch["last_updated"] = utcnow()
        if self.db is not None:
            ref = self.db.collection(self.stock_col).document(stock_id)

            def _tx() -> dict | None:
                snap = ref.get()
                if not snap.exists:
                    return None
                ref.set(patch, merge=True)
                return doc_to_dict(ref.get())

            result = await self.run(_tx)
        else:
            row = MEMORY.blood_stock.get(stock_id)
            if row is None:
                return None
            row.update(patch)
            result = row
        if result:
            await self._recompute_hospital_units(result.get("hospital_id"))
        return result

    async def delete_stock(self, stock_id: str) -> dict | None:
        if self.db is not None:
            ref = self.db.collection(self.stock_col).document(stock_id)
            snap = await self.run(ref.get)
            if not snap.exists:
                return None
            row = doc_to_dict(snap)
            await self.run(ref.delete)
        else:
            row = MEMORY.blood_stock.pop(stock_id, None)
        if row:
            await self._recompute_hospital_units(row.get("hospital_id"))
        return row

    async def decrement_units(self, stock_id: str, units: int) -> dict:
        """Transactional decrement — units never go below zero."""
        if units <= 0:
            raise ValueError("units must be positive")
        if self.db is not None:
            ref = self.db.collection(self.stock_col).document(stock_id)

            def _tx(transaction):
                snap = ref.get(transaction=transaction)
                if not snap.exists:
                    raise LookupError("stock not found")
                current = snap.to_dict().get("units_available", 0)
                if current < units:
                    raise ValueError("not enough units available")
                transaction.update(ref, {"units_available": current - units,
                                          "last_updated": utcnow()})
                return current - units

            transaction = self.db.transaction()
            remaining = await self.run(_tx, transaction)
        else:
            row = MEMORY.blood_stock.get(stock_id)
            if row is None:
                raise LookupError("stock not found")
            if row.get("units_available", 0) < units:
                raise ValueError("not enough units available")
            row["units_available"] -= units
            row["last_updated"] = utcnow()
            remaining = row["units_available"]

        row = await self.get_stock(stock_id)
        await self._recompute_hospital_units((row or {}).get("hospital_id"))
        return {"id": stock_id, "units_available": remaining}

    async def total_units(self) -> int:
        return sum(r.get("units_available", 0) for r in await self.all_stock())

    # --------------------------------------------------------------- requests
    async def list_requests(self, status: str | None, blood_group: str | None,
                            requester_uid: str | None = None) -> list[dict]:
        rows = await self._all(self.req_col, MEMORY.blood_requests)
        def match(row: dict) -> bool:
            if requester_uid and row.get("requester_uid") != requester_uid:
                return False
            if status and row.get("status") != status:
                return False
            if blood_group and row.get("blood_group", "").lower() != blood_group.lower():
                return False
            return True
        return sorted((r for r in rows if match(r)),
                      key=lambda r: r.get("created_at") or datetime.min.replace().now(utcnow().tzinfo),
                      reverse=True)

    async def get_request(self, request_id: str) -> dict | None:
        if self.db is not None:
            snap = await self.run(self.db.collection(self.req_col).document(request_id).get)
            return doc_to_dict(snap) if snap.exists else None
        return MEMORY.blood_requests.get(request_id)

    async def create_request(self, data: dict) -> dict:
        request_id = new_id()
        data = {**data, "id": request_id, "status": "pending", "created_at": utcnow()}
        if self.db is not None:
            await self.run(self.db.collection(self.req_col).document(request_id).set, data)
        else:
            MEMORY.blood_requests[request_id] = data
        return data

    async def update_request_status(self, request_id: str, status: str) -> dict | None:
        patch = {"status": status, "updated_at": utcnow()}
        if self.db is not None:
            ref = self.db.collection(self.req_col).document(request_id)
            snap = await self.run(ref.get)
            if not snap.exists:
                return None
            await self.run(ref.set, patch, merge=True)
            return doc_to_dict(await self.run(ref.get))
        row = MEMORY.blood_requests.get(request_id)
        if row is None:
            return None
        row.update(patch)
        return row

    async def count_requests(self, status: str | None = None) -> int:
        return len(await self.list_requests(status, None))

    # ---------------------------------------------------------------- helper
    async def _all(self, collection: str, memory: dict) -> list[dict]:
        if self.db is not None:
            snaps = await self.run(lambda: list(self.db.collection(collection).stream()))
            return [doc_to_dict(s) for s in snaps]
        return list(memory.values())

    async def _recompute_hospital_units(self, hospital_id: str | None) -> None:
        """Keep hospitals/{id}.blood_units_by_group consistent with stock rows."""
        if not hospital_id:
            return
        stock = await self.all_stock()
        units: dict[str, int] = {}
        for row in stock:
            if row.get("hospital_id") == hospital_id and row.get("units_available", 0) > 0:
                group = row.get("blood_group")
                units[group] = units.get(group, 0) + row["units_available"]
        if self.db is not None:
            ref = self.db.collection(self.hosp_col).document(hospital_id)
            snap = await self.run(ref.get)
            if snap.exists:
                await self.run(ref.set, {"blood_units_by_group": units,
                                          "last_updated": utcnow()}, merge=True)
        elif hospital_id in MEMORY.hospitals:
            MEMORY.hospitals[hospital_id]["blood_units_by_group"] = units
            MEMORY.hospitals[hospital_id]["last_updated"] = utcnow()
