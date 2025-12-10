using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Options;
using Microsoft.OpenApi.Validations.Rules;
using Microsoft.SemanticKernel;
using Microsoft.SemanticKernel.ChatCompletion;
using Microsoft.SemanticKernel.Connectors.Google;
using writing_service.Contracts;
using writing_service.Domains.Entities;
using writing_service.Infrastructure.Persistence;

namespace writing_service.Features.Helper
{
    public interface IWritingGrader
    {
        Task<(WritingGradeResponse, LlmWritingScoreCompact)> Grade(ContentSubmission submission, CancellationToken token);
        WritingEvaluation MapToEvaluation(WritingGradeResponse response, LlmWritingScoreCompact raw);
    }
    public class WritingGrader : IWritingGrader
    {

        private readonly ILogger<WritingGrader> _logger;
        private readonly IChatCompletionService _chat;
        private readonly Kernel _kernel;
        public WritingGrader(
        ILogger<WritingGrader> logger, Kernel kernel, IChatCompletionService chat
        )
        {
            _chat = chat;
            _kernel = kernel;
            _logger = logger;
        }
        public async Task<(WritingGradeResponse, LlmWritingScoreCompact)> Grade(ContentSubmission submission, CancellationToken token)
        {
            var systemPrompt =
                "IELTS W2 examiner. Score essay 0-9. " +
                "Reply ONLY JSON:{\"ob\":6.5," +
                "\"ta\":{\"b\":6,\"c\":\"...\"}," +
                "\"cc\":{\"b\":6,\"c\":\"...\"}," +
                "\"lr\":{\"b\":7,\"c\":\"...\"}," +
                "\"gr\":{\"b\":6,\"c\":\"...\"}," +
                "\"s\":[\"...\"],\"p\":\"...\"}. " +
                "ob=overall; ta,cc,lr,gr=criteria; s=suggestions; b=band; c=comment; p=improved paragraph.";

            var userContent = $"T:{submission.Task}\nE:{submission.Answer}";
            var history = new ChatHistory();
            history.AddSystemMessage(systemPrompt);
            history.AddUserMessage(userContent);
            var settings = new GeminiPromptExecutionSettings
            {
                Temperature = 0.2,
                MaxTokens = 1200,
                ResponseMimeType = "application/json",
                ResponseSchema = typeof(LlmWritingScoreCompact)
            };
            var messages = await _chat.GetChatMessageContentsAsync(history, executionSettings: settings, kernel: _kernel, cancellationToken: token);
            var content = messages.LastOrDefault()?.Content;
            if (string.IsNullOrWhiteSpace(content))
            {
                _logger.LogWarning("Gemini returned empty content.");
                throw new InvalidOperationException("Model returned empty content.");
            }

            var trimmed = content.Trim();
            trimmed = ExtractJsonObject.Extract(trimmed);
            LlmWritingScoreCompact jsonRes;
            try
            {
                jsonRes = JsonSerializer.Deserialize<LlmWritingScoreCompact>(trimmed)
                          ?? throw new InvalidOperationException("Cannot convert model JSON into object.");
            }
            catch (JsonException ex)
            {
                throw new InvalidOperationException(
                    $"Failed to parse model JSON. Content: {trimmed[..Math.Min(trimmed.Length, 200)]}",
                    ex);
            }

            var resp = LlmToResponseHelper.MapToResponse(submission, jsonRes);
            return (resp, jsonRes);
        }

        public WritingEvaluation MapToEvaluation(WritingGradeResponse response, LlmWritingScoreCompact raw)
        {
            var model = LlmToResponseHelper.ResolveModelName();
            var provider = LlmToResponseHelper.ResolveProvider();
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
                Model = model,
                TaskResponseBand = response.TaskResponse.Band,
                TaskResponseComment = response.TaskResponse.Comment,
                Provider = provider,
                SuggestionsJson = JsonSerializer.Serialize(response.Suggestions),
                RawLlmJson = JsonSerializer.Serialize(raw),
                PromptSchemaVersion = "v1"
            };
            return evaluation;

        }
    }
}
