"""Section Coverage Evaluator for Langfens Loop Engine V2 (Phase 15 / P15-repair-closure).

Layering decision (P11-02 vs P15):

Fresh Blind Solver / Adversary coverage is a *coverage* guarantee, not a *structural*
one. `SectionStructureEvaluator` owns the deterministic shape invariants of a section
(2 groups, 720-915 passage words, exact S1/S2/S3 counts, types, sizes, contiguous
numbering). Binding those invariants to the presence of an `evaluationsSummary` block
coupled two unrelated contracts: a structurally perfect section assembled before its
children were committed could never pass, and every missing-coverage signal was reported
under a structural issue code with no owner.

This evaluator is the owner of the coverage guarantee. It is fail-closed and unchanged in
strength: an absent, partial, stale or explicitly-uncovered summary all produce CRITICAL
`FRESH_EVALUATION_MISSING` / `STALE_DEPENDENCY` blockers, so a section can never be
accepted without fresh solver/adversary evidence. No threshold, issue code or severity was
relaxed — only the layer that emits them moved.
"""

from __future__ import annotations

from collections.abc import Mapping
from typing import List, Optional
from uuid import uuid4

from app.config import settings
from app.contracts.artifact import ArtifactEnvelope, ArtifactType
from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.contracts.issue import Issue, IssueCode, IssueScope, IssueSeverity
from app.evaluators.base import BaseEvaluator, EvaluationStage, EvaluatorMetadata
from app.loop.context import LoopContext


class SectionCoverageEvaluator(BaseEvaluator):
    """Enforces fresh Blind Solver / Adversary coverage binding for a Section artifact."""

    def __init__(self, required: bool = True, timeout_seconds: Optional[float] = None):
        t_sec = (
            timeout_seconds
            if timeout_seconds is not None
            else getattr(settings, "evaluator_deterministic_timeout_seconds", 5.0)
        )
        super().__init__(
            EvaluatorMetadata(
                evaluator_id="eval_section_coverage",
                evaluator_version="1.0.0",
                name="Section Fresh Solver and Adversary Coverage Evaluator",
                description=(
                    "Fail-closed binding of fresh dependency evidence and mandatory "
                    "Blind Solver / Adversary coverage to a section"
                ),
                stage=EvaluationStage.DETERMINISTIC,
                target_artifact_types=[ArtifactType.SECTION],
                required=required,
                hard_checks=[
                    IssueCode.STALE_DEPENDENCY,
                    IssueCode.FRESH_EVALUATION_MISSING,
                ],
                timeout_seconds=t_sec,
                is_expensive=False,
            )
        )

    async def _evaluate_impl(
        self, context: LoopContext, artifact: ArtifactEnvelope, intent_id: str
    ) -> EvaluationResult:
        payload = artifact.payload
        issues: List[Issue] = []
        sec_id = int(payload.get("sectionId") or payload.get("section_id") or artifact.section_id or 1)

        eval_summary = payload.get("evaluationsSummary") or payload.get("evaluations_summary")
        if not isinstance(eval_summary, Mapping):
            issues.append(
                Issue.create(
                    issue_id=f"iss_sec_{sec_id}_no_eval_summary_{uuid4().hex[:8]}",
                    code=IssueCode.FRESH_EVALUATION_MISSING,
                    severity=IssueSeverity.CRITICAL,
                    scope=IssueScope.SECTION,
                    message=(
                        f"Section {sec_id} lacks required evaluationsSummary binding "
                        "solver/adversary coverage"
                    ),
                    affected_refs=[artifact.to_ref()],
                    evaluator_id=self.evaluator_id,
                )
            )
            eval_summary = {}

        fresh_evals = eval_summary.get("freshEvaluations") is True
        solver_covered = eval_summary.get("solverCovered") is True
        adversary_covered = eval_summary.get("adversaryCovered") is True
        accepted_eval_refs = eval_summary.get("acceptedEvaluationRefs") or []
        has_stale_deps = eval_summary.get("hasStaleDependencies", False)

        if not fresh_evals or has_stale_deps:
            issues.append(
                Issue.create(
                    issue_id=f"iss_sec_{sec_id}_stale_{uuid4().hex[:8]}",
                    code=IssueCode.STALE_DEPENDENCY,
                    severity=IssueSeverity.CRITICAL,
                    scope=IssueScope.SECTION,
                    message=f"Section {sec_id} contains stale or unverified dependency references",
                    affected_refs=[artifact.to_ref()],
                    evaluator_id=self.evaluator_id,
                )
            )

        if (
            not solver_covered
            or not adversary_covered
            or not accepted_eval_refs
            or eval_summary.get("missingRequiredEvaluations", False)
        ):
            issues.append(
                Issue.create(
                    issue_id=f"iss_sec_{sec_id}_missing_eval_{uuid4().hex[:8]}",
                    code=IssueCode.FRESH_EVALUATION_MISSING,
                    severity=IssueSeverity.CRITICAL,
                    scope=IssueScope.SECTION,
                    message=(
                        f"Section {sec_id} is missing mandatory fresh Blind Solver "
                        "or Adversary coverage"
                    ),
                    affected_refs=[artifact.to_ref()],
                    evaluator_id=self.evaluator_id,
                )
            )

        status = EvaluationStatus.FAIL if issues else EvaluationStatus.PASS
        return EvaluationResult(
            evaluation_id=f"eval_cov_{uuid4().hex[:12]}",
            evaluator_id=self.evaluator_id,
            evaluator_version=self.evaluator_version,
            target_ref=artifact.to_ref(),
            status=status,
            issues=issues,
            score=1.0 if status == EvaluationStatus.PASS else 0.0,
        )