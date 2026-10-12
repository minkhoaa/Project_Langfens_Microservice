"""Phase 15 V2 scope-aware escalation for evidence defects (agent B / D2).

Live campaign evidence: camp_G15_d2c833c1c04f, run
bench_adc6cec1099fda44df71ac0326ec0134, case 16 (seed 101).

The run's only OPEN blocker was a QUESTION-scoped EVIDENCE_MISSING:

    EVIDENCE_MISSING | QUESTION | OPEN | Question 9 completion answer
    'mutant huntingtin (mHTT)' does not appear as a full-token verbatim
    span in passage

Because `EVIDENCE_MISSING` sits in `LoopPolicy.escalate_codes`,
`LoopController.decide` returned ESCALATE for the ENTIRE paper
("source/evidence requires editorial or source review"), killing one
paper over one slot's answer. That is the over-broad escalation this
file pins down.

The general rule under test:
    * An evidence defect whose scope is QUESTION is a per-slot
      generation defect: it routes to the question loop's
      regeneration path, exactly as other regenerable codes are
      handled. It must NOT escalate the whole paper.
    * A genuine source insufficiency — EVIDENCE_MISSING at
      PASSAGE / SOURCE scope, or SOURCE_INSUFFICIENT at any scope —
      MUST still escalate. Removing EVIDENCE_MISSING wholesale from
      escalate_codes would fail open on real source problems and is
      therefore not the fix.

These are pure behavioural tests of the decision table: they build a
real LoopContext, a real IssueLedgerManager with the issue recorded at
a chosen scope, and a real EvaluationResult, then call the real
`LoopController.decide`. No file text is read and no model string is
matched; the classification is by IssueCode + IssueScope only.
"""

from __future__ import annotations

from uuid import UUID

import pytest

from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.contracts.issue import IssueCode, IssueScope, IssueSeverity
from app.contracts.loop import DecisionType, LoopReason
from app.loop.context import AuthorityGrant, LoopContext
from app.loop.controller import LoopController
from app.loop.detectors import OscillationDetector, StagnationDetector
from app.loop.ledger import IssueLedgerManager
from app.loop.policy import LoopPolicy


RUN_ID = "bench_adc6cec1099fda44df71ac0326ec0134"

# A fixed authority owner so the decision table sees an active lease.
_OWNER = UUID("00000000-0000-4000-8000-000000000001")


def _context(scope: IssueScope, *, artifact_id: str = "art_question_09"):
    """A real LoopContext bound to one question artifact (no cancellation)."""
    return LoopContext(
        runId=RUN_ID,
        targetArtifactId=artifact_id,
        targetArtifactType=ArtifactType.QUESTION,
        scope=scope,
        authority=AuthorityGrant(leaseOwner=_OWNER, epoch=1),
    )


def _artifact(ctx: LoopContext, version: int = 1) -> ArtifactEnvelope:
    """A real immutable artifact envelope at the requested version."""
    return ArtifactEnvelope.create(
        ctx.target_artifact_id,
        ctx.target_artifact_type,
        ctx.run_id,
        {"answer": "mutant huntingtin (mHTT)"},
        "2.0.0",
        version=version,
    )


def _policy() -> LoopPolicy:
    """Default policy with a single required evaluator (loose caps for the unit scope)."""
    return LoopPolicy(required_evaluator_ids=("required",))


def _decide(scope: IssueScope, issue_code: IssueCode, *, has_repairer: bool = False):
    """Drive `LoopController.decide` with exactly one open CRITICAL blocker
    of the given (code, scope) and return the LoopDecision.
    """
    ctx = _context(scope)
    art = _artifact(ctx)
    ctx.current_artifact = art

    ledger = IssueLedgerManager(ctx.run_id)
    ledger.record_issue(
        issue_code,
        IssueSeverity.CRITICAL,
        scope,
        f"Question 9 completion answer defect ({issue_code.value}/{scope.value})",
        affected_refs=[art.to_ref()],
    )

    ev = EvaluationResult(
        evaluationId=f"eval_{art.version}",
        evaluatorId="required",
        evaluatorVersion="1",
        targetRef=art.to_ref(),
        inputDependencyRefs=list(art.parent_refs),
        status=EvaluationStatus.FAIL,
        issues=ledger.get_open_issues(),
        score=0.5,
    )

    decision = LoopController(_policy()).decide(
        ctx,
        ledger,
        [ev],
        StagnationDetector(),
        OscillationDetector(),
        dependencies_fresh=True,
        repair_attempts_this_version=0,
        generated_versions=0,
        has_repairer=has_repairer,
    )
    return decision


