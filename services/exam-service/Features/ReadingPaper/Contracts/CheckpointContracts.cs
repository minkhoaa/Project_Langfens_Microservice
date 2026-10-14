using System.Text.Json.Serialization;

namespace exam_service.Features.ReadingPaper.Contracts;

public sealed record OperationGrantRequest(
    [property: JsonPropertyName("runId")] string RunId,
    [property: JsonPropertyName("epoch")] int Epoch,
    [property: JsonPropertyName("leaseOwner")] Guid LeaseOwner,
    [property: JsonPropertyName("operationId")] string OperationId,
    [property: JsonPropertyName("operationType")] string OperationType,
    [property: JsonPropertyName("requestHash")] string RequestHash,
    [property: JsonPropertyName("tokenReservation")] int TokenReservation,
    [property: JsonPropertyName("costReservationUsd")] decimal CostReservationUsd = 0m,
    [property: JsonPropertyName("wallTimeReservationSeconds")] double WallTimeReservationSeconds = 60.0,
    [property: JsonPropertyName("sectionId")] string? SectionId = null,
    [property: JsonPropertyName("artifactId")] string? ArtifactId = null,
    [property: JsonPropertyName("parentOperationId")] string? ParentOperationId = null
);

public sealed record OperationReconcileRequest(
    [property: JsonPropertyName("runId")] string RunId,
    [property: JsonPropertyName("epoch")] int Epoch,
    [property: JsonPropertyName("leaseOwner")] Guid LeaseOwner,
    [property: JsonPropertyName("operationId")] string OperationId,
    [property: JsonPropertyName("tokensUsed")] int TokensUsed,
    [property: JsonPropertyName("wallTimeUsedSeconds")] double WallTimeUsedSeconds,
    [property: JsonPropertyName("costUsedUsd")] decimal CostUsedUsd = 0m,
    [property: JsonPropertyName("accountingType")] string AccountingType = "UNKNOWN",
    [property: JsonPropertyName("resultRefJson")] string? ResultRefJson = null,
    [property: JsonPropertyName("resolvedFingerprints")] List<string>? ResolvedFingerprints = null,
    [property: JsonPropertyName("supersededFingerprints")] List<string>? SupersededFingerprints = null,
    [property: JsonPropertyName("promptTokensUsed")] int? PromptTokensUsed = null,
    [property: JsonPropertyName("completionTokensUsed")] int? CompletionTokensUsed = null,
    [property: JsonPropertyName("reasoningTokensUsed")] int? ReasoningTokensUsed = null
);

public sealed record OperationReconcileResult(
    [property: JsonPropertyName("operationId")] string OperationId,
    [property: JsonPropertyName("status")] string Status,
    [property: JsonPropertyName("tokensUsed")] int TokensUsed,
    [property: JsonPropertyName("wallTimeUsedSeconds")] double WallTimeUsedSeconds,
    [property: JsonPropertyName("reconciledAt")] DateTime ReconciledAt,
    [property: JsonPropertyName("reservationBreached")] bool ReservationBreached = false,
    [property: JsonPropertyName("budgetBreachDetected")] bool BudgetBreachDetected = false
);

public sealed record BudgetAllocationItem(
    [property: JsonPropertyName("scopeType")] string ScopeType,
    [property: JsonPropertyName("scopeId")] string ScopeId,
    [property: JsonPropertyName("parentScopeId")] string? ParentScopeId,
    [property: JsonPropertyName("tokenCap")] int TokenCap,
    [property: JsonPropertyName("callCap")] int CallCap = 5,
    [property: JsonPropertyName("wallTimeCapSeconds")] int WallTimeCapSeconds = 300
);

public sealed record SetBudgetAllocationsRequest(
    [property: JsonPropertyName("runId")] string RunId,
    [property: JsonPropertyName("epoch")] int Epoch,
    [property: JsonPropertyName("leaseOwner")] Guid LeaseOwner,
    [property: JsonPropertyName("allocations")] List<BudgetAllocationItem> Allocations
);

public sealed record SetBudgetAllocationsResult(
    [property: JsonPropertyName("runId")] string RunId,
    [property: JsonPropertyName("allocationsCount")] int AllocationsCount,
    [property: JsonPropertyName("updatedAt")] DateTime UpdatedAt
);

public sealed record OperationGrantResult(
    [property: JsonPropertyName("operationId")] string OperationId,
    [property: JsonPropertyName("runId")] string RunId,
    [property: JsonPropertyName("status")] string Status,
    [property: JsonPropertyName("tokenReservation")] int TokenReservation,
    [property: JsonPropertyName("wallTimeReservationSeconds")] double WallTimeReservationSeconds = 60.0,
    [property: JsonPropertyName("grantedAt")] DateTime GrantedAt = default,
    [property: JsonPropertyName("isReplay")] bool IsReplay = false,
    [property: JsonPropertyName("resultRefJson")] string? ResultRefJson = null,
    [property: JsonPropertyName("reservationBreached")] bool ReservationBreached = false,
    [property: JsonPropertyName("budgetBreachDetected")] bool BudgetBreachDetected = false
);

