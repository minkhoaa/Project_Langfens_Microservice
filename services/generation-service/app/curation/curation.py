"""Phase-14 curation state machine and audit log for human feedback lifecycle.

The curation lifecycle is intentionally strict: a human feedback record (raw edit,
publish, accept) never constitutes ground-truth / gold label on its own. To
become a CURATED gold label, it must traverse ``RAW -> ANNOTATED -> REVIEWED
-> CURATED``. Any attempt to short-circuit (e.g. ``RAW -> CURATED``) is
rejected. The audit log records every transition with reviewer identity,
review comment, and timestamp.
"""
from __future__ import annotations

import json
import secrets
import uuid
from dataclasses import dataclass, field
from datetime import datetime, timezone
from enum import Enum
from typing import Any, Iterable


class CurationStatus(str, Enum):
    """Strictly ordered curation states."""

    RAW = "RAW"
    ANNOTATED = "ANNOTATED"
    REVIEWED = "REVIEWED"
    CURATED = "CURATED"
    REJECTED = "REJECTED"


class ActionType(str, Enum):
    """Action kinds on feedback records."""

    EDIT = "EDIT"
    ACCEPT = "ACCEPT"
    PUBLISH = "PUBLISH"
    REJECT = "REJECT"
    PROMOTE = "PROMOTE"


# Allowed transitions between curation states. Anything else raises.
ALLOWED_TRANSITIONS: dict[CurationStatus, set[CurationStatus]] = {
    CurationStatus.RAW: {CurationStatus.ANNOTATED, CurationStatus.REJECTED},
    CurationStatus.ANNOTATED: {CurationStatus.REVIEWED, CurationStatus.REJECTED},
    CurationStatus.REVIEWED: {CurationStatus.CURATED, CurationStatus.REJECTED},
    CurationStatus.CURATED: set(),  # terminal
    CurationStatus.REJECTED: set(),  # terminal
}

# State transitions require a reviewer role for these source -> target pairs.
REVIEW_REQUIRED_TRANSITIONS: set[tuple[CurationStatus, CurationStatus]] = {
    (CurationStatus.ANNOTATED, CurationStatus.REVIEWED),
    (CurationStatus.REVIEWED, CurationStatus.CURATED),
    (CurationStatus.ANNOTATED, CurationStatus.REJECTED),
    (CurationStatus.REVIEWED, CurationStatus.REJECTED),
}

# Authoritative reviewer / curator roles.
REVIEWER_ROLES: frozenset[str] = frozenset({"admin", "curator", "reviewer"})


class CurationError(RuntimeError):
    """Raised on any violation of the curation lifecycle."""


@dataclass(frozen=True)
class CurationAuditLog:
    """Immutable audit log row for a state transition."""

    log_id: str
    feedback_id: str
    from_status: CurationStatus | None
    to_status: CurationStatus
    reviewer_id: str
    review_comment: str
    timestamp: str
    action_type: ActionType
    metadata: dict[str, Any] = field(default_factory=dict)


@dataclass
class FeedbackRecord:
    """In-memory model of a feedback record under curation."""

    feedback_id: str
    editor_id: str
    editor_role: str
    action_type: ActionType
    status: CurationStatus = CurationStatus.RAW
    reasons: list[str] = field(default_factory=list)
    comment: str = ""
    artifact_id: str | None = None
    artifact_version: str | None = None
    target_entity_type: str | None = None
    target_entity_id: str | None = None
    before_payload: dict[str, Any] | None = None
    after_payload: dict[str, Any] | None = None
    diff: dict[str, Any] | None = None
    idempotency_key: str | None = None
    created_at: str = field(default_factory=lambda: _utcnow_iso())
    curated_at: str | None = None


def _utcnow_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def _new_id() -> str:
    return secrets.token_hex(8)


def _payload_fingerprint(
    *,
    action_type: ActionType,
    editor_id: str,
    editor_role: str,
    reasons: Iterable[str],
    comment: str,
    artifact_id: str | None,
    artifact_version: str | None,
    target_entity_type: str | None,
    target_entity_id: str | None,
    before_payload: dict[str, Any] | None,
    after_payload: dict[str, Any] | None,
    diff: dict[str, Any] | None,
    idempotency_key: str | None,
) -> str:
    import hashlib
    body = {
        "action_type": action_type.value,
        "editor_id": editor_id,
        "editor_role": editor_role,
        "reasons": sorted(reasons),
        "comment": comment,
        "artifact_id": artifact_id,
        "artifact_version": artifact_version,
        "target_entity_type": target_entity_type,
        "target_entity_id": target_entity_id,
        "before_payload": before_payload,
        "after_payload": after_payload,
        "diff": diff,
        "idempotency_key": idempotency_key,
    }
    return hashlib.sha256(json.dumps(body, sort_keys=True, separators=(",", ":"), default=str).encode("utf-8")).hexdigest()

