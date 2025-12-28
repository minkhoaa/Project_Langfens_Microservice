using System.Text.Json;
using OpenAI.Chat;
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
        private readonly ChatClient _chatClient;

        public WritingGrader(ILogger<WritingGrader> logger, ChatClient chatClient)
        {
            _chatClient = chatClient;
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

            var messages = new List<ChatMessage>
            {
                new SystemChatMessage(systemPrompt),
                new UserChatMessage(userContent)
            };

            var options = new ChatCompletionOptions
            {
                Temperature = 0.1f,
                MaxOutputTokenCount = 1200,
                ResponseFormat = ChatResponseFormat.CreateJsonObjectFormat()
            };

            var completion = await _chatClient.CompleteChatAsync(messages, options, token);
            var content = completion.Value.Content.FirstOrDefault()?.Text;

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