public sealed record CheckpointCommitRequest(
    [property: JsonPropertyName("runId")] string RunId,
    [property: JsonPropertyName("epoch")] int Epoch,
    [property: JsonPropertyName("leaseOwner")] Guid LeaseOwner,
    [property: JsonPropertyName("operationId")] string OperationId,
    [property: JsonPropertyName("requestHash")] string RequestHash,
    [property: JsonPropertyName("artifact")] ArtifactEnvelope Artifact,
    [property: JsonPropertyName("evaluations")] List<EvaluationResult>? Evaluations = null,
    [property: JsonPropertyName("decision")] LoopDecision? Decision = null,
    [property: JsonPropertyName("expectedHeadVersion")] int? ExpectedHeadVersion = null,
    [property: JsonPropertyName("events")] List<DomainEvent>? Events = null,
    [property: JsonPropertyName("tokensUsed")] int TokensUsed = 0,
    [property: JsonPropertyName("costUsedUsd")] decimal CostUsedUsd = 0m,
    [property: JsonPropertyName("wallTimeUsedSeconds")] double WallTimeUsedSeconds = 0.0,
    [property: JsonPropertyName("resolvedFingerprints")] List<string>? ResolvedFingerprints = null,
    [property: JsonPropertyName("supersededFingerprints")] List<string>? SupersededFingerprints = null,
    [property: JsonPropertyName("requiredEvaluatorIds")] List<string>? RequiredEvaluatorIds = null
);

public sealed record DraftCheckpointRequest(
    [property: JsonPropertyName("runId")] string RunId,
    [property: JsonPropertyName("epoch")] int Epoch,
    [property: JsonPropertyName("leaseOwner")] Guid LeaseOwner,
    [property: JsonPropertyName("operationId")] string OperationId,
    [property: JsonPropertyName("requestHash")] string RequestHash,
    [property: JsonPropertyName("artifact")] ArtifactEnvelope Artifact,
    [property: JsonPropertyName("tokensUsed")] int TokensUsed = 0,
    [property: JsonPropertyName("costUsedUsd")] decimal CostUsedUsd = 0m,
    [property: JsonPropertyName("wallTimeUsedSeconds")] double WallTimeUsedSeconds = 0.0,
    [property: JsonPropertyName("resolvedFingerprints")] List<string>? ResolvedFingerprints = null,
    [property: JsonPropertyName("supersededFingerprints")] List<string>? SupersededFingerprints = null
);
public sealed record CheckpointAck(
    [property: JsonPropertyName("runId")] string RunId,
    [property: JsonPropertyName("epoch")] int Epoch,
    [property: JsonPropertyName("artifactId")] string ArtifactId,
    [property: JsonPropertyName("version")] int Version,
    [property: JsonPropertyName("contentHash")] string ContentHash,
    [property: JsonPropertyName("serverTimestampUtc")] DateTime ServerTimestampUtc,
    [property: JsonPropertyName("isReplay")] bool IsReplay = false
);

public sealed record UnknownOutcomeRequest(
    [property: JsonPropertyName("runId")] string RunId,
    [property: JsonPropertyName("epoch")] int Epoch,
    [property: JsonPropertyName("leaseOwner")] Guid LeaseOwner,
    [property: JsonPropertyName("operationId")] string OperationId,
    [property: JsonPropertyName("errorMessage")] string ErrorMessage
);

public sealed record UnknownOutcomeAck(
    [property: JsonPropertyName("operationId")] string OperationId,
    [property: JsonPropertyName("status")] string Status,
    [property: JsonPropertyName("reservationPreserved")] bool ReservationPreserved,
    [property: JsonPropertyName("recordedAt")] DateTime RecordedAt
);

public sealed record ArtifactResumeInfo(
    [property: JsonPropertyName("artifactId")] string ArtifactId,
    [property: JsonPropertyName("artifactType")] string ArtifactType,
    [property: JsonPropertyName("acceptedVersion")] int AcceptedVersion,
    [property: JsonPropertyName("acceptedHash")] string AcceptedHash,
    [property: JsonPropertyName("payloadJson")] string PayloadJson,
    [property: JsonPropertyName("parentRefs")] List<ArtifactRef> ParentRefs,
    [property: JsonPropertyName("isStale")] bool IsStale = false,
    [property: JsonPropertyName("envelopeJson")] string? EnvelopeJson = null
);
public sealed record LoopCursorCheckpointRequest(
    [property: JsonPropertyName("runId")] string RunId,
    [property: JsonPropertyName("epoch")] int Epoch,
    [property: JsonPropertyName("leaseOwner")] Guid LeaseOwner,
    [property: JsonPropertyName("artifactId")] string ArtifactId,
    [property: JsonPropertyName("expectedRevision")] int ExpectedRevision,
    [property: JsonPropertyName("stateJson")] string StateJson,
    [property: JsonPropertyName("lastOperationId")] string? LastOperationId = null
);

