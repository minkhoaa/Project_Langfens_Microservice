"""Canonical Evaluation Contracts for Langfens Loop Engine V2."""

from __future__ import annotations

from datetime import datetime, timezone
from enum import Enum
from typing import List, Optional
from pydantic import Field, field_validator

from .artifact import ArtifactRef
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
    ) -> EvaluationResult:
        """Constructs an explicit ERROR evaluation result with an attached critical issue."""
        issue = Issue.create(
            issue_id=f"iss_{evaluation_id}",
            code=code,
            severity=IssueSeverity.CRITICAL,
            scope=IssueScope.SECTION,
            message=error_message,
            affected_refs=[target_ref],
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
