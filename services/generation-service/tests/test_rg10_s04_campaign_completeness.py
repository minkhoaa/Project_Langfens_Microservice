"""Unit tests for RG10-S04: Campaign completeness and accounting reconciliation.

Objective: Assignment ledger, attempts, retries, status distribution, token estimates and cost confidence reconciled.
Decisive acceptance condition: Counts/totals match frozen grid; no phantom successes or zero unknown; malformed outputs cannot disappear.
"""

from __future__ import annotations

import pytest

from app.contracts.research import (
    ExecutionStatus,
    ExperimentAssignment,
    OutputAvailability,
)
from app.experiment.campaign_runner import (
    CampaignBatchExecutor,
    CampaignCompletenessReport,
    CampaignReconciliationManager,
    DenominatorMismatchError,
)
from app.experiment.ledger import (
    AttemptRecord,
    DuplicateAttemptError,
    ExperimentReplayLedger,
    OrphanRetryError,
    ZeroBilledMissingTelemetryError,
)
from app.persistence.grammar_store import ResearchPublicationForbiddenError


def _build_test_ledger(num_items: int = 10) -> ExperimentReplayLedger:
    ledger = ExperimentReplayLedger()
    assignments = []
    for idx in range(num_items):
        item_id = f"item-rec-{idx:03d}"
        for arm in ("A", "B", "C"):
            asg = ExperimentAssignment(
                assignment_id=f"asg-{item_id}-{arm}",
                dataset_item_id=item_id,
                configuration_id=arm,
                attempt_number=1,
            )
            assignments.append(asg)
    ledger.freeze_assignments(assignments)
    return ledger


def test_pos_rg10_s04_completeness_reconciliation_matches_frozen_grid():
    """POS-RG10-S04: Counts and totals match frozen grid; no phantom successes or zero unknown."""
    ledger = _build_test_ledger(10)  # 30 assignments
    recon_mgr = CampaignReconciliationManager()

    # Record attempts for all 30 assignments across A, B, C
    for asg in ledger.get_frozen_assignments():
        attempt = AttemptRecord(
            attempt_id=f"att-{asg.assignment_id}-1",
            assignment_id=asg.assignment_id,
            dataset_item_id=asg.dataset_item_id,
            configuration_id=asg.configuration_id,
            attempt_number=1,
            execution_status=ExecutionStatus.COMPLETED,
            output_availability=OutputAvailability.NORMALIZED,
            usage_call_count=1,
            usage_prompt_tokens=150,
            usage_completion_tokens=250,
            usage_total_tokens=400,
            usage_confidence="EXACT",
            cost_usd=0.0023,
            is_terminal=True,
        )
        ledger.record_attempt(attempt)

    report = recon_mgr.reconcile_campaign_completeness(ledger)
    assert report.total_frozen_assignments == 30
    assert report.total_attempts == 30
    assert report.is_fully_reconciled is True
    assert report.status_distribution["COMPLETED"] == 30
    assert report.confidence_distribution["EXACT"] == 30
    for arm in ("A", "B", "C"):
        assert report.completion_rate_by_arm[arm] == 1.0
        assert report.cost_by_arm[arm] > 0.0
        assert report.token_usage_by_arm[arm]["total"] == 10 * 400

