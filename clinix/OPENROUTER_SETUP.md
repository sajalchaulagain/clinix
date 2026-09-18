# OpenRouter Setup Guide (Free Tier)

## What is OpenRouter?

OpenRouter is an API gateway that gives you access to dozens of AI models
(including free ones) through a single API. CliniX uses it for:

| Feature | Model (free) | Endpoint |
|---|---|---|
| Upachar Sathi (AI Health Chat) | `mistralai/mistral-7b-instruct:free` | `POST /api/v1/ai/chat` |
| Baidyek Sathi (Ayurvedic Chat) | `mistralai/mistral-7b-instruct:free` | `POST /api/v1/ayurvedic/chat` |
| Medicine Scanner (vision) | `google/gemma-3-27b-it:free` | `POST /api/v1/medicines/analyze` |
| Mental Health Screening | `mistralai/mistral-7b-instruct:free` | `POST /api/v1/mental-health/analyze` |

---

## Where Does the Key Live?

> ⚠️ **The OpenRouter API key lives ONLY in `backend/.env`.**  
> It is NEVER placed in the Flutter app or committed to git.

```
backend/.env          ← OpenRouter key goes HERE
clinix/.env           ← Public config only (no keys ever)
lib/                  ← Flutter code never sees the key
```

---

## Step 1 — Get a Free Key

1. Go to [https://openrouter.ai/keys](https://openrouter.ai/keys)
2. Sign in with GitHub or Google (free)
3. Click **"Create Key"** → give it a name (e.g. `clinix-dev`)
4. Copy the key — it starts with `sk-or-v1-`

> **Free tier limits**: ~200 requests/day per free model, no credit card required.

---

## Step 2 — Add the Key to the Backend

Open `backend/.env` and fill in:

```env
OPENROUTER_API_KEY=sk-or-v1-YOUR_KEY_HERE
OPENROUTER_CHAT_MODEL=mistralai/mistral-7b-instruct:free
OPENROUTER_VISION_MODEL=google/gemma-3-27b-it:free
MOCK_EXTERNAL_SERVICES=false   # ← change this to false
```

---

## Step 3 — Start the Backend

```powershell
cd e:\CliniX\clinix\backend
python -m venv .venv
.\.venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```

The backend will start at `http://localhost:8000`.  
Visit `http://localhost:8000/docs` to see the interactive API docs.

---

## Step 4 — Switch Flutter to Live Mode

In `clinix/.env`:
```env
USE_MOCK_DATA=false
API_BASE_URL=http://localhost:8000
```

Restart the Flutter app — AI features now call the real backend.

---

## Free Models Reference

| Model | Type | Good for |
|---|---|---|
| `mistralai/mistral-7b-instruct:free` | Chat | General health questions |
| `google/gemma-3-12b-it:free` | Chat | Longer context |
| `meta-llama/llama-3.1-8b-instruct:free` | Chat | Fast responses |
| `google/gemma-3-27b-it:free` | Vision+Chat | Medicine label scanning |

Browse all free models at: [https://openrouter.ai/models?q=free](https://openrouter.ai/models?q=free)

---

## How It Works (Architecture)

```
Flutter App
    │  POST /api/v1/ai/chat  (Firebase ID token in header)
    ▼
FastAPI Backend  (backend/app/integrations/openrouter.py)
    │  POST https://openrouter.ai/api/v1/chat/completions
    │  Authorization: Bearer sk-or-v1-...   ← key stays here
    ▼
OpenRouter → AI Model → Response text
    │
    ▼
FastAPI serializes to ChatMessage schema
    │
    ▼
Flutter renders response in chat bubble
```
