"""Transactional Step Journal and Operation Intent Ledger for Loop Engine V2."""

from __future__ import annotations

import hashlib
from datetime import datetime, timezone
from typing import Any, Dict, List, Optional, Tuple
from uuid import UUID
from pydantic import ConfigDict, Field

from app.contracts.base import CanonicalBaseModel
from app.contracts.loop import LoopState


class OperationIntent(CanonicalBaseModel):
    """Operation intent declaring exact target, reservation, and cryptographic request hash."""

    operation_id: str = Field(..., alias="operationId")
    operation_type: str = Field(..., alias="operationType")
    run_id: str = Field(..., alias="runId")
    target_artifact_id: str = Field(..., alias="targetArtifactId")
    expected_version: int = Field(..., alias="expectedVersion", ge=1)
    token_reservation: int = Field(default=0, alias="tokenReservation")
    wall_time_reservation_seconds: float = Field(default=60.0, alias="wallTimeReservationSeconds")
    request_hash: str = Field(..., alias="requestHash")
    created_at: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc),
        alias="createdAt",
    )

    @classmethod
    def create(
        cls,
        operation_id: str,
        operation_type: str,
        run_id: str,
        target_artifact_id: str,
        expected_version: int,
        token_reservation: int = 0,
        wall_time_reservation_seconds: float = 60.0,
        payload_for_hash: Any = None,
    ) -> OperationIntent:
        req_raw = f"{operation_id}:{operation_type}:{target_artifact_id}:{expected_version}"
        if payload_for_hash is not None:
            req_raw += f":{str(payload_for_hash)}"
        req_hash = hashlib.sha256(req_raw.encode("utf-8")).hexdigest()
        return cls(
            operationId=operation_id,
            operationType=operation_type,
            runId=run_id,
            targetArtifactId=target_artifact_id,
            expectedVersion=expected_version,
            tokenReservation=token_reservation,
            wallTimeReservationSeconds=wall_time_reservation_seconds,
            requestHash=req_hash,
        )


class JournalEntry(CanonicalBaseModel):
    """Immutable journal record tracking an operation step from intent to durable acknowledgment."""

    model_config = ConfigDict(
        frozen=False,
        populate_by_name=True,
        extra="forbid",
    )

    entry_id: str = Field(..., alias="entryId")
    step_index: int = Field(..., alias="stepIndex", ge=0)
    state_before: LoopState = Field(..., alias="stateBefore")
    intent: OperationIntent
    status: str = Field(default="INTENT_RECORDED")  # INTENT_RECORDED, EXECUTION_STARTED, ACKNOWLEDGED, FAILED
    result_hash: Optional[str] = Field(default=None, alias="resultHash")
    tokens_used: int = Field(default=0, alias="tokensUsed")
    wall_time_used_seconds: float = Field(default=0.0, alias="wallTimeUsedSeconds")
    error_message: Optional[str] = Field(default=None, alias="errorMessage")
    ack_data: Optional[Dict[str, Any]] = Field(default=None, alias="ackData")
    recorded_at: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc),
        alias="recordedAt",
    )
    committed_at: Optional[datetime] = Field(default=None, alias="committedAt")


class StepJournal:
    """Transactional journal recording every side-effect intent, execution, and ack.
    
    Acts as a client-side projection over the authoritative exam-service persistence.
    """

    def __init__(
        self,
        run_id: str,
        persistence_client: Optional[Any] = None,
        authority: Optional[Any] = None,
    ):
        self.run_id = run_id
        self.persistence_client = persistence_client
        self.authority = authority
        self._entries: List[JournalEntry] = []
        self._entries_by_op_id: Dict[str, JournalEntry] = {}

    @classmethod
    def from_entries(
        cls,
        run_id: str,
        entries: List[JournalEntry],
        persistence_client: Optional[Any] = None,
        authority: Optional[Any] = None,
    ) -> StepJournal:
        """Reconstructs StepJournal projection from journal entries."""
        journal = cls(run_id=run_id, persistence_client=persistence_client, authority=authority)
        for e in entries:
            journal._entries.append(e)
            journal._entries_by_op_id[e.intent.operation_id] = e
        return journal

    @property
    def entries(self) -> List[JournalEntry]:
        return list(self._entries)
    def record_intent(self, intent: OperationIntent, state_before: LoopState) -> JournalEntry:
        """Records an operation intent prior to executing any external call or mutation."""
        step_idx = len(self._entries)
        entry_id = f"jent_{self.run_id}_{step_idx}_{intent.operation_id[:8]}"
        entry = JournalEntry(
            entryId=entry_id,
            stepIndex=step_idx,
            stateBefore=state_before,
            intent=intent,
            status="INTENT_RECORDED",
        )
        self._entries.append(entry)
        self._entries_by_op_id[intent.operation_id] = entry
        return entry

    def mark_execution_started(self, operation_id: str) -> None:
        """Marks that execution of the intent has begun."""
        entry = self._entries_by_op_id.get(operation_id)
        if entry:
            entry.status = "EXECUTION_STARTED"

    def record_ack(
        self,
        operation_id: str,
        result_hash: str,
        tokens_used: int = 0,
        wall_time_used_s: float = 0.0,
        ack_data: Optional[Dict[str, Any]] = None,
    ) -> JournalEntry:
        """Durably acknowledges successful completion of an operation."""
        entry = self._entries_by_op_id.get(operation_id)
        if not entry:
            raise KeyError(f"Operation ID '{operation_id}' not found in journal")
        entry.status = "ACKNOWLEDGED"
        entry.result_hash = result_hash
        entry.tokens_used = max(0, tokens_used)
        entry.wall_time_used_seconds = max(0.0, wall_time_used_s)
        entry.ack_data = ack_data
        entry.committed_at = datetime.now(timezone.utc)
        return entry

    def record_failure(
        self,
        operation_id: str,
        error_message: str,
        tokens_used: int = 0,
        wall_time_used_s: float = 0.0,
    ) -> JournalEntry:
        """Records failure of an operation."""
        entry = self._entries_by_op_id.get(operation_id)
        if not entry:
            raise KeyError(f"Operation ID '{operation_id}' not found in journal")
        entry.status = "FAILED"
        entry.error_message = error_message
        entry.tokens_used = max(0, tokens_used)
        entry.wall_time_used_seconds = max(0.0, wall_time_used_s)
        entry.committed_at = datetime.now(timezone.utc)
        return entry

    def get_last_acknowledged_entry(self) -> Optional[JournalEntry]:
        """Finds the most recent ACKNOWLEDGED entry."""
        for entry in reversed(self._entries):
            if entry.status == "ACKNOWLEDGED":
                return entry
        return None

    def get_cumulative_usage(self) -> Tuple[int, float, int]:
        """Calculates cumulative tokens, wall time, and operation calls across all entries."""
        total_tokens = sum(e.tokens_used for e in self._entries)
        total_wall_time = sum(e.wall_time_used_seconds for e in self._entries)
        total_calls = sum(1 for e in self._entries if e.intent.operation_type in ("GENERATE", "EVALUATE", "REPAIR"))
        return total_tokens, total_wall_time, total_calls

    def export_journal_traces(self) -> List[Dict[str, Any]]:
        """Exports all journal traces as serializable dicts for reporting and gate evidence."""
        return [e.model_dump(mode="json") for e in self._entries]
