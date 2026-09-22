# CliniX

**Your Smart Healthcare Companion** — a production-oriented Flutter frontend for a smart healthcare, medicine & blood support platform. CliniX is the modern evolution of the "Hamro Upachar" project.

> **Status: FRONTEND ONLY.** The FastAPI backend is a separate project and is
> NOT implemented here. This app ships with clearly-labelled mock repositories
> and a complete integration layer so the backend can be connected **without
> rewriting the UI**.

---

## ✨ Features

| Module | Highlights |
|---|---|
| **Authentication** | Splash, 4-page onboarding (shown once), login, signup (optional health fields), forgot password, email verification, role-aware sessions |
| **Home Dashboard** | Greeting, notification bell with unread badge, search entry, health summary, 6-feature grid, quick actions, recommended doctors |
| **Explore** | Global search, module directory, doctor discovery |
| **Upachar Sathi** | AI health chat with typing indicator, suggestions, image + voice placeholders, **pinned medical safety disclaimer**, emergency guidance |
| **Mental Health** | 10-question well-being screening with progress, processing state, **non-diagnostic** summary with coping/lifestyle guidance |
| **Medicine** | Scanner (camera/gallery, multi-image, remove/retake), animated analysis, sectioned results, side-by-side comparison, searchable medicine guide |
| **Baidyek Sathi** | Ayurvedic symptom input, wellness categories, traditional remedy cards with precautions, dedicated chat |
| **Blood** | Stock search (group/location/hospital/availability), detail pages, request form with urgency, recent requests |
| **Donors** | Filterable directory, availability + eligibility hints, mediated contact requests, "Become a Donor" |
| **Hospitals** | Directory with per-group blood availability chips, contact/detail sheet |
| **Reminders** | Offline-first CRUD, multiple dose times, **real local notifications** (`flutter_local_notifications`), enable/disable switch |
| **Notifications** | Typed notification center (reminder / blood / system / AI result / appointment), mark-as-read, deep-link routing |
| **Profile & Settings** | Profile + medical preferences, theme (system/light/dark), language-ready (EN/NE structure), AI disclaimer, legal pages |
| **Admin** | Role-gated dashboard with stats, blood inventory **CRUD**, request status management, donor/hospital/user lists, notification broadcast |

Every data screen supports **loading / success / empty / error + retry** states via reusable `AsyncValueView`, `SkeletonList`, `AppEmptyState` and `AppErrorView`.

---

## 🛠 Tech Stack

- **Flutter** (Material 3) with **Dart ≥ 3.6** (Flutter ≥ 3.27 recommended)
- **Riverpod** (flutter_riverpod 2.x) — state management, no codegen needed
- **GoRouter** — typed routes, `StatefulShellRoute` bottom-nav, auth/admin redirects
- **Dio** — REST client abstraction for the future FastAPI backend
- **SharedPreferences** — onboarding flag, settings, offline reminder store
- **flutter_local_notifications + timezone** — medicine reminder schedules
- **firebase_core / auth / firestore / messaging / storage** — *opt-in* integration structure
- **image_picker**, **cached_network_image**, **intl**, **equatable**, **flutter_dotenv**

No unnecessary packages. No CodeGen, no DI framework, no ORM — readable by a student.

---

## 🏗 Architecture

```
UI (screens/widgets)
   ↓ watches
Riverpod controllers/providers  (per-feature state: AsyncValue, Notifier)
   ↓ calls
Repository interfaces           (auth, blood, donors, hospitals, medicine,
   ↓ implemented by               ai, ayurvedic, reminders, notifications, admin)
Mock*Repository today ── OR ── Api*/Firebase*Repository later
   ↓ uses
Services  (ApiClient/Dio, LocalStorage, NotificationService, Firebase services)
```

Two integration shapes, never mixed:

```
AI / medicine API data:   UI → Provider → Repository → ApiService (Dio) → FastAPI
Firebase data:            UI → Provider → Repository → Firebase Service → Firebase
```

**Security rules baked in:**
- No OpenRouter keys, backend secrets, or admin credentials can exist in this app.
- `.env` holds **public** config only (ship-safe). Never put secrets there.
- Role checks exist in UI (hiding) **and** router (redirect) — but real
  authorization is a backend/Firestore-rules responsibility.

---

## 📁 Project Structure

