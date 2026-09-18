"""Admin schemas."""
from pydantic import BaseModel, Field


class AdminStats(BaseModel):
    total_donors: int = 0
    available_blood_units: int = 0
    total_blood_requests: int = 0
    registered_hospitals: int = 0
    pending_requests: int = 0
    total_users: int = 0


class BroadcastRequest(BaseModel):
    title: str = Field(min_length=2, max_length=120)
    body: str = Field(min_length=2, max_length=500)


class BroadcastResult(BaseModel):
    recipients: int
    note: str = ""
