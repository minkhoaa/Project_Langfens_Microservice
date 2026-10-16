"""Phase-level integration test suite for RG09: Final dataset and preregistration freeze.

Parent: generation_baseline/prompts/prompt-phase-09.md
Objective: 25-40 Reading and 25-40 Grammar paired input items; gold isolation and immutable campaign manifest.
Decisive acceptance condition: Family-disjoint datasets; evaluator, endpoints, analysis, exclusions and resource policies frozen.

Integration verification:
1. PHASE-RG09-01: End-to-end dataset construction (28 Reading + 28 Grammar) with 168 paired assignments.
2. PHASE-RG09-02: Strict family-disjointness audit against DEV, CALIBRATION, HOLDOUT, G15, and quarantined sets.
3. PHASE-RG09-03: Sealed gold vault and blind review export ensuring reviewers cannot infer arm identities.
4. PHASE-RG09-04: Preregistered statistical analysis plan pinned by SHA256; post-hoc endpoint switching rejected.
5. PHASE-RG09-05: Foundation model minimax/MiniMax-Text-01, prompt hashes, and safety timeout/budgets frozen.
6. PHASE-RG09-06: Immutable campaign manifest sealed with root SHA256; owner approval gate and reviewer partitions enforced.
"""

from __future__ import annotations

import hashlib
import pytest

