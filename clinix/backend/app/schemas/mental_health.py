"""Mental-health screening schemas — mirror Flutter MentalHealth* models.

CRITICAL: `band` literals match Dart WellbeingBand `.name` values EXACTLY:
'stable', 'mildConcern', 'elevatedConcern' (camelCase on purpose)."""
from typing import Literal

from pydantic import BaseModel, Field

WellbeingBand = Literal["stable", "mildConcern", "elevatedConcern"]


class MentalHealthAnswer(BaseModel):
    question_id: str
    selected_option_index: int = Field(ge=0, le=10)
    score: int = Field(ge=0, le=10)


class MentalHealthQuestionBrief(BaseModel):
    """Question text context; optional so the backend can enrich observations
    without owning the canonical question list (which lives in Flutter today)."""
    id: str
    text: str = ""
    options: list[str] = Field(default_factory=list)


class ScreeningAnalyzeRequest(BaseModel):
    answers: list[MentalHealthAnswer] = Field(min_length=1, max_length=40)
    questions: list[MentalHealthQuestionBrief] = Field(default_factory=list)


class MentalHealthResult(BaseModel):
    band: WellbeingBand
    summary: str
    observations: list[str]
    coping_suggestions: list[str]
    lifestyle_suggestions: list[str]
    seek_help_guidance: str
    total_score: int = 0
    max_score: int = 0
    is_ai_generated: bool = True
