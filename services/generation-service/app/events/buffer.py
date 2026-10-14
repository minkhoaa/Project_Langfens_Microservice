"""Bounded Event Ring Buffer for Backpressure and Client Isolation (Phase 13).

Provides a bounded async queue/ring buffer with:
1. Maximum capacity (default 1000 events).
2. Non-blocking push so slow streaming clients NEVER block loop execution or checkpoints.
3. Drop-oldest-non-terminal policy when saturated, ensuring terminal events (RUN_COMPLETED,
   RUN_FAILED) are NEVER dropped.
4. Async iteration and graceful drain/close semantics.
"""

from __future__ import annotations

import asyncio
from collections import deque
import logging
from typing import AsyncIterator, Optional

from app.contracts.event import EventEnvelope
from app.events.taxonomy import is_terminal


logger = logging.getLogger(__name__)

DEFAULT_BUFFER_CAPACITY = 1000


class BoundedEventBuffer:
    """Bounded, async-iterable event buffer with non-blocking backpressure protection."""

    def __init__(self, capacity: int = DEFAULT_BUFFER_CAPACITY):
        self.capacity = max(10, capacity)
        self._queue: deque[EventEnvelope] = deque()
        self._lock = asyncio.Lock()
        self._has_item = asyncio.Event()
        self._closed = False
        self._dropped_count = 0
        self._total_enqueued = 0

    @property
    def dropped_count(self) -> int:
        """Total number of non-terminal events dropped due to buffer saturation."""
        return self._dropped_count

    @property
    def total_enqueued(self) -> int:
        """Total number of events accepted into the buffer."""
        return self._total_enqueued

    @property
    def is_closed(self) -> bool:
        """Whether the buffer is closed for new events."""
        return self._closed

    def size(self) -> int:
        """Current number of items in the buffer."""
        return len(self._queue)

    def put_nowait(self, envelope: EventEnvelope) -> bool:
        """Non-blocking put. Drops oldest non-terminal item if buffer is full."""
        if self._closed:
            return False

        if len(self._queue) >= self.capacity:
            # Saturated buffer: drop oldest non-terminal event
            dropped = False
            # Find and remove oldest non-terminal
            for i in range(len(self._queue)):
                if not is_terminal(self._queue[i].event_type):
                    del self._queue[i]
                    self._dropped_count += 1
                    dropped = True
                    logger.warning(
                        "BoundedEventBuffer saturated (cap=%d); dropped oldest non-terminal event for run %s",
                        self.capacity,
                        envelope.run_id,
                    )
                    break

            if not dropped:
                # If all items are terminal and new item is non-terminal, drop the incoming one
                if not is_terminal(envelope.event_type):
                    self._dropped_count += 1
                    logger.warning(
                        "BoundedEventBuffer saturated with terminal events; dropped incoming non-terminal event %s",
                        envelope.event_type,
                    )
                    return False
                # If incoming is terminal, append regardless
                self._queue.append(envelope)
                self._total_enqueued += 1
                self._has_item.set()
                return True

        self._queue.append(envelope)
        self._total_enqueued += 1
        self._has_item.set()
        return True

    async def put(self, envelope: EventEnvelope) -> bool:
        """Async put wrapper (always non-blocking to prevent execution starvation)."""
        async with self._lock:
            return self.put_nowait(envelope)

    async def get(self) -> Optional[EventEnvelope]:
        """Async get next event. Returns None when closed and drained."""
        while True:
            async with self._lock:
                if self._queue:
                    item = self._queue.popleft()
                    if not self._queue and not self._closed:
                        self._has_item.clear()
                    return item
                if self._closed:
                    return None

            await self._has_item.wait()

    def close(self) -> None:
        """Signal that no more events will be added to the buffer."""
        self._closed = True
        self._has_item.set()

    def __aiter__(self) -> AsyncIterator[EventEnvelope]:
        return self

    async def __anext__(self) -> EventEnvelope:
        item = await self.get()
        if item is None:
            raise StopAsyncIteration
        return item


__all__ = [
    "DEFAULT_BUFFER_CAPACITY",
    "BoundedEventBuffer",
]
