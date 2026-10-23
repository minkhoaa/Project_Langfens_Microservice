"""M3-powered Diagnostic Repair Planning Capability for Langfens Loop Engine."""

from __future__ import annotations

import json
import logging
from typing import Any, Dict, List, Optional, Sequence
from uuid import UUID, uuid4

from app.contracts.issue import Issue, IssueCode
from app.providers.errors import DeadlineExceededError, ProviderError, TimeoutError as ProviderTimeoutError, TruncatedOutputError
from app.providers.gateway import ProviderGateway
from app.providers.models import Capability, ChatMessage, ProviderRequest
from app.providers.parser import parse_defensive_json
from app.repair.base import RepairJustificationError
from app.repair.contracts import (
    RepairAction,
    RepairPlan,
    RepairPlanValidationError,
    validate_repair_plan_compatibility,
)

logger = logging.getLogger(__name__)

M3_REPAIR_PLANNER_SYSTEM_PROMPT = """You are MiniMax-M3, an expert IELTS exam diagnostic reasoning agent in the Langfens Autonomous Engine.
Your task is to analyze why an IELTS Reading question failed semantic, factual, or adversarial evaluation, and produce a strictly typed RepairPlan.

Rules:
1. You are an advisory diagnostic planner, NEVER the authoritative generator or committer.
2. You must choose exactly one repairAction from this versioned enumeration:
   - REPHRASE_STEM: Resolve ambiguous, misleading, or leaking question phrasing.
   - SWAP_DISTRACTOR: Replace an ambiguous or implausible MCQ distractor while preserving verified correct answer.
   - REFINE_CLOZE_TARGET: Refine completion/short-answer targeting within existing word and evidence bounds.
   - CLARIFY_NOT_GIVEN_BOUNDARY: Clarify boundary conditions for TRUE/FALSE/NOT_GIVEN statements.
   - REGENERATE_DISTINCT_CANDIDATE: Address duplicate or semantically overlapping questions while keeping claim binding.
3. You must preserve the authoritative evidence claim reference verbatim in `preserveEvidenceClaimRef`. Do NOT alter, substitute, or rotate the claim.
4. You must provide concrete, unambiguous directives in `repairConstraints` that MiniMax-Text-01 will use to rewrite the question.
5. Output ONLY valid JSON matching this schema:
{
  "issueCode": "<IssueCode>",
  "targetQuestion": <int>,
  "repairAction": "<RepairAction>",
  "diagnosis": "<detailed diagnostic analysis>",
  "repairConstraints": ["<constraint 1>", "<constraint 2>"],
  "preserveEvidenceClaimRef": "<verbatim authoritative claim ref>",
  "expectedCorrection": "<optional model rewrite or target guidance>"
}
"""


