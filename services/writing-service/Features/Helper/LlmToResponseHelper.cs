using System;
using Shared.ExamDto.Contracts.Writing;
using writing_service.Contracts;

namespace writing_service.Features.Helper;

public static class LlmToResponseHelper
{
    public static string ResolveModelName()
    {
        var model = Environment.GetEnvironmentVariable("GEMINI__MODEL");
        return string.IsNullOrWhiteSpace(model) ? "gemini-2.5-flash-lite" : model;
    }

    public static string ResolveProvider()
    {
        var provider = Environment.GetEnvironmentVariable("GEMINI__PROVIDER");
        return string.IsNullOrWhiteSpace(provider) ? "gemini" : provider;
    }

    public static WritingGradeResponse MapToResponse(ContentSubmission submission, LlmWritingScoreCompact compact)
    {
        var wordCount = CountWords(submission.Answer);
        var model = ResolveModelName();
        var provider = ResolveProvider();

        return new WritingGradeResponse
        {

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
            Model = model,
            ModelProvider = provider,
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
