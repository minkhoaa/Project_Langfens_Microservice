"""Unit tests for RG07-S05: Failure, usage, denominators and replay ledger.

Invariants:
- All assignments and attempts including timeout/partial/cancel/failure mapped with usage confidence.
- E2E primary denominator equals frozen assignments; retry linkage explicit.
- Failed outputs are NOT filtered or billed as zero by missing telemetry.
- Replay does not inflate frozen assignments; research publication to production is strictly forbidden.
"""

from __future__ import annotations

import json
from pathlib import Path
import jsonschema
import pytest
from pydantic import ValidationError

from app.contracts.research import (
    ExecutionStatus,
    ExperimentAssignment,
    OutputAvailability,
)
from app.experiment.ledger import (
    AttemptRecord,
    DuplicateAttemptError,
    ExperimentReplayLedger,
    OrphanRetryError,
    ZeroBilledMissingTelemetryError,
)
from app.persistence.grammar_store import ResearchPublicationForbiddenError


def load_schemas():
    schema_path = (
        Path(__file__).resolve().parents[3]
        / "generation_baseline"
        / "contracts"
        / "JSON_SCHEMAS.json"
    )
    return json.loads(schema_path.read_text())


@pytest.fixture
def frozen_assignments():
    return [
        ExperimentAssignment(
            assignment_id="item-01__arm_A__att1",
            dataset_item_id="item-01",
            configuration_id="A",
            attempt_number=1,
            run_id="run-a-01",
            result_ref="secure://results/run-a-01",
        ),
        ExperimentAssignment(
            assignment_id="item-01__arm_B__att1",
            dataset_item_id="item-01",
            configuration_id="B",
            attempt_number=1,
            run_id="run-b-01",
            result_ref="secure://results/run-b-01",
        ),
        ExperimentAssignment(
            assignment_id="item-01__arm_C__att1",
            dataset_item_id="item-01",
            configuration_id="C",
            attempt_number=1,
            run_id="run-c-01",
            result_ref="secure://results/run-c-01",
        ),
    ]


def test_pos_rg07_s05_reconciled_denominators_and_retry_linkage(frozen_assignments):
    """POS-RG07-S05: E2E denominator equals frozen assignments; retry linkage explicit."""
    ledger = ExperimentReplayLedger()
    ledger.freeze_assignments(frozen_assignments)

    # 1. Record completed attempt for A
    att_a = AttemptRecord(
        attempt_id="att-a-01",
        assignment_id="item-01__arm_A__att1",
        dataset_item_id="item-01",
        configuration_id="A",
        attempt_number=1,
        parent_attempt_id=None,
        execution_status=ExecutionStatus.COMPLETED,
        output_availability=OutputAvailability.NORMALIZED,
        usage_call_count=1,
        usage_total_tokens=1500,
        usage_confidence="EXACT",
        is_terminal=True,
    )
    ledger.record_attempt(att_a)

    # 2. Record initial timed-out attempt for B, followed by linked retry attempt 2
    att_b1 = AttemptRecord(
        attempt_id="att-b-01",
        assignment_id="item-01__arm_B__att1",
        dataset_item_id="item-01",
        configuration_id="B",
        attempt_number=1,
        parent_attempt_id=None,
        execution_status=ExecutionStatus.TIMED_OUT,
        output_availability=OutputAvailability.NONE,
        failure_code="PROVIDER_TIMEOUT",
        usage_call_count=1,
        usage_total_tokens=450,
        usage_confidence="EXACT",
        is_terminal=False,
    )
    ledger.record_attempt(att_b1)

    att_b2 = AttemptRecord(
        attempt_id="att-b-02",
        assignment_id="item-01__arm_B__att1",
        dataset_item_id="item-01",
        configuration_id="B",
        attempt_number=2,
        parent_attempt_id="att-b-01",  # Explicit retry linkage
        execution_status=ExecutionStatus.COMPLETED,
        output_availability=OutputAvailability.NORMALIZED,
        usage_call_count=3,
        usage_total_tokens=3200,
        usage_confidence="EXACT",
        is_terminal=True,
    )
    ledger.record_attempt(att_b2)

    # 3. Record failed validation attempt for C (non-zero failed usage)
    att_c = AttemptRecord(
        attempt_id="att-c-01",
        assignment_id="item-01__arm_C__att1",
        dataset_item_id="item-01",
        configuration_id="C",
        attempt_number=1,
        parent_attempt_id=None,
        execution_status=ExecutionStatus.FAILED_VALIDATION,
        output_availability=OutputAvailability.RAW_ONLY,
        failure_code="AMBIGUOUS_DISTRACTORS",
        usage_call_count=2,
        usage_total_tokens=1800,
        usage_confidence="EXACT",
        is_terminal=True,
    )
    ledger.record_attempt(att_c)

    # 4. Verify reconciled denominators
    stats = ledger.get_reconciled_denominators()
    assert stats["total_frozen_assignments"] == 3
    assert stats["arm_denominators"]["A"] == 1
    assert stats["arm_denominators"]["B"] == 1  # Retry does NOT inflate denominator!
    assert stats["arm_denominators"]["C"] == 1

    # Check terminal statuses
    assert stats["by_arm"]["A"]["completed"] == 1
    assert stats["by_arm"]["B"]["completed"] == 1
    assert stats["by_arm"]["B"]["retried"] == 1
    assert stats["by_arm"]["C"]["failed_validation"] == 1
    assert stats["total_reconciled"] == 3
    assert stats["is_fully_reconciled"] is True

    # Check attempt lineage
    lineage = ledger.get_attempt_lineage("item-01__arm_B__att1")
    assert len(lineage) == 2
    assert lineage[0].attempt_id == "att-b-01"
    assert lineage[1].attempt_id == "att-b-02"
    assert lineage[1].parent_attempt_id == "att-b-01"



