using System.Text.Json.Serialization;

namespace speaking_service.Contracts;

public class LlmSpeakingScoreCompact
{
    [JsonPropertyName("ob")]
    public double OverallBand { get; set; }

    [JsonPropertyName("fc")]
    public CriterionArray FluencyAndCoherence { get; set; } = new();

    [JsonPropertyName("lr")]
    public CriterionArray LexicalResource { get; set; } = new();

    [JsonPropertyName("gr")]
    public CriterionArray GrammaticalRangeAndAccuracy { get; set; } = new();

    [JsonPropertyName("pr")]
    public CriterionArray Pronunciation { get; set; } = new();

    [JsonPropertyName("s")]
    public List<string> Suggestions { get; set; } = new();

    [JsonPropertyName("p")]
    public string ImprovedAnswer { get; set; } = string.Empty;
}

public class CriterionArray
{
    [JsonPropertyName("b")]
    public double Band { get; set; }

    [JsonPropertyName("c")]
    public string Comment { get; set; } = string.Empty;
}
