"""Doctor schemas — mirror Flutter DoctorModel."""
from pydantic import BaseModel, Field


class Doctor(BaseModel):
    id: str
    name: str
    specialty: str
    hospital_name: str
    location: str
    rating: float = Field(default=0, ge=0, le=5)
    years_experience: int = Field(default=0, ge=0)
    consultation_fee: float | None = Field(default=None, ge=0)
    image_url: str | None = None
    is_available_today: bool = False
    bio: str | None = None
