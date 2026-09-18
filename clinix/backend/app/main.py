"""CliniX FastAPI application entry point.

Run locally:

    cd backend
    python -m venv .venv && source .venv/bin/activate
    pip install -r requirements.txt
    cp .env.example .env
    uvicorn app.main:app --reload
"""
import logging
import time
from contextlib import asynccontextmanager

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from slowapi.errors import RateLimitExceeded
from slowapi.middleware import SlowAPIMiddleware
from fastapi.responses import JSONResponse

from app.api import api_router
from app.api.limiter import limiter
from app.core.config import get_settings
from app.core.exceptions import register_exception_handlers
from app.core.firebase import init_firebase
from app.core.logging import new_request_id, setup_logging

logger = logging.getLogger("clinix.app")
settings = get_settings()


@asynccontextmanager
async def lifespan(app: FastAPI):
    setup_logging(settings.debug)
    init_firebase(settings)
    logger.info(
        "CliniX backend starting env=%s mock_mode=%s",
        settings.app_env, settings.mock_external_services,
    )
    yield


app = FastAPI(
    title="CliniX API",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan,
)

# --------------------------------------------------------------------------
# Security middleware order: request-id logging -> CORS -> rate limiting.
# --------------------------------------------------------------------------
@app.middleware("http")
async def request_context(request: Request, call_next):
    request_id = new_request_id()
    start = time.perf_counter()
    # Never log Authorization headers, tokens, or request bodies here.
    logger.info("req=%s %s %s", request_id, request.method, request.url.path)
    response = await call_next(request)
    duration_ms = (time.perf_counter() - start) * 1000
    response.headers["X-Request-Id"] = request_id
    logger.info("req=%s status=%s %.1fms", request_id, response.status_code, duration_ms)
    return response


app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,   # explicit origins only — never "*"
    allow_credentials=False,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["Authorization", "Content-Type"],
    max_age=600,
)

app.state.limiter = limiter
app.add_middleware(SlowAPIMiddleware)


@app.exception_handler(RateLimitExceeded)
async def rate_limit_handler(request: Request, exc: RateLimitExceeded) -> JSONResponse:
    return JSONResponse(
        status_code=429,
        content={"detail": "Too many requests. Please wait a moment and try again."},
    )


register_exception_handlers(app)
app.include_router(api_router, prefix=settings.api_prefix)


@app.get("/health", include_in_schema=False)
async def root_health() -> dict:
    return {"status": "ok"}
