"""Test configuration: the entire test suite runs in mock mode with NO
external services, NO Firebase credentials, and the in-memory store.

Auth tokens used by these tests (development bypass honored only in mock mode):
    Authorization: Bearer dev-user   -> patient "dev-user"
    Authorization: Bearer dev-admin  -> admin (custom-claim role 'admin')
"""
import os

# Set BEFORE the app is imported so get_settings() picks them up.
os.environ["MOCK_EXTERNAL_SERVICES"] = "true"
os.environ["APP_ENV"] = "test"
os.environ["ALLOWED_ORIGINS"] = "http://localhost:8080"

import pytest  # noqa: E402
from fastapi.testclient import TestClient  # noqa: E402

from app.main import app  # noqa: E402


@pytest.fixture(scope="session")
def client() -> TestClient:
    with TestClient(app) as test_client:
        yield test_client


@pytest.fixture()
def user_headers() -> dict:
    return {"Authorization": "Bearer dev-user"}


@pytest.fixture()
def admin_headers() -> dict:
    return {"Authorization": "Bearer dev-admin"}
