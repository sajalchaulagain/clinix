"""Blood stock & request workflows.

Safety/business invariants live here: units never drop below zero, request
statuses follow an explicit lifecycle, and fulfilling a request decrements
stock transactionally via the repository.
"""
from fastapi import HTTPException

from app.repositories.blood_repository import BloodRepository
from app.schemas.blood import (BloodRequestCreate, BloodStockUpsert,
                                BloodRequestStatus)

# Explicit lifecycle — the UI hints at these transitions.
_ALLOWED_TRANSITIONS: dict[str, set[str]] = {
    "pending": {"approved", "fulfilled", "cancelled"},
    "approved": {"fulfilled", "cancelled"},
    "fulfilled": set(),
    "cancelled": set(),
}


class BloodService:
    def __init__(self, repo: BloodRepository) -> None:
        self.repo = repo

    async def upsert_stock(self, payload: BloodStockUpsert) -> dict:
        return await self.repo.create_stock(payload.model_dump())

    async def update_stock(self, stock_id: str, payload: BloodStockUpsert) -> dict:
        result = await self.repo.update_stock(stock_id, payload.model_dump())
        if result is None:
            raise HTTPException(status_code=404, detail="Blood stock entry not found.")
        return result

    async def delete_stock(self, stock_id: str) -> None:
        if await self.repo.delete_stock(stock_id) is None:
            raise HTTPException(status_code=404, detail="Blood stock entry not found.")

    async def create_request(self, requester_name: str, requester_uid: str,
                             payload: BloodRequestCreate) -> dict:
        data = payload.model_dump() | {"requester_name": requester_name or "CliniX user",
                                        "requester_uid": requester_uid}
        return await self.repo.create_request(data)

    async def change_status(self, request_id: str, new_status: BloodRequestStatus) -> dict:
        row = await self.repo.get_request(request_id)
        if row is None:
            raise HTTPException(status_code=404, detail="Blood request not found.")
        current = row.get("status", "pending")
        if new_status != current and new_status not in _ALLOWED_TRANSITIONS.get(current, set()):
            raise HTTPException(
                status_code=409,
                detail=f"Cannot move a blood request from '{current}' to '{new_status}'.",
            )
        updated = await self.repo.update_request_status(request_id, new_status)
        assert updated is not None
        return updated
