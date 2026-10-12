"""Phase 13 Eventing, Outbox, Replay, Buffer, and Legacy Projection Tests (T13-03 - T13-07)."""

from __future__ import annotations

import asyncio
from datetime import datetime, timezone
import json
from pathlib import Path
import tempfile
import pytest

from app.contracts.artifact import ArtifactRef, ArtifactType
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
from app.events.buffer import BoundedEventBuffer
from app.events.envelope import (
    build_envelope,
    generate_event_id,
    local_sanitize_string,
    sanitize_payload,
)
from app.events.outbox import EventOutbox
from app.events.replay import (
    EventDeduplicator,
    parse_cursor,
    replay_from_cursor,
    replay_from_event_id,
)
from app.events.stream import EventStreamer, stream_events
from app.events.taxonomy import (
    ARTIFACT_EVENT_TYPES,
    PROGRESS_EVENT_TYPES,
    TERMINAL_EVENT_TYPES,
    is_progress,
    is_terminal,
    requires_artifact_ref,
)

@pytest.fixture
def temp_outbox() -> EventOutbox:
    """Create an isolated in-memory EventOutbox."""
    return EventOutbox()
# ---------------------------------------------------------------------------
# 1. Taxonomy & Classification Tests
# ---------------------------------------------------------------------------

def test_event_taxonomy_completeness():
    expected_types = {
        "RUN_STARTED",
        "CHECKPOINT_SAVED",
        "ARTIFACT_PRODUCED",
        "EVALUATION_COMPLETED",
        "ISSUE_RECORDED",
        "LOOP_DECIDED",
        "OPERATION_GRANTED",
        "SECTION_GENERATED",
        "PAPER_GENERATED",
        "RUN_COMPLETED",
        "RUN_FAILED",
        "HEARTBEAT",
    }
    actual_types = {e.value for e in EventType}
    assert actual_types == expected_types
    assert len(EventType) == 12


def test_taxonomy_helper_classifications():
    assert is_terminal(EventType.RUN_COMPLETED) is True
    assert is_terminal(EventType.RUN_FAILED) is True
    assert is_terminal(EventType.SECTION_GENERATED) is False
    assert is_terminal("RUN_COMPLETED") is True
    assert is_terminal("INVALID_TYPE") is False

    assert is_progress(EventType.SECTION_GENERATED) is True
    assert is_progress(EventType.CHECKPOINT_SAVED) is True
    assert is_progress(EventType.RUN_COMPLETED) is False
    assert is_progress(EventType.HEARTBEAT) is False

    assert requires_artifact_ref(EventType.ARTIFACT_PRODUCED) is True
    assert requires_artifact_ref(EventType.SECTION_GENERATED) is True
    assert requires_artifact_ref(EventType.RUN_STARTED) is False


# ---------------------------------------------------------------------------
# 2. Envelope Construction, Schema & Sanitization Tests
# ---------------------------------------------------------------------------

def test_build_envelope_assigns_defaults_and_metadata():
    run_id = "run_test_001"
    envelope = build_envelope(
        event_type=EventType.RUN_STARTED,
        run_id=run_id,
        payload={"topic": "Quantum Computing", "targetSections": 3},
        sequence=1,
    )
    assert envelope.event_id.startswith("evt_")
    assert envelope.sequence == 1
    assert envelope.run_id == run_id
    assert envelope.schema_version == SCHEMA_VERSION == "2.0.0"
    assert envelope.engine_version == ENGINE_VERSION == "2.0.0"
    assert envelope.event_type == EventType.RUN_STARTED
    assert envelope.payload["topic"] == "Quantum Computing"
    assert isinstance(envelope.timestamp, datetime)


def test_build_envelope_rejects_invalid_sequence():
    with pytest.raises(ValueError, match="Sequence must be monotonic >= 1"):
        build_envelope(
            event_type=EventType.RUN_STARTED,
            run_id="run_test",
            payload={},
            sequence=0,
        )


