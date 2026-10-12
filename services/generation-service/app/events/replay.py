"""Event Replay and Deduplication Services (Phase 13).

Provides cursor-based and Last-Event-ID replay from the PostgreSQL database
via CheckpointClient or in-memory EventOutbox cache with at-least-once delivery
semantics and duplicate elimination.
"""

from __future__ import annotations

from datetime import datetime, timezone
import json
import logging
from typing import Any, AsyncIterator, Iterable, List, Optional, Set, Union

from app.contracts.event import EventEnvelope, EventType
from app.events.envelope import build_envelope
from app.events.outbox import EventOutbox, get_event_outbox


logger = logging.getLogger(__name__)


def parse_cursor(cursor: Union[int, str, None]) -> int:
    """Parse a sequence cursor from query parameters or Last-Event-ID header.

    Returns:
        0 if cursor is None or empty; otherwise integer >= 0.
    """
    if cursor is None:
        return 0
    if isinstance(cursor, int):
        return max(0, cursor)
    if isinstance(cursor, str):
        cursor_str = cursor.strip()
        if not cursor_str:
            return 0
        try:
            return max(0, int(cursor_str))
        except ValueError:
            return 0
    return 0


def _convert_db_record_to_envelope(record: Any, fallback_seq: int) -> Optional[EventEnvelope]:
    """Convert a database outbox record to a validated EventEnvelope."""
    try:
        if isinstance(record, dict):
            event_id = record.get("eventId") or record.get("event_id", "")
            event_type_raw = record.get("eventType") or record.get("event_type", "")
            run_id = record.get("runId") or record.get("run_id", "")
            seq = record.get("sequence", fallback_seq)
            payload_json = record.get("payloadJson") or record.get("payload_json", "{}")
            created_at_raw = record.get("createdAt") or record.get("created_at")
        else:
            event_id = getattr(record, "eventId", "")
            event_type_raw = getattr(record, "eventType", "")
            run_id = getattr(record, "runId", "")
            seq = getattr(record, "sequence", fallback_seq)
            payload_json = getattr(record, "payloadJson", "{}")
            created_at_raw = getattr(record, "createdAt", None)

        if isinstance(payload_json, str):
            payload = json.loads(payload_json) if payload_json else {}
        elif isinstance(payload_json, dict):
            payload = payload_json
        else:
            payload = {}

        if isinstance(created_at_raw, str):
            ts = datetime.fromisoformat(created_at_raw.replace("Z", "+00:00"))
        elif isinstance(created_at_raw, datetime):
            ts = created_at_raw
        else:
            ts = datetime.now(timezone.utc)

        return build_envelope(
            event_type=event_type_raw,
            run_id=run_id,
            payload=payload,
            sequence=max(1, int(seq)),
            event_id=event_id,
            timestamp=ts,
            sanitize=False,  # Database records are already authoritative
        )
    except Exception as e:
        logger.warning("Failed converting db record to envelope: %s", e)
        return None


def replay_from_cursor(
    run_id: str,
    cursor: int = 0,
    *,
    limit: Optional[int] = None,
    outbox: Optional[EventOutbox] = None,
    client: Optional[Any] = None,
) -> List[EventEnvelope]:
    """Retrieve all recorded events for run_id strictly after the given sequence cursor.

    When client is provided, the PostgreSQL outbox is the SOLE authoritative source
    (fail-closed: never falls back to local in-memory cache).
    When client is None, falls back to the in-memory outbox buffer for offline test mode.
    """
    # 1. Authoritative PostgreSQL query
    if client is not None:
        if hasattr(client, "get_outbox_events"):
            try:
                db_records = client.get_outbox_events(run_id, after_sequence=cursor)
                if not db_records:
                    return []
                envelopes: List[EventEnvelope] = []
                for i, rec in enumerate(db_records, start=cursor + 1):
                    env = _convert_db_record_to_envelope(rec, fallback_seq=i)
                    if env is not None:
                        envelopes.append(env)
                if limit is not None:
                    return envelopes[:limit]
                return envelopes
            except Exception as e:
                logger.error("Authoritative PostgreSQL replay failed for run %s: %s", run_id, e)
                return []
        return []

    # 2. Local in-memory outbox buffer (offline unit tests only)
    box = outbox or get_event_outbox()
    return box.get_events(run_id, after_sequence=cursor, limit=limit)
def replay_from_event_id(
    run_id: str,
    last_event_id: str,
    *,
    outbox: Optional[EventOutbox] = None,
    client: Optional[Any] = None,
) -> List[EventEnvelope]:
    """Retrieve recorded events for run_id following the specified last_event_id.

    Resolves the authoritative sequence for last_event_id from PostgreSQL when client
    is provided; falls back to local in-memory outbox cache for offline tests.
    """
    cursor = 0
    if client is not None and hasattr(client, "get_outbox_events"):
        try:
            all_records = client.get_outbox_events(run_id, after_sequence=0)
            for i, rec in enumerate(all_records, start=1):
                eid = rec.get("eventId") if isinstance(rec, dict) else getattr(rec, "eventId", "")
                if eid == last_event_id:
                    seq = rec.get("sequence") if isinstance(rec, dict) else getattr(rec, "sequence", i)
                    cursor = int(seq)
                    break
        except Exception as e:
            logger.debug("Failed looking up event %s in CheckpointClient outbox: %s", last_event_id, e)
    else:
        box = outbox or get_event_outbox()
        target_event = box.get_event_by_id(last_event_id)
        cursor = target_event.sequence if target_event else 0

    return replay_from_cursor(run_id, cursor=cursor, outbox=outbox, client=client)

class EventDeduplicator:
    """Stateful deduplicator tracking seen event IDs and sequences for a client session."""

    def __init__(self, initial_seen_ids: Optional[Iterable[str]] = None, initial_max_seq: int = 0):
        self._seen_ids: Set[str] = set(initial_seen_ids or [])
        self._max_sequence: int = initial_max_seq

    def is_duplicate(self, envelope: EventEnvelope) -> bool:
        """Return True if envelope has already been observed."""
        if envelope.event_type == EventType.HEARTBEAT:
            return False
        if envelope.event_id in self._seen_ids:
            return True
        if envelope.sequence <= self._max_sequence and self._max_sequence > 0:
            # Sequence has already been seen or surpassed
            return True
        return False
    def track(self, envelope: EventEnvelope) -> bool:
        """Track envelope. Return True if event is new (accepted), False if duplicate."""
        if self.is_duplicate(envelope):
            return False
        self._seen_ids.add(envelope.event_id)
        if envelope.sequence > self._max_sequence:
            self._max_sequence = envelope.sequence
        return True

    def filter_new(self, envelopes: Iterable[EventEnvelope]) -> List[EventEnvelope]:
        """Filter a list of envelopes returning only unobserved items."""
        return [e for e in envelopes if self.track(e)]


__all__ = [
    "parse_cursor",
    "replay_from_cursor",
    "replay_from_event_id",
    "EventDeduplicator",
]