```
lib/
├── main.dart                     # bootstrap: .env, storage, (optional) Firebase, notifications
├── app/
│   ├── app.dart                  # MaterialApp.router + theme switching
│   ├── config/app_config.dart    # .env-backed public configuration
│   ├── router/
│   │   ├── app_router.dart       # GoRouter: all routes + auth/admin redirects
│   │   └── main_shell.dart       # floating bottom navigation (5 tabs)
│   └── theme/app_theme.dart      # single light/dark ThemeData definition
├── core/
│   ├── constants/                # colors, dimensions, app strings, branding
│   ├── errors/app_exception.dart # user-safe exception vocabulary
│   ├── network/                  # ApiClient, ApiEndpoints(⚠️draft), ApiResponse, error mapper
│   ├── services/                 # local storage, local notifications,
│   │   └── firebase/             # auth/firestore/storage/messaging wrappers
│   ├── utils/                    # validators, debouncer, date formatters
│   └── widgets/                  # reusable design system (buttons, cards, states…)
├── shared/
│   ├── models/                   # 15 JSON-serializable models
│   └── extensions/               # context helpers
└── features/                     # one folder per module
    ├── auth/  (domain/data/presentation)
    ├── onboarding/
    ├── home/
    ├── doctors/
    ├── ai_assistant/
    ├── mental_health/
    ├── medicine/
    ├── ayurvedic/
    ├── blood/    (+ shared MockBloodDataStore)
    ├── donors/
    ├── hospitals/
    ├── reminders/
    ├── notifications/
    ├── profile/
    ├── settings/
    └── admin/
test/                             # validators, models, repository behavior tests
.env.example                      # template for public config
pubspec.yaml
```

---

## 🚀 Setup & Run

### Prerequisites
- Flutter SDK **≥ 3.27** (`flutter --version`), Dart **≥ 3.6**
- Android Studio / Xcode toolchains for device builds

```bash
git clone <your-repo> clinix && cd clinix
cp .env.example .env           # public config; mock mode enabled by default
flutter pub get
flutter run                    # choose an Android/iOS device or emulator
```

**First run flow:** splash → onboarding (once) → login → *(demo)* any email + 6-char password → home.
Use an email containing **"admin"** (e.g. `admin@clinix.app`) to preview the admin role.

### Platform notes

**Android** — add to `android/app/src/main/AndroidManifest.xml` (inside `<manifest>`) for reminders/notifications:

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

**iOS** — `image_picker` and local notifications need usage descriptions in `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key><string>Used to photograph medicine packages.</string>
<key>NSPhotoLibraryUsageDescription</key><string>Used to select medicine photos.</string>
```

---

## 🔥 Firebase Setup (after package rename)

1. Add Android application `com.sajalchaulagain.clinix` in Firebase Console.
2. Download updated `google-services.json` to `clinix/android/app/`.
3. Run FlutterFire CLI to update configuration:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure          # generates lib/firebase_options.dart
   ```
4. Register the release SHA-1 fingerprint in Firebase Console (required if Google Sign-In is used). Retrieve SHA-1 using:
   ```bash
   keytool -list -v -keystore android/upload-keystore.jks -alias upload
   ```
5. In `.env`, set `USE_FIREBASE=true` and `USE_MOCK_DATA=false`.
6. Configure Firestore **security rules** and admin **custom claims** server-side — the app never grants itself roles.

No `google-services.json` / `firebase_options.dart` is committed (gitignored).

---

## 🌐 Deployment (Render.com)

Deploying `clinix/backend` on Render.com:

### Option A: Render Blueprint (Recommended)
Connect your GitHub repository to Render and deploy using the root `render.yaml` blueprint. Render automatically provisions the web service with all configuration settings.

### Option B: Manual Web Service Setup
- **Service Type**: Web Service
- **Runtime**: Docker
- **Root Directory**: `clinix/backend`
- **Region**: Singapore
- **Branch**: `main`
- **Health Check Path**: `/api/v1/health`

### Environment Variables

| Variable | Recommended / Example Value | Description |
|---|---|---|
| `APP_ENV` | `production` | Application environment mode |
| `DEBUG` | `false` | Enable/disable debug output |
| `MOCK_EXTERNAL_SERVICES` | `false` | Set `false` for live integrations |
| `ALLOWED_ORIGINS` | `https://sajalchaulagain.com.np` | CORS allowed origin domains |
| `OPENROUTER_CHAT_MODEL` | `meta-llama/llama-3.1-8b-instruct` | OpenRouter chat model identifier |
| `OPENROUTER_VISION_MODEL` | `google/gemini-2.0-flash-001` | OpenRouter vision model identifier |
| `FIREBASE_PROJECT_ID` | *(Secret)* | Firebase project ID |
| `FIREBASE_CLIENT_EMAIL` | *(Secret)* | Service account client email |
| `FIREBASE_PRIVATE_KEY` | *(Secret)* | Service account private key |
| `OPENROUTER_API_KEY` | *(Secret)* | OpenRouter API Key |

> [!NOTE]
> **Free Tier Spin-Down Note**: Render free-tier web services automatically enter a sleep state after 15 minutes of inactivity. Initial cold-start requests may take up to 50 seconds to respond.

---

## 📦 Release Builds (Android)

To build a signed release APK for Android:

### 1. Generate a Keystore
Run `keytool` to create a signing key in `clinix/android/upload-keystore.jks`:
```bash
keytool -genkey -v -keystore upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### 2. Create `key.properties`
Copy `clinix/android/key.properties.example` to `clinix/android/key.properties` and populate the fields:
- `storePassword`: Keystore password
- `keyPassword`: Key password
- `keyAlias`: Key alias (e.g. `upload`)
- `storeFile`: Path to keystore file (e.g. `upload-keystore.jks`)

### 3. Build Release APK
Copy `clinix/.env.release.example` to `clinix/.env` and update `API_BASE_URL` with your Render backend URL, then run:
```bash
flutter build apk --release
```

### 4. Publishing to GitHub Releases
When publishing a release on GitHub, rename the generated APK (`build/app/outputs/flutter-apk/app-release.apk`) to **`CliniX.apk`**.
This ensures that the latest release binary is always accessible at:
`https://github.com/sajalchaulagain/clinix/releases/latest/download/CliniX.apk`


