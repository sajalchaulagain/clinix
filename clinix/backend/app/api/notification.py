"""Notification-center routes (per-user; scoped strictly by token uid)."""
from fastapi import APIRouter, Depends, HTTPException

from app.core.security import CurrentUser, get_current_user
from app.repositories.notification_repository import NotificationRepository
from app.schemas.common import MessageOut
from app.schemas.notification import DeviceTokenIn, Notification

router = APIRouter(prefix="/notifications", tags=["notifications"])


@router.get("", response_model=list[Notification])
async def list_notifications(user: CurrentUser = Depends(get_current_user)) -> list[Notification]:
    rows = await NotificationRepository().list_for(user.uid)
    return [Notification(**r) for r in rows]


@router.put("/{notification_id}/read", response_model=Notification)
async def mark_read(notification_id: str,
                    user: CurrentUser = Depends(get_current_user)) -> Notification:
    row = await NotificationRepository().mark_read(user.uid, notification_id)
    if row is None:
        raise HTTPException(status_code=404, detail="Notification not found.")
    return Notification(**row)


@router.put("/read-all", response_model=MessageOut)
async def mark_all_read(user: CurrentUser = Depends(get_current_user)) -> MessageOut:
    count = await NotificationRepository().mark_all_read(user.uid)
    return MessageOut(detail=f"Marked {count} notifications as read.")


@router.post("/device-token", response_model=MessageOut)
async def register_device_token(payload: DeviceTokenIn,
                                user: CurrentUser = Depends(get_current_user)) -> MessageOut:
    await NotificationRepository().register_token(user.uid, payload.token, payload.platform)
    return MessageOut(detail="Device token registered.")
