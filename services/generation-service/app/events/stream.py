"""Event Streaming, Heartbeat Isolation, and Backpressure Management (Phase 13).

Provides the unified EventStreamer engine for:
1. Pushing events into the persistent outbox and bounded buffer.
2. Background heartbeat isolation (default 5s interval) that never starves on slow consumers.
3. Legacy NDJSON vs Rich v2.0.0 event projection.
4. Safe disconnection handling: EOF without terminal persistence marks run as INCOMPLETE.
"""

from __future__ import annotations

import asyncio
from datetime import datetime, timezone
import json
import logging
from typing import Any, AsyncIterator, Dict, Optional, Union

from app.contracts.artifact import ArtifactRef
from app.contracts.event import EventEnvelope, EventType, LegacyProjector
from app.events.buffer import BoundedEventBuffer, DEFAULT_BUFFER_CAPACITY
from app.events.envelope import build_envelope
from app.events.outbox import EventOutbox, get_event_outbox
from app.events.replay import EventDeduplicator, replay_from_cursor
from app.events.taxonomy import is_terminal


logger = logging.getLogger(__name__)

DEFAULT_HEARTBEAT_INTERVAL_SECONDS = 5.0


class EventStreamer:
    """Orchestrates event publication, background heartbeat loop, buffer backpressure,

    and legacy vs rich NDJSON streaming.
    """

    def __init__(
        self,
        run_id: str,
        *,
        outbox: Optional[EventOutbox] = None,
        client: Optional[Any] = None,
        buffer_capacity: int = DEFAULT_BUFFER_CAPACITY,
        heartbeat_interval_seconds: float = DEFAULT_HEARTBEAT_INTERVAL_SECONDS,
        legacy: bool = False,
        cursor: int = 0,
        enable_heartbeats: bool = True,
    ):
        self.run_id = run_id
        self.outbox = outbox or get_event_outbox()
        self.client = client
        self.buffer = BoundedEventBuffer(capacity=buffer_capacity)
        self.heartbeat_interval = max(0.1, heartbeat_interval_seconds)
        self.legacy = legacy
        self.cursor = max(0, cursor)
        self.enable_heartbeats = enable_heartbeats
        self._heartbeat_task: Optional[asyncio.Task] = None
        self._deduplicator = EventDeduplicator(initial_max_seq=0)
        self._terminal_reached = False
        self._is_stopped = False
        self._lock = asyncio.Lock()
    async def start(self) -> None:
        """Start the background heartbeat task."""
        if self.enable_heartbeats and self._heartbeat_task is None:
            self._heartbeat_task = asyncio.create_task(self._run_heartbeat_loop())

    async def _run_heartbeat_loop(self) -> None:
        """Isolated background loop generating periodic heartbeat events."""
        try:
            while not self._terminal_reached and not self._is_stopped:
                await asyncio.sleep(self.heartbeat_interval)
                if self._terminal_reached or self._is_stopped:
                    break

                try:
                    envelope = build_envelope(
                        event_type=EventType.HEARTBEAT,
                        run_id=self.run_id,
                        payload={
                            "runId": self.run_id,
                            "timestamp": datetime.now(timezone.utc).isoformat(),
                            "status": "IN_PROGRESS",
                        },
                        sequence=1,  # Transport-level keepalive
                        sanitize=False,
                    )
                    await self.buffer.put(envelope)
                except Exception as e:
                    logger.debug("Failed to emit heartbeat for %s: %s", self.run_id, e)
        except asyncio.CancelledError:
            pass

    async def publish(
        self,
        event_type: EventType | str,
        payload: Dict[str, Any] | Any,
        *,
        event_id: Optional[str] = None,
        operation_id: Optional[str] = None,
        artifact_ref: Optional[ArtifactRef] = None,
        timestamp: Optional[datetime] = None,
        sanitize: bool = True,
    ) -> EventEnvelope:
        """Publish an event atomically into outbox and stream buffer."""
        if isinstance(event_type, str):
            event_type = EventType(event_type)

        # Invariant: If publishing a terminal event (RUN_COMPLETED), verify that
        # durable persistence fact is confirmed if client is present
        if event_type == EventType.RUN_COMPLETED and self.client is not None:
            if not self.outbox.has_terminal_fact(self.run_id, client=self.client):
                raise RuntimeError(
                    f"Durable finalization fact missing in persistence store for run {self.run_id}"
                )

        # 1. Append to in-memory buffer
        envelope = self.outbox.append(
            run_id=self.run_id,
            event_type=event_type,
            payload=payload,
            event_id=event_id,
            operation_id=operation_id,
            artifact_ref=artifact_ref,
            timestamp=timestamp,
            sanitize=sanitize,
        )

        if is_terminal(event_type):
            self._terminal_reached = True

        # 2. Push into non-blocking bounded buffer
        await self.buffer.put(envelope)

        if is_terminal(event_type):
            await self.stop()

        return envelope

    async def stop(self) -> None:
        """Cancel heartbeat task and close buffer."""
        self._is_stopped = True
        if self._heartbeat_task and not self._heartbeat_task.done():
            self._heartbeat_task.cancel()
            try:
                await self._heartbeat_task
            except asyncio.CancelledError:
                pass
            self._heartbeat_task = None
        self.buffer.close()

    def format_event_line(self, envelope: EventEnvelope) -> str:
        """Format an event envelope into a single-line JSON string according to legacy mode."""
        if self.legacy:
            projected = LegacyProjector.project(envelope)
            return json.dumps(projected, ensure_ascii=False) + "\n"
        else:
            data = envelope.model_dump(by_alias=True)
            # Ensure datetime is serialized to ISO8601
            if "timestamp" in data and isinstance(data["timestamp"], datetime):
                data["timestamp"] = data["timestamp"].isoformat()
            return json.dumps(data, ensure_ascii=False) + "\n"

    async def stream_bytes(
        self,
        *,
        client_disconnected: Optional[asyncio.Event] = None,
    ) -> AsyncIterator[bytes]:
        """Async iterator yielding UTF-8 encoded NDJSON bytes.

        Replays historical events first if cursor > 0, then streams live events.
        """
        await self.start()
        emitted_terminal = False

        try:
            # 1. Replay historical events from cursor
            if self.cursor >= 0:
                historical_events = replay_from_cursor(
                    self.run_id,
                    cursor=self.cursor,
                    outbox=self.outbox,
                    client=self.client,
                )
                for envelope in historical_events:
                    if self._deduplicator.track(envelope):
                        if is_terminal(envelope.event_type):
                            emitted_terminal = True
                        line = self.format_event_line(envelope)
                        yield line.encode("utf-8")

            # 2. Stream live buffer events
            if not emitted_terminal:
                async for envelope in self.buffer:
                    if client_disconnected and client_disconnected.is_set():
                        break

                    if self._deduplicator.track(envelope):
                        if is_terminal(envelope.event_type):
                            emitted_terminal = True
                        line = self.format_event_line(envelope)
                        yield line.encode("utf-8")

                    if emitted_terminal:
                        break

        except (asyncio.CancelledError, GeneratorExit):
            # Client disconnected mid-stream
            logger.info("Stream cancelled/disconnected for run %s", self.run_id)
        finally:
            await self.stop()
            # Invariant: If stream ended without emitting terminal fact, mark as INCOMPLETE
            if not emitted_terminal and not self.outbox.has_terminal_fact(self.run_id, client=self.client):
                self.outbox.mark_incomplete(self.run_id, "Stream disconnected without terminal event")


async def stream_events(
    run_id: str,
    *,
    outbox: Optional[EventOutbox] = None,
    client: Optional[Any] = None,
    legacy: bool = False,
    cursor: int = 0,
    buffer_capacity: int = DEFAULT_BUFFER_CAPACITY,
    heartbeat_interval_seconds: float = DEFAULT_HEARTBEAT_INTERVAL_SECONDS,
    client_disconnected: Optional[asyncio.Event] = None,
) -> AsyncIterator[bytes]:
    """Helper generator for FastAPI StreamingResponse or ASGI endpoints."""
    streamer = EventStreamer(
        run_id=run_id,
        outbox=outbox,
        client=client,
        buffer_capacity=buffer_capacity,
        heartbeat_interval_seconds=heartbeat_interval_seconds,
        legacy=legacy,
        cursor=cursor,
    )
    async for chunk in streamer.stream_bytes(client_disconnected=client_disconnected):
        yield chunk
__all__ = [
    "DEFAULT_HEARTBEAT_INTERVAL_SECONDS",
    "EventStreamer",
    "stream_events",
]
