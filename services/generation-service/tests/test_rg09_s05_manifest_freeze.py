"""Unit tests for RG09-S05: Final immutable manifest and access separation.

Parent: generation_baseline/prompts/sprints/prompt-sprint-09-05.md
Objective: Sealed manifest hash, assignment roster, checkable evidence references and reviewer access partitions.
Decisive acceptance condition: Hash detects any in-place mutation; owner approve before final campaign; no mixed DEV/FINAL refs.
"""

from __future__ import annotations

import pytest

from app.contracts.research import (
    ExperimentAssignment,
    ExperimentManifest,
    PromptVersionMap,
)
from app.experiment.campaign_manifest import (
    CampaignApprovalRecord,
    CampaignManifestBuilder,
    CampaignNotApprovedError,
    ManifestTamperedError,
    MixedEnvironmentReferenceForbiddenError,
    ReviewerAccessPartitionViolationError,
    SealedCampaignReport,
)
from app.experiment.final_dataset import FinalDatasetRegistry
from app.experiment.preregistration import PreregisteredAnalysisPlan


def _build_test_registry() -> FinalDatasetRegistry:
    registry = FinalDatasetRegistry()
    registry.build_reading_final_tasks()
    registry.build_grammar_final_tasks()
    registry.generate_paired_assignments(attempt_number=1)
    return registry


def test_pos_rg09_s05_manifest_freeze_and_tamper_detection():
    """POS-RG09-S05: Final manifest root SHA256 computed; any in-place mutation detected."""
    registry = _build_test_registry()
    plan = PreregisteredAnalysisPlan()
    builder = CampaignManifestBuilder()

    manifest = builder.build_manifest(registry=registry, analysis_plan=plan)

    # 1. Manifest invariants
    assert manifest.split == "FINAL_EVAL"
    assert manifest.foundation_model_id == "minimax/MiniMax-Text-01"
    assert len(manifest.assignments) == (28 + 28) * 3  # 168 assignments
    assert len(manifest.source_sha256) == 64
    assert len(manifest.analysis_plan_sha256) == 64

    # 2. Compute root hash and verify integrity
    root_hash = builder.compute_manifest_root_hash(manifest)
    assert len(root_hash) == 64
    builder.verify_manifest_integrity(manifest, root_hash)

    # 3. Detect in-place mutation of an assignment
    tampered_manifest = manifest.model_copy(deep=True)
    tampered_manifest.assignments[0] = ExperimentAssignment(
        assignment_id="tampered-asg-id",
        dataset_item_id="tampered-item",
        configuration_id="C",
        attempt_number=1,
    )

    with pytest.raises(ManifestTamperedError) as exc_info:
        builder.verify_manifest_integrity(tampered_manifest, root_hash)
    assert "Manifest root SHA256 mismatch" in str(exc_info.value)

    # 4. Owner approval workflow
    approval = CampaignApprovalRecord(
        approval_id="appr-2026-001",
        approved_by="lead_researcher_admin",
        is_approved=True,
        approval_notes="All 56 tasks verified, disjointness confirmed, preregistration pinned.",
        approval_timestamp="2026-10-15T19:00:00Z",
        approved_manifest_sha256=root_hash,
    )
    builder.enforce_owner_approval(approval, root_hash)


def test_neg_rg09_s05_no_mixed_dev_and_no_unapproved_launch():
    """NEG-RG09-S05: Mixed DEV references and unapproved campaign launches fail closed."""
    builder = CampaignManifestBuilder()
    plan = PreregisteredAnalysisPlan()

    # 1. Reject mixed DEV references in assignments
    registry = _build_test_registry()
    corrupted_assignments = list(registry.assignments)
    corrupted_assignments[0] = ExperimentAssignment(
        assignment_id="dev-pilot-assignment-001",  # FORBIDDEN DEV REFERENCE!
        dataset_item_id="dev-item-001",
        configuration_id="A",
        attempt_number=1,
    )

    with pytest.raises(MixedEnvironmentReferenceForbiddenError) as exc_info:
        builder.validate_environment_separation(corrupted_assignments, registry)
    assert "forbidden DEV or pilot reference" in str(exc_info.value)

    # 2. Reject campaign execution without owner approval
    with pytest.raises(CampaignNotApprovedError) as exc_info:
        builder.enforce_owner_approval(approval=None, manifest_hash="any-hash")
    assert "explicit owner approval has not been granted" in str(exc_info.value)

    # 3. Reject campaign execution with mismatched approval hash
    stale_approval = CampaignApprovalRecord(
        approval_id="appr-stale",
        approved_by="admin",
        is_approved=True,
        approval_notes="Stale approval",
        approval_timestamp="2026-10-14T10:00:00Z",
        approved_manifest_sha256="stale_hash_" + "0" * 53,
    )
    with pytest.raises(CampaignNotApprovedError) as exc_info:
        builder.enforce_owner_approval(stale_approval, manifest_hash="fresh_hash_" + "1" * 53)
    assert "does not match current manifest hash" in str(exc_info.value)


def test_edge_rg09_s05_reviewer_access_partitions():
    """EDGE-RG09-S05: Blind reviewers partitioned from manifest arms and sealed gold."""
    builder = CampaignManifestBuilder()

    # 1. Blind reviewer cannot access manifest arm assignments or sealed gold
    with pytest.raises(ReviewerAccessPartitionViolationError):
        builder.enforce_reviewer_partition("BLIND_REVIEWER", "MANIFEST_ASSIGNMENTS")

    with pytest.raises(ReviewerAccessPartitionViolationError):
        builder.enforce_reviewer_partition("BLIND_REVIEWER", "SEALED_GOLD")

    with pytest.raises(ReviewerAccessPartitionViolationError):
        builder.enforce_reviewer_partition("BLIND_REVIEWER", "ARM_IDENTIFIERS")

    # 2. Research analyst cannot access live sealed gold unblinding
    with pytest.raises(ReviewerAccessPartitionViolationError):
        builder.enforce_reviewer_partition("RESEARCH_ANALYST", "SEALED_GOLD")

    # 3. Allowed targets do not raise
    builder.enforce_reviewer_partition("BLIND_REVIEWER", "BLIND_ITEM_PAYLOAD")
    builder.enforce_reviewer_partition("RESEARCH_ANALYST", "AGGREGATE_METRICS")


def test_reg_rg09_s05_sealed_campaign_report_structure():
    """REG-RG09-S05: Sealed campaign report matches CAMPAIGN_MANIFEST_TEMPLATE.json structure."""
    report = SealedCampaignReport(
        experiment_id="exp-ielts-final-2026",
        dataset_version="v1.0.0",
        split="FINAL_EVAL",
        domain_item_counts={"reading": 28, "grammar": 28},
        total_assignments=168,
        foundation_model_id="minimax/MiniMax-Text-01",
        model_revision="UNKNOWN",
        code_commit_sha="9e81cda156e950d7e705df9effe23e685cc89de5",
        prompt_versions=PromptVersionMap(A="v2.1", B="v2.2", C="v3.0"),
        rubric_hash="a" * 64,
        analysis_plan_hash="b" * 64,
        manifest_root_sha256="c" * 64,
    )

    assert report.state == "SEALED_CAMPAIGN_MANIFEST"
    assert report.domain_item_counts["reading"] == 28
    assert report.domain_item_counts["grammar"] == 28
    assert report.total_assignments == 168
    assert report.human_adjudication_panel["status"] == "BLOCKED_PENDING_EXTERNAL_PANEL"
