"""Auth contract tests: identity comes ONLY from the bearer token;
client-sent uid/role fields must never take effect."""


def test_me_as_dev_user(client, user_headers):
    response = client.get("/api/v1/auth/me", headers=user_headers)
    assert response.status_code == 200
    body = response.json()
    assert body["id"] == "dev-user"
    assert body["role"] == "patient"


def test_me_as_dev_admin(client, admin_headers):
    response = client.get("/api/v1/auth/me", headers=admin_headers)
    assert response.json()["role"] == "admin"


def test_me_without_token_returns_401(client):
    response = client.get("/api/v1/auth/me")
    assert response.status_code == 401
    assert "detail" in response.json()
    assert isinstance(response.json()["detail"], str)


def test_update_profile_ignores_role_field(client, user_headers):
    # Even if a hostile client sends a role, it must never apply.
    response = client.put(
        "/api/v1/auth/users/me",
        headers=user_headers,
        json={"full_name": "Test User", "role": "admin", "email_verified": True},
    )
    assert response.status_code in (200, 422)  # extra fields rejected or ignored
    me = client.get("/api/v1/auth/me", headers=user_headers).json()
    assert me["role"] == "patient"
    assert me["full_name"] == "Test User"


def test_update_profile_roundtrip(client, user_headers):
    response = client.put(
        "/api/v1/auth/users/me",
        headers=user_headers,
        json={"blood_group": "O+", "phone": "+977-9812345678"},
    )
    assert response.status_code == 200
    body = response.json()
    assert body["blood_group"] == "O+"
    assert body["phone"] == "+977-9812345678"
