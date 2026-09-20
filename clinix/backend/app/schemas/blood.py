"""Blood schemas — mirror Flutter BloodStockModel / BloodRequestModel."""
import re
from datetime import date, datetime
from typing import Literal

from pydantic import BaseModel, Field, field_validator

BloodRequestStatus = Literal["pending", "approved", "fulfilled", "cancelled"]
BloodRequestUrgency = Literal["normal", "urgent", "critical"]
BLOOD_GROUPS = Literal["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]
DonationRequestStatus = Literal["pending", "confirmed", "completed", "cancelled"]


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


# ---------------------------------------------------------------- donation requests
_PHONE_RE = re.compile(r'^[+\d][\d\s\-]{5,14}$')


class DonationRequestCreate(BaseModel):
    donor_name: str = Field(min_length=2, max_length=120)
    phone: str = Field(min_length=7, max_length=20)
    blood_group: BLOOD_GROUPS
    units: int = Field(default=1, ge=1, le=2)
    hospital_name: str = Field(min_length=2, max_length=160)
    location: str = Field(min_length=2, max_length=160)
    preferred_date: date | None = None
    notes: str | None = Field(default=None, max_length=500)

    @field_validator('phone')
    @classmethod
    def validate_phone(cls, v: str) -> str:
        digits = re.sub(r'\D', '', v)
        if len(digits) < 7 or len(digits) > 15:
            raise ValueError('Phone must contain 7–15 digits')
        return v

    @field_validator('preferred_date')
    @classmethod
    def not_in_past(cls, v: date | None) -> date | None:
        if v is not None and v < date.today():
            raise ValueError('preferred_date cannot be in the past')
        return v


class DonationRequest(BaseModel):
    id: str
    user_id: str
    donor_name: str
    phone: str
    blood_group: str
    units: int
    hospital_name: str
    location: str
    preferred_date: date | None = None
    notes: str | None = None
    status: DonationRequestStatus
    created_at: datetime
