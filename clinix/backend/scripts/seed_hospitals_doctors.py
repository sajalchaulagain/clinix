import os
import sys
from datetime import datetime, timezone
import firebase_admin
from firebase_admin import credentials, firestore

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.core.config import get_settings


def seed_hospitals_doctors():
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

    hospitals = [
        {
            "id": "hosp-bir",
            "name": "Bir Hospital",
            "location": "Kantipath, Kathmandu",
            "phone": "+977-1-4221988",
            "is_open_24_hours": True,
            "blood_units_by_group": {"A+": 18, "B-": 0},
            "last_updated": datetime.now(timezone.utc),
        },
        {
            "id": "hosp-tuth",
            "name": "TU Teaching Hospital Maharajgunj",
            "location": "Maharajgunj, Kathmandu",
            "phone": "+977-1-4412303",
            "is_open_24_hours": True,
            "blood_units_by_group": {"O+": 35, "AB-": 5},
            "last_updated": datetime.now(timezone.utc),
        },
        {
            "id": "hosp-patan",
            "name": "Patan Hospital",
            "location": "Lagankhel, Lalitpur",
            "phone": "+977-1-5522295",
            "is_open_24_hours": True,
            "blood_units_by_group": {"B+": 24},
            "last_updated": datetime.now(timezone.utc),
        },
        {
            "id": "hosp-norvic",
            "name": "Norvic International Hospital",
            "location": "Thapathali, Kathmandu",
            "phone": "+977-1-5970032",
            "is_open_24_hours": True,
            "blood_units_by_group": {"AB+": 12, "O+": 40},
            "last_updated": datetime.now(timezone.utc),
        },
        {
            "id": "hosp-grande",
            "name": "Grande International Hospital",
            "location": "Dhapasi, Kathmandu",
            "phone": "+977-1-5159266",
            "is_open_24_hours": True,
            "blood_units_by_group": {"A-": 6, "B+": 15},
            "last_updated": datetime.now(timezone.utc),
        },
        {
            "id": "hosp-civil",
            "name": "Civil Service Hospital",
            "location": "Minbhawan, Kathmandu",
            "phone": "+977-1-4107000",
            "is_open_24_hours": True,
            "blood_units_by_group": {"O-": 2, "A+": 28},
            "last_updated": datetime.now(timezone.utc),
        },
        {
            "id": "hosp-kist",
            "name": "KIST Medical College Hospital",
            "location": "Imadol, Lalitpur",
            "phone": "+977-1-5201496",
            "is_open_24_hours": True,
            "blood_units_by_group": {},
            "last_updated": datetime.now(timezone.utc),
        },
        {
            "id": "hosp-dhulikhel",
            "name": "Dhulikhel Hospital",
            "location": "Dhulikhel, Kavre",
            "phone": "+977-11-490497",
            "is_open_24_hours": True,
            "blood_units_by_group": {},
            "last_updated": datetime.now(timezone.utc),
        },
    ]

    doctors = [
        {
            "id": "doc-01",
            "name": "Dr. Ram Shrestha",
            "specialty": "Cardiology",
            "hospital_name": "Bir Hospital",
            "location": "Kantipath, Kathmandu",
            "rating": 4.8,
            "years_experience": 15,
            "consultation_fee": 800.0,
            "is_available_today": True,
            "bio": "Senior Consultant Cardiologist specializing in interventional cardiology.",
        },
        {
            "id": "doc-02",
            "name": "Dr. Sita Adhikari",
            "specialty": "Pediatrics",
            "hospital_name": "TU Teaching Hospital Maharajgunj",
            "location": "Maharajgunj, Kathmandu",
            "rating": 4.9,
            "years_experience": 12,
            "consultation_fee": 1000.0,
            "is_available_today": True,
            "bio": "Consultant Pediatrician with expertise in child development and neonatology.",
        },
        {
            "id": "doc-03",
            "name": "Dr. Anish Sharma",
            "specialty": "General Medicine",
            "hospital_name": "Patan Hospital",
            "location": "Lagankhel, Lalitpur",
            "rating": 4.7,
            "years_experience": 10,
            "consultation_fee": 600.0,
            "is_available_today": True,
            "bio": "General Physician focused on preventative care and chronic illness management.",
        },
        {
            "id": "doc-04",
            "name": "Dr. Puja Karki",
            "specialty": "Gynecology & Obstetrics",
            "hospital_name": "Norvic International Hospital",
            "location": "Thapathali, Kathmandu",
            "rating": 4.9,
            "years_experience": 18,
            "consultation_fee": 1500.0,
            "is_available_today": True,
            "bio": "Senior Obstetrician and Gynecologist specialized in high-risk pregnancies.",
        },
        {
            "id": "doc-05",
            "name": "Dr. Bikash Thapa",
            "specialty": "Orthopedics",
            "hospital_name": "Grande International Hospital",
            "location": "Dhapasi, Kathmandu",
            "rating": 4.6,
            "years_experience": 14,
            "consultation_fee": 1200.0,
            "is_available_today": True,
            "bio": "Orthopedic Surgeon expert in joint replacement and sports trauma.",
        },
        {
            "id": "doc-06",
            "name": "Dr. Sunita Maharjan",
            "specialty": "Dermatology",
            "hospital_name": "Civil Service Hospital",
            "location": "Minbhawan, Kathmandu",
            "rating": 4.8,
            "years_experience": 8,
            "consultation_fee": 700.0,
            "is_available_today": True,
            "bio": "Consultant Dermatologist for skin disorders, allergies, and cosmetic care.",
        },
        {
            "id": "doc-07",
            "name": "Dr. Praveen Giri",
            "specialty": "Neurology",
            "hospital_name": "KIST Medical College Hospital",
            "location": "Imadol, Lalitpur",
            "rating": 4.9,
            "years_experience": 16,
            "consultation_fee": 1500.0,
            "is_available_today": True,
            "bio": "Consultant Neurologist specializing in stroke management and headache care.",
        },
        {
            "id": "doc-08",
            "name": "Dr. Nisha Dahal",
            "specialty": "Psychiatry",
            "hospital_name": "Dhulikhel Hospital",
            "location": "Dhulikhel, Kavre",
            "rating": 4.7,
            "years_experience": 11,
            "consultation_fee": 1000.0,
            "is_available_today": True,
            "bio": "Consultant Psychiatrist dedicated to mental wellness and behavioral health.",
        },
        {
            "id": "doc-09",
            "name": "Dr. Deepak Pokharel",
            "specialty": "Gastroenterology",
            "hospital_name": "Bir Hospital",
            "location": "Kantipath, Kathmandu",
            "rating": 4.8,
            "years_experience": 20,
            "consultation_fee": 1000.0,
            "is_available_today": True,
            "bio": "Senior Gastroenterologist skilled in therapeutic endoscopy and liver health.",
        },
        {
            "id": "doc-10",
            "name": "Dr. Archana Joshi",
            "specialty": "ENT",
            "hospital_name": "Patan Hospital",
            "location": "Lagankhel, Lalitpur",
            "rating": 4.9,
            "years_experience": 13,
            "consultation_fee": 800.0,
            "is_available_today": True,
            "bio": "ENT Specialist focusing on sinus, ear micro-surgery, and throat care.",
        },
    ]

    print("Seeding Firestore collection 'hospitals'...")
    hosp_ref = db.collection("hospitals")
    for hosp in hospitals:
        hosp_ref.document(hosp["id"]).set(hosp)

    print("Seeding Firestore collection 'doctors'...")
    doc_ref = db.collection("doctors")
    for doc in doctors:
        doc_ref.document(doc["id"]).set(doc)

    print(f"Successfully seeded {len(hospitals)} hospitals and {len(doctors)} doctors!")


if __name__ == "__main__":
    seed_hospitals_doctors()
