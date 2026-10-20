"""Admin question autogen router powered by ProviderGateway and Unified Question Validation Engine.

Strictly dispatches via MiniMax allowlist; Groq fallback is disabled.
Validates generated questions against passage and canonical invariants before response.
"""
from __future__ import annotations

import json
import logging
from typing import Any, Dict, List, Optional
from uuid import uuid4

from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, Field

from app.config import settings
from app.providers.gateway import provider_gateway
from app.providers.models import Capability, ChatMessage, ProviderRequest
from app.providers.parser import parse_defensive_json
from app.validation.models import ValidationPolicy, ValidationStatus
from app.validation.pipeline import validate_question

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/v1/autogen", tags=["autogen"])


class AutogenQuestionsRequest(BaseModel):
    type: str = Field(..., description="Canonical question type (e.g. MULTIPLE_CHOICE_SINGLE)")
    passage: str = Field(..., min_length=1, description="Source reading passage / material")
    count: int = Field(default=1, ge=1, le=10, description="Number of questions to generate")
    difficulty: int = Field(default=3, ge=1, le=5, description="Difficulty 1-5")
    skill: str = Field(default="READING", description="Skill name (default: READING)")
    extra_context: Optional[str] = Field(default=None, description="Optional extra instructions or constraints")


class AutogenQuestionsResponse(BaseModel):
    questions: List[Dict[str, Any]] = Field(..., description="List of generated valid question JSON objects")


def _normalize_questions(result: Any) -> Optional[List[Dict[str, Any]]]:
    """Defensively extract a list of question dicts from LLM result."""
    if isinstance(result, list):
        return [q for q in result if isinstance(q, dict)]

    if isinstance(result, dict):
        for key in ("questions", "items", "data", "results", "question"):
            val = result.get(key)
            if isinstance(val, list):
                return [q for q in val if isinstance(q, dict)]
            if isinstance(val, dict) and ("type" in val or "promptMd" in val):
                return [val]

        if "type" in result or "promptMd" in result:
            return [result]

    return None


@router.post("/questions", response_model=AutogenQuestionsResponse)
async def autogen_questions(
    req: AutogenQuestionsRequest,
) -> AutogenQuestionsResponse:
    """Generate IELTS question JSON via ProviderGateway (MiniMax only).

    Enforces:
    1. Strict MiniMax provider dispatch (Groq fallback forbidden).
    2. Finite token and wall time budgets.
    3. Unified Question Validation Engine check with original source passage.
    """
    system_instruction = (
        f"You are a Senior Cambridge IELTS Academic Exam Author. Generate {req.count} original "
        f"{req.type} question(s) for the IELTS {req.skill} test at CEFR difficulty band {req.difficulty}/5.\n\n"
        f"INVARIANTS:\n"
        f"1. Ground all questions, options, headings, and answers strictly in the provided reading passage.\n"
        f"2. Output strictly English only. Vietnamese or non-English text is strictly forbidden.\n"
        f"3. All completion and short-answer keys must be 1, 2, or 3 words maximum copied verbatim from the passage.\n"
        f"4. Provide a full valid canonical answer key for every scored item. Generic placeholders ('Item 1', 'TBD', 'N/A') are forbidden.\n"
        f"5. Output STRICT JSON format only: {{\"questions\": [ ... ]}} with no markdown fences or conversational filler."
    )

    user_prompt = (
        f"Reading Passage:\n\"\"\"\n{req.passage}\n\"\"\"\n\n"
        f"Task: Generate {req.count} {req.type} question(s).\n"
        f"{f'Extra context: {req.extra_context}' if req.extra_context else ''}\n"
        f"Output JSON: {{\"questions\": [...]}}"
    )

    op_id = f"autogen_q_{uuid4().hex[:8]}"
    provider_req = ProviderRequest(
        capability=Capability.GENERATE_JSON,
        messages=[
            ChatMessage(role="system", content=system_instruction),
            ChatMessage(role="user", content=user_prompt),
        ],
        operation_id=op_id,
        run_id=f"run_autogen_{uuid4().hex[:8]}",
        preferred_provider="minimax",
        allowed_providers=["minimax"],
        allow_fallback=False,
        model_size="large",
        temperature=0.3,
        max_tokens=4096,
        timeout_seconds=min(90.0, float(getattr(settings, "loop_operation_wall_reservation_seconds", 60.0))),
        wall_time_reservation_seconds=min(90.0, float(getattr(settings, "loop_operation_wall_reservation_seconds", 60.0))),
    )

    try:
        resp = await provider_gateway.execute(
            request=provider_req,
            epoch=1,
            lease_owner=uuid4(),
        )
    except Exception as exc:
        logger.error("ProviderGateway autogen dispatch failed: %s", exc)
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=f"MiniMax generation transport failed: {exc}",
        ) from exc

    raw_parsed = resp.parsed_payload if resp.parsed_payload is not None else parse_defensive_json(resp.raw_text)
    questions_raw = _normalize_questions(raw_parsed)

    if not questions_raw:
        logger.error("MiniMax output is not a valid questions list: %s", str(resp.raw_text)[:300])
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="LLM output is not a list of questions",
        )

    # Validate all generated questions using Unified Question Validation Engine,
    # strictly passing the source passage and context
    validation_failures: List[Dict[str, Any]] = []
    policy = ValidationPolicy(enforce_grounding=True, enforce_language=True)

    for idx, q in enumerate(questions_raw):
        if not isinstance(q, dict):
            validation_failures.append({"question_index": idx + 1, "issues": ["Question is not a JSON object"]})
            continue

        q.setdefault("type", req.type)
        q.setdefault("skill", req.skill)
        q.setdefault("difficulty", req.difficulty)

        val_result = validate_question(
            question=q,
            passage=req.passage,
            context={"expected_type": req.type, "expected_skill": req.skill, "expected_difficulty": req.difficulty},
            policy=policy,
        )

        if val_result.status == ValidationStatus.INVALID:
            blocking_reasons = [i.message for i in val_result.issues if i.is_blocking]
            validation_failures.append({
                "question_index": idx + 1,
                "issues": blocking_reasons or ["Validation failed"],
            })

    if validation_failures:
        logger.warning("Generated questions failed validation: %s", validation_failures)
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail={
                "message": "Generated questions failed canonical validation checks",
                "validation_errors": validation_failures,
            },
        )

    return AutogenQuestionsResponse(questions=questions_raw)
