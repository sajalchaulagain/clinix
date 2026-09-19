"""Chat services for Upachar Sathi and Baidyek Sathi."""
from datetime import datetime, timezone

from app.core.config import Settings
from app.integrations.openrouter import OpenRouterClient
from app.prompts.baidyek_prompt import BAIDYEK_SYSTEM_PROMPT
from app.prompts.upachar_prompt import UPACHAR_SYSTEM_PROMPT
from app.repositories.base import new_id
from app.schemas.ai import ChatMessage, ChatRequest
from app.services import safety_service

DISCLAIMER = "For anything severe, persistent, or worrying, please consult a qualified healthcare professional."


async def _build_reply(settings: Settings, client: OpenRouterClient,
                       system_prompt: str, request: ChatRequest) -> ChatMessage:
    raw_history = [m for m in request.history if m.sender in ("user", "ai")]
    last_user = next((m for m in reversed(raw_history) if m.sender == "user"), None)
    last_text = (last_user.text if last_user else "")

    # Safety screening runs BEFORE the AI call and short-circuits it.
    if safety_service.detect_self_harm(last_text):
        return ChatMessage(id=new_id(), text=safety_service.self_harm_message(settings),
                           sender="ai", created_at=datetime.now(timezone.utc))
    if safety_service.detect_emergency(last_text):
        return ChatMessage(id=new_id(), text=safety_service.emergency_message(settings),
                           sender="ai", created_at=datetime.now(timezone.utc))

    messages = [{"role": "system", "content": system_prompt}]
    for msg in raw_history[-12:]:  # keep the context window small
        messages.append({"role": "user" if msg.sender == "user" else "assistant",
                          "content": msg.text})
    if not messages[1:]:
        messages.append({"role": "user", "content": "Hello"})
    if request.attachment_base64:
        messages.append(
            {"role": "user",
              "content": f"(The user attached an image named '{raw_history[-1].attachment_name or 'attachment'}'.) "
                          "Describe general, cautious guidance about it."}
        )

    reply = await client.complete_chat(messages, fallback_models=settings.openrouter_chat_fallback_list)
    reply = reply.strip() or "I wasn't able to compose a helpful reply just now. Please try again."
    if DISCLAIMER.lower() not in reply.lower() and "emergency" not in last_text.lower():
        reply = f"{reply}\n\n{DISCLAIMER}"
    return ChatMessage(id=new_id(), text=reply, sender="ai",
                       created_at=datetime.now(timezone.utc))


async def upachar_reply(settings: Settings, request: ChatRequest) -> ChatMessage:
    return await _build_reply(settings, OpenRouterClient(settings),
                              UPACHAR_SYSTEM_PROMPT, request)


async def baidyek_reply(settings: Settings, request: ChatRequest) -> ChatMessage:
    return await _build_reply(settings, OpenRouterClient(settings),
                              BAIDYEK_SYSTEM_PROMPT, request)
