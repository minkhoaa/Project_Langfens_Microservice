"""Authoritative Event Outbox and Streaming Cache (Phase 13).

Serves as an in-memory streaming buffer and deduplication layer in front of the
authoritative PostgreSQL ReadingPaperEventOutbox managed by CheckpointService.

Guarantees:
1. Strictly monotonic 1-based sequence numbering per run.
2. Idempotent deduplication by eventId or sequence.
3. Authoritative reconciliation against CheckpointService / PostgreSQL database:
   disconnected streams without a terminal persistence fact are INCOMPLETE.
"""

from __future__ import annotations

import asyncio
from datetime import datetime, timezone
import logging
import threading
from typing import Any, Dict, List, Optional, Set

from app.contracts.artifact import ArtifactRef
from app.contracts.event import EventEnvelope, EventType
from app.events.envelope import build_envelope
from app.events.taxonomy import is_terminal


logger = logging.getLogger(__name__)


class EventOutbox:
    """Thread-safe and async-safe outbox buffer for appending, storing, and querying run events."""

    def __init__(self):
        self._lock = threading.RLock()
        self._async_locks: Dict[str, asyncio.Lock] = {}

        # In-memory streaming buffer
        self._events_by_run: Dict[str, List[EventEnvelope]] = {}
        self._events_by_id: Dict[str, EventEnvelope] = {}
        self._sequence_by_run: Dict[str, int] = {}
        self._terminal_facts: Dict[str, Dict[str, Any]] = {}
        self._incomplete_runs: Set[str] = set()

    def record_terminal_fact(
        self,
        run_id: str,
        fact: Dict[str, Any],
        *,
        event_type: EventType = EventType.RUN_COMPLETED,
    ) -> None:
        """Explicitly record a verified persistence fact (e.g. from CheckpointClient or Exam persistence)."""
        with self._lock:
            normalized_fact = {
                "runId": run_id,
                "eventType": event_type.value,
                "timestamp": datetime.now(timezone.utc).isoformat(),
                "fact": fact,
            }
            self._terminal_facts[run_id] = normalized_fact
            if run_id in self._incomplete_runs:
                self._incomplete_runs.remove(run_id)

    def has_terminal_fact(self, run_id: str, client: Any = None) -> bool:
        """Check whether a durable terminal persistence fact exists for run_id."""
        with self._lock:
            if run_id in self._terminal_facts:
                return True

            # If client is provided, query database authority
            if client is not None:
                try:
                    if hasattr(client, "resume_state"):
                        resume = client.resume_state(run_id)
                        if getattr(resume, "status", None) in ("COMPLETED", "Completed"):
                            return True
                    if hasattr(client, "get_outbox_events"):
                        events = client.get_outbox_events(run_id)
                        for ev in events:
                            ev_type = ev.get("eventType") if isinstance(ev, dict) else getattr(ev, "eventType", "")
                            if ev_type in (EventType.RUN_COMPLETED.value, EventType.RUN_FAILED.value):
                                return True
                except Exception as e:
                    logger.debug("Database check for terminal fact on run %s returned: %s", run_id, e)

            return False

    def get_terminal_fact(self, run_id: str) -> Optional[Dict[str, Any]]:
        """Retrieve the verified terminal fact if it exists in cache."""
        with self._lock:
            return self._terminal_facts.get(run_id)

    def reconcile_status(self, run_id: str, client: Any = None) -> str:
        """Authoritative status reconciliation for a run.

        Queries the CheckpointClient (PostgreSQL) when available, falling back to cached outbox facts.

        Returns:
            - 'COMPLETED' if durable RUN_COMPLETED fact exists
            - 'FAILED' if durable RUN_FAILED fact exists
            - 'INCOMPLETE' if run started or disconnected without durable terminal fact
            - 'UNKNOWN' if run is completely unknown
        """
        with self._lock:
            # 1. Check PostgreSQL via client if supplied
            if client is not None:
                try:
                    if hasattr(client, "resume_state"):
                        resume = client.resume_state(run_id)
                        status = getattr(resume, "status", None)
                        if status in ("COMPLETED", "Completed"):
                            return "COMPLETED"
                        elif status in ("FAILED", "Failed"):
                            return "FAILED"

                    if hasattr(client, "get_outbox_events"):
                        db_events = client.get_outbox_events(run_id)
                        if db_events:
                            for ev in db_events:
                                ev_type = ev.get("eventType") if isinstance(ev, dict) else getattr(ev, "eventType", "")
                                if ev_type == EventType.RUN_COMPLETED.value:
                                    return "COMPLETED"
                                elif ev_type == EventType.RUN_FAILED.value:
                                    return "FAILED"
                            return "INCOMPLETE"
                except Exception as e:
                    logger.debug("Failed querying CheckpointClient for run %s: %s", run_id, e)

            # 2. Check in-memory terminal facts
            fact = self.get_terminal_fact(run_id)
            if fact:
                ev_type = fact.get("eventType")
                if ev_type == EventType.RUN_COMPLETED.value:
                    return "COMPLETED"
                elif ev_type == EventType.RUN_FAILED.value:
                    return "FAILED"

            if run_id in self._incomplete_runs:
                return "INCOMPLETE"

            if run_id in self._events_by_run and len(self._events_by_run[run_id]) > 0:
                # Started but no terminal fact
                return "INCOMPLETE"

            return "UNKNOWN"

    def mark_incomplete(self, run_id: str, reason: str = "Stream disconnected before terminal fact") -> None:
        """Mark a run as incomplete due to stream disconnection or abnormal EOF."""
        with self._lock:
            if not self.has_terminal_fact(run_id):
                self._incomplete_runs.add(run_id)

    def append(
        self,
        run_id: str,
        event_type: EventType | str,
        payload: Dict[str, Any] | Any,
        *,
        event_id: Optional[str] = None,
        operation_id: Optional[str] = None,
        artifact_ref: Optional[ArtifactRef] = None,
        timestamp: Optional[datetime] = None,
        sanitize: bool = True,
    ) -> EventEnvelope:
        """Append an event to the in-memory stream buffer with monotonic sequence numbering and deduplication."""
        if isinstance(event_type, str):
            event_type = EventType(event_type)

        with self._lock:
            # Check deduplication by event_id if provided
            if event_id and event_id in self._events_by_id:
                return self._events_by_id[event_id]

            # Sequence assignment (strictly monotonic starting at 1 for stream delivery)
            current_seq = self._sequence_by_run.get(run_id, 0)
            next_seq = current_seq + 1

            envelope = build_envelope(
                event_type=event_type,
                run_id=run_id,
                payload=payload,
                sequence=next_seq,
                event_id=event_id,
                operation_id=operation_id,
                artifact_ref=artifact_ref,
                timestamp=timestamp,
                sanitize=sanitize,
            )

            # Store in-memory buffer
            self._sequence_by_run[run_id] = next_seq
            if run_id not in self._events_by_run:
                self._events_by_run[run_id] = []
            self._events_by_run[run_id].append(envelope)
            self._events_by_id[envelope.event_id] = envelope

            return envelope

    async def append_async(
        self,
        run_id: str,
        event_type: EventType | str,
        payload: Dict[str, Any] | Any,
        *,
        event_id: Optional[str] = None,
        operation_id: Optional[str] = None,
        artifact_ref: Optional[ArtifactRef] = None,
        timestamp: Optional[datetime] = None,
        sanitize: bool = True,
    ) -> EventEnvelope:
        """Async wrapper around append."""
        return self.append(
            run_id=run_id,
            event_type=event_type,
            payload=payload,
            event_id=event_id,
            operation_id=operation_id,
            artifact_ref=artifact_ref,
            timestamp=timestamp,
            sanitize=sanitize,
        )

    def get_events(
        self,
        run_id: str,
        after_sequence: int = 0,
        limit: Optional[int] = None,
    ) -> List[EventEnvelope]:
        """Fetch events for a run with sequence > after_sequence, up to limit."""
        with self._lock:
            events = self._events_by_run.get(run_id, [])
            filtered = [e for e in events if e.sequence > after_sequence]
            if limit is not None:
                return filtered[:limit]
            return filtered

    def get_event_by_id(self, event_id: str) -> Optional[EventEnvelope]:
        """Retrieve an event by unique eventId for deduplication."""
        with self._lock:
            return self._events_by_id.get(event_id)

    def get_latest_sequence(self, run_id: str) -> int:
        """Get the latest sequence number for a run."""
        with self._lock:
            return self._sequence_by_run.get(run_id, 0)

    def clear(self) -> None:
        """Clear all in-memory events and state (useful in test teardown)."""
        with self._lock:
            self._events_by_run.clear()
            self._events_by_id.clear()
            self._sequence_by_run.clear()
            self._terminal_facts.clear()
            self._incomplete_runs.clear()


# Shared singleton instance
_default_outbox: Optional[EventOutbox] = None


def get_event_outbox() -> EventOutbox:
    """Retrieve or initialize the singleton EventOutbox."""
    global _default_outbox
    if _default_outbox is None:
        _default_outbox = EventOutbox()
    return _default_outbox


__all__ = [
    "EventOutbox",
    "get_event_outbox",
]
