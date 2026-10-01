"""Issue fingerprints and evidence-backed lifecycle transitions for a single run."""
from __future__ import annotations

from datetime import datetime, timezone
from typing import Any, Sequence

from pydantic import Field

from app.contracts.artifact import ArtifactRef
from app.contracts.base import CanonicalBaseModel
from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.contracts.issue import (
    Issue, IssueCode, IssueLedger, IssueScope, IssueSeverity, IssueStatus,
    compute_issue_fingerprint,
)


class IssueResolutionRecord(CanonicalBaseModel):
    fingerprint: str
    previous_status: IssueStatus
    new_status: IssueStatus
    justification: str
    reconciled_by: str
    resolved_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))


class IssueLedgerManager:
    """No issue is closed by omission, score, or an unrelated evaluator's PASS."""

    def __init__(self, run_id: str, ledger_id: str | None = None):
        self.run_id = run_id
        self.ledger_id = ledger_id or f"ledger_{run_id}"
        self._issues_by_fp: dict[str, Issue] = {}
        self._resolution_history: list[IssueResolutionRecord] = []

    @property
    def issues(self) -> list[Issue]:
        return list(self._issues_by_fp.values())

    @property
    def resolution_history(self) -> list[IssueResolutionRecord]:
        return list(self._resolution_history)

    def to_ledger(self) -> IssueLedger:
        return IssueLedger(ledgerId=self.ledger_id, runId=self.run_id, issues=self.issues)

    def record_issue(
        self, code: IssueCode, severity: IssueSeverity, scope: IssueScope, message: str,
        affected_refs: Sequence[ArtifactRef] | None = None, evidence: str | None = None,
        proposed_repair: str | None = None, issue_id: str | None = None,
        reported_by: str | None = None,
    ) -> Issue:
        refs = list(affected_refs or [])
        fp = compute_issue_fingerprint(code, scope, refs, message)
        old = self._issues_by_fp.get(fp)
        if old is not None:
            if old.status == IssueStatus.OPEN:
                return old
            reopened = old.model_copy(update={"status": IssueStatus.OPEN, "resolved_at": None})
            self._issues_by_fp[fp] = reopened
            self._resolution_history.append(IssueResolutionRecord(
                fingerprint=fp, previous_status=old.status, new_status=IssueStatus.OPEN,
                justification="Explicit recurrence in subsequent evaluation", reconciled_by=reported_by or "runtime",
            ))
            return reopened
        issue = Issue.create(
            issue_id=issue_id or f"iss_{fp[:16]}", code=code, severity=severity,
            scope=scope, message=message, affected_refs=refs, evidence=evidence,
            proposed_repair=proposed_repair, evaluator_id=reported_by,
        )
        self._issues_by_fp[fp] = issue
        return issue

    def ingest_issues(self, issues: Sequence[Issue], reported_by: str | None = None) -> None:
        for issue in issues:
            self.record_issue(
                code=issue.code, severity=issue.severity, scope=issue.scope,
                message=issue.message, affected_refs=issue.affected_refs,
                evidence=issue.evidence, proposed_repair=issue.proposed_repair,
                issue_id=issue.issue_id, reported_by=reported_by or issue.evaluator_id,
            )

    def resolve_issue(self, fingerprint: str, verification: EvaluationResult) -> bool:
        issue = self._issues_by_fp.get(fingerprint)
        if issue is None:
            raise ValueError(f"Unknown issue fingerprint: {fingerprint}")
        if issue.status != IssueStatus.OPEN:
            return False
        # P07-06 Invariant: Previous issues can only be resolved by the corresponding evaluator
        if issue.evaluator_id is not None and verification.evaluator_id != issue.evaluator_id:
            raise ValueError(
                f"Resolution requires the corresponding evaluator '{issue.evaluator_id}' to verify the fix, "
                f"not '{verification.evaluator_id}'"
            )
        valid_target = any(
            verification.target_ref == ref or
            (verification.target_ref.artifact_id == ref.artifact_id and verification.target_ref.version > ref.version)
            for ref in issue.affected_refs
        )
        if (verification.status != EvaluationStatus.PASS or
            fingerprint not in verification.resolved_issue_fingerprints or
            not valid_target or
            fingerprint in {i.fingerprint for i in verification.issues}):
            raise ValueError("Resolution requires explicit PASS verification of the affected ref or its replacement")
        self._transition(issue, IssueStatus.RESOLVED,
                         f"Verified by {verification.evaluation_id} on {verification.target_ref.content_hash}",
                         verification.evaluator_id)
        return True

    def supersede_replaced_version(self, previous: ArtifactRef, replacement: ArtifactRef) -> int:
        if previous.artifact_id != replacement.artifact_id or replacement.version <= previous.version:
            raise ValueError("Supersession requires a durably committed newer version of the same artifact")
        count = 0
        for issue in list(self._issues_by_fp.values()):
            if issue.status == IssueStatus.OPEN and previous in issue.affected_refs:
                self._transition(issue, IssueStatus.SUPERSEDED,
                                 f"Replaced {previous.artifact_id} v{previous.version} with v{replacement.version} ({replacement.content_hash})",
                                 "loop-runtime")
                count += 1
        return count

    def _transition(self, issue: Issue, status: IssueStatus, justification: str, actor: str) -> None:
        self._issues_by_fp[issue.fingerprint] = issue.model_copy(update={
            "status": status, "resolved_at": datetime.now(timezone.utc),
        })
        self._resolution_history.append(IssueResolutionRecord(
            fingerprint=issue.fingerprint, previous_status=issue.status, new_status=status,
            justification=justification, reconciled_by=actor,
        ))

    def find_resolvable_fingerprints(self, evaluator_id: str, newer_target: ArtifactRef) -> list[str]:
        """Finds open issue fingerprints originally detected by evaluator_id that affect
        an earlier version of newer_target.artifact_id, eligible for resolution on PASS.
        """
        resolvable = []
        for issue in self.get_open_issues():
            if issue.evaluator_id == evaluator_id:
                for ref in issue.affected_refs:
                    if ref.artifact_id == newer_target.artifact_id and newer_target.version > ref.version:
                        resolvable.append(issue.fingerprint)
                        break
        return resolvable

    def reconcile_evaluation(self, evaluation: EvaluationResult) -> None:
        self.ingest_issues(evaluation.issues, reported_by=evaluation.evaluator_id)
        for fingerprint in evaluation.resolved_issue_fingerprints:
            self.resolve_issue(fingerprint, evaluation)

    def merge_evaluations(self, evaluations: Sequence[EvaluationResult]) -> None:
        """Sequentially merges and reconciles a list of evaluation results."""
        for ev in evaluations:
            self.reconcile_evaluation(ev)
    def get_unresolved_blockers(self) -> list[Issue]:
        return [i for i in self.issues if i.status == IssueStatus.OPEN and i.severity == IssueSeverity.CRITICAL]

    def has_unresolved_blockers(self) -> bool:
        return bool(self.get_unresolved_blockers())

    def get_open_issues(self) -> list[Issue]:
        return [i for i in self.issues if i.status == IssueStatus.OPEN]

    def get_open_fingerprints(self) -> set[str]:
        return {i.fingerprint for i in self.get_open_issues()}

    def to_dict(self) -> dict[str, Any]:
        return {
            "runId": self.run_id, "ledgerId": self.ledger_id,
            "issues": [i.model_dump(mode="json", by_alias=True) for i in self.issues],
            "resolutionHistory": [r.model_dump(mode="json") for r in self._resolution_history],
        }

    @classmethod
    def from_dict(cls, data: dict[str, Any]) -> IssueLedgerManager:
        manager = cls(data["runId"], data.get("ledgerId"))
        for payload in data.get("issues", []):
            issue = Issue.model_validate(payload)
            if compute_issue_fingerprint(issue.code, issue.scope, issue.affected_refs, issue.message) != issue.fingerprint:
                raise ValueError("Corrupt issue fingerprint in durable ledger")
            manager._issues_by_fp[issue.fingerprint] = issue
        manager._resolution_history = [IssueResolutionRecord.model_validate(r) for r in data.get("resolutionHistory", [])]
        return manager
