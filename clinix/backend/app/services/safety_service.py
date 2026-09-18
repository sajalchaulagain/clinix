"""Keyword-based safety screening that runs BEFORE any AI call.

Cheap, deterministic detection of emergencies / self-harm signals so the
AI never improvises crisis handling. Not a medical classifier — it only
decides "should we escalate the response framing right now".
"""
import re

from app.core.config import Settings

EMERGENCY_PATTERNS = [
    r"chest\s*pain|heart\s*attack|can'?t\s*breathe|breathing\s*(problem|difficulty)",
    r"stroke|collapsed|unconscious|seizure|severe\s*bleed|poison|overdose",
    r"anaphyl|allergic\s*reaction|swelling.*throat",
]
SELF_HARM_PATTERNS = [
    r"suicid|kill\s*my\s*self|end\s*my\s*life|self[-\s]*harm|want\s*to\s*die",
    r"no\s*reason\s*to\s*live|hurt(ing)?\s*myself",
]


def _matches(patterns: list[str], text: str) -> bool:
    return any(re.search(p, text, flags=re.IGNORECASE) for p in patterns)


def detect_emergency(text: str) -> bool:
    return _matches(EMERGENCY_PATTERNS, text)


def detect_self_harm(text: str) -> bool:
    return _matches(SELF_HARM_PATTERNS, text)


def emergency_message(settings: Settings) -> str:
    return (
        "This sounds like it could be a medical emergency.\n\n"
        f"{settings.emergency_guidance_text}\n\n"
        "Please don't wait for an online reply — call your local emergency number or get to the "
        "nearest emergency department immediately. If someone is with you, tell them now."
    )


def self_harm_message(settings: Settings) -> str:
    return (
        "I'm really glad you reached out, and I'm sorry it feels this heavy right now.\n\n"
        "Please reach out to someone right away — a trusted person, a crisis helpline, or "
        f"emergency services. {settings.emergency_guidance_text}\n\n"
        "You deserve support today, not someday. The CliniX well-being tools can support reflection, "
        "but they can't replace a human being in moments like this."
    )
