using System.Text.Json.Serialization;

namespace exam_service.Features.ReadingPaper.Contracts;

[JsonConverter(typeof(JsonStringEnumConverter))]
public enum EvaluationStatus
{
    PASS,
    FAIL,
    ERROR,
    NOT_APPLICABLE
}

public sealed record UsageMetrics(
    [property: JsonPropertyName("promptTokens")] int? PromptTokens,
    [property: JsonPropertyName("completionTokens")] int? CompletionTokens,
    [property: JsonPropertyName("totalTokens")] int? TotalTokens,
    [property: JsonPropertyName("costUsd")] double? CostUsd
);

public sealed record EvaluationResult(
    [property: JsonPropertyName("evaluationId")] string EvaluationId,
    [property: JsonPropertyName("evaluatorId")] string EvaluatorId,
    [property: JsonPropertyName("evaluatorVersion")] string EvaluatorVersion,
    [property: JsonPropertyName("targetRef")] ArtifactRef TargetRef,
    [property: JsonPropertyName("status")] EvaluationStatus Status,
    [property: JsonPropertyName("issues")] IReadOnlyList<Issue> Issues,
    [property: JsonPropertyName("score")] double? Score,
    [property: JsonPropertyName("inputDependencyRefs")] IReadOnlyList<ArtifactRef> InputDependencyRefs,
    [property: JsonPropertyName("provider")] string? Provider,
    [property: JsonPropertyName("model")] string? Model,
    [property: JsonPropertyName("promptVersion")] string? PromptVersion,
    [property: JsonPropertyName("elapsedMs")] double? ElapsedMs,
    [property: JsonPropertyName("usage")] UsageMetrics? Usage,
    [property: JsonPropertyName("evaluatedAt")] DateTime EvaluatedAt,
    [property: JsonPropertyName("resolvedIssueFingerprints")] IReadOnlyList<string>? ResolvedIssueFingerprints = null
)
{
    [JsonIgnore]
    public bool IsPass =>
        Status == EvaluationStatus.PASS &&
        !Issues.Any(i => i.Severity == IssueSeverity.CRITICAL && i.Status == IssueStatus.OPEN);
}
