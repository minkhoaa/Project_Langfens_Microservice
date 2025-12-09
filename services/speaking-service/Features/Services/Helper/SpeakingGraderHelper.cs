using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.Extensions.Options;
using speaking_service.Contracts;
using speaking_service.Domains.Entities;
using speaking_service.Features.Helper;

namespace speaking_service.Features.Services.Helper
{

    public interface ISpeakingGrader
    {
        Task<(SpeakingGradeResponse, LlmSpeakingScoreCompact)> Grade(ContentSubmission submission, CancellationToken token);
    }
    public class SpeakingGrader : ISpeakingGrader
    {
        private readonly IHttpClientFactory _client;
        private readonly OpenRouterOptions _router;
        public SpeakingGrader(IHttpClientFactory client, IOptions<OpenRouterOptions> router
)
        {
            _client = client;
            _router = router.Value;
        }
        public async Task<(SpeakingGradeResponse, LlmSpeakingScoreCompact)> Grade(ContentSubmission submission, CancellationToken token)
        {
            var client = _client.CreateClient("openrouter");
            var systemPrompt =
                "IELTS speaking examiner. Score 0-9. Reply ONLY JSON:{\"ob\":6.5," +
                "\"fc\":{\"b\":6,\"c\":\"...\"},\"lr\":{\"b\":7,\"c\":\"...\"}," +
                "\"gr\":{\"b\":6,\"c\":\"...\"},\"pr\":{\"b\":6,\"c\":\"...\"}," +
                "\"s\":[\"...\"],\"p\":\"...\"}. ob=overall; fc,lr,gr,pr=criteria; s=suggestions; b=band; c=comment; p=improved answer.";

            var userContent = $"T:{submission.Task}\nE:{submission.Transcript}";

            var payload = new
            {
                model = _router.Model,
                messages = new[]
                {
                new { role = "system", content = systemPrompt },
                new { role = "user", content = userContent }
            },
                temperature = 0.2,
                max_tokens = 800,
                response_format = new { type = "json_object" }
            };
            var json = JsonSerializer.Serialize(payload);

            using var content = new StringContent(json, Encoding.UTF8, "application/json");
            var response = await client.PostAsync("chat/completions", content, token);
            if (!response.IsSuccessStatusCode)
            {
                var err = await response.Content.ReadAsStringAsync(token);
                throw new HttpRequestException($"OpenRouter error {(int)response.StatusCode}: {err}");
            }

            var responseText = await response.Content.ReadAsStringAsync(token);
            var responseTrimmed = responseText.TrimStart();
            if (!(responseTrimmed.StartsWith("{") || responseTrimmed.StartsWith("[")))
            {
                throw new InvalidOperationException(
                    $"OpenRouter returned non-JSON. Status {(int)response.StatusCode}. Starts with: {responseTrimmed[..Math.Min(responseTrimmed.Length, 120)]}");
            }
            using var doc = JsonDocument.Parse(responseText);
            var assistantContent = doc.RootElement
                .GetProperty("choices")[0]
                .GetProperty("message")
                .GetProperty("content")
                .GetString();

            if (string.IsNullOrWhiteSpace(assistantContent))
                throw new InvalidOperationException("Model returned empty content.");
            var trimmed = assistantContent.Trim();


            if (trimmed.StartsWith("```"))
            {
                var firstNewLine = trimmed.IndexOf('\n');
                if (firstNewLine >= 0)
                {
                    trimmed = trimmed[(firstNewLine + 1)..];
                    var fenceIndex = trimmed.LastIndexOf("```", StringComparison.Ordinal);
                    if (fenceIndex >= 0)
                        trimmed = trimmed[..fenceIndex];
                }
                trimmed = trimmed.Trim();
            }
            if (!(trimmed.StartsWith("{") || trimmed.StartsWith("[")))
            {
                throw new InvalidOperationException(
                    $"Model did not return JSON. Starts with: {trimmed[..Math.Min(trimmed.Length, 50)]}");
            }
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

        private SpeakingEvaluation MapToEvaluation(SpeakingGradeResponse response, LlmSpeakingScoreCompact raw)
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
                Provider = "LLM Provider",
                SuggestionsJson = JsonSerializer.Serialize(response.Suggestions),
                RawLlmJson = JsonSerializer.Serialize(raw),
                PromptSchemaVersion = "v1"
            };
            return evaluation;

        }
    }

}