"""Prompts for the medicine vision pipeline.

The vision model MUST return strict JSON matching this envelope so the
backend can validate it with Pydantic before anything reaches Flutter."""

MEDICINE_VISION_JSON_SCHEMA = """{
  "medicines": [
    {
      "medicine_name": "string (brand or printed name)",
      "generic_name": "string | null",
      "common_uses": ["string", "..."],
      "dosage_information": "string | null (label text only, never a personalized dose)",
      "common_side_effects": ["string", "..."],
      "precautions": ["string", "..."],
      "warnings": ["string", "..."],
      "contraindications": ["string", "..."],
      "interactions": [{"interacts_with": "string", "severity": "mild|moderate|severe", "description": "string"}],
      "storage_information": "string | null"
    }
  ]
}"""

MEDICINE_VISION_PROMPT = f"""You are analyzing photos of medicine packaging/labels inside the CliniX healthcare app.

Read the visible text on the package (name, generic name, strength, manufacturer, claims).

Respond with STRICT JSON ONLY (no markdown fences, no commentary), exactly matching this shape:
{MEDICINE_VISION_JSON_SCHEMA}

Rules:
- Only include information you can justify from the image plus well-established reference knowledge for that exact medicine. If the image is unreadable, return {{"medicines": []}}.
- dosage_information: summarize LABEL-LEVEL guidance only ("typical adult dose per label is ... take with food"). Never invent a personalized dose.
- interactions: include only widely-documented interactions. Use severity "mild", "moderate", or "severe".
- Keep each list item short (max ~20 words).
- One entry per DISTINCT medicine visible in the images (max 4).
"""
