using System.Text.Json.Serialization;

namespace writing_service.Contracts;

public record AiCompareRequestDto(
    [property: JsonPropertyName("essay_text")] string EssayText,
    [property: JsonPropertyName("topic")] string Topic,
    [property: JsonPropertyName("task_type")] string TaskType,
    [property: JsonPropertyName("student_band")] float StudentBand
);

public class AiCompareResponseDto
{
    [JsonPropertyName("overall_analysis")]
    public string OverallAnalysis { get; set; } = "";

    [JsonPropertyName("vocabulary_feedback")]
    public string VocabularyFeedback { get; set; } = "";

    [JsonPropertyName("coherence_feedback")]
    public string CoherenceFeedback { get; set; } = "";

    [JsonPropertyName("grammar_feedback")]
    public string GrammarFeedback { get; set; } = "";

    [JsonPropertyName("task_response_feedback")]
    public string TaskResponseFeedback { get; set; } = "";

    [JsonPropertyName("step_up_band")]
    public float StepUpBand { get; set; }

    [JsonPropertyName("target_band")]
    public float TargetBand { get; set; }

    [JsonPropertyName("step_up_analysis")]
    public string StepUpAnalysis { get; set; } = "";

    [JsonPropertyName("target_analysis")]
    public string TargetAnalysis { get; set; } = "";

    [JsonPropertyName("key_improvements")]
    public List<string> KeyImprovements { get; set; } = [];

    [JsonPropertyName("no_references_found")]
    public bool NoReferencesFound { get; set; }
}
