"""Donor routes."""
from fastapi import APIRouter, Depends, HTTPException, Query

from app.core.security import CurrentUser, get_current_user
from app.repositories.donor_repository import DonorRepository
from app.repositories.notification_repository import NotificationRepository
from app.schemas.donor import BecomeDonorRequest, Donor, DonorContactRequest
from app.services.donor_service import DonorService

router = APIRouter(prefix="/donors", tags=["donors"])


def _service() -> DonorService:
    return DonorService(DonorRepository(), NotificationRepository())


@router.get("", response_model=list[Donor])
async def list_donors(blood_group: str | None = Query(default=None),
                      location: str | None = Query(default=None),
                      user: CurrentUser = Depends(get_current_user)) -> list[Donor]:
    _ = user
    rows = await DonorRepository().list_donors(blood_group, location)
    return [Donor(**r) for r in rows]


@router.get("/me", response_model=Donor)
async def my_donor_profile(user: CurrentUser = Depends(get_current_user)) -> Donor:
    row = await DonorRepository().get(user.uid)
    if row is None:
        raise HTTPException(status_code=404, detail="You are not registered as a donor yet.")
    return Donor(**row)


@router.post("/me", response_model=Donor, status_code=201)
async def become_donor(payload: BecomeDonorRequest,
                       user: CurrentUser = Depends(get_current_user)) -> Donor:
    row = await _service().register(user.uid, user.name or user.email, payload)
    return Donor(**row)


@router.put("/me", response_model=Donor)
async def update_donor_availability(payload: BecomeDonorRequest,
                                    user: CurrentUser = Depends(get_current_user)) -> Donor:
    row = await _service().set_availability(user.uid, payload.is_available,
                                            payload.last_donation_date)
    if row is None:
        raise HTTPException(status_code=404, detail="You are not registered as a donor yet.")
    # Location/blood group edits go through the same doc; apply after availability.
    repo = DonorRepository()
    row = await repo.upsert_profile(user.uid, user.name or user.email, payload.model_dump())
    return Donor(**row)


@router.post("/{donor_id}/contact-request")
async def contact_request(donor_id: str, payload: DonorContactRequest,
                          user: CurrentUser = Depends(get_current_user)) -> dict:
    donor = await _service().request_contact(donor_id, user.name or user.email,
                                             user.uid, payload.note)
    if donor is None:
        raise HTTPException(status_code=404, detail="Donor not found.")
    return {"detail": "The donor has been notified through CliniX.", "donor_id": donor_id}
