"""Canonical Domain Event Contracts for Langfens Loop Engine V2 (Phase 13).

Defines the authoritative rich event envelope (v2.0.0), event taxonomy,
typed payloads, and legacy NDJSON projection rules.
"""

from __future__ import annotations

from datetime import datetime, timezone
from enum import Enum
from typing import Any, Dict, List, Literal, Mapping, Optional, Union
import uuid

from pydantic import Field

from .base import CanonicalBaseModel
from .artifact import ArtifactRef


SCHEMA_VERSION: str = "2.0.0"
ENGINE_VERSION: str = "2.0.0"


class EventType(str, Enum):
    """Canonical event taxonomy (12 event types)."""

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


# ---------------------------------------------------------------------------
# Typed Payload Models
# ---------------------------------------------------------------------------

class RunStartedPayload(CanonicalBaseModel):
    topic: str
    target_sections: int = Field(default=3, alias="targetSections")
    epoch: int = 1
    lease_owner: Optional[str] = Field(default=None, alias="leaseOwner")
    profile: Optional[str] = None
    started_at: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc),
        alias="startedAt",
    )


class CheckpointSavedPayload(CanonicalBaseModel):
    checkpoint_version: int = Field(..., alias="checkpointVersion")
    head_version: int = Field(..., alias="headVersion")
    state: str
    tokens_used: int = Field(default=0, alias="tokensUsed")
    cost_used_usd: float = Field(default=0.0, alias="costUsedUsd")


class ArtifactProducedPayload(CanonicalBaseModel):
    artifact_id: str = Field(..., alias="artifactId")
    artifact_type: str = Field(..., alias="artifactType")
    content_hash: str = Field(..., alias="contentHash")
    section_index: Optional[int] = Field(default=None, alias="sectionIndex")


class EvaluationCompletedPayload(CanonicalBaseModel):
    evaluator_id: str = Field(..., alias="evaluatorId")
    passed: bool
    score: float
    issues_count: int = Field(default=0, alias="issuesCount")


class IssueRecordedPayload(CanonicalBaseModel):
    issue_code: str = Field(..., alias="issueCode")
    severity: str
    message: str
    section_index: Optional[int] = Field(default=None, alias="sectionIndex")


class LoopDecidedPayload(CanonicalBaseModel):
    decision_type: str = Field(..., alias="decisionType")
    action: str
    reason: str
    target_component: Optional[str] = Field(default=None, alias="targetComponent")


class OperationGrantedPayload(CanonicalBaseModel):
    operation_id: str = Field(..., alias="operationId")
    operation_type: str = Field(..., alias="operationType")
    granted: bool = True
    reservation_id: Optional[str] = Field(default=None, alias="reservationId")


class SectionGeneratedPayload(CanonicalBaseModel):
    section_index: int = Field(..., alias="sectionIndex")
    title: str
    passage: Optional[str] = None
    groups: Optional[List[Dict[str, Any]]] = None
    source_pmcid: Optional[str] = Field(default=None, alias="sourcePmcid")
    raw_section: Optional[Dict[str, Any]] = Field(default=None, alias="rawSection")
    is_final: bool = Field(default=False, alias="isFinal")


class PaperGeneratedPayload(CanonicalBaseModel):
    paper_id: Optional[str] = Field(default=None, alias="paperId")
    title: str
    sections_count: int = Field(default=3, alias="sectionsCount")
    total_questions: int = Field(default=40, alias="totalQuestions")
    raw_paper: Optional[Dict[str, Any]] = Field(default=None, alias="rawPaper")
    is_final: bool = Field(default=False, alias="isFinal")


class RunCompletedPayload(CanonicalBaseModel):
    status: Literal["COMPLETED"] = "COMPLETED"
    run_id: str = Field(..., alias="runId")
    job_id: Optional[str] = Field(default=None, alias="jobId")
    exam_id: Optional[str] = Field(default=None, alias="examId")
    final_score: Optional[float] = Field(default=None, alias="finalScore")
    tokens_used: int = Field(default=0, alias="tokensUsed")
    cost_used_usd: float = Field(default=0.0, alias="costUsedUsd")
    result: Optional[Dict[str, Any]] = None
    durable_persistence_verified: bool = Field(default=True, alias="durablePersistenceVerified")


class RunFailedPayload(CanonicalBaseModel):
    status: Literal["FAILED"] = "FAILED"
    run_id: str = Field(..., alias="runId")
    http_status: int = Field(default=500, alias="httpStatus")
    error_code: str = Field(default="GENERATION_FAILED", alias="errorCode")
    message: str
    traceback: Optional[str] = None
    recoverable: bool = False


class HeartbeatPayload(CanonicalBaseModel):
    run_id: str = Field(..., alias="runId")
    timestamp: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc),
    )
    status: str = "IN_PROGRESS"
    active_operations: int = Field(default=0, alias="activeOperations")


# ---------------------------------------------------------------------------
# Authoritative Event Envelope (v2.0.0)
# ---------------------------------------------------------------------------

class EventEnvelope(CanonicalBaseModel):
    """Authoritative event envelope for telemetry, outbox, and audit replay."""

    event_id: str = Field(..., alias="eventId")
    sequence: int = Field(..., ge=1)
    timestamp: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc),
    )
    run_id: str = Field(..., alias="runId")
    operation_id: Optional[str] = Field(default=None, alias="operationId")
    artifact_ref: Optional[ArtifactRef] = Field(default=None, alias="artifactRef")
    schema_version: str = Field(default=SCHEMA_VERSION, alias="schemaVersion")
    engine_version: str = Field(default=ENGINE_VERSION, alias="engineVersion")
    event_type: EventType = Field(..., alias="eventType")
    payload: Dict[str, Any] = Field(default_factory=dict)


