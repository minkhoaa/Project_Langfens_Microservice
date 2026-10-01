"""Canonical Domain Event Contracts for Langfens Loop Engine V2."""

from __future__ import annotations

from datetime import datetime, timezone
from enum import Enum
from typing import Any, Optional
from pydantic import Field

from .base import CanonicalBaseModel


class EventType(str, Enum):
    RUN_STARTED = "RUN_STARTED"
    CHECKPOINT_SAVED = "CHECKPOINT_SAVED"
    ARTIFACT_PRODUCED = "ARTIFACT_PRODUCED"
    EVALUATION_COMPLETED = "EVALUATION_COMPLETED"
    ISSUE_RECORDED = "ISSUE_RECORDED"
    LOOP_DECIDED = "LOOP_DECIDED"
    OPERATION_GRANTED = "OPERATION_GRANTED"
    RUN_COMPLETED = "RUN_COMPLETED"
    RUN_FAILED = "RUN_FAILED"


class DomainEvent(CanonicalBaseModel):
    """Immutable domain event for telemetry, outbox streaming, and audit replay."""

    event_id: str = Field(..., alias="eventId")
    event_type: EventType = Field(..., alias="eventType")
    run_id: str = Field(..., alias="runId")
    section_id: Optional[int] = Field(default=None, alias="sectionId")
    epoch: int = Field(default=1, ge=1)
    idempotency_key: str = Field(..., alias="idempotencyKey")
    timestamp: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc),
    )
    data: Any
