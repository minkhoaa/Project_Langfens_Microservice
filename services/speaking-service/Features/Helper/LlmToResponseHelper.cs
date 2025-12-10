using System;
using Shared.ExamDto.Contracts.Speaking;
using speaking_service.Contracts;

namespace speaking_service.Features.Helper;

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

    public static SpeakingGradeResponse MapToResponse(
        ContentSubmission submission,
        LlmSpeakingScoreCompact compact
    )
    {
        var wordCount = CountWords(submission.Transcript);
        var model = ResolveModelName();
        var provider = ResolveProvider();

        return new SpeakingGradeResponse
        {
            SubmissionId = Guid.NewGuid(),
            TaskText = submission.Task,
            TranscriptRaw = submission.Transcript,
            TranscriptNormalized = submission.Transcript,
            WordCount = wordCount,
            OverallBand = compact.OverallBand,
            FluencyAndCoherence = new CriterionScore
            {
                Band = compact.FluencyAndCoherence.Band,
                Comment = compact.FluencyAndCoherence.Comment,
            },
            LexicalResource = new CriterionScore
            {
                Band = compact.LexicalResource.Band,
                Comment = compact.LexicalResource.Comment,
            },
            GrammaticalRangeAndAccuracy = new CriterionScore
            {
                Band = compact.GrammaticalRangeAndAccuracy.Band,
                Comment = compact.GrammaticalRangeAndAccuracy.Comment,
            },
            Pronunciation = new CriterionScore
            {
                Band = compact.Pronunciation.Band,
                Comment = compact.Pronunciation.Comment,
            },
            Suggestions = compact.Suggestions,
            ImprovedAnswer = compact.ImprovedAnswer,
            Model = model,
            ModelProvider = provider,
            GradedAt = DateTimeOffset.UtcNow,
            RawLlmJson = null,
        };
    }

    public static int CountWords(string text)
    {
        if (string.IsNullOrWhiteSpace(text))
            return 0;
        return text.Split(
            new[] { ' ', '\n', '\r', '\t' },
            StringSplitOptions.RemoveEmptyEntries
        ).Length;
    }
}
