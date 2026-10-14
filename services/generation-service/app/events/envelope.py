"""Authoritative Event Envelope Construction & Sanitization (Phase 13).

Provides factory functions for creating v2.0.0 EventEnvelope instances with
automatic sanitization (redacting sk-... keys, Bearer tokens, secrets,
<thinking> CoT blocks, and copyright notices) while preserving unicode and
structured domain fields.
"""

from __future__ import annotations

from datetime import datetime, timezone
import re
from typing import Any, Dict, Mapping, Optional, Union
import uuid

from app.contracts.artifact import ArtifactRef
from app.contracts.event import (
    ENGINE_VERSION,
    SCHEMA_VERSION,
    EventEnvelope,
    EventType,
)


# ---------------------------------------------------------------------------
# Redaction Patterns
# ---------------------------------------------------------------------------

_API_KEY_REGEX = re.compile(r"\b(?:sk-[A-Za-z0-9_-]{20,}|Bearer\s+[A-Za-z0-9._~+/-]+=*)\b", re.IGNORECASE)
_SECRET_KEY_REGEX = re.compile(r"(?i)\b(?:password|secret|api_?key|auth_?token)\s*[:=]\s*['\"]?([^\s'\"]+)['\"]?")
_THINKING_REGEX = re.compile(r"<thinking>.*?</thinking>", re.DOTALL | re.IGNORECASE)
_COPYRIGHT_REGEX = re.compile(r"(?i)(?:©|\bcopyright\b|\ball rights reserved\b)[^\n.]*", re.IGNORECASE)


def local_sanitize_string(text: str) -> str:
    """Sanitize string values by masking secrets, thinking tags, and copyright."""
    if not text:
        return text

    # Remove thinking tags
    text = _THINKING_REGEX.sub("[REDACTED_COT]", text)

    # Redact API keys / Bearer tokens
    text = _API_KEY_REGEX.sub("[REDACTED_SECRET]", text)

    # Redact password / secret assignments
    text = _SECRET_KEY_REGEX.sub(r"\1=[REDACTED_SECRET]", text)

    # Redact copyright notices
    text = _COPYRIGHT_REGEX.sub("[REDACTED_COPYRIGHT]", text)

    return text


def sanitize_payload(payload: Any) -> Any:
    """Recursively sanitize dictionary / list / string payloads.

    Attempts to delegate to ``app.observability.redaction`` if available;
    otherwise applies standard local pattern redaction.
    """
    try:
        from app.observability.redaction import redact_payload  # type: ignore
        return redact_payload(payload)
    except (ImportError, AttributeError):
        pass

    if isinstance(payload, str):
        return local_sanitize_string(payload)
    elif isinstance(payload, Mapping):
        return {k: sanitize_payload(v) for k, v in payload.items()}
    elif isinstance(payload, (list, tuple, set)):
        return [sanitize_payload(item) for item in payload]
    return payload


def generate_event_id() -> str:
    """Generate a unique event ID starting with evt_."""
    return f"evt_{uuid.uuid4().hex}"


def build_envelope(
    event_type: EventType | str,
    run_id: str,
    payload: Dict[str, Any] | Any,
    sequence: int,
    *,
    event_id: Optional[str] = None,
    operation_id: Optional[str] = None,
    artifact_ref: Optional[ArtifactRef] = None,
    timestamp: Optional[datetime] = None,
    schema_version: str = SCHEMA_VERSION,
    engine_version: str = ENGINE_VERSION,
    sanitize: bool = True,
) -> EventEnvelope:
    """Construct an authoritative, validated v2.0.0 EventEnvelope."""
    if isinstance(event_type, str):
        event_type = EventType(event_type)

    if sequence < 1:
        raise ValueError(f"Sequence must be monotonic >= 1, got {sequence}")

    raw_payload: Dict[str, Any]
    if hasattr(payload, "model_dump"):
        raw_payload = payload.model_dump(by_alias=True)
    elif isinstance(payload, dict):
        raw_payload = payload
    else:
        raw_payload = {"data": payload}

    clean_payload = sanitize_payload(raw_payload) if sanitize else raw_payload

    return EventEnvelope(
        eventId=event_id or generate_event_id(),
        sequence=sequence,
        timestamp=timestamp or datetime.now(timezone.utc),
        runId=run_id,
        operationId=operation_id,
        artifactRef=artifact_ref,
        schemaVersion=schema_version,
        engineVersion=engine_version,
        eventType=event_type,
        payload=clean_payload,
    )


__all__ = [
    "generate_event_id",
    "sanitize_payload",
    "local_sanitize_string",
    "build_envelope",
]
