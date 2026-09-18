"""Blood schemas — mirror Flutter BloodStockModel / BloodRequestModel."""
from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field

BloodRequestStatus = Literal["pending", "approved", "fulfilled", "cancelled"]
BloodRequestUrgency = Literal["normal", "urgent", "critical"]
BLOOD_GROUPS = Literal["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]


class BloodStock(BaseModel):
    id: str
    blood_group: str
    hospital_name: str
    location: str
    units_available: int = Field(ge=0)  # never negative — hard business rule
    last_updated: datetime
    hospital_id: str | None = None


class BloodStockUpsert(BaseModel):
    blood_group: BLOOD_GROUPS
    hospital_name: str = Field(min_length=2, max_length=160)
    location: str = Field(min_length=2, max_length=160)
    units_available: int = Field(ge=0, le=100000)
    hospital_id: str | None = None


class BloodRequestCreate(BaseModel):
    blood_group: BLOOD_GROUPS
    units: int = Field(ge=1, le=20)
    hospital_name: str = Field(min_length=2, max_length=160)
    location: str = Field(min_length=2, max_length=160)
    urgency: BloodRequestUrgency = "normal"
    reason: str | None = Field(default=None, max_length=500)
    patient_name: str | None = Field(default=None, max_length=120)


class BloodRequest(BaseModel):
    id: str
    requester_name: str
    blood_group: str
    units: int
    hospital_name: str
    location: str
    status: BloodRequestStatus
    created_at: datetime
    urgency: BloodRequestUrgency = "normal"
    reason: str | None = None
    patient_name: str | None = None


class BloodRequestStatusUpdate(BaseModel):
    status: BloodRequestStatus
