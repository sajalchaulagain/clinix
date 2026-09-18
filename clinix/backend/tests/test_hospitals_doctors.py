def test_hospitals_list_and_filter(client, user_headers):
    response = client.get("/api/v1/hospitals", headers=user_headers,
                          params={"location": "Lalitpur"})
    assert response.status_code == 200
    assert all("lalitpur" in h["location"].lower() for h in response.json())


def test_hospital_detail_shape(client, user_headers):
    response = client.get("/api/v1/hospitals/hos-1", headers=user_headers)
    assert response.status_code == 200
    body = response.json()
    assert body["blood_units_by_group"]["A+"] == 24
    assert "last_updated" in body


def test_missing_hospital_404(client, user_headers):
    assert client.get("/api/v1/hospitals/nope", headers=user_headers).status_code == 404


def test_doctors_list_filter(client, user_headers):
    response = client.get("/api/v1/doctors", headers=user_headers,
                          params={"specialty": "cardiology"})
    assert all("cardio" in d["specialty"].lower() for d in response.json())


def test_recommended_before_path_param(client, user_headers):
    """Regression: /doctors/recommended must not match /doctors/{doctor_id}."""
    response = client.get("/api/v1/doctors/recommended", headers=user_headers)
    assert response.status_code == 200
    rows = response.json()
    assert rows
    ratings = [d["rating"] for d in rows]
    assert ratings == sorted(ratings, reverse=True)


def test_doctor_detail_404(client, user_headers):
    assert client.get("/api/v1/doctors/nope", headers=user_headers).status_code == 404
