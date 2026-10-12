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
            # P15: when the version/generated cap converts a continue-decision into a
            # terminal FAIL, the truthful reason is whichever mechanism actually
            # stopped the loop. If the loop was repeating an identical outcome, the
            # honest attribution is NO_PROGRESS (or OSCILLATION), not MAX_VERSIONS --
            # otherwise diagnostic replay cannot distinguish "engine gave up too early"
            # from "content was genuinely unfixable".
            if version >= self.policy.max_versions or (kind == DecisionType.REGENERATE and
                                                        generated_versions >= self.policy.max_generated_versions):
                if stagnation_detector.consecutive_identical_outcomes > 0:
                    return fail(
                        LoopReason.NO_PROGRESS,
                        f"{detail}; {stagnation_detector.consecutive_identical_outcomes} "
                        f"consecutive attempt(s) produced a semantically identical artifact "
                        f"before the immutable version cap was reached",
                    )
                if oscillation_detector.consecutive_repeats > 0:
                    return fail(
                        LoopReason.OSCILLATION,
                        f"{detail}; {oscillation_detector.consecutive_repeats} repeated "
                        f"artifact/issue cycle(s) before the immutable version cap was reached",
                    )
                return fail(LoopReason.MAX_VERSIONS, f"{detail}; immutable version cap reached")
            tokens = (self.policy.repair_token_reservation if kind == DecisionType.REPAIR
                      else self.policy.generate_token_reservation)
            b = context.budget_tracker
            if not self.policy.is_unlimited and self.policy.max_total_calls > 0 and b.calls_used + 1 > self.policy.max_total_calls:
                return fail(LoopReason.CALL_CAP, "next operation would exceed call cap")
            if not self.policy.is_unlimited and self.policy.max_total_tokens > 0 and b.tokens_used + tokens > self.policy.max_total_tokens:
                return fail(LoopReason.TOKEN_CAP, "next reservation would exceed token cap")
            wall_res = min(self.policy.operation_wall_reservation_seconds, 60.0)
            if not self.policy.is_unlimited and self.policy.max_wall_time_seconds > 0 and b.get_elapsed_seconds() + wall_res > self.policy.max_wall_time_seconds:
                return fail(LoopReason.WALL_TIME_CAP, "next operation would exceed deadline")
            state = LoopState.REPAIRING if kind == DecisionType.REPAIR else LoopState.DRAFTING
            return decision(kind, reason, detail, state, version + 1)

        if context.is_cancelled():
            return fail(LoopReason.CANCELLED, "cancellation observed", aborted=True)
        if not context.check_authority():
            return fail(LoopReason.LEASE_LOST, "local authority revoked", aborted=True)
        if artifact is None:
            return fail(LoopReason.INVALID_OUTPUT, "no exact artifact to decide")
        if not self.policy.is_unlimited and self.policy.max_wall_time_seconds > 0 and context.budget_tracker.get_elapsed_seconds() >= self.policy.max_wall_time_seconds:
            return fail(LoopReason.WALL_TIME_CAP, "deadline exhausted")

        by_id = {ev.evaluator_id: ev for ev in latest_evaluations}
        required = set(self.policy.required_evaluator_ids)
        if not required or required - by_id.keys():
            return fail(LoopReason.MISSING_EVALUATOR, "required evaluations absent")
        if (len(by_id) != len(latest_evaluations) or
            any(ev.status in (EvaluationStatus.ERROR, EvaluationStatus.NOT_APPLICABLE) for ev in latest_evaluations)):
            return fail(LoopReason.EVALUATOR_ERROR, "evaluator error, timeout or incomplete result")
        for ev in latest_evaluations:
            if ev.target_ref != artifact.to_ref() or set(ev.input_dependency_refs) != set(artifact.parent_refs):
                diff = set(ev.input_dependency_refs) ^ set(artifact.parent_refs)
                return fail(LoopReason.STALE_DEPENDENCY, f"evaluation {ev.evaluator_id} does not bind exact target and parents: target_match={ev.target_ref == artifact.to_ref()}, ev_dep_len={len(ev.input_dependency_refs)}, art_parents_len={len(artifact.parent_refs)}, diff_len={len(diff)}")
        if not dependencies_fresh:
            return next_work(DecisionType.REGENERATE, LoopReason.STALE_DEPENDENCY,
                             "; ".join(dependency_stale_reasons or ["upstream reference changed"]))
        if oscillation_detector.is_oscillating(self.policy.max_oscillation_cycles):
            return fail(LoopReason.OSCILLATION, "repeated artifact/issue cycle")
        if stagnation_detector.is_stagnated(self.policy.max_consecutive_no_progress):
            return fail(LoopReason.NO_PROGRESS, "identical repair output")

        blockers = ledger_mgr.get_unresolved_blockers()
        if any(self.policy.escalates(i.code, i.scope) for i in blockers):
            return decision(DecisionType.ESCALATE, LoopReason.SOURCE_INSUFFICIENT,
                            "source/evidence requires editorial or source review", LoopState.FAILED)
        if blockers:
            can_repair = (has_repairer and all(i.code in self.policy.allow_repair_codes for i in blockers) and
                          repair_attempts_this_version < self.policy.max_repair_attempts_per_version and
                          context.budget_tracker.repairs_used < self.policy.max_total_repairs)
            # P15 case-09: `max_versions` is a single immutable-version budget shared
            # by generation AND repair (`max_repair_attempts_per_version=2`), so when a
            # repairer exists the loop spent v1..v3 on one generation plus two repairs
            # and never reached a second generation. Because the blocker set is
            # unchanged, both repairs had demonstrably failed to resolve it, and the
            # campaign recorded the result as if the passage had had only ONE attempt
            # (`MAX_VERSIONS: 1 exact-target blockers`) while the paper loop, whose
            # repairs were refused and fell back to regeneration, had three.
            #
            # The last available version is therefore worth more spent on a FRESH
            # generation than on a third repair of an artifact already shown to be
            # unrepairable by this repairer. This only redirects the final slot: the
            # immutable-version bound, the repair-attempt cap, and no-progress
            # termination are all unchanged, and no cap is raised.
            #
            # The redirect is deliberately skipped once the detectors are already
            # reporting repeats: at that point the truthful terminal reason is
            # NO_PROGRESS/OSCILLATION, and swapping in a fresh generation would mask
            # that attribution behind MAX_VERSIONS.
            repeat_signal = (stagnation_detector.consecutive_identical_outcomes > 0 or
                             oscillation_detector.consecutive_repeats > 0)
            final_slot = version + 1 >= self.policy.max_versions
            if (can_repair and final_slot and not repeat_signal and
                    generated_versions < self.policy.max_generated_versions):
                return next_work(DecisionType.REGENERATE, LoopReason.REPAIRABLE_DEFECTS,
                                 f"{len(blockers)} exact-target blockers; final version slot "
                                 f"redirected from repair to regeneration because repair "
                                 f"has not resolved the blocker set")
            if can_repair:
                return next_work(DecisionType.REPAIR, LoopReason.REPAIRABLE_DEFECTS,
                                 f"{len(blockers)} exact-target blockers")
            return next_work(DecisionType.REGENERATE, LoopReason.UNREPAIRABLE_DEFECTS,
                             f"{len(blockers)} unresolved blockers or repair cap")
        if any(ev.status != EvaluationStatus.PASS for ev in latest_evaluations):
            return next_work(DecisionType.REGENERATE, LoopReason.UNREPAIRABLE_DEFECTS,
                             "non-passing evaluation without local repair")
        required_scores = [ev.score for ev in latest_evaluations if ev.score is not None and ev.evaluator_id in required]
        if required_scores and min(required_scores) < self.policy.min_score_threshold:
            return next_work(DecisionType.REGENERATE, LoopReason.UNREPAIRABLE_DEFECTS,
                             "evaluation below minimum score")
        return decision(DecisionType.PASS, LoopReason.ACCEPTED,
                        "all required evaluations PASS on fresh dependencies; no open blockers",
                        LoopState.COMPLETED, evaluation_ref=by_id[self.policy.required_evaluator_ids[0]].evaluation_id)
