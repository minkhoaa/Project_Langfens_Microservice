using System.Text.Json.Serialization;
using writing_service.Domains.Entities;

namespace writing_service.Contracts;

public class WritingGradeResult
{
    [JsonPropertyName("response")]
    public WritingGradeResponseDto Response { get; set; } = new();

    [JsonPropertyName("compact")]
    public LlmWritingScoreCompact Compact { get; set; } = new();
}

public class WritingGradeResponseDto
{
    [JsonPropertyName("ob")]
    public double OverallBand { get; set; }

    [JsonPropertyName("ta")]
    public CriterionDto TaskResponse { get; set; } = new();

    [JsonPropertyName("cc")]
    public CriterionDto CoherenceAndCohesion { get; set; } = new();

    [JsonPropertyName("lr")]
    public CriterionDto LexicalResource { get; set; } = new();

    [JsonPropertyName("gr")]
    public CriterionDto GrammaticalRangeAndAccuracy { get; set; } = new();

    [JsonPropertyName("s")]
    public List<string> Suggestions { get; set; } = new();

    [JsonPropertyName("p")]
    public string ImprovedParagraph { get; set; } = string.Empty;

    [JsonPropertyName("raw_llm_json")]
    public string? RawLlmJson { get; set; }

    // Essay data (populated from submission, not from LLM response)
    public Guid SubmissionId { get; set; }
    public string EssayRaw { get; set; } = string.Empty;
    public string EssayNormalized { get; set; } = string.Empty;
    public int WordCount { get; set; }
    public string? TaskText { get; set; }

    public static WritingGradeResponseDto BuildResponseDtoFromEvaluation(WritingEvaluation eval)
    {
        var suggestions = new List<string>();
        if (!string.IsNullOrWhiteSpace(eval.SuggestionsJson))
        {
            try
            {
                suggestions = System.Text.Json.JsonSerializer.Deserialize<List<string>>(eval.SuggestionsJson)
                    ?? new List<string>();
            }
            catch (System.Text.Json.JsonException) { /* keep empty */ }
        }
        return new WritingGradeResponseDto
        {
            SubmissionId = eval.SubmissionId,
            OverallBand = eval.OverallBand,
            TaskResponse = new CriterionDto { Band = eval.TaskResponseBand, Comment = eval.TaskResponseComment },
            CoherenceAndCohesion = new CriterionDto { Band = eval.CoherenceAndCohesionBand, Comment = eval.CoherenceAndCohesionComment },
            LexicalResource = new CriterionDto { Band = eval.LexicalResourceBand, Comment = eval.LexicalResourceComment },
            GrammaticalRangeAndAccuracy = new CriterionDto { Band = eval.GrammaticalRangeAndAccuracyBand, Comment = eval.GrammaticalRangeAndAccuracyComment },
            Suggestions = suggestions,
            ImprovedParagraph = eval.ImprovedParagraph ?? string.Empty,
            RawLlmJson = eval.RawLlmJson
        };
    }
}

public class CriterionDto
{
    [JsonPropertyName("b")]
    public double Band { get; set; }

    [JsonPropertyName("c")]
    public string Comment { get; set; } = string.Empty;

    public Shared.ExamDto.Contracts.Writing.CriterionScore ToCriterionScore()
    {
        return new Shared.ExamDto.Contracts.Writing.CriterionScore { Band = Band, Comment = Comment };
    }
}