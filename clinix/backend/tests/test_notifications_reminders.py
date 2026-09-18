"""Notification + reminder route tests: scoping by uid, read state, CRUD."""

def test_notifications_mark_read_flow(client, user_headers):
    # Seed one via the donor contact flow.
    client.post("/api/v1/donors/don-2/contact-request", headers=user_headers, json={})
    headers = {"Authorization": "Bearer don-2"}
    notifs = client.get("/api/v1/notifications", headers=headers).json()
    unread = [n for n in notifs if n["is_read"] is False]
    assert unread

    response = client.put(f"/api/v1/notifications/{unread[0]['id']}/read", headers=headers)
    assert response.json()["is_read"] is True

    response = client.put("/api/v1/notifications/read-all", headers=headers)
    assert response.status_code == 200


def test_register_device_token(client, user_headers):
    response = client.post("/api/v1/notifications/device-token",
                           headers=user_headers,
                           json={"token": "test-fcm-token-abc123", "platform": "android"})
    assert response.status_code == 200


REMINDER = {
    "medicine_name": "Vitamin D3", "dosage": "1000 IU", "frequency": "once_daily",
    "times": ["08:00"], "start_date": "2026-09-19T00:00:00Z",
}


def test_reminder_crud(client, user_headers):
    created = client.post("/api/v1/reminders", headers=user_headers, json=REMINDER)
    assert created.status_code == 201
    reminder_id = created.json()["id"]

    listed = client.get("/api/v1/reminders", headers=user_headers)
    assert any(r["id"] == reminder_id for r in listed.json())

    updated = client.put(f"/api/v1/reminders/{reminder_id}", headers=user_headers,
                         json={**REMINDER, "dosage": "2000 IU"})
    assert updated.json()["dosage"] == "2000 IU"

    deleted = client.delete(f"/api/v1/reminders/{reminder_id}", headers=user_headers)
    assert deleted.status_code == 200


def test_reminder_time_format_validation(client, user_headers):
    bad = {**REMINDER, "times": ["25:70"]}
    assert client.post("/api/v1/reminders", headers=user_headers, json=bad).status_code == 422


def test_reminders_not_shared_between_users(client, user_headers):
    other = {"Authorization": "Bearer some-other-user"}
    listed = client.get("/api/v1/reminders", headers=other).json()
    assert all(r["medicine_name"] != "Vitamin D3" for r in listed)
