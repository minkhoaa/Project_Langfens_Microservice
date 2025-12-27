using System.Text.Json;
using Microsoft.SemanticKernel;
using Microsoft.SemanticKernel.ChatCompletion;
using Microsoft.SemanticKernel.Connectors.OpenAI;
using writing_service.Contracts;
using writing_service.Domains.Entities;

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
            string systemPrompt = WritingTemplate.SystemPrompt;
            var wordCount = submission.Answer?.Split(' ', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries).Length ?? 0;

            var userContent = $"""
                            WC:{wordCount}
                            T:{submission.Task}
                            E:{submission.Answer}
                            """;
            var history = new ChatHistory();
            history.AddSystemMessage(systemPrompt);
            history.AddUserMessage(userContent);
            var settings = new OpenAIPromptExecutionSettings
            {
                Temperature = 0.1,
                MaxTokens = 1200,
                ResponseFormat = "json_object",
            };
            var messages = await _chat.GetChatMessageContentsAsync(history, executionSettings: settings, kernel: _kernel, cancellationToken: token);
            var content = messages.LastOrDefault()?.Content;
            if (string.IsNullOrWhiteSpace(content))
            {
                _logger.LogWarning("Azure OpenAI returned empty content.");
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
