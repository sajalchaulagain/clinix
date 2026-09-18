"""Blood availability & request routes.

Static segments ('my') are declared BEFORE path params so FastAPI routes
/blood/requests/my to the special handler instead of matching {request_id}.
"""
from fastapi import APIRouter, Depends, HTTPException, Query

from app.core.security import CurrentUser, get_current_user, require_admin
from app.repositories.blood_repository import BloodRepository
from app.schemas.blood import (BloodRequest, BloodRequestCreate,
                                BloodRequestStatusUpdate, BloodStock)
from app.services.blood_service import BloodService

router = APIRouter(prefix="/blood", tags=["blood"])


# ------------------------------------------------------------------- stock
@router.get("/stock", response_model=list[BloodStock])
async def list_stock(blood_group: str | None = Query(default=None),
                     location: str | None = Query(default=None),
                     low_stock: bool = Query(default=False),
                     user: CurrentUser = Depends(get_current_user)) -> list[BloodStock]:
    _ = user
    rows = await BloodRepository().list_stock(blood_group, location, low_stock)
    return [BloodStock(**r) for r in rows]


@router.get("/stock/{stock_id}", response_model=BloodStock)
async def get_stock(stock_id: str,
                    user: CurrentUser = Depends(get_current_user)) -> BloodStock:
    _ = user
    row = await BloodRepository().get_stock(stock_id)
    if row is None:
        raise HTTPException(status_code=404, detail="Blood stock entry not found.")
    return BloodStock(**row)


# ---------------------------------------------------------------- requests
@router.get("/requests", response_model=list[BloodRequest])
async def list_requests(status: str | None = Query(default=None),
                        blood_group: str | None = Query(default=None),
                        user: CurrentUser = Depends(get_current_user)) -> list[BloodRequest]:
    _ = user
    rows = await BloodRepository().list_requests(status, blood_group)
    return [BloodRequest(**r) for r in rows]


@router.get("/requests/my", response_model=list[BloodRequest])
async def my_requests(user: CurrentUser = Depends(get_current_user)) -> list[BloodRequest]:
    rows = await BloodRepository().list_requests(None, None, requester_uid=user.uid)
    return [BloodRequest(**r) for r in rows]


@router.post("/requests", response_model=BloodRequest, status_code=201)
async def create_request(payload: BloodRequestCreate,
                         user: CurrentUser = Depends(get_current_user)) -> BloodRequest:
    service = BloodService(BloodRepository())
    row = await service.create_request(user.name or user.email, user.uid, payload)
    return BloodRequest(**row)


@router.get("/requests/{request_id}", response_model=BloodRequest)
async def get_request(request_id: str,
                      user: CurrentUser = Depends(get_current_user)) -> BloodRequest:
    _ = user
    row = await BloodRepository().get_request(request_id)
    if row is None:
        raise HTTPException(status_code=404, detail="Blood request not found.")
    return BloodRequest(**row)


@router.put("/requests/{request_id}/status", response_model=BloodRequest)
async def set_status(request_id: str, payload: BloodRequestStatusUpdate,
                     admin: CurrentUser = Depends(require_admin)) -> BloodRequest:
    """Only admins change request status; lifecycle rules live in the service."""
    _ = admin
    service = BloodService(BloodRepository())
    row = await service.change_status(request_id, payload.status)
    return BloodRequest(**row)
