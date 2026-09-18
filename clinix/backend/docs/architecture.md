# Architecture

## Layers

```
Flutter (Riverpod repositories)
        │  HTTPS, Authorization: Bearer <Firebase ID token>
        ▼
FastAPI routes (app/api/)
        │  endpoints mirror lib/core/network/api_endpoints.dart EXACTLY
        ▼
Core deps (app/core/)
  security.py  → verifies the Firebase ID token; role = custom claim only
  config.py    → pydantic-settings; all secrets from backend/.env
  exceptions.py→ every error body is {"detail": "<safe text>"}
        ▼
Schemas (app/schemas/) — Pydantic v2, field names = Dart models' JSON keys,
                        enum literals = Dart enum .name strings verbatim
        ▼
Services (app/services/) — business rules & pipelines
  safety_service      → emergency/self-harm keyword screen BEFORE any AI call
  ai_chat_service     → persona prompts, history trimming
  medicine_service    → Pillow validation → vision AI → strict JSON → Pydantic
                        → RxNorm normalization → openFDA label enrichment
  mental_health_service → deterministic band from scores; AI writes narrative only
        ▼
Repositories (app/repositories/integrations)
  Firestore via firebase-admin  (prod)
  MemoryStore (seeded)          (dev, MOCK_EXTERNAL_SERVICES=true)
        ▼
Integrations (server-side keys only): OpenRouter, openFDA, RxNorm, FCM
```

## Key decisions

| Decision | Why |
|---|---|
| Firestore (no ORM) | the Flutter app already uses Firebase; Admin SDK reads/writes from the server keeps a single source of truth |
| In-memory dev store | `uvicorn` runs end-to-end with zero cloud accounts; tests never touch the network |
| Raw model JSON responses (no `{data}` envelope) | models parse one-to-one into Dart `fromJson` factories |
| `{"detail": str}` errors | exactly what the Flutter `ApiErrorMapper` reads for every status |
| slowapi rate limiting | simple in-process limiter — no Redis dependency |
| Role from custom claims | `require_admin` re-checks the claim on every admin call; UI hiding is only UX |
| Reminders offline-first | optional sync endpoints exist (`/reminders`) but local notifications stay canonical |
| AI output → JSON parse → Pydantic → retry once | LLMs misbehave; invalid JSON never reaches the app |

## Medicine pipeline (most complex flow)

1. `POST /api/v1/medicines/analyze` (multipart, ≤4 images)
2. Pillow verifies bytes (JPEG/PNG/WEBP), normalizes to RGB JPEG ≤1024px, ≤8MB each
3. OpenRouter vision model is prompted for STRICT JSON (see `prompts/medicine_prompt.py`)
4. Response parsed → `MedicineAnalysis` validated → retry exactly once on parse failure
5. RxNorm normalizes generic names; openFDA label sections merge (deduplicated)
6. Enrichment failures are SOFT — the AI result returns as-is, always with
   `is_ai_generated: true` so the app keeps its safety labeling

## Mental-health scoring

The band (`stable` / `mildConcern` / `elevatedConcern` — camelCase to mirror
the Dart enum) is computed by the service from the submitted scores.
AI only drafts the narrative; if it fails, curated templates are used.
Nothing here is diagnostic (see `docs/medical-safety.md`).
