# CliniX Backend (FastAPI)

The server half of CliniX. It verifies Firebase ID tokens, runs all AI features
through server-side OpenRouter calls, enriches medicine data with openFDA/RxNorm,
and persists app data in Firestore — with a fully-offline development mode so the
whole stack runs with zero cloud accounts.

## Quick start (development, no credentials needed)

```bash
cd backend
python -m venv .venv && source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env                                # defaults are dev-friendly: MOCK_EXTERNAL_SERVICES=true
uvicorn app.main:app --reload
```

* API: <http://localhost:8000/api/v1>
* Interactive docs: <http://localhost:8000/docs>
* Health: `GET /health` and `GET /api/v1/health`

In mock mode, authenticate with dev tokens:
`Authorization: Bearer dev-user` (patient) or `Bearer dev-admin` (admin).
The in-memory store is seeded with hospitals, blood stock, doctors, donors and
blood requests so the Flutter app demos end-to-end.

## Run the tests

```bash
cd backend
pip install -r requirements.txt
pytest -q
```

The suite (55 tests) mocks every external dependency — no network, no Firebase,
no OpenRouter key required.

## Project layout

```
app/
  core/        config (.env), security (token verification), exceptions, logging
  api/         routers — endpoint paths match lib/core/network/api_endpoints.dart
  schemas/     Pydantic v2 models — field names match lib/shared/models/*.dart
  services/    business rules, safety screens, pipelines
  repositories/ Firestore + in-memory dev store data access
  integrations/ OpenRouter, openFDA, RxNorm, FCM (all server-side keys here only)
  prompts/     system prompts for the three AI features
scripts/
  seed_db.py   seeds Firestore with demo data (real mode only)
tests/         pytest suite — everything external mocked
docs/          architecture, contract, firestore schema, security notes
```

## Docs

* [docs/architecture.md](docs/architecture.md) — layers, data flow, design decisions
* [docs/api-contract.md](docs/api-contract.md) — endpoint table + request/response shapes
* [docs/firestore-schema.md](docs/firestore-schema.md) — collections and security rules
* [docs/security.md](docs/security.md) — auth, rate limits, mock-mode rules
* [docs/medical-safety.md](docs/medical-safety.md) — health-content guardrails
* [../docs/backend-integration.md](../docs/backend-integration.md) — Flutter repository → endpoint mapping

## Going to production (checklist)

1. `MOCK_EXTERNAL_SERVICES=false` in `.env`
2. Fill in Firebase Admin service-account fields; run `python scripts/seed_db.py`
3. Set `OPENROUTER_API_KEY` (and choose models)
4. Set `ALLOWED_ORIGINS` to your deployed origins (no `*`)
5. Grant admin via Firebase custom claim: `role: 'admin'` (Firebase Console /
   Admin SDK) — the `/admin/*` routes verify this claim server-side
6. Point the app: Flutter `.env` → `API_BASE_URL`, `USE_MOCK_DATA=false`,
   `USE_FIREBASE=true`
7. Deploy with the included `Dockerfile` (never bake `.env` into the image)