def test_sanitization_redacts_keys_cot_and_copyright():
    dirty_payload = {
        "apiKey": "sk-1234567890abcdef1234567890",
        "auth": "Bearer secret-token-value-12345",
        "analysis": "<thinking>Private internal model chain of thought</thinking> Here is the summary.",
        "source_text": "This content is Copyright © 2026 Cambridge Assessment. All rights reserved.",
        "safe_unicode": "IELTS Academic: 日本語, Español, Français — “Double quotes” & ‘Single’",
    }
    cleaned = sanitize_payload(dirty_payload)
    assert "sk-" not in str(cleaned["apiKey"])
    assert "REDACTED" in str(cleaned["apiKey"])
    assert "secret-token-value" not in str(cleaned["auth"])
    assert "REDACTED" in str(cleaned["auth"])
    assert "<thinking>" not in str(cleaned["analysis"])
    assert "REDACTED" in str(cleaned["analysis"])
    assert "Here is the summary." in str(cleaned["analysis"])
    assert (isinstance(cleaned["source_text"], dict) and cleaned["source_text"].get("redacted") is True) or "redacted" in str(cleaned["source_text"]).lower()
    assert "日本語" in str(cleaned["safe_unicode"])
    assert "“Double quotes”" in str(cleaned["safe_unicode"])


# ---------------------------------------------------------------------------
# 3. Outbox Monotonic Sequencing, Dedup & Terminal Durability
# ---------------------------------------------------------------------------

def test_outbox_monotonic_sequence_and_isolation(temp_outbox: EventOutbox):
    run_a = "run_alpha"
    run_b = "run_beta"

    e1 = temp_outbox.append(run_a, EventType.RUN_STARTED, {"topic": "A1"})
    e2 = temp_outbox.append(run_a, EventType.CHECKPOINT_SAVED, {"headVersion": 1})
    e3 = temp_outbox.append(run_a, EventType.SECTION_GENERATED, {"sectionIndex": 1, "title": "Sec 1"})

    # Sequence for run_a must be strictly 1, 2, 3
    assert e1.sequence == 1
    assert e2.sequence == 2
    assert e3.sequence == 3
    assert temp_outbox.get_latest_sequence(run_a) == 3

    # Run B starts its own independent sequence from 1
    eb1 = temp_outbox.append(run_b, EventType.RUN_STARTED, {"topic": "B1"})
    assert eb1.sequence == 1


def test_outbox_deduplication_by_event_id(temp_outbox: EventOutbox):
    run_id = "run_dedup"
    custom_id = "evt_fixed_unique_123"

    e1 = temp_outbox.append(
        run_id, EventType.RUN_STARTED, {"topic": "Dedup"}, event_id=custom_id
    )
    assert e1.event_id == custom_id
    assert e1.sequence == 1

    # Appending again with the same event_id returns the existing envelope without incrementing sequence
    e2 = temp_outbox.append(
        run_id, EventType.RUN_STARTED, {"topic": "Duplicate"}, event_id=custom_id
    )
    assert e2.event_id == custom_id
    assert e2.sequence == 1
    assert len(temp_outbox.get_events(run_id)) == 1


def test_outbox_durable_terminal_fact_persistence(temp_outbox: EventOutbox):
    run_id = "run_terminal_persist"
    assert temp_outbox.has_terminal_fact(run_id) is False
    assert temp_outbox.reconcile_status(run_id) == "UNKNOWN"

    # 1. Append progress - status is INCOMPLETE
    temp_outbox.append(run_id, EventType.RUN_STARTED, {"topic": "Durability"})
    assert temp_outbox.reconcile_status(run_id) == "INCOMPLETE"

    # 2. Appending unverified RUN_COMPLETED does NOT promote to terminal fact
    completed_event = temp_outbox.append(
        run_id,
        EventType.RUN_COMPLETED,
        {
            "runId": run_id,
            "jobId": "job_123",
            "examId": "exam_456",
            "finalScore": 9.0,
        },
    )
    # Invariant: Must remain False until verified CAS/DB persistence is confirmed!
    assert temp_outbox.has_terminal_fact(run_id) is False
    assert temp_outbox.reconcile_status(run_id) == "INCOMPLETE"

    # 3. Explicitly recording verified terminal persistence fact promotes to COMPLETED
    temp_outbox.record_terminal_fact(
        run_id,
        {"ack": "CAS_VERIFIED_COMMIT", "examId": "exam_456", "eventId": completed_event.event_id},
    )
    assert temp_outbox.has_terminal_fact(run_id) is True
    assert temp_outbox.reconcile_status(run_id) == "COMPLETED"
    fact = temp_outbox.get_terminal_fact(run_id)
    assert fact is not None
    assert fact["eventType"] == "RUN_COMPLETED"
    assert fact["fact"]["examId"] == "exam_456"