public sealed record LoopCursorCheckpoint(
    [property: JsonPropertyName("artifactId")] string ArtifactId,
    [property: JsonPropertyName("revision")] int Revision,
    [property: JsonPropertyName("stateJson")] string StateJson,
    [property: JsonPropertyName("lastOperationId")] string? LastOperationId
);

public sealed record OperationResumeInfo(
    [property: JsonPropertyName("operationId")] string OperationId,
    [property: JsonPropertyName("operationType")] string OperationType,
    [property: JsonPropertyName("status")] string Status,
    [property: JsonPropertyName("artifactId")] string? ArtifactId,
    [property: JsonPropertyName("requestHash")] string RequestHash,
    [property: JsonPropertyName("tokenReservation")] int TokenReservation,
    [property: JsonPropertyName("tokensUsed")] int TokensUsed,
    [property: JsonPropertyName("wallTimeReservationSeconds")] double WallTimeReservationSeconds,
    [property: JsonPropertyName("wallTimeUsedSeconds")] double WallTimeUsedSeconds,
    [property: JsonPropertyName("resultRefJson")] string? ResultRefJson,
    [property: JsonPropertyName("promptTokensUsed")] int? PromptTokensUsed = null,
    [property: JsonPropertyName("completionTokensUsed")] int? CompletionTokensUsed = null,
    [property: JsonPropertyName("reasoningTokensUsed")] int? ReasoningTokensUsed = null,
    [property: JsonPropertyName("accountingType")] string AccountingType = "UNKNOWN",
    [property: JsonPropertyName("reservationBreached")] bool ReservationBreached = false
);

public sealed record ResumeStateResult(
    [property: JsonPropertyName("runId")] string RunId,
    [property: JsonPropertyName("jobId")] Guid JobId,
    [property: JsonPropertyName("epoch")] int Epoch,
    [property: JsonPropertyName("status")] string Status,
    [property: JsonPropertyName("engineVersion")] string EngineVersion,
    [property: JsonPropertyName("schemaVersion")] string SchemaVersion,
    [property: JsonPropertyName("policyVersion")] string PolicyVersion,
    [property: JsonPropertyName("artifacts")] List<ArtifactResumeInfo> Artifacts,
    [property: JsonPropertyName("isCompatible")] bool IsCompatible = true,
    [property: JsonPropertyName("incompatibilityReason")] string? IncompatibilityReason = null,
    [property: JsonPropertyName("tokensUsed")] int TokensUsed = 0,
    [property: JsonPropertyName("callsUsed")] int CallsUsed = 0,
    [property: JsonPropertyName("wallTimeUsedSeconds")] double WallTimeUsedSeconds = 0.0,
    [property: JsonPropertyName("budgetCapCalls")] int BudgetCapCalls = 25,
    [property: JsonPropertyName("budgetCapTokens")] int BudgetCapTokens = 150000,
    [property: JsonPropertyName("budgetCapWallTimeSeconds")] int BudgetCapWallTimeSeconds = 900,
    [property: JsonPropertyName("createdAt")] DateTime? CreatedAt = null,
    [property: JsonPropertyName("hardDeadlineAt")] DateTime? HardDeadlineAt = null,
    [property: JsonPropertyName("draftArtifacts")] List<ArtifactResumeInfo>? DraftArtifacts = null,
    [property: JsonPropertyName("issues")] List<Issue>? Issues = null,
    [property: JsonPropertyName("evaluations")] List<EvaluationResult>? Evaluations = null,
    [property: JsonPropertyName("loopCursors")] List<LoopCursorCheckpoint>? LoopCursors = null,
    [property: JsonPropertyName("operations")] List<OperationResumeInfo>? Operations = null,
    [property: JsonPropertyName("budgetProfileVersion")] string? BudgetProfileVersion = null,
    [property: JsonPropertyName("budgetProfileSha256")] string? BudgetProfileSha256 = null,
    [property: JsonPropertyName("budgetProfileSource")] string? BudgetProfileSource = null,
    [property: JsonPropertyName("budgetProfileJson")] string? BudgetProfileJson = null,
    [property: JsonPropertyName("budgetBreachDetected")] bool BudgetBreachDetected = false
);

