"""Canonical Issue Ledger Contracts for Langfens Loop Engine V2."""

from __future__ import annotations

import hashlib
from datetime import datetime, timezone
from enum import Enum
from typing import List, Optional
from pydantic import Field

from .artifact import ArtifactRef
from .base import CanonicalBaseModel


class IssueSeverity(str, Enum):
    CRITICAL = "CRITICAL"
    MAJOR = "MAJOR"
    MINOR = "MINOR"
    INFO = "INFO"


class IssueScope(str, Enum):
    SOURCE = "SOURCE"
    EVIDENCE = "EVIDENCE"
    BLUEPRINT = "BLUEPRINT"
    PASSAGE = "PASSAGE"
    QUESTION_GROUP = "QUESTION_GROUP"
    QUESTION = "QUESTION"
    SECTION = "SECTION"
    PAPER = "PAPER"


class IssueStatus(str, Enum):
    OPEN = "OPEN"
    RESOLVED = "RESOLVED"
    SUPERSEDED = "SUPERSEDED"


class IssueCode(str, Enum):
    # Five source fidelity hard errors
    UNSUPPORTED_OR_CONTRADICTED_CLAIM = "UNSUPPORTED_OR_CONTRADICTED_CLAIM"
    CAUSAL_OVERSTATEMENT = "CAUSAL_OVERSTATEMENT"
    OVERSTATED_CERTAINTY = "OVERSTATED_CERTAINTY"
    UNMEASURED_OUTCOME = "UNMEASURED_OUTCOME"
    SOURCE_INSUFFICIENT = "SOURCE_INSUFFICIENT"

    # Construction & contract violations
    EVIDENCE_MISSING = "EVIDENCE_MISSING"
    AMBIGUOUS_ANSWER = "AMBIGUOUS_ANSWER"
    ANSWER_LEAKAGE = "ANSWER_LEAKAGE"
    BAD_DISTRACTOR = "BAD_DISTRACTOR"
    WORD_LIMIT_EXCEEDED = "WORD_LIMIT_EXCEEDED"
    DUPLICATE_CONTENT = "DUPLICATE_CONTENT"
    EVALUATOR_UNAVAILABLE = "EVALUATOR_UNAVAILABLE"
    STALE_DEPENDENCY = "STALE_DEPENDENCY"
    BUDGET_EXHAUSTED = "BUDGET_EXHAUSTED"
    SCHEMA_VIOLATION = "SCHEMA_VIOLATION"
    INSUFFICIENT_OPTIONS = "INSUFFICIENT_OPTIONS"
    SECTION_WORD_COUNT_OUT_OF_BOUNDS = "SECTION_WORD_COUNT_OUT_OF_BOUNDS"
    QUESTION_NUMBERING_INVALID = "QUESTION_NUMBERING_INVALID"
    QUESTION_COUNT_MISMATCH = "QUESTION_COUNT_MISMATCH"
    SECTION_GROUP_COUNT_MISMATCH = "SECTION_GROUP_COUNT_MISMATCH"
    SECTION_GROUP_TYPE_MISMATCH = "SECTION_GROUP_TYPE_MISMATCH"
    SECTION_GROUP_SIZE_MISMATCH = "SECTION_GROUP_SIZE_MISMATCH"
    SPAN_CONCENTRATION_DETECTED = "SPAN_CONCENTRATION_DETECTED"
    ANSWER_CONCENTRATION_DETECTED = "ANSWER_CONCENTRATION_DETECTED"
    EDITORIAL_STYLE_DEFECT = "EDITORIAL_STYLE_DEFECT"
    EDITORIAL_SKILL_DIVERSITY_DEFECT = "EDITORIAL_SKILL_DIVERSITY_DEFECT"
    FRESH_EVALUATION_MISSING = "FRESH_EVALUATION_MISSING"


def compute_issue_fingerprint(
    code: IssueCode,
    scope: IssueScope,
    affected_refs: List[ArtifactRef],
    message: str,
) -> str:
    """Computes a deterministic hash fingerprint to prevent duplicate error thrashing."""
    ref_keys = sorted(f"{r.artifact_type}:{r.artifact_id}:{r.version}" for r in affected_refs)
    normalized_msg = " ".join(message.strip().lower().split())
    raw = f"{code.value}|{scope.value}|{','.join(ref_keys)}|{normalized_msg}"
    return hashlib.sha256(raw.encode("utf-8")).hexdigest()


class Issue(CanonicalBaseModel):
    """Specific error or defect detected by an evaluator or policy validator."""

    issue_id: str = Field(..., alias="issueId")
    code: IssueCode
    severity: IssueSeverity
    scope: IssueScope
    affected_refs: List[ArtifactRef] = Field(default_factory=list, alias="affectedRefs")
    message: str
    evidence: Optional[str] = None
    proposed_repair: Optional[str] = Field(default=None, alias="proposedRepair")
    status: IssueStatus = IssueStatus.OPEN
    fingerprint: str
    evaluator_id: Optional[str] = Field(default=None, alias="evaluatorId")
    created_at: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc),
        alias="createdAt",
    )
    resolved_at: Optional[datetime] = Field(default=None, alias="resolvedAt")
    @classmethod
    def create(
        cls,
        issue_id: str,
        code: IssueCode,
        severity: IssueSeverity,
        scope: IssueScope,
        message: str,
        affected_refs: Optional[List[ArtifactRef]] = None,
        evidence: Optional[str] = None,
        proposed_repair: Optional[str] = None,
        status: IssueStatus = IssueStatus.OPEN,
        created_at: Optional[datetime] = None,
        evaluator_id: Optional[str] = None,
    ) -> Issue:
        refs = affected_refs or []
        fp = compute_issue_fingerprint(code, scope, refs, message)
        return cls(
            issueId=issue_id,
            code=code,
            severity=severity,
            scope=scope,
            affectedRefs=refs,
            message=message,
            evidence=evidence,
            proposedRepair=proposed_repair,
            status=status,
            fingerprint=fp,
            evaluatorId=evaluator_id,
            createdAt=created_at or datetime.now(timezone.utc),
        )


class IssueLedger(CanonicalBaseModel):
    """Ledger recording current and historical issues across loop iterations."""

    ledger_id: str = Field(..., alias="ledgerId")
    run_id: str = Field(..., alias="runId")
    issues: List[Issue] = Field(default_factory=list)

    def has_critical_issues(self) -> bool:
        """Returns True if any open issue is CRITICAL."""
        return any(
            i.severity == IssueSeverity.CRITICAL and i.status == IssueStatus.OPEN
            for i in self.issues
        )

    def open_issues(self) -> List[Issue]:
        """Returns all open issues."""
        return [i for i in self.issues if i.status == IssueStatus.OPEN]

    def has_fingerprint(self, fingerprint: str) -> bool:
        """Checks if an open issue with the given fingerprint already exists."""
        return any(
            i.fingerprint == fingerprint and i.status == IssueStatus.OPEN
            for i in self.issues
        )
