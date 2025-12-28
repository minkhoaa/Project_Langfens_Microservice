using System;
using System.Text.Json;
using System.Threading.Tasks;
using OpenAI.Chat;
using Microsoft.Extensions.Logging;
using speaking_service.Contracts;
using speaking_service.Domains.Entities;
using speaking_service.Features.Helper;

namespace speaking_service.Features.Services.Helper
{
    public interface ISpeakingGrader
    {
        Task<(SpeakingGradeResponse, LlmSpeakingScoreCompact)> Grade(ContentSubmission submission, CancellationToken token);
        SpeakingEvaluation MapToEvaluation(SpeakingGradeResponse response, LlmSpeakingScoreCompact raw);
    }

    public class SpeakingGrader : ISpeakingGrader
    {
        private readonly ILogger<SpeakingGrader> _logger;
        private readonly ChatClient _chatClient;

        public SpeakingGrader(ILogger<SpeakingGrader> logger, ChatClient chatClient)
        {
            _logger = logger;
            _chatClient = chatClient;
        }

        public async Task<(SpeakingGradeResponse, LlmSpeakingScoreCompact)> Grade(ContentSubmission submission, CancellationToken token)
        {
            string systemPrompt = SpeakingTemplate.SystemPrompt;
            var userContent = $"""
                            Q:{submission.Task}
                            E:{submission.Transcript} 
                            """;

            var messages = new List<ChatMessage>
            {
                new SystemChatMessage(systemPrompt),
                new UserChatMessage(userContent)
            };

            var options = new ChatCompletionOptions
            {
                Temperature = 0.2f,
                MaxOutputTokenCount = 1200,
                ResponseFormat = ChatResponseFormat.CreateJsonObjectFormat()
            };

            var completion = await _chatClient.CompleteChatAsync(messages, options, token);
            var content = completion.Value.Content.FirstOrDefault()?.Text;

            if (string.IsNullOrWhiteSpace(content))
            {
                _logger.LogWarning("Azure OpenAI returned empty content for speaking submission.");
                throw new InvalidOperationException("Model returned empty content.");
            }

            var trimmed = content.Trim();
            trimmed = ExtractJsonObject.Extract(trimmed);

            LlmSpeakingScoreCompact jsonRes;
            try
            {
                jsonRes = JsonSerializer.Deserialize<LlmSpeakingScoreCompact>(trimmed)
                          ?? throw new InvalidOperationException("Cannot convert model JSON into object.");
            }
            catch (JsonException ex)
            {
                throw new InvalidOperationException(
                    $"Failed to parse model JSON. Content: {trimmed[..Math.Min(trimmed.Length, 200)]}",
                    ex);
            }

            if (jsonRes is null) throw new InvalidOperationException("Cannot convert into Object");
            var resp = LlmToResponseHelper.MapToResponse(submission, jsonRes);
            return (resp, jsonRes);
        }

        public SpeakingEvaluation MapToEvaluation(SpeakingGradeResponse response, LlmSpeakingScoreCompact raw)
        {
            var evaluation = new SpeakingEvaluation
            {
                SubmissionId = response.SubmissionId,
                OverallBand = response.OverallBand,
                FluencyAndCoherenceBand = response.FluencyAndCoherence.Band,
                FluencyAndCoherenceComment = response.FluencyAndCoherence.Comment,
                GrammaticalRangeAndAccuracyBand = response.GrammaticalRangeAndAccuracy.Band,
                GrammaticalRangeAndAccuracyComment = response.GrammaticalRangeAndAccuracy.Comment,
                CreatedAt = DateTime.UtcNow,
                LexicalResourceBand = response.LexicalResource.Band,
                LexicalResourceComment = response.LexicalResource.Comment,
                ImprovedAnswer = response.ImprovedAnswer,
                Model = response.Model,
                PronunciationBand = response.Pronunciation.Band,
                PronunciationComment = response.Pronunciation.Comment,
                Provider = response.ModelProvider ?? LlmToResponseHelper.ResolveProvider(),
                SuggestionsJson = JsonSerializer.Serialize(response.Suggestions),
                RawLlmJson = JsonSerializer.Serialize(raw),
                PromptSchemaVersion = "v1"
            };
            return evaluation;
        }
    }
}
