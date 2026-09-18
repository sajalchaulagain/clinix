"""Blood stock/request tests: filters, lifecycle, units invariants, 404s."""


def test_list_stock_filter(client, user_headers):
    response = client.get("/api/v1/blood/stock", headers=user_headers,
                          params={"blood_group": "O+"})
    assert response.status_code == 200
    rows = response.json()
    assert rows and all(r["blood_group"] == "O+" for r in rows)
    assert all(r["units_available"] >= 0 for r in rows)


def test_low_stock_filter(client, user_headers):
    response = client.get("/api/v1/blood/stock", headers=user_headers,
                          params={"low_stock": True})
    assert all(r["units_available"] <= 5 for r in response.json())


def test_create_and_get_own_request(client, user_headers):
    response = client.post("/api/v1/blood/requests", headers=user_headers, json={
        "blood_group": "A+", "units": 2, "hospital_name": "City General Hospital",
        "location": "Kathmandu", "urgency": "urgent", "reason": "Surgery",
    })
    assert response.status_code == 201
    body = response.json()
    assert body["status"] == "pending"
    assert body["requester_name"] == "Dev User"

    mine = client.get("/api/v1/blood/requests/my", headers=user_headers)
    assert any(r["id"] == body["id"] for r in mine.json())


def test_my_requests_before_path_param(client, user_headers):
    """Regression: /requests/my must NOT be swallowed by /requests/{request_id}."""
    response = client.get("/api/v1/blood/requests/my", headers=user_headers)
    assert response.status_code == 200
    assert isinstance(response.json(), list)


def test_get_missing_request_404(client, user_headers):
    response = client.get("/api/v1/blood/requests/does-not-exist", headers=user_headers)
    assert response.status_code == 404
    assert isinstance(response.json()["detail"], str)


def test_units_validation(client, user_headers):
    response = client.post("/api/v1/blood/requests", headers=user_headers, json={
        "blood_group": "A+", "units": 25, "hospital_name": "H", "location": "L",
    })
    assert response.status_code == 422


def test_status_transition_rules(client, admin_headers):
    # Fulfilled requests are terminal — no transition allowed.
    response = client.put("/api/v1/blood/requests/req-3/status", headers=admin_headers,
                          json={"status": "cancelled"})
    assert response.status_code == 409

    # Pending -> approved is allowed.
    response = client.put("/api/v1/blood/requests/req-1/status", headers=admin_headers,
                          json={"status": "approved"})
    assert response.status_code == 200
    assert response.json()["status"] == "approved"
