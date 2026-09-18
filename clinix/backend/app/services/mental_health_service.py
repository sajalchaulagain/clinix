"""Well-being screening analysis.

The band is computed DETERMINISTICALLY from the scores (mirrors the Flutter
mock thresholds), and AI only writes the supportive narrative — the score
itself never depends on generated text. If AI narrative fails, the service
falls back to warm templated content. This endpoint is NON-DIAGNOSTIC.
"""
import json
import logging

from app.core.config import Settings
from app.integrations.openrouter import OpenRouterClient
from app.prompts.mental_health_prompt import MENTAL_HEALTH_NARRATIVE_PROMPT
from app.schemas.mental_health import (MentalHealthResult, ScreeningAnalyzeRequest,
                                        WellbeingBand)
from app.services import safety_service

logger = logging.getLogger("clinix.mental-health")

# Keep in sync with Flutter MOCK_MENTAL_HEALTH questions (max 3 per question).
_MAX_PER_QUESTION = 3


def _band(total: int, max_score: int) -> WellbeingBand:
    if max_score <= 0:
        return "stable"
    ratio = total / max_score
    if ratio <= 0.33:
        return "stable"
    if ratio <= 0.66:
        return "mildConcern"
    return "elevatedConcern"


_TEMPLATES: dict[WellbeingBand, dict] = {
    "stable": {
        "summary": "Your answers point to a generally stable week, with the usual ups and downs most people experience.",
        "observations": [
            "Energy and mood appear fairly steady across most areas.",
            "Everyday stress shows up occasionally rather than constantly.",
        ],
        "coping_suggestions": [
            "Keep doing what already works for you — routines, people, activities.",
            "Take short pauses on busier days before things pile up.",
        ],
        "lifestyle_suggestions": [
            "Keep a regular sleep schedule.",
            "A short daily walk goes a long way.",
            "Regular meals and hydration support steady energy.",
        ],
        "seek_help_guidance": "If things start feeling heavier or these patterns change, talking to a counsellor or doctor is a strength, not a weakness.",
    },
    "mildConcern": {
        "summary": "Your answers suggest some areas feel heavier than usual right now — worth a bit of extra care this week.",
        "observations": [
            "Some days look harder than others across energy, sleep or focus.",
            "Stress appears noticeable though not constant.",
        ],
        "coping_suggestions": [
            "Try a 5-minute slow-breathing break when things feel heavy.",
            "Break tasks into smaller, doable steps.",
            "Talking it out with someone you trust often helps.",
        ],
        "lifestyle_suggestions": [
            "Keep a steady sleep/wake time even on harder days.",
            "Gentle movement — a short walk, stretching — can lift the load.",
            "Limit caffeine later in the day.",
        ],
        "seek_help_guidance": "If these feelings persist for a couple of weeks, or start affecting daily life, consider speaking with a counsellor or doctor.",
    },
    "elevatedConcern": {
        "summary": "Your answers suggest you're carrying a lot right now. That's hard, and it's okay to lean on support.",
        "observations": [
            "Several areas — energy, sleep, mood — look strained at the same time.",
            "Daily tasks may be taking noticeably more effort than usual.",
        ],
        "coping_suggestions": [
            "Focus on the smallest next step, not the whole mountain.",
            "Reach out to one trusted person today, even briefly.",
            "Slow breathing (in 4, out 6) can ease acute waves.",
        ],
        "lifestyle_suggestions": [
            "Protect sleep as carefully as you can this week.",
            "Short, gentle activity — even a few minutes — can help.",
            "Eat and hydrate regularly, even when appetite is low.",
        ],
        "seek_help_guidance": "Please consider reaching out to a mental-health professional or a doctor soon — soon is better than later. If you ever feel unsafe or at risk of harming yourself, contact emergency services or a crisis helpline immediately.",
    },
}


class MentalHealthService:
    def __init__(self, settings: Settings) -> None:
        self.settings = settings
        self.openrouter = OpenRouterClient(settings)

    async def analyze(self, request: ScreeningAnalyzeRequest) -> MentalHealthResult:
        total = sum(a.score for a in request.answers)
        max_score = len(request.answers) * _MAX_PER_QUESTION
        band = _band(total, max_score)

        joined = " ".join(a.question_id for a in request.answers)
        if safety_service.detect_self_harm(joined):
            # Extremely rare (question ids are static), but the guard is cheap.
            result = MentalHealthResult(band="elevatedConcern", total_score=total,
                                        max_score=max_score, **_TEMPLATES["elevatedConcern"])
            result.seek_help_guidance = safety_service.self_harm_message(self.settings)
            return result

        narrative = await self._narrative(band)
        base = _TEMPLATES[band]
        return MentalHealthResult(
            band=band,
            summary=narrative.get("summary") or base["summary"],
            observations=narrative.get("observations") or base["observations"],
            coping_suggestions=narrative.get("coping_suggestions") or base["coping_suggestions"],
            lifestyle_suggestions=narrative.get("lifestyle_suggestions") or base["lifestyle_suggestions"],
            seek_help_guidance=narrative.get("seek_help_guidance") or base["seek_help_guidance"],
            total_score=total,
            max_score=max_score,
            is_ai_generated=True,
        )

    async def _narrative(self, band: WellbeingBand) -> dict:
        try:
            raw = await self.openrouter.complete_chat(
                [
                    {"role": "system", "content": MENTAL_HEALTH_NARRATIVE_PROMPT},
                    {"role": "user", "content": f"Screening band: {band}. Write the narrative."},
                ],
                json_mode=True,
            )
            text = raw.strip()
            start, end = text.find("{"), text.rfind("}")
            payload = json.loads(text[start:end + 1]) if start >= 0 else {}
            # Allow only the narrative keys; band stays server-computed.
            return {k: payload[k] for k in
                    ("summary", "observations", "coping_suggestions",
                     "lifestyle_suggestions", "seek_help_guidance") if k in payload}
        except Exception as exc:
            logger.warning("mental-health narrative fallback: %s", exc)
            return {}
