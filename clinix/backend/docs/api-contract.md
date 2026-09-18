# API Contract

Base URL: `{API_BASE_URL}/api/v1`. All endpoints (except `/health`) expect
`Authorization: Bearer <Firebase ID token>` — or `dev-user` / `dev-admin` in
mock mode. Every error body is `{"detail": "<message>"}`.

## Auth & profile

| Method | Path | Handler returns | Notes |
|---|---|---|---|
| GET | `/auth/me` | UserProfile | lazily creates the profile on first call |
| PUT | `/auth/users/me` | UserProfile | only profile fields updatable; role never accepted |

## AI assistants

| Method | Path | Body | Returns |
|---|---|---|---|
| POST | `/ai/chat` | `{history: ChatMessage[], attachment_base64?}` | ChatMessage (sender=ai) |
| POST | `/ayurvedic/chat` | same | ChatMessage |

Rate-limited to 20/min. Emergency/self-harm keywords bypass the LLM.

## Medicines

| Method | Path | Body | Returns |
|---|---|---|---|
| POST | `/medicines/analyze` | multipart `images` (≤4) | MedicineAnalysis[] |
| POST | `/medicines/compare` | `{analyses: [2..4]}` | MedicineAnalysis[] |
| GET | `/medicines/info?name=` | — | MedicineAnalysis |
| GET | `/medicines/search?query=` | — | MedicineSummary[] |

## Mental health

| Method | Path | Body | Returns |
|---|---|---|---|
| POST | `/mental-health/analyze` | `{answers: [{question_id, selected_option_index, score}]}` | MentalHealthResult |

`band` ∈ `stable` | `mildConcern` | `elevatedConcern` (exact Dart enum names).

## Blood

| Method | Path | Returns |
|---|---|---|
| GET | `/blood/stock?blood_group&location&low_stock` | BloodStock[] |
| GET | `/blood/stock/{id}` | BloodStock |
| GET | `/blood/requests?status&blood_group` | BloodRequest[] |
| GET | `/blood/requests/my` | caller's BloodRequest[] |
| POST | `/blood/requests` → 201 | BloodRequest |
| GET | `/blood/requests/{id}` | BloodRequest |
| PUT | `/blood/requests/{id}/status` | BloodRequest (admin; lifecycle enforced) |

## Donors

| Method | Path | Returns |
|---|---|---|
| GET | `/donors?blood_group&location` | Donor[] — **no contact fields, ever** |
| GET | `/donors/me` | Donor (404 until registered) |
| POST | `/donors/me` → 201 | Donor |
| PUT | `/donors/me` | Donor |
| POST | `/donors/{id}/contact-request` | `{detail}` — notifies donor in-app |

## Hospitals & doctors

| Method | Path |
|---|---|
| GET | `/hospitals?location` |
| GET | `/hospitals/{id}` |
| GET | `/doctors?specialty&location&available_today` |
| GET | `/doctors/recommended` |
| GET | `/doctors/{id}` |

## Notifications & reminders

| Method | Path |
|---|---|
| GET | `/notifications` |
| PUT | `/notifications/{id}/read` |
| PUT | `/notifications/read-all` |
| POST | `/notifications/device-token` — `{token, platform}` |
| GET/POST | `/reminders` |
| PUT/DELETE | `/reminders/{id}` |

Notification `type` ∈ `reminder|bloodRequest|bloodAvailability|system|aiResult|appointment`.

## Admin (role claim verified server-side per call)

| Method | Path |
|---|---|
| GET | `/admin/stats` |
| GET/POST | `/admin/blood-inventory` |
| PUT/DELETE | `/admin/blood-inventory/{id}` |
| GET | `/admin/blood-requests?status` |
| PUT | `/admin/blood-requests/{id}/status` |
| GET/DELETE | `/admin/donors`, `/admin/donors/{id}` |
| GET/POST | `/admin/hospitals` |
| PUT/DELETE | `/admin/hospitals/{id}` |
| GET | `/admin/users` |
| POST | `/admin/notifications/broadcast` — `{title, body}` |

## Model field reference (snake_case ↔ Dart model)

| Backend schema | Dart model |
|---|---|
| UserProfileOut | UserModel |
| ChatMessage | ChatMessageModel |
| MedicineAnalysis / MedicineInteraction / MedicineSummary | MedicineAnalysisModel / MedicineInteractionModel / MedicineModel |
| MentalHealthResult | MentalHealthResultModel |
| BloodStock / BloodRequest | BloodStockModel / BloodRequestModel |
| Donor | DonorModel |
| Hospital | HospitalModel |
| Doctor | DoctorModel |
| Notification | NotificationModel |
| Reminder | ReminderModel |
