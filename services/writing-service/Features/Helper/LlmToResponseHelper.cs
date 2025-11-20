using writing_service.Contracts;

namespace writing_service.Features.Helper;

public static class LlmToResponseHelper
{
    public static WritingGradeResponse MapToResponse(ContentSubmission submission, LlmWritingScoreCompact compact)
    {
        var wordCount = CountWords(submission.Answer);

        return new WritingGradeResponse
        {
            SubmissionId = Guid.NewGuid(),
            TaskText = submission.Task,
            EssayRaw = submission.Answer,
            EssayNormalized = submission.Answer,
            WordCount = wordCount,
            OverallBand = compact.OverallBand,

            TaskResponse = new CriterionScore
            {
                Band = compact.TaskResponse.Band,
                Comment = compact.TaskResponse.Comment
            },
            CoherenceAndCohesion = new CriterionScore
            {
                Band = compact.CoherenceAndCohesion.Band,
                Comment = compact.CoherenceAndCohesion.Comment
            },
            LexicalResource = new CriterionScore
            {
                Band = compact.LexicalResource.Band,
                Comment = compact.LexicalResource.Comment
            },
            GrammaticalRangeAndAccuracy = new CriterionScore
            {
                Band = compact.GrammaticalRangeAndAccuracy.Band,
                Comment = compact.GrammaticalRangeAndAccuracy.Comment
            },

            Suggestions = compact.Suggestions,
            ImprovedParagraph = compact.ImprovedParagraph,
            Model = string.Empty,
            ModelProvider = "openrouter",
            GradedAt = DateTimeOffset.UtcNow,
            RawLlmJson = null 
        };
    }

    public static int CountWords(string text)
    {
        if (string.IsNullOrWhiteSpace(text)) return 0;
        return text
            .Split(new[] { ' ', '\n', '\r', '\t' }, StringSplitOptions.RemoveEmptyEntries)
            .Length;
    }
}