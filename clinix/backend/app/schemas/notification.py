"""Notification schemas — mirror Flutter NotificationModel. `type` literals
match Dart AppNotificationType `.name` values (camelCase) exactly."""
from datetime import datetime
from typing import Any, Literal

from pydantic import BaseModel, Field

NotificationType = Literal[
    "reminder",
    "bloodRequest",
    "bloodAvailability",
    "system",
    "aiResult",
    "appointment",
]


class Notification(BaseModel):
    id: str
    type: NotificationType
    title: str
    body: str
    created_at: datetime
    is_read: bool = False
    payload: dict[str, Any] | None = None


class DeviceTokenIn(BaseModel):
    token: str = Field(min_length=10, max_length=512)
    platform: Literal["android", "ios", "web", "unknown"] = "unknown"
