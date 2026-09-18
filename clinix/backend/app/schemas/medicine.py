"""Medicine schemas — mirror Flutter MedicineAnalysisModel /
MedicineInteractionModel / MedicineModel."""
from typing import Literal

from pydantic import BaseModel, Field

InteractionSeverity = Literal["mild", "moderate", "severe"]


class MedicineInteraction(BaseModel):
    interacts_with: str
    severity: InteractionSeverity
    description: str


class MedicineAnalysis(BaseModel):
    medicine_name: str
    generic_name: str | None = None
    common_uses: list[str] = Field(default_factory=list)
    dosage_information: str | None = None
    common_side_effects: list[str] = Field(default_factory=list)
    precautions: list[str] = Field(default_factory=list)
    warnings: list[str] = Field(default_factory=list)
    contraindications: list[str] = Field(default_factory=list)
    interactions: list[MedicineInteraction] = Field(default_factory=list)
    storage_information: str | None = None
    is_ai_generated: bool = True  # drives Flutter's safety labeling — keep true


class MedicineSummary(BaseModel):
    """Flutter MedicineModel."""
    id: str
    name: str
    generic_name: str | None = None
    manufacturer: str | None = None
    category: str | None = None
    description: str | None = None


class CompareRequest(BaseModel):
    # Flutter sends 2-4 analyses selected in the scanner.
    analyses: list[MedicineAnalysis] = Field(min_length=2, max_length=4)
