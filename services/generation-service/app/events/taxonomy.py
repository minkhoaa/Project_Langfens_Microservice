"""Event taxonomy for the GenerationService V2 Loop Engine (Phase 13).

Defines the canonical ``EventType`` enum, terminal/progress groupings used by
the outbox, replay buffer, streaming layer, and legacy NDJSON projection.

Invariants enforced here:

* ``RUN_COMPLETED`` / ``RUN_FAILED`` are the **only** terminal event types.
* Heartbeats are first-class events (``HEARTBEAT``) so they can be filtered
  by the legacy projector and metric accounting without losing sequence
  ordering.
"""

from __future__ import annotations

from enum import Enum
from typing import FrozenSet


class EventType(str, Enum):
    """Canonical lifecycle, artifact, and control event taxonomy."""

    RUN_STARTED = "RUN_STARTED"
    CHECKPOINT_SAVED = "CHECKPOINT_SAVED"
    ARTIFACT_PRODUCED = "ARTIFACT_PRODUCED"
    EVALUATION_COMPLETED = "EVALUATION_COMPLETED"
    ISSUE_RECORDED = "ISSUE_RECORDED"
    LOOP_DECIDED = "LOOP_DECIDED"
    OPERATION_GRANTED = "OPERATION_GRANTED"
    SECTION_GENERATED = "SECTION_GENERATED"
    PAPER_GENERATED = "PAPER_GENERATED"
    RUN_COMPLETED = "RUN_COMPLETED"
    RUN_FAILED = "RUN_FAILED"
    HEARTBEAT = "HEARTBEAT"


TERMINAL_EVENT_TYPES: FrozenSet[EventType] = frozenset(
    {EventType.RUN_COMPLETED, EventType.RUN_FAILED}
)

PROGRESS_EVENT_TYPES: FrozenSet[EventType] = frozenset(
    {
        EventType.CHECKPOINT_SAVED,
        EventType.ARTIFACT_PRODUCED,
        EventType.EVALUATION_COMPLETED,
        EventType.ISSUE_RECORDED,
        EventType.LOOP_DECIDED,
        EventType.OPERATION_GRANTED,
        EventType.SECTION_GENERATED,
        EventType.PAPER_GENERATED,
    }
)

ARTIFACT_EVENT_TYPES: FrozenSet[EventType] = frozenset(
    {
        EventType.ARTIFACT_PRODUCED,
        EventType.SECTION_GENERATED,
        EventType.PAPER_GENERATED,
        EventType.CHECKPOINT_SAVED,
    }
)


def is_terminal(event_type: EventType | str) -> bool:
    """Return True when ``event_type`` ends the run lifecycle."""
    if isinstance(event_type, str):
        try:
            event_type = EventType(event_type)
        except ValueError:
            return False
    return event_type in TERMINAL_EVENT_TYPES


def is_progress(event_type: EventType | str) -> bool:
    """Return True when ``event_type`` is a non-terminal progress event."""
    if isinstance(event_type, str):
        try:
            event_type = EventType(event_type)
        except ValueError:
            return False
    return event_type in PROGRESS_EVENT_TYPES


def requires_artifact_ref(event_type: EventType | str) -> bool:
    """Return True when ``event_type`` MUST carry an ``artifactRef``."""
    if isinstance(event_type, str):
        try:
            event_type = EventType(event_type)
        except ValueError:
            return False
    return event_type in ARTIFACT_EVENT_TYPES


__all__ = [
    "EventType",
    "TERMINAL_EVENT_TYPES",
    "PROGRESS_EVENT_TYPES",
    "ARTIFACT_EVENT_TYPES",
    "is_terminal",
    "is_progress",
    "requires_artifact_ref",
]