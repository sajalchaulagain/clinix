"""Seed Firestore with demo blood stock, hospitals, doctors and donors.

Run AFTER configuring backend/.env with real Firebase Admin credentials:

    cd backend
    python scripts/seed_db.py

Safe to re-run: seeds use fixed document ids and merge-set them.
"""
from datetime import datetime, timezone

from app.core.config import get_settings
from app.core.firebase import get_db, init_firebase

SEED = {
    "hospitals": {
        "hos-1": {"id": "hos-1", "name": "City General Hospital", "location": "Kathmandu",
                   "phone": "+977-1-5550001", "is_open_24_hours": True,
                   "blood_units_by_group": {"A+": 24, "O+": 18}},
        "hos-2": {"id": "hos-2", "name": "Patan Hospital", "location": "Lalitpur",
                   "phone": "+977-1-5550002", "is_open_24_hours": True,
                   "blood_units_by_group": {"O+": 31, "B+": 9}},
        "hos-3": {"id": "hos-3", "name": "Bir Hospital", "location": "Kathmandu",
                   "phone": "+977-1-5550003", "is_open_24_hours": False,
                   "blood_units_by_group": {"AB+": 6}},
    },
    "blood_stock": {
        "stk-1": {"id": "stk-1", "blood_group": "A+", "hospital_name": "City General Hospital",
                   "location": "Kathmandu", "units_available": 24, "hospital_id": "hos-1"},
        "stk-2": {"id": "stk-2", "blood_group": "O+", "hospital_name": "City General Hospital",
                   "location": "Kathmandu", "units_available": 18, "hospital_id": "hos-1"},
        "stk-3": {"id": "stk-3", "blood_group": "O+", "hospital_name": "Patan Hospital",
                   "location": "Lalitpur", "units_available": 31, "hospital_id": "hos-2"},
        "stk-4": {"id": "stk-4", "blood_group": "B+", "hospital_name": "Patan Hospital",
                   "location": "Lalitpur", "units_available": 9, "hospital_id": "hos-2"},
        "stk-5": {"id": "stk-5", "blood_group": "AB+", "hospital_name": "Bir Hospital",
                   "location": "Kathmandu", "units_available": 6, "hospital_id": "hos-3"},
    },
    "blood_requests": {
        "req-1": {"id": "req-1", "requester_name": "Ramesh Shrestha", "blood_group": "O+",
                   "units": 2, "hospital_name": "City General Hospital", "location": "Kathmandu",
                   "status": "pending", "urgency": "urgent", "reason": "Post-surgery transfusion",
                   "patient_name": "Sita Shrestha"},
        "req-2": {"id": "req-2", "requester_name": "Anita Karki", "blood_group": "B+",
                   "units": 1, "hospital_name": "Patan Hospital", "location": "Lalitpur",
                   "status": "pending", "urgency": "normal", "reason": "Scheduled procedure",
                   "patient_name": "Anita Karki"},
        "req-3": {"id": "req-3", "requester_name": "Bikash Tamang", "blood_group": "AB+",
                   "units": 3, "hospital_name": "Bir Hospital", "location": "Kathmandu",
                   "status": "fulfilled", "urgency": "critical", "reason": "Emergency transfusion",
                   "patient_name": "Bikash Tamang"},
    },
    "donors": {
        "don-1": {"id": "don-1", "name": "Aarav Bhattarai", "blood_group": "O+",
                   "location": "Kathmandu", "is_available": True, "total_donations": 0},
        "don-2": {"id": "don-2", "name": "Priya Maharjan", "blood_group": "A+",
                   "location": "Kathmandu", "is_available": False, "total_donations": 3},
        "don-3": {"id": "don-3", "name": "Sandeep Gurung", "blood_group": "B+",
                   "location": "Lalitpur", "is_available": True, "total_donations": 5},
    },
    "doctors": {
        "doc-1": {"id": "doc-1", "name": "Dr. Nisha Adhikari", "specialty": "Cardiology",
                   "hospital_name": "City General Hospital", "location": "Kathmandu",
                   "rating": 4.8, "years_experience": 12, "consultation_fee": 1200.0,
                   "image_url": None, "is_available_today": True,
                   "bio": "Cardiologist focused on preventive heart care."},
        "doc-2": {"id": "doc-2", "name": "Dr. Rajan Shrestha", "specialty": "Dermatology",
                   "hospital_name": "DermaCare Clinic", "location": "Kathmandu",
                   "rating": 4.6, "years_experience": 8, "consultation_fee": 900.0,
                   "image_url": None, "is_available_today": False,
                   "bio": "Skin conditions and preventive skin care."},
        "doc-3": {"id": "doc-3", "name": "Dr. Anita Karki", "specialty": "Pediatrics",
                   "hospital_name": "Kanti Children's Hospital", "location": "Kathmandu",
                   "rating": 4.7, "years_experience": 10, "consultation_fee": 1000.0,
                   "image_url": None, "is_available_today": True,
                   "bio": "Child health, immunization and growth monitoring."},
        "doc-4": {"id": "doc-4", "name": "Dr. Bikash Thapa", "specialty": "Orthopedics",
                   "hospital_name": "Patan Hospital", "location": "Lalitpur",
                   "rating": 4.4, "years_experience": 15, "consultation_fee": 1500.0,
                   "image_url": None, "is_available_today": False,
                   "bio": "Bone and joint care, sports injuries."},
    },
}


def main() -> None:
    settings = get_settings()
    if not settings.firebase_configured:
        print("Firebase Admin credentials are not configured in backend/.env")
        print(" (dev mode uses the in-memory store automatically — no seeding needed).")
        raise SystemExit(1)

    init_firebase(settings)
    db = get_db()
    assert db is not None

    now = datetime.now(timezone.utc)
    total = 0
    for collection, docs in SEED.items():
        for doc_id, data in docs.items():
            payload = {**data, "last_updated": now} if "last_updated" not in data and collection in ("hospitals", "blood_stock") else {
                **data, **({"created_at": now} if collection == "blood_requests" else {})}
            db.collection(collection).document(doc_id).set(payload, merge=True)
            total += 1
        print(f"✓ {collection}: {len(docs)} docs")
    print(f"Seeded {total} documents.")


if __name__ == "__main__":
    main()
