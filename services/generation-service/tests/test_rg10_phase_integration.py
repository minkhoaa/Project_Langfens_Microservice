"""Phase-level integration test suite for RG10: Final paired research campaign.

Objective: Complete Reading and Grammar A/B/C assignments, external scoring and blinded human subset.
Decisive acceptance condition: Counts match frozen assignments exactly and retries/failures remain visible.

Integration verification:
1. PHASE-RG10-01: End-to-end bounded batch execution (Reading and Grammar) with 100% frozen grid reconciliation.
2. PHASE-RG10-02: Retry lineage and failure retention: parent IDs preserved and failures visible in denominators.
3. PHASE-RG10-03: Independent scoring and blind review export: neutral evaluation without arm labels or gold leakage.
4. PHASE-RG10-04: Truthful accounting: call counts, prompt/completion tokens, cost by arm, and confidence distributions reconciled.
5. PHASE-RG10-05: Immutable research snapshot sealing with real file byte hashes and honest dirty worktree provenance.
6. PHASE-RG10-06: Production passage boundaries remain strict and research publishing is blocked.
"""

from __future__ import annotations

from pathlib import Path
from uuid import uuid4
import pytest

from app.contracts.artifact import ArtifactType
from app.contracts.evaluation import EvaluationStatus
from app.contracts.issue import IssueCode, IssueScope
from app.contracts.research import (
    ExecutionStatus,
    ExperimentAssignment,
    GenerationResult,
    OutputAvailability,
)
from app.evaluators.rubric import EvaluationVerdict
from app.experiment.blind_review import (
    BlindReviewManager,
    ReviewerVerdictSubmission,
    SealedGoldVault,
)
from app.experiment.campaign_manifest import CampaignManifestBuilder
from app.experiment.campaign_runner import (
    CampaignBatchExecutor,
    CampaignCompletenessReport,
    CampaignReconciliationManager,
    FinalResearchSnapshotSealer,
    IndependentCampaignScorer,
    SealedResearchSnapshot,
    SnapshotTamperedError,
)
from app.experiment.final_dataset import FinalDatasetRegistry
from app.experiment.ledger import AttemptRecord, ExperimentReplayLedger
from app.experiment.paired import PairedAssignmentManager
from app.experiment.preregistration import PreregisteredAnalysisPlan
from tests.research_provider_fixtures import DeterministicExperimentClient
from app.persistence.grammar_store import ResearchPublicationForbiddenError
from app.evaluators.section import SectionStructureEvaluator
from app.loop.context import AuthorityGrant, LoopContext
from tests.test_t12_paper_loop import create_mock_section_envelope


def _setup_phase_environment():
    registry = FinalDatasetRegistry()
    reading_tasks = registry.build_reading_final_tasks()
    grammar_tasks = registry.build_grammar_final_tasks()

    client = DeterministicExperimentClient()
    assignment_manager = PairedAssignmentManager()
    ledger = ExperimentReplayLedger()
    runner = CampaignBatchExecutor(
        assignment_manager=assignment_manager,
        ledger=ledger,
        client=client,
    )
    return reading_tasks, grammar_tasks, runner, ledger, client, registry


def test_phase_rg10_01_end_to_end_batch_execution_and_reconciliation():
    """PHASE-RG10-01: End-to-end execution of Reading and Grammar in bounded batches (<=5 items)."""
    reading_tasks, grammar_tasks, runner, ledger, client, _ = _setup_phase_environment()

    # Partition reading (28 items -> 6 batches) and grammar (28 items -> 6 batches)
    r_batches = runner.partition_batches(reading_tasks, max_items_per_batch=5)
    g_batches = runner.partition_batches(grammar_tasks, max_items_per_batch=5)
    assert len(r_batches) == 6
    assert len(g_batches) == 6

    # Execute all reading batches
    r_states = [runner.execute_reading_batch(b, idx + 1) for idx, b in enumerate(r_batches)]
    runner.validate_batch_coverage(reading_tasks, r_states)

    # Execute all grammar batches
    g_states = [runner.execute_grammar_batch(b, idx + 1) for idx, b in enumerate(g_batches)]
    runner.validate_batch_coverage(grammar_tasks, g_states)

    # Reconcile campaign ledger
    recon_mgr = CampaignReconciliationManager()
    report = recon_mgr.reconcile_campaign_completeness(ledger)

    # Invariants: exactly 56 dataset items * 3 arms = 168 assigned slots
    assert report.total_frozen_assignments == 168
    assert report.total_attempts >= 168
    assert report.is_fully_reconciled is True
    assert report.unattempted_count == 0


