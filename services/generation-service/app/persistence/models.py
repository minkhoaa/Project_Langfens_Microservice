from datetime import datetime
from typing import Any, Dict, List, Optional
from uuid import UUID
from pydantic import Field

from app.contracts.base import CanonicalBaseModel
from app.contracts.artifact import ArtifactEnvelope, ArtifactRef
from app.contracts.evaluation import EvaluationResult
from app.contracts.issue import Issue
from app.contracts.loop import LoopDecision
from app.contracts.event import DomainEvent


class OperationGrantRequest(CanonicalBaseModel):
    runId: str
    epoch: int
    leaseOwner: UUID
    operationId: str
    operationType: str
    requestHash: str
    tokenReservation: int
    costReservationUsd: float = 0.0
    wallTimeReservationSeconds: float = 60.0
    sectionId: Optional[str] = None
    artifactId: Optional[str] = None
    parentOperationId: Optional[str] = None


class OperationReconcileRequest(CanonicalBaseModel):
    runId: str
    epoch: int
    leaseOwner: UUID
    operationId: str
    tokensUsed: int
    wallTimeUsedSeconds: float
    costUsedUsd: float = 0.0
    accountingType: str = "REPORTED"
    resultRefJson: Optional[str] = None
    resolvedFingerprints: Optional[List[str]] = None
    supersededFingerprints: Optional[List[str]] = None

class OperationReconcileResult(CanonicalBaseModel):
    operationId: str
    status: str
    tokensUsed: int
    wallTimeUsedSeconds: float
    reconciledAt: datetime


class BudgetAllocationItem(CanonicalBaseModel):
    scopeType: str
    scopeId: str
    parentScopeId: Optional[str] = None
    tokenCap: int
    callCap: int = 5
    wallTimeCapSeconds: int = 300


class SetBudgetAllocationsRequest(CanonicalBaseModel):
    runId: str
    epoch: int
    leaseOwner: UUID
    allocations: List[BudgetAllocationItem]


class SetBudgetAllocationsResult(CanonicalBaseModel):
    runId: str
    allocationsCount: int
    updatedAt: datetime

class OperationGrantResult(CanonicalBaseModel):
    operationId: str
    runId: str
    status: str
    tokenReservation: int
    wallTimeReservationSeconds: float = 60.0
    grantedAt: datetime
    isReplay: bool = False

class CheckpointCommitRequest(CanonicalBaseModel):
    runId: str
    epoch: int
    leaseOwner: UUID
    operationId: str
    requestHash: str
    artifact: ArtifactEnvelope
    evaluations: Optional[List[EvaluationResult]] = None
    decision: Optional[LoopDecision] = None
    expectedHeadVersion: Optional[int] = None
    events: Optional[List[DomainEvent]] = None
    requiredEvaluatorIds: Optional[List[str]] = None
    tokensUsed: int = 0
    costUsedUsd: float = 0.0
    wallTimeUsedSeconds: float = 0.0

class DraftCheckpointRequest(CanonicalBaseModel):
    runId: str
    epoch: int
    leaseOwner: UUID
    operationId: str
    requestHash: str
    artifact: ArtifactEnvelope
    tokensUsed: int = 0
    costUsedUsd: float = 0.0
    wallTimeUsedSeconds: float = 0.0

class CheckpointAck(CanonicalBaseModel):
    runId: str
    epoch: int
    artifactId: str
    version: int
    contentHash: str
    serverTimestampUtc: datetime
    isReplay: bool = False


class UnknownOutcomeRequest(CanonicalBaseModel):
    runId: str
    epoch: int
    leaseOwner: UUID
    operationId: str
    errorMessage: str


class UnknownOutcomeAck(CanonicalBaseModel):
    operationId: str
    status: str
    reservationPreserved: bool
    recordedAt: datetime


class ArtifactResumeInfo(CanonicalBaseModel):
    artifactId: str
    artifactType: str
    acceptedVersion: int
    acceptedHash: str
    payloadJson: str
    parentRefs: List[ArtifactRef] = Field(default_factory=list)
    isStale: bool = False
    envelopeJson: Optional[str] = None


class LoopCursorCheckpointRequest(CanonicalBaseModel):
    runId: str
    epoch: int
    leaseOwner: UUID
    artifactId: str
    expectedRevision: int
    stateJson: str
    lastOperationId: Optional[str] = None


class LoopCursorCheckpoint(CanonicalBaseModel):
    artifactId: str
    revision: int
    stateJson: str
    lastOperationId: Optional[str] = None


class OperationResumeInfo(CanonicalBaseModel):
    operationId: str
    operationType: str
    status: str
    artifactId: Optional[str] = None
    requestHash: str
    tokenReservation: int
    tokensUsed: int
    wallTimeReservationSeconds: float
    wallTimeUsedSeconds: float
    resultRefJson: Optional[str] = None
    parentOperationId: Optional[str] = None
class ResumeStateResult(CanonicalBaseModel):
    runId: str
    jobId: UUID
    epoch: int
    status: str
    engineVersion: str
    schemaVersion: str
    policyVersion: str
    artifacts: List[ArtifactResumeInfo] = Field(default_factory=list)
    isCompatible: bool = True
    incompatibilityReason: Optional[str] = None
    tokensUsed: int = 0
    callsUsed: int = 0
    wallTimeUsedSeconds: float = 0.0
    budgetCapCalls: int = 25
    budgetCapTokens: int = 150000
    budgetCapWallTimeSeconds: int = 900
    createdAt: Optional[datetime] = None
    hardDeadlineAt: Optional[datetime] = None
    draftArtifacts: Optional[List[ArtifactResumeInfo]] = None
    issues: Optional[List[Issue]] = None
    evaluations: Optional[List[EvaluationResult]] = None
    loopCursors: Optional[List[LoopCursorCheckpoint]] = None
    operations: Optional[List[OperationResumeInfo]] = None
class InvalidateDependencyRequest(CanonicalBaseModel):
    runId: str
    epoch: int
    leaseOwner: UUID
    targetArtifactId: str
    reason: str


class InvalidateDependencyResult(CanonicalBaseModel):
    runId: str
    invalidatedArtifactIds: List[str]
    preservedArtifactIds: List[str]


class BuildExamInternalRequest(CanonicalBaseModel):
    runId: str
    epoch: int
    leaseOwner: UUID
    jobId: UUID


class BuildExamInternalResult(CanonicalBaseModel):
    examId: UUID
    slug: str
    isExisting: bool = False