public sealed record InvalidateDependencyRequest(
    [property: JsonPropertyName("runId")] string RunId,
    [property: JsonPropertyName("epoch")] int Epoch,
    [property: JsonPropertyName("leaseOwner")] Guid LeaseOwner,
    [property: JsonPropertyName("targetArtifactId")] string TargetArtifactId,
    [property: JsonPropertyName("reason")] string Reason
);

public sealed record InvalidateDependencyResult(
    [property: JsonPropertyName("runId")] string RunId,
    [property: JsonPropertyName("invalidatedArtifactIds")] List<string> InvalidatedArtifactIds,
    [property: JsonPropertyName("preservedArtifactIds")] List<string> PreservedArtifactIds
);

public sealed record BuildExamInternalRequest(
    [property: JsonPropertyName("runId")] string RunId,
    [property: JsonPropertyName("epoch")] int Epoch,
    [property: JsonPropertyName("leaseOwner")] Guid LeaseOwner,
    [property: JsonPropertyName("jobId")] Guid JobId,
    [property: JsonPropertyName("finalEvaluations")] List<EvaluationResult>? FinalEvaluations = null
);

public sealed record BuildExamInternalResult(
    [property: JsonPropertyName("examId")] Guid ExamId,
    [property: JsonPropertyName("slug")] string Slug,
    [property: JsonPropertyName("isExisting")] bool IsExisting = false
);

public sealed record PublishExamRequest(
    [property: JsonPropertyName("examId")] Guid ExamId,
    [property: JsonPropertyName("slug")] string? Slug = null,
    [property: JsonPropertyName("runId")] string? RunId = null,
    [property: JsonPropertyName("actor")] string Actor = "system-admin-publish"
);

public sealed record PublishExamResult(
    [property: JsonPropertyName("examId")] Guid ExamId,
    [property: JsonPropertyName("slug")] string Slug,
    [property: JsonPropertyName("statusBefore")] string StatusBefore,
    [property: JsonPropertyName("statusAfter")] string StatusAfter,
    [property: JsonPropertyName("publishedAt")] DateTime PublishedAt,
    [property: JsonPropertyName("runId")] string? RunId
);

public sealed record BenchmarkCampaignCreateRequest(
    [property: JsonPropertyName("campaignId")] string CampaignId,
    [property: JsonPropertyName("authorizationId")] string AuthorizationId,
    [property: JsonPropertyName("authorizedBy")] string AuthorizedBy,
    [property: JsonPropertyName("corpusSha256")] string CorpusSha256,
    [property: JsonPropertyName("configSha256")] string ConfigSha256,
    [property: JsonPropertyName("budgetCapCalls")] int BudgetCapCalls,
    [property: JsonPropertyName("budgetCapTokens")] int BudgetCapTokens,
    [property: JsonPropertyName("budgetCapWallTimeSeconds")] double BudgetCapWallTimeSeconds
);

public sealed record BenchmarkCaseProvisionRequest(
    [property: JsonPropertyName("campaignId")] string CampaignId,
    [property: JsonPropertyName("caseId")] string CaseId,
    [property: JsonPropertyName("claimId")] string ClaimId,
    [property: JsonPropertyName("leaseOwner")] Guid LeaseOwner,
    [property: JsonPropertyName("workerInput")] BenchmarkWorkerInput? WorkerInput = null
);

public sealed record BenchmarkWorkerInput(
    [property: JsonPropertyName("topic")] string Topic,
    [property: JsonPropertyName("sources")] List<ReadingSource> Sources);

public sealed record BenchmarkCaseCompleteRequest(
    [property: JsonPropertyName("campaignId")] string CampaignId,
    [property: JsonPropertyName("caseId")] string CaseId,
    [property: JsonPropertyName("claimId")] string ClaimId,
    [property: JsonPropertyName("epoch")] int Epoch,
    [property: JsonPropertyName("leaseOwner")] Guid LeaseOwner
);

public sealed record OutboxEventDto(
    [property: JsonPropertyName("id")] Guid Id,
    [property: JsonPropertyName("runId")] string RunId,
    [property: JsonPropertyName("eventId")] string EventId,
    [property: JsonPropertyName("eventType")] string EventType,
    [property: JsonPropertyName("idempotencyKey")] string IdempotencyKey,
    [property: JsonPropertyName("epoch")] int Epoch,
    [property: JsonPropertyName("payloadJson")] string PayloadJson,
    [property: JsonPropertyName("status")] string Status,
    [property: JsonPropertyName("createdAt")] DateTime CreatedAt,
    [property: JsonPropertyName("sequence")] long Sequence = 0
);
