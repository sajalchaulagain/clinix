"""Mental-health screening tests: deterministic banding + exact enum strings."""

def _answers(score: int, count: int = 10) -> list[dict]:
    return [{"question_id": f"mh-{i}", "selected_option_index": score, "score": score}
            for i in range(count)]


def test_stable_band_exact_string(client, user_headers):
    response = client.post("/api/v1/mental-health/analyze", headers=user_headers,
                           json={"answers": _answers(0)})
    assert response.status_code == 200
    body = response.json()
    assert body["band"] == "stable"          # exact Dart enum .name
    assert body["total_score"] == 0
    assert body["max_score"] == 30
    assert body["is_ai_generated"] is True


def test_mild_concern_band_camelcase(client, user_headers):
    # 15/30 = 0.5 → mildConcern (camelCase on purpose)
    response = client.post("/api/v1/mental-health/analyze", headers=user_headers,
                           json={"answers": _answers(1) + _answers(2, 5)})
    body = response.json()
    assert body["band"] == "mildConcern"


def test_elevated_concern_band(client, user_headers):
    response = client.post("/api/v1/mental-health/analyze", headers=user_headers,
                           json={"answers": _answers(3)})
    body = response.json()
    assert body["band"] == "elevatedConcern"
    # High bands must carry strong professional-help guidance.
    assert "professional" in body["seek_help_guidance"].lower() or "doctor" in body["seek_help_guidance"].lower()


def test_never_emits_diagnosis(client, user_headers):
    response = client.post("/api/v1/mental-health/analyze", headers=user_headers,
                           json={"answers": _answers(3)})
    text = " ".join([response.json()["summary"],
                      *response.json()["observations"]]).lower()
    assert "you have" not in text
    assert "disorder" not in text


def test_empty_answers_rejected(client, user_headers):
    response = client.post("/api/v1/mental-health/analyze", headers=user_headers,
                           json={"answers": []})
    assert response.status_code == 422
