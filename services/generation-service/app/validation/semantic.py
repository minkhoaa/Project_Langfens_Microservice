"""Layer 3: Targeted MiniMax semantic verification via ProviderGateway.

Enforces:
- Strict MiniMax provider policy (zero Groq fallback).
- Explicit finite budgets and durable accounting.
- Independent verification (never self-assessment alone).
- Fail-closed to NEEDS_REVIEW when ambiguity remains.
"""
from __future__ import annotations

import hashlib
import json
import logging
from typing import Any, Dict, List, Optional
from uuid import UUID, uuid4

from app.config import settings
from app.providers.gateway import ProviderGateway
from app.providers.models import Capability, ChatMessage, ProviderRequest
from app.providers.parser import parse_defensive_json
from app.validation.models import (
    IssueCode,
    Repairability,
    ValidationIssue,
    ValidationPolicy,
    ValidationResult,
    ValidationSeverity,
    ValidationStatus,
)

logger = logging.getLogger(__name__)

SEMANTIC_VERIFICATION_PROMPT = """You are an independent Senior Cambridge IELTS Academic Reading Examiner.
Verify whether the proposed answer key for the IELTS question below is factually, logically, and unambiguously supported by the reading passage.

RULES:
1. Base your evaluation EXCLUSIVELY on the provided passage. Do not use outside knowledge.
2. For TRUE_FALSE_NOT_GIVEN:
   - TRUE: Directly entailed by the passage.
   - FALSE: Factually contradicted by the passage.
   - NOT GIVEN: The passage neither confirms nor contradicts the statement.
3. For COMPLETION / SHORT ANSWER:
   - The answer must be exact or an exact paraphrase of words in the text.
4. Output STRICT JSON only:
{
  "is_supported": true/false,
  "verdict": "SUPPORTED" | "CONTRADICTED" | "UNVERIFIABLE" | "AMBIGUOUS",
  "confidence": 0.0 to 1.0,
  "evidence_quote": "exact quote from passage",
  "explanation": "brief reason in English"
}"""


