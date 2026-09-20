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


# -------------------------------------------------------- donation requests
_DONATION_PAYLOAD = {
    "donor_name": "Hari Prasad",
    "phone": "+977-9812345678",
    "blood_group": "O+",
    "units": 1,
    "hospital_name": "Patan Hospital",
    "location": "Lalitpur",
}


def test_donation_request_unauthenticated(client):
    response = client.post("/api/v1/blood/donation-requests", json=_DONATION_PAYLOAD)
    assert response.status_code == 401


def test_create_donation_request_appears_in_my(client, user_headers):
    resp = client.post("/api/v1/blood/donation-requests",
                       headers=user_headers, json=_DONATION_PAYLOAD)
    assert resp.status_code == 201
    body = resp.json()
    assert body["status"] == "pending"
    assert body["donor_name"] == "Hari Prasad"
    assert body["blood_group"] == "O+"

    mine = client.get("/api/v1/blood/donation-requests/my", headers=user_headers)
    assert mine.status_code == 200
    assert any(r["id"] == body["id"] for r in mine.json())


def test_cancel_donation_request(client, user_headers):
    resp = client.post("/api/v1/blood/donation-requests",
                       headers=user_headers, json=_DONATION_PAYLOAD)
    assert resp.status_code == 201
    don_id = resp.json()["id"]

    cancel = client.put(f"/api/v1/blood/donation-requests/{don_id}/cancel",
                        headers=user_headers)
    assert cancel.status_code == 200
    assert cancel.json()["status"] == "cancelled"


def test_donation_phone_validation(client, user_headers):
    bad = {**_DONATION_PAYLOAD, "phone": "123"}
    resp = client.post("/api/v1/blood/donation-requests",
                       headers=user_headers, json=bad)
    assert resp.status_code == 422


def test_donation_units_max_2(client, user_headers):
    bad = {**_DONATION_PAYLOAD, "units": 5}
    resp = client.post("/api/v1/blood/donation-requests",
                       headers=user_headers, json=bad)
    assert resp.status_code == 422

