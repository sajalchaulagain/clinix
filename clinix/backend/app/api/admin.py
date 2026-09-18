"""Admin routes — every one gated by require_admin (verified custom claim,
checked on the server regardless of what the Flutter UI hides)."""
from fastapi import APIRouter, Depends, HTTPException, Query

from app.core.config import Settings, get_settings
from app.core.security import CurrentUser, require_admin
from app.repositories.blood_repository import BloodRepository
from app.repositories.doctor_repository import DoctorRepository
from app.repositories.donor_repository import DonorRepository
from app.repositories.hospital_repository import HospitalRepository
from app.repositories.notification_repository import NotificationRepository
from app.repositories.user_repository import UserRepository
from app.schemas.admin import AdminStats, BroadcastRequest, BroadcastResult
from app.schemas.blood import BloodRequest, BloodRequestStatusUpdate, BloodStock, BloodStockUpsert
from app.schemas.common import MessageOut
from app.schemas.donor import Donor
from app.schemas.hospital import Hospital, HospitalUpsert
from app.schemas.user import UserProfileOut
from app.services.admin_service import AdminService
from app.services.blood_service import BloodService
from app.services.notification_service import NotificationService

router = APIRouter(prefix="/admin", tags=["admin"],
                   dependencies=[Depends(require_admin)])


def _admin_service() -> AdminService:
    return AdminService(UserRepository(), DonorRepository(), BloodRepository(),
                        HospitalRepository(), DoctorRepository())


@router.get("/stats", response_model=AdminStats)
async def stats() -> AdminStats:
    return await _admin_service().stats()


# --------------------------------------------------------- blood inventory
@router.get("/blood-inventory", response_model=list[BloodStock])
async def list_inventory() -> list[BloodStock]:
    return [BloodStock(**r) for r in await BloodRepository().all_stock()]


@router.post("/blood-inventory", response_model=BloodStock, status_code=201)
async def create_inventory(payload: BloodStockUpsert) -> BloodStock:
    service = BloodService(BloodRepository())
    return BloodStock(**await service.upsert_stock(payload))


@router.put("/blood-inventory/{stock_id}", response_model=BloodStock)
async def update_inventory(stock_id: str, payload: BloodStockUpsert) -> BloodStock:
    service = BloodService(BloodRepository())
    return BloodStock(**await service.update_stock(stock_id, payload))


@router.delete("/blood-inventory/{stock_id}", response_model=MessageOut)
async def delete_inventory(stock_id: str) -> MessageOut:
    service = BloodService(BloodRepository())
    await service.delete_stock(stock_id)
    return MessageOut(detail="Blood stock entry deleted.")


# --------------------------------------------------------- blood requests
@router.get("/blood-requests", response_model=list[BloodRequest])
async def admin_blood_requests(status: str | None = Query(default=None)) -> list[BloodRequest]:
    rows = await BloodRepository().list_requests(status, None)
    return [BloodRequest(**r) for r in rows]


@router.put("/blood-requests/{request_id}/status", response_model=BloodRequest)
async def admin_set_request_status(request_id: str,
                                   payload: BloodRequestStatusUpdate) -> BloodRequest:
    service = BloodService(BloodRepository())
    return BloodRequest(**await service.change_status(request_id, payload.status))


# ------------------------------------------------------------------- others
@router.get("/donors", response_model=list[Donor])
async def admin_donors() -> list[Donor]:
    return [Donor(**r) for r in await DonorRepository().list_donors(None, None)]


@router.delete("/donors/{donor_id}", response_model=MessageOut)
async def admin_remove_donor(donor_id: str) -> MessageOut:
    if await DonorRepository().delete(donor_id) is None:
        raise HTTPException(status_code=404, detail="Donor not found.")
    return MessageOut(detail="Donor removed.")


@router.get("/hospitals", response_model=list[Hospital])
async def admin_hospitals() -> list[Hospital]:
    return [Hospital(**r) for r in await HospitalRepository().list_hospitals(None)]


@router.post("/hospitals", response_model=Hospital, status_code=201)
async def admin_create_hospital(payload: HospitalUpsert) -> Hospital:
    return Hospital(**await HospitalRepository().create(payload.model_dump()))


@router.put("/hospitals/{hospital_id}", response_model=Hospital)
async def admin_update_hospital(hospital_id: str, payload: HospitalUpsert) -> Hospital:
    # Full replace of editable fields only.
    row = await HospitalRepository().update(hospital_id, payload.model_dump())
    if row is None:
        raise HTTPException(status_code=404, detail="Hospital not found.")
    return Hospital(**row)


@router.delete("/hospitals/{hospital_id}", response_model=MessageOut)
async def admin_delete_hospital(hospital_id: str) -> MessageOut:
    if await HospitalRepository().delete(hospital_id) is None:
        raise HTTPException(status_code=404, detail="Hospital not found.")
    return MessageOut(detail="Hospital deleted.")


@router.get("/users", response_model=list[UserProfileOut])
async def admin_users() -> list[UserProfileOut]:
    return await _admin_service().all_users()


@router.post("/notifications/broadcast", response_model=BroadcastResult)
async def broadcast(payload: BroadcastRequest,
                    settings: Settings = Depends(get_settings),
                    admin: CurrentUser = Depends(require_admin)) -> BroadcastResult:
    _ = settings, admin
    service = NotificationService(NotificationRepository())
    recipients = await service.broadcast(payload.title, payload.body)
    return BroadcastResult(recipients=recipients,
                           note="Delivered to every registered device token.")