async def verify_semantics_with_minimax(
    question: Dict[str, Any],
    passage: str,
    result: ValidationResult,
    policy: ValidationPolicy,
    gateway: ProviderGateway,
    context: Optional[Dict[str, Any]] = None,
) -> ValidationResult:
    """Perform targeted MiniMax semantic verification for unresolved or disputed questions."""
    ctx = context or {}
    run_id = ctx.get("run_id") or f"val_{uuid4().hex[:12]}"
    operation_id = f"op_val_sem_{uuid4().hex[:8]}"
    lease_owner = ctx.get("lease_owner")
    if lease_owner is None:
        lease_owner = uuid4()
    elif isinstance(lease_owner, str):
        try:
            lease_owner = UUID(lease_owner)
        except ValueError:
            lease_owner = uuid4()

    q_type = question.get("type", "UNKNOWN")
    prompt_md = question.get("promptMd", "")
    explanation_md = question.get("explanationMd", "")

    user_payload = {
        "questionType": q_type,
        "prompt": prompt_md,
        "explanation": explanation_md,
        "passage": passage[:10_000],  # Bounded passage window
    }

    if "options" in question:
        user_payload["options"] = question["options"]
    if "blankAcceptTexts" in question:
        user_payload["blankAcceptTexts"] = question["blankAcceptTexts"]
    if "matchPairs" in question:
        user_payload["matchPairs"] = question["matchPairs"]
    if "shortAnswerAcceptTexts" in question:
        user_payload["shortAnswerAcceptTexts"] = question["shortAnswerAcceptTexts"]
    if "orderCorrects" in question:
        user_payload["orderCorrects"] = question["orderCorrects"]

    user_content = json.dumps(user_payload, ensure_ascii=False)
    messages = [
        ChatMessage(role="system", content=SEMANTIC_VERIFICATION_PROMPT),
        ChatMessage(role="user", content=user_content),
    ]

    prompt_hash = hashlib.sha256(f"{SEMANTIC_VERIFICATION_PROMPT}:{user_content}".encode("utf-8")).hexdigest()

    req = ProviderRequest(
        run_id=run_id,
        operation_id=operation_id,
        messages=messages,
        capability=Capability.GENERATE_JSON,
        preferred_provider="minimax",  # STRICT: MiniMax only, no Groq fallback
        model_size="large",
        temperature=0.0,
        max_tokens=policy.max_word_limit * 100 + 300,
        prompt_hash=prompt_hash,
        timeout_seconds=min(60.0, float(getattr(settings, "loop_operation_wall_reservation_seconds", 60.0))),
        wall_time_reservation_seconds=min(60.0, float(getattr(settings, "loop_operation_wall_reservation_seconds", 60.0))),
    )

    try:
        resp = await gateway.execute(
            request=req,
            epoch=ctx.get("epoch", 1),
            lease_owner=lease_owner,
        )
    except Exception as exc:
        logger.warning("ProviderGateway MiniMax execution failed during semantic validation: %s", exc)
        return result.model_copy(
            update={
                "status": ValidationStatus.NEEDS_REVIEW,
                "reasons": result.reasons + [f"MiniMax semantic check failed: {exc}"],
            }
        )

    tokens_used = resp.usage.total_tokens if resp.usage else 0
    raw_text = getattr(resp, "raw_text", None) or getattr(resp, "text", "") or ""
    parsed = parse_defensive_json(raw_text)

    receipt = {
        "provider": "minimax",
        "model": getattr(resp, "model_name", None) or getattr(resp, "model", "abab6.5s-chat"),
        "operation_id": operation_id,
        "tokens_consumed": tokens_used,
        "prompt_tokens": resp.usage.prompt_tokens if resp.usage else 0,
        "completion_tokens": resp.usage.completion_tokens if resp.usage else 0,
    }

    if not isinstance(parsed, dict) or "verdict" not in parsed:
        return result.model_copy(
            update={
                "status": ValidationStatus.NEEDS_REVIEW,
                "tokens_consumed": result.tokens_consumed + tokens_used,
                "cost_receipt": receipt,
                "reasons": result.reasons + ["MiniMax returned non-JSON or missing verdict"],
            }
        )

    verdict = str(parsed.get("verdict", "")).upper()
    is_supp = bool(parsed.get("is_supported", False))
    quote = str(parsed.get("evidence_quote", "")).strip()
    explanation = str(parsed.get("explanation", "")).strip()

    new_issues = list(result.issues)
    evidence_summary = dict(result.evidence_summary)
    evidence_summary["minimax_verdict"] = verdict
    evidence_summary["minimax_evidence_quote"] = quote
    evidence_summary["minimax_explanation"] = explanation

    if verdict == "SUPPORTED" and is_supp:
        # Verified valid by MiniMax
        status = result.status  # Keep existing valid status
    elif verdict in ("CONTRADICTED", "UNVERIFIABLE"):
        new_issues.append(
            ValidationIssue(
                code=IssueCode.ERR_CONTRADICTED_ANSWER if verdict == "CONTRADICTED" else IssueCode.ERR_UNGROUNDED_ANSWER,
                message=f"MiniMax semantic check: answer is {verdict.lower()}. {explanation}",
                severity=ValidationSeverity.ERROR,
                is_blocking=True,
                evidence_ref=quote or None,
                repairability=Repairability.REPAIRABLE_MANUAL,
            )
        )
        status = ValidationStatus.INVALID
    else:
        # Ambiguous or inconclusive
        new_issues.append(
            ValidationIssue(
                code=IssueCode.ERR_AMBIGUOUS_ANSWER,
                message=f"MiniMax semantic check: answer is ambiguous. {explanation}",
                severity=ValidationSeverity.WARNING,
                is_blocking=False,
                evidence_ref=quote or None,
                repairability=Repairability.REPAIRABLE_MANUAL,
            )
        )
        status = ValidationStatus.NEEDS_REVIEW

    return ValidationResult(
        status=status,
        question_type=result.question_type,
        schema_version=result.schema_version,
        issues=new_issues,
        scored_items=result.scored_items,
        is_repairable=result.is_repairable,
        reasons=[i.message for i in new_issues if i.is_blocking],
        evidence_summary=evidence_summary,
        tokens_consumed=result.tokens_consumed + tokens_used,
        cost_receipt=receipt,
    )