# Backward-compatible model for existing persistence and test callers
class DomainEvent(CanonicalBaseModel):
    """Legacy/Persistence domain event representation."""

    event_id: str = Field(..., alias="eventId")
    event_type: EventType = Field(..., alias="eventType")
    run_id: str = Field(..., alias="runId")
    section_id: Optional[int] = Field(default=None, alias="sectionId")
    epoch: int = Field(default=1, ge=1)
    idempotency_key: str = Field(..., alias="idempotencyKey")
    timestamp: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc),
    )
    data: Any = None


# ---------------------------------------------------------------------------
# Legacy NDJSON Projection
# ---------------------------------------------------------------------------

class LegacyProjector:
    """Projects rich v2.0.0 EventEnvelope instances into legacy NDJSON format.

    Legacy NDJSON only supports 3 shapes:
    1. {"type": "log", "level": "...", "message": "...", "runId": "..."}
    2. {"type": "result", "section": {...}}
    3. {"type": "error", "httpStatus": ..., "message": "...", "traceback": "..."}

    INVARIANT:
    {"type": "result", ...} is ONLY emitted from durable final persistence facts
    (RUN_COMPLETED or explicitly verified final artifacts). Intermediate progress
    events (SECTION_GENERATED, PAPER_GENERATED) are projected as log events to
    prevent premature legacy stream termination.
    """

    @staticmethod
    def project(envelope: EventEnvelope | Dict[str, Any]) -> Dict[str, Any]:
        """Project a v2 EventEnvelope to a legacy NDJSON line dict."""
        if isinstance(envelope, EventEnvelope):
            event_type = envelope.event_type
            payload = envelope.payload or {}
            run_id = envelope.run_id
        else:
            event_type = EventType(envelope.get("eventType", envelope.get("event_type")))
            payload = envelope.get("payload", {})
            run_id = envelope.get("runId", envelope.get("run_id", ""))

        if event_type == EventType.RUN_FAILED:
            http_status = payload.get("httpStatus", payload.get("http_status", 500))
            message = payload.get("message", "Generation failed")
            traceback = payload.get("traceback", "")
            return {
                "type": "error",
                "httpStatus": int(http_status),
                "message": str(message),
                "traceback": str(traceback) if traceback else "",
            }

        # Invariant: 'result' is emitted ONLY on final persistence fact (RUN_COMPLETED or isFinal=True)
        is_final = bool(
            event_type == EventType.RUN_COMPLETED
            or payload.get("isFinal") is True
            or payload.get("is_final") is True
            or payload.get("durablePersistenceVerified") is True
        )

        if is_final and event_type in (EventType.RUN_COMPLETED, EventType.SECTION_GENERATED, EventType.PAPER_GENERATED):
            # Extract section data
            section_data: Optional[Dict[str, Any]] = None
            if "rawSection" in payload and payload["rawSection"]:
                section_data = payload["rawSection"]
            elif "section" in payload and payload["section"]:
                section_data = payload["section"]
            elif "result" in payload and isinstance(payload["result"], dict) and "section" in payload["result"]:
                section_data = payload["result"]["section"]
            elif "result" in payload and isinstance(payload["result"], dict) and "groups" in payload["result"]:
                section_data = payload["result"]
            elif "title" in payload and "groups" in payload:
                section_data = {
                    "title": payload.get("title", ""),
                    "passage": payload.get("passage", ""),
                    "groups": payload.get("groups", []),
                    "source": payload.get("source", {}),
                }

            if section_data and "title" in section_data and "groups" in section_data:
                return {
                    "type": "result",
                    "section": section_data,
                }
            elif event_type == EventType.RUN_COMPLETED:
                return {
                    "type": "log",
                    "level": "Information",
                    "message": f"Run {run_id} completed successfully (persisted).",
                    "runId": run_id,
                }

        if event_type == EventType.HEARTBEAT:
            return {
                "type": "log",
                "level": "Debug",
                "message": f"Heartbeat for run {run_id}",
                "runId": run_id,
            }

        # All progress events project to log
        level = "Information"
        if event_type == EventType.ISSUE_RECORDED:
            level = "Warning" if payload.get("severity") != "CRITICAL" else "Error"
            msg = f"Issue recorded: {payload.get('issueCode', payload.get('issue_code', 'UNKNOWN'))} - {payload.get('message', '')}"
        elif event_type == EventType.EVALUATION_COMPLETED:
            msg = f"Evaluation completed: {payload.get('evaluatorId', payload.get('evaluator_id', ''))} (passed={payload.get('passed', False)})"
        elif event_type == EventType.CHECKPOINT_SAVED:
            msg = f"Checkpoint saved at version {payload.get('headVersion', payload.get('head_version', 0))}"
        elif event_type == EventType.LOOP_DECIDED:
            msg = f"Loop decision: {payload.get('action', '')} ({payload.get('reason', '')})"
        elif event_type == EventType.ARTIFACT_PRODUCED:
            msg = f"Artifact produced: {payload.get('artifactType', payload.get('artifact_type', ''))} ({payload.get('artifactId', payload.get('artifact_id', ''))})"
        elif event_type == EventType.SECTION_GENERATED:
            msg = f"Section generated: Section {payload.get('sectionIndex', payload.get('section_index', 1))} ('{payload.get('title', '')}')"
        elif event_type == EventType.PAPER_GENERATED:
            msg = f"Paper generated: '{payload.get('title', '')}' ({payload.get('sectionsCount', payload.get('sections_count', 3))} sections)"
        elif event_type == EventType.RUN_STARTED:
            msg = f"Run {run_id} started for topic '{payload.get('topic', '')}'"
        else:
            msg = f"Event {event_type.value} occurred"

        return {
            "type": "log",
            "level": level,
            "message": msg,
            "runId": run_id,
        }
