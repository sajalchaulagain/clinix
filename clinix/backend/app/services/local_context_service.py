"""Local Context Service for RAG grounding into AI system prompts."""
import logging

from app.core.config import Settings
from app.repositories.blood_repository import BloodRepository
from app.repositories.hospital_repository import HospitalRepository

logger = logging.getLogger("clinix.local_context")


async def get_blood_summary(settings: Settings) -> str:
    """Returns top blood stock entries formatted for AI prompt grounding."""
    try:
        repo = BloodRepository()
        rows = await repo.all_stock()
        if not rows:
            return ""
        avail = [r for r in rows if r.get("units_available", 0) > 0]
        avail.sort(key=lambda r: -r.get("units_available", 0))
        lines = []
        for r in avail[:15]:
            bg = r.get("blood_group", "Unknown")
            u = r.get("units_available", 0)
            hosp = r.get("hospital_name") or r.get("hospital_id") or "Local Bank"
            loc = r.get("location", "")
            loc_str = f" ({loc})" if loc else ""
            lines.append(f"• {bg}: {u}u @ {hosp}{loc_str}")
        return "\n".join(lines)
    except Exception as exc:
        logger.warning("Failed to fetch blood summary for grounding: %s", exc)
        return ""


async def get_hospital_list(settings: Settings) -> str:
    """Returns Kathmandu Valley hospitals formatted for AI prompt grounding."""
    try:
        repo = HospitalRepository()
        rows = await repo.list_hospitals(location=None)
        if not rows:
            return ""
        lines = []
        for r in rows[:12]:
            name = r.get("name", "")
            loc = r.get("location", "")
            phone = r.get("phone")
            phone_str = f" - Phone: {phone}" if phone else ""
            lines.append(f"• {name} ({loc}){phone_str}")
        return "\n".join(lines)
    except Exception as exc:
        logger.warning("Failed to fetch hospital list for grounding: %s", exc)
        return ""
