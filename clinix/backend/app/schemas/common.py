"""Shared schema helpers."""
from pydantic import BaseModel


class MessageOut(BaseModel):
    detail: str


class IdOut(BaseModel):
    id: str
