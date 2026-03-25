using System.Diagnostics;
using System.Globalization;
using Microsoft.EntityFrameworkCore.ValueGeneration.Internal;

namespace Shared.ExamDto.Contracts.Writing
{
    public record WritingGradeRequestMessage(
        Guid AttemptId,
        Guid UserId,
        Guid? QuestionId,
        string Type,
        string? TaskText,
        string? AnswerText,
        string TaskType = "TASK_2"  // Default to TASK_2 (more common), explicit field replaces fragile length heuristic
    );
    public class WritingGradeResponseMessage
    {
        public Guid AttemptId { get; set; }
        public Guid UserId { get; set; }
        public Guid? QuestionId { get; set; }
        public string? TaskText { get; set; } = string.Empty;
        // Bài viết
        public string EssayRaw { get; set; } = string.Empty;
        public string EssayNormalized { get; set; } = string.Empty;
        public int WordCount { get; set; }

        // Điểm
        public double OverallBand { get; set; }
        public CriterionScore TaskResponse { get; set; } = default!;
        public CriterionScore CoherenceAndCohesion { get; set; } = default!;
        public CriterionScore LexicalResource { get; set; } = default!;
        public CriterionScore GrammaticalRangeAndAccuracy { get; set; } = default!;

        // Gợi ý & ví dụ
        public List<string> Suggestions { get; set; } = default!;
        public string ImprovedParagraph { get; set; } = string.Empty;

        // Progressive band comparison result (populated asynchronously after grading)
        public string? ComparativeAnalysisJson { get; set; }
    };
    public class CriterionScore
    {
        public double Band { get; set; }
        public string Comment { get; set; } = string.Empty;
    }
}