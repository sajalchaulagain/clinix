"""Admin gating + CRUD tests. The Flutter admin UI hides these screens for
patients — hiding is UX, THIS suite tests the real security boundary."""

def test_admin_stats_gated_for_patients(client, user_headers):
    assert client.get("/api/v1/admin/stats", headers=user_headers).status_code == 403


def test_admin_stats_unauthenticated(client):
    assert client.get("/api/v1/admin/stats").status_code == 401


def test_admin_stats_returns_contract(client, admin_headers):
    body = client.get("/api/v1/admin/stats", headers=admin_headers).json()
    for key in ("total_donors", "available_blood_units", "total_blood_requests",
                "registered_hospitals", "pending_requests", "total_users"):
        assert isinstance(body[key], int)
    assert body["available_blood_units"] >= 0


def test_inventory_crud_recomputes_units_map(client, admin_headers):
    created = client.post("/api/v1/admin/blood-inventory", headers=admin_headers, json={
        "blood_group": "A-", "hospital_name": "City General Hospital",
        "location": "Kathmandu", "units_available": 7, "hospital_id": "hos-1",
    })
    assert created.status_code == 201
    stock_id = created.json()["id"]

    stock = client.get(f"/api/v1/blood/stock/{stock_id}",
                       headers=admin_headers)
    assert stock.json()["units_available"] == 7

    # Hospital map was recomputed after the create.
    hospital = client.get("/api/v1/hospitals/hos-1", headers=admin_headers).json()
    assert hospital["blood_units_by_group"]["A-"] == 7

    updated = client.put(f"/api/v1/admin/blood-inventory/{stock_id}",
                         headers=admin_headers, json={
            "blood_group": "A-", "hospital_name": "City General Hospital",
            "location": "Kathmandu", "units_available": 3, "hospital_id": "hos-1",
        })
    assert updated.json()["units_available"] == 3

    hospital = client.get("/api/v1/hospitals/hos-1", headers=admin_headers).json()
    assert hospital["blood_units_by_group"]["A-"] == 3

    deleted = client.delete(f"/api/v1/admin/blood-inventory/{stock_id}",
                            headers=admin_headers)
    assert deleted.status_code == 200
    assert client.get(f"/api/v1/blood/stock/{stock_id}",
                      headers=admin_headers).status_code == 404


def test_inventory_units_cannot_be_negative(client, admin_headers):
    response = client.post("/api/v1/admin/blood-inventory", headers=admin_headers, json={
        "blood_group": "O-", "hospital_name": "H", "location": "L",
        "units_available": -5, "hospital_id": None,
    })
    assert response.status_code == 422


def test_admin_hospital_crud(client, admin_headers):
    created = client.post("/api/v1/admin/hospitals", headers=admin_headers, json={
        "name": "Norvic International", "location": "Kathmandu",
        "phone": "+977-1-5550004", "is_open_24_hours": True,
    })
    assert created.status_code == 201
    hid = created.json()["id"]

    updated = client.put(f"/api/v1/admin/hospitals/{hid}", headers=admin_headers, json={
        "name": "Norvic International", "location": "Kathmandu",
        "phone": None, "is_open_24_hours": False,
    })
    assert updated.json()["is_open_24_hours"] is False

    assert client.delete(f"/api/v1/admin/hospitals/{hid}",
                         headers=admin_headers).status_code == 200


def test_admin_users_and_broadcast(client, admin_headers, user_headers):
    client.get("/api/v1/notifications/device-token", headers=user_headers)  # warm auth
    client.post("/api/v1/notifications/device-token", headers=user_headers,
                json={"token": "broadcast-test-token-999", "platform": "android"})
    users = client.get("/api/v1/admin/users", headers=admin_headers)
    assert users.status_code == 200

    client.get("/api/v1/auth/me", headers=user_headers)  # ensure user exists
    result = client.post("/api/v1/admin/notifications/broadcast",
                         headers=admin_headers,
                         json={"title": "Test", "body": "Hello everyone"})
    assert result.status_code == 200
    assert result.json()["recipients"] >= 1
