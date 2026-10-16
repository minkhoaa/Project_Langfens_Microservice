"""Unit tests for RG10-S01: Reading final paired assignment batches.

Parent: generation_baseline/prompts/sprints/prompt-sprint-10-01.md
Objective: Frozen 25-40 Reading items x A/B/C executed in resumable bounded batches.
Decisive acceptance condition: Counts match frozen assignments exactly and retries/failures remain visible.
"""

from __future__ import annotations

from uuid import uuid4

import pytest

from app.contracts.artifact import ArtifactType
from app.contracts.evaluation import EvaluationStatus
from app.contracts.issue import IssueCode, IssueScope, IssueSeverity
from app.contracts.research import (
    ExecutionStatus,
    ExperimentAssignment,
    OutputAvailability,
    PairedTaskFixture,
    PromptVersionMap,
    ReadingTask,
    SourceRef,
    StandaloneGroupType,
)
from app.experiment.campaign_runner import (
    BatchCardinalityExceededError,
    BatchExecutionState,
    CampaignBatchExecutor,
    CherryPickForbiddenError,
    ReplacementItemForbiddenError,
)
from app.experiment.final_dataset import FinalDatasetRegistry
from app.experiment.ledger import DuplicateAttemptError, ExperimentReplayLedger
from app.experiment.paired import PairedAssignmentManager
from app.experiment.runners import (
    ConfigurationARunner,
    ConfigurationBRunner,
    ConfigurationCRunner,
)
from app.persistence.grammar_store import ResearchPublicationForbiddenError
from app.evaluators.section import SectionStructureEvaluator
from app.loop.context import AuthorityGrant, LoopContext
from tests.test_t12_paper_loop import create_mock_section_envelope
from tests.research_provider_fixtures import DeterministicExperimentClient


def _build_reading_fixtures(count: int = 28) -> List[PairedTaskFixture]:
    registry = FinalDatasetRegistry()
    reading_tasks = registry.build_reading_final_tasks()
    return reading_tasks[:count]


def test_pos_rg10_s01_reading_final_paired_batches_execution():
    """POS-RG10-S01: Frozen Reading items executed in bounded batches (<=5 items) with retry lineage."""
    fixtures = _build_reading_fixtures(28)
    assert len(fixtures) == 28

    client = DeterministicExperimentClient()
    assignment_manager = PairedAssignmentManager()
    ledger = ExperimentReplayLedger()
    runner = CampaignBatchExecutor(
        assignment_manager=assignment_manager,
        ledger=ledger,
        client=client,
    )

    # 1. Partition into bounded batches
    batches = runner.partition_batches(fixtures, max_items_per_batch=5)
    assert len(batches) == 6  # 5, 5, 5, 5, 5, 3
    for b in batches:
        assert len(b) <= 5

    # 2. Execute batches
    batch_states: List[BatchExecutionState] = []
    for idx, batch_fixtures in enumerate(batches):
        state = runner.execute_reading_batch(
            batch_fixtures=batch_fixtures,
            batch_index=idx + 1,
            allow_retries=True,
            max_retries=2,
        )
        batch_states.append(state)
        assert state.status in ("COMPLETED", "PARTIAL", "FAILED")
        assert len(state.dataset_item_ids) <= 5
        assert len(state.assignment_ids) == len(batch_fixtures) * 3

    # 3. Exactly one authoritative outcome per assignment
    total_assignments = sum(len(s.assignment_ids) for s in batch_states)
    assert total_assignments == 28 * 3  # 84 arm assignments

    # Verify coverage across all batches
    runner.validate_batch_coverage(fixtures, batch_states)

    # Check ledger accounting: all 84 assignments frozen and attempted
    ledger_summary = ledger.reconcile_campaign()
    assert ledger_summary.total_frozen_assignments == 84
    assert ledger_summary.total_attempts >= 84


