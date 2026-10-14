"""Phase 13 — Distributed Tracing and Context Propagation.

Provides:
- ContextVar-based TracingContext for async/sync run_id, operation_id, span_id propagation.
- W3C TraceContext traceparent generation and parsing.
- Span lifecycle management (start_span, end_span) with in-memory collector.
- Bounded attributes sanitization.
"""

from __future__ import annotations

import contextvars
import secrets
import time
from dataclasses import dataclass, field
from typing import Any, Dict, List, Mapping, Optional, Sequence, Tuple

from app.observability.redaction import redact_payload, redact_text

# Context variables for tracing
_CURRENT_TRACE_ID: contextvars.ContextVar[Optional[str]] = contextvars.ContextVar(
    "_CURRENT_TRACE_ID", default=None
)
_CURRENT_SPAN_ID: contextvars.ContextVar[Optional[str]] = contextvars.ContextVar(
    "_CURRENT_SPAN_ID", default=None
)
_CURRENT_RUN_ID: contextvars.ContextVar[Optional[str]] = contextvars.ContextVar(
    "_CURRENT_RUN_ID", default=None
)
_CURRENT_OPERATION_ID: contextvars.ContextVar[Optional[str]] = contextvars.ContextVar(
    "_CURRENT_OPERATION_ID", default=None
)
_CURRENT_SEQUENCE: contextvars.ContextVar[int] = contextvars.ContextVar(
    "_CURRENT_SEQUENCE", default=0
)


def _generate_trace_id() -> str:
    return secrets.token_hex(16)  # 32 hex chars


def _generate_span_id() -> str:
    return secrets.token_hex(8)  # 16 hex chars


@dataclass
class Span:
    """Represents a single trace span."""

    name: str
    trace_id: str
    span_id: str
    parent_span_id: Optional[str] = None
    run_id: Optional[str] = None
    operation_id: Optional[str] = None
    sequence: int = 0
    start_time: float = field(default_factory=time.time)
    end_time: Optional[float] = None
    attributes: Dict[str, Any] = field(default_factory=dict)
    events: List[Dict[str, Any]] = field(default_factory=list)
    status: str = "UNSET"  # UNSET, OK, ERROR
    error_message: Optional[str] = None

    @property
    def duration_seconds(self) -> float:
        if self.end_time is None:
            return max(0.0, time.time() - self.start_time)
        return max(0.0, self.end_time - self.start_time)

    def set_attribute(self, key: str, value: Any) -> None:
        safe_val = redact_payload(value)
        self.attributes[str(key)] = safe_val

    def add_event(self, name: str, attributes: Optional[Mapping[str, Any]] = None) -> None:
        self.events.append({
            "name": str(name),
            "timestamp": time.time(),
            "attributes": redact_payload(dict(attributes or {})),
        })

    def finish(self, status: str = "OK", error: Optional[Exception | str] = None) -> None:
        self.end_time = time.time()
        self.status = str(status).upper()
        if error is not None:
            self.status = "ERROR"
            self.error_message = redact_text(str(error))


class TracingContext:
    """Manager and accessor for the current distributed trace state."""

    def __init__(self) -> None:
        self._spans: List[Span] = []

    @property
    def trace_id(self) -> Optional[str]:
        return _CURRENT_TRACE_ID.get()

    @property
    def span_id(self) -> Optional[str]:
        return _CURRENT_SPAN_ID.get()

    @property
    def run_id(self) -> Optional[str]:
        return _CURRENT_RUN_ID.get()

    @property
    def operation_id(self) -> Optional[str]:
        return _CURRENT_OPERATION_ID.get()

    @property
    def sequence(self) -> int:
        return _CURRENT_SEQUENCE.get()

    def increment_sequence(self) -> int:
        nxt = _CURRENT_SEQUENCE.get() + 1
        _CURRENT_SEQUENCE.set(nxt)
        return nxt

    def set_context(
        self,
        *,
        trace_id: Optional[str] = None,
        span_id: Optional[str] = None,
        run_id: Optional[str] = None,
        operation_id: Optional[str] = None,
        sequence: Optional[int] = None,
    ) -> None:
        if trace_id is not None:
            _CURRENT_TRACE_ID.set(trace_id)
        if span_id is not None:
            _CURRENT_SPAN_ID.set(span_id)
        if run_id is not None:
            _CURRENT_RUN_ID.set(run_id)
        if operation_id is not None:
            _CURRENT_OPERATION_ID.set(operation_id)
        if sequence is not None:
            _CURRENT_SEQUENCE.set(sequence)

    def extract_traceparent(self, header_value: str) -> bool:
        """Parses W3C traceparent header: 00-{trace_id}-{parent_id}-{flags}."""
        if not header_value or not isinstance(header_value, str):
            return False
        parts = header_value.strip().split("-")
        if len(parts) != 4:
            return False
        version, trace_id, parent_id, _flags = parts
        if len(trace_id) == 32 and len(parent_id) == 16:
            _CURRENT_TRACE_ID.set(trace_id)
            _CURRENT_SPAN_ID.set(parent_id)
            return True
        return False

    def inject_traceparent(self) -> str:
        """Returns W3C traceparent header string."""
        tid = self.trace_id or _generate_trace_id()
        sid = self.span_id or _generate_span_id()
        return f"00-{tid}-{sid}-01"

    def start_span(
        self,
        name: str,
        *,
        attributes: Optional[Mapping[str, Any]] = None,
        run_id: Optional[str] = None,
        operation_id: Optional[str] = None,
    ) -> Span:
        curr_tid = self.trace_id or _generate_trace_id()
        parent_sid = self.span_id
        new_sid = _generate_span_id()

        _CURRENT_TRACE_ID.set(curr_tid)
        _CURRENT_SPAN_ID.set(new_sid)

        eff_run_id = run_id or self.run_id
        if eff_run_id:
            _CURRENT_RUN_ID.set(eff_run_id)

        eff_op_id = operation_id or self.operation_id
        if eff_op_id:
            _CURRENT_OPERATION_ID.set(eff_op_id)

        seq = self.increment_sequence()

        span = Span(
            name=name,
            trace_id=curr_tid,
            span_id=new_sid,
            parent_span_id=parent_sid,
            run_id=eff_run_id,
            operation_id=eff_op_id,
            sequence=seq,
        )
        if attributes:
            for k, v in attributes.items():
                span.set_attribute(k, v)

        self._spans.append(span)
        return span

    def get_collected_spans(self) -> List[Span]:
        return list(self._spans)

    def clear(self) -> None:
        self._spans.clear()
        _CURRENT_TRACE_ID.set(None)
        _CURRENT_SPAN_ID.set(None)
        _CURRENT_RUN_ID.set(None)
        _CURRENT_OPERATION_ID.set(None)
        _CURRENT_SEQUENCE.set(0)

_DEFAULT_TRACING = TracingContext()


def get_tracing_context() -> TracingContext:
    return _DEFAULT_TRACING
