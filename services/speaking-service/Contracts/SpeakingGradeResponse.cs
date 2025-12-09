using Shared.ExamDto.Contracts.Speaking;

namespace speaking_service.Contracts;

public class SpeakingGradeResponse
{
    public Guid SubmissionId { get; set; }

    public string TaskText { get; set; } = string.Empty;
    public string TranscriptRaw { get; set; } = string.Empty;
    public string TranscriptNormalized { get; set; } = string.Empty;
    public int WordCount { get; set; }

    public double OverallBand { get; set; }
    public CriterionScore FluencyAndCoherence { get; set; } = new();
    public CriterionScore LexicalResource { get; set; } = new();
    public CriterionScore GrammaticalRangeAndAccuracy { get; set; } = new();
    public CriterionScore Pronunciation { get; set; } = new();

    public List<string> Suggestions { get; set; } = new();
    public string ImprovedAnswer { get; set; } = string.Empty;

    public string Model { get; set; } = string.Empty;
    public string? ModelProvider { get; set; }
    public DateTimeOffset GradedAt { get; set; }

    public string? RawLlmJson { get; set; }
}

