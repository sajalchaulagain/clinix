"""Donor schemas — mirror Flutter DonorModel. Note there is intentionally
NO phone/contact field anywhere: donor contact privacy is a hard design rule,
contact is always mediated by the platform."""
from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field


class Donor(BaseModel):
    id: str
    name: str
    blood_group: str
    location: str
    is_available: bool = False
    last_donation_date: datetime | None = None
    total_donations: int = 0


class BecomeDonorRequest(BaseModel):
    blood_group: Literal["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]
    location: str = Field(min_length=2, max_length=160)
    last_donation_date: datetime | None = None
    is_available: bool = True


class DonorContactRequest(BaseModel):
    note: str | None = Field(default=None, max_length=300)