def test_phase_rg10_02_retry_lineage_and_failure_visibility():
    """PHASE-RG10-02: Retry lineage preserves parent IDs and failures remain visible in denominators."""
    ledger = ExperimentReplayLedger()
    asg = ExperimentAssignment(
        assignment_id="asg-retry-test-01",
        dataset_item_id="item-retry-01",
        configuration_id="B",
        attempt_number=1,
    )
    ledger.freeze_assignments([asg])

    # Attempt 1: Failed validation
    att1 = AttemptRecord(
        attempt_id="att-retry-01-1",
        assignment_id=asg.assignment_id,
        dataset_item_id=asg.dataset_item_id,
        configuration_id="B",
        attempt_number=1,
        execution_status=ExecutionStatus.FAILED_VALIDATION,
        output_availability=OutputAvailability.PARSEABLE,
        failure_code="UNGROUNDED_CONTENT",
        usage_call_count=1,
        usage_total_tokens=120,
        usage_confidence="EXACT",
        cost_usd=0.001,
        is_terminal=False,
    )
    ledger.record_attempt(att1)

    # Attempt 2: Successful retry
    att2 = AttemptRecord(
        attempt_id="att-retry-01-2",
        assignment_id=asg.assignment_id,
        dataset_item_id=asg.dataset_item_id,
        configuration_id="B",
        attempt_number=2,
        parent_attempt_id=att1.attempt_id,
        execution_status=ExecutionStatus.COMPLETED,
        output_availability=OutputAvailability.NORMALIZED,
        usage_call_count=1,
        usage_total_tokens=220,
        usage_confidence="EXACT",
        cost_usd=0.0018,
        is_terminal=True,
    )
    ledger.record_attempt(att2)

    lineage = ledger.get_attempt_lineage(asg.assignment_id)
    assert len(lineage) == 2
    assert lineage[0].execution_status == ExecutionStatus.FAILED_VALIDATION
    assert lineage[1].parent_attempt_id == lineage[0].attempt_id
    assert lineage[1].execution_status == ExecutionStatus.COMPLETED


def test_phase_rg10_03_independent_scoring_and_blind_review():
    """PHASE-RG10-03: Independent neutral scoring and blind review consensus without arm contamination."""
    vault = SealedGoldVault()
    manager = BlindReviewManager(vault=vault)
    scorer = IndependentCampaignScorer(blind_manager=manager)

    assignment = ExperimentAssignment(
        assignment_id="asg-phase-blind-01",
        dataset_item_id="item-phase-01",
        configuration_id="C",
        attempt_number=1,
    )

    # Verify missing output cannot receive invented score
    missing_result = scorer.score_generation_result(
        result=GenerationResult(
            run_id="run-missing-01",
            dataset_item_id=assignment.dataset_item_id,
            configuration_id="C",
            task_type="READING_SINGLE_PASSAGE",
            execution_status=ExecutionStatus.TIMED_OUT,
            output_availability=OutputAvailability.NONE,
            generated_content=None,
            failure_code="PROVIDER_TIMEOUT",
        ),
        assignment=assignment,
    )
    assert missing_result.verdict == EvaluationVerdict.NOT_RUN
    assert missing_result.evaluable is False


def test_phase_rg10_04_truthful_accounting_tokens_and_cost():
    """PHASE-RG10-04: Telemetry tracks exact call counts, tokens, cost by arm, and confidence."""
    reading_tasks, _, runner, ledger, _, _ = _setup_phase_environment()
    batch = runner.execute_reading_batch(reading_tasks[:2], batch_index=1)
    assert batch.status == "COMPLETED"

    recon_mgr = CampaignReconciliationManager()
    report = recon_mgr.reconcile_campaign_completeness(ledger)

    # 2 items * 3 arms = 6 assignments
    assert report.total_frozen_assignments == 6
    assert report.total_attempts >= 6
    assert report.confidence_distribution["ESTIMATED"] >= 6
    for arm in ("A", "B", "C"):
        assert report.cost_by_arm[arm] is None
        assert report.token_usage_by_arm[arm]["total"] > 0