# ---------------------------------------------------------------------------
# (1) The case-16 shape: a QUESTION-scoped evidence defect must NOT escalate
#     the whole paper. It is a per-slot regeneration, like SCHEMA_VIOLATION.
# ---------------------------------------------------------------------------


def test_phase15_v2rate_b_question_scoped_evidence_missing_does_not_escalate():
    """A one-slot evidence defect routes to regeneration, not paper escalation.

    This is exactly the defect that killed case 16: a QUESTION-scoped
    EVIDENCE_MISSING whose message is about one slot's completion answer
    not being verbatim in the passage. It must decide REGENERATE (the
    question loop's regeneration path), never ESCALATE.
    """
    decision = _decide(IssueScope.QUESTION, IssueCode.EVIDENCE_MISSING)

    assert decision.decision != DecisionType.ESCALATE, (
        "a QUESTION-scoped EVIDENCE_MISSING must not escalate the whole paper; "
        "it is a regenerable per-slot defect"
    )
    assert decision.decision == DecisionType.REGENERATE, (
        "a QUESTION-scoped EVIDENCE_MISSING must route to the question loop's "
        f"regeneration path, got {decision.decision}"
    )
    assert decision.reason_code == LoopReason.UNREPAIRABLE_DEFECTS


# ---------------------------------------------------------------------------
# (2) Genuine source insufficiency must STILL escalate. Removing
#     EVIDENCE_MISSING wholesale would fail open on real source problems;
#     these cases pin that we do not.
# ---------------------------------------------------------------------------


@pytest.mark.parametrize("scope", [
    IssueScope.SOURCE,
    IssueScope.PASSAGE,
    IssueScope.SECTION,
    IssueScope.EVIDENCE,
])
def test_phase15_v2rate_b_non_question_evidence_missing_still_escalates(scope):
    """An evidence defect that is NOT about one slot's answer still escalates.

    Only the QUESTION scope is demoted. SOURCE / PASSAGE / SECTION /
    EVIDENCE scopes describe the source or the passage as a whole, which
    no local regeneration can fix, so they must still escalate.
    """
    decision = _decide(scope, IssueCode.EVIDENCE_MISSING)

    assert decision.decision == DecisionType.ESCALATE, (
        f"EVIDENCE_MISSING at {scope.value} scope is a source/evidence defect, "
        f"not a per-slot answer defect, and must still escalate; got {decision.decision}"
    )
    assert decision.reason_code == LoopReason.SOURCE_INSUFFICIENT


@pytest.mark.parametrize("scope", [
    IssueScope.SOURCE,
    IssueScope.PASSAGE,
    IssueScope.SECTION,
    IssueScope.QUESTION,
])
def test_phase15_v2rate_b_source_insufficient_still_escalates_at_any_scope(scope):
    """SOURCE_INSUFFICIENT is never demoted, at any scope."""
    decision = _decide(scope, IssueCode.SOURCE_INSUFFICIENT)

    assert decision.decision == DecisionType.ESCALATE, (
        f"SOURCE_INSUFFICIENT at {scope.value} scope must escalate; "
        f"got {decision.decision}"
    )
    assert decision.reason_code == LoopReason.SOURCE_INSUFFICIENT


# ---------------------------------------------------------------------------
# (3) Boundary of the demotion: only the (EVIDENCE_MISSING, QUESTION) pair
#     is affected. Every other escalate code keeps escalating at every
#     scope, and the other regenerable codes keep regenerating.
# ---------------------------------------------------------------------------


