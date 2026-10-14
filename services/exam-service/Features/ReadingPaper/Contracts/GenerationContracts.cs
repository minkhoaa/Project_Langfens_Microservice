using System.Text.Json.Serialization;

namespace exam_service.Features.ReadingPaper.Contracts;

[JsonConverter(typeof(JsonStringEnumConverter))]
public enum SectionSlotStatus
{
    PENDING,
    IN_PROGRESS,
    COMPLETED,
    FAILED
}

[JsonConverter(typeof(JsonStringEnumConverter))]
public enum OperationStatus
{
    GRANTED,
    CONSUMED,
    EXPIRED,
    RELEASED
}

[JsonConverter(typeof(JsonStringEnumConverter))]
public enum BudgetStatus
{
    ACTIVE,
    EXHAUSTED,
    RELEASED
}

public sealed record RunIdentity(
    [property: JsonPropertyName("runId")] string RunId,
    [property: JsonPropertyName("jobId")] string JobId,
    [property: JsonPropertyName("epoch")] int Epoch,
    [property: JsonPropertyName("leaseOwner")] string? LeaseOwner,
    [property: JsonPropertyName("createdAt")] DateTime CreatedAt
);

public sealed record SectionSlot(
    [property: JsonPropertyName("slotNumber")] int SlotNumber,
    [property: JsonPropertyName("topic")] string? Topic,
    [property: JsonPropertyName("status")] SectionSlotStatus Status,
    [property: JsonPropertyName("completedArtifactId")] string? CompletedArtifactId,
    [property: JsonPropertyName("completedAt")] DateTime? CompletedAt
);

public sealed record OperationGrant(
    [property: JsonPropertyName("grantId")] string GrantId,
    [property: JsonPropertyName("runId")] string RunId,
    [property: JsonPropertyName("operationName")] string OperationName,
    [property: JsonPropertyName("maxTokens")] int MaxTokens,
    [property: JsonPropertyName("timeoutSeconds")] double TimeoutSeconds,
    [property: JsonPropertyName("status")] OperationStatus Status,
    [property: JsonPropertyName("grantedAt")] DateTime GrantedAt,
    [property: JsonPropertyName("expiresAt")] DateTime? ExpiresAt
);

public sealed record BudgetReservation(
    [property: JsonPropertyName("reservationId")] string ReservationId,
    [property: JsonPropertyName("runId")] string RunId,
    [property: JsonPropertyName("maxCalls")] int MaxCalls,
    [property: JsonPropertyName("maxTokens")] int MaxTokens,
    [property: JsonPropertyName("costCapUsd")] double? CostCapUsd,
    [property: JsonPropertyName("callsConsumed")] int CallsConsumed,
    [property: JsonPropertyName("tokensConsumed")] int TokensConsumed,
    [property: JsonPropertyName("status")] BudgetStatus Status
)
{
    [JsonIgnore]
    public bool IsExhausted => CallsConsumed >= MaxCalls || TokensConsumed >= MaxTokens;
}
