# Firestore schema

Written through the Admin SDK (bypasses rules), but these are also the shapes
the Flutter app may read directly via firestore_service when USE_FIREBASE=true.

## Collections

### users/{uid}
```json
{ "id": "<uid>", "full_name": "", "email": "", "role": "patient|admin",
  "phone": null, "date_of_birth": null, "blood_group": null,
  "emergency_contact": null, "photo_url": null, "email_verified": false,
  "created_at": "Timestamp" }
```
`role` here mirrors the custom claim for display; authorization always reads
the VERIFIED CLAIM from the token, never this document.

### users/{uid}/reminders/{id}
```json
{ "id", "medicine_name", "dosage", "frequency", "times": ["08:00"],
  "start_date", "end_date": null, "notes": null, "is_enabled": true, "created_at" }
```

### users/{uid}/notifications/{id}
```json
{ "id", "type": "reminder|bloodRequest|bloodAvailability|system|aiResult|appointment",
  "title", "body", "created_at", "is_read": false, "payload": null }
```

### users/{uid}/device_tokens/{tokenSuffix}
```json
{ "token", "platform": "android|ios|web|unknown", "updated_at" }
```

### blood_stock/{id}
```json
{ "id", "blood_group": "A+", "hospital_name", "location",
  "units_available": 0,  "last_updated", "hospital_id" }
```
Invariant: `units_available` never negative (transactional decrement).

### blood_requests/{id}
```json
{ "id", "requester_name", "requester_uid", "blood_group", "units",
  "hospital_name", "location", "status": "pending|approved|fulfilled|cancelled",
  "urgency": "normal|urgent|critical", "reason": null, "patient_name": null,
  "created_at" }
```

### donors/{uid}
```json
{ "id": "<uid>", "name", "blood_group", "location",
  "is_available": true, "last_donation_date": null, "total_donations": 0 }
```
Privacy rule: **no phone/contact fields are stored here** — donor contact is
mediated through in-app notifications (`donor_contacts` arrive as
`bloodRequest` notifications).

### hospitals/{id}
```json
{ "id", "name", "location", "phone", "is_open_24_hours": false,
  "blood_units_by_group": {"A+": 24}, "last_updated" }
```
`blood_units_by_group` is recomputed server-side whenever stock rows change
for that hospital.

### doctors/{id}
```json
{ "id", "name", "specialty", "hospital_name", "location", "rating": 0.0,
  "years_experience": 0, "consultation_fee": null, "image_url": null,
  "is_available_today": false, "bio": null }
```

## Seeding
`python scripts/seed_db.py` writes demo docs (fixed ids `hos-1`, `stk-1`,
`req-1`, `don-1`, `doc-1` …) using merge-set, safe to re-run.

## Suggested client-side security rules

Client writes are limited to auth/* anyway; if the app reads Firestore
directly, protect it:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{db}/documents {
    function signedIn() { return request.auth != null; }
    match /users/{uid} {
      allow read, update: if signedIn() && request.auth.uid == uid;
      match /{sub=**} { allow read, write: if signedIn() && request.auth.uid == uid; }
    }
    match /{collection=**} { allow read: if signedIn(); allow write: if false; }
  }
}
```
All mutations then flow through the Admin SDK via the FastAPI backend.