def test_phase15_v2rate_b_only_evidence_missing_is_scope_demoted():
    """No code other than EVIDENCE_MISSING is scope-demoted.

    Pins the blast radius of the fix: escalate_codes minus
    {EVIDENCE_MISSING} still escalate at QUESTION scope too, so the
    demotion cannot silently swallow a genuine escalation.
    """
    policy = LoopPolicy()
    always_escalate = policy.escalate_codes - {IssueCode.EVIDENCE_MISSING}
    assert always_escalate, "policy must retain at least one always-escalate code"
    for code in always_escalate:
        decision = _decide(IssueScope.QUESTION, code)
        assert decision.decision == DecisionType.ESCALATE, (
            f"{code.value} at QUESTION scope must still escalate; got {decision.decision}"
        )


@pytest.mark.parametrize("code", [
    IssueCode.SCHEMA_VIOLATION,
    IssueCode.DUPLICATE_CONTENT,
    IssueCode.ANSWER_LEAKAGE,
    IssueCode.STALE_DEPENDENCY,
])
def test_phase15_v2rate_b_other_regenerable_codes_still_regenerate_at_question_scope(code):
    """The other regenerable codes are unchanged at QUESTION scope."""
    decision = _decide(IssueScope.QUESTION, code)

    assert decision.decision == DecisionType.REGENERATE, (
        f"{code.value} at QUESTION scope must regenerate; got {decision.decision}"
    )


# ---------------------------------------------------------------------------
# (4) No cap is raised and no termination is weakened: the demoted issue is
#     still a CRITICAL open blocker, so the paper can never PASS with it,
#     and the bounded versions/caps are untouched.
# ---------------------------------------------------------------------------


def test_phase15_v2rate_b_question_evidence_missing_still_blocks_pass():
    """Routing to regenerate must not make the blocker disappear.

    The defect is demoted only from ESCALATE to REGENERATE. The issue is
    still recorded as an open CRITICAL blocker, so the loop cannot reach
    PASS while it remains unresolved. This pins that grounding is not
    relaxed by the scope-aware escalation.
    """
    ctx = _context(IssueScope.QUESTION)
    art = _artifact(ctx)
    ctx.current_artifact = art

    ledger = IssueLedgerManager(ctx.run_id)
    issue = ledger.record_issue(
        IssueCode.EVIDENCE_MISSING,
        IssueSeverity.CRITICAL,
        IssueScope.QUESTION,
        "Question 9 completion answer 'mutant huntingtin (mHTT)' does not appear "
        "as a full-token verbatim span in passage",
        affected_refs=[art.to_ref()],
    )

    assert issue.status.value == "OPEN"
    blockers = ledger.get_unresolved_blockers()
    assert len(blockers) == 1, "the demoted issue must remain an open CRITICAL blocker"
    assert blockers[0].code == IssueCode.EVIDENCE_MISSING

    # A clean evaluation cannot PASS while the blocker is open: the
    # decision table checks the open blockers before the PASS branch.
    ev = EvaluationResult(
        evaluationId="eval_1",
        evaluatorId="required",
        evaluatorVersion="1",
        targetRef=art.to_ref(),
        inputDependencyRefs=list(art.parent_refs),
        status=EvaluationStatus.PASS,
        issues=[],
        score=0.99,
    )
    decision = LoopController(_policy()).decide(
        ctx, ledger, [ev], StagnationDetector(), OscillationDetector(),
        dependencies_fresh=True, repair_attempts_this_version=0,
        generated_versions=0, has_repairer=False,
    )
    assert decision.decision != DecisionType.PASS, (
        "an open CRITICAL blocker must prevent PASS regardless of scope"
    )


def test_phase15_v2rate_b_escalation_fix_raises_no_caps():
    """Static guard: the demotion must not be bought with a raised cap.

    Pins the exact default caps the demotion relies on staying put. If a
    future change widens any of these to buy a better rate, this fails.
    """
    policy = LoopPolicy()

    assert policy.max_versions == 3
    assert policy.max_generated_versions == 3
    assert policy.max_repair_attempts_per_version == 2
    assert policy.max_total_repairs == 5
    assert policy.max_consecutive_no_progress == 2
    assert policy.max_oscillation_cycles == 2

    # EVIDENCE_MISSING stays declared as an escalate code: the policy is
    # scope-aware at the decision table, not gutted at the declaration.
    assert IssueCode.EVIDENCE_MISSING in policy.escalate_codes