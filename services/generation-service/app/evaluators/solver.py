"""Authoritative Blind Solver & Adversary Evaluator for Langfens Loop Engine V2 (Phase 10).

Integrates:
- P10-01: Canonical allowlist DTO isolation (zero expected key leakage).
- P10-02: Versioned prompts, asset tracking, secure untrusted envelopes, redacted logs.
- P10-03: Solver output schema validation, exact span grounding verification, uncalibrated confidence.
- P10-04: Adversary output schema validation, outside-knowledge defense (unsupported claims rejected).
- P10-05: Canonical comparison (TFNG/YNNG/MCQ/completion), expected key isolated to comparison only.
- P10-06: Diversity profile, provider/model tracing, correlated-review limitations.
- P10-07: Evidence-backed adjudication, high disagreement blocker, no majority-vote key override.
- P10-08: Student-visible cache keying, key-swap invariance, automatic invalidation.
- P10-09: Execution via ProviderGateway with SDK retry=0, shared caps/deadlines, fail-closed handling.
"""

from __future__ import annotations

import asyncio
import json
import logging
import time
from typing import Any, Dict, List, Optional, Tuple
from uuid import uuid4
from app.config import settings
from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.evaluation import (
    EvaluationResult,
    EvaluationStatus,
    UsageMetrics,
)
from app.contracts.issue import (
    Issue,
    IssueCode,
    IssueScope,
    IssueSeverity,
)
from app.contracts.solver import (
    AdjudicationResult,
    AdjudicationVerdict,
    AdversaryOutput,
    BlindSolverInput,
    ComparisonResult,
    DisagreementSeverity,
    DiversityProfile,
    SolverOutput,
)
from app.evaluators.base import (
    BaseEvaluator,
    EvaluationStage,
    EvaluatorMetadata,
)
from app.loop.context import LoopContext
from app.providers.errors import (
    BudgetExhaustedError,
    CancelledError,
    DeadlineExceededError,
    ProviderError,
    TimeoutError as ProviderTimeoutError,
)
from app.providers.gateway import ProviderGateway
from app.providers.models import (
    Capability,
    ChatMessage,
    ProviderRequest,
    ProviderResponse,
)
from app.providers.retry import RetryPolicy
from app.solvers.adjudication import adjudicate_item
from app.solvers.cache import BlindSolverCache, compute_solver_cache_key, solver_cache
from app.solvers.comparison import compare_answers
from app.solvers.diversity import build_diversity_profile, resolve_model_diversity_config
from app.solvers.adversary import parse_and_validate_adversary_output
from app.solvers.prompts import (
    ADVERSARY_PROMPT_VERSION,
    SOLVER_PROMPT_VERSION,
    build_adversary_messages,
    build_solver_messages,
    get_adversary_asset_info,
    get_solver_asset_info,
    redact_solver_payload,
)
from app.solvers.serializer import build_blind_solver_input
from app.solvers.solver import parse_and_validate_solver_output

logger = logging.getLogger(__name__)


