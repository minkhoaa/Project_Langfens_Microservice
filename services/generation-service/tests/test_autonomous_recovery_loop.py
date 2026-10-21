"""Tests for Task 6: Autonomous Recovery Engine & BoundedLoop Integration.

Covers:
1. Escalation ladder: ITEM_REPAIR -> ITEM_RESELECT -> GROUP_REPAIR -> PASSAGE_REPAIR -> REGENERATE.
2. Deterministic issue SHA-256 hashes and StagnationDetector escalation after 2 consecutive identical issue hashes.
3. OscillationDetector cycle tracking.
4. Diagnostic feedback formatting with adversary counter-claims and conflicting spans.
5. Conservative downstream invalidation closure for passage edits based on evidence spans.
"""
from __future__ import annotations

import pytest
from uuid import uuid4

from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.issue import AcademicIssue, Issue, IssueCode, IssueScope, IssueSeverity, IssueStatus
from app.contracts.loop import DecisionType, LoopReason
from app.loop.context import AuthorityGrant, LoopContext
from app.loop.controller import LoopController, EscalationLadder
from app.loop.detectors import StagnationDetector, OscillationDetector, compute_issues_digest
from app.loop.ledger import IssueLedgerManager
from app.loop.policy import LoopPolicy
from app.repair.passage import compute_passage_edit_invalidation
from app.repair.question import format_diagnostic_feedback


def make_context(target_id: str = "art_section_1", target_type: ArtifactType = ArtifactType.SECTION):
    grant = AuthorityGrant(leaseOwner=uuid4(), epoch=1)
    ctx = LoopContext(
        run_id="run_test_recovery",
        target_artifact_id=target_id,
        target_artifact_type=target_type,
        scope=IssueScope.SECTION,
        authority=grant,
    )
    return ctx


def make_issue(
    code: IssueCode = IssueCode.AMBIGUOUS_ANSWER,
    scope: IssueScope = IssueScope.QUESTION,
    severity: IssueSeverity = IssueSeverity.CRITICAL,
    message: str = "Question 23 has 2 defensible answers (A and C) in paragraph 3.",
    target_ref: str = "question:run1:23",
) -> AcademicIssue:
    return AcademicIssue(
        code=code,
        scope=scope,
        severity=severity,
        message=message,
        artifact_ref=target_ref,
        location=target_ref,
    )


def test_recovery_isolates_defective_question_and_routes_to_item_repair():
    """Isolated single-question defect routes to ITEM_REPAIR."""
    controller = LoopController(policy=LoopPolicy.reading_section())
    issue = make_issue(
        code=IssueCode.AMBIGUOUS_ANSWER,
        scope=IssueScope.QUESTION,
        message="Question 23 has 2 defensible answers: A and C",
        target_ref="question:run1:23",
    )
    ctx = make_context()
    decision = controller.decide_recovery(issues=[issue], context=ctx)
    assert decision.decision == DecisionType.REPAIR
    assert decision.target_scope == "ITEM_REPAIR"
    assert decision.target_artifact_id == "question:run1:23"


def test_recovery_isolates_defective_question_and_escalates_on_stagnation():
    controller = LoopController()
    issue = AcademicIssue(code="AMBIGUOUS_ANSWER", severity=IssueSeverity.CRITICAL, artifact_ref="question:run1:23", scope=IssueScope.QUESTION)
    decision = controller.decide(issues=[issue])
    assert decision.decision_type == DecisionType.REPAIR
    assert decision.target_scope == "ITEM_REPAIR"

def test_stagnation_detector_tracks_issue_digest_and_escalates_on_repeat():
    """When identical issue hashes repeat twice, StagnationDetector triggers escalation."""
    detector = StagnationDetector()
    issues = [
        make_issue(code=IssueCode.AMBIGUOUS_ANSWER, target_ref="question:run1:23"),
    ]
    digest1 = compute_issues_digest(issues)
    assert isinstance(digest1, str) and len(digest1) == 64

    # 1st time
    escalate = detector.record_issues_digest(digest1)
    assert escalate is False
    assert detector.consecutive_identical_issues == 0

    # 2nd time (identical digest) -> triggers escalation
    escalate = detector.record_issues_digest(digest1)
    assert escalate is True
    assert detector.consecutive_identical_issues == 1
    assert detector.should_escalate_stagnation(threshold=1) is True


