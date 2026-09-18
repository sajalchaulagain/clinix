"""Donor tests: privacy rule — no endpoint ever leaks a contact number."""

def test_list_donors_no_contact_fields(client, user_headers):
    response = client.get("/api/v1/donors", headers=user_headers)
    assert response.status_code == 200
    donors = response.json()
    assert donors
    for donor in donors:
        assert "phone" not in donor
        assert "contact" not in donor


def test_filter_by_group(client, user_headers):
    response = client.get("/api/v1/donors", headers=user_headers,
                          params={"blood_group": "B+"})
    assert all(d["blood_group"] == "B+" for d in response.json())


def test_become_and_fetch_me(client, user_headers):
    response = client.post("/api/v1/donors/me", headers=user_headers,
                           json={"blood_group": "O+", "location": "Pokhara"})
    assert response.status_code == 201
    me = client.get("/api/v1/donors/me", headers=user_headers)
    assert me.status_code == 200
    assert me.json()["blood_group"] == "O+"


def test_contact_request_creates_notification(client, user_headers):
    response = client.post("/api/v1/donors/don-1/contact-request",
                           headers=user_headers, json={"note": "Urgent A- need"})
    assert response.status_code == 200
    # Donor should have received a bloodRequest notification.
    # (dev-user acts as donor-1's account in this mock store)
    notifs = client.get("/api/v1/notifications",
                        headers={"Authorization": "Bearer don-1"}).json()
    assert any(n["type"] == "bloodRequest" for n in notifs)


def test_contact_request_missing_donor_404(client, user_headers):
    response = client.post("/api/v1/donors/nope/contact-request",
                           headers=user_headers, json={})
    assert response.status_code == 404
