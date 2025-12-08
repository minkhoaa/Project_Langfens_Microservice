namespace Shared.ExamDto.Contracts.Speaking
{
    public class SpeakingGradingResponseMessage
    {
        public Guid AttemptId { get; set; }
        public Guid UserId { get; set; }
        public Guid? QuestionId { get; set; }
        public string? TaskText { get; set; } = string.Empty;
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

    }

    public class CriterionScore
    {
        public double Band { get; set; }
        public string Comment { get; set; } = string.Empty;
    }

}