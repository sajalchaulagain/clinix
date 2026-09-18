"""Medicine pipeline: upload validation → vision AI → strict JSON parse →
Pydantic validation → RxNorm normalization → openFDA label enrichment.

Trust boundaries:
  • uploads: bytes are validated with Pillow (never by filename/extension)
  • AI output: never trusted — parsed as JSON, validated against our schema,
    retried at most once, otherwise the call fails cleanly.
  • enrichment failures (openFDA/RxNorm) are soft: AI-only data is returned,
    still labelled is_ai_generated=true. Nothing is fabricated.
"""
import base64
import io
import json
import logging

from fastapi import HTTPException
from PIL import Image

from app.core.config import Settings
from app.integrations.openfda import OpenFDAClient
from app.integrations.openrouter import OpenRouterClient
from app.integrations.rxnorm import RxNormClient
from app.prompts.medicine_prompt import MEDICINE_VISION_PROMPT
from app.schemas.medicine import MedicineAnalysis, MedicineSummary

logger = logging.getLogger("clinix.medicine")

MAX_DIMENSION = 1024
ALLOWED_FORMATS = {"JPEG", "PNG", "WEBP"}


def validate_and_prepare_images(files: list[tuple[str, bytes]],
                                max_mb: int) -> list[str]:
    """Pillow-verify each upload then return data-URL-safe base64 JPEGs."""
    if not files:
        raise HTTPException(status_code=400, detail="Provide at least one image.")
    if len(files) > 4:
        raise HTTPException(status_code=400, detail="Upload up to 4 images at a time.")

    prepared: list[str] = []
    for filename, content in files:
        if len(content) > max_mb * 1024 * 1024:
            raise HTTPException(status_code=413, detail=f"'{filename}' is too large (max {max_mb} MB).")
        if len(content) == 0:
            raise HTTPException(status_code=400, detail=f"'{filename}' is empty.")
        try:
            image = Image.open(io.BytesIO(content))
            image.load()
        except Exception as exc:
            # Security: trust Pillow, never the extension or magic claims.
            raise HTTPException(
                status_code=400, detail=f"'{filename}' is not a valid image file."
            ) from exc
        if image.format not in ALLOWED_FORMATS:
            raise HTTPException(
                status_code=400,
                detail=f"Unsupported image format '{image.format}'. Use JPEG, PNG or WEBP.",
            )

        image = image.convert("RGB")
        if max(image.size) > MAX_DIMENSION:
            image.thumbnail((MAX_DIMENSION, MAX_DIMENSION))  # control model cost
        buffer = io.BytesIO()
        image.save(buffer, format="JPEG", quality=85)
        prepared.append(base64.b64encode(buffer.getvalue()).decode("ascii"))
    return prepared


def _extract_json(raw: str) -> dict:
    """Strict JSON parse with markdown-fence tolerance; raises on garbage."""
    text = raw.strip()
    if text.startswith("```"):
        lines = [l for l in text.splitlines() if not l.strip().startswith("```")]
        text = "\n".join(lines).strip()
    start, end = text.find("{"), text.rfind("}")
    if start == -1 or end == -1:
        raise ValueError("AI response did not contain a JSON object")
    return json.loads(text[start:end + 1])