def test_pos_rg07_s05_unattempted_assignments_reconciled(frozen_assignments):
    """POS-RG07-S05: Frozen assignments without attempts are reconciled as unattempted."""
    ledger = ExperimentReplayLedger()
    ledger.freeze_assignments(frozen_assignments)  # 3 frozen assignments (A, B, C)

    # Record attempt ONLY for A and B; C remains unattempted
    ledger.record_attempt(
        AttemptRecord(
            attempt_id="att-a-only",
            assignment_id="item-01__arm_A__att1",
            dataset_item_id="item-01",
            configuration_id="A",
            attempt_number=1,
            parent_attempt_id=None,
            execution_status=ExecutionStatus.COMPLETED,
            output_availability=OutputAvailability.NORMALIZED,
            usage_call_count=1,
            usage_total_tokens=1200,
            usage_confidence="EXACT",
            is_terminal=True,
        )
    )
    ledger.record_attempt(
        AttemptRecord(
            attempt_id="att-b-only",
            assignment_id="item-01__arm_B__att1",
            dataset_item_id="item-01",
            configuration_id="B",
            attempt_number=1,
            parent_attempt_id=None,
            execution_status=ExecutionStatus.TIMED_OUT,
            output_availability=OutputAvailability.NONE,
            usage_call_count=1,
            usage_total_tokens=500,
            usage_confidence="EXACT",
            is_terminal=True,
        )
    )

    stats = ledger.get_reconciled_denominators()
    assert stats["total_frozen_assignments"] == 3
    assert stats["total_unattempted"] == 1
    assert stats["total_reconciled"] == 3
    assert stats["is_fully_reconciled"] is True
    assert stats["by_arm"]["C"]["unattempted"] == 1
    assert stats["by_arm"]["C"]["assigned"] == 1