from app.contracts.research import (
    ExecutionStatus,
    ExperimentAssignment,
    GenerationResult,
    NeutralOutput,
    NeutralQuestion,
    NeutralQuestionGroup,
    OutputAvailability,
    PromptVersionMap,
    StandaloneGroupType,
)
from app.experiment.blind_review import (
    BlindReviewManager,
    GoldSmugglingForbiddenError,
    ReviewerVerdictSubmission,
    SealedGoldAccessForbiddenError,
    SealedGoldVault,
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
from app.experiment.final_dataset import (
    FORBIDDEN_DEV_CALIBRATION_FAMILIES,
    FinalDatasetRegistry,
    SourceFamilyOverlapError,
)
from app.experiment.freeze_manifest import (
    OperationTimeoutError,
    ProviderFallbackForbiddenError,
    ProviderFreezeManager,
    ResourceBudgetExceededError,
    ResourceSafetyPolicy,
    SamplingParameters,
    SamplingParameterTamperedError,
)
from app.experiment.preregistration import (
    AnalysisPlanTamperedError,
    PostHocEndpointSwitchingForbiddenError,
    PreregisteredAnalysisPlan,
)


def test_phase_rg09_01_full_paired_dataset_freeze():
    """PHASE-RG09-01: 28 Reading + 28 Grammar items constructed with balanced strata and 168 paired assignments."""
    registry = FinalDatasetRegistry()
    reading_tasks = registry.build_reading_final_tasks()
    grammar_tasks = registry.build_grammar_final_tasks()
    assignments = registry.generate_paired_assignments(attempt_number=1)

    assert len(reading_tasks) == 28
    assert len(grammar_tasks) == 28
    assert len(assignments) == 56 * 3  # Exactly 168 assignments
    assert registry.is_frozen is True

    # Validate batch partition rule (FINAL_BATCH_RULES.md: max 5 items per batch)
    batches = registry.partition_into_batches(max_items_per_batch=5)
    assert len(batches) == 12
    for b in batches:
        assert len(b) <= 5


def test_phase_rg09_02_strict_family_disjointness():
    """PHASE-RG09-02: Zero source-family overlap between FINAL and DEV/CALIBRATION/HOLDOUT/G15/quarantined."""
    registry = FinalDatasetRegistry()
    reading_tasks = registry.build_reading_final_tasks()
    grammar_tasks = registry.build_grammar_final_tasks()

    final_families = {t.source.source_family for t in reading_tasks + grammar_tasks}
    assert len(final_families) == 14  # 7 reading + 7 grammar

    # Disjointness check against all known prior families
    overlap = final_families.intersection(FORBIDDEN_DEV_CALIBRATION_FAMILIES)
    assert len(overlap) == 0, f"Found leaked source families: {overlap}"


def test_phase_rg09_03_sealed_gold_and_blind_review_pipeline():
    """PHASE-RG09-03: Sealed gold vault isolates ground-truth; blind review export strips all arm identifiers."""
    manager = BlindReviewManager()
    assignment = ExperimentAssignment(
        assignment_id="final-reading-001__arm_C__att1",
        dataset_item_id="final-reading-001",
        configuration_id="C",
        attempt_number=1,
    )
    neutral = NeutralOutput(
        context_text="Plant biology experiments under LED photoperiods show controlled biomass accumulation.",
        question_groups=[NeutralQuestionGroup(group_id="g1", question_ids=["q1"])],
        questions=[
            NeutralQuestion(
                question_id="q1",
                question_type=StandaloneGroupType.TFNG,
                text="Photoperiods influence plant biomass.",
                options=["TRUE", "FALSE", "NOT GIVEN"],
                instructions="Answer TRUE, FALSE, or NOT GIVEN.",
            )
        ],
    )
    result = GenerationResult(
        run_id="run-c-101",
        dataset_item_id="final-reading-001",
        configuration_id="C",
        task_type="READING_SINGLE_PASSAGE",
        execution_status=ExecutionStatus.COMPLETED,
        output_availability=OutputAvailability.NORMALIZED,
        generated_content=neutral,
        private_answer_ref="secret-ans-ref",
    )

    blind_item = manager.export_blind_review_item(
        assignment=assignment,
        generation_result=result,
        domain="READING",
        gold_answers={"q1": "TRUE"},
    )

    # 1. Arm C and run_id completely decoupled from reviewer payload
    assert "arm_C" not in blind_item.blind_item_id
    assert "run-c" not in blind_item.blind_item_id

    # 2. Vault stores mapping and seal locks it
    vault = manager.vault
    root_hash = vault.seal_vault()
    assert len(root_hash) == 64

    # 3. Only auditor can unblind mapping
    mapping = vault.get_mapping(blind_item.blind_item_id, actor_role="EXPERIMENT_AUDITOR")
    assert mapping.actual_configuration_id == "C"

    with pytest.raises(SealedGoldAccessForbiddenError):
        vault.get_mapping(blind_item.blind_item_id, actor_role="BLIND_REVIEWER")

    # 4. Gold smuggling in input is detected and blocked
    with pytest.raises(GoldSmugglingForbiddenError):
        manager.assert_no_gold_in_input({"task": "sample", "_gold_answer": "TRUE"})


def test_phase_rg09_04_statistical_preregistration_freeze():
    """PHASE-RG09-04: Primary endpoint pinned; paired contrasts and 95% CIs execute deterministically."""
    plan = PreregisteredAnalysisPlan()

    assert plan.primary_endpoint == "independent_final_PASS / all_assigned"
    assert len(plan.plan_sha256) == 64
    plan.assert_plan_unmodified(plan.plan_sha256)

    # Attempted post-hoc switch raises error
    with pytest.raises(PostHocEndpointSwitchingForbiddenError):
        plan.switch_endpoint("post_hoc_endpoint")

    # Simulated paired evaluation
    paired_data = {
        f"item-{i}": {"A": 0.5, "B": 0.6, "C": 0.8}
        for i in range(28)
    }
    result = plan.compute_domain_contrasts("READING", paired_data)
    assert result.total_assigned == 28
    assert len(result.contrasts) == 2
    assert result.contrasts[0].ci_lower <= result.contrasts[0].point_estimate <= result.contrasts[0].ci_upper


def test_phase_rg09_05_provider_prompts_and_budget_freeze():
    """PHASE-RG09-05: Foundation model minimax/MiniMax-Text-01, prompt hashes, and budgets frozen."""
    manager = ProviderFreezeManager(
        foundation_model_id="minimax/MiniMax-Text-01",
        model_revision="UNKNOWN",
    )

    # 1. Pinned model validation
    manager.validate_provider_and_model("minimax/MiniMax-Text-01")
    with pytest.raises(ProviderFallbackForbiddenError):
        manager.validate_provider_and_model("groq/llama-3.3-70b-versatile")

    # 2. Frozen prompts have 64-char SHA256 hashes
    for arm in ("A", "B", "C"):
        p = manager.get_prompt_spec(arm)
        assert len(p.template_sha256) == 64

    # 3. UNLIMITED cap does not bypass timeout or token ceilings
    with pytest.raises(OperationTimeoutError):
        manager.enforce_resource_safety(elapsed_seconds=70.0, tokens_consumed=1000, unlimited_cap_requested=True)

    with pytest.raises(ResourceBudgetExceededError):
        manager.enforce_resource_safety(elapsed_seconds=10.0, tokens_consumed=9000, unlimited_cap_requested=True)


def test_phase_rg09_06_sealed_manifest_and_access_partitions():
    """PHASE-RG09-06: Manifest sealed with root SHA256; owner approval and reviewer partitions enforced."""
    registry = FinalDatasetRegistry()
    registry.build_reading_final_tasks()
    registry.build_grammar_final_tasks()
    registry.generate_paired_assignments(attempt_number=1)

    plan = PreregisteredAnalysisPlan()
    builder = CampaignManifestBuilder()
    manifest = builder.build_manifest(registry=registry, analysis_plan=plan)

    # 1. Compute root hash and verify tamper detection
    root_hash = builder.compute_manifest_root_hash(manifest)
    assert len(root_hash) == 64
    builder.verify_manifest_integrity(manifest, root_hash)

    tampered = manifest.model_copy(deep=True)
    tampered.assignments[0] = ExperimentAssignment(
        assignment_id="tampered-asg",
        dataset_item_id="tampered-item",
        configuration_id="A",
        attempt_number=1,
    )
    with pytest.raises(ManifestTamperedError):
        builder.verify_manifest_integrity(tampered, root_hash)

    # 2. Owner approval gate
    approval = CampaignApprovalRecord(
        approval_id="appr-final-2026",
        approved_by="lead_investigator",
        is_approved=True,
        approval_notes="Dataset, preregistration, and manifest frozen and sealed.",
        approval_timestamp="2026-10-15T19:30:00Z",
        approved_manifest_sha256=root_hash,
    )
    builder.enforce_owner_approval(approval, root_hash)

    # 3. Reviewer access partitions
    with pytest.raises(ReviewerAccessPartitionViolationError):
        builder.enforce_reviewer_partition("BLIND_REVIEWER", "MANIFEST_ASSIGNMENTS")

    with pytest.raises(ReviewerAccessPartitionViolationError):
        builder.enforce_reviewer_partition("BLIND_REVIEWER", "SEALED_GOLD")

    # 4. Sealed campaign report structure
    report = SealedCampaignReport(
        experiment_id=manifest.experiment_id,
        dataset_version=manifest.dataset_version,
        split="FINAL_EVAL",
        domain_item_counts={"reading": 28, "grammar": 28},
        total_assignments=168,
        foundation_model_id=manifest.foundation_model_id,
        model_revision="UNKNOWN",
        code_commit_sha=manifest.code_commit_sha,
        prompt_versions=manifest.prompt_versions,
        rubric_hash=hashlib.sha256(b"rubric-qgeval-v2.0").hexdigest(),
        analysis_plan_hash=manifest.analysis_plan_sha256,
        manifest_root_sha256=root_hash,
        approval_record=approval,
    )
    assert report.state == "SEALED_CAMPAIGN_MANIFEST"
    assert report.human_adjudication_panel["status"] == "BLOCKED_PENDING_EXTERNAL_PANEL"
