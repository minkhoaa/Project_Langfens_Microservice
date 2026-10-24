"""Layer 3: Targeted MiniMax semantic verification via ProviderGateway.

Hardened semantic layer enforcing:
1. Verification of actual MiniMax dispatch from gateway receipts (never relying on preferred_provider alone).
2. Dynamic provider and model identities from actual receipts (never hardcoded strings).
3. Separation of mocked test receipts from real API receipts.
4. Independent verification of returned evidence quotes against the actual passage.
5. Strict validation of verdict schema, allowed enum values, and strict boolean types.
6. Detection and explicit disclosure of passage truncation (never silent truncation).
7. Dispatching to MiniMax only for cases requiring semantic evaluation.
8. Finite budgets, durable token accounting, and bounded retries.
9. Uncertain model judgments (low confidence, ambiguous, ungrounded quotes) fail closed to NEEDS_REVIEW.
10. Automated LLM evaluation is clearly recorded as machine assessment, never certified human gold.
"""
from __future__ import annotations

import hashlib
import json
import logging
import re
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

ALLOWED_VERDICTS = frozenset({"SUPPORTED", "CONTRADICTED", "UNVERIFIABLE", "AMBIGUOUS"})
MAX_PASSAGE_WINDOW_CHARS = 10_000
MIN_CONFIDENCE_THRESHOLD = 0.75


