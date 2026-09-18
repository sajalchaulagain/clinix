# Firebase Setup Guide (Free Spark Plan)

## What Firebase is Used For

| Service | Where used | Limit (free Spark plan) |
|---|---|---|
| **Firebase Auth** | User login/signup (email+password) | 50,000 MAU |
| **Firestore** | Blood stock, donors, hospitals, doctors, user profiles | 1GB storage, 50K reads/day |
| **Cloud Messaging (FCM)** | Push notifications | Free, unlimited |
| **Storage** | Profile photo uploads | 5GB storage, 1GB/day download |

> All free — no billing required for development and small-scale production.

---

## Architecture: Firebase in CliniX

```
Flutter App
├── Firebase Auth  ← login, signup, ID token generation (direct)
├── Firestore      ← read-only public data (blood stock, hospitals, donors)
│                     write operations go through FastAPI for validation
└── FCM            ← receives push notifications

FastAPI Backend
├── Firebase Admin SDK  ← verifies ID tokens from Flutter
├── Firestore Admin     ← server-side writes (blood requests, admin ops)
└── FCM Admin           ← sends push notifications (via backend)
```

---

## Step 1 — Create a Firebase Project

1. Go to [https://console.firebase.google.com](https://console.firebase.google.com)
2. Click **"Add project"**
3. Name it `clinix` (or anything you like)
4. Disable Google Analytics (not needed)
5. Click **"Create project"**

---

## Step 2 — Enable Authentication

1. In your project: **Build → Authentication → Get started**
2. Click **"Email/Password"** → Enable → Save
3. (Optional) Enable **Google Sign-in** for social login

---

## Step 3 — Enable Firestore

1. **Build → Firestore Database → Create database**
2. Choose **"Start in test mode"** (for development)
3. Select a region close to your users (e.g. `asia-south1` for South Asia)

### Firestore Collection Schema

Create these collections with sample documents to test:

```
📁 users/{uid}
   id: string
   full_name: string
   email: string
   role: "patient" | "admin"
   blood_group: string?
   phone: string?
   created_at: timestamp

📁 blood_stock/{stockId}
   id: string
   blood_group: "A+" | "A-" | "B+" | "B-" | "AB+" | "AB-" | "O+" | "O-"
   hospital_name: string
   location: string
   units_available: number (≥ 0)
   last_updated: timestamp
   hospital_id: string?

📁 blood_requests/{requestId}
   id: string
   requester_name: string
   requester_uid: string
   blood_group: string
   units: number
   hospital_name: string
   location: string
   status: "pending" | "approved" | "fulfilled" | "cancelled"
   urgency: "normal" | "urgent" | "critical"
   created_at: timestamp
   reason: string?
   patient_name: string?

📁 donors/{donorId}
   id: string
   uid: string   (links to Firebase Auth user)
   name: string
   blood_group: string
   location: string
   is_available: boolean
   last_donation_date: timestamp?
   total_donations: number

📁 hospitals/{hospitalId}
   id: string
   name: string
   location: string
   phone: string?
   is_open_24_hours: boolean
   blood_units_by_group: map  (e.g. {"A+": 12, "O-": 3})
   last_updated: timestamp

📁 doctors/{doctorId}
   id: string
   name: string
   specialty: string
   hospital_name: string
   location: string
   rating: number (0-5)
   years_experience: number
   consultation_fee: number?
   image_url: string?
   is_available_today: boolean
   bio: string?
```

---

## Step 4 — Register Flutter App

1. In Firebase Console: **Project Settings (gear icon) → General**
2. Under **"Your apps"**, click **"Add app" → Web** (for Flutter web)
   - App nickname: `CliniX Web`
   - No Firebase Hosting needed
3. Copy the config values — you'll need them for `flutterfire configure`

---

## Step 5 — Run FlutterFire Configure

Install the FlutterFire CLI if not installed:

```powershell
dart pub global activate flutterfire_cli
```

Then in your Flutter project:

```powershell
cd e:\CliniX\clinix
flutterfire configure
```

- Select your Firebase project
- Select **Web** platform (and Android/iOS if needed)
- This generates `lib/firebase_options.dart` automatically

---

## Step 6 — Enable Firebase in the App

In `clinix/.env`:
```env
USE_FIREBASE=true
USE_MOCK_DATA=false   # optional — can keep mock while testing Firebase auth
```

---

## Step 7 — Backend Firebase Admin SDK

1. Firebase Console → **Project Settings → Service accounts**
2. Click **"Generate new private key"** → downloads a JSON file
3. Open the JSON and copy these three values into `backend/.env`:

```env
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY=-----BEGIN PRIVATE KEY-----\nYOUR_KEY\n-----END PRIVATE KEY-----\n
```

> ⚠️ **Keep the JSON file off of git.** Only put the three values in `backend/.env`.

---

## Step 8 — Firestore Security Rules (Production)

Replace test-mode rules with these before going to production:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users can only read/write their own profile
    match /users/{uid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }

    // Blood stock is public read; writes go through backend only
    match /blood_stock/{id} {
      allow read: if true;
      allow write: if false;  // backend writes via Admin SDK
    }

    // Blood requests: user can read their own; writes through backend
    match /blood_requests/{id} {
      allow read: if request.auth != null &&
                     request.auth.uid == resource.data.requester_uid;
      allow write: if false;
    }

    // Donors: public read (no contact details stored); write through backend
    match /donors/{id} {
      allow read: if true;
      allow write: if false;
    }

    // Hospitals and doctors: public read
    match /hospitals/{id} {
      allow read: if true;
      allow write: if false;
    }
    match /doctors/{id} {
      allow read: if true;
      allow write: if false;
    }
  }
}
```

---

## Quick Start Checklist

- [ ] Created Firebase project
- [ ] Enabled Email/Password Auth
- [ ] Created Firestore database (test mode)
- [ ] Ran `flutterfire configure` → `lib/firebase_options.dart` generated
- [ ] Set `USE_FIREBASE=true` in `clinix/.env`
- [ ] Added Firebase Admin SDK credentials to `backend/.env`
- [ ] Backend started with `uvicorn app.main:app --reload`
- [ ] FlutterApp restarted with `flutter run -d chrome --web-port=8080`
