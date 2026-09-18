"""Auth routes — prefix /auth (mounted under /api/v1)."""
from fastapi import APIRouter, Depends, HTTPException

from app.core.security import CurrentUser, get_current_user
from app.repositories.user_repository import UserRepository
from app.schemas.user import UserProfileOut, UserProfileUpdate

router = APIRouter(prefix="/auth", tags=["auth"])


@router.get("/me", response_model=UserProfileOut)
async def get_me(user: CurrentUser = Depends(get_current_user)) -> UserProfileOut:
    """Returns (or lazily creates) the caller's profile. UID + role come from
    the verified token only."""
    repo = UserRepository()
    profile = await repo.upsert_initial(
        uid=user.uid, email=user.email, name=user.name,
        role=user.role, email_verified=user.email_verified,
    )
    assert profile is not None
    return UserProfileOut(**profile)


@router.put("/users/me", response_model=UserProfileOut)
async def update_me(update: UserProfileUpdate,
                    user: CurrentUser = Depends(get_current_user)) -> UserProfileOut:
    repo = UserRepository()
    await repo.upsert_initial(user.uid, user.email, user.name, user.role, user.email_verified)
    profile = await repo.update(user.uid, update)
    if profile is None:
        raise HTTPException(status_code=404, detail="Profile not found.")
    return UserProfileOut(**profile)