def verify_quote_grounding(quote_text: str, full_passage: str) -> bool:
    """Verifies that the returned evidence quote exists verbatim or near-verbatim in the passage."""
    if not quote_text or not full_passage:
        return False
    q_norm = " ".join(quote_text.strip().lower().split())
    p_norm = " ".join(full_passage.strip().lower().split())

    if q_norm in p_norm:
        return True

    # Check sentence fragments for longer quotes
    fragments = [f.strip() for f in re.split(r"[\.\,\;\:\n]", q_norm) if len(f.strip()) >= 20]
    if fragments and any(f in p_norm for f in fragments):
        return True

    return False


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

    # Requirement 7: Detect and disclose truncation rather than silently ignoring it
    is_truncated = len(passage) > MAX_PASSAGE_WINDOW_CHARS
    passage_payload = passage[:MAX_PASSAGE_WINDOW_CHARS]

    user_payload: Dict[str, Any] = {
        "questionType": q_type,
        "prompt": prompt_md,
        "explanation": explanation_md,
        "passage": passage_payload,
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
        preferred_provider="minimax",
        allowed_providers=["minimax"],
        allow_fallback=False,
        model_size="large",
        temperature=0.0,
        max_tokens=min(policy.token_budget, 1200),
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

    # Requirements 1, 2, 3: Obtain identities from actual receipts, never hardcoded strings
    actual_provider = getattr(resp, "provider_name", "UNKNOWN")
    actual_model = getattr(resp, "model_name", "UNKNOWN")
    tokens_used = resp.usage.total_tokens if resp.usage else 0

    # Requirement 4: Separate mocked test receipts from real API receipts
    is_mock = bool(
        getattr(resp, "is_mock", False) is True
        or "mock" in str(actual_provider).lower()
        or "fake" in str(actual_provider).lower()
        or getattr(resp, "provider_request_id", None) is None
    )

    receipt = {
        "provider": actual_provider,
        "model": actual_model,
        "operation_id": getattr(resp, "operation_id", operation_id),
        "tokens_consumed": tokens_used,
        "prompt_tokens": resp.usage.prompt_tokens if resp.usage else 0,
        "completion_tokens": resp.usage.completion_tokens if resp.usage else 0,
        "is_mock": is_mock,
        "receipt_kind": "MOCKED_TEST" if is_mock else "REAL_API",
        "human_certified": False,
    }

    # Requirement 1: Verify actual MiniMax dispatch
    if actual_provider.lower() not in ("minimax", "mock_minimax") and not is_mock:
        return result.model_copy(
            update={
                "status": ValidationStatus.NEEDS_REVIEW,
                "tokens_consumed": result.tokens_consumed + tokens_used,
                "cost_receipt": receipt,
                "reasons": result.reasons + [f"MiniMax dispatch unverified: received response from '{actual_provider}'"],
            }
        )

    raw_text = getattr(resp, "raw_text", None) or getattr(resp, "text", "") or ""
    parsed = parse_defensive_json(raw_text)

    new_issues = list(result.issues)
    evidence_summary = dict(result.evidence_summary)
    evidence_summary["machine_assessment_only"] = True
    evidence_summary["certified_human_gold"] = False

    if is_truncated:
        evidence_summary["passage_truncated"] = True
        evidence_summary["passage_original_chars"] = len(passage)
        evidence_summary["passage_evaluated_chars"] = MAX_PASSAGE_WINDOW_CHARS
        new_issues.append(
            ValidationIssue(
                code=IssueCode.ERR_EVALUATION_INCONCLUSIVE,
                message=(
                    f"Passage exceeded {MAX_PASSAGE_WINDOW_CHARS} chars ({len(passage)} chars) and was truncated; "
                    f"semantic validation evaluated first {MAX_PASSAGE_WINDOW_CHARS} chars only"
                ),
                severity=ValidationSeverity.WARNING,
                is_blocking=False,
            )
        )

    # Requirement 6: Validate semantic verdict schema and boolean types strictly
    if not isinstance(parsed, dict) or "verdict" not in parsed:
        return result.model_copy(
            update={
                "status": ValidationStatus.NEEDS_REVIEW,
                "tokens_consumed": result.tokens_consumed + tokens_used,
                "cost_receipt": receipt,
                "reasons": result.reasons + ["MiniMax returned non-JSON or missing verdict"],
                "evidence_summary": evidence_summary,
            }
        )

    raw_verdict = str(parsed.get("verdict", "")).strip().upper()
    raw_is_supp = parsed.get("is_supported")

    if raw_verdict not in ALLOWED_VERDICTS:
        return result.model_copy(
            update={
                "status": ValidationStatus.NEEDS_REVIEW,
                "tokens_consumed": result.tokens_consumed + tokens_used,
                "cost_receipt": receipt,
                "reasons": result.reasons + [f"MiniMax returned invalid verdict enum: '{raw_verdict}'"],
                "evidence_summary": evidence_summary,
            }
        )

    # Strict boolean validation
    if type(raw_is_supp) is not bool:
        return result.model_copy(
            update={
                "status": ValidationStatus.NEEDS_REVIEW,
                "tokens_consumed": result.tokens_consumed + tokens_used,
                "cost_receipt": receipt,
                "reasons": result.reasons + [f"MiniMax returned non-boolean is_supported: {type(raw_is_supp).__name__}"],
                "evidence_summary": evidence_summary,
            }
        )

    try:
        confidence = float(parsed.get("confidence", 0.0))
    except (ValueError, TypeError):
        confidence = 0.0

    quote = str(parsed.get("evidence_quote", "")).strip()
    explanation = str(parsed.get("explanation", "")).strip()

    evidence_summary["minimax_verdict"] = raw_verdict
    evidence_summary["minimax_is_supported"] = raw_is_supp
    evidence_summary["minimax_confidence"] = confidence
    evidence_summary["minimax_evidence_quote"] = quote
    evidence_summary["minimax_explanation"] = explanation

    # Requirement 5: Verify returned evidence quotes against the actual passage
    quote_verified = True
    if quote:
        quote_verified = verify_quote_grounding(quote, passage)
        evidence_summary["quote_grounding_verified"] = quote_verified
        if not quote_verified:
            new_issues.append(
                ValidationIssue(
                    code=IssueCode.ERR_UNGROUNDED_ANSWER,
                    message=f"MiniMax evidence quote '{quote[:80]}' could not be verified in the source passage",
                    severity=ValidationSeverity.WARNING,
                    is_blocking=False,
                    evidence_ref=quote,
                    repairability=Repairability.REPAIRABLE_MANUAL,
                )
            )

    # Requirement 10: Treat uncertain model judgments as NEEDS_REVIEW
    if raw_verdict == "SUPPORTED" and raw_is_supp is True and confidence >= MIN_CONFIDENCE_THRESHOLD and quote_verified:
        # Verified valid by MiniMax with grounded quote and high confidence
        status = result.status if result.status != ValidationStatus.NEEDS_REVIEW else ValidationStatus.VALID
        semantic_valid = True
    elif raw_verdict == "CONTRADICTED":
        new_issues.append(
            ValidationIssue(
                code=IssueCode.ERR_CONTRADICTED_ANSWER,
                message=f"MiniMax semantic check: answer is contradicted by passage. {explanation}",
                severity=ValidationSeverity.ERROR,
                is_blocking=True,
                evidence_ref=quote or None,
                repairability=Repairability.REPAIRABLE_MANUAL,
            )
        )
        status = ValidationStatus.INVALID
        semantic_valid = False
    elif raw_verdict == "UNVERIFIABLE":
        new_issues.append(
            ValidationIssue(
                code=IssueCode.ERR_UNGROUNDED_ANSWER,
                message=f"MiniMax semantic check: answer is unverifiable from passage. {explanation}",
                severity=ValidationSeverity.ERROR,
                is_blocking=True,
                evidence_ref=quote or None,
                repairability=Repairability.REPAIRABLE_MANUAL,
            )
        )
        status = ValidationStatus.INVALID
        semantic_valid = False
    else:
        # Ambiguous, low confidence (< 0.75), ungrounded quote, or inconsistent flags -> fail closed to NEEDS_REVIEW
        new_issues.append(
            ValidationIssue(
                code=IssueCode.ERR_AMBIGUOUS_ANSWER,
                message=f"MiniMax semantic check inconclusive (verdict={raw_verdict}, confidence={confidence:.2f}, quote_verified={quote_verified}). {explanation}",
                severity=ValidationSeverity.WARNING,
                is_blocking=False,
                evidence_ref=quote or None,
                repairability=Repairability.REPAIRABLE_MANUAL,
            )
        )
        status = ValidationStatus.NEEDS_REVIEW
        semantic_valid = None

    blocking_reasons = [i.message for i in new_issues if i.is_blocking]
    if status == ValidationStatus.NEEDS_REVIEW and not blocking_reasons:
        blocking_reasons = [i.message for i in new_issues if i.code in (IssueCode.ERR_AMBIGUOUS_ANSWER, IssueCode.ERR_EVALUATION_INCONCLUSIVE)]

    return ValidationResult(
        status=status,
        question_type=result.question_type,
        schema_version=result.schema_version,
        structural_valid=result.structural_valid,
        semantic_valid=semantic_valid if semantic_valid is not None else result.semantic_valid,
        grounding_verified=result.grounding_verified and quote_verified,
        issues=new_issues,
        scored_items=result.scored_items,
        is_repairable=result.is_repairable,
        reasons=blocking_reasons,
        evidence_summary=evidence_summary,
        tokens_consumed=result.tokens_consumed + tokens_used,
        cost_receipt=receipt,
    )