def test_outbox_reconcile_with_checkpoint_client():
    outbox = EventOutbox()
    run_id = "run_db_reconcile"

    class MockCheckpointClient:
        def resume_state(self, r_id):
            class State:
                status = "COMPLETED"
            return State()

        def get_outbox_events(self, r_id, after_sequence=0):
            return [
                {
                    "eventId": "evt_db_1",
                    "eventType": "RUN_STARTED",
                    "runId": r_id,
                    "sequence": 1,
                    "payloadJson": json.dumps({"topic": "Replay Topic"}),
                    "createdAt": "2026-10-08T12:00:00Z",
                },
                {
                    "eventId": "evt_db_2",
                    "eventType": "RUN_COMPLETED",
                    "runId": r_id,
                    "sequence": 2,
                    "payloadJson": json.dumps({"status": "COMPLETED"}),
                    "createdAt": "2026-10-08T12:05:00Z",
                },
            ]

    mock_client = MockCheckpointClient()
    assert outbox.reconcile_status(run_id, client=mock_client) == "COMPLETED"
    assert outbox.has_terminal_fact(run_id, client=mock_client) is True

    # Test replay using CheckpointClient
    replayed = replay_from_cursor(run_id, cursor=0, client=mock_client)
    assert len(replayed) == 2
    assert replayed[0].event_id == "evt_db_1"
    assert replayed[0].sequence == 1
    assert replayed[0].payload["topic"] == "Replay Topic"
    assert replayed[1].event_id == "evt_db_2"
    assert replayed[1].sequence == 2


def test_outbox_mark_incomplete_on_disconnect(temp_outbox: EventOutbox):
    run_id = "run_disconnect"
    temp_outbox.append(run_id, EventType.RUN_STARTED, {"topic": "Incomplete"})
    temp_outbox.mark_incomplete(run_id, "Client disconnected abruptly")
    assert temp_outbox.reconcile_status(run_id) == "INCOMPLETE"


# ---------------------------------------------------------------------------
# 4. Cursor Replay & Deduplication
# ---------------------------------------------------------------------------

def test_parse_cursor():
    assert parse_cursor(None) == 0
    assert parse_cursor("") == 0
    assert parse_cursor(5) == 5
    assert parse_cursor("12") == 12
    assert parse_cursor("invalid") == 0


def test_replay_from_cursor_and_event_id(temp_outbox: EventOutbox):
    run_id = "run_replay"
    events = [
        temp_outbox.append(run_id, EventType.RUN_STARTED, {"seq": 1}),
        temp_outbox.append(run_id, EventType.CHECKPOINT_SAVED, {"seq": 2}),
        temp_outbox.append(run_id, EventType.SECTION_GENERATED, {"seq": 3}),
        temp_outbox.append(run_id, EventType.EVALUATION_COMPLETED, {"seq": 4}),
    ]

    # Replay after sequence 2
    replayed = replay_from_cursor(run_id, cursor=2, outbox=temp_outbox)
    assert len(replayed) == 2
    assert [e.sequence for e in replayed] == [3, 4]

    # Replay from event ID
    replayed_id = replay_from_event_id(run_id, last_event_id=events[1].event_id, outbox=temp_outbox)
    assert len(replayed_id) == 2
    assert [e.sequence for e in replayed_id] == [3, 4]


