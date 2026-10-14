"""Phase-14 Version Promotion Manager and Production Gating.

Implements:
  - Strict Gate Evaluation: Candidate must pass all hard invariants (100%),
    have 0 hard regressions, and achieve required soft thresholds.
  - Hard Gate Precedence (T14-07): If candidate fails any hard gate, promotion
    is REJECTED even if soft metrics (semantic recall, speed, cost) improved.
  - Security Rule: Raw feedback or raw edits cannot trigger auto-deployment
    of production prompts/models. Only CURATED datasets may back promoted artifacts.
  - Safe Version Pinning & Routing (T14-08):
    - New runs receive the new pinned version.
    - In-flight runs and caches retain their existing bound version.
  - Clean Rollback: Restores previous version cleanly with audit log.
"""
from __future__ import annotations

import logging
from dataclasses import dataclass, field
from datetime import datetime, timezone
from enum import Enum
from pathlib import Path
from typing import Any, Sequence

from app.curation.curation import CurationStatus, FeedbackRecord
from app.offline_eval.comparison import (
    GateVerdict,
    PairedComparisonReport,
)
from app.promotion.registry import PromptVersionRegistry, RegistryError

logger = logging.getLogger(__name__)


class PromotionStatus(str, Enum):
    PROMOTED = "PROMOTED"
    REJECTED = "REJECTED"
    ROLLED_BACK = "ROLLED_BACK"


class PromotionError(RuntimeError):
    """Raised on invalid promotion attempts or security policy violations."""


# Authoritative reviewer roles allowed to approve promotions
PROMOTION_ROLES: frozenset[str] = frozenset({"admin", "curator", "release_manager", "lead_evaluator"})


@dataclass(frozen=True)
class PromotionDecision:
    """Audit record for a version promotion attempt."""

    version: str
    previous_version: str
    status: PromotionStatus
    approved_by: str
    approver_role: str
    reason: str
    rejection_reasons: list[str]
    report_id: str | None
    dataset_version: str | None
    decided_at: str
    config_applied: dict[str, Any] = field(default_factory=dict)

    def to_dict(self) -> dict[str, Any]:
        return {
            "version": self.version,
            "previous_version": self.previous_version,
            "status": self.status.value,
            "approved_by": self.approved_by,
            "approver_role": self.approver_role,
            "reason": self.reason,
            "rejection_reasons": self.rejection_reasons,
            "report_id": self.report_id,
            "dataset_version": self.dataset_version,
            "decided_at": self.decided_at,
            "config_applied": self.config_applied,
        }


