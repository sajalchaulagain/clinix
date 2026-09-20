"""Data-access foundation.

Every repository talks to Firestore (firebase-admin) when it is configured,
or to a deterministic in-memory store when running local development with
MOCK_EXTERNAL_SERVICES=true. The store keeps dev runs stateful across
requests (create → list cycles work) without needing Google credentials.

Firestore layout (documented in backend/docs/firestore-schema.md):

    users/{uid}
    users/{uid}/reminders/{id}
    users/{uid}/notifications/{id}
    users/{uid}/device_tokens/{token}
    blood_stock/{id}
    blood_requests/{id}
    donors/{uid}            # doc id == auth uid, never exposes phone numbers
    hospitals/{id}
    doctors/{id}
"""
import asyncio
import uuid
from datetime import datetime, timezone

from app.core.firebase import get_db

COLLECTIONS = {
    "users": "users",
    "blood_stock": "blood_stock",
    "blood_requests": "blood_requests",
    "blood_donation_requests": "blood_donation_requests",
    "donors": "donors",
    "hospitals": "hospitals",
    "doctors": "doctors",
}


def utcnow() -> datetime:
    return datetime.now(timezone.utc)


def new_id() -> str:
    return uuid.uuid4().hex[:20]


class MemoryStore:
    """In-memory fallback for development ONLY (seeded so the UI has data)."""

    def __init__(self) -> None:
        now = utcnow()
        self.users: dict[str, dict] = {}
        self.blood_stock: dict[str, dict] = {
            "stk-1": {"id": "stk-1", "blood_group": "A+", "hospital_name": "City General Hospital",
                       "location": "Kathmandu", "units_available": 24, "last_updated": now, "hospital_id": "hos-1"},
            "stk-2": {"id": "stk-2", "blood_group": "O+", "hospital_name": "City General Hospital",
                       "location": "Kathmandu", "units_available": 18, "last_updated": now, "hospital_id": "hos-1"},
            "stk-3": {"id": "stk-3", "blood_group": "O+", "hospital_name": "Patan Hospital",
                       "location": "Lalitpur", "units_available": 31, "last_updated": now, "hospital_id": "hos-2"},
            "stk-4": {"id": "stk-4", "blood_group": "B+", "hospital_name": "Patan Hospital",
                       "location": "Lalitpur", "units_available": 9, "last_updated": now, "hospital_id": "hos-2"},
            "stk-5": {"id": "stk-5", "blood_group": "AB+", "hospital_name": "Bir Hospital",
                       "location": "Kathmandu", "units_available": 6, "last_updated": now, "hospital_id": "hos-3"},
        }
        self.blood_requests: dict[str, dict] = {
            "req-1": {"id": "req-1", "requester_name": "Ramesh Shrestha", "blood_group": "O+",
                       "units": 2, "hospital_name": "City General Hospital", "location": "Kathmandu",
                       "status": "pending", "created_at": now, "urgency": "urgent",
                       "reason": "Post-surgery transfusion", "patient_name": "Sita Shrestha"},
            "req-2": {"id": "req-2", "requester_name": "Anita Karki", "blood_group": "B+",
                       "units": 1, "hospital_name": "Patan Hospital", "location": "Lalitpur",
                       "status": "pending", "created_at": now, "urgency": "normal",
                       "reason": "Scheduled procedure", "patient_name": "Anita Karki"},
            "req-3": {"id": "req-3", "requester_name": "Bikash Tamang", "blood_group": "AB+",
                       "units": 3, "hospital_name": "Bir Hospital", "location": "Kathmandu",
                       "status": "fulfilled", "created_at": now, "urgency": "critical",
                       "reason": "Emergency transfusion", "patient_name": "Bikash Tamang"},
        }
        self.donors: dict[str, dict] = {
            "don-1": {"id": "don-1", "name": "Aarav Bhattarai", "blood_group": "O+",
                       "location": "Kathmandu", "is_available": True,
                       "last_donation_date": None, "total_donations": 0},
            "don-2": {"id": "don-2", "name": "Priya Maharjan", "blood_group": "A+",
                       "location": "Kathmandu", "is_available": False,
                       "last_donation_date": now, "total_donations": 3},
            "don-3": {"id": "don-3", "name": "Sandeep Gurung", "blood_group": "B+",
                       "location": "Lalitpur", "is_available": True,
                       "last_donation_date": now, "total_donations": 5},
        }
        self.hospitals: dict[str, dict] = {
            "hos-1": {"id": "hos-1", "name": "City General Hospital", "location": "Kathmandu",
                       "phone": "+977-1-5550001", "is_open_24_hours": True,
                       "blood_units_by_group": {"A+": 24, "O+": 18}, "last_updated": now},
            "hos-2": {"id": "hos-2", "name": "Patan Hospital", "location": "Lalitpur",
                       "phone": "+977-1-5550002", "is_open_24_hours": True,
                       "blood_units_by_group": {"O+": 31, "B+": 9}, "last_updated": now},
            "hos-3": {"id": "hos-3", "name": "Bir Hospital", "location": "Kathmandu",
                       "phone": "+977-1-5550003", "is_open_24_hours": False,
                       "blood_units_by_group": {"AB+": 6}, "last_updated": now},
        }
        self.doctors: dict[str, dict] = {
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
        }
        # uid -> collection -> docs
        self.reminders: dict[str, dict[str, dict]] = {}
        self.notifications: dict[str, dict[str, dict]] = {}
        self.device_tokens: dict[str, set[str]] = {}
        self.blood_donation_requests: dict[str, dict] = {}


MEMORY = MemoryStore()


class Repository:
    """Base for all repositories: resolves the backend at construction time."""

    def __init__(self) -> None:
        self.db = get_db()  # Firestore client or None (memory mode)

    # Firestore SDK is synchronous; keep endpoints async-friendly.
    @staticmethod
    async def run(func, *args, **kwargs):
        return await asyncio.to_thread(func, *args, **kwargs)


def doc_to_dict(doc, fallback_id: str | None = None) -> dict:
    data = doc.to_dict() or {}
    data.setdefault("id", doc.id)
    if fallback_id is not None:
        data["id"] = fallback_id
    return data
