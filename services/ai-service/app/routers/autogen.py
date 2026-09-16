"""Auto-gen router — server-side proxy for LLM-driven question generation.

Forwards requests to Groq via groq_service.groq_generate. Resolves JSON
shape server-side to prevent FE from sending malformed shapes.
"""
from __future__ import annotations

import logging
from typing import Any

from fastapi import APIRouter, Depends, HTTPException, status

from app.prompts.autogen import build_system_prompt, build_user_prompt
from app.prompts.autogen_data import get_constraints, get_json_shape
from app.schemas.autogen import AutogenQuestionsRequest, AutogenQuestionsResponse
from app.services.groq_service import groq_generate

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/v1/autogen", tags=["autogen"])


@router.post("/questions", response_model=AutogenQuestionsResponse)
async def autogen_questions(
    req: AutogenQuestionsRequest,
    # user: dict = Depends(get_current_user),  # TODO: wire JWT auth in Phase 5 follow-up
) -> AutogenQuestionsResponse:
    """Generate IELTS question JSON via LLM (Groq server-side).

    Args:
        req: Request body with type, skill, passage, count, difficulty, optional extra.

    Returns:
        Response with list of generated question JSON objects.

    Raises:
        HTTPException 400 if question type is unknown.
        HTTPException 502 if LLM output is not a valid list.
    """
    try:
        json_shape = get_json_shape(req.type)
        constraints = get_constraints(req.type)
    except KeyError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Unknown question type: {req.type}",
        ) from exc

    system_prompt = build_system_prompt(req.type, json_shape, constraints)
    user_prompt = build_user_prompt(
        req.type, req.passage, req.count, req.difficulty, req.extra_context or ""
    )

    result: dict[str, Any] = await groq_generate(
        prompt_template="{system}\n\n{user}",
        variables={"system": system_prompt, "user": user_prompt},
        expect_json=True,
        temperature=0.3,
        max_tokens=4096,
    )

    questions_raw = result.get("questions")
    if not isinstance(questions_raw, list):
        logger.error("LLM output not a list: %s", type(questions_raw))
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="LLM output is not a list of questions",
        )

    return AutogenQuestionsResponse(questions=questions_raw)
