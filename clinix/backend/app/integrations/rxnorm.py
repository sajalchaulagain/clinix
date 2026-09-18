"""RxNorm integration: drug-name normalization (RxCUI, generic/brand links).

IMPORTANT: we deliberately do NOT call any retired/discontinued RxNav
interaction endpoint. Interaction information comes from openFDA label text +
clearly-labelled AI interpretation instead. RxNorm is used only for concept
normalization, which is stable and documented.
"""
import logging
import re

import httpx

from app.core.config import Settings

logger = logging.getLogger("clinix.rxnorm")


class RxNormClient:
    def __init__(self, settings: Settings) -> None:
        self._settings = settings

    async def normalize(self, name: str) -> dict | None:
        """Return {'rxcui', 'name', 'synonym'} or None. Soft-fails to None."""
        if self._settings.mock_external_services:
            return self._mock_normalize(name)
        cleaned = re.sub(r"[^a-zA-Z0-9 \-]", "", name).strip()
        if not cleaned:
            return None
        try:
            async with httpx.AsyncClient(timeout=self._settings.external_api_timeout) as http:
                response = await http.get(
                    f"{self._settings.rxnorm_base_url}/drugs.json",
                    params={"name": cleaned},
                )
                response.raise_for_status()
                data = response.json()
        except (httpx.HTTPError, ValueError) as exc:
            logger.warning("RxNorm lookup failed for %r: %s", cleaned, exc)
            return None

        concepts = (data.get("drugGroup", {}) or {}).get("conceptGroup", []) or []
        for group in concepts:
            for props in group.get("conceptProperties", []) or []:
                return {
                    "rxcui": props.get("rxcui"),
                    "name": props.get("name"),
                    "synonym": props.get("synonym") or None,
                }
        return None

    def _mock_normalize(self, name: str) -> dict | None:
        # Small deterministic table so dev mode shows the full pipeline.
        known = {
            "paracetamol": {"rxcui": "161", "name": "Acetaminophen", "synonym": "Paracetamol"},
            "acetaminophen": {"rxcui": "161", "name": "Acetaminophen", "synonym": "Paracetamol"},
            "ibuprofen": {"rxcui": "5640", "name": "Ibuprofen", "synonym": None},
            "cetirizine": {"rxcui": "20610", "name": "Cetirizine", "synonym": None},
            "amoxicillin": {"rxcui": "723", "name": "Amoxicillin", "synonym": None},
        }
        return known.get(name.strip().lower())
