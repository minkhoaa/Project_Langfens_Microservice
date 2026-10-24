"""Final immutable campaign manifest and access separation manager (RG09-S05).

Implements normative research obligations from:
- Campaign closure, immutable manifests, reviewer access partitions and audit trails
- generation_baseline/templates/CAMPAIGN_MANIFEST_TEMPLATE.json (Campaign manifest structure)
- generation_baseline/contracts/JSON_SCHEMAS.json ($defs/ExperimentManifest)

Invariants:
1. Sealed manifest hash: Root SHA256 detects any in-place mutation across all assignments and configs.
2. Owner approval gate: Owner approval required before final campaign execution (CampaignNotApprovedError).
3. No mixed DEV/FINAL references: Any DEV or holdout reference in FINAL manifest raises MixedEnvironmentReferenceForbiddenError.
4. Reviewer access partitions: Blind reviewers partitioned from manifest arms and sealed gold.
5. Attributable provenance: Explicit code_commit_sha, dataset hashes, and human panel status recorded.
"""

from __future__ import annotations

import hashlib
import json
from typing import Any, Dict, List, Literal, Optional, Set
from uuid import uuid4

from pydantic import Field, field_validator

from app.contracts.base import CanonicalBaseModel
from app.contracts.research import (
    ExperimentAssignment,
    ExperimentManifest,
    PromptVersionMap,
)
from app.experiment.final_dataset import (
    FORBIDDEN_DEV_CALIBRATION_FAMILIES,
    FinalDatasetRegistry,
)
from app.experiment.freeze_manifest import ProviderFreezeManager
from app.experiment.preregistration import PreregisteredAnalysisPlan


class ManifestTamperedError(RuntimeError):
    """Raised when sealed manifest hash does not match expected integrity hash."""


class MixedEnvironmentReferenceForbiddenError(RuntimeError):
    """Raised when DEV or holdout references are found in the FINAL campaign manifest."""


class CampaignNotApprovedError(RuntimeError):
    """Raised when a final campaign is initiated without verified owner approval."""


class ReviewerAccessPartitionViolationError(RuntimeError):
    """Raised when a reviewer or unauthorized role attempts to access partitioned manifest data."""


class CampaignApprovalRecord(CanonicalBaseModel):
    """Cryptographic record of explicit owner approval for campaign freeze."""

    approval_id: str
    approved_by: str
    is_approved: bool
    approval_notes: str
    approval_timestamp: str
    approved_manifest_sha256: str


class SealedCampaignReport(CanonicalBaseModel):
    """Summary record matching CAMPAIGN_MANIFEST_TEMPLATE.json."""

    state: Literal["SEALED_CAMPAIGN_MANIFEST"] = "SEALED_CAMPAIGN_MANIFEST"
    experiment_id: str
    dataset_version: str
    split: Literal["FINAL_EVAL"] = "FINAL_EVAL"
    domain_item_counts: Dict[str, int]
    total_assignments: int
    arms: List[str] = Field(default_factory=lambda: ["A", "B", "C"])
    foundation_model_id: str
    model_revision: Optional[str] = "UNKNOWN"
    code_commit_sha: str
    prompt_versions: PromptVersionMap
    rubric_hash: str
    analysis_plan_hash: str
    manifest_root_sha256: str
    missing_data_rule: str = "missing/failed/abstained not counted primary PASS"
    approval_record: Optional[CampaignApprovalRecord] = None
    human_adjudication_panel: Dict[str, str] = Field(
        default_factory=lambda: {
            "status": "BLOCKED_PENDING_EXTERNAL_PANEL",
            "reason": "Expert external panel not present in local workspace; independent human review remains required",
        }
    )


