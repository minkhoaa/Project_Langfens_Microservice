"""Authoritative Eventing, Outbox, Replay, and Backpressure System (Phase 13)."""

from __future__ import annotations

from app.contracts.event import (
    ENGINE_VERSION,
    SCHEMA_VERSION,
    ArtifactProducedPayload,
    CheckpointSavedPayload,
    DomainEvent,
    EvaluationCompletedPayload,
    EventEnvelope,
    EventType,
    HeartbeatPayload,
    IssueRecordedPayload,
    LegacyProjector,
    LoopDecidedPayload,
    OperationGrantedPayload,
    PaperGeneratedPayload,
    RunCompletedPayload,
    RunFailedPayload,
    RunStartedPayload,
    SectionGeneratedPayload,
)
from app.events.buffer import BoundedEventBuffer, DEFAULT_BUFFER_CAPACITY
from app.events.envelope import (
    build_envelope,
    generate_event_id,
    local_sanitize_string,
    sanitize_payload,
)
from app.events.outbox import (
    EventOutbox,
    get_event_outbox,
)
from app.events.replay import (
    EventDeduplicator,
    parse_cursor,
    replay_from_cursor,
    replay_from_event_id,
)
from app.events.stream import (
    DEFAULT_HEARTBEAT_INTERVAL_SECONDS,
    EventStreamer,
    stream_events,
)
from app.events.taxonomy import (
    ARTIFACT_EVENT_TYPES,
    PROGRESS_EVENT_TYPES,
    TERMINAL_EVENT_TYPES,
    is_progress,
    is_terminal,
    requires_artifact_ref,
)

__all__ = [
    # Contracts & Taxonomy
    "EventType",
    "TERMINAL_EVENT_TYPES",
    "PROGRESS_EVENT_TYPES",
    "ARTIFACT_EVENT_TYPES",
    "is_terminal",
    "is_progress",
    "requires_artifact_ref",
    "SCHEMA_VERSION",
    "ENGINE_VERSION",
    "EventEnvelope",
    "DomainEvent",
    "LegacyProjector",
    "RunStartedPayload",
    "CheckpointSavedPayload",
    "ArtifactProducedPayload",
    "EvaluationCompletedPayload",
    "IssueRecordedPayload",
    "LoopDecidedPayload",
    "OperationGrantedPayload",
    "SectionGeneratedPayload",
    "PaperGeneratedPayload",
    "RunCompletedPayload",
    "RunFailedPayload",
    "HeartbeatPayload",
    # Envelope & Sanitization
    "build_envelope",
    "generate_event_id",
    "sanitize_payload",
    "local_sanitize_string",
    # Outbox
    "EventOutbox",
    "get_event_outbox",
    # Buffer
    "DEFAULT_BUFFER_CAPACITY",
    "BoundedEventBuffer",
    # Replay & Dedup
    "parse_cursor",
    "replay_from_cursor",
    "replay_from_event_id",
    "EventDeduplicator",
    # Streaming
    "DEFAULT_HEARTBEAT_INTERVAL_SECONDS",
    "EventStreamer",
    "stream_events",
]