def test_event_deduplicator():
    dedup = EventDeduplicator()
    e1 = build_envelope(EventType.RUN_STARTED, "r1", {"a": 1}, sequence=1, event_id="evt_1")
    e2 = build_envelope(EventType.CHECKPOINT_SAVED, "r1", {"a": 2}, sequence=2, event_id="evt_2")

    assert dedup.track(e1) is True
    assert dedup.track(e1) is False  # duplicate by ID / sequence
    assert dedup.track(e2) is True
    assert dedup.track(e2) is False

    # Older sequence is rejected
    e_old = build_envelope(EventType.RUN_STARTED, "r1", {"a": 0}, sequence=1, event_id="evt_new")
    assert dedup.track(e_old) is False


# ---------------------------------------------------------------------------
# 5. Legacy NDJSON Projection Invariants
# ---------------------------------------------------------------------------

def test_legacy_projector_strictly_three_shapes():
    run_id = "run_legacy"

    # 1. Error shape
    err_envelope = build_envelope(
        EventType.RUN_FAILED,
        run_id,
        {"httpStatus": 422, "message": "Short text", "traceback": "tb"},
        sequence=1,
    )
    p_err = LegacyProjector.project(err_envelope)
    assert set(p_err.keys()) == {"type", "httpStatus", "message", "traceback"}
    assert p_err["type"] == "error"
    assert p_err["httpStatus"] == 422

    # 2. Result shape (ONLY for durable final persistence)
    valid_section = {
        "title": "Passage 1",
        "passage": "Full passage text...",
        "groups": [{"id": 1, "questions": []}],
    }
    res_envelope = build_envelope(
        EventType.RUN_COMPLETED,
        run_id,
        {"result": {"section": valid_section}, "durablePersistenceVerified": True},
        sequence=2,
    )
    p_res = LegacyProjector.project(res_envelope)
    assert p_res["type"] == "result"
    assert "section" in p_res
    assert p_res["section"]["title"] == "Passage 1"

    # 3. Intermediate progress events MUST project to log (never result)
    intermediate_envelope = build_envelope(
        EventType.SECTION_GENERATED,
        run_id,
        {"sectionIndex": 1, "title": "Draft Section 1", "isFinal": False},
        sequence=3,
    )
    p_log = LegacyProjector.project(intermediate_envelope)
    assert p_log["type"] == "log"
    assert "Section 1" in p_log["message"]

    # 4. Heartbeat projects to log
    hb_envelope = build_envelope(
        EventType.HEARTBEAT,
        run_id,
        {"status": "IN_PROGRESS"},
        sequence=4,
    )
    p_hb = LegacyProjector.project(hb_envelope)
    assert p_hb["type"] == "log"
    assert "Heartbeat" in p_hb["message"]


# ---------------------------------------------------------------------------
# 6. Bounded Buffer, Backpressure & Terminal Protection
# ---------------------------------------------------------------------------

@pytest.mark.asyncio
async def test_bounded_buffer_caps_capacity_and_drops_oldest_non_terminal():
    cap = 10
    buffer = BoundedEventBuffer(capacity=cap)

    # Fill buffer to capacity with progress events
    for i in range(1, 11):
        envelope = build_envelope(EventType.CHECKPOINT_SAVED, "r1", {"head": i}, sequence=i)
        assert buffer.put_nowait(envelope) is True

    assert buffer.size() == 10
    assert buffer.dropped_count == 0

    # Put an 11th progress event -> drops oldest non-terminal (sequence=1)
    e11 = build_envelope(EventType.CHECKPOINT_SAVED, "r1", {"head": 11}, sequence=11)
    buffer.put_nowait(e11)
    assert buffer.size() == 10
    assert buffer.dropped_count == 1

    # First item out should now be sequence=2 (sequence=1 was dropped)
    first_item = await buffer.get()
    assert first_item.sequence == 2


