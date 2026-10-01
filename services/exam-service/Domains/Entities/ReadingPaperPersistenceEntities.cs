using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace exam_service.Domains.Entities;

public sealed class ReadingPaperRun
{
    [Key] public Guid Id { get; set; } = Guid.NewGuid();
    public Guid JobId { get; set; }
    public string RunId { get; set; } = string.Empty;
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
