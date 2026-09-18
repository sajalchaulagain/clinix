"""Mental-health screening routes."""
from fastapi import APIRouter, Depends, Request

from app.api.limiter import limiter
from app.core.config import Settings, get_settings
from app.core.security import CurrentUser, get_current_user
from app.schemas.mental_health import MentalHealthResult, ScreeningAnalyzeRequest
from app.services.mental_health_service import MentalHealthService

router = APIRouter(prefix="/mental-health", tags=["mental-health"])


@router.post("/analyze", response_model=MentalHealthResult)
@limiter.limit("10/minute")
async def analyze(request: Request, payload: ScreeningAnalyzeRequest,
                  settings: Settings = Depends(get_settings),
                  user: CurrentUser = Depends(get_current_user)) -> MentalHealthResult:
    # NON-DIAGNOSTIC: see docs/medical-safety.md.
    _ = user
    return await MentalHealthService(settings).analyze(payload)