@pytest.mark.asyncio
async def test_bounded_buffer_never_drops_terminal_event():
    buffer = BoundedEventBuffer(capacity=10)

    # Fill buffer with terminal event + progress events
    terminal_event = build_envelope(EventType.RUN_COMPLETED, "r1", {"status": "COMPLETED"}, sequence=1)
    buffer.put_nowait(terminal_event)

    for i in range(2, 11):
        env = build_envelope(EventType.CHECKPOINT_SAVED, "r1", {"head": i}, sequence=i)
        buffer.put_nowait(env)

    assert buffer.size() == 10

    # Overfill buffer with 5 more progress events
    for i in range(11, 16):
        env = build_envelope(EventType.CHECKPOINT_SAVED, "r1", {"head": i}, sequence=i)
        buffer.put_nowait(env)

    # The terminal event MUST still be at the front of the queue
    item = await buffer.get()
    assert item.event_type == EventType.RUN_COMPLETED
    assert item.sequence == 1


# ---------------------------------------------------------------------------
# 7. Streaming, Heartbeat Isolation & Replay Integration
# ---------------------------------------------------------------------------

@pytest.mark.asyncio
async def test_event_streamer_heartbeat_isolation_and_terminal_drain(temp_outbox: EventOutbox):
    run_id = "run_stream_test"
    streamer = EventStreamer(
        run_id=run_id,
        outbox=temp_outbox,
        heartbeat_interval_seconds=0.05,
        legacy=False,
    )

    chunks = []

    async def consumer():
        async for chunk in streamer.stream_bytes():
            chunks.append(chunk.decode("utf-8"))

    consumer_task = asyncio.create_task(consumer())

    # Emit initial progress
    await streamer.publish(EventType.RUN_STARTED, {"topic": "Marine Biology"})

    # Wait for at least 2 heartbeats
    await asyncio.sleep(0.15)

    # Emit terminal completion
    temp_outbox.record_terminal_fact(run_id, {"status": "COMPLETED"})
    await streamer.publish(
        EventType.RUN_COMPLETED,
        {
            "runId": run_id,
            "status": "COMPLETED",
        },
    )

    await consumer_task

    assert len(chunks) >= 3
    parsed = [json.loads(c) for c in chunks if c.strip()]
    event_types = [p["eventType"] for p in parsed]

    assert "RUN_STARTED" in event_types
    assert "HEARTBEAT" in event_types
    assert "RUN_COMPLETED" in event_types
    assert temp_outbox.reconcile_status(run_id) == "COMPLETED"

@pytest.mark.asyncio
async def test_streamer_legacy_projection_output(temp_outbox: EventOutbox):
    run_id = "run_legacy_stream"
    streamer = EventStreamer(
        run_id=run_id,
        outbox=temp_outbox,
        enable_heartbeats=False,
        legacy=True,
    )

    chunks = []

    async def consumer():
        async for chunk in streamer.stream_bytes():
            chunks.append(chunk.decode("utf-8"))

    consumer_task = asyncio.create_task(consumer())

    valid_section = {
        "title": "Passage 1",
        "passage": "Text...",
        "groups": [{"id": 1, "questions": []}],
    }

    await streamer.publish(EventType.RUN_STARTED, {"topic": "Botany"})
    await streamer.publish(EventType.SECTION_GENERATED, {"sectionIndex": 1, "title": "Passage 1", "isFinal": False})
    await streamer.publish(
        EventType.RUN_COMPLETED,
        {"result": {"section": valid_section}, "durablePersistenceVerified": True},
    )

    await consumer_task

    parsed = [json.loads(c) for c in chunks if c.strip()]
    assert len(parsed) == 3
    assert parsed[0]["type"] == "log"
    assert parsed[1]["type"] == "log"  # Intermediate section is logged
    assert parsed[2]["type"] == "result"  # Final completed result emitted
    assert parsed[2]["section"]["title"] == "Passage 1"

