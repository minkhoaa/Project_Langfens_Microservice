using System;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.SemanticKernel;
using Microsoft.SemanticKernel.ChatCompletion;
using Microsoft.SemanticKernel.Connectors.Google;
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
        private readonly IChatCompletionService _chat;
        private readonly Kernel _kernel;
        public SpeakingGrader(ILogger<SpeakingGrader> logger, Kernel kernel, IChatCompletionService chat)
        {
            _logger = logger;
            _kernel = kernel;
            _chat = chat;
        }
        public async Task<(SpeakingGradeResponse, LlmSpeakingScoreCompact)> Grade(ContentSubmission submission, CancellationToken token)
        {
            var systemPrompt =
                "IELTS speaking examiner. Score 0-9. Reply ONLY JSON:{\"ob\":6.5," +
                "\"fc\":{\"b\":6,\"c\":\"...\"},\"lr\":{\"b\":7,\"c\":\"...\"}," +
                "\"gr\":{\"b\":6,\"c\":\"...\"},\"pr\":{\"b\":6,\"c\":\"...\"}," +
                "\"s\":[\"...\"],\"p\":\"...\"}. ob=overall; fc,lr,gr,pr=criteria; s=suggestions; b=band; c=comment; p=improved answer.";

            var userContent = $"T:{submission.Task}\nE:{submission.Transcript}";

            var history = new ChatHistory();
            history.AddSystemMessage(systemPrompt);
            history.AddUserMessage(userContent);

            var settings = new GeminiPromptExecutionSettings
            {
                Temperature = 0.2,
                MaxTokens = 1200,
                ResponseMimeType = "application/json",
                ResponseSchema = typeof(LlmSpeakingScoreCompact)
            };

            var messages = await _chat.GetChatMessageContentsAsync(
                history,
                executionSettings: settings,
                kernel: _kernel,
                cancellationToken: token);
            var content = messages.LastOrDefault()?.Content;
            if (string.IsNullOrWhiteSpace(content))
            {
                _logger.LogWarning("Gemini returned empty content for speaking submission.");
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