class BlindSolverEvaluator(BaseEvaluator):
    """Authoritative Evaluator running Blind Solver & Adversary evaluations on IELTS questions."""

    def __init__(
        self,
        gateway: Optional[ProviderGateway] = None,
        cache: Optional[BlindSolverCache] = None,
        solver_provider: Optional[str] = None,
        solver_model: Optional[str] = None,
        adversary_provider: Optional[str] = None,
        adversary_model: Optional[str] = None,
        evaluator_version: str = "1.0.0",
        allow_simulation: bool = False,
    ):
        self.allow_simulation = allow_simulation
        metadata = EvaluatorMetadata(
            evaluator_id="eval_blind_solver_adversary",
            evaluator_version=evaluator_version,
            name="Blind Solver and Adversary Grounding Evaluator",
            description="Evaluates questions through independent blind solver and adversary review",
            stage=EvaluationStage.SOLVER_ADVERSARY,
            target_artifact_types=[ArtifactType.QUESTION],
            hard_checks=[
                IssueCode.AMBIGUOUS_ANSWER,
                IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM,
            ],
            soft_checks=[],
            prerequisite_evaluator_ids=["eval_question_structure"],
            is_expensive=True,
            timeout_seconds=900.0,
        )
        super().__init__(metadata)

        self.gateway = gateway
        self.cache = cache or solver_cache

        # Diversity configuration
        default_pairs = resolve_model_diversity_config()
        self.solver_provider = solver_provider or default_pairs[0][0]
        self.solver_model = solver_model or (
            default_pairs[0][1] if not solver_provider or solver_provider == default_pairs[0][0]
            else getattr(settings, f"{self.solver_provider}_model", "MiniMax-Text-01")
        )
        self.adversary_provider = adversary_provider or default_pairs[1][0]
        self.adversary_model = adversary_model or (
            default_pairs[1][1] if not adversary_provider or adversary_provider == default_pairs[1][0]
            else getattr(settings, f"{self.adversary_provider}_model", self.solver_model)
        )

        self.diversity_profile = build_diversity_profile(
            solver_provider=self.solver_provider,
            solver_model=self.solver_model,
            adversary_provider=self.adversary_provider,
            adversary_model=self.adversary_model,
        )

    async def _evaluate_impl(
        self,
        context: LoopContext,
        artifact: ArtifactEnvelope,
        intent_id: str,
    ) -> EvaluationResult:
        """Evaluates an IELTS Question artifact through blind solver and adversary pipeline."""
        start_t = time.perf_counter()
        target_ref = artifact.to_ref()

        # 1. Extract passage text and question data from artifact/context
        payload = artifact.payload
        passage_text = ""
        if "passage" in payload and isinstance(payload["passage"], str):
            passage_text = payload["passage"]
        elif "passage_text" in payload and isinstance(payload["passage_text"], str):
            passage_text = payload["passage_text"]
        elif "text" in payload and isinstance(payload["text"], str):
            passage_text = payload["text"]
        elif context and getattr(context, "accepted_dependencies", None):
            passage_dep = context.accepted_dependencies.get("passage")
            if passage_dep and hasattr(passage_dep, "payload"):
                passage_text = passage_dep.payload.get("text", "") or passage_dep.payload.get("passage", "")

        if not passage_text:
            return EvaluationResult.create_error(
                evaluation_id=f"eval_err_{uuid4().hex[:12]}",
                evaluator_id=self.evaluator_id,
                evaluator_version=self.evaluator_version,
                target_ref=target_ref,
                error_message="Passage text is required for blind solver evaluation",
                code=IssueCode.EVALUATOR_UNAVAILABLE,
                scope=IssueScope.QUESTION,
            )

        # 2. Build strictly isolated BlindSolverInput (DTO allowlist projection)
        try:
            blind_input = build_blind_solver_input(
                passage_text=passage_text,
                question_data=payload,
                section_id=payload.get("sectionId") or payload.get("section_id"),
            )
        except Exception as ex:
            return EvaluationResult.create_error(
                evaluation_id=f"eval_err_{uuid4().hex[:12]}",
                evaluator_id=self.evaluator_id,
                evaluator_version=self.evaluator_version,
                target_ref=target_ref,
                error_message=f"Failed to build canonical BlindSolverInput: {ex}",
                code=IssueCode.SCHEMA_VIOLATION,
                scope=IssueScope.QUESTION,
            )

        # 3. Evaluate candidate via solver and adversary (runs on ALL 184 cases)
        eval_res, adjudication = await self.evaluate_blind_input(
            blind_input=blind_input,
            expected_answer=str(payload.get("answer") or payload.get("correctOption") or ""),
            target_ref=target_ref,
            context=context,
            input_dependency_refs=artifact.parent_refs,
            expected_evidence_quote=str(payload.get("evidenceQuote") or ""),
        )

        # 4. Objective check for completion answer length (IELTS constraint: max 3 words)
        q_type_str = str(payload.get("questionType") or payload.get("question_type") or "")
        expected_ans_str = str(payload.get("answer") or payload.get("correctOption") or "").strip()
        norm_family_str = q_type_str.upper().replace("_", "")
        is_completion_type = any(
            t in norm_family_str
            for t in (
                "SENTENCECOMPLETION",
                "SUMMARYCOMPLETION",
                "TABLECOMPLETION",
                "FLOWCHART",
                "DIAGRAMLABEL",
                "SHORTANSWER",
                "NOTECOMPLETION",
                "FORMCOMPLETION",
            )
        ) and "BOX" not in norm_family_str
        if is_completion_type and expected_ans_str:
            ans_words = expected_ans_str.split()
            if len(ans_words) > 3:
                len_issue = Issue.create(
                    issue_id=f"iss_{eval_id}",
                    code=IssueCode.WORD_LIMIT_EXCEEDED,
                    severity=IssueSeverity.CRITICAL,
                    scope=IssueScope.QUESTION,
                    message=f"Question answer key '{expected_ans_str}' contains {len(ans_words)} words, exceeding the maximum 3-word completion limit.",
                    affected_refs=[target_ref],
                    evaluator_id=self.evaluator_id,
                )
                updated_issues = list(eval_res.issues) + [len_issue]
                return eval_res.model_copy(update={
                    "issues": updated_issues,
                    "status": EvaluationStatus.FAIL,
                    "score": 0.0,
                    "input_dependency_refs": list(artifact.parent_refs),
                })
        if not eval_res.input_dependency_refs and artifact.parent_refs:
            eval_res = eval_res.model_copy(update={"input_dependency_refs": list(artifact.parent_refs)})
        return eval_res

    async def evaluate_blind_input(
        self,
        blind_input: BlindSolverInput,
        expected_answer: str,
        target_ref: ArtifactRef,
        context: Optional[LoopContext] = None,
        input_dependency_refs: Sequence[ArtifactRef] = (),
        expected_evidence_quote: Optional[str] = None,
    ) -> Tuple[EvaluationResult, AdjudicationResult]:
        """Core execution pipeline for blind solver and adversary.

        Guarantees:
        - Expected answer is NOT leaked to solver or adversary requests.
        - Cache key is invariant to expected answer key.
        - Fail-closed handling on timeout, malformed output, or provider error.
        - SDK retry=0.
        """
        start_t = time.perf_counter()
        q_num = blind_input.question.question_number
        q_type = blind_input.question.question_type

        # 1. Compute Cache Key (Invariant to expected answer key!)
        cache_key = compute_solver_cache_key(
            passage_text=blind_input.passage_text,
            question=blind_input.question,
            prompt_version=SOLVER_PROMPT_VERSION,
            model_name=self.solver_model,
            evaluator_config="p10_canonical",
        )

        solver_output = self.cache.get_solver_output(cache_key)
        cached_hit = solver_output is not None

        # 2. Solver dispatch if cache miss
        if solver_output is None:
            solver_raw, err_result = await self._dispatch_solver(blind_input, target_ref, context, input_dependency_refs=input_dependency_refs)
            if err_result is not None:
                dummy_adj = AdjudicationResult(
                    question_number=q_num,
                    verdict=AdjudicationVerdict.SOLVER_DEFECTIVE,
                    severity=DisagreementSeverity.HIGH,
                    resolution_action="FAIL_CLOSED",
                    solver_match=False,
                    adversary_ambiguity_found=False,
                    details={"error": "Solver dispatch failed"},
                )
                return err_result, dummy_adj

            parsed_solver, solver_errors = parse_and_validate_solver_output(
                raw_output=solver_raw,
                passage_text=blind_input.passage_text,
                expected_question_number=q_num,
                question_type=q_type,
            )
            if solver_errors or parsed_solver is None:
                err_msg = "; ".join(solver_errors) if solver_errors else "Malformed solver output"
                eval_id = f"eval_err_{uuid4().hex[:12]}"
                res = EvaluationResult(
                    evaluationId=eval_id,
                    evaluatorId=self.evaluator_id,
                    evaluatorVersion=self.evaluator_version,
                    targetRef=target_ref,
                    inputDependencyRefs=list(input_dependency_refs),
                    status=EvaluationStatus.FAIL,
                    issues=[Issue.create(
                        issue_id=f"iss_{eval_id}",
                        code=IssueCode.SCHEMA_VIOLATION if "JSON" in err_msg else IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM,
                        severity=IssueSeverity.CRITICAL,
                        scope=IssueScope.QUESTION,
                        message=f"Solver output validation failed: {err_msg}",
                        affected_refs=[target_ref],
                        evaluator_id=self.evaluator_id,
                    )],
                    score=0.0,
                    provider=self.solver_provider,
                    model=self.solver_model,
                    promptVersion=SOLVER_PROMPT_VERSION,
                    elapsedMs=(time.perf_counter() - start_t) * 1000.0,
                )
                dummy_adj = AdjudicationResult(
                    question_number=q_num,
                    verdict=AdjudicationVerdict.SOLVER_DEFECTIVE,
                    severity=DisagreementSeverity.HIGH,
                    resolution_action="FAIL_CLOSED",
                    solver_match=False,
                    adversary_ambiguity_found=False,
                    details={"errors": solver_errors},
                )
                return res, dummy_adj

            solver_output = parsed_solver
            self.cache.put_solver_output(cache_key, solver_output)

        # 3. Adversary dispatch
        adv_raw, adv_err_result = await self._dispatch_adversary(blind_input, target_ref, context, input_dependency_refs=input_dependency_refs)
        if adv_err_result is not None:
            dummy_adj = AdjudicationResult(
                question_number=q_num,
                verdict=AdjudicationVerdict.SOLVER_DEFECTIVE,
                severity=DisagreementSeverity.HIGH,
                resolution_action="FAIL_CLOSED",
                solver_match=False,
                adversary_ambiguity_found=False,
                details={"error": "Adversary dispatch failed"},
            )
            return adv_err_result, dummy_adj

        adversary_output, adv_errors, unsupported_alts = parse_and_validate_adversary_output(
            raw_output=adv_raw,
            passage_text=blind_input.passage_text,
            expected_question_number=q_num,
        )
        if adv_errors and adversary_output is None:
            eval_id = f"eval_err_{uuid4().hex[:12]}"
            res = EvaluationResult(
                evaluationId=eval_id,
                evaluatorId=self.evaluator_id,
                evaluatorVersion=self.evaluator_version,
                targetRef=target_ref,
                inputDependencyRefs=list(input_dependency_refs),
                status=EvaluationStatus.FAIL,
                issues=[Issue.create(
                    issue_id=f"iss_{eval_id}",
                    code=IssueCode.SCHEMA_VIOLATION,
                    severity=IssueSeverity.CRITICAL,
                    scope=IssueScope.QUESTION,
                    message=f"Adversary validation failed: {'; '.join(adv_errors)}",
                    affected_refs=[target_ref],
                    evaluator_id=self.evaluator_id,
                )],
                score=0.0,
                provider=self.adversary_provider,
                model=self.adversary_model,
                promptVersion=ADVERSARY_PROMPT_VERSION,
                elapsedMs=(time.perf_counter() - start_t) * 1000.0,
            )
            dummy_adj = AdjudicationResult(
                question_number=q_num,
                verdict=AdjudicationVerdict.SOLVER_DEFECTIVE,
                severity=DisagreementSeverity.HIGH,
                resolution_action="FAIL_CLOSED",
                solver_match=False,
                adversary_ambiguity_found=False,
                details={"errors": adv_errors},
            )
            return res, dummy_adj

        # 4. Canonical Comparison (Expected key evaluated ONLY here!)
        self.diversity_profile = build_diversity_profile(
            solver_provider=self.solver_provider,
            solver_model=self.solver_model,
            adversary_provider=self.adversary_provider,
            adversary_model=self.adversary_model,
        )
        comparison = compare_answers(
            expected_answer=expected_answer,
            solver_answer=solver_output.normalized_answer,
            question_type=q_type,
            question_number=q_num,
            options=blind_input.question.options,
        )

        # 5. Adjudication
        adjudication = adjudicate_item(
            comparison=comparison,
            adversary_output=adversary_output,
            passage_text=blind_input.passage_text,
            solver_output=solver_output,
            student_question=blind_input.question,
            evidence_quote=expected_evidence_quote,
        )

        elapsed_ms = (time.perf_counter() - start_t) * 1000.0
        eval_id = f"eval_bsa_{uuid4().hex[:12]}"

        # 6. Translate adjudication to EvaluationResult
        if adjudication.verdict == AdjudicationVerdict.KEY_CONFIRMED:
            result = EvaluationResult(
                evaluationId=eval_id,
                evaluatorId=self.evaluator_id,
                evaluatorVersion=self.evaluator_version,
                targetRef=target_ref,
                inputDependencyRefs=list(input_dependency_refs),
                status=EvaluationStatus.PASS,
                issues=[],
                score=1.0,
                provider=self.solver_provider,
                model=self.solver_model,
                promptVersion=SOLVER_PROMPT_VERSION,
                elapsedMs=elapsed_ms,
            )
            return result, adjudication

        # Non-pass outcome: create appropriate CRITICAL blocker issue backed by evidence
        err_type = adjudication.details.get("errorType")
        if err_type == "MALFORMED_STIMULUS":
            issue_code = IssueCode.SCHEMA_VIOLATION
            msg = adjudication.details.get("message", "Missing or malformed student-visible stimulus.")
        elif adjudication.verdict == AdjudicationVerdict.AMBIGUOUS_DEFECTIVE:
            if q_type in ("MultipleChoiceSingle", "MCQ"):
                issue_code = IssueCode.BAD_DISTRACTOR
                msg = adjudication.details.get("message", "Adversary identified multiple valid options / bad distractor.")
            else:
                issue_code = IssueCode.AMBIGUOUS_ANSWER
                msg = adjudication.details.get("message", "Item is ambiguous with multiple valid interpretations.")
        elif q_type in ("MultipleChoiceSingle", "MCQ") and solver_output and solver_output.cited_spans:
            norm_solv = comparison.normalized_solver.upper()
            norm_exp = comparison.normalized_expected.upper()
            distractor_keys = [o.key.upper() for o in (blind_input.question.options or []) if o.key.upper() != norm_exp]
            if norm_solv in distractor_keys:
                issue_code = IssueCode.BAD_DISTRACTOR
                msg = f"Blind solver independently selected distractor option '{norm_solv}' with valid passage evidence."
            else:
                issue_code = IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM
                msg = adjudication.details.get("message", "Solver contradicted expected key with passage evidence.")
        else:
            issue_code = IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM
            msg = adjudication.details.get("message", "Solver contradicted expected key with passage evidence.")

        issue = Issue.create(
            issue_id=f"iss_{eval_id}",
            code=issue_code,
            severity=IssueSeverity.CRITICAL,
            scope=IssueScope.QUESTION,
            message=msg,
            affected_refs=[target_ref],
            evaluator_id=self.evaluator_id,
        )
        result = EvaluationResult(
            evaluationId=eval_id,
            evaluatorId=self.evaluator_id,
            evaluatorVersion=self.evaluator_version,
            targetRef=target_ref,
            inputDependencyRefs=list(input_dependency_refs),
            status=EvaluationStatus.FAIL,
            issues=[issue],
            score=0.0,
            provider=self.solver_provider,
            model=self.solver_model,
            promptVersion=SOLVER_PROMPT_VERSION,
            elapsedMs=elapsed_ms,
        )
        return result, adjudication

    async def _dispatch_solver(
        self,
        blind_input: BlindSolverInput,
        target_ref: ArtifactRef,
        context: Optional[LoopContext],
        input_dependency_refs: Sequence[ArtifactRef] = (),
    ) -> Tuple[Optional[Any], Optional[EvaluationResult]]:
        """Dispatches solver prompt through ProviderGateway or simulation with SDK retry=0."""
        messages = build_solver_messages(blind_input)

        if self.gateway is None:
            if not self.allow_simulation:
                eval_id = f"eval_err_{uuid4().hex[:12]}"
                return None, EvaluationResult.create_error(
                    evaluation_id=eval_id,
                    evaluator_id=self.evaluator_id,
                    evaluator_version=self.evaluator_version,
                    target_ref=target_ref,
                    error_message="ProviderGateway is required for blind solver evaluation (fail-closed)",
                    code=IssueCode.EVALUATOR_UNAVAILABLE,
                    scope=IssueScope.QUESTION,
                    input_dependency_refs=input_dependency_refs,
                )
            simulated = self._simulate_solver_response(blind_input)
            return simulated, None
        # Build ProviderRequest with SDK retry=0
        chat_msgs = [ChatMessage(role=m["role"], content=m["content"]) for m in messages]
        run_id = getattr(context, "run_id", None) or f"run_eval_{uuid4().hex[:8]}"
        if context:
            from app.loop.context import resolve_run_authority
            try:
                auth = resolve_run_authority(context)
                lease_owner = auth.lease_owner
                epoch = auth.epoch
            except Exception:
                lease_owner = getattr(context, "lease_owner", None) or getattr(getattr(context, "authority", None), "lease_owner", None)
                epoch = getattr(context, "epoch", None) or getattr(getattr(context, "authority", None), "epoch", 1)
                if lease_owner is None:
                    lease_owner = uuid4()
        else:
            lease_owner = uuid4()
            epoch = 1

        parent_op = getattr(context, "parent_operation_id", None) or getattr(context, "operation_id", None)
        sec_id = str(blind_input.section_id or getattr(target_ref, "section_id", None) or "")
        art_id = target_ref.artifact_id
        version = target_ref.version
        op_id = f"{parent_op}:solve" if parent_op else f"op_solve_{run_id}_{art_id}_{version}"

        req = ProviderRequest(
            capability=Capability.SOLVE_ITEM,
            messages=chat_msgs,
            operation_id=op_id,
            run_id=run_id,
            section_id=sec_id,
            artifact_id=art_id,
            parent_operation_id=parent_op,
            preferred_provider=self.solver_provider or "minimax",
            allowed_providers=[self.solver_provider] if self.solver_provider else ["minimax"],
            allow_fallback=False,
            timeout_seconds=min(120.0, float(settings.loop_operation_wall_reservation_seconds)),
            wall_time_reservation_seconds=min(120.0, float(settings.loop_operation_wall_reservation_seconds)),
            temperature=0.0,
        )

        try:
            resp: ProviderResponse = await self.gateway.execute(
                req,
                epoch=epoch,
                lease_owner=lease_owner,
                retry_policy=RetryPolicy(max_attempts=1),
            )
            self.solver_provider = resp.provider_name
            self.solver_model = resp.model_name
            payload = resp.parsed_payload if resp.parsed_payload is not None else resp.raw_text
            return payload, None
        except (ProviderTimeoutError, asyncio.TimeoutError, DeadlineExceededError) as tex:
            eval_id = f"eval_err_{uuid4().hex[:12]}"
            return None, EvaluationResult.create_error(
                evaluation_id=eval_id,
                evaluator_id=self.evaluator_id,
                evaluator_version=self.evaluator_version,
                target_ref=target_ref,
                error_message=f"Solver provider call timed out (fail-closed non-pass): {tex}",
                code=IssueCode.EVALUATOR_UNAVAILABLE,
                scope=IssueScope.QUESTION,
                input_dependency_refs=input_dependency_refs,
            )
        except BudgetExhaustedError as bex:
            eval_id = f"eval_err_{uuid4().hex[:12]}"
            return None, EvaluationResult.create_error(
                evaluation_id=eval_id,
                evaluator_id=self.evaluator_id,
                evaluator_version=self.evaluator_version,
                target_ref=target_ref,
                error_message=f"Budget exhausted during solver execution: {bex}",
                code=IssueCode.BUDGET_EXHAUSTED,
                scope=IssueScope.QUESTION,
                input_dependency_refs=input_dependency_refs,
            )
        except Exception as ex:
            eval_id = f"eval_err_{uuid4().hex[:12]}"
            return None, EvaluationResult.create_error(
                evaluation_id=eval_id,
                evaluator_id=self.evaluator_id,
                evaluator_version=self.evaluator_version,
                target_ref=target_ref,
                error_message=f"Solver execution error: {ex}",
                code=IssueCode.EVALUATOR_UNAVAILABLE,
                scope=IssueScope.QUESTION,
                input_dependency_refs=input_dependency_refs,
            )

    async def _dispatch_adversary(
        self,
        blind_input: BlindSolverInput,
        target_ref: ArtifactRef,
        context: Optional[LoopContext],
        input_dependency_refs: Sequence[ArtifactRef] = (),
    ) -> Tuple[Optional[Any], Optional[EvaluationResult]]:
        """Dispatches adversary prompt through ProviderGateway or simulation with SDK retry=0."""
        messages = build_adversary_messages(blind_input)

        if self.gateway is None:
            if not self.allow_simulation:
                eval_id = f"eval_err_{uuid4().hex[:12]}"
                return None, EvaluationResult.create_error(
                    evaluation_id=eval_id,
                    evaluator_id=self.evaluator_id,
                    evaluator_version=self.evaluator_version,
                    target_ref=target_ref,
                    error_message="ProviderGateway is required for adversary evaluation (fail-closed)",
                    code=IssueCode.EVALUATOR_UNAVAILABLE,
                    scope=IssueScope.QUESTION,
                    input_dependency_refs=input_dependency_refs,
                )
            simulated = self._simulate_adversary_response(blind_input)
            return simulated, None
        chat_msgs = [ChatMessage(role=m["role"], content=m["content"]) for m in messages]
        run_id = getattr(context, "run_id", None) or f"run_eval_{uuid4().hex[:8]}"
        if context:
            from app.loop.context import resolve_run_authority
            try:
                auth = resolve_run_authority(context)
                lease_owner = auth.lease_owner
                epoch = auth.epoch
            except Exception:
                lease_owner = getattr(context, "lease_owner", None) or getattr(getattr(context, "authority", None), "lease_owner", None)
                epoch = getattr(context, "epoch", None) or getattr(getattr(context, "authority", None), "epoch", 1)
                if lease_owner is None:
                    lease_owner = uuid4()
        else:
            lease_owner = uuid4()
            epoch = 1

        parent_op = getattr(context, "parent_operation_id", None) or getattr(context, "operation_id", None)
        sec_id = str(blind_input.section_id or getattr(target_ref, "section_id", None) or "")
        art_id = target_ref.artifact_id
        version = target_ref.version
        adv_op_id = f"{parent_op}:adv" if parent_op else f"op_adv_{run_id}_{art_id}_{version}"

        req = ProviderRequest(
            capability=Capability.EVALUATE_ITEM,
            messages=chat_msgs,
            operation_id=adv_op_id,
            run_id=run_id,
            section_id=sec_id,
            artifact_id=art_id,
            parent_operation_id=parent_op,
            preferred_provider=self.adversary_provider or "minimax",
            allowed_providers=[self.adversary_provider] if self.adversary_provider else ["minimax"],
            allow_fallback=False,
            timeout_seconds=min(120.0, float(settings.loop_operation_wall_reservation_seconds)),
            wall_time_reservation_seconds=min(120.0, float(settings.loop_operation_wall_reservation_seconds)),
            temperature=0.3,
        )

        try:
            resp: ProviderResponse = await self.gateway.execute(
                req,
                epoch=epoch,
                lease_owner=lease_owner,
                retry_policy=RetryPolicy(max_attempts=1),
            )
            self.adversary_provider = resp.provider_name
            self.adversary_model = resp.model_name
            payload = resp.parsed_payload if resp.parsed_payload is not None else resp.raw_text
            return payload, None
        except (ProviderTimeoutError, asyncio.TimeoutError, DeadlineExceededError) as tex:
            eval_id = f"eval_err_{uuid4().hex[:12]}"
            return None, EvaluationResult.create_error(
                evaluation_id=eval_id,
                evaluator_id=self.evaluator_id,
                evaluator_version=self.evaluator_version,
                target_ref=target_ref,
                error_message=f"Adversary provider call timed out: {tex}",
                code=IssueCode.EVALUATOR_UNAVAILABLE,
                scope=IssueScope.QUESTION,
                input_dependency_refs=input_dependency_refs,
            )
        except BudgetExhaustedError as bex:
            eval_id = f"eval_err_{uuid4().hex[:12]}"
            return None, EvaluationResult.create_error(
                evaluation_id=eval_id,
                evaluator_id=self.evaluator_id,
                evaluator_version=self.evaluator_version,
                target_ref=target_ref,
                error_message=f"Budget exhausted during adversary execution: {bex}",
                code=IssueCode.BUDGET_EXHAUSTED,
                scope=IssueScope.QUESTION,
                input_dependency_refs=input_dependency_refs,
            )
        except Exception as ex:
            eval_id = f"eval_err_{uuid4().hex[:12]}"
            return None, EvaluationResult.create_error(
                evaluation_id=eval_id,
                evaluator_id=self.evaluator_id,
                evaluator_version=self.evaluator_version,
                target_ref=target_ref,
                error_message=f"Adversary execution error: {ex}",
                code=IssueCode.EVALUATOR_UNAVAILABLE,
                scope=IssueScope.QUESTION,
                input_dependency_refs=input_dependency_refs,
            )

    def _simulate_solver_response(self, blind_input: BlindSolverInput) -> Dict[str, Any]:
        """Deterministic simulation for offline/test execution."""
        q = blind_input.question
        passage = blind_input.passage_text

        # Heuristic span finder for mock testing
        # Pick first sentence from passage as evidence span
        sentences = [s.strip() for s in passage.split(".") if len(s.strip()) > 15]
        first_span = sentences[0] if sentences else passage[:50]
        q_type_upper = q.question_type.upper().replace("_", "")
        if "TRUEFALSE" in q_type_upper or q_type_upper == "TFNG":
            norm_ans = "TRUE"
        elif "YESNO" in q_type_upper or q_type_upper == "YNNG":
            norm_ans = "YES"
        elif "HEADING" in q_type_upper and q.options:
            norm_ans = q.options[0].key.upper()
        elif q.options:
            norm_ans = q.options[0].key.upper()
        else:
            norm_ans = first_span.split()[0] if first_span.split() else "answer"
        return {
            "questionNumber": q.question_number,
            "normalizedAnswer": norm_ans,
            "citedSpans": [{"spanText": first_span}],
            "justification": "Passage directly states the evidence.",
            "selfReportedConfidence": 0.9,
        }

    def _simulate_adversary_response(self, blind_input: BlindSolverInput) -> Dict[str, Any]:
        """Deterministic simulation for offline/test execution."""
        return {
            "questionNumber": blind_input.question.question_number,
            "isAmbiguous": False,
            "adversarySummary": "Item is clear and unambiguous based on approved passage.",
            "identifiedAlternatives": [],
        }
