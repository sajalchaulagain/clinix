"""User profile schemas — field-for-field compatible with Flutter UserModel
(lib/shared/models/user_model.dart)."""
from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field

Role = Literal["patient", "admin"]


class UserProfileOut(BaseModel):
    id: str
    full_name: str = ""
    email: str = ""
    role: Role = "patient"
    phone: str | None = None
    date_of_birth: datetime | None = None
    blood_group: str | None = None
    emergency_contact: str | None = None
    photo_url: str | None = None
    email_verified: bool = False
    created_at: datetime | None = None


class UserProfileUpdate(BaseModel):
    """Clients may update these fields only. id / role / email / email_verified
    are never accepted here — role changes happen via admin tooling + claims."""
    full_name: str | None = Field(default=None, min_length=3, max_length=120)
    phone: str | None = Field(default=None, max_length=20)
    date_of_birth: datetime | None = None
    blood_group: str | None = None
    emergency_contact: str | None = Field(default=None, max_length=20)
    photo_url: str | None = None
