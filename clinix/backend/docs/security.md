# Security notes

## Authentication
* Every request carries `Authorization: Bearer <Firebase ID token>`; the backend
  verifies it with `firebase_admin.auth.verify_id_token`.
* UID and role come ONLY from the verified token's claims. Request bodies never
  accept an `uid` / `role` / `email_verified` field (verified by
  `test_auth.py::test_update_profile_ignores_role_field`).
* `require_admin` re-checks the custom claim `role == "admin"` on every admin
  call. Hiding admin UI in Flutter is convenience, not protection.

## Secrets
* OpenRouter key, Firebase Admin service-account fields, and CORS config live
  ONLY in `backend/.env`. The Flutter `.env` holds public config
  (base URL + feature flags) — never secrets.
* `.env.example` is the only committed env file.

## Dev tokens (mock mode)
* `Bearer dev-user` / `Bearer dev-admin` / `Bearer <anything>` authenticate
  ONLY when `MOCK_EXTERNAL_SERVICES=true` and Firebase Admin is unconfigured.
* In production mock mode must be `false`; without Firebase credentials the
  API then refuses to fabricate auth (`503`).

## Inputs
* Uploads: Pillow re-encodes images (JPEG/PNG/WEBP), caps size (8 MB) and
  dimensions (1024px). Filenames and extensions are never trusted.
* Query/body sizes are Pydantic-validated; blood units clamp to sane ranges.
* CORS: explicit origins from `ALLOWED_ORIGINS`, never `*` with credentials.
* Rate limits (slowapi, in-process): AI chat 20/min, medicine analyze/compare
  10/min, medicine info 30/min.

## Errors
* Contract: `{"detail": "<string>"}` for every error.
* Stack traces, provider payloads, env values and internal paths never leave
  the server — see `app/core/exceptions.py`.

## Logging
* Request middleware logs method/path/status/timing only — never tokens,
  bodies, or API keys. Image bytes are never logged.
