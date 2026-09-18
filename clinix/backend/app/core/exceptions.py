"""Error vocabulary.

Contract with Flutter (lib/core/network/api_exception.dart): every error body
is `{"detail": "<human-safe message>"}` — the ApiErrorMapper reads exactly this
field, so we keep FastAPI's native shape and add handlers for the rest.
"""
import logging

from fastapi import FastAPI, HTTPException, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse

logger = logging.getLogger("clinix.errors")


class ExternalServiceError(Exception):
    """An upstream provider (OpenRouter/openFDA/RxNorm/FCM) failed."""

    def __init__(self, service: str, detail: str = "") -> None:
        super().__init__(detail)
        self.service = service
        self.detail = detail or f"{service} is temporarily unavailable."


def register_exception_handlers(app: FastAPI) -> None:
    @app.exception_handler(RequestValidationError)
    async def validation_handler(
        request: Request, exc: RequestValidationError
    ) -> JSONResponse:
        # Flatten to a single friendly string so Flutter can display it.
        parts = []
        for error in exc.errors()[:3]:
            loc = ".".join(str(p) for p in error.get("loc", []) if p != "body")
            parts.append(f"{loc}: {error.get('msg')}" if loc else error.get("msg", "Invalid input"))
        return JSONResponse(
            status_code=422,
            content={"detail": " ".join(parts) or "Invalid request data."},
        )

    @app.exception_handler(ExternalServiceError)
    async def external_handler(
        request: Request, exc: ExternalServiceError
    ) -> JSONResponse:
        logger.warning("external service failure service=%s err=%s", exc.service, exc.detail)
        # 502: bad gateway; message is text safe for end users.
        return JSONResponse(
            status_code=502,
            content={"detail": f"Our {exc.service} provider is temporarily unavailable. Please try again shortly."},
        )

    @app.exception_handler(Exception)
    async def unhandled_handler(request: Request, exc: Exception) -> JSONResponse:
        # Full trace stays in server logs; clients only get a safe message.
        logger.exception("unhandled error on %s %s", request.method, request.url.path)
        return JSONResponse(
            status_code=500,
            content={"detail": "Something went wrong on our side. Please try again."},
        )

    # HTTPException keeps FastAPI's default {"detail": ...} — already compatible.
    _ = HTTPException
