"""Canonical Evaluation Contracts for Langfens Loop Engine V2."""

from __future__ import annotations

from datetime import datetime, timezone
from enum import Enum
from typing import List, Optional
from pydantic import Field, field_validator

from .artifact import ArtifactRef, ArtifactType
from .base import CanonicalBaseModel
from .issue import Issue, IssueCode, IssueScope, IssueSeverity, IssueStatus


class EvaluationStatus(str, Enum):
    PASS = "PASS"
    FAIL = "FAIL"
    ERROR = "ERROR"
    NOT_APPLICABLE = "NOT_APPLICABLE"


class UsageMetrics(CanonicalBaseModel):
    """Token and resource consumption metrics."""

    prompt_tokens: Optional[int] = Field(default=None, alias="promptTokens")
    completion_tokens: Optional[int] = Field(default=None, alias="completionTokens")
    total_tokens: Optional[int] = Field(default=None, alias="totalTokens")
    cost_usd: Optional[float] = Field(default=None, alias="costUsd")


class EvaluationResult(CanonicalBaseModel):
    """Result of evaluating an artifact by a deterministic or semantic evaluator."""

    evaluation_id: str = Field(..., alias="evaluationId")
    evaluator_id: str = Field(..., alias="evaluatorId")
    evaluator_version: str = Field(..., alias="evaluatorVersion")
    target_ref: ArtifactRef = Field(..., alias="targetRef")
    status: EvaluationStatus
    issues: List[Issue] = Field(default_factory=list)
    score: Optional[float] = Field(default=None, ge=0.0, le=1.0)
    input_dependency_refs: List[ArtifactRef] = Field(
        default_factory=list,
        alias="inputDependencyRefs",
    )
    resolved_issue_fingerprints: List[str] = Field(default_factory=list, alias="resolvedIssueFingerprints")
    provider: Optional[str] = None
    model: Optional[str] = None
    prompt_version: Optional[str] = Field(default=None, alias="promptVersion")
    elapsed_ms: Optional[float] = Field(default=None, ge=0.0, alias="elapsedMs")
    usage: Optional[UsageMetrics] = None
    evaluated_at: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc),
        alias="evaluatedAt",
    )
    @field_validator("resolved_issue_fingerprints", mode="before")
    @classmethod
    def _coerce_null_fingerprints(cls, v: Any) -> List[str]:
        if v is None:
            return []
        return v


    def is_pass(self) -> bool:
        """Strict PASS check: Status must be PASS and no critical open issues exist."""
        if self.status != EvaluationStatus.PASS:
            return False
        return not any(
            i.severity == IssueSeverity.CRITICAL and i.status == IssueStatus.OPEN
            for i in self.issues
        )

    def to_canonical_research_result(
        self,
        dataset_item_id: str,
        output_sha256: str,
        rubric_version: str = "R1-2026.1",
    ) -> Dict[str, Any]:
        """Bridges in-loop EvaluationResult to normative JSON_SCHEMAS.json#/$defs/EvaluationResult.

        Maps internal EvaluationStatus:
        - PASS -> PASS
        - FAIL -> FAIL
        - ERROR -> UNCERTAIN (with error issue message as abstention_reason)
        - NOT_APPLICABLE -> NOT_RUN
        """
        status_map = {
            EvaluationStatus.PASS: "PASS",
            EvaluationStatus.FAIL: "FAIL",
            EvaluationStatus.ERROR: "UNCERTAIN",
            EvaluationStatus.NOT_APPLICABLE: "NOT_RUN",
        }
        verdict = status_map.get(self.status, "FAIL")
        abstention_reason = None
        if self.status == EvaluationStatus.ERROR:
            critical_issues = [i.message for i in self.issues if i.severity == IssueSeverity.CRITICAL]
            abstention_reason = "; ".join(critical_issues) if critical_issues else "Evaluator error"
        elif self.status == EvaluationStatus.NOT_APPLICABLE:
            abstention_reason = "Evaluator not applicable to target artifact"
        elif self.status == EvaluationStatus.FAIL:
            fail_issues = [i.message for i in self.issues]
            abstention_reason = "; ".join(fail_issues) if fail_issues else "Evaluation failed"

        return {
            "evaluation_id": self.evaluation_id,
            "dataset_item_id": dataset_item_id,
            "output_sha256": output_sha256,
            "rubric_version": rubric_version,
            "evaluator_version": self.evaluator_version,
            "evaluable": self.status not in (EvaluationStatus.ERROR, EvaluationStatus.NOT_APPLICABLE),
            "hard_checks": {"status": self.status.value, "is_pass": self.is_pass()},
            "semantic_scores": {"score": self.score} if self.score is not None else {},
            "task_validity": {"resolved_issues": len(self.resolved_issue_fingerprints)},
            "verdict": verdict,
            "abstention_reason": abstention_reason,
            "evidence_refs": [r.artifact_id for r in self.input_dependency_refs] or ["target:" + self.target_ref.artifact_id],
        }

    @classmethod
    def create_error(
        cls,
        evaluation_id: str,
        evaluator_id: str,
        evaluator_version: str,
        target_ref: ArtifactRef,
        error_message: str,
        code: IssueCode = IssueCode.EVALUATOR_UNAVAILABLE,
        elapsed_ms: Optional[float] = None,
        scope: Optional[IssueScope] = None,
    ) -> EvaluationResult:
        """Constructs an explicit ERROR evaluation result with an attached critical issue."""
        if scope is None:
            if target_ref.artifact_type == ArtifactType.QUESTION:
                target_scope = IssueScope.QUESTION
            elif target_ref.artifact_type == ArtifactType.PASSAGE:
                target_scope = IssueScope.PASSAGE
            elif target_ref.artifact_type == ArtifactType.SOURCE_PACK:
                target_scope = IssueScope.SOURCE
            else:
                target_scope = IssueScope.SECTION
        else:
            target_scope = scope

        issue = Issue.create(
            issue_id=f"iss_{evaluation_id}",
            code=code,
            severity=IssueSeverity.CRITICAL,
            scope=target_scope,
            message=error_message,
            affected_refs=[target_ref],
            evaluator_id=evaluator_id,
        )
        return cls(
            evaluationId=evaluation_id,
            evaluatorId=evaluator_id,
            evaluatorVersion=evaluator_version,
            targetRef=target_ref,
            status=EvaluationStatus.ERROR,
            issues=[issue],
            score=0.0,
            elapsedMs=elapsed_ms,
        )
