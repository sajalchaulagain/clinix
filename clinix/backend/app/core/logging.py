import logging
import sys
import uuid


def setup_logging(debug: bool = False) -> None:
    level = logging.DEBUG if debug else logging.INFO
    logging.basicConfig(
        level=level,
        format="%(asctime)s %(levelname)s %(name)s %(message)s",
        stream=sys.stdout,
    )


def new_request_id() -> str:
    return uuid.uuid4().hex[:12]


# Security: never log Authorization headers, tokens, API keys, or image bytes.
SENSITIVE_HEADERS = {"authorization", "cookie", "x-api-key"}
