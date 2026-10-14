using System.Security.Cryptography;
using System.Text;
using System.Text.Json.Serialization;

namespace exam_service.Features.ReadingPaper.Contracts;

[JsonConverter(typeof(JsonStringEnumConverter))]
public enum IssueSeverity
{
    CRITICAL,
    MAJOR,
    MINOR,
    INFO
}

[JsonConverter(typeof(JsonStringEnumConverter))]
public enum IssueScope
{
    SOURCE,
    EVIDENCE,
    BLUEPRINT,
    PASSAGE,
    QUESTION_GROUP,
    QUESTION,
    SECTION,
    PAPER
}

[JsonConverter(typeof(JsonStringEnumConverter))]
public enum IssueStatus
{
    OPEN,
    RESOLVED,
    SUPERSEDED
}

[JsonConverter(typeof(JsonStringEnumConverter))]
public enum IssueCode
{
    // Five source fidelity hard errors
    UNSUPPORTED_OR_CONTRADICTED_CLAIM,
    CAUSAL_OVERSTATEMENT,
    OVERSTATED_CERTAINTY,
    UNMEASURED_OUTCOME,
    SOURCE_INSUFFICIENT,

    // Construction & contract violations
    EVIDENCE_MISSING,
    AMBIGUOUS_ANSWER,
    ANSWER_LEAKAGE,
    BAD_DISTRACTOR,
    WORD_LIMIT_EXCEEDED,
    DUPLICATE_CONTENT,
    EVALUATOR_UNAVAILABLE,
    STALE_DEPENDENCY,
    BUDGET_EXHAUSTED,
    SCHEMA_VIOLATION,
    INSUFFICIENT_OPTIONS,
    SECTION_WORD_COUNT_OUT_OF_BOUNDS,
    QUESTION_NUMBERING_INVALID,
    QUESTION_COUNT_MISMATCH,
    SECTION_GROUP_COUNT_MISMATCH,
    SECTION_GROUP_TYPE_MISMATCH,
    SECTION_GROUP_SIZE_MISMATCH,
    SPAN_CONCENTRATION_DETECTED,
    ANSWER_CONCENTRATION_DETECTED,
    EDITORIAL_STYLE_DEFECT,
    EDITORIAL_SKILL_DIVERSITY_DEFECT,
    FRESH_EVALUATION_MISSING,
    MONOTONOUS_ANSWER_DISTRIBUTION,
    CROSS_SECTION_DUPLICATE_CONTENT,
    CROSS_SECTION_LEAKAGE
}
public sealed record Issue(
    [property: JsonPropertyName("issueId")] string IssueId,
    [property: JsonPropertyName("code")] IssueCode Code,
    [property: JsonPropertyName("severity")] IssueSeverity Severity,
    [property: JsonPropertyName("scope")] IssueScope Scope,
    [property: JsonPropertyName("affectedRefs")] IReadOnlyList<ArtifactRef> AffectedRefs,
    [property: JsonPropertyName("message")] string Message,
    [property: JsonPropertyName("evidence")] string? Evidence,
    [property: JsonPropertyName("proposedRepair")] string? ProposedRepair,
    [property: JsonPropertyName("status")] IssueStatus Status,
    [property: JsonPropertyName("fingerprint")] string Fingerprint,
    [property: JsonPropertyName("createdAt")] DateTime CreatedAt,
    [property: JsonPropertyName("resolvedAt")] DateTime? ResolvedAt,
    [property: JsonPropertyName("evaluatorId")] string? EvaluatorId = null
)
{
    public static string ComputeFingerprint(
        IssueCode code,
        IssueScope scope,
        IEnumerable<ArtifactRef> affectedRefs,
        string message)
    {
        var refKeys = affectedRefs
            .Select(r => $"{r.ArtifactType}:{r.ArtifactId}:{r.Version}")
            .OrderBy(k => k, StringComparer.Ordinal);
        var normMsg = string.Join(" ", message.Trim().ToLowerInvariant().Split((char[]?)null, StringSplitOptions.RemoveEmptyEntries));
        var raw = $"{code}|{scope}|{string.Join(",", refKeys)}|{normMsg}";
        var hash = SHA256.HashData(Encoding.UTF8.GetBytes(raw));
        return Convert.ToHexStringLower(hash);
    }
}

public sealed record IssueLedger(
    [property: JsonPropertyName("ledgerId")] string LedgerId,
    [property: JsonPropertyName("runId")] string RunId,
    [property: JsonPropertyName("issues")] IReadOnlyList<Issue> Issues
)
{
    [JsonIgnore]
    public bool HasCriticalIssues => Issues.Any(i => i.Severity == IssueSeverity.CRITICAL && i.Status == IssueStatus.OPEN);
}
