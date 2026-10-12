using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace exam_service.Domains.Entities;

public sealed class ReadingPaperRun
{
    [Key] public Guid Id { get; set; } = Guid.NewGuid();
    public Guid JobId { get; set; }
    public string RunId { get; set; } = string.Empty;
    public string? BenchmarkCampaignId { get; set; }
    public string? BenchmarkCaseId { get; set; }
    public string? BenchmarkClaimId { get; set; }
    public int Epoch { get; set; } = 1;
    public string Status { get; set; } = "INITIALIZED";
    public Guid? LeaseOwner { get; set; }
    public DateTime? LeaseUntil { get; set; }
    public int CancelVersion { get; set; } = 0;
    public string EngineVersion { get; set; } = "2.0.0";
    public string SchemaVersion { get; set; } = "2.0.0";
    public string PolicyVersion { get; set; } = "2.0.0";
    public string SourceRevisionsJson { get; set; } = "[]";
    public int BudgetCapCalls { get; set; } = 25;
    public int BudgetCapTokens { get; set; } = 150000;
    public int BudgetUsedCalls { get; set; } = 0;
    public int BudgetUsedTokens { get; set; } = 0;
    public int BudgetCapWallTimeSeconds { get; set; } = 900;
    public double BudgetUsedWallTimeSeconds { get; set; } = 0.0;
    [MaxLength(64)] public string BudgetProfileVersion { get; set; } = "legacy-unpinned";
    [MaxLength(64)] public string BudgetProfileSha256 { get; set; } = string.Empty;
    [MaxLength(256)] public string BudgetProfileSource { get; set; } = "migration:legacy";
    public string BudgetProfileJson { get; set; } = "{}";
    public bool BudgetBreachDetected { get; set; } = false;
    public string? BudgetBreachReason { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    [ForeignKey(nameof(JobId))]
    public ReadingPaperJob? Job { get; set; }
}

public sealed class ReadingPaperArtifact
{
    [Key] public Guid Id { get; set; } = Guid.NewGuid();
    public string RunId { get; set; } = string.Empty;
    public string ArtifactId { get; set; } = string.Empty;
    public string ArtifactType { get; set; } = string.Empty;
    public int Version { get; set; } = 1;
    public string ContentHash { get; set; } = string.Empty;
    public string PayloadJson { get; set; } = "{}";
    public string ParentRefsJson { get; set; } = "[]";
    public string ProducerVersion { get; set; } = "2.0.0";
    public string? EnvelopeJson { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}

public sealed class ReadingPaperArtifactHead
{
    [Key] public Guid Id { get; set; } = Guid.NewGuid();
    public string RunId { get; set; } = string.Empty;
    public string ArtifactId { get; set; } = string.Empty;
    public int AcceptedVersion { get; set; }
    public string AcceptedHash { get; set; } = string.Empty;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}

public sealed class ReadingPaperArtifactDependency
{
    [Key] public Guid Id { get; set; } = Guid.NewGuid();
    public string RunId { get; set; } = string.Empty;
    public string ArtifactId { get; set; } = string.Empty;
    public int Version { get; set; }
    public string ParentArtifactId { get; set; } = string.Empty;
    public int ParentVersion { get; set; }
    public string ParentContentHash { get; set; } = string.Empty;
}

public sealed class ReadingPaperEvaluation
{
    [Key] public Guid Id { get; set; } = Guid.NewGuid();
    public string RunId { get; set; } = string.Empty;
    public string EvaluationId { get; set; } = string.Empty;
    public string EvaluatorId { get; set; } = string.Empty;
    public string EvaluatorVersion { get; set; } = "1.0.0";
    public string TargetArtifactId { get; set; } = string.Empty;
    public int TargetVersion { get; set; }
    public string TargetContentHash { get; set; } = string.Empty;
    public string Status { get; set; } = "PASS";
    public bool IsPass { get; set; }
    public string PayloadJson { get; set; } = "{}";
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}

public sealed class ReadingPaperIssue
{
    [Key] public Guid Id { get; set; } = Guid.NewGuid();
    public string RunId { get; set; } = string.Empty;
    public string IssueId { get; set; } = string.Empty;
    public string EvaluationId { get; set; } = string.Empty;
    public string Code { get; set; } = string.Empty;
    public string Severity { get; set; } = "CRITICAL";
    public string Scope { get; set; } = "QUESTION";
    public string Message { get; set; } = string.Empty;
    public string Status { get; set; } = "OPEN";
    public string Fingerprint { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}

public sealed class ReadingPaperDecision
{
    [Key] public Guid Id { get; set; } = Guid.NewGuid();
    public string RunId { get; set; } = string.Empty;
    public string DecisionId { get; set; } = string.Empty;
    public string Decision { get; set; } = "PASS";
    public string CurrentState { get; set; } = "EVALUATING";
    public string NextState { get; set; } = "COMPLETED";
    public string Reason { get; set; } = string.Empty;
    public string TargetScope { get; set; } = "SECTION";
    public string? EvaluationRef { get; set; }
    public string? BudgetReservationId { get; set; }
    public int? ExpectedVersion { get; set; }
    public string PayloadJson { get; set; } = "{}";
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}

public sealed class ReadingPaperOperation
{
    [Key] public Guid Id { get; set; } = Guid.NewGuid();
    public string RunId { get; set; } = string.Empty;
    public string OperationId { get; set; } = string.Empty;
    public string OperationType { get; set; } = "PROVIDER_CALL";
    public string RequestHash { get; set; } = string.Empty;
    public string Status { get; set; } = "RESERVED";
    public int TokenReservation { get; set; }
    public int TokensUsed { get; set; } = 0;
    public int? PromptTokensUsed { get; set; }
    public int? CompletionTokensUsed { get; set; }
    public int? ReasoningTokensUsed { get; set; }
    [MaxLength(24)] public string AccountingType { get; set; } = "UNKNOWN";
    public bool ReservationBreached { get; set; } = false;
    public string? BudgetBreachReason { get; set; }
    public decimal CostReservationUsd { get; set; } = 0m;
    public decimal CostUsedUsd { get; set; } = 0m;
    public string? SectionId { get; set; }
    public string? ArtifactId { get; set; }
    public string? ParentOperationId { get; set; }
    public double WallTimeReservationSeconds { get; set; } = 60.0;
    public double WallTimeUsedSeconds { get; set; } = 0.0;
    public string? ResultRefJson { get; set; }
    public string? ErrorMessage { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}
 
// A fenced, CAS-updated projection; artifacts and operation outcomes remain immutable.
public sealed class ReadingPaperLoopCursor
{
    [Key] public Guid Id { get; set; } = Guid.NewGuid();
    public string RunId { get; set; } = string.Empty;
    public string ArtifactId { get; set; } = string.Empty;
    public int Revision { get; set; }
    public string StateJson { get; set; } = "{}";
    public string? LastOperationId { get; set; }
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}
public sealed class ReadingPaperEventOutbox
{
    [Key] public Guid Id { get; set; } = Guid.NewGuid();
    public string RunId { get; set; } = string.Empty;
    public string EventId { get; set; } = string.Empty;
    public long Sequence { get; set; } = 0;
    public string EventType { get; set; } = string.Empty;
    public string IdempotencyKey { get; set; } = string.Empty;
    public int Epoch { get; set; } = 1;
    public string PayloadJson { get; set; } = "{}";
    public string Status { get; set; } = "PENDING";
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? PublishedAt { get; set; }
}

public sealed class ReadingPaperBudgetAllocation
{
    [Key] public Guid Id { get; set; } = Guid.NewGuid();
    public string RunId { get; set; } = string.Empty;
    public string ScopeType { get; set; } = "SECTION"; // "SECTION" or "ARTIFACT"
    public string ScopeId { get; set; } = string.Empty; // e.g. "section_1", "passage_1"
    public string? ParentScopeId { get; set; } // e.g. "section_1"
    public int TokenCap { get; set; }
    public int CallCap { get; set; } = 5;
    public int WallTimeCapSeconds { get; set; } = 300;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}

/// <summary>
/// Phase 14: durable lineage record for a single entity (Exam/Section/Passage/Question/Option)
/// that was produced by a Reading Paper run. Captures the immutable content hash at the time of
/// generation so that subsequent human edits can be evaluated against the original artifact.
/// </summary>
public sealed class ReadingPaperEntityLineage
{
    [Key] public Guid Id { get; set; } = Guid.NewGuid();
    [MaxLength(128)] public string RunId { get; set; } = string.Empty;
    public Guid ExamId { get; set; }
    public Guid? SectionId { get; set; }
    public Guid? QuestionId { get; set; }
    public Guid? OptionId { get; set; }
    [MaxLength(64)] public string EntityType { get; set; } = string.Empty;
    [MaxLength(128)] public string EntityId { get; set; } = string.Empty;
    [MaxLength(128)] public string ArtifactId { get; set; } = string.Empty;
    [MaxLength(64)] public string ArtifactType { get; set; } = string.Empty;
    public int ArtifactVersion { get; set; } = 1;
    [MaxLength(128)] public string ContentHash { get; set; } = string.Empty;
    public string ParentRefsJson { get; set; } = "[]";
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}

/// <summary>
/// Phase 14: durable record of a human-authored edit applied to a generated entity.
/// Pairs before/after content hashes and payloads, an exact diff, taxonomy reasons,
/// and a downstream-impact projection. Inserted atomically with a
/// HUMAN_FEEDBACK_CAPTURED event into the ReadingPaperEventOutbox inside the same
/// transaction as the edit itself. Idempotency is enforced by the unique
/// IdempotencyKey index.
/// </summary>
public sealed class ReadingPaperHumanFeedback
{
    [Key] public Guid Id { get; set; } = Guid.NewGuid();
    [MaxLength(128)] public string FeedbackId { get; set; } = string.Empty;
    [MaxLength(128)] public string? RunId { get; set; }
    public Guid ExamId { get; set; }
    public Guid? SectionId { get; set; }
    public Guid? QuestionId { get; set; }
    public Guid? OptionId { get; set; }
    [MaxLength(64)] public string TargetEntityType { get; set; } = string.Empty;
    [MaxLength(128)] public string TargetEntityId { get; set; } = string.Empty;
    [MaxLength(128)] public string? ArtifactId { get; set; }
    public int? ArtifactVersion { get; set; }
    [MaxLength(128)] public string BeforeContentHash { get; set; } = string.Empty;
    [MaxLength(128)] public string AfterContentHash { get; set; } = string.Empty;
    public string BeforePayloadJson { get; set; } = "{}";
    public string AfterPayloadJson { get; set; } = "{}";
    public string DiffJson { get; set; } = "{}";
    [MaxLength(128)] public string EditorId { get; set; } = string.Empty;
    [MaxLength(64)] public string EditorRole { get; set; } = "ADMIN";
    public string ReasonsJson { get; set; } = "[]";
    [MaxLength(4000)] public string Comment { get; set; } = string.Empty;
    public string DownstreamImpactJson { get; set; } = "{}";
    [MaxLength(32)] public string ActionType { get; set; } = string.Empty;
    [MaxLength(32)] public string CurationStatus { get; set; } = "RAW";
    [MaxLength(256)] public string IdempotencyKey { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}

/// <summary>
/// Phase 14: Append-only curation audit trail for human feedback records.
/// Captures every review/curation state transition (RAW -> ANNOTATED -> REVIEWED -> CURATED / REJECTED)
/// without mutating the underlying ReadingPaperHumanFeedback evidence record.
/// </summary>
public sealed class ReadingPaperFeedbackCurationRecord
{
    [Key] public Guid Id { get; set; } = Guid.NewGuid();
    [MaxLength(128)] public string ReviewId { get; set; } = string.Empty;
    [MaxLength(128)] public string FeedbackId { get; set; } = string.Empty;
    [MaxLength(32)] public string FromStatus { get; set; } = "RAW";
    [MaxLength(32)] public string ToStatus { get; set; } = string.Empty;
    [MaxLength(128)] public string ReviewerId { get; set; } = string.Empty;
    [MaxLength(64)] public string ReviewerRole { get; set; } = "ADMIN";
    [MaxLength(4000)] public string ReviewNotes { get; set; } = string.Empty;
    [MaxLength(64)] public string Action { get; set; } = "REVIEW";
    [MaxLength(256)] public string? IdempotencyKey { get; set; }
    public DateTime ReviewedAt { get; set; } = DateTime.UtcNow;
}
