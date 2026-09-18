"""Hospital schemas — mirror Flutter HospitalModel."""
from datetime import datetime

from pydantic import BaseModel, Field


class Hospital(BaseModel):
    id: str
    name: str
    location: str
    phone: str | None = None
    is_open_24_hours: bool = False
    # Flutter renders this map verbatim as availability chips.
    blood_units_by_group: dict[str, int] = Field(default_factory=dict)
    last_updated: datetime


class HospitalUpsert(BaseModel):
    name: str = Field(min_length=2, max_length=160)
    location: str = Field(min_length=2, max_length=160)
    phone: str | None = Field(default=None, max_length=25)
    is_open_24_hours: bool = False