class MedicineService:
    def __init__(self, settings: Settings) -> None:
        self.settings = settings
        self.openrouter = OpenRouterClient(settings)
        self.openfda = OpenFDAClient(settings)
        self.rxnorm = RxNormClient(settings)

    # ---------------------------------------------------------- analyze
    async def analyze(self, files: list[tuple[str, bytes]]) -> list[MedicineAnalysis]:
        images_b64 = validate_and_prepare_images(files, self.settings.max_upload_size_mb)

        raw = await self.openrouter.complete_vision(MEDICINE_VISION_PROMPT, images_b64)
        analyses = self._parse_analyses(raw)
        if analyses is None:
            # Retry exactly once — the most common failure is trailing prose.
            raw = await self.openrouter.complete_vision(
                MEDICINE_VISION_PROMPT + "\n\nREMINDER: output the JSON object only.",
                images_b64,
            )
            analyses = self._parse_analyses(raw)

        if not analyses:
            raise HTTPException(
                status_code=422,
                detail="No medicines could be identified in the uploaded images. Try a clearer, closer photo of the label.",
            )
        return [await self._enrich(a) for a in analyses[:4]]

    def _parse_analyses(self, raw: str) -> list[MedicineAnalysis] | None:
        try:
            payload = _extract_json(raw)
            medicines = payload.get("medicines", [])
            return [MedicineAnalysis(**m, is_ai_generated=True) for m in medicines]
        except (ValueError, TypeError, KeyError) as exc:
            logger.warning("AI medicine JSON invalid: %s", exc)
            return None

    async def _enrich(self, analysis: MedicineAnalysis) -> MedicineAnalysis:
        data = analysis.model_dump()

        normalized = await self.rxnorm.normalize(
            analysis.generic_name or analysis.medicine_name
        )
        if normalized and not data.get("generic_name"):
            data["generic_name"] = normalized.get("name")

        label = await self.openfda.search_label(analysis.generic_name or analysis.medicine_name)
        if label:
            def merged(ai_list: list, fda_list: list) -> list:
                seen, out = set(), []
                for item in [*ai_list, *fda_list]:
                    key = item.strip().lower()
                    if key and key not in seen:
                        seen.add(key)
                        out.append(item)
                return out[:8]

            data["common_uses"] = merged(data.get("common_uses", []), label.uses)
            data["common_side_effects"] = merged(data.get("common_side_effects", []), label.side_effects)
            data["warnings"] = merged(data.get("warnings", []), label.warnings)
            if not data.get("dosage_information") and label.dosage:
                data["dosage_information"] = label.dosage
            if not data.get("storage_information") and label.storage:
                data["storage_information"] = label.storage
        return MedicineAnalysis(**{**data, "is_ai_generated": True})

    # ---------------------------------------------------------- compare
    async def compare(self, analyses: list[MedicineAnalysis]) -> list[MedicineAnalysis]:
        results = []
        for analysis in analyses:
            results.append(await self._enrich(analysis))
        return results

    # -------------------------------------------------------- info/search
    async def info_by_name(self, name: str) -> MedicineAnalysis:
        label = await self.openfda.search_label(name)
        if label is None and not self.settings.mock_external_services:
            raise HTTPException(status_code=404, detail="No label information found for that name.")
        data: dict = {
            "medicine_name": name,
            "is_ai_generated": True,
            "common_uses": [], "common_side_effects": [], "precautions": [],
            "warnings": [], "contraindications": [], "interactions": [],
        }
        if label:
            data.update({
                "medicine_name": label.brand_names[0] if label.brand_names else name,
                "generic_name": label.generic_name,
                "common_uses": label.uses,
                "common_side_effects": label.side_effects,
                "warnings": label.warnings,
                "contraindications": label.contraindications,
                "dosage_information": label.dosage,
                "storage_information": label.storage,
            })
        normalized = await self.rxnorm.normalize(data.get("generic_name") or name)
        if normalized and not data.get("generic_name"):
            data["generic_name"] = normalized.get("name")
        return MedicineAnalysis(**data)

    async def search(self, query: str) -> list[MedicineSummary]:
        labels = await self.openfda.search_names(query)
        results, seen = [], set()
        for i, label in enumerate(labels):
            name = label.brand_names[0] if label.brand_names else query
            key = name.lower()
            if key in seen:
                continue
            seen.add(key)
            results.append(MedicineSummary(
                id=new_summary_id(i, name), name=name,
                generic_name=label.generic_name, manufacturer=label.manufacturer,
                category="Medicine",
                description=f"Official US drug-label information for {name}.",
            ))
        return results[:10]


def new_summary_id(index: int, name: str) -> str:
    slug = "".join(c if c.isalnum() else "-" for c in name.lower()).strip("-")
    return f"med-{slug or 'result'}-{index + 1}"