class CurationManager:
    """State machine + audit log manager for feedback records.

    The manager owns the lifecycle and refuses transitions that would let raw
    edits/accepts/publishes become ground truth without independent review.
    """

    def __init__(self) -> None:
        self._records: dict[str, FeedbackRecord] = {}
        self._logs: list[CurationAuditLog] = []
        self._payload_fingerprints: dict[str, str] = {}

    # ------------------------------------------------------------------
    # record lifecycle
    # ------------------------------------------------------------------

    def register(
        self,
        *,
        feedback_id: str | None = None,
        editor_id: str,
        editor_role: str,
        action_type: ActionType,
        reasons: Iterable[str] = (),
        comment: str = "",
        artifact_id: str | None = None,
        artifact_version: str | None = None,
        target_entity_type: str | None = None,
        target_entity_id: str | None = None,
        before_payload: dict[str, Any] | None = None,
        after_payload: dict[str, Any] | None = None,
        diff: dict[str, Any] | None = None,
        idempotency_key: str | None = None,
    ) -> FeedbackRecord:
        """Register a raw feedback record. Always starts at RAW unless
        the feedback_id/idempotency_key already exists.

        If existing record with identical payload is re-submitted (idempotent replay),
        the existing record is returned without resetting its status or creating
        duplicate RAW audit logs.
        If payload differs, raises CurationError (conflict).
        """
        reasons_list = list(reasons)
        incoming_fp = _payload_fingerprint(
            action_type=action_type,
            editor_id=editor_id,
            editor_role=editor_role,
            reasons=reasons_list,
            comment=comment,
            artifact_id=artifact_id,
            artifact_version=artifact_version,
            target_entity_type=target_entity_type,
            target_entity_id=target_entity_id,
            before_payload=before_payload,
            after_payload=after_payload,
            diff=diff,
            idempotency_key=idempotency_key,
        )
        existing: FeedbackRecord | None = None
        if feedback_id and feedback_id in self._records:
            existing = self._records[feedback_id]
        elif idempotency_key:
            for r in self._records.values():
                if r.idempotency_key == idempotency_key:
                    existing = r
                    break

        if existing is not None:
            existing_fp = self._payload_fingerprints.get(existing.feedback_id)
            if existing_fp != incoming_fp:
                raise CurationError(
                    f"Idempotent conflict on feedback_id={existing.feedback_id}: "
                    "payload differs from previously recorded feedback."
                )
            # Identical payload: return existing record without resetting status or logging
            return existing

        fid = feedback_id or _new_id()
        record = FeedbackRecord(
            feedback_id=fid,
            editor_id=editor_id,
            editor_role=editor_role,
            action_type=action_type,
            status=CurationStatus.RAW,
            reasons=reasons_list,
            comment=comment,
            artifact_id=artifact_id,
            artifact_version=artifact_version,
            target_entity_type=target_entity_type,
            target_entity_id=target_entity_id,
            before_payload=before_payload,
            after_payload=after_payload,
            diff=diff,
            idempotency_key=idempotency_key,
        )
        self._records[fid] = record
        self._payload_fingerprints[fid] = incoming_fp
        # Initial registration is also audited so the trail starts at RAW.
        self._append_log(
            record,
            from_status=None,
            to_status=CurationStatus.RAW,
            reviewer_id=editor_id,
            review_comment=comment or "raw feedback received",
            action_type=action_type,
        )
        return record

    def transition(
        self,
        *,
        feedback_id: str,
        target: CurationStatus,
        reviewer_id: str,
        reviewer_role: str,
        comment: str,
        action_type: ActionType | None = None,
        metadata: dict[str, Any] | None = None,
    ) -> FeedbackRecord:
        """Transition a record to ``target``.

        Raises :class:`CurationError` for any illegal transition or role
        violation. Records the transition in the audit trail.
        """
        record = self._records.get(feedback_id)
        if record is None:
            raise CurationError(f"unknown feedback_id={feedback_id}")
        current = record.status
        if target == current:
            return record
        allowed = ALLOWED_TRANSITIONS.get(current, set())
        if target not in allowed:
            raise CurationError(
                f"illegal transition {current.value} -> {target.value} "
                f"for feedback_id={feedback_id}"
            )
        if (current, target) in REVIEW_REQUIRED_TRANSITIONS:
            if reviewer_role not in REVIEWER_ROLES:
                raise CurationError(
                    f"role {reviewer_role!r} cannot transition "
                    f"{current.value} -> {target.value}"
                )
            if not comment or not comment.strip():
                raise CurationError(
                    f"review comment required for transition "
                    f"{current.value} -> {target.value}"
                )

        # Forbid skipping directly into CURATED unless we traversed REVIEWED.
        # Already enforced above by allowed transitions; this assertion keeps
        # the invariant explicit.
        assert current != CurationStatus.RAW or target != CurationStatus.CURATED, (
            "raw cannot become curated without review"
        )

        record.status = target
        if target == CurationStatus.CURATED:
            record.curated_at = _utcnow_iso()

        self._append_log(
            record,
            from_status=current,
            to_status=target,
            reviewer_id=reviewer_id,
            review_comment=comment,
            action_type=action_type or ActionType.PROMOTE,
            metadata=metadata or {},
        )
        return record

    # ------------------------------------------------------------------
    # queries
    # ------------------------------------------------------------------

    def get(self, feedback_id: str) -> FeedbackRecord:
        record = self._records.get(feedback_id)
        if record is None:
            raise CurationError(f"unknown feedback_id={feedback_id}")
        return record

    def get_audit_trail(self, feedback_id: str) -> list[CurationAuditLog]:
        return [log for log in self._logs if log.feedback_id == feedback_id]

    def all_audit_logs(self) -> list[CurationAuditLog]:
        return list(self._logs)

    def list_curated(self) -> list[FeedbackRecord]:
        return [r for r in self._records.values() if r.status == CurationStatus.CURATED]

    def list_status(self, status: CurationStatus) -> list[FeedbackRecord]:
        return [r for r in self._records.values() if r.status == status]

    # ------------------------------------------------------------------
    # gold-set guard
    # ------------------------------------------------------------------

    def assert_can_mark_gold(self, feedback_id: str) -> None:
        """Raise if the record is not allowed into a gold/ground-truth set.

        The only states from which a feedback record may enter a gold label
        dataset are ``CURATED`` and ``REVIEWED`` (for review-time benchmarks).
        Any RAW or ANNOTATED state MUST NOT be marked gold.
        """
        record = self.get(feedback_id)
        if record.status not in (CurationStatus.CURATED, CurationStatus.REVIEWED):
            raise CurationError(
                f"feedback_id={feedback_id} status={record.status.value} "
                f"is not eligible for gold/ground-truth"
            )

    def is_gold_eligible(self, feedback_id: str) -> bool:
        try:
            self.assert_can_mark_gold(feedback_id)
            return True
        except CurationError:
            return False

    # ------------------------------------------------------------------
    # internals
    # ------------------------------------------------------------------

    def _append_log(
        self,
        record: FeedbackRecord,
        *,
        from_status: CurationStatus | None,
        to_status: CurationStatus,
        reviewer_id: str,
        review_comment: str,
        action_type: ActionType,
        metadata: dict[str, Any] | None = None,
    ) -> CurationAuditLog:
        log = CurationAuditLog(
            log_id=uuid.uuid4().hex,
            feedback_id=record.feedback_id,
            from_status=from_status,
            to_status=to_status,
            reviewer_id=reviewer_id,
            review_comment=review_comment,
            timestamp=_utcnow_iso(),
            action_type=action_type,
            metadata=metadata or {},
        )
        self._logs.append(log)
        return log