class CampaignManifestBuilder:
    """Builds, validates, seals, and verifies the final immutable experiment manifest."""

    def __init__(
        self,
        experiment_id: str = "exp-ielts-rq2-final-2026",
        dataset_version: str = "v1.0.0-final",
        code_commit_sha: str = "9e81cda156e950d7e705df9effe23e685cc89de5",
        foundation_model_id: str = "minimax/MiniMax-Text-01",
        rubric_version: str = "rubric-qgeval-v2.0",
    ) -> None:
        self.experiment_id = experiment_id
        self.dataset_version = dataset_version
        self.code_commit_sha = code_commit_sha
        self.foundation_model_id = foundation_model_id
        self.rubric_version = rubric_version

    def build_manifest(
        self,
        registry: FinalDatasetRegistry,
        analysis_plan: PreregisteredAnalysisPlan,
        prompt_versions: Optional[PromptVersionMap] = None,
    ) -> ExperimentManifest:
        """Constructs a canonical ExperimentManifest from frozen registry and analysis plan."""
        reading_tasks = registry.reading_tasks
        grammar_tasks = registry.grammar_tasks

        if not reading_tasks or not grammar_tasks:
            raise ValueError("Registry must contain both reading and grammar tasks before manifest build")

        assignments = registry.assignments
        if not assignments:
            raise ValueError("Registry has no generated paired assignments")

        # Validate no mixed environment references
        self.validate_environment_separation(assignments, registry)

        # Compute source_sha256 across all task sources
        all_tasks = reading_tasks + grammar_tasks
        task_source_hashes = sorted([t.source.source_sha256 for t in all_tasks])
        combined_source_sha = hashlib.sha256(":".join(task_source_hashes).encode("utf-8")).hexdigest()

        pv = prompt_versions or PromptVersionMap(
            A="v2.1-baseline",
            B="v2.2-grounded",
            C="v3.0-adversarial",
        )

        manifest = ExperimentManifest(
            experiment_id=self.experiment_id,
            dataset_version=self.dataset_version,
            split="FINAL_EVAL",
            source_sha256=combined_source_sha,
            code_commit_sha=self.code_commit_sha,
            foundation_model_id=self.foundation_model_id,
            prompt_versions=pv,
            rubric_version=self.rubric_version,
            assignments=assignments,
            primary_endpoint=analysis_plan.primary_endpoint,
            analysis_plan_sha256=analysis_plan.plan_sha256,
        )
        return manifest

    def validate_environment_separation(
        self,
        assignments: List[ExperimentAssignment],
        registry: FinalDatasetRegistry,
    ) -> None:
        """Enforces that no DEV, pilot, or calibration references are mixed into the FINAL manifest."""
        all_tasks = registry.reading_tasks + registry.grammar_tasks
        for task in all_tasks:
            fam = task.source.source_family
            if fam in FORBIDDEN_DEV_CALIBRATION_FAMILIES or any(
                forbidden in fam for forbidden in FORBIDDEN_DEV_CALIBRATION_FAMILIES
            ):
                raise MixedEnvironmentReferenceForbiddenError(
                    f"FINAL manifest task {task.dataset_item_id} contains forbidden DEV/calibration family '{fam}'"
                )

        for asg in assignments:
            if "dev" in asg.assignment_id.lower() or "pilot" in asg.assignment_id.lower():
                raise MixedEnvironmentReferenceForbiddenError(
                    f"Assignment {asg.assignment_id} contains forbidden DEV or pilot reference"
                )

    def compute_manifest_root_hash(self, manifest: ExperimentManifest) -> str:
        """Computes deterministic root SHA256 of all manifest assignments, hashes, and configurations."""
        assignment_lines = sorted(
            [f"{a.assignment_id}:{a.dataset_item_id}:{a.configuration_id}:{a.attempt_number}" for a in manifest.assignments]
        )
        canonical_str = (
            f"{manifest.experiment_id}:{manifest.dataset_version}:{manifest.split}:"
            f"{manifest.source_sha256}:{manifest.code_commit_sha}:{manifest.foundation_model_id}:"
            f"{manifest.prompt_versions.A}:{manifest.prompt_versions.B}:{manifest.prompt_versions.C}:"
            f"{manifest.rubric_version}:{manifest.primary_endpoint}:{manifest.analysis_plan_sha256}:"
            f"{hashlib.sha256(':'.join(assignment_lines).encode('utf-8')).hexdigest()}"
        )
        return hashlib.sha256(canonical_str.encode("utf-8")).hexdigest()

    def verify_manifest_integrity(self, manifest: ExperimentManifest, expected_root_hash: str) -> None:
        """Verifies that the manifest has not been tampered with or modified in-place."""
        computed_hash = self.compute_manifest_root_hash(manifest)
        if computed_hash != expected_root_hash:
            raise ManifestTamperedError(
                f"Manifest root SHA256 mismatch. Expected '{expected_root_hash}', computed '{computed_hash}'"
            )

    def enforce_owner_approval(self, approval: Optional[CampaignApprovalRecord], manifest_hash: str) -> None:
        """Guarantees owner has formally approved the campaign manifest before launch."""
        if not approval or not approval.is_approved:
            raise CampaignNotApprovedError(
                "Final campaign launch is BLOCKED: explicit owner approval has not been granted."
            )
        if approval.approved_manifest_sha256 != manifest_hash:
            raise CampaignNotApprovedError(
                f"Owner approval hash '{approval.approved_manifest_sha256}' does not match "
                f"current manifest hash '{manifest_hash}'. Re-approval required."
            )

    def enforce_reviewer_partition(self, actor_role: str, access_target: str) -> None:
        """Partitions reviewer access, preventing blind reviewers from inspecting unblinded data."""
        if actor_role == "BLIND_REVIEWER":
            if access_target in ("MANIFEST_ASSIGNMENTS", "SEALED_GOLD", "ARM_IDENTIFIERS", "PRIVATE_ANSWERS"):
                raise ReviewerAccessPartitionViolationError(
                    f"Role '{actor_role}' is partitioned from target '{access_target}'."
                )
        elif actor_role == "RESEARCH_ANALYST":
            if access_target in ("SEALED_GOLD", "LIVE_UNBLINDING"):
                raise ReviewerAccessPartitionViolationError(
                    f"Role '{actor_role}' is not authorized to access '{access_target}'."
                )
