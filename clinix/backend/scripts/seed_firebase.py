import os
import sys
import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime, timezone

# Ensure we're running in the backend directory context
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.core.config import settings

def seed_firebase():
    if not settings.FIREBASE_PROJECT_ID:
        print("No FIREBASE_PROJECT_ID found in .env. Skipping seed.")
        return

    # Check if app already initialized
    try:
        app = firebase_admin.get_app()
    except ValueError:
        cert = {
            "type": "service_account",
            "project_id": settings.FIREBASE_PROJECT_ID,
            "private_key": settings.FIREBASE_PRIVATE_KEY.replace('\\n', '\n'),
            "client_email": settings.FIREBASE_CLIENT_EMAIL,
            "token_uri": "https://oauth2.googleapis.com/token",
        }
        cred = credentials.Certificate(cert)
        app = firebase_admin.initialize_app(cred)

    db = firestore.client()

    hospitals = [
        {
            "id": "hosp-1",
            "name": "Bir Hospital",
            "location": "Kantipath, Kathmandu",
            "phone": "977-1-4221988",
            "is_open_24_hours": True,
            "blood_units_by_group": {"A+": 12, "O+": 25, "B+": 8},
            "last_updated": datetime.now(timezone.utc),
        },
        {
            "id": "hosp-2",
            "name": "Teaching Hospital",
            "location": "Maharajgunj, Kathmandu",
            "phone": "977-1-4412303",
            "is_open_24_hours": True,
            "blood_units_by_group": {"O-": 4, "AB+": 2, "A-": 1},
            "last_updated": datetime.now(timezone.utc),
        },
        {
            "id": "hosp-3",
            "name": "Patan Hospital",
            "location": "Lagankhel, Lalitpur",
            "phone": "977-1-5522278",
            "is_open_24_hours": True,
            "blood_units_by_group": {"B-": 3, "A+": 15, "O+": 10},
            "last_updated": datetime.now(timezone.utc),
        }
    ]

    print("Seeding hospitals...")
    hospitals_ref = db.collection('hospitals')
    for h in hospitals:
        hospitals_ref.document(h['id']).set(h, merge=True)

    doctors = [
        {
            "id": "doc-1",
            "name": "Dr. Sanduk Ruit",
            "specialty": "Ophthalmology",
            "hospital_name": "Tilganga Institute of Ophthalmology",
            "location": "Gaushala, Kathmandu",
            "rating": 4.9,
            "years_experience": 35,
            "consultation_fee": 500,
            "is_available_today": True,
            "bio": "World-renowned ophthalmologist.",
        },
        {
            "id": "doc-2",
            "name": "Dr. Bhagawan Koirala",
            "specialty": "Cardiology",
            "hospital_name": "Manmohan Cardiothoracic",
            "location": "Maharajgunj, Kathmandu",
            "rating": 4.8,
            "years_experience": 28,
            "consultation_fee": 800,
            "is_available_today": False,
            "bio": "Leading cardiothoracic surgeon.",
        }
    ]

    print("Seeding doctors...")
    doctors_ref = db.collection('doctors')
    for d in doctors:
        doctors_ref.document(d['id']).set(d, merge=True)

    print("Seeding complete.")

if __name__ == "__main__":
    seed_firebase()
