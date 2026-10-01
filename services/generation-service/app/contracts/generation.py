"""Canonical Generation Run & Resource Budget Contracts."""

from __future__ import annotations

from datetime import datetime, timezone
from enum import Enum
from typing import List, Optional
from pydantic import Field

from .base import CanonicalBaseModel


class SectionSlotStatus(str, Enum):
    PENDING = "PENDING"
    IN_PROGRESS = "IN_PROGRESS"
    COMPLETED = "COMPLETED"
    FAILED = "FAILED"


class OperationStatus(str, Enum):
    GRANTED = "GRANTED"
    CONSUMED = "CONSUMED"
    EXPIRED = "EXPIRED"
    RELEASED = "RELEASED"


class BudgetStatus(str, Enum):
    ACTIVE = "ACTIVE"
    EXHAUSTED = "EXHAUSTED"
    RELEASED = "RELEASED"


class RunIdentity(CanonicalBaseModel):
    """Immutable identity identifying a generation run and fencing epoch."""

    run_id: str = Field(..., alias="runId")
    job_id: str = Field(..., alias="jobId")
    epoch: int = Field(default=1, ge=1)
    lease_owner: Optional[str] = Field(default=None, alias="leaseOwner")
    created_at: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc),
        alias="createdAt",
    )


class SectionSlot(CanonicalBaseModel):
    """Slot for a specific section within the paper."""

    slot_number: int = Field(..., ge=1, le=3, alias="slotNumber")
    topic: Optional[str] = None
    status: SectionSlotStatus = SectionSlotStatus.PENDING
    completed_artifact_id: Optional[str] = Field(default=None, alias="completedArtifactId")
    completed_at: Optional[datetime] = Field(default=None, alias="completedAt")


class OperationGrant(CanonicalBaseModel):
    """Persisted grant permitting a bounded operation (e.g. LLM call) before side effect."""

    grant_id: str = Field(..., alias="grantId")
    run_id: str = Field(..., alias="runId")
    operation_name: str = Field(..., alias="operationName")
    max_tokens: int = Field(..., ge=1, alias="maxTokens")
    timeout_seconds: float = Field(default=60.0, ge=1.0, alias="timeoutSeconds")
    status: OperationStatus = OperationStatus.GRANTED
    granted_at: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc),
        alias="grantedAt",
    )
    expires_at: Optional[datetime] = Field(default=None, alias="expiresAt")


class BudgetReservation(CanonicalBaseModel):
    """Bounded resource budget reservation enforcing hard caps across a run."""

    reservation_id: str = Field(..., alias="reservationId")
    run_id: str = Field(..., alias="runId")
    max_calls: int = Field(..., ge=1, alias="maxCalls")
    max_tokens: int = Field(..., ge=1, alias="maxTokens")
    cost_cap_usd: Optional[float] = Field(default=None, ge=0.0, alias="costCapUsd")
    calls_consumed: int = Field(default=0, ge=0, alias="callsConsumed")
    tokens_consumed: int = Field(default=0, ge=0, alias="tokensConsumed")
    status: BudgetStatus = BudgetStatus.ACTIVE

    def is_exhausted(self) -> bool:
        """Returns True if call cap or token cap has been reached or exceeded."""
        return self.calls_consumed >= self.max_calls or self.tokens_consumed >= self.max_tokens


class GenerationRun(CanonicalBaseModel):
    """State tracking for a full generation run."""

    identity: RunIdentity
    slots: List[SectionSlot] = Field(default_factory=list)
    budget: BudgetReservation
    status: str = "PENDING"
    created_at: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc),
        alias="createdAt",
    )