def test_neg_rg10_s01_batch_cardinality_and_no_cherry_picking():
    """NEG-RG10-S01: >5 items rejected; replacement items and cherry-picking fail closed."""
    fixtures = _build_reading_fixtures(10)
    runner = CampaignBatchExecutor(client=DeterministicExperimentClient())

    # 1. Reject batch cardinality > 5 items
    with pytest.raises(BatchCardinalityExceededError) as exc_info:
        runner.partition_batches(fixtures, max_items_per_batch=6)
    assert "cannot exceed 5" in str(exc_info.value)

    with pytest.raises(BatchCardinalityExceededError) as exc_info:
        runner.execute_reading_batch(batch_fixtures=fixtures[:6], batch_index=1)
    assert "exceeds maximum allowed cardinality" in str(exc_info.value)

    # 2. Reject replacing failed assignment with replacement task
    tampered_fixture = fixtures[0].model_copy(update={"dataset_item_id": "replacement-item-fake-01"})
    with pytest.raises(ReplacementItemForbiddenError) as exc_info:
        runner.validate_no_replacement(
            original_item_id=fixtures[0].dataset_item_id,
            executed_item_id=tampered_fixture.dataset_item_id,
        )
    assert "Replacement of frozen assignment" in str(exc_info.value)

    # 3. Reject cherry-picking (omitting failed batches from accounting)
    batches = runner.partition_batches(fixtures[:6], max_items_per_batch=5)  # 2 batches: 5, 1
    state1 = runner.execute_reading_batch(batches[0], batch_index=1)
    # Only supply batch 1, omitting batch 2
    with pytest.raises(CherryPickForbiddenError) as exc_info:
        runner.validate_batch_coverage(fixtures[:6], [state1])
    assert "Missing executed batches" in str(exc_info.value)


def test_edge_rg10_s01_resumable_batches_and_interrupted_progress():
    """EDGE-RG10-S01: Resuming an interrupted batch preserves attempt lineage without duplicating."""
    fixtures = _build_reading_fixtures(3)
    ledger = ExperimentReplayLedger()
    runner = CampaignBatchExecutor(ledger=ledger, client=DeterministicExperimentClient())

    # Initial execution
    state = runner.execute_reading_batch(batch_fixtures=fixtures, batch_index=1)
    assert state.status == "COMPLETED"
    attempts_initial = len(state.attempts)

    # Resuming completed batch with same state returns idempotent completed state
    resumed_state = runner.execute_reading_batch(
        batch_fixtures=fixtures,
        batch_index=1,
        resume_state=state,
    )
    assert resumed_state.status == "COMPLETED"
    assert len(resumed_state.attempts) == attempts_initial

    # Empty batch raises ValueError
    with pytest.raises(ValueError) as exc_info:
        runner.execute_reading_batch(batch_fixtures=[], batch_index=1)
    assert "requires at least one fixture" in str(exc_info.value)


@pytest.mark.asyncio
async def test_reg_rg10_s01_strict_v2_and_research_publication_isolation():
    """Research excerpts are usable inputs, not production-compliant section passages."""
    fixtures = _build_reading_fixtures(1)
    fixture = fixtures[0]

    # Verify strict reading v2 properties intact
    # 1. Research attempt cannot be published to production
    runner = CampaignBatchExecutor(client=DeterministicExperimentClient())
    state = runner.execute_reading_batch([fixture], batch_index=1)
    assert len(state.attempts) == 3

    for attempt in state.attempts:
        with pytest.raises(ResearchPublicationForbiddenError) as exc_info:
            runner.attempt_to_publish_research_attempt(attempt)
        assert "RESEARCH_PUBLICATION_FORBIDDEN" in str(exc_info.value)

    for attempt in state.attempts:
        assert attempt.execution_status == ExecutionStatus.COMPLETED
        assert attempt.output_availability == OutputAvailability.NORMALIZED

    # The same excerpt must still fail the real production section validator.
    section = create_mock_section_envelope(1, custom_passage=fixture.passage_text)
    context = LoopContext(
        runId=section.run_id,
        scope=IssueScope.SECTION,
        targetArtifactId=section.artifact_id,
        targetArtifactType=ArtifactType.SECTION,
        authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1),
    )
    result = await SectionStructureEvaluator().evaluate(context, section, "rg10-excerpt")
    assert result.status == EvaluationStatus.FAIL
    assert any(
        issue.code == IssueCode.SECTION_WORD_COUNT_OUT_OF_BOUNDS
        and issue.severity == IssueSeverity.CRITICAL
        for issue in result.issues
    )