def serialise_audit_log(log: CurationAuditLog) -> dict[str, Any]:
    return {
        "log_id": log.log_id,
        "feedback_id": log.feedback_id,
        "from_status": log.from_status.value if log.from_status is not None else None,
        "to_status": log.to_status.value,
        "reviewer_id": log.reviewer_id,
        "review_comment": log.review_comment,
        "timestamp": log.timestamp,
        "action_type": log.action_type.value,
        "metadata": dict(log.metadata),
    }


def serialise_record(record: FeedbackRecord) -> dict[str, Any]:
    return {
        "feedback_id": record.feedback_id,
        "editor_id": record.editor_id,
        "editor_role": record.editor_role,
        "action_type": record.action_type.value,
        "status": record.status.value,
        "reasons": list(record.reasons),
        "comment": record.comment,
        "artifact_id": record.artifact_id,
        "artifact_version": record.artifact_version,
        "target_entity_type": record.target_entity_type,
        "target_entity_id": record.target_entity_id,
        "before_payload": record.before_payload,
        "after_payload": record.after_payload,
        "diff": record.diff,
        "idempotency_key": record.idempotency_key,
        "created_at": record.created_at,
        "curated_at": record.curated_at,
    }


def dumps(obj: Any) -> str:
    """Stable JSON serialiser for stage persistence."""

    return json.dumps(obj, sort_keys=True, separators=(",", ":"), default=str)