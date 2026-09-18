"""Medicine routes — scan (vision), compare by name, guided info, search."""
from fastapi import APIRouter, Depends, File, Query, Request, UploadFile

from app.api.limiter import limiter
from app.core.config import Settings, get_settings
from app.core.security import CurrentUser, get_current_user
from app.schemas.medicine import CompareRequest, MedicineAnalysis, MedicineSummary
from app.services.medicine_service import MedicineService

router = APIRouter(prefix="/medicines", tags=["medicines"])


@router.post("/analyze", response_model=list[MedicineAnalysis])
@limiter.limit("10/minute")
async def analyze(request: Request,
                  images: list[UploadFile] = File(description="Up to 4 label photos"),
                  settings: Settings = Depends(get_settings),
                  user: CurrentUser = Depends(get_current_user)) -> list[MedicineAnalysis]:
    _ = user
    files = [(img.filename or "image", await img.read()) for img in images]
    return await MedicineService(settings).analyze(files)


@router.post("/compare", response_model=list[MedicineAnalysis])
@limiter.limit("10/minute")
async def compare(request: Request, payload: CompareRequest,
                  settings: Settings = Depends(get_settings),
                  user: CurrentUser = Depends(get_current_user)) -> list[MedicineAnalysis]:
    _ = user
    return await MedicineService(settings).compare(payload.analyses)


@router.get("/info", response_model=MedicineAnalysis)
@limiter.limit("30/minute")
async def info(request: Request,
               name: str = Query(min_length=2, max_length=120),
               settings: Settings = Depends(get_settings),
               user: CurrentUser = Depends(get_current_user)) -> MedicineAnalysis:
    _ = user
    return await MedicineService(settings).info_by_name(name)


@router.get("/search", response_model=list[MedicineSummary])
async def search(query: str = Query(min_length=2, max_length=80),
                 settings: Settings = Depends(get_settings),
                 user: CurrentUser = Depends(get_current_user)) -> list[MedicineSummary]:
    _ = user
    return await MedicineService(settings).search(query)