def test_controller_escalates_to_item_reselect_or_regenerate_on_stagnation():
    """Stagnation on an item repair escalates to ITEM_RESELECT."""
    controller = LoopController(policy=LoopPolicy.reading_section())
    issue = make_issue(
        code=IssueCode.AMBIGUOUS_ANSWER,
        scope=IssueScope.QUESTION,
        message="Question 23 has 2 defensible answers: A and C",
        target_ref="question:run1:23",
    )
    ctx = make_context()
    detector = StagnationDetector()
    digest = compute_issues_digest([issue])
    detector.record_issues_digest(digest)
    detector.record_issues_digest(digest) # 2 consecutive identical issue hashes

    decision = controller.decide_recovery(
        issues=[issue],
        context=ctx,
        stagnation_detector=detector,
    )
    # Escalated from ITEM_REPAIR to ITEM_RESELECT
    assert decision.decision == DecisionType.REPAIR
    assert decision.target_scope == "ITEM_RESELECT"


def test_controller_routes_group_defects_to_group_repair():
    """Defects affecting question group flow / headings list route to GROUP_REPAIR."""
    controller = LoopController(policy=LoopPolicy.reading_section())
    issue = make_issue(
        code=IssueCode.DUPLICATE_ITEMS,
        scope=IssueScope.QUESTION_GROUP,
        message="Headings list in group 2 contains redundant heading option III and VI",
        target_ref="group:run1:2",
    )
    ctx = make_context()
    decision = controller.decide_recovery(issues=[issue], context=ctx)
    assert decision.decision == DecisionType.REPAIR
    assert decision.target_scope == "GROUP_REPAIR"


def test_controller_routes_passage_defects_to_passage_repair():
    """Defects requiring clarifying passage text route to PASSAGE_REPAIR."""
    controller = LoopController(policy=LoopPolicy.reading_section())
    issue = make_issue(
        code=IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM,
        scope=IssueScope.PASSAGE,
        message="Passage contradicts source fact regarding solar collector temperature",
        target_ref="passage:run1:1",
    )
    ctx = make_context()
    decision = controller.decide_recovery(issues=[issue], context=ctx)
    assert decision.decision == DecisionType.REPAIR
    assert decision.target_scope == "PASSAGE_REPAIR"


def test_controller_routes_repeated_failure_to_regenerate():
    """Repeated failures past maximum attempts escalate to REGENERATE."""
    controller = LoopController(policy=LoopPolicy.reading_section())
    issue = make_issue(
        code=IssueCode.AMBIGUOUS_ANSWER,
        scope=IssueScope.QUESTION,
        target_ref="question:run1:23",
    )
    ctx = make_context()
    # If attempt count exceeds max repair attempts or ladder exceeds capacity
    decision = controller.decide_recovery(
        issues=[issue],
        context=ctx,
        repair_attempts=5,
    )
    assert decision.decision == DecisionType.REGENERATE


def test_format_diagnostic_feedback():
    """Formatting diagnostic feedback includes adversary counter-claim and conflicting span."""
    issue = make_issue(
        code=IssueCode.AMBIGUOUS_ANSWER,
        message="Question 23 has 2 defensible answers (A and C)",
        target_ref="question:run1:23",
    )
    prompt = format_diagnostic_feedback(
        issue=issue,
        adversary_claim="Option C ('high humidity') is also strongly supported by lines 14-16.",
        conflicting_span="Atmospheric moisture remained consistently elevated across the trials.",
        question_text="Which factor contributed to the outcome? A: heat, B: wind, C: humidity, D: pressure",
    )
    assert "AMBIGUOUS_ANSWER" in prompt
    assert "Option C" in prompt
    assert "Atmospheric moisture" in prompt
    assert "Question 23" in prompt


def test_passage_edit_downstream_invalidation_closure():
    """Downstream invalidation closure invalidates overlapping question slots while preserving others."""
    # Passage edit occurred at span [100, 250]
    edited_span = (100, 250)
    questions = [
        {
            "id": "q21",
            "evidence_spans": [{"start": 10, "end": 80}], # No overlap
        },
        {
            "id": "q22",
            "evidence_spans": [{"start": 90, "end": 120}], # Overlaps [100, 250]
        },
        {
            "id": "q23",
            "evidence_spans": [{"start": 200, "end": 240}], # Overlaps [100, 250]
        },
        {
            "id": "q24",
            "evidence_spans": [{"start": 300, "end": 450}], # No overlap
        },
    ]

    invalidated, unaffected = compute_passage_edit_invalidation(
        edited_span=edited_span,
        questions=questions,
    )

    assert set(invalidated) == {"q22", "q23"}
    assert set(unaffected) == {"q21", "q24"}
