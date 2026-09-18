"""openFDA drug-label integration.

We fetch official label sections and NORMALIZE them into short plain strings —
raw openFDA JSON never crosses to Flutter. Failures are soft: callers get None
and proceed with AI-only data (clearly labelled) rather than crashing.
"""
import logging
import re
from dataclasses import dataclass, field

import httpx

from app.core.config import Settings
from app.core.exceptions import ExternalServiceError

logger = logging.getLogger("clinix.openfda")


@dataclass
class OpenFDALabel:
    brand_names: list[str] = field(default_factory=list)
    generic_name: str | None = None
    manufacturer: str | None = None
    uses: list[str] = field(default_factory=list)
    dosage: str | None = None
    side_effects: list[str] = field(default_factory=list)
    warnings: list[str] = field(default_factory=list)
    contraindications: list[str] = field(default_factory=list)
    interactions_text: str | None = None
    storage: str | None = None


class OpenFDAClient:
    def __init__(self, settings: Settings) -> None:
        self._settings = settings

    async def search_label(self, name: str) -> OpenFDALabel | None:
        if self._settings.mock_external_services:
            return self._mock_label(name)
        cleaned = re.sub(r"[^a-zA-Z0-9 \-]", "", name).strip()
        if not cleaned:
            return None
        query = (
            f'openfda.brand_name:"{cleaned}"+openfda.generic_name:"{cleaned}"'
        )
        params: dict = {"search": query, "limit": "1"}
        if self._settings.openfda_api_key:
            params["api_key"] = self._settings.openfda_api_key
        try:
            async with httpx.AsyncClient(timeout=self._settings.external_api_timeout) as http:
                response = await http.get(
                    f"{self._settings.openfda_base_url}/drug/label.json", params=params
                )
                if response.status_code == 404:
                    return None
                response.raise_for_status()
                data = response.json()
        except (httpx.HTTPError, ValueError) as exc:
            # Soft failure by design — medicine analysis must not crash.
            logger.warning("openFDA lookup failed for %r: %s", cleaned, exc)
            return None

        results = data.get("results") or []
        if not results:
            return None
        return self._normalize(results[0])

    async def search_names(self, query: str, limit: int = 8) -> list[OpenFDALabel]:
        """Used by the medicine guide search. Returns several distinct labels."""
        if self._settings.mock_external_services:
            return self._mock_search(query, limit)
        cleaned = re.sub(r"[^a-zA-Z0-9 \-]", "", query).strip()
        if not cleaned:
            return []
        params: dict = {
            "search": f'openfda.brand_name:{cleaned}* openfda.generic_name:{cleaned}*'.replace(" ", "+"),
            "limit": str(min(limit, 10)),
        }
        if self._settings.openfda_api_key:
            params["api_key"] = self._settings.openfda_api_key
        try:
            async with httpx.AsyncClient(timeout=self._settings.external_api_timeout) as http:
                response = await http.get(
                    f"{self._settings.openfda_base_url}/drug/label.json", params=params
                )
                if response.status_code == 404:
                    return []
                response.raise_for_status()
                data = response.json()
        except (httpx.HTTPError, ValueError) as exc:
            logger.warning("openFDA search failed for %r: %s", cleaned, exc)
            return []
        return [self._normalize(r) for r in data.get("results", [])]

    # ------------------------------------------------------------------
    def _normalize(self, result: dict) -> OpenFDALabel:
        openfda = result.get("openfda", {}) or {}

        def first(key: str) -> str | None:
            values = result.get(key) or openfda.get(key) or []
            if isinstance(values, list) and values:
                return str(values[0])
            return None

        def sentences(key: str, max_items: int = 4, max_words: int = 25) -> list[str]:
            raw = first(key) or ""
            # Labels are long prose; split into short, UI-friendly bullets.
            chunks = re.split(r"(?<=[.!?])\s+", raw)
            items: list[str] = []
            for chunk in chunks:
                text = " ".join(chunk.split())
                if not text or len(text) < 4:
                    continue
                words = text.split()
                items.append(" ".join(words[:max_words]) + ("…" if len(words) > max_words else ""))
                if len(items) >= max_items:
                    break
            return items

        return OpenFDALabel(
            brand_names=[str(v) for v in openfda.get("brand_name", [])][:4],
            generic_name=(openfda.get("generic_name") or [None])[0],
            manufacturer=(openfda.get("manufacturer_name") or [None])[0],
            uses=sentences("indications_and_usage") or sentences("purpose"),
            dosage=self._truncate(first("dosage_and_administration")),
            side_effects=sentences("adverse_reactions"),
            warnings=sentences("warnings") or sentences("boxed_warning"),
            contraindications=sentences("contraindications"),
            interactions_text=self._truncate(first("drug_interactions")),
            storage=self._truncate(first("storage_and_handling")),
        )

    @staticmethod
    def _truncate(text: str | None, words: int = 60) -> str | None:
        if not text:
            return None
        parts = text.split()
        return " ".join(parts[:words]) + ("…" if len(parts) > words else "")

    # ------------------------------------------------------------------
    # Deterministic dev fixtures (mock mode only).
    # ------------------------------------------------------------------
    def _mock_label(self, name: str) -> OpenFDALabel | None:
        key = name.lower()
        fixtures = {
            "paracetamol": OpenFDALabel(
                brand_names=["Paracetamol"],
                generic_name="Acetaminophen",
                manufacturer="Dev Fixtures Co.",
                uses=["Relief of mild to moderate pain", "Reduction of fever"],
                warnings=["Overdose can cause serious liver damage"],
            ),
            "ibuprofen": OpenFDALabel(
                brand_names=["Ibuprofen"],
                generic_name="Ibuprofen",
                uses=["Pain relief and fever reduction"],
                side_effects=["Stomach upset or indigestion"],
                interactions_text="May increase bleeding risk with anticoagulants.",
            ),
            "acetaminophen": OpenFDALabel(
                brand_names=["Paracetamol"],
                generic_name="Acetaminophen",
                uses=["Relief of mild to moderate pain", "Reduction of fever"],
            ),
        }
        for needle, label in fixtures.items():
            if needle in key:
                return label
        return None

    def _mock_search(self, query: str, limit: int) -> list[OpenFDALabel]:
        catalog = [
            OpenFDALabel(brand_names=["Paracetamol"], generic_name="Acetaminophen",
                         manufacturer="Dev Fixtures Co."),
            OpenFDALabel(brand_names=["Ibuprofen"], generic_name="Ibuprofen"),
            OpenFDALabel(brand_names=["Cetirizine"], generic_name="Cetirizine"),
            OpenFDALabel(brand_names=["Amoxicillin"], generic_name="Amoxicillin"),
        ]
        q = query.lower()
        return [
            label for label in catalog
            if q in label.brand_names[0].lower() or (label.generic_name or "").lower().find(q) >= 0
        ][:limit]


# Used for type checks only — keeps linters quiet about unused import.
_ = ExternalServiceError
