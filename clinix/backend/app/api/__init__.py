"""Router assembly for /api/v1."""
from fastapi import APIRouter

from app.api import (admin, ai, auth, blood, doctor, donor, health, hospital,
                     medicine, mental_health, notification, reminder)

api_router = APIRouter()
api_router.include_router(health.router)
api_router.include_router(auth.router)
api_router.include_router(ai.router)
api_router.include_router(medicine.router)
api_router.include_router(mental_health.router)
api_router.include_router(blood.router)
api_router.include_router(donor.router)
api_router.include_router(hospital.router)
api_router.include_router(doctor.router)
api_router.include_router(notification.router)
api_router.include_router(reminder.router)
api_router.include_router(admin.router)
