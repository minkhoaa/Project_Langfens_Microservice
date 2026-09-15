"""Pydantic schemas for /api/v1/autogen/* endpoints."""
from __future__ import annotations

from typing import Optional

from pydantic import BaseModel, Field


class AutogenQuestionsRequest(BaseModel):
    type: str = Field(..., description="QuestionType enum value, e.g. 'MULTIPLE_CHOICE_SINGLE'")
    skill: str = Field(..., description="READING|LISTENING|WRITING|SPEAKING")
    passage: str = Field(..., min_length=1, description="Source passage / material")
    count: int = Field(..., ge=1, le=10, description="Number of questions to generate")
    difficulty: int = Field(..., ge=1, le=5, description="Difficulty 1-5")
    extra_context: Optional[str] = Field(default=None, description="Optional extra context")


class AutogenQuestionsResponse(BaseModel):
    questions: list[dict] = Field(..., description="List of generated question JSON objects")
