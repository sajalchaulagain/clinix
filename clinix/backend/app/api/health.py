"""Health check — no auth, no secrets, no version internals."""
from fastapi import APIRouter

from app.core.firebase import firebase_ready

router = APIRouter(tags=["health"])


@router.get("/health")
async def health() -> dict:
    return {"status": "ok", "firebase": "configured" if firebase_ready() else "memory-store"}