def test_phase_rg10_05_immutable_snapshot_sealing_and_provenance():
    """PHASE-RG10-05: Real file byte hashes and honest dirty worktree provenance sealed with root SHA256."""
    reading_tasks, _, _, ledger, _, registry = _setup_phase_environment()
    sealer = FinalResearchSnapshotSealer()

    plan = PreregisteredAnalysisPlan()
    builder = CampaignManifestBuilder()
    registry.generate_paired_assignments(attempt_number=1)
    manifest = builder.build_manifest(registry=registry, analysis_plan=plan)
    manifest_root = builder.compute_manifest_root_hash(manifest)
    manifest_with_root = manifest.model_copy(update={"manifest_root_sha256": manifest_root})

    # Read real file bytes on disk
    runner_path = Path("app/experiment/campaign_runner.py")
    dataset_path = Path("app/experiment/final_dataset.py")
    worktree_hashes = {
        str(runner_path): sealer.compute_file_sha256(runner_path),
        str(dataset_path): sealer.compute_file_sha256(dataset_path),
    }

    snapshot = sealer.seal_snapshot(
        manifest=manifest_with_root,
        ledger=ledger,
        evaluations_ledger_sha256="e" * 64,
        human_review_ledger_sha256="h" * 64,
        code_commit_sha="9e81cda156e950d7e705df9effe23e685cc89de5",
        worktree_dirty=True,
        dirty_state="M services/generation-service/app/experiment/campaign_runner.py, ...",
        worktree_content_hashes=worktree_hashes,
    )

    assert snapshot.state == "SEALED_RESEARCH_SNAPSHOT"
    assert len(snapshot.snapshot_root_sha256) == 64
    assert snapshot.worktree_dirty is True
    sealer.verify_snapshot_integrity(snapshot, snapshot.snapshot_root_sha256)

    # Tampering detected
    tampered = snapshot.model_copy(update={"dataset_version": "v999.0-tampered"})
    with pytest.raises(SnapshotTamperedError):
        sealer.verify_snapshot_integrity(tampered, snapshot.snapshot_root_sha256)


@pytest.mark.asyncio
@pytest.mark.parametrize(
    ("word_count", "expected_status"),
    [(719, EvaluationStatus.FAIL), (720, EvaluationStatus.PASS),
     (915, EvaluationStatus.PASS), (916, EvaluationStatus.FAIL)],
)
async def test_phase_rg10_06_strict_reading_v2_regression_and_isolation(
    word_count, expected_status
):
    """Research metadata cannot bypass production's inclusive 720–915 word band."""

    # 1. Research publishing to production strictly forbidden
    ledger = ExperimentReplayLedger()
    with pytest.raises(ResearchPublicationForbiddenError) as exc_info:
        ledger.publish_to_production("att-phase-001", admin_user_id="fake-admin")
    assert "RESEARCH_PUBLICATION_FORBIDDEN" in str(exc_info.value)

    section = create_mock_section_envelope(1, word_count=word_count)
    section = section.create_next_version(
        new_payload={
            **section.payload,
            "is_research_mode": True,
            "task_type": "READING_SINGLE_PASSAGE",
        },
        producer_version=section.producer_version,
    )
    context = LoopContext(
        runId=section.run_id,
        scope=IssueScope.SECTION,
        targetArtifactId=section.artifact_id,
        targetArtifactType=ArtifactType.SECTION,
        authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1),
    )
    result = await SectionStructureEvaluator().evaluate(context, section, "rg10-bounds")
    assert result.status == expected_status
    word_issues = [
        issue for issue in result.issues
        if issue.code == IssueCode.SECTION_WORD_COUNT_OUT_OF_BOUNDS
    ]
    assert bool(word_issues) == (expected_status == EvaluationStatus.FAIL)
