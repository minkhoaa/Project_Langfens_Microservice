using System.Text.Json.Serialization;

namespace writing_service.Contracts;

public class LlmWritingScoreCompact
{
    [JsonPropertyName("ob")]
    public double OverallBand { get; set; }

    [JsonPropertyName("ta")]
    public CriterionArray TaskResponse { get; set; } = new();

    [JsonPropertyName("cc")]
    public CriterionArray CoherenceAndCohesion { get; set; } = new();

    [JsonPropertyName("lr")]
    public CriterionArray LexicalResource { get; set; } = new();

    [JsonPropertyName("gr")]
    public CriterionArray GrammaticalRangeAndAccuracy { get; set; } = new();

    [JsonPropertyName("s")]
    public List<string> Suggestions { get; set; } = new();

    [JsonPropertyName("p")]
    public string ImprovedParagraph { get; set; } = string.Empty;
}
public class CriterionArray
{
    [JsonPropertyName("b")]
    public double Band { get; set; }

    [JsonPropertyName("c")]
    public string Comment { get; set; } = string.Empty;
}