"""Pure, fail-closed decision table for a bounded artifact loop."""
from __future__ import annotations

from collections.abc import Sequence
from enum import Enum
from typing import Optional
from uuid import uuid4

from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.contracts.issue import Issue, IssueCode, IssueScope, IssueSeverity
from app.contracts.loop import DecisionType, LoopDecision, LoopReason, LoopState
from app.loop.context import LoopContext
from app.loop.detectors import OscillationDetector, StagnationDetector
from app.loop.ledger import IssueLedgerManager
from app.loop.policy import LoopPolicy


class EscalationLadder(str, Enum):
    """Escalation steps for autonomous defect recovery."""
    ITEM_REPAIR = "ITEM_REPAIR"
    ITEM_RESELECT = "ITEM_RESELECT"
    GROUP_REPAIR = "GROUP_REPAIR"
    PASSAGE_REPAIR = "PASSAGE_REPAIR"
    REGENERATE = "REGENERATE"

class LoopController:
    def __init__(self, policy: Optional[LoopPolicy] = None):
        self.policy = policy or LoopPolicy.reading_section()

    def decide(
        self,
        context: Optional[LoopContext] = None,
        ledger_mgr: Optional[IssueLedgerManager] = None,
        latest_evaluations: Sequence[EvaluationResult] = (),
        stagnation_detector: Optional[StagnationDetector] = None,
        oscillation_detector: Optional[OscillationDetector] = None,
        dependencies_fresh: bool = True,
        dependency_stale_reasons: list[str] | None = None,
        repair_attempts_this_version: int = 0,
        generated_versions: int = 0,
        has_repairer: bool = True,
        issues: Optional[Sequence[object]] = None,
        **kwargs,
    ) -> LoopDecision:
        if issues is not None:
            from app.loop.context import AuthorityGrant
            auth = kwargs.get("authority") or AuthorityGrant(leaseOwner=uuid4(), epoch=1)
            ctx = context or LoopContext(
                run_id=kwargs.get("run_id", "run_recovery"),
                target_artifact_id=kwargs.get("target_artifact_id", "question:target"),
                target_artifact_type=kwargs.get("target_artifact_type", "Section"),
                scope=kwargs.get("scope", IssueScope.QUESTION),
                authority=auth,
            )
            return self.decide_recovery(
                issues=issues,
                context=ctx,
                stagnation_detector=stagnation_detector,
                oscillation_detector=oscillation_detector,
                repair_attempts=repair_attempts_this_version,
            )
        if context is None:
            raise ValueError("LoopController.decide requires either 'context' or 'issues'")
        if stagnation_detector is None:
            stagnation_detector = StagnationDetector()
        if oscillation_detector is None:
            oscillation_detector = OscillationDetector()
        if ledger_mgr is None:
            ledger_mgr = IssueLedgerManager(run_id=context.run_id)
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

    def decide_recovery(
        self,
        issues: Sequence[object],
        context: LoopContext,
        stagnation_detector: Optional[StagnationDetector] = None,
        oscillation_detector: Optional[OscillationDetector] = None,
        repair_attempts: int = 0,
        reserve_candidates_available: bool = True,
    ) -> LoopDecision:
        """Diagnoses issues and routes to the appropriate level of the escalation ladder.

        Escalation Ladder:
        1. ITEM_REPAIR: Isolated single-question defects (e.g. ambiguity, bad distractor, ungrounded key).
        2. ITEM_RESELECT: When item repair repeats or stagnates, pull a candidate from reserve pool.
        3. GROUP_REPAIR: Shared group issues (summary flow, headings list, diagram labels).
        4. PASSAGE_REPAIR: Defect requires clarifying passage text (contradiction, overstatement, passage gap).
        5. REGENERATE: Repeated failures after repairs or unrepairable defects.
        """
        artifact = context.current_artifact
        version = artifact.version if artifact else 0
        cur_state = context.cursor.current_state if context.cursor else LoopState.DRAFTING

        # Filter or check issues
        if not issues:
            return LoopDecision(
                decisionId=f"dec_{uuid4().hex}",
                runId=context.run_id,
                decision=DecisionType.PASS,
                currentState=cur_state,
                nextState=LoopState.COMPLETED,
                reason="No issues reported",
                reasonCode=LoopReason.ACCEPTED,
                targetScope=context.scope,
                targetArtifactId=context.target_artifact_id,
                expectedVersion=version,
            )

        # Max repair attempts check
        max_repairs = getattr(self.policy, "max_total_repairs", 3)
        if repair_attempts >= max_repairs:
            return LoopDecision(
                decisionId=f"dec_{uuid4().hex}",
                runId=context.run_id,
                decision=DecisionType.REGENERATE,
                currentState=cur_state,
                nextState=LoopState.DRAFTING,
                reason=f"Exceeded max repair attempts ({repair_attempts} >= {max_repairs}); regenerating",
                reasonCode=LoopReason.MAX_REPAIRS,
                targetScope=context.scope,
                targetArtifactId=context.target_artifact_id,
                expectedVersion=version + 1,
            )

        # Classify scopes and targets of issues
        has_passage_defect = False
        has_group_defect = False
        question_issues: list[object] = []

        for iss in issues:
            scope = getattr(iss, "scope", None)
            scope_v = getattr(scope, "value", str(scope) if scope else "")
            code = getattr(iss, "code", None)
            code_v = getattr(code, "value", str(code) if code else "")

            if scope_v in (IssueScope.PASSAGE.value, "PASSAGE", "SECTION"):
                has_passage_defect = True
            elif scope_v in (IssueScope.QUESTION_GROUP.value, "QUESTION_GROUP", "GROUP"):
                has_group_defect = True
            elif scope_v in (IssueScope.QUESTION.value, "QUESTION", "ITEM"):
                question_issues.append(iss)
            else:
                # Check code heuristics
                if code_v in (
                    IssueCode.OVERSTATED_CERTAINTY.value,
                    IssueCode.CAUSAL_OVERSTATEMENT.value,
                    IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM.value,
                    IssueCode.SECTION_WORD_COUNT_OUT_OF_BOUNDS.value,
                ):
                    has_passage_defect = True
                elif code_v in (
                    IssueCode.DUPLICATE_ITEMS.value,
                    "DUPLICATE_ITEMS",
                    "SUMMARY_COHERENCE",
                    "HEADING_REDUNDANCY",
                ):
                    has_group_defect = True
                else:
                    question_issues.append(iss)

        # Ladder Level 4: PASSAGE_REPAIR
        if has_passage_defect:
            art_ref = getattr(issues[0], "artifact_ref", None) or getattr(issues[0], "location", None) or context.target_artifact_id
            return LoopDecision(
                decisionId=f"dec_{uuid4().hex}",
                runId=context.run_id,
                decision=DecisionType.REPAIR,
                currentState=cur_state,
                nextState=LoopState.REPAIRING,
                reason="Passage defect detected; routing to PASSAGE_REPAIR",
                reasonCode=LoopReason.REPAIRABLE_DEFECTS,
                targetScope=EscalationLadder.PASSAGE_REPAIR.value,
                targetArtifactId=str(art_ref),
                expectedVersion=version + 1,
            )

        # Ladder Level 3: GROUP_REPAIR
        if has_group_defect or len({getattr(q, 'artifact_ref', None) for q in question_issues if getattr(q, 'artifact_ref', None)}) > 2:
            art_ref = getattr(issues[0], "artifact_ref", None) or getattr(issues[0], "location", None) or context.target_artifact_id
            return LoopDecision(
                decisionId=f"dec_{uuid4().hex}",
                runId=context.run_id,
                decision=DecisionType.REPAIR,
                currentState=cur_state,
                nextState=LoopState.REPAIRING,
                reason="Group-level defect detected; routing to GROUP_REPAIR",
                reasonCode=LoopReason.REPAIRABLE_DEFECTS,
                targetScope=EscalationLadder.GROUP_REPAIR.value,
                targetArtifactId=str(art_ref),
                expectedVersion=version + 1,
            )

        # Check stagnation detector for item repair
        is_stagnated = False
        if stagnation_detector:
            is_stagnated = stagnation_detector.should_escalate_stagnation(threshold=1)

        first_q = question_issues[0] if question_issues else issues[0]
        target_id = getattr(first_q, "artifact_ref", None) or getattr(first_q, "location", None) or context.target_artifact_id

        # Ladder Level 2: ITEM_RESELECT
        if is_stagnated:
            if reserve_candidates_available:
                return LoopDecision(
                    decisionId=f"dec_{uuid4().hex}",
                    runId=context.run_id,
                    decision=DecisionType.REPAIR,
                    currentState=cur_state,
                    nextState=LoopState.REPAIRING,
                    reason="Stagnation detected after repeated identical defects; escalating to ITEM_RESELECT",
                    reasonCode=LoopReason.REPAIRABLE_DEFECTS,
                    targetScope=EscalationLadder.ITEM_RESELECT.value,
                    targetArtifactId=str(target_id),
                    expectedVersion=version + 1,
                )
            else:
                return LoopDecision(
                    decisionId=f"dec_{uuid4().hex}",
                    runId=context.run_id,
                    decision=DecisionType.REGENERATE,
                    currentState=cur_state,
                    nextState=LoopState.DRAFTING,
                    reason="Stagnation detected and no reserve candidates available; escalating to REGENERATE",
                    reasonCode=LoopReason.UNREPAIRABLE_DEFECTS,
                    targetScope=EscalationLadder.REGENERATE.value,
                    targetArtifactId=str(target_id),
                    expectedVersion=version + 1,
                )

        # Ladder Level 1: ITEM_REPAIR
        return LoopDecision(
            decisionId=f"dec_{uuid4().hex}",
            runId=context.run_id,
            decision=DecisionType.REPAIR,
            currentState=cur_state,
            nextState=LoopState.REPAIRING,
            reason="Isolated single-question defect; routing to ITEM_REPAIR",
            reasonCode=LoopReason.REPAIRABLE_DEFECTS,
            targetScope=EscalationLadder.ITEM_REPAIR.value,
            targetArtifactId=str(target_id),
            expectedVersion=version + 1,
        )
