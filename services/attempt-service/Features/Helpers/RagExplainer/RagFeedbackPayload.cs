using System.Text.Json;
using System.Text.Json.Serialization;

namespace attempt_service.Features.Helpers.RagExplainer;

/// <summary>
/// Local mirror of the shared RagFeedbackEnvelope shape. We use this type
/// only for serializing the stored JSONB column and for deserializing the
/// ai-service response inside the orchestrator. The FE consumes the
/// canonical Shared.PublicContracts.Contracts.Ai.RagFeedbackEnvelope
/// after JSON round-tripping via the gateway.
/// </summary>
public sealed class RagFeedbackEnvelopeDto
{
    [JsonPropertyName("item_id")] public string ItemId { get; set; } = "";
    [JsonPropertyName("domain")] public string Domain { get; set; } = "";
    [JsonPropertyName("overall_band")] public double? OverallBand { get; set; }
    [JsonPropertyName("criteria")] public List<CriterionScoreDto> Criteria { get; set; } = new();
    [JsonPropertyName("evidence")] public List<EvidenceDto> Evidence { get; set; } = new();
    [JsonPropertyName("suggestions")] public List<SuggestionDto> Suggestions { get; set; } = new();
    [JsonPropertyName("raw_llm_json")] public string? RawLlmJson { get; set; }
}

public sealed class CriterionScoreDto
{
    [JsonPropertyName("name")] public string Name { get; set; } = "";
    [JsonPropertyName("band")] public double Band { get; set; }
    [JsonPropertyName("comment")] public string Comment { get; set; } = "";
    [JsonPropertyName("evidence_ids")] public List<string>? EvidenceIds { get; set; }
}

public sealed class EvidenceDto
{
    [JsonPropertyName("id")] public string Id { get; set; } = "";
    [JsonPropertyName("text")] public string Text { get; set; } = "";
    [JsonPropertyName("source")] public string Source { get; set; } = "";
    [JsonPropertyName("relevance")] public double Relevance { get; set; }
}

public sealed class SuggestionDto
{
    [JsonPropertyName("text")] public string Text { get; set; } = "";
    [JsonPropertyName("target")] public string Target { get; set; } = "";
}