def test_neg_rg07_s05_failed_outputs_not_billed_as_zero_with_missing_telemetry(frozen_assignments):
    """NEG-RG07-S05: Failed outputs not filtered or billed as zero by missing telemetry."""
    ledger = ExperimentReplayLedger()
    ledger.freeze_assignments(frozen_assignments)

    # Attempting to bill a failed run with 0 tokens under EXACT confidence is forbidden
    with pytest.raises(
        ZeroBilledMissingTelemetryError,
        match="Failed output cannot be billed as zero tokens with EXACT confidence",
    ):
        ledger.record_attempt(
            AttemptRecord(
                attempt_id="att-zero-01",
                assignment_id="item-01__arm_A__att1",
                dataset_item_id="item-01",
                configuration_id="A",
                attempt_number=1,
                parent_attempt_id=None,
                execution_status=ExecutionStatus.FAILED_RUNTIME,
                output_availability=OutputAvailability.NONE,
                usage_call_count=1,
                usage_total_tokens=0,  # Zeroed tokens with call_count > 0!
                usage_confidence="EXACT",  # Forbidden: cannot claim EXACT 0 tokens
                is_terminal=True,
            )
        )

    # Truthful UNKNOWN confidence or non-zero estimated token count succeeds
    valid_unknown = AttemptRecord(
        attempt_id="att-unknown-01",
        assignment_id="item-01__arm_A__att1",
        dataset_item_id="item-01",
        configuration_id="A",
        attempt_number=1,
        parent_attempt_id=None,
        execution_status=ExecutionStatus.FAILED_RUNTIME,
        output_availability=OutputAvailability.NONE,
        usage_call_count=1,
        usage_total_tokens=0,
        usage_confidence="UNKNOWN",  # Allowed: truthfully discloses UNKNOWN
        is_terminal=True,
    )
    ledger.record_attempt(valid_unknown)
    assert ledger.get_attempt("att-unknown-01") is not None


def test_edge_rg07_s05_duplicate_attempt_and_orphan_retry_rejected(frozen_assignments):
    """EDGE-RG07-S05: Duplicate attempt ID and orphan retry parent safely rejected."""
    ledger = ExperimentReplayLedger()
    ledger.freeze_assignments(frozen_assignments)

    att1 = AttemptRecord(
        attempt_id="att-dup-01",
        assignment_id="item-01__arm_A__att1",
        dataset_item_id="item-01",
        configuration_id="A",
        attempt_number=1,
        parent_attempt_id=None,
        execution_status=ExecutionStatus.COMPLETED,
        output_availability=OutputAvailability.NORMALIZED,
        usage_call_count=1,
        usage_total_tokens=1000,
        usage_confidence="EXACT",
        is_terminal=True,
    )
    ledger.record_attempt(att1)

    # 1. Duplicate attempt ID rejection
    with pytest.raises(DuplicateAttemptError, match="Duplicate attempt"):
        ledger.record_attempt(att1)

    # 2. Orphan retry rejection (parent attempt does not exist)
    with pytest.raises(OrphanRetryError, match="Parent attempt 'nonexistent-parent' not found"):
        ledger.record_attempt(
            AttemptRecord(
                attempt_id="att-orphan-01",
                assignment_id="item-01__arm_A__att1",
                dataset_item_id="item-01",
                configuration_id="A",
                attempt_number=2,
                parent_attempt_id="nonexistent-parent",
                execution_status=ExecutionStatus.COMPLETED,
                output_availability=OutputAvailability.NORMALIZED,
                usage_call_count=1,
                usage_total_tokens=1200,
                usage_confidence="EXACT",
                is_terminal=True,
            )
        )


def test_reg_rg07_s05_research_publication_to_production_forbidden(frozen_assignments):
    """REG-RG07-S05: Research attempts cannot be published to production exams."""
    ledger = ExperimentReplayLedger()
    ledger.freeze_assignments(frozen_assignments)

    att = AttemptRecord(
        attempt_id="att-pub-01",
        assignment_id="item-01__arm_A__att1",
        dataset_item_id="item-01",
        configuration_id="A",
        attempt_number=1,
        parent_attempt_id=None,
        execution_status=ExecutionStatus.COMPLETED,
        output_availability=OutputAvailability.NORMALIZED,
        usage_call_count=1,
        usage_total_tokens=1000,
        usage_confidence="EXACT",
        is_terminal=True,
    )
    ledger.record_attempt(att)

    # Inviolable protection: attempting to publish research attempt to production raises ResearchPublicationForbiddenError
    with pytest.raises(ResearchPublicationForbiddenError, match="RESEARCH_PUBLICATION_FORBIDDEN"):
        ledger.publish_to_production(attempt_id="att-pub-01", admin_user_id="admin-01")
