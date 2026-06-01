using System.Net.Http.Json;
using System.Text.Json.Serialization;
using Microsoft.Extensions.Logging;
using Shared.ExamDto.Contracts.Speaking;
using speaking_service.Contracts;
using speaking_service.Domains.Entities;

namespace speaking_service.Features.Services.Helper;

public class AiSpeakingGrader : ISpeakingGrader
{
    private readonly HttpClient _http;
    private readonly ILogger<AiSpeakingGrader> _logger;

    public AiSpeakingGrader(HttpClient http, ILogger<AiSpeakingGrader> logger)
    {
        _http = http;
        _logger = logger;
    }

    public async Task<SpeakingGradeResult> GradeAsync(ContentSubmission submission, CancellationToken ct)
    {
        var request = new
        {
            task = submission.Task,
            transcript = submission.Transcript,
            word_count = submission.Transcript.Split(' ', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries).Length
        };

        var httpResponse = await _http.PostAsJsonAsync("/api/v1/speaking/grade", request, ct);

        if (!httpResponse.IsSuccessStatusCode)
        {
            var errorBody = await httpResponse.Content.ReadAsStringAsync(ct);
            _logger.LogError("ai-service speaking grade returned {StatusCode}: {ErrorBody}",
                httpResponse.StatusCode, errorBody);
            httpResponse.EnsureSuccessStatusCode();
        }

        // ai-service returns SpeakingGradeResponse with compact JSON field names (ob, fc, lr, gr, pr, s, p)
        // We must use a DTO that matches those names exactly for correct deserialization
        var aiResponse = await httpResponse.Content.ReadFromJsonAsync<AiSpeakingApiResponse>(ct)
            ?? throw new InvalidOperationException("Null response from ai-service speaking grade");

        var wordCount = submission.Transcript.Split(' ', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries).Length;

        // Map ai-service response → LlmSpeakingScoreCompact
        var compact = new LlmSpeakingScoreCompact
        {
            OverallBand = aiResponse.ob,
            FluencyAndCoherence = new CriterionArray { Band = aiResponse.fc.b, Comment = aiResponse.fc.c },
            LexicalResource = new CriterionArray { Band = aiResponse.lr.b, Comment = aiResponse.lr.c },
            GrammaticalRangeAndAccuracy = new CriterionArray { Band = aiResponse.gr.b, Comment = aiResponse.gr.c },
            Pronunciation = new CriterionArray { Band = aiResponse.pr.b, Comment = aiResponse.pr.c },
            Suggestions = aiResponse.s,
            ImprovedAnswer = aiResponse.p,
        };

        // Build SpeakingGradeResponse (with .NET naming) for downstream use
        var response = new SpeakingGradeResponse
        {
            SubmissionId = Guid.NewGuid(),
            TaskText = submission.Task,
            TranscriptRaw = submission.Transcript,
            TranscriptNormalized = submission.Transcript,
            WordCount = wordCount,
            OverallBand = aiResponse.ob,
            FluencyAndCoherence = new CriterionScore { Band = aiResponse.fc.b, Comment = aiResponse.fc.c },
            LexicalResource = new CriterionScore { Band = aiResponse.lr.b, Comment = aiResponse.lr.c },
            GrammaticalRangeAndAccuracy = new CriterionScore { Band = aiResponse.gr.b, Comment = aiResponse.gr.c },
            Pronunciation = new CriterionScore { Band = aiResponse.pr.b, Comment = aiResponse.pr.c },
            Suggestions = aiResponse.s,
            ImprovedAnswer = aiResponse.p,
            Model = "qwen25-lora",
            ModelProvider = "local",
            GradedAt = DateTimeOffset.UtcNow,
            RawLlmJson = aiResponse.raw_llm_json,
        };

        // Build SpeakingGradeResponseDto for JSON compat
        var responseDto = new SpeakingGradeResponseDto
        {
            OverallBand = aiResponse.ob,
            FluencyAndCoherence = new CriterionScore { Band = aiResponse.fc.b, Comment = aiResponse.fc.c },
            LexicalResource = new CriterionScore { Band = aiResponse.lr.b, Comment = aiResponse.lr.c },
            GrammaticalRangeAndAccuracy = new CriterionScore { Band = aiResponse.gr.b, Comment = aiResponse.gr.c },
            Pronunciation = new CriterionScore { Band = aiResponse.pr.b, Comment = aiResponse.pr.c },
            Suggestions = aiResponse.s,
            ImprovedAnswer = aiResponse.p,
            RawLlmJson = aiResponse.raw_llm_json,
            WordCount = wordCount,
        };

        return new SpeakingGradeResult { Response = responseDto, Compact = compact };
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
            Provider = response.ModelProvider ?? "local",
            SuggestionsJson = System.Text.Json.JsonSerializer.Serialize(response.Suggestions),
            RawLlmJson = System.Text.Json.JsonSerializer.Serialize(raw),
            PromptSchemaVersion = "v1"
        };
        return evaluation;
    }
}
