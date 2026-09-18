"""AI chat contract tests. In mock mode the OpenRouter client returns
deterministic fixtures, so tests assert SHAPE + safety behavior, not prose."""

CHAT_PAYLOAD = {
    "history": [
        {"id": "m1", "text": "What usually helps with mild headaches?",
         "sender": "user", "created_at": "2026-09-19T10:00:00Z"}
    ]
}


def test_upachar_chat_returns_ai_message(client, user_headers):
    response = client.post("/api/v1/ai/chat", headers=user_headers, json=CHAT_PAYLOAD)
    assert response.status_code == 200
    body = response.json()
    assert body["sender"] == "ai"
    assert body["status"] == "sent"
    assert len(body["text"]) > 10
    assert "created_at" in body


def test_baidyek_chat_returns_ai_message(client, user_headers):
    response = client.post("/api/v1/ayurvedic/chat", headers=user_headers, json=CHAT_PAYLOAD)
    assert response.status_code == 200
    assert response.json()["sender"] == "ai"


def test_emergency_keyword_bypasses_ai(client, user_headers):
    payload = {"history": [{"id": "m1", "text": "severe chest pain right now",
                             "sender": "user", "created_at": "2026-09-19T10:00:00Z"}]}
    body = client.post("/api/v1/ai/chat", headers=user_headers, json=payload).json()
    assert "emergency" in body["text"].lower()


def test_self_harm_keyword_bypasses_ai(client, user_headers):
    payload = {"history": [{"id": "m1", "text": "I want to end my life",
                             "sender": "user", "created_at": "2026-09-19T10:00:00Z"}]}
    body = client.post("/api/v1/ai/chat", headers=user_headers, json=payload).json()
    assert "support" in body["text"].lower() or "help" in body["text"].lower()
    assert "diagnos" not in body["text"].lower()


def test_chat_requires_auth(client):
    assert client.post("/api/v1/ai/chat", json=CHAT_PAYLOAD).status_code == 401
