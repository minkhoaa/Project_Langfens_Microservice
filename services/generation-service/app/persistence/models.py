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
    promptTokensUsed: Optional[int] = None
    completionTokensUsed: Optional[int] = None
    reasoningTokensUsed: Optional[int] = None
    costUsedUsd: float = 0.0
    accountingType: str = "UNKNOWN"
    resultRefJson: Optional[str] = None
    resolvedFingerprints: Optional[List[str]] = None
    supersededFingerprints: Optional[List[str]] = None

class OperationReconcileResult(CanonicalBaseModel):
    operationId: str
    status: str
    tokensUsed: int
    wallTimeUsedSeconds: float
    reconciledAt: datetime
    reservationBreached: bool = False
    budgetBreachDetected: bool = False


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
    resultRefJson: Optional[str] = None
    reservationBreached: bool = False
    budgetBreachDetected: bool = False

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

    def to_ref(self) -> ArtifactRef:
        from app.contracts.artifact import ArtifactRef, ArtifactType
        return ArtifactRef(
            artifactId=self.artifactId,
            artifactType=ArtifactType(self.artifactType),
            version=self.acceptedVersion,
            contentHash=self.acceptedHash,
        )

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
    promptTokensUsed: Optional[int] = None
    completionTokensUsed: Optional[int] = None
    reasoningTokensUsed: Optional[int] = None
    accountingType: str = "UNKNOWN"
    reservationBreached: bool = False
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
    budgetProfileVersion: Optional[str] = None
    budgetProfileSha256: Optional[str] = None
    budgetProfileSource: Optional[str] = None
    budgetProfileJson: Optional[str] = None
    budgetBreachDetected: bool = False
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


class BenchmarkCampaignCreateRequest(CanonicalBaseModel):
    campaignId: str
    authorizationId: str
    authorizedBy: str
    corpusSha256: str
    configSha256: str
    budgetCapCalls: int
    budgetCapTokens: int
    budgetCapWallTimeSeconds: float


class BenchmarkCaseProvisionRequest(CanonicalBaseModel):
    campaignId: str
    caseId: str
    claimId: str
    leaseOwner: UUID


class BenchmarkCaseCompleteRequest(CanonicalBaseModel):
    campaignId: str
    caseId: str
    claimId: str
    epoch: int
    leaseOwner: UUID


class BenchmarkCaseProvisionResult(CanonicalBaseModel):
    campaignId: str
    caseId: str
    runId: str
    jobId: UUID
    status: str
    epoch: int
    leaseOwner: UUID
    claimId: str
    leaseUntil: Optional[datetime] = None
    alreadyCompleted: bool = False
    operationCount: int = 0
    unknownOperationCount: int = 0
    completedOperationCount: int = 0


class BenchmarkCaseStatus(CanonicalBaseModel):
    caseId: str
    runId: str
    status: str
    epoch: int
    runCallCap: int
    runCallsUsed: int
    runTokenCap: int
    runTokensUsed: int
    runWallTimeCapSeconds: float
    runWallTimeUsedSeconds: float
    operationCount: int
    unknownOperationCount: int
    completedOperationCount: int


class BenchmarkCampaignStatus(CanonicalBaseModel):
    campaignId: str
    authorizationId: str
    authorizedBy: str
    corpusSha256: str
    configSha256: str
    status: str
    budgetCapCalls: int
    budgetUsedCalls: int
    budgetCapTokens: int
    budgetUsedTokens: int
    budgetCapWallTimeSeconds: float
    budgetUsedWallTimeSeconds: float
    createdAt: datetime
    updatedAt: datetime
    budgetBreachDetected: bool = False
    budgetBreachReason: Optional[str] = None
    cases: List[BenchmarkCaseStatus] = Field(default_factory=list)


class OutboxEventRecord(CanonicalBaseModel):
    id: UUID
    runId: str
    eventId: str
    eventType: str
    idempotencyKey: str
    epoch: int
    payloadJson: str
    status: str
    createdAt: datetime
    sequence: int = 0
