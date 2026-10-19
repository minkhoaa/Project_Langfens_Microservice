"""Unified validation entry point for all 19 IELTS question types."""
from __future__ import annotations

import logging
from typing import Any, Dict, List, Optional

from app.validation.models import (
    ValidationPolicy,
    ValidationResult,
    ValidationStatus,
)
from app.validation.registry import get_validator_registry

logger = logging.getLogger(__name__)


def validate_question(
    question: Any,
    passage: Optional[str] = None,
    context: Optional[Dict[str, Any]] = None,
    policy: Optional[ValidationPolicy] = None,
) -> ValidationResult:
    """Unified deterministic validation entry point for a single IELTS question.

    Args:
        question: Parsed question dictionary.
        passage: Optional source reading passage for grounding checks.
        context: Optional section/exam metadata context.
        policy: Validation configuration policy.

    Returns:
        ValidationResult with status VALID, INVALID, or NEEDS_REVIEW.
    """
    registry = get_validator_registry()
    return registry.validate_question(
        question=question,
        passage=passage,
        context=context,
        policy=policy,
    )


async def validate_question_async(
    question: Any,
    passage: Optional[str] = None,
    context: Optional[Dict[str, Any]] = None,
    policy: Optional[ValidationPolicy] = None,
    gateway: Optional[Any] = None,
) -> ValidationResult:
    """Unified validation entry point supporting layered evaluation.

    Layers:
    1. Deterministic rules (structure, answer keys, English language, options, markers).
    2. Deterministic passage grounding and consistency checks.
    3. Targeted MiniMax semantic verification only where deterministic checks are inconclusive
       and policy.allow_llm_eval is True.
    4. Flagging unresolved ambiguity as NEEDS_REVIEW.
    """
    pol = policy or ValidationPolicy()

    # Layer 1 & 2: Deterministic validation
    result = validate_question(question=question, passage=passage, context=context, policy=pol)

    # If already INVALID on hard structural / schema / language defect, never do LLM calls
    if result.status == ValidationStatus.INVALID:
        return result

    # Layer 3: Targeted semantic check if requested and gateway available
    if pol.allow_llm_eval and gateway is not None and passage:
        try:
            from app.validation.semantic import verify_semantics_with_minimax
            semantic_result = await verify_semantics_with_minimax(
                question=question,
                passage=passage,
                result=result,
                policy=pol,
                gateway=gateway,
                context=context,
            )
            return semantic_result
        except Exception as exc:
            logger.warning("Targeted semantic evaluation failed: %s", exc)
            # Fail closed to NEEDS_REVIEW when semantic check fails unexpectedly
            return result.model_copy(
                update={
                    "status": ValidationStatus.NEEDS_REVIEW,
                    "reasons": result.reasons + [f"Semantic evaluation inconclusive: {exc}"],
                }
            )

    return result


def validate_question_batch(
    questions: List[Any],
    passage: Optional[str] = None,
    context: Optional[Dict[str, Any]] = None,
    policy: Optional[ValidationPolicy] = None,
) -> List[ValidationResult]:
    """Validate a batch of questions deterministically."""
    pol = policy or ValidationPolicy()
    return [
        validate_question(question=q, passage=passage, context=context, policy=pol)
        for q in questions
    ]