@pytest.mark.asyncio
async def test_streamer_replays_from_checkpoint_client():
    run_id = "run_db_stream_replay"

    class MockClient:
        def resume_state(self, r_id):
            class State:
                status = "COMPLETED"
            return State()

        def get_outbox_events(self, r_id, after_sequence=0):
            return [
                {
                    "eventId": "evt_db_1",
                    "eventType": "RUN_STARTED",
                    "runId": r_id,
                    "sequence": 1,
                    "payloadJson": json.dumps({"topic": "Astronomy"}),
                    "createdAt": "2026-10-08T12:00:00Z",
                },
                {
                    "eventId": "evt_db_2",
                    "eventType": "RUN_COMPLETED",
                    "runId": r_id,
                    "sequence": 2,
                    "payloadJson": json.dumps({"status": "COMPLETED", "durablePersistenceVerified": True}),
                    "createdAt": "2026-10-08T12:05:00Z",
                },
            ]

    mock_client = MockClient()
    streamer = EventStreamer(
        run_id=run_id,
        client=mock_client,
        cursor=0,
        enable_heartbeats=False,
        legacy=False,
    )

    chunks = []
    async for chunk in streamer.stream_bytes():
        chunks.append(chunk.decode("utf-8"))

    assert len(chunks) == 2
    p1 = json.loads(chunks[0])
    p2 = json.loads(chunks[1])
    assert p1["eventId"] == "evt_db_1"
    assert p1["eventType"] == "RUN_STARTED"
    assert p2["eventId"] == "evt_db_2"
    assert p2["eventType"] == "RUN_COMPLETED"


def test_replay_from_event_id_with_checkpoint_client():
    run_id = "run_db_event_id_replay"

    class MockClient:
        def get_outbox_events(self, r_id, after_sequence=0):
            all_evts = [
                {
                    "eventId": "evt_db_101",
                    "eventType": "RUN_STARTED",
                    "runId": r_id,
                    "sequence": 1,
                    "payloadJson": json.dumps({"topic": "Replay 101"}),
                    "createdAt": "2026-10-08T12:00:00Z",
                },
                {
                    "eventId": "evt_db_102",
                    "eventType": "SECTION_GENERATED",
                    "runId": r_id,
                    "sequence": 2,
                    "payloadJson": json.dumps({"sectionIndex": 1}),
                    "createdAt": "2026-10-08T12:02:00Z",
                },
                {
                    "eventId": "evt_db_103",
                    "eventType": "RUN_COMPLETED",
                    "runId": r_id,
                    "sequence": 3,
                    "payloadJson": json.dumps({"status": "COMPLETED"}),
                    "createdAt": "2026-10-08T12:05:00Z",
                },
            ]
            return [e for e in all_evts if e["sequence"] > after_sequence]

    mock_client = MockClient()
    # Event ID exists ONLY in the DB outbox
    replayed = replay_from_event_id(run_id, last_event_id="evt_db_101", client=mock_client)
    assert len(replayed) == 2
    assert replayed[0].event_id == "evt_db_102"
    assert replayed[0].sequence == 2
    assert replayed[1].event_id == "evt_db_103"
    assert replayed[1].sequence == 3


@pytest.mark.asyncio
async def test_streamer_terminal_publish_fails_closed_when_not_in_db():
    run_id = "run_db_unverified_terminal"

    class MockClientIncomplete:
        def resume_state(self, r_id):
            class State:
                status = "IN_PROGRESS"
            return State()

        def get_outbox_events(self, r_id, after_sequence=0):
            return []

    mock_client = MockClientIncomplete()
    streamer = EventStreamer(run_id=run_id, client=mock_client, enable_heartbeats=False)

    # Attempting to publish RUN_COMPLETED when PostgreSQL shows IN_PROGRESS must fail closed
    with pytest.raises(RuntimeError, match="Durable finalization fact missing in persistence store"):
        await streamer.publish(
            EventType.RUN_COMPLETED,
            {"runId": run_id, "status": "COMPLETED"},
        )
