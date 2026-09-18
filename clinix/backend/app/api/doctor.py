"""Doctor discovery routes."""
from fastapi import APIRouter, Depends, HTTPException, Query

from app.core.security import CurrentUser, get_current_user
from app.repositories.doctor_repository import DoctorRepository
from app.schemas.doctor import Doctor

router = APIRouter(prefix="/doctors", tags=["doctors"])


@router.get("", response_model=list[Doctor])
async def list_doctors(specialty: str | None = Query(default=None),
                       location: str | None = Query(default=None),
                       available_today: bool = Query(default=False),
                       user: CurrentUser = Depends(get_current_user)) -> list[Doctor]:
    _ = user
    rows = await DoctorRepository().list_doctors(specialty, location, available_today)
    return [Doctor(**r) for r in rows]


@router.get("/recommended", response_model=list[Doctor])
async def recommended_doctors(user: CurrentUser = Depends(get_current_user)) -> list[Doctor]:
    _ = user
    return [Doctor(**r) for r in await DoctorRepository().recommended()]


@router.get("/{doctor_id}", response_model=Doctor)
async def get_doctor(doctor_id: str,
                     user: CurrentUser = Depends(get_current_user)) -> Doctor:
    _ = user
    row = await DoctorRepository().get(doctor_id)
    if row is None:
        raise HTTPException(status_code=404, detail="Doctor not found.")
    return Doctor(**row)