def test_neg_rg10_s04_malformed_or_dropped_output_cannot_disappear_from_denominators():
    """NEG-RG10-S04: Failed/malformed output cannot disappear from denominators or be zero-billed."""
    ledger = _build_test_ledger(5)  # 15 assignments
    recon_mgr = CampaignReconciliationManager()
    frozen = ledger.get_frozen_assignments()

    # 1. Zero-billed missing telemetry on failed run raises ZeroBilledMissingTelemetryError
    with pytest.raises(ZeroBilledMissingTelemetryError) as exc_info:
        bad_attempt = AttemptRecord(
            attempt_id="att-bad-001",
            assignment_id=frozen[0].assignment_id,
            dataset_item_id=frozen[0].dataset_item_id,
            configuration_id="A",
            attempt_number=1,
            execution_status=ExecutionStatus.FAILED_RUNTIME,
            output_availability=OutputAvailability.NONE,
            usage_call_count=1,
            usage_total_tokens=0,
            usage_confidence="EXACT",  # Cannot claim EXACT 0 tokens for failed run with calls
            is_terminal=True,
        )
        ledger.record_attempt(bad_attempt)
    assert "Failed output cannot be billed as zero tokens with EXACT confidence" in str(exc_info.value)

    # 2. Omitted assignment fails full reconciliation
    # Record attempts for only 14 out of 15 assignments
    for asg in frozen[:-1]:
        attempt = AttemptRecord(
            attempt_id=f"att-{asg.assignment_id}-1",
            assignment_id=asg.assignment_id,
            dataset_item_id=asg.dataset_item_id,
            configuration_id=asg.configuration_id,
            attempt_number=1,
            execution_status=ExecutionStatus.FAILED_VALIDATION,
            output_availability=OutputAvailability.PARSEABLE,
            usage_call_count=1,
            usage_prompt_tokens=100,
            usage_completion_tokens=50,
            usage_total_tokens=150,
            usage_confidence="EXACT",
            is_terminal=True,
        )
        ledger.record_attempt(attempt)

    # Reconciling with an unattempted/omitted assignment records unattempted and fails strict complete-only check
    report = recon_mgr.reconcile_campaign_completeness(ledger)
    assert report.status_distribution["FAILED_VALIDATION"] == 14
    assert report.unattempted_count == 1
    with pytest.raises(DenominatorMismatchError) as exc_info:
        recon_mgr.assert_no_unattempted_assignments(report)
    assert "Unattempted assignments remaining" in str(exc_info.value)


def test_edge_rg10_s04_retry_lineages_and_duplicate_attempts():
    """EDGE-RG10-S04: Linked retries accounted without duplicate attempts."""
    ledger = _build_test_ledger(2)
    frozen = ledger.get_frozen_assignments()
    asg = frozen[0]

    # Attempt 1: Failed runtime
    att1 = AttemptRecord(
        attempt_id=f"att-{asg.assignment_id}-1",
        assignment_id=asg.assignment_id,
        dataset_item_id=asg.dataset_item_id,
        configuration_id=asg.configuration_id,
        attempt_number=1,
        execution_status=ExecutionStatus.FAILED_RUNTIME,
        output_availability=OutputAvailability.NONE,
        usage_call_count=1,
        usage_total_tokens=50,
        usage_confidence="ESTIMATED",
        is_terminal=False,
    )
    ledger.record_attempt(att1)

    # Attempt 2: Retry linked to parent Attempt 1
    att2 = AttemptRecord(
        attempt_id=f"att-{asg.assignment_id}-2",
        assignment_id=asg.assignment_id,
        dataset_item_id=asg.dataset_item_id,
        configuration_id=asg.configuration_id,
        attempt_number=2,
        parent_attempt_id=att1.attempt_id,
        execution_status=ExecutionStatus.COMPLETED,
        output_availability=OutputAvailability.NORMALIZED,
        usage_call_count=1,
        usage_total_tokens=250,
        usage_confidence="EXACT",
        is_terminal=True,
    )
    ledger.record_attempt(att2)

    # Orphan retry without parent raises OrphanRetryError
    with pytest.raises(OrphanRetryError) as exc_info:
        orphan = AttemptRecord(
            attempt_id=f"att-{asg.assignment_id}-orphan",
            assignment_id=asg.assignment_id,
            dataset_item_id=asg.dataset_item_id,
            configuration_id=asg.configuration_id,
            attempt_number=3,
            parent_attempt_id="nonexistent-parent-att",
            execution_status=ExecutionStatus.COMPLETED,
            output_availability=OutputAvailability.NORMALIZED,
            is_terminal=True,
        )
        ledger.record_attempt(orphan)
    assert "Parent attempt" in str(exc_info.value)

    # Duplicate attempt ID raises DuplicateAttemptError
    with pytest.raises(DuplicateAttemptError) as exc_info:
        dup = att1.model_copy()
        ledger.record_attempt(dup)
    assert "Duplicate attempt" in str(exc_info.value)


def test_reg_rg10_s04_research_isolation():
    """REG-RG10-S04: Replay ledger prevents publishing attempts to production."""
    ledger = _build_test_ledger(1)
    with pytest.raises(ResearchPublicationForbiddenError) as exc_info:
        ledger.publish_to_production("att-001", admin_user_id="fake-admin")
    assert "RESEARCH_PUBLICATION_FORBIDDEN" in str(exc_info.value)
