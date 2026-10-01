using System.Text.Json.Serialization;

namespace exam_service.Features.ReadingPaper.Contracts;

[JsonConverter(typeof(JsonStringEnumConverter))]
public enum DecisionType
{
    PASS,
    REPAIR,
    REGENERATE,
    ESCALATE,
    FAIL
}

[JsonConverter(typeof(JsonStringEnumConverter))]
public enum LoopState
{
    INITIALIZED,
    INGESTING,
    EVIDENCE_EXTRACTING,
    BLUEPRINTING,
    DRAFTING,
    EVALUATING,
    REPAIRING,
    COMPLETED,
    FAILED,
    ABORTED
}

public sealed record LoopDecision(
    [property: JsonPropertyName("decisionId")] string DecisionId,
    [property: JsonPropertyName("runId")] string RunId,
    [property: JsonPropertyName("decision")] DecisionType Decision,
    [property: JsonPropertyName("currentState")] LoopState CurrentState,
    [property: JsonPropertyName("nextState")] LoopState NextState,
    [property: JsonPropertyName("reason")] string Reason,
    [property: JsonPropertyName("targetScope")] IssueScope TargetScope,
    [property: JsonPropertyName("budgetReservationId")] string? BudgetReservationId,
    [property: JsonPropertyName("expectedVersion")] int? ExpectedVersion,
    [property: JsonPropertyName("evaluationRef")] string? EvaluationRef,
    [property: JsonPropertyName("createdAt")] DateTime CreatedAt,
    [property: JsonPropertyName("targetArtifactId")] string? TargetArtifactId = null,
    [property: JsonPropertyName("reasonCode")] string? ReasonCode = null
)
{
    public static (bool IsValid, string? ErrorMessage) ValidateDecision(
        LoopDecision decision,
        EvaluationResult? latestEvaluation = null)
    {
        if (decision.Decision == DecisionType.PASS || decision.NextState == LoopState.COMPLETED)
        {
            if (latestEvaluation == null)
                return (false, "Fail-closed rejection: decision PASS or transition to COMPLETED requires a non-null EvaluationResult");
            if (latestEvaluation.Status != EvaluationStatus.PASS)
                return (false, $"Fail-closed rejection: evaluation status is {latestEvaluation.Status}, cannot decide PASS");
            if (!latestEvaluation.IsPass)
                return (false, "Fail-closed rejection: evaluation contains open CRITICAL issues, cannot decide PASS");
            if (decision.EvaluationRef != latestEvaluation.EvaluationId)
                return (false, $"Fail-closed rejection: decision evaluationRef '{decision.EvaluationRef}' does not match latest evaluationId '{latestEvaluation.EvaluationId}'");
        }

        return (true, null);
    }
}
