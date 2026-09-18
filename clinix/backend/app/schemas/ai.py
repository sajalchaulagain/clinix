"""Chat schemas — mirror Flutter ChatMessageModel
(lib/shared/models/chat_message_model.dart). Enum literals match Dart `.name`
values exactly."""
from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field

ChatSender = Literal["user", "ai", "system"]
ChatStatus = Literal["sending", "sent", "error"]


class ChatMessage(BaseModel):
    id: str = ""
    text: str
    sender: ChatSender
    created_at: datetime
    status: ChatStatus = "sent"
    attachment_name: str | None = None
    is_disclaimer: bool = False


class ChatRequest(BaseModel):
    # `history` carries the conversation so far (the Flutter ChatController's
    # state). The optional attachment is base64-encoded image bytes.
    history: list[ChatMessage] = Field(default_factory=list)
    attachment_base64: str | None = Field(default=None, max_length=12_000_000)


class AyurvedicChatRequest(ChatRequest):
    pass
