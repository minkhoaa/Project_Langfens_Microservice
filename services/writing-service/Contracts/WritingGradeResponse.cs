using Shared.ExamDto.Contracts.Writing;

namespace writing_service.Contracts;

public class WritingGradeResponse
{
    public Guid SubmissionId { get; set; }

    // Thông tin task
    public string TaskText { get; set; } = string.Empty;
    public string? ImageUrl { get; set; }
    public WritingCategory ExamType { get; set; } = WritingCategory.TOEIC;

    // Bài viết
    public string EssayRaw { get; set; } = string.Empty;
    public string EssayNormalized { get; set; } = string.Empty;
    public int WordCount { get; set; }

    // Điểm
    public double OverallBand { get; set; }
    public CriterionScore TaskResponse { get; set; } = new();
    public CriterionScore CoherenceAndCohesion { get; set; } = new();
    public CriterionScore LexicalResource { get; set; } = new();
    public CriterionScore GrammaticalRangeAndAccuracy { get; set; } = new();

    // Gợi ý & ví dụ
    public List<string> Suggestions { get; set; } = new();
    public string ImprovedParagraph { get; set; } = string.Empty;

    // Thông tin model
    public string Model { get; set; } = string.Empty;
    public string? ModelProvider { get; set; } // "openrouter/deepseek-v3:free" ...
    public DateTimeOffset GradedAt { get; set; }

    // Optional: lưu raw JSON để debug
    public string? RawLlmJson { get; set; }

    // Grammar rules used to ground the `gr` criterion
    [System.Text.Json.Serialization.JsonPropertyName("grammarRules")]
    public List<GrammarRuleDto> GrammarRules { get; set; } = new();

    // User-essay-specific grammar issues the LLM grader identified
    [System.Text.Json.Serialization.JsonPropertyName("grammarErrors")]
    public List<GrammarErrorDto> GrammarErrors { get; set; } = new();
}

