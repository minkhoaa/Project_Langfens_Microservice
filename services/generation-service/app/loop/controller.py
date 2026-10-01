"""Pure, fail-closed decision table for a bounded artifact loop."""
from __future__ import annotations

from collections.abc import Sequence
from uuid import uuid4

from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.contracts.loop import DecisionType, LoopDecision, LoopReason, LoopState
from app.loop.context import LoopContext
from app.loop.detectors import OscillationDetector, StagnationDetector
from app.loop.ledger import IssueLedgerManager
from app.loop.policy import LoopPolicy


class LoopController:
    def __init__(self, policy: LoopPolicy):
        self.policy = policy

    def decide(
        self, context: LoopContext, ledger_mgr: IssueLedgerManager,
        latest_evaluations: Sequence[EvaluationResult],
        stagnation_detector: StagnationDetector, oscillation_detector: OscillationDetector,
        dependencies_fresh: bool = True, dependency_stale_reasons: list[str] | None = None,
        repair_attempts_this_version: int = 0, generated_versions: int = 0,
        has_repairer: bool = True,
    ) -> LoopDecision:
        artifact = context.current_artifact
        version = artifact.version if artifact else 0

        def decision(kind: DecisionType, reason: LoopReason, detail: str, next_state: LoopState,
                     expected_version: int = version, evaluation_ref: str | None = None) -> LoopDecision:
            return LoopDecision(
                decisionId=f"dec_{uuid4().hex}", runId=context.run_id, decision=kind,
                currentState=context.cursor.current_state, nextState=next_state,
                reason=f"{reason.value}: {detail}", reasonCode=reason,
                targetScope=context.scope, targetArtifactId=context.target_artifact_id,
                expectedVersion=expected_version, evaluationRef=evaluation_ref,
            )

        def fail(reason: LoopReason, detail: str, aborted: bool = False) -> LoopDecision:
            return decision(DecisionType.FAIL, reason, detail,
                            LoopState.ABORTED if aborted else LoopState.FAILED)

        def next_work(kind: DecisionType, reason: LoopReason, detail: str) -> LoopDecision:
            if version >= self.policy.max_versions or (kind == DecisionType.REGENERATE and
                                                        generated_versions >= self.policy.max_generated_versions):
                return fail(LoopReason.MAX_VERSIONS, f"{detail}; immutable version cap reached")
            tokens = (self.policy.repair_token_reservation if kind == DecisionType.REPAIR
                      else self.policy.generate_token_reservation)
            b = context.budget_tracker
            if b.calls_used + 1 > self.policy.max_total_calls:
                return fail(LoopReason.CALL_CAP, "next operation would exceed call cap")
            if b.tokens_used + tokens > self.policy.max_total_tokens:
                return fail(LoopReason.TOKEN_CAP, "next reservation would exceed token cap")
            if b.get_elapsed_seconds() + self.policy.operation_wall_reservation_seconds > self.policy.max_wall_time_seconds:
                return fail(LoopReason.WALL_TIME_CAP, "next operation would exceed deadline")
            state = LoopState.REPAIRING if kind == DecisionType.REPAIR else LoopState.DRAFTING
            return decision(kind, reason, detail, state, version + 1)

        if context.is_cancelled():
            return fail(LoopReason.CANCELLED, "cancellation observed", aborted=True)
        if not context.check_authority():
            return fail(LoopReason.LEASE_LOST, "local authority revoked", aborted=True)
        if artifact is None:
            return fail(LoopReason.INVALID_OUTPUT, "no exact artifact to decide")
        if context.budget_tracker.get_elapsed_seconds() >= self.policy.max_wall_time_seconds:
            return fail(LoopReason.WALL_TIME_CAP, "deadline exhausted")

        by_id = {ev.evaluator_id: ev for ev in latest_evaluations}
        required = set(self.policy.required_evaluator_ids)
        if not required or required - by_id.keys():
            return fail(LoopReason.MISSING_EVALUATOR, "required evaluations absent")
        if (len(by_id) != len(latest_evaluations) or
            any(ev.status in (EvaluationStatus.ERROR, EvaluationStatus.NOT_APPLICABLE) for ev in latest_evaluations)):
            return fail(LoopReason.EVALUATOR_ERROR, "evaluator error, timeout or incomplete result")
        for ev in latest_evaluations:
            if (ev.target_ref != artifact.to_ref() or
                set(ev.input_dependency_refs) != set(artifact.parent_refs)):
                return fail(LoopReason.STALE_DEPENDENCY, "evaluation does not bind exact target and parents")
        if not dependencies_fresh:
            return next_work(DecisionType.REGENERATE, LoopReason.STALE_DEPENDENCY,
                             "; ".join(dependency_stale_reasons or ["upstream reference changed"]))
        if oscillation_detector.is_oscillating(self.policy.max_oscillation_cycles):
            return fail(LoopReason.OSCILLATION, "repeated artifact/issue cycle")
        if stagnation_detector.is_stagnated(self.policy.max_consecutive_no_progress):
            return fail(LoopReason.NO_PROGRESS, "identical repair output")

        blockers = ledger_mgr.get_unresolved_blockers()
        if any(i.code in self.policy.escalate_codes for i in blockers):
            return decision(DecisionType.ESCALATE, LoopReason.SOURCE_INSUFFICIENT,
                            "source/evidence requires editorial or source review", LoopState.FAILED)
        if blockers:
            if (has_repairer and all(i.code in self.policy.allow_repair_codes for i in blockers) and
                repair_attempts_this_version < self.policy.max_repair_attempts_per_version and
                context.budget_tracker.repairs_used < self.policy.max_total_repairs):
                return next_work(DecisionType.REPAIR, LoopReason.REPAIRABLE_DEFECTS,
                                 f"{len(blockers)} exact-target blockers")
            return next_work(DecisionType.REGENERATE, LoopReason.UNREPAIRABLE_DEFECTS,
                             f"{len(blockers)} unresolved blockers or repair cap")
        if any(ev.status != EvaluationStatus.PASS for ev in latest_evaluations):
            return next_work(DecisionType.REGENERATE, LoopReason.UNREPAIRABLE_DEFECTS,
                             "non-passing evaluation without local repair")
        scores = [ev.score for ev in latest_evaluations if ev.score is not None]
        if scores and min(scores) < self.policy.min_score_threshold:
            return next_work(DecisionType.REGENERATE, LoopReason.UNREPAIRABLE_DEFECTS,
                             "evaluation below minimum score")
        return decision(DecisionType.PASS, LoopReason.ACCEPTED,
                        "all required evaluations PASS on fresh dependencies; no open blockers",
                        LoopState.COMPLETED, evaluation_ref=by_id[self.policy.required_evaluator_ids[0]].evaluation_id)