class VersionPromotionManager:
    """Manages candidate evaluation gates, promotion decisions, and rollbacks."""

    def __init__(
        self,
        registry: PromptVersionRegistry | None = None,
        persist_path: str | Path | None = None,
    ) -> None:
        self.registry = registry or PromptVersionRegistry()
        self.persist_path = Path(persist_path) if persist_path else None
        self._decisions: list[PromotionDecision] = []
    def evaluate_and_promote(
        self,
        *,
        candidate_version: str,
        description: str,
        comparison_report: PairedComparisonReport,
        approver_id: str,
        approver_role: str,
        reason: str,
        dataset_records: Sequence[FeedbackRecord | dict[str, Any]] | None = None,
        dataset_version: str | None = None,
        config: dict[str, Any] | None = None,
    ) -> PromotionDecision:
        """Evaluate candidate against gates and promote if all criteria pass.

        CRITICAL GATE RULES:
          1. If comparison_report.verdict != GateVerdict.PASSED (e.g. hard invariant < 100%),
             promotion MUST BE REJECTED immediately, even if soft metrics improved.
          2. Raw feedback records CANNOT trigger auto-deployment to production. If any
             dataset records are provided and any is in RAW or ANNOTATED state, REJECT.
          3. Approver role must be in PROMOTION_ROLES.
        """
        rejection_reasons: list[str] = []
        prev_version = self.registry.active_pinned_version

        # Rule 1: Role check
        if approver_role not in PROMOTION_ROLES:
            rejection_reasons.append(
                f"Approver role {approver_role!r} is not authorized to promote versions. Required: {sorted(PROMOTION_ROLES)}"
            )

        # Rule 2: Security check - No raw feedback auto-deployment
        if dataset_records:
            self._validate_curated_data_only(dataset_records, rejection_reasons)

        # Rule 3: Evaluation Gate check (Hard Gates have absolute veto)
        if comparison_report.verdict != GateVerdict.PASSED:
            rejection_reasons.append(
                f"Evaluation gate verdict was {comparison_report.verdict.value} (Candidate failed hard/soft gates)"
            )
            rejection_reasons.extend(comparison_report.rejection_reasons)

        if rejection_reasons:
            decision = PromotionDecision(
                version=candidate_version,
                previous_version=prev_version,
                status=PromotionStatus.REJECTED,
                approved_by=approver_id,
                approver_role=approver_role,
                reason=reason,
                rejection_reasons=rejection_reasons,
                report_id=comparison_report.report_id,
                dataset_version=dataset_version,
                decided_at=datetime.now(timezone.utc).isoformat(),
                config_applied=config or {},
            )
            self._decisions.append(decision)
            logger.warning(
                "Version %s REJECTED from promotion: %s",
                candidate_version,
                rejection_reasons,
            )
            return decision

        # All gates passed: Register and Pin staged version
        try:
            self.registry.register_version(
                version=candidate_version,
                description=description,
                registered_by=approver_id,
                config=config or {},
                benchmark_report_id=comparison_report.report_id,
            )
        except RegistryError:
            # Version might already be registered in pre-stage
            pass

        self.registry.pin_active_version(
            candidate_version,
            pinned_by=approver_id,
            reason=f"Promoted: {reason} (Report {comparison_report.report_id})",
        )

        decision = PromotionDecision(
            version=candidate_version,
            previous_version=prev_version,
            status=PromotionStatus.PROMOTED,
            approved_by=approver_id,
            approver_role=approver_role,
            reason=reason,
            rejection_reasons=[],
            report_id=comparison_report.report_id,
            dataset_version=dataset_version,
            decided_at=datetime.now(timezone.utc).isoformat(),
            config_applied=config or {},
        )
        self._decisions.append(decision)
        logger.info("Successfully PROMOTED version %s to active", candidate_version)
        if self.persist_path:
            try:
                self.registry.save(self.persist_path)
            except Exception as exc:
                logger.warning("Failed to auto-persist registry to %s: %s", self.persist_path, exc)
        return decision

    def rollback(
        self,
        target_version: str,
        *,
        operator_id: str,
        operator_role: str,
        reason: str,
    ) -> PromotionDecision:
        """Rollback production active version to target_version."""
        if operator_role not in PROMOTION_ROLES:
            raise PromotionError(
                f"Operator role {operator_role!r} is not authorized for rollback."
            )
        prev = self.registry.active_pinned_version
        self.registry.rollback_to_version(
            target_version,
            rolled_back_by=operator_id,
            reason=reason,
        )
        decision = PromotionDecision(
            version=target_version,
            previous_version=prev,
            status=PromotionStatus.ROLLED_BACK,
            approved_by=operator_id,
            approver_role=operator_role,
            reason=reason,
            rejection_reasons=[],
            report_id=None,
            dataset_version=None,
            decided_at=datetime.now(timezone.utc).isoformat(),
        )
        self._decisions.append(decision)
        if self.persist_path:
            try:
                self.registry.save(self.persist_path)
            except Exception as exc:
                logger.warning("Failed to auto-persist registry to %s: %s", self.persist_path, exc)
        return decision

    def get_decision_history(self) -> list[PromotionDecision]:
        return list(self._decisions)

    def _validate_curated_data_only(
        self,
        records: Sequence[FeedbackRecord | dict[str, Any]],
        rejection_reasons: list[str],
    ) -> None:
        """Verify that zero RAW or ANNOTATED feedback records back this candidate."""
        raw_count = 0
        for r in records:
            if isinstance(r, FeedbackRecord):
                if r.status not in (CurationStatus.CURATED, CurationStatus.REVIEWED):
                    raw_count += 1
            elif isinstance(r, dict):
                st = r.get("status")
                if st not in ("CURATED", "REVIEWED", CurationStatus.CURATED, CurationStatus.REVIEWED):
                    raw_count += 1
        if raw_count > 0:
            rejection_reasons.append(
                f"Security Violation: Found {raw_count} uncurated (RAW/ANNOTATED) records backing candidate. "
                "Raw human edits cannot auto-deploy to production."
            )