class RepairPlanningCapability:
    """Invokes MiniMax-M3 strictly for diagnostic reasoning and surgical repair plan formation."""

    def __init__(self, gateway: ProviderGateway, model_id: str = "MiniMax-M3") -> None:
        self.gateway = gateway
        self.model_id = model_id

    async def plan_repair(
        self,
        question_payload: Dict[str, Any],
        passage_text: str,
        authoritative_claim_ref: str,
        issues: Sequence[Issue],
        run_id: str,
        section_id: str,
        artifact_id: str,
        lease_owner: UUID,
        epoch: int,
        parent_operation_id: Optional[str] = None,
        adversary_feedback: Optional[str] = None,
        previous_attempts: Optional[Sequence[Dict[str, Any]]] = None,
        remaining_tokens: Optional[int] = None,
        timeout_seconds: float = 30.0,
    ) -> RepairPlan:
        """Executes a single, bounded M3 planning invocation and validates the returned RepairPlan."""
        if lease_owner is None:
            raise ValueError("Missing authority lease_owner: fabrication with uuid4 is prohibited")
        if epoch is None or not isinstance(epoch, int) or epoch < 1:
            raise ValueError(f"Invalid authority epoch {epoch}: must be an integer >= 1")

        target_q_num = int(question_payload.get("questionNumber") or question_payload.get("number") or 1)
        primary_issue = issues[0] if issues else Issue(
            code=IssueCode.AMBIGUOUS_ANSWER,
            message="Question failed validation",
        )

        user_content = json.dumps(
            {
                "targetQuestionNumber": target_q_num,
                "currentQuestion": {
                    "questionType": question_payload.get("questionType") or question_payload.get("type"),
                    "prompt": question_payload.get("prompt") or question_payload.get("statement"),
                    "answer": question_payload.get("answer"),
                    "options": question_payload.get("options"),
                    "evidenceQuote": question_payload.get("evidenceQuote"),
                },
                "authoritativeClaimRef": authoritative_claim_ref,
                "detectedIssues": [
                    {
                        "code": getattr(iss.code, "value", str(iss.code)),
                        "message": iss.message,
                        "evidence": iss.evidence,
                    }
                    for iss in issues
                ],
                "adversaryFeedback": adversary_feedback or "",
                "passageExcerpt": (passage_text[:1500] + "...") if len(passage_text) > 1500 else passage_text,
                "previousFailedAttempts": list(previous_attempts or []),
            },
            indent=2,
        )

        if parent_operation_id:
            op_id = f"{parent_operation_id}:m3_plan:q{target_q_num}"
        else:
            op_id = f"op:{run_id}:repair_plan:q{target_q_num}"
        req = ProviderRequest(
            capability=Capability.PLAN_REPAIR,
            messages=[
                ChatMessage(role="system", content=M3_REPAIR_PLANNER_SYSTEM_PROMPT),
                ChatMessage(role="user", content=f"Analyze this failed question and output the diagnostic repair plan JSON:\n\n{user_content}"),
            ],
            operation_id=op_id,
            run_id=run_id,
            section_id=section_id,
            artifact_id=artifact_id,
            parent_operation_id=parent_operation_id,
            preferred_provider="minimax",
            pinned_provider="minimax",
            pinned_model=self.model_id,
            model_size="large",
            temperature=0.1,
            max_tokens=2048,
            timeout_seconds=min(timeout_seconds, 60.0),
            wall_time_reservation_seconds=min(timeout_seconds, 60.0),
            remaining_tokens=remaining_tokens,
            target_model=RepairPlan,
            response_schema=RepairPlan.model_json_schema(),
            allow_repair=True,
        )

        try:
            resp = await self.gateway.execute(req, epoch=epoch, lease_owner=lease_owner)
        except TruncatedOutputError as trunc_err:
            logger.warning("MiniMax-M3 planning truncated (length cutoff): %s", trunc_err)
            raise RepairJustificationError(f"M3 repair planning truncated (output cut off): {trunc_err}") from trunc_err
        except (ProviderTimeoutError, DeadlineExceededError) as timeout_err:
            logger.warning("MiniMax-M3 planning timed out: %s", timeout_err)
            raise RepairJustificationError(f"M3 repair planning provider timed out: {timeout_err}") from timeout_err
        except Exception as prov_err:
            logger.warning("MiniMax-M3 planning failed fail-closed: %s", prov_err)
            raise RepairJustificationError(f"M3 repair planning provider dispatch failed: {prov_err}") from prov_err

        # Extract and validate payload
        try:
            if isinstance(resp.parsed_payload, dict):
                plan = RepairPlan.model_validate(resp.parsed_payload)
            else:
                raw = resp.raw_text or ""
                parsed = parse_defensive_json(raw, target_model=RepairPlan, allow_repair=True)
                plan = RepairPlan.model_validate(parsed)
            validate_repair_plan_compatibility(
                plan,
                authoritative_claim_ref=authoritative_claim_ref,
                target_question=target_q_num,
                eligible_issues=issues,
            )
            return plan
        except RepairPlanValidationError as val_err:
            logger.warning("M3 repair plan violated safety contract: %s", val_err)
            raise RepairJustificationError(f"M3 repair planning rejected by contract validation: {val_err}") from val_err
        except Exception as parse_err:
            logger.warning("M3 repair plan schema validation failed: %s", parse_err)
            raise RepairJustificationError(f"M3 repair planning schema validation failed: {parse_err}") from parse_err
