using System.Text.Json.Serialization;

namespace exam_service.Features.ReadingPaper.Contracts;

[JsonConverter(typeof(JsonStringEnumConverter))]
public enum EntailmentLabel
{
    [JsonPropertyName("ENTAILS")]
    Entails,
    [JsonPropertyName("CONTRADICTS")]
    Contradicts,
    [JsonPropertyName("NEUTRAL")]
    Neutral,
    [JsonPropertyName("UNVERIFIABLE")]
    Unverifiable
}

[JsonConverter(typeof(JsonStringEnumConverter))]
public enum Qualifier
{
    [JsonPropertyName("DEFINITE")]
    Definite,
    [JsonPropertyName("PROBABLE")]
    Probable,
    [JsonPropertyName("POSSIBLE")]
    Possible,
    [JsonPropertyName("HYPOTHETICAL")]
    Hypothetical,
    [JsonPropertyName("UNSUPPORTED")]
    Unsupported
}

public sealed record SourceOffset(
    [property: JsonPropertyName("startChar")] int StartChar,
    [property: JsonPropertyName("endChar")] int EndChar,
    [property: JsonPropertyName("sourceId")] string SourceId
);

public sealed record VerifiedClaim(
    [property: JsonPropertyName("claimId")] string ClaimId,
    [property: JsonPropertyName("text")] string Text,
    [property: JsonPropertyName("sourceId")] string SourceId,
    [property: JsonPropertyName("offsets")] SourceOffset? Offsets,
    [property: JsonPropertyName("confidence")] double Confidence,
    [property: JsonPropertyName("entailment")] EntailmentLabel Entailment,
    [property: JsonPropertyName("qualifier")] Qualifier Qualifier,
    [property: JsonPropertyName("keywords")] IReadOnlyList<string> Keywords
);

public sealed record AbsenceAssessment(
    [property: JsonPropertyName("assessmentId")] string AssessmentId,
    [property: JsonPropertyName("claimOrTopic")] string ClaimOrTopic,
    [property: JsonPropertyName("absenceReason")] string AbsenceReason,
    [property: JsonPropertyName("topicalContextSpan")] string? TopicalContextSpan,
    [property: JsonPropertyName("absenceConfirmed")] bool AbsenceConfirmed
);

public sealed record EvidenceGraph(
    [property: JsonPropertyName("graphId")] string GraphId,
    [property: JsonPropertyName("runId")] string RunId,
    [property: JsonPropertyName("sourcePackId")] string? SourcePackId = null,
    [property: JsonPropertyName("version")] string Version = "v1.0.0",
    [property: JsonPropertyName("contentHash")] string? ContentHash = null,
    [property: JsonPropertyName("status")] string Status = "ACCEPTED",
    [property: JsonPropertyName("sectionId")] int? SectionId = null,
    [property: JsonPropertyName("claims")] IReadOnlyList<VerifiedClaim> Claims = null!,
    [property: JsonPropertyName("absenceAssessments")] IReadOnlyList<AbsenceAssessment> AbsenceAssessments = null!,
    [property: JsonPropertyName("verifiedAt")] DateTime VerifiedAt = default
);
