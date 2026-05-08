using System.Text.Json;
using writing_service.Contracts;
using writing_service.Domains.Entities;

namespace writing_service.Features.Helper;

public static class WritingEvaluationMapper
{
    public static WritingEvaluation MapToEvaluation(WritingGradeResponseDto response, LlmWritingScoreCompact raw)
    {
        var evaluation = new WritingEvaluation
        {
            SubmissionId = response.SubmissionId,
            OverallBand = response.OverallBand,
            CoherenceAndCohesionBand = response.CoherenceAndCohesion.Band,
            CoherenceAndCohesionComment = response.CoherenceAndCohesion.Comment,
            GrammaticalRangeAndAccuracyBand = response.GrammaticalRangeAndAccuracy.Band,
            GrammaticalRangeAndAccuracyComment = response.GrammaticalRangeAndAccuracy.Comment,
            CreatedAt = DateTime.UtcNow,
            LexicalResourceBand = response.LexicalResource.Band,
            LexicalResourceComment = response.LexicalResource.Comment,
            ImprovedParagraph = response.ImprovedParagraph,
            Model = "ai-service",  // ai-service resolves actual model
            TaskResponseBand = response.TaskResponse.Band,
            TaskResponseComment = response.TaskResponse.Comment,
            Provider = "ai-service",
            SuggestionsJson = JsonSerializer.Serialize(response.Suggestions),
            RawLlmJson = JsonSerializer.Serialize(raw),
            PromptSchemaVersion = "v2"  // ai-service uses v2 prompt schema
        };
        return evaluation;
    }
}