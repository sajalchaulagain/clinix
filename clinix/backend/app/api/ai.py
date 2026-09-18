"""AI assistant routes — /ai/chat (Upachar Sathi) and /ayurvedic/chat
(Baidyek Sathi). Both return a single AI ChatMessage."""
from fastapi import APIRouter, Depends, Request

from app.api.limiter import limiter
from app.core.config import Settings, get_settings
from app.core.security import CurrentUser, get_current_user
from app.schemas.ai import AyurvedicChatRequest, ChatMessage, ChatRequest
from app.services import ai_chat_service

router = APIRouter(tags=["ai"])


@router.post("/ai/chat", response_model=ChatMessage)
@limiter.limit("20/minute")
async def upachar_chat(request: Request, payload: ChatRequest,
                       settings: Settings = Depends(get_settings),
                       user: CurrentUser = Depends(get_current_user)) -> ChatMessage:
    _ = user
    return await ai_chat_service.upachar_reply(settings, payload)


@router.post("/ayurvedic/chat", response_model=ChatMessage)
@limiter.limit("20/minute")
async def baidyek_chat(request: Request, payload: AyurvedicChatRequest,
                       settings: Settings = Depends(get_settings),
                       user: CurrentUser = Depends(get_current_user)) -> ChatMessage:
    _ = user
    return await ai_chat_service.baidyek_reply(settings, payload)
