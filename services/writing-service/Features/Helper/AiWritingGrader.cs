using System.Text.Json;
using Microsoft.Extensions.DependencyInjection;
using writing_service.Contracts;

namespace writing_service.Features.Helper;

public class AiWritingGrader : IWritingGrader
{
    private readonly HttpClient _http;
    private readonly ILogger<AiWritingGrader> _logger;
    private readonly CircuitBreaker _circuitBreaker;

    public AiWritingGrader(HttpClient http, ILogger<AiWritingGrader> logger, [FromKeyedServices("grader")] CircuitBreaker circuitBreaker)
    {
        _http = http;
        _logger = logger;
        _circuitBreaker = circuitBreaker;
    }

    public async Task<WritingGradeResult> GradeAsync(ContentSubmission submission, CancellationToken ct)
    {
        if (!_circuitBreaker.CanExecute())
        {
            _logger.LogWarning("AI grade call rejected - circuit breaker is open for task {Task}", submission.Task);
            throw new InvalidOperationException("AI service circuit breaker is open");
        }

        var wordCount = submission.Answer?.Split(' ', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries).Length ?? 0;

        var request = new
        {
            task = submission.Task,
            answer = submission.Answer,
            word_count = wordCount,
            chart_description = submission.ChartDescription,
            task_type = submission.TaskType
        };

        try
        {
            var response = await _http.PostAsJsonAsync("/api/v1/writing/grade", request, ct);
            response.EnsureSuccessStatusCode();
            _circuitBreaker.RecordSuccess();

            var gradeResponse = await response.Content.ReadFromJsonAsync<WritingGradeResponseDto>(ct)
                                ?? throw new InvalidOperationException("Failed to deserialize ai-service response");

            var compact = new LlmWritingScoreCompact
            {
                OverallBand = gradeResponse.OverallBand,
                TaskResponse = new CriterionArray { Band = gradeResponse.TaskResponse.Band, Comment = gradeResponse.TaskResponse.Comment },
                CoherenceAndCohesion = new CriterionArray { Band = gradeResponse.CoherenceAndCohesion.Band, Comment = gradeResponse.CoherenceAndCohesion.Comment },
                LexicalResource = new CriterionArray { Band = gradeResponse.LexicalResource.Band, Comment = gradeResponse.LexicalResource.Comment },
                GrammaticalRangeAndAccuracy = new CriterionArray { Band = gradeResponse.GrammaticalRangeAndAccuracy.Band, Comment = gradeResponse.GrammaticalRangeAndAccuracy.Comment },
                Suggestions = gradeResponse.Suggestions,
                ImprovedParagraph = gradeResponse.ImprovedParagraph
            };

            var result = new WritingGradeResult
            {
                Response = gradeResponse,
                Compact = compact
            };

            return result;
        }
        catch (Exception ex)
        {
            _circuitBreaker.RecordFailure();
            _logger.LogWarning(ex, "AI grade call failed for task {Task}", submission.Task);
            throw;
        }
    }
}