"""Unit tests for RG10-S05: Seal final research snapshot.

Parent: generation_baseline/prompts/sprints/prompt-sprint-10-05.md
Objective: Immutable hashes for results, evals, human labels, code/config/model/source and reproducibility metadata.
Decisive acceptance condition: Any changed content requires explicit new version/campaign, not overwritten hash; provenance honest.
"""

from __future__ import annotations

from pathlib import Path
import pytest

from app.contracts.research import (
    ExecutionStatus,
    ExperimentAssignment,
    OutputAvailability,
)
from app.experiment.campaign_manifest import CampaignManifestBuilder
from app.experiment.campaign_runner import (
    ConcealedMissingRowsForbiddenError,
    FalseProvenanceClaimError,
    FinalResearchSnapshotSealer,
    SealedResearchSnapshot,
    SnapshotTamperedError,
)
from app.experiment.final_dataset import FinalDatasetRegistry
from app.experiment.ledger import AttemptRecord, ExperimentReplayLedger
from app.experiment.preregistration import PreregisteredAnalysisPlan
from app.persistence.grammar_store import ResearchPublicationForbiddenError


def _build_test_environment():
    registry = FinalDatasetRegistry()
    registry.build_reading_final_tasks()
    registry.build_grammar_final_tasks()
    registry.generate_paired_assignments(attempt_number=1)

    plan = PreregisteredAnalysisPlan()
    builder = CampaignManifestBuilder()
    manifest = builder.build_manifest(registry=registry, analysis_plan=plan)

    # Compute genuine manifest root SHA256
    manifest_root_hash = builder.compute_manifest_root_hash(manifest)
    manifest_with_root = manifest.model_copy(update={"manifest_root_sha256": manifest_root_hash})

    ledger = ExperimentReplayLedger()
    ledger.freeze_assignments(manifest.assignments[:30])

    for asg in manifest.assignments[:30]:
        att = AttemptRecord(
            attempt_id=f"att-{asg.assignment_id}-1",
            assignment_id=asg.assignment_id,
            dataset_item_id=asg.dataset_item_id,
            configuration_id=asg.configuration_id,
            attempt_number=1,
            execution_status=ExecutionStatus.COMPLETED,
            output_availability=OutputAvailability.NORMALIZED,
            usage_call_count=1,
            usage_total_tokens=300,
            usage_confidence="EXACT",
            cost_usd=0.0015,
            is_terminal=True,
        )
        ledger.record_attempt(att)

    return manifest_with_root, ledger


def test_pos_rg10_s05_seal_final_research_snapshot_and_tamper_detection():
    """POS-RG10-S05: Immutable snapshot sealed with real hashes and honest dirty worktree provenance."""
    manifest, ledger = _build_test_environment()
    sealer = FinalResearchSnapshotSealer()

    # Compute real file hashes from actual code on disk
    runner_path = Path("app/experiment/campaign_runner.py")
    dataset_path = Path("app/experiment/final_dataset.py")
    worktree_hashes = {
        str(runner_path): sealer.compute_file_sha256(runner_path),
        str(dataset_path): sealer.compute_file_sha256(dataset_path),
    }

    dirty_state_str = "M app/experiment/campaign_runner.py, M app/experiment/ledger.py"

    snapshot = sealer.seal_snapshot(
        manifest=manifest,
        ledger=ledger,
        evaluations_ledger_sha256="e" * 64,
        human_review_ledger_sha256="h" * 64,
        code_commit_sha="9e81cda156e950d7e705df9effe23e685cc89de5",
        worktree_dirty=True,
        dirty_state=dirty_state_str,
        worktree_content_hashes=worktree_hashes,
    )

    # 1. Snapshot integrity invariants
    assert snapshot.state == "SEALED_RESEARCH_SNAPSHOT"
    assert len(snapshot.snapshot_root_sha256) == 64
    assert len(snapshot.results_ledger_sha256) == 64
    assert snapshot.code_commit_sha == "9e81cda156e950d7e705df9effe23e685cc89de5"
    assert snapshot.worktree_dirty is True
    assert snapshot.dirty_state == dirty_state_str
    assert len(snapshot.worktree_content_hashes) == 2
    assert snapshot.foundation_model_id == "minimax/MiniMax-Text-01"

    # Verify integrity passes on clean snapshot
    sealer.verify_snapshot_integrity(snapshot, snapshot.snapshot_root_sha256)

    # 2. Tampering with any field triggers SnapshotTamperedError
    tampered_snapshot = snapshot.model_copy(update={"code_commit_sha": "tampered-sha-0000000"})
    with pytest.raises(SnapshotTamperedError) as exc_info:
        sealer.verify_snapshot_integrity(tampered_snapshot, snapshot.snapshot_root_sha256)
    assert "Snapshot root SHA256 mismatch" in str(exc_info.value)


def test_neg_rg10_s05_no_concealed_missing_rows_and_false_provenance_claim():
    """NEG-RG10-S05: False provenance claims (clean commit on dirty worktree) and concealed rows fail closed."""
    manifest, ledger = _build_test_environment()
    sealer = FinalResearchSnapshotSealer()

    runner_path = Path("app/experiment/campaign_runner.py")
    worktree_hashes = {str(runner_path): sealer.compute_file_sha256(runner_path)}

    # 1. Falsely claiming clean worktree on dirty state raises FalseProvenanceClaimError
    with pytest.raises(FalseProvenanceClaimError) as exc_info:
        sealer.seal_snapshot(
            manifest=manifest,
            ledger=ledger,
            evaluations_ledger_sha256="e" * 64,
            human_review_ledger_sha256="h" * 64,
            code_commit_sha="9e81cda156e950d7e705df9effe23e685cc89de5",
            worktree_dirty=False,  # Falsely claims clean
            dirty_state="M app/experiment/campaign_runner.py",
            worktree_content_hashes=worktree_hashes,
        )
    assert "False provenance claim" in str(exc_info.value)

    # 2. Concealing missing rows raises ConcealedMissingRowsForbiddenError
    with pytest.raises(ConcealedMissingRowsForbiddenError) as exc_info:
        sealer.enforce_no_concealed_missing_rows(
            accounted_count=len(ledger.get_all_attempts()),
            expected_total_count=168,
        )
    assert "Cannot seal snapshot with concealed or missing assignment rows" in str(exc_info.value)


def test_edge_rg10_s05_missing_manifest_root_or_nonexistent_file():
    """EDGE-RG10-S05: Missing manifest_root_sha256 or nonexistent source file fails closed."""
    manifest, ledger = _build_test_environment()
    sealer = FinalResearchSnapshotSealer()

    # 1. Manifest missing manifest_root_sha256 raises ValueError (no fallback)
    tampered_manifest = manifest.model_copy(update={"manifest_root_sha256": None})
    with pytest.raises(ValueError) as exc_info:
        sealer.seal_snapshot(
            manifest=tampered_manifest,
            ledger=ledger,
            evaluations_ledger_sha256="e" * 64,
            human_review_ledger_sha256="h" * 64,
            code_commit_sha="9e81cda156e950d7e705df9effe23e685cc89de5",
            worktree_dirty=True,
            dirty_state="dirty",
            worktree_content_hashes={"f": "a" * 64},
        )
    assert "manifest_root_sha256 is required" in str(exc_info.value)

    # 2. Nonexistent file hashing raises FileNotFoundError
    with pytest.raises(FileNotFoundError) as exc_info:
        sealer.compute_file_sha256("nonexistent/phantom_file.py")
    assert "Source file not found" in str(exc_info.value)


def test_reg_rg10_s05_research_isolation():
    """REG-RG10-S05: Sealed snapshot cannot be published to production."""
    sealer = FinalResearchSnapshotSealer()
    with pytest.raises(ResearchPublicationForbiddenError) as exc_info:
        sealer.publish_snapshot_to_production("snap-001", admin_user_id="fake-admin")
    assert "RESEARCH_PUBLICATION_FORBIDDEN" in str(exc_info.value)


def test_edge_rg10_s05_manifest_rubric_hash_validation():
    """Manifest with explicit malformed rubric_hash fails closed; valid 64-char hash is bound."""
    manifest, ledger = _build_test_environment()
    sealer = FinalResearchSnapshotSealer()

    class ManifestWithRubricHash:
        def __init__(self, base, rubric_hash):
            for k, v in base.__dict__.items():
                setattr(self, k, v)
            self.rubric_hash = rubric_hash

    malformed = ManifestWithRubricHash(manifest, "not-64-hex")
    with pytest.raises(ValueError, match="rubric_hash on manifest is invalid"):
        sealer.seal_snapshot(
            manifest=malformed,
            ledger=ledger,
            evaluations_ledger_sha256="e" * 64,
            human_review_ledger_sha256="h" * 64,
            code_commit_sha="9e81cda156e950d7e705df9effe23e685cc89de5",
            worktree_dirty=True,
            dirty_state="dirty",
            worktree_content_hashes={"f": "a" * 64},
        )

    valid_hash = "a" * 64
    valid = ManifestWithRubricHash(manifest, valid_hash)
    snapshot = sealer.seal_snapshot(
        manifest=valid,
        ledger=ledger,
        evaluations_ledger_sha256="e" * 64,
        human_review_ledger_sha256="h" * 64,
        code_commit_sha="9e81cda156e950d7e705df9effe23e685cc89de5",
        worktree_dirty=True,
        dirty_state="dirty",
        worktree_content_hashes={"f": "a" * 64},
    )
    assert snapshot.rubric_hash == valid_hash
