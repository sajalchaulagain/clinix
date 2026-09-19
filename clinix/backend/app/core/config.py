from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Runtime configuration from backend/.env (server-side secrets live here,
    never in the Flutter app)."""

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    app_env: str = "development"
    debug: bool = True
    api_prefix: str = "/api/v1"

    # Firebase Admin (Auth verification + Firestore)
    firebase_project_id: str | None = None
    firebase_client_email: str | None = None
    firebase_private_key: str | None = None

    # OpenRouter (server-side key — Flutter must never see it)
    openrouter_api_key: str | None = None
    openrouter_chat_model: str = "meta-llama/llama-3.1-8b-instruct"
    openrouter_chat_fallbacks: str = "meta-llama/llama-3.1-8b-instruct:free,google/gemma-3-12b-it:free"
    openrouter_vision_model: str = "google/gemini-2.0-flash-001"
    openrouter_base_url: str = "https://openrouter.ai/api/v1"

    @property
    def openrouter_chat_fallback_list(self) -> list[str]:
        if not self.openrouter_chat_fallbacks:
            return []
        return [m.strip() for m in self.openrouter_chat_fallbacks.split(",") if m.strip()]

    # openFDA / RxNorm
    openfda_api_key: str | None = None
    openfda_base_url: str = "https://api.fda.gov"
    rxnorm_base_url: str = "https://rxnav.nlm.nih.gov/REST"

    ai_timeout: float = 60.0
    external_api_timeout: float = 15.0

    # When true: external integrations + auth are replaced by deterministic,
    # clearly-labelled dev fixtures. NEVER true in production.
    mock_external_services: bool = True

    allowed_origins: str = "http://localhost:3000,http://localhost:8080"
    max_upload_size_mb: int = 8
    rate_limit_per_minute: int = 30

    emergency_guidance_text: str = (
        "If this is an emergency, contact your local emergency number immediately."
    )

    @property
    def cors_origins(self) -> list[str]:
        return [o.strip() for o in self.allowed_origins.split(",") if o.strip()]

    @property
    def firebase_configured(self) -> bool:
        return bool(
            self.firebase_project_id
            and self.firebase_client_email
            and self.firebase_private_key
        )


@lru_cache
def get_settings() -> Settings:
    return Settings()
