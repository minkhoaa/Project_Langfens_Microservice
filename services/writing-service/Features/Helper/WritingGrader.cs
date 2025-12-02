using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Options;
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
        private readonly OpenRouterOptions _router;
        private readonly IHttpClientFactory _client;
        public WritingGrader(
        IOptions<OpenRouterOptions> router,
        IHttpClientFactory client)
        {
            _client = client;
            _router = router.Value;
        }
        public async Task<(WritingGradeResponse, LlmWritingScoreCompact)> Grade(ContentSubmission submission, CancellationToken token)
        {
            var client = _client.CreateClient("openrouter");
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

            var payload = new
            {
                model = _router.Model,
                messages = new[]
                {
                new { role = "system", content = systemPrompt },
                new { role = "user", content = userContent }
            },
                temperature = 0.2,
                max_tokens = 800
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
            if (jsonRes is null) throw new InvalidOperationException("Cannot convert into Object");
            var resp = LlmToResponseHelper.MapToResponse(submission, jsonRes);
            return (resp, jsonRes);
        }

        public WritingEvaluation MapToEvaluation(WritingGradeResponse response, LlmWritingScoreCompact raw)
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
                Model = response.Model,
                TaskResponseBand = response.TaskResponse.Band,
                TaskResponseComment = response.TaskResponse.Comment,
                Provider = "LLM Provider",
                SuggestionsJson = JsonSerializer.Serialize(response.Suggestions),
                RawLlmJson = JsonSerializer.Serialize(raw),
                PromptSchemaVersion = "v1"
            };
            return evaluation;

        }
    }
}