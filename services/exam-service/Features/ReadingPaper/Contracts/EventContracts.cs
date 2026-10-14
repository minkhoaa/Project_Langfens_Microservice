using System.Text.Json;
using System.Text.Json.Serialization;

namespace exam_service.Features.ReadingPaper.Contracts;

[JsonConverter(typeof(JsonStringEnumConverter))]
public enum EventType
{
    RUN_STARTED,
    CHECKPOINT_SAVED,
    ARTIFACT_PRODUCED,
    EVALUATION_COMPLETED,
    ISSUE_RECORDED,
    LOOP_DECIDED,
    OPERATION_GRANTED,
    SECTION_GENERATED,
    PAPER_GENERATED,
    RUN_COMPLETED,
    RUN_FAILED,
    HEARTBEAT
}

/// <summary>
/// Authoritative V2.0.0 Event Envelope matching python engine.
/// </summary>
public sealed record EventEnvelope(
    [property: JsonPropertyName("eventId")] string EventId,
    [property: JsonPropertyName("sequence")] long Sequence,
    [property: JsonPropertyName("timestamp")] DateTimeOffset Timestamp,
    [property: JsonPropertyName("runId")] string RunId,
    [property: JsonPropertyName("eventType")] EventType EventType,
    [property: JsonPropertyName("payload")] JsonElement Payload,
    [property: JsonPropertyName("operationId")] string? OperationId = null,
    [property: JsonPropertyName("artifactRef")] ArtifactRef? ArtifactRef = null,
    [property: JsonPropertyName("schemaVersion")] string SchemaVersion = "2.0.0",
    [property: JsonPropertyName("engineVersion")] string EngineVersion = "2.0.0"
);

/// <summary>
/// Backward-compatible domain event representation for persistence checkpoints.
/// </summary>
public sealed record DomainEvent(
    [property: JsonPropertyName("eventId")] string EventId,
    [property: JsonPropertyName("eventType")] EventType EventType,
    [property: JsonPropertyName("runId")] string RunId,
    [property: JsonPropertyName("sectionId")] int? SectionId,
    [property: JsonPropertyName("epoch")] int Epoch,
    [property: JsonPropertyName("idempotencyKey")] string IdempotencyKey,
    [property: JsonPropertyName("timestamp")] DateTime Timestamp,
    [property: JsonPropertyName("data")] JsonElement Data,
    [property: JsonPropertyName("sequence")] long Sequence = 0
);

public sealed record HeartbeatPayload(
    [property: JsonPropertyName("runId")] string RunId,
    [property: JsonPropertyName("timestamp")] DateTimeOffset Timestamp,
    [property: JsonPropertyName("status")] string Status = "IN_PROGRESS",
    [property: JsonPropertyName("activeOperations")] int ActiveOperations = 0
);

public sealed record RunCompletedPayload(
    [property: JsonPropertyName("status")] string Status,
    [property: JsonPropertyName("runId")] string RunId,
    [property: JsonPropertyName("jobId")] string? JobId = null,
    [property: JsonPropertyName("examId")] string? ExamId = null,
    [property: JsonPropertyName("finalScore")] double? FinalScore = null,
    [property: JsonPropertyName("tokensUsed")] int TokensUsed = 0,
    [property: JsonPropertyName("costUsedUsd")] decimal CostUsedUsd = 0m,
    [property: JsonPropertyName("result")] JsonElement? Result = null
);

public sealed record RunFailedPayload(
    [property: JsonPropertyName("status")] string Status,
    [property: JsonPropertyName("runId")] string RunId,
    [property: JsonPropertyName("httpStatus")] int HttpStatus = 500,
    [property: JsonPropertyName("errorCode")] string ErrorCode = "GENERATION_FAILED",
    [property: JsonPropertyName("message")] string Message = "",
    [property: JsonPropertyName("traceback")] string? Traceback = null,
    [property: JsonPropertyName("recoverable")] bool Recoverable = false
);
