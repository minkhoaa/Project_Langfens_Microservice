using System.Text.Json.Serialization;
using Shared.ExamDto.Contracts.Speaking;
using speaking_service.Contracts;

namespace speaking_service.Contracts;

public class SpeakingGradeResult
{
    [JsonPropertyName("response")]
    public SpeakingGradeResponseDto Response { get; set; } = new();

    [JsonPropertyName("compact")]
    public LlmSpeakingScoreCompact Compact { get; set; } = new();
}

public class SpeakingGradeResponseDto
{
    [JsonPropertyName("ob")]
    public double OverallBand { get; set; }

    [JsonPropertyName("fc")]
    public CriterionScore FluencyAndCoherence { get; set; } = new();

    [JsonPropertyName("lr")]
    public CriterionScore LexicalResource { get; set; } = new();

    [JsonPropertyName("gr")]
    public CriterionScore GrammaticalRangeAndAccuracy { get; set; } = new();

    [JsonPropertyName("pr")]
    public CriterionScore Pronunciation { get; set; } = new();

    [JsonPropertyName("s")]
    public List<string> Suggestions { get; set; } = new();

    [JsonPropertyName("p")]
    public string ImprovedAnswer { get; set; } = string.Empty;

    [JsonPropertyName("raw_llm_json")]
    public string? RawLlmJson { get; set; }

    [JsonPropertyName("word_count")]
    public int WordCount { get; set; }
}

/// <summary>
/// Compact JSON DTO matching ai-service SpeakingGradeResponse field names exactly.
/// Used for deserialization only — convert to SpeakingGradeResponse/SpeakingGradeResponseDto for use.
/// </summary>
internal class AiSpeakingApiResponse
{
    [JsonPropertyName("ob")]
    public double ob { get; set; }

    [JsonPropertyName("fc")]
    public AiCriterion fc { get; set; } = new();

    [JsonPropertyName("lr")]
    public AiCriterion lr { get; set; } = new();

    [JsonPropertyName("gr")]
    public AiCriterion gr { get; set; } = new();

    [JsonPropertyName("pr")]
    public AiCriterion pr { get; set; } = new();

    [JsonPropertyName("s")]
    public List<string> s { get; set; } = new();

    [JsonPropertyName("p")]
    public string p { get; set; } = string.Empty;

    [JsonPropertyName("raw_llm_json")]
    public string? raw_llm_json { get; set; }
}

internal class AiCriterion
{
    [JsonPropertyName("b")]
    public double b { get; set; }

    [JsonPropertyName("c")]
    public string c { get; set; } = string.Empty;
}
