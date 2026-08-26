namespace attempt_service.Features.Helpers;

public sealed record AnswerEnvelope(string Type, string RawJson, object TypedRecord);