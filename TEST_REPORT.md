# Comprehensive Verification Test Report: CliniX Android & Release Pipeline

**Date:** 2026-09-22  
**Branch:** `verification`  
**Package Name:** `com.sajalchaulagain.clinix`  
**Backend Endpoint:** `https://desktop-8sf7hia.tail323ad9.ts.net` (Configured in `clinix/.env`)  

---

## Executive Summary & Pass/Fail Matrix

| Phase | Test Item | Description | Status | Key Details / Metrics |
| :--- | :--- | :--- | :---: | :--- |
| **A1** | Namespace & AppId | `build.gradle.kts` package configuration | **PASS** | `namespace` & `applicationId` both set to `com.sajalchaulagain.clinix` |
| **A2** | Google Services JSON | `google-services.json` package & app ID verification | **PASS** | Package: `com.sajalchaulagain.clinix`, Mobile SDK App ID: `1:498472334145:android:200b4ec07bdac308a027c0` |
| **A3** | Firebase Options Dart | `lib/firebase_options.dart` config alignment | **PASS** | `appId` matches `google-services.json` (`...200b4ec07bdac308a027c0`), `projectId`: `clinix-69` |
| **A4** | Environment Security | Public `.env` safety & runtime flag check | **PASS** | `USE_MOCK_DATA=false`, `USE_FIREBASE=true`, `API_BASE_URL` uses `https://` (No raw secrets exposed) |
| **B1** | Backend Health Check | GET `/api/v1/health` endpoint validation | **FAIL** | 502 Bad Gateway (Backend host `desktop-8sf7hia.tail323ad9.ts.net` unreachable/offline) |
| **B2** | Security Regression | Dev token authentication rejection test | **FAIL** | 502 Bad Gateway (Unable to test auth rejection due to host 502) |
| **B3** | CORS Restrictions | Origin validation headers check | **FAIL** | 502 Bad Gateway (CORS headers absent on gateway error) |
| **B4** | OpenAPI Docs | GET `/docs` availability | **FAIL** | 502 Bad Gateway |
| **C1** | Dependency Resolution | `flutter pub get` package resolution | **PASS** | Successfully resolved all dependencies with 0 conflicts |
| **C2** | Static Code Analysis | `flutter analyze` linter check | **PASS** | `No issues found!` (0 errors, 0 warnings, 0 infos) |
| **C3** | Unit Test Suite | `flutter test` execution | **PASS** | 24 unit tests executed & passed cleanly |
| **C4** | Model Unit Tests | Additional coverage added | **PASS** | Added `test/models_test.dart` for `NotificationModel` JSON round-trip & `copyWith` |
| **D1** | Debug APK Build | `flutter build apk --debug` | **PASS** | Compiled successfully using debug signing fallback |
| **D2** | Release Split APK Build | Obfuscated per-ABI release compilation | **PASS** | Compiled arm64-v8a, armeabi-v7a, and x86_64 release APKs with debug signing fallback |
| **D3** | APK Size Verification | File size audit | **PASS** | `app-arm64-v8a-release.apk` (20.45 MB), `app-armeabi-v7a-release.apk` (17.95 MB), `app-x86_64-release.apk` (21.88 MB), `app-debug.apk` (156.13 MB) |
| **D4** | Architecture Isolation | Native library `.so` contents check | **PASS** | `app-arm64-v8a-release.apk` contains ONLY `lib/arm64-v8a/` binaries (`libapp.so`, `libflutter.so`, `libdatastore_shared_counter.so`) |
| **D5** | Obfuscation Integrity | Artifact verification | **PASS** | Obfuscation map generated at `build/symbols/` without manifest corruption |
| **E1** | Device Detection | `flutter devices` detection | **PASS** | Device detected (`23129RAA4G`, Android 15, API 35) |
| **E2** | Release APK Install | ADB installation attempt | **FAIL (USER)** | `INSTALL_FAILED_USER_RESTRICTED` (Prompt was canceled/declined on the physical test device) |
| **E3** | App Launch & Logcat | Application execution & crash monitor | **PARTIAL** | Launched previous installation (`com.example.clinix`). No native runtime crashes observed. |
| **E4** | Integration Tests | End-to-End automated UI test | **SKIPPED** | `CLINIX_TEST_EMAIL` and `CLINIX_TEST_PASSWORD` environment variables were not provided. |
| **E5** | Device Cleanup | State check | **PASS** | Existing installations retained. |

---

## Detailed Findings & Discrepancies

### 1. Configuration Fixes Applied (Phase A)
- **`google-services.json` File Naming:** File was named `google-services copy.json` in `clinix/android/app/`. Corrected by restoring `google-services.json` containing package `com.sajalchaulagain.clinix`.
- **`firebase_options.dart` App ID Alignment:** The Android `appId` in `lib/firebase_options.dart` was referencing the old `com.example.clinix` App ID (`1:498472334145:android:e18b3e0a9b4bb39ba027c0`). Updated to match the new `google-services.json` App ID (`1:498472334145:android:200b4ec07bdac308a027c0`).

### 2. Backend Gateway Issue (Phase B)
- **Host Configured:** `https://desktop-8sf7hia.tail323ad9.ts.net` (Tailscale funnel / proxy host).
- **Result:** Returned HTTP `502 Bad Gateway`.
- **Probing Render Deployment:** Probed `https://clinix-backend.onrender.com` — returned `404 Not Found`.
- **Impact:** The backend server is currently offline or unreachable at the configured URL.

### 3. Build & Architecture Outputs (Phase D)
- **Release APK Sizes:**
  - `app-arm64-v8a-release.apk`: **20.45 MB** (21,447,889 bytes)
  - `app-armeabi-v7a-release.apk`: **17.95 MB** (18,823,835 bytes)
  - `app-x86_64-release.apk`: **21.88 MB** (22,948,048 bytes)
  - `app-debug.apk`: **156.13 MB** (163,719,457 bytes)
- **Native Library Contents (`app-arm64-v8a-release.apk`):**
  - `lib/arm64-v8a/libapp.so`
  - `lib/arm64-v8a/libdatastore_shared_counter.so`
  - `lib/arm64-v8a/libflutter.so`
  - *(armeabi-v7a and x86_64 libraries are completely absent as required).*

---

## What Still Needs a Human (Manual Verification Checklist)

1. **Backend Service URL:**
   - Update `API_BASE_URL` in `clinix/.env` to point to the active production backend URL on Render once deployed.
2. **On-Device ADB Install Authorization:**
   - Approve the ADB USB install prompt on the physical Android device (`23129RAA4G`) when running `adb install` for package `com.sajalchaulagain.clinix`.
3. **End-to-End User Authentication:**
   - Perform a real user signup/login flow with a fresh email address against the live backend to verify Firebase Auth token generation and FastAPI session handling.
4. **AI Medical Chat Quality:**
   - Test the OpenRouter AI chat feature in the app to verify response latency and streaming quality.
5. **Medicine Reminder System Notifications:**
   - Schedule a medicine reminder and verify that local push notifications fire at the scheduled time.
6. **In-App Self-Update Dialog:**
   - Publish a test tag (`v1.0.1`) on GitHub Releases with a release asset `CliniX.apk` to verify the Task 4 update prompt dialog appears on app launch.
