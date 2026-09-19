"""OpenRouter client — the ONLY place the API key is used (server-side).

MOCK MODE: when `mock_external_services` is on or no key is configured, we
return deterministic, clearly-labelled fixture responses so the whole stack
works offline in development. Production never fabricates answers: real mode
without a key raises ExternalServiceError.
"""
import asyncio
import json
import logging

import httpx

from app.core.config import Settings
from app.core.exceptions import ExternalServiceError

logger = logging.getLogger("clinix.openrouter")


class OpenRouterClient:
    def __init__(self, settings: Settings) -> None:
        self._settings = settings

    @property
    def _mocking(self) -> bool:
        return self._settings.mock_external_services or not self._settings.openrouter_api_key

    async def complete_chat(
        self,
        messages: list[dict],
        *,
        model: str | None = None,
        fallback_models: list[str] | None = None,
        json_mode: bool = False,
    ) -> str:
        """Plain chat completion -> assistant content string."""
        if self._mocking:
            return self._mock_chat(messages, json_mode)

        primary_model = model or self._settings.openrouter_chat_model
        fallbacks = fallback_models if fallback_models is not None else self._settings.openrouter_chat_fallback_list

        models_to_try: list[str] = [primary_model]
        for fb in fallbacks:
            if fb and fb not in models_to_try:
                models_to_try.append(fb)

        last_error: Exception | None = None
        for candidate_model in models_to_try:
            try:
                return await self._request(messages, candidate_model, json_mode)
            except ExternalServiceError as exc:
                last_error = exc
                logger.warning(
                    "OpenRouter attempt failed for model=%s; trying next fallback model if available",
                    candidate_model,
                )
                continue

        if last_error:
            raise last_error
        raise ExternalServiceError("AI service", "All AI provider models failed.")

    async def complete_vision(self, prompt: str, images_b64: list[str]) -> str:
        """Vision completion with base64 image parts."""
        if self._mocking:
            return self._mock_vision()
        content: list[dict] = [{"type": "text", "text": prompt}]
        for b64 in images_b64:
            content.append(
                {
                    "type": "image_url",
                    "image_url": {"url": f"data:image/jpeg;base64,{b64}"},
                }
            )
        messages = [{"role": "user", "content": content}]
        return await self._request(messages, self._settings.openrouter_vision_model, json_mode=True)

    async def _request(self, messages: list[dict], model: str, json_mode: bool) -> str:
        payload: dict = {
            "model": model,
            "messages": messages,
            "temperature": 0.4,
            "max_tokens": 1600,
        }
        if json_mode:
            payload["response_format"] = {"type": "json_object"}
        headers = {
            "Authorization": f"Bearer {self._settings.openrouter_api_key}",
            "HTTP-Referer": "https://clinix.app",
            "X-Title": "CliniX Backend",
        }

        retried_429 = False
        retried_400_json = False

        async with httpx.AsyncClient(timeout=self._settings.ai_timeout) as http:
            while True:
                try:
                    response = await http.post(
                        f"{self._settings.openrouter_base_url}/chat/completions",
                        json=payload,
                        headers=headers,
                    )
                    status = response.status_code
                    logger.info("OpenRouter attempt model=%s status=%d", model, status)

                    if status == 429 and not retried_429:
                        retried_429 = True
                        logger.info(
                            "OpenRouter 429 rate limit for model=%s; sleeping 8s before retry", model
                        )
                        await asyncio.sleep(8)
                        continue

                    if status == 400 and json_mode and "response_format" in payload and not retried_400_json:
                        retried_400_json = True
                        logger.info(
                            "OpenRouter 400 bad request for model=%s with json_mode; retrying without response_format",
                            model,
                        )
                        payload.pop("response_format", None)
                        continue

                    response.raise_for_status()
                    data = response.json()
                    break
                except (httpx.HTTPError, ValueError) as exc:
                    status_code = getattr(getattr(exc, "response", None), "status_code", None)
                    logger.warning(
                        "openrouter request failed for model=%s status=%s: %s",
                        model,
                        status_code,
                        exc,
                    )
                    raise ExternalServiceError(
                        "AI service", f"OpenRouter model {model} failed (status {status_code})"
                    ) from exc

        try:
            return data["choices"][0]["message"]["content"] or ""
        except (KeyError, IndexError, TypeError) as exc:
            raise ExternalServiceError("AI service", "Malformed AI provider response.") from exc

    # ------------------------------------------------------------------
    # Deterministic dev fixtures (mock mode only, never production).
    # ------------------------------------------------------------------
    def _mock_chat(self, messages: list[dict], json_mode: bool) -> str:
        if json_mode:
            # Used by the mental-health narrative path.
            return json.dumps(
                {
                    "summary": "Your answers describe some everyday ups and downs, with a few areas worth caring for this week.",
                    "observations": [
                        "Energy and sleep patterns show some day-to-day variation.",
                        "Stress appears to come in waves rather than constantly.",
                    ],
                    "coping_suggestions": [
                        "Try a 5-minute slow-breathing break when things feel heavy.",
                        "Note one thing that went okay today before sleeping.",
                        "Talk it through with someone you trust.",
                    ],
                    "lifestyle_suggestions": [
                        "Keep a regular sleep/wake time this week.",
                        "Add a short daily walk, even 10 minutes.",
                        "Keep mealtimes and hydration fairly regular.",
                    ],
                    "seek_help_guidance": "If these feelings persist for a couple of weeks or start affecting daily life, consider speaking with a counsellor or doctor.",
                }
            )
        system_text = " ".join(m.get("content", "")[:60] for m in messages[:1])
        if "Baidyek" in system_text:
            return (
                "In Ayurvedic tradition, evenings are for winding down: a warm light dinner, "
                "gentle stretches, and herbal infusions like tulsi are traditionally used to "
                "support rest. These are traditional wellness practices, not medical treatments — "
                "check suitability with a qualified practitioner, especially if you take medicines, "
                "are pregnant, or have a condition."
            )
        return (
            "Thanks for your question. In general, many everyday symptoms have simple causes, "
            "but persistent or severe ones deserve professional evaluation.\n\n"
            "• Rest, hydration, and regular meals help many everyday complaints\n"
            "• Watch for warning signs like high fever, chest pain, or trouble breathing\n\n"
            "For anything severe, persistent, or worrying, please consult a qualified healthcare professional."
        )

    def _mock_vision(self) -> str:
        return json.dumps(
            {
                "medicines": [
                    {
                        "medicine_name": "Paracetamol 500mg",
                        "generic_name": "Acetaminophen",
                        "common_uses": ["Relief of mild to moderate pain", "Reduction of fever"],
                        "dosage_information": "Typical label guidance: 500mg-1g every 4-6 hours as needed, max 4g/day.",
                        "common_side_effects": ["Generally well tolerated at label doses"],
                        "precautions": ["Do not exceed the maximum daily dose", "Caution with liver disease"],
                        "warnings": ["Overdose can cause serious liver damage"],
                        "contraindications": ["Severe liver impairment"],
                        "interactions": [
                            {
                                "interacts_with": "Alcohol",
                                "severity": "moderate",
                                "description": "Regular heavy alcohol use increases liver-risk with paracetamol.",
                            }
                        ],
                        "storage_information": "Store below 25°C, away from moisture and children.",
                    }
                ]
            }
        )
