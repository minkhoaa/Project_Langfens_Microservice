"""Context, Authority, Budget and Resume Cursor for Loop Engine V2."""

from __future__ import annotations

from datetime import datetime, timezone
import time
from typing import Any, Callable, Dict, Optional, Sequence, Tuple
from uuid import UUID, uuid4
from pydantic import ConfigDict, Field

from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.base import CanonicalBaseModel
from app.contracts.issue import Issue, IssueScope
from app.contracts.loop import LoopState


class AuthorityGrant(CanonicalBaseModel):
    """Authority grant carrying lease owner UUID, fencing epoch, and cancellation check."""

    lease_owner: UUID = Field(..., alias="leaseOwner")
    epoch: int = Field(..., ge=0)
    revoked: bool = False

    def is_authority_active(self, current_lease_owner: Optional[UUID] = None, current_epoch: Optional[int] = None) -> bool:
        """Verifies if the current authority is still active and uncontested."""
        if self.revoked:
            return False
        if current_lease_owner is not None and current_lease_owner != self.lease_owner:
            return False
        if current_epoch is not None and current_epoch != self.epoch:
            return False
        return True


class BudgetTracker(CanonicalBaseModel):
    """Tracks cumulative usage and enforces bounded caps."""

    model_config = ConfigDict(
        frozen=False,
        populate_by_name=True,
        extra="forbid",
    )

    calls_used: int = Field(default=0, alias="callsUsed")
    tokens_used: int = Field(default=0, alias="tokensUsed")
    wall_time_used_seconds: float = Field(default=0.0, alias="wallTimeUsedSeconds")
    versions_used: int = Field(default=0, alias="versionsUsed")
    repairs_used: int = Field(default=0, alias="repairsUsed")
    started_at: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc),
        alias="startedAt",
    )

    def record_usage(self, tokens: int = 0, wall_time_s: float = 0.0, calls: int = 1) -> None:
        """Records token and wall time usage, advancing call count."""
        self.tokens_used += max(0, tokens)
        self.wall_time_used_seconds += max(0.0, wall_time_s)
        self.calls_used += max(0, calls)

    def record_version(self) -> int:
        """Records generation of a new version."""
        self.versions_used += 1
        return self.versions_used

    def record_repair(self) -> int:
        """Records a repair attempt."""
        self.repairs_used += 1
        return self.repairs_used

    def get_elapsed_seconds(self) -> float:
        """Calculates actual wall time elapsed since tracker initialization."""
        now = datetime.now(timezone.utc)
        elapsed = (now - self.started_at).total_seconds()
        return max(self.wall_time_used_seconds, elapsed)

class ResumeCursor(CanonicalBaseModel):
    """Durable resume cursor identifying current step, state, and committed artifact version."""

    model_config = ConfigDict(
        frozen=False,
        populate_by_name=True,
        extra="forbid",
    )

    step_index: int = Field(default=0, alias="stepIndex")
    revision: int = Field(default=0, ge=0)
    current_state: LoopState = Field(default=LoopState.INITIALIZED, alias="currentState")
    target_version: int = Field(default=0, alias="targetVersion")
    target_artifact_id: Optional[str] = Field(default=None, alias="targetArtifactId")
    target_content_hash: Optional[str] = Field(default=None, alias="targetContentHash")
    last_operation_id: Optional[str] = Field(default=None, alias="lastOperationId")
    last_ack_hash: Optional[str] = Field(default=None, alias="lastAckHash")
    updated_at: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc),
        alias="updatedAt",
    )

    def advance(
        self,
        next_state: LoopState,
        operation_id: Optional[str] = None,
        ack_hash: Optional[str] = None,
        version: Optional[int] = None,
        content_hash: Optional[str] = None,
        op_id: Optional[str] = None,
    ) -> ResumeCursor:
        """Advances the cursor to the next state, incrementing step_index."""
        self.step_index += 1
        self.current_state = next_state
        actual_op_id = operation_id or op_id
        if actual_op_id is not None:
            self.last_operation_id = actual_op_id
        if ack_hash is not None:
            self.last_ack_hash = ack_hash
        if version is not None:
            self.target_version = version
        if content_hash is not None:
            self.target_content_hash = content_hash
        self.updated_at = datetime.now(timezone.utc)
        return self


class LoopContext(CanonicalBaseModel):
    """Execution context for a bounded LoopRuntime run."""

    model_config = ConfigDict(
        frozen=False,
        populate_by_name=True,
        extra="forbid",
    )

    run_id: str = Field(..., alias="runId")
    scope: IssueScope
    target_artifact_id: str = Field(..., alias="targetArtifactId")
    target_artifact_type: ArtifactType = Field(..., alias="targetArtifactType")
    section_id: Optional[int] = Field(default=None, alias="sectionId")
    authority: AuthorityGrant
    input_dependencies: Tuple[ArtifactRef, ...] = Field(default_factory=tuple, alias="inputDependencies")
    policy_version: str = Field(default="2.0.0", alias="policyVersion")
    budget_tracker: BudgetTracker = Field(default_factory=BudgetTracker, alias="budgetTracker")
    cursor: ResumeCursor = Field(default_factory=ResumeCursor, alias="cursor")
    current_artifact: Optional[ArtifactEnvelope] = Field(default=None, alias="currentArtifact")
    accepted_artifact: Optional[ArtifactEnvelope] = Field(default=None, alias="acceptedArtifact")
    is_cancelled_func: Optional[Callable[[], bool]] = Field(default=None, exclude=True)
    open_issues: Tuple[Issue, ...] = Field(default_factory=tuple, alias="openIssues")
    parent_operation_id: Optional[str] = Field(default=None, alias="parentOperationId")
    def is_cancelled(self) -> bool:
        """Checks if a cancellation signal has been raised."""
        if self.is_cancelled_func is not None:
            try:
                return bool(self.is_cancelled_func())
            except Exception:
                return True
        return False

    def check_authority(self, current_lease_owner: Optional[UUID] = None, current_epoch: Optional[int] = None) -> bool:
        """Validates that this context still holds valid lease authority and is not cancelled."""
        if self.is_cancelled():
            return False
        return self.authority.is_authority_active(current_lease_owner, current_epoch)
