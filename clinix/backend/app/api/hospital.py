"""Hospital discovery routes (admin CRUD lives under /admin/hospitals)."""
from fastapi import APIRouter, Depends, HTTPException, Query

from app.core.security import CurrentUser, get_current_user
from app.repositories.hospital_repository import HospitalRepository
from app.schemas.hospital import Hospital

router = APIRouter(prefix="/hospitals", tags=["hospitals"])


@router.get("", response_model=list[Hospital])
async def list_hospitals(location: str | None = Query(default=None),
                         user: CurrentUser = Depends(get_current_user)) -> list[Hospital]:
    _ = user
    return [Hospital(**r) for r in await HospitalRepository().list_hospitals(location)]


@router.get("/{hospital_id}", response_model=Hospital)
async def get_hospital(hospital_id: str,
                       user: CurrentUser = Depends(get_current_user)) -> Hospital:
    _ = user
    row = await HospitalRepository().get(hospital_id)
    if row is None:
        raise HTTPException(status_code=404, detail="Hospital not found.")
    return Hospital(**row)
