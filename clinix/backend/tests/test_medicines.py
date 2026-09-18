"""Medicine pipeline tests — image validation uses Pillow on REAL bytes,
AI output is parsed + Pydantic-validated (mock fixtures make it deterministic)."""
import base64

from PIL import Image
import io


def make_png_bytes(size=(64, 64), color=(200, 120, 40)) -> bytes:
    buf = io.BytesIO()
    Image.new("RGB", size, color).save(buf, format="PNG")
    return buf.getvalue()


def test_analyze_accepts_valid_image(client, user_headers):
    files = [("images", ("label.png", make_png_bytes(), "image/png"))]
    response = client.post("/api/v1/medicines/analyze", headers=user_headers, files=files)
    assert response.status_code == 200
    body = response.json()
    assert isinstance(body, list) and len(body) == 1
    med = body[0]
    assert med["is_ai_generated"] is True
    assert med["medicine_name"]
    # mock enrichment merged without duplicates
    names = [u.lower() for u in med["common_uses"]]
    assert len(names) == len(set(names))


def test_analyze_rejects_non_image_bytes(client, user_headers):
    files = [("images", ("evil.png", b"not-an-image", "image/png"))]
    response = client.post("/api/v1/medicines/analyze", headers=user_headers, files=files)
    assert response.status_code == 400
    assert "not a valid image" in response.json()["detail"]


def test_analyze_rejects_oversize(client, user_headers):
    big = make_png_bytes() + b"0" * (9 * 1024 * 1024)
    files = [("images", ("big.png", big, "image/png"))]
    response = client.post("/api/v1/medicines/analyze", headers=user_headers, files=files)
    assert response.status_code == 413


def test_analyze_requires_images(client, user_headers):
    response = client.post("/api/v1/medicines/analyze", headers=user_headers, files=[])
    assert response.status_code in (400, 422)


def test_search_matches_fixture_catalog(client, user_headers):
    response = client.get("/api/v1/medicines/search", headers=user_headers,
                          params={"query": "paracetamol"})
    assert response.status_code == 200
    results = response.json()
    assert any(r["name"].lower().startswith("paracetamol") for r in results)


def test_info_by_name(client, user_headers):
    response = client.get("/api/v1/medicines/info", headers=user_headers,
                          params={"name": "ibuprofen"})
    assert response.status_code == 200
    body = response.json()
    assert body["is_ai_generated"] is True


def test_compare_shape(client, user_headers):
    payload = {
        "analyses": [
            {"medicine_name": "Paracetamol", "generic_name": None, "common_uses": ["pain"],
             "dosage_information": None, "common_side_effects": [], "precautions": [],
             "warnings": [], "contraindications": [], "interactions": [],
             "storage_information": None, "is_ai_generated": True},
            {"medicine_name": "Ibuprofen", "is_ai_generated": True},
        ]
    }
    response = client.post("/api/v1/medicines/compare", headers=user_headers, json=payload)
    assert response.status_code == 200
    assert len(response.json()) == 2


def test_multipart_field_name_is_images(client, user_headers):
    # The Flutter ApiClient sends multipart field `images` — a wrong field
    # name would fail FastAPI validation (422), which this guards.
    files = [("files", ("label.png", make_png_bytes(), "image/png"))]
    response = client.post("/api/v1/medicines/analyze", headers=user_headers, files=files)
    assert response.status_code == 422
