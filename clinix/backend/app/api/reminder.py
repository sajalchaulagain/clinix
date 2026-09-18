"""Reminder sync routes. Reminders remain offline-first in Flutter;
these endpoints mirror them for backup/restore."""
from fastapi import APIRouter, Depends

from app.core.security import CurrentUser, get_current_user
from app.repositories.reminder_repository import ReminderRepository
from app.schemas.common import MessageOut
from app.schemas.reminder import Reminder, ReminderUpsert

router = APIRouter(prefix="/reminders", tags=["reminders"])


@router.get("", response_model=list[Reminder])
async def list_reminders(user: CurrentUser = Depends(get_current_user)) -> list[Reminder]:
    return [Reminder(**r) for r in await ReminderRepository().list_all(user.uid)]


@router.post("", response_model=Reminder, status_code=201)
async def create_reminder(payload: ReminderUpsert,
                          user: CurrentUser = Depends(get_current_user)) -> Reminder:
    return Reminder(**await ReminderRepository().create(user.uid, payload.model_dump()))


@router.put("/{reminder_id}", response_model=Reminder)
async def update_reminder(reminder_id: str, payload: ReminderUpsert,
                          user: CurrentUser = Depends(get_current_user)) -> Reminder:
    row = await ReminderRepository().update(user.uid, reminder_id, payload.model_dump())
    if row is None:
        from fastapi import HTTPException
        raise HTTPException(status_code=404, detail="Reminder not found.")
    return Reminder(**row)


@router.delete("/{reminder_id}", response_model=MessageOut)
async def delete_reminder(reminder_id: str,
                          user: CurrentUser = Depends(get_current_user)) -> MessageOut:
    if not await ReminderRepository().delete(user.uid, reminder_id):
        from fastapi import HTTPException
        raise HTTPException(status_code=404, detail="Reminder not found.")
    return MessageOut(detail="Reminder deleted.")
