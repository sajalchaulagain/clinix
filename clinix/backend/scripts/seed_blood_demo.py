import os
import sys
from datetime import datetime, timezone
import firebase_admin
from firebase_admin import credentials, firestore

# Ensure we're running in the backend directory context
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.core.config import get_settings

def seed_blood_demo():
    settings = get_settings()
    if not settings.firebase_project_id:
        print("No FIREBASE_PROJECT_ID found in .env. Aborting.")
        return

    try:
        app = firebase_admin.get_app()
    except ValueError:
        cert = {
            "type": "service_account",
            "project_id": settings.firebase_project_id,
            "private_key": settings.firebase_private_key.replace('\\n', '\n'),
            "client_email": settings.firebase_client_email,
            "token_uri": "https://oauth2.googleapis.com/token",
        }
        cred = credentials.Certificate(cert)
        app = firebase_admin.initialize_app(cred)

    db = firestore.client()

    # 11 blood stock documents covering all 8 blood groups
    stock_items = [
        {
            "id": "bs-01",
            "blood_group": "A+",
            "hospital_name": "Bir Hospital",
            "location": "Kantipath, Kathmandu",
            "units_available": 18,
            "last_updated": datetime.now(timezone.utc),
            "hospital_id": "hosp-bir",
        },
        {
            "id": "bs-02",
            "blood_group": "O+",
            "hospital_name": "TU Teaching Hospital Maharajgunj",
            "location": "Maharajgunj, Kathmandu",
            "units_available": 35,
            "last_updated": datetime.now(timezone.utc),
            "hospital_id": "hosp-tuth",
        },
        {
            "id": "bs-03",
            "blood_group": "B+",
            "hospital_name": "Patan Hospital",
            "location": "Lagankhel, Lalitpur",
            "units_available": 24,
            "last_updated": datetime.now(timezone.utc),
            "hospital_id": "hosp-patan",
        },
        {
            "id": "bs-04",
            "blood_group": "AB+",
            "hospital_name": "Norvic International",
            "location": "Thapathali, Kathmandu",
            "units_available": 12,
            "last_updated": datetime.now(timezone.utc),
            "hospital_id": "hosp-norvic",
        },
        {
            "id": "bs-05",
            "blood_group": "A-",
            "hospital_name": "Grande International",
            "location": "Dhapasi, Kathmandu",
            "units_available": 6,
            "last_updated": datetime.now(timezone.utc),
            "hospital_id": "hosp-grande",
        },
        {
            "id": "bs-06",
            "blood_group": "O-",
            "hospital_name": "Civil Service Hospital",
            "location": "Minbhawan, Kathmandu",
            "units_available": 2,  # LOW STOCK DEMO
            "last_updated": datetime.now(timezone.utc),
            "hospital_id": "hosp-civil",
        },
        {
            "id": "bs-07",
            "blood_group": "B-",
            "hospital_name": "Bir Hospital",
            "location": "Kantipath, Kathmandu",
            "units_available": 0,  # OUT OF STOCK DEMO
            "last_updated": datetime.now(timezone.utc),
            "hospital_id": "hosp-bir",
        },
        {
            "id": "bs-08",
            "blood_group": "AB-",
            "hospital_name": "TU Teaching Hospital Maharajgunj",
            "location": "Maharajgunj, Kathmandu",
            "units_available": 5,
            "last_updated": datetime.now(timezone.utc),
            "hospital_id": "hosp-tuth",
        },
        {
            "id": "bs-09",
            "blood_group": "A+",
            "hospital_name": "Civil Service Hospital",
            "location": "Minbhawan, Kathmandu",
            "units_available": 28,
            "last_updated": datetime.now(timezone.utc),
            "hospital_id": "hosp-civil",
        },
        {
            "id": "bs-10",
            "blood_group": "O+",
            "hospital_name": "Norvic International",
            "location": "Thapathali, Kathmandu",
            "units_available": 40,
            "last_updated": datetime.now(timezone.utc),
            "hospital_id": "hosp-norvic",
        },
        {
            "id": "bs-11",
            "blood_group": "B+",
            "hospital_name": "Grande International",
            "location": "Dhapasi, Kathmandu",
            "units_available": 15,
            "last_updated": datetime.now(timezone.utc),
            "hospital_id": "hosp-grande",
        },
    ]

    print("Seeding Firestore collection 'blood_stock'...")
    stock_ref = db.collection('blood_stock')
    for item in stock_items:
        stock_ref.document(item['id']).set(item)

    print(f"Successfully seeded {len(stock_items)} blood stock documents into Firestore!")

if __name__ == "__main__":
    seed_blood_demo()
