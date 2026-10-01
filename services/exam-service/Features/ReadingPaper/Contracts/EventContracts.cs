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
    RUN_COMPLETED,
    RUN_FAILED
}

public sealed record DomainEvent(
    [property: JsonPropertyName("eventId")] string EventId,
    [property: JsonPropertyName("eventType")] EventType EventType,
    [property: JsonPropertyName("runId")] string RunId,
    [property: JsonPropertyName("sectionId")] int? SectionId,
    [property: JsonPropertyName("epoch")] int Epoch,
    [property: JsonPropertyName("idempotencyKey")] string IdempotencyKey,
    [property: JsonPropertyName("timestamp")] DateTime Timestamp,
    [property: JsonPropertyName("data")] JsonElement Data
);