---

## 🧪 Testing

```bash
flutter test
```

| Suite | Covers |
|---|---|
| `test/validators_test.dart` | email/password/phone/blood group/units rules |
| `test/models_test.dart` | JSON round-trips, reminder scheduling logic, **non-diagnostic wording guard** |
| `test/repositories_test.dart` | mock auth session lifecycle, blood filters, request submission, local reminder persistence |

Run static checks with `flutter analyze`.

---

## 🔌 Mock Repositories, and Where the Backend Connects

`.env` → `USE_MOCK_DATA=true` binds every repository interface to a `Mock*`
implementation with simulated latency. Swapping to real implementations
changes **one provider per feature** — the UI is untouched.

| Interface | Mock (today) | Backend hookup point | Uses draft endpoint |
|---|---|---|---|
| `AuthRepository` | `MockAuthRepository` (SharedPrefs session) | `auth_providers.dart` → `FirebaseAuthRepository` | `/api/v1/auth/me` (token verify) |
| `DoctorRepository` | `MockDoctorRepository` | `doctor_providers.dart` | *(TBD)* |
| `AiRepository` | `MockAiRepository` (canned safety-first replies) | `chat_providers.dart` → `ApiAiRepository` (`ApiClient`) | `/api/v1/ai/chat`, `/api/v1/ayurvedic/chat` |
| `MentalHealthRepository` | `MockMentalHealthRepository` (**demo scoring, to be removed**) | `screening_providers.dart` | `/api/v1/mental-health/analyze` |
| `MedicineRepository` | `MockMedicineRepository` (catalog of 4) | `medicine_providers.dart` → uploads via `ApiClient.uploadImages` | `/api/v1/medicines/{analyze,compare,info}` |
| `AyurvedicRepository` | `MockAyurvedicRepository` | `ayurvedic_providers.dart` | chat shares AI endpoint |
| `BloodRepository` | `MockBloodRepository` (**shared MockBloodDataStore**) | `blood_providers.dart` | `/api/v1/blood/*` |
| `DonorRepository` | `MockDonorRepository` (mediated contact) | `donor_providers.dart` | `/api/v1/donors` |
| `HospitalRepository` | `MockHospitalRepository` | `hospital_providers.dart` | `/api/v1/hospitals` |
| `ReminderRepository` | `LocalReminderRepository` (**real, offline-first — keep it**) | add `ApiReminderRepository` for sync later | *(optional sync)* |
| `NotificationRepository` | `MockNotificationRepository` | `notification_providers.dart` | *(TBD, FCM-fed)* |
| `AdminRepository` | `MockAdminRepository` (writes to shared store) | `admin_providers.dart` | `/api/v1/admin/*` |

**Files that will change for backend integration** (and only these):
- `lib/core/network/api_endpoints.dart` — confirm real paths from the FastAPI routers
- Each feature's `providers/` file — swap the mock binding for the API/Firebase implementation
- `lib/main.dart` — Firebase init already wired behind `USE_FIREBASE`

**Request/response shaping:** repositories return the models in `lib/shared/models/`.
The backend should emit those JSON shapes (snake_case fields match the models'
`toJson`, e.g. `MedicineAnalysisModel` ↔ `{"medicine_name", "generic_name", "common_uses": [...], "warnings": [...], "interactions": [{"interacts_with","severity","description"}], "is_ai_generated": true}`).
Errors: FastAPI's `{"detail": "..."}` is mapped to user-safe exceptions by `ApiErrorMapper`.

**Architecture in the target state:**

```
Flutter UI → Providers → Repositories ──(REST, Bearer Firebase ID token)──▶
FastAPI (auth verify, OpenRouter AI, openFDA, RxNorm, business rules) ──▶
Firebase (Auth/Firestore/FCM/Storage) + external APIs
```

---

## 🗺 Roadmap after backend connection

1. Confirm endpoint paths in `api_endpoints.dart`
2. Implement `Api*Repository` classes alongside mocks (keep mocks for tests!)
3. Run `flutterfire configure`, flip env flags
4. Wire FCM token registration after login
5. Nepali localization via ARB (`AppStrings` marks the sensitive copy)
6. Legal review of the demo Terms/Privacy content

---

## ⚕️ Medical Safety Commitments (enforced in copy + tests)

- The app **never** claims diagnosis: "screening summary", "general well-being indicators", "AI-generated information".
- Emergency guidance is one tap away from every AI surface.
- Ayurvedic content is labelled as traditional wellness information, not validated treatment.
- Donor contact is mediated; private numbers are never rendered.

---

Built for a hackathon-ready demo with a clean architecture a student developer can understand, modify, and extend. 🏥
