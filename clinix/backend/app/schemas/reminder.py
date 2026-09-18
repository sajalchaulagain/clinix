"""Reminder schemas — mirror Flutter ReminderModel. Sync is OPTIONAL:
reminders stay offline-first with local notifications in Flutter; these
endpoints exist so schedules can be restored on new devices."""
from datetime import datetime
import re

from pydantic import BaseModel, Field, field_validator


class Reminder(BaseModel):
    id: str
    medicine_name: str
    dosage: str
    frequency: str
    times: list[str] = Field(default_factory=list)  # "HH:MM" 24h
    start_date: datetime
    end_date: datetime | None = None
    notes: str | None = None
    is_enabled: bool = True
    created_at: datetime | None = None

    @field_validator("times")
    @classmethod
    def validate_hhmm(cls, value: list[str]) -> list[str]:
        pattern = re.compile(r"^([01]\d|2[0-3]):[0-5]\d$")
        for t in value:
            if not pattern.match(t):
                raise ValueError("times must be 'HH:MM' in 24h format")
        return value


class ReminderUpsert(BaseModel):
    medicine_name: str = Field(min_length=2, max_length=120)
    dosage: str = Field(min_length=1, max_length=60)
    frequency: str = Field(min_length=2, max_length=60)
    times: list[str] = Field(min_length=1, max_length=8)
    start_date: datetime
    end_date: datetime | None = None
    notes: str | None = Field(default=None, max_length=300)
    is_enabled: bool = True

    @field_validator("times")
    @classmethod
    def validate_hhmm(cls, value: list[str]) -> list[str]:
        return Reminder.validate_hhmm(value)
