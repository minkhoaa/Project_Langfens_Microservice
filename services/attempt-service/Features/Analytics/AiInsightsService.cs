using System.Text.Json;
using Microsoft.SemanticKernel;
using Microsoft.SemanticKernel.ChatCompletion;
using Microsoft.SemanticKernel.Connectors.OpenAI;
using attempt_service.Domain.Enums;
using attempt_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace attempt_service.Features.Analytics;

public interface IAiInsightsService
{
    Task<IResult> GetAiInsights(Guid userId, CancellationToken token);
}

public class AiInsightsService : IAiInsightsService
{
    private readonly AttemptDbContext _context;
    private readonly IChatCompletionService _chat;
    private readonly Kernel _kernel;
    private readonly ILogger<AiInsightsService> _logger;

    public AiInsightsService(
        AttemptDbContext context,
        IChatCompletionService chat,
        Kernel kernel,
        ILogger<AiInsightsService> logger)
    {
        _context = context;
        _chat = chat;
        _kernel = kernel;
        _logger = logger;
    }

    public async Task<IResult> GetAiInsights(Guid userId, CancellationToken token)
    {
        // Get predicted band data
        var placementResults = await _context.PlacementResults
            .AsNoTracking()
            .Where(pr => pr.UserId == userId && pr.Band > 0)
            .OrderByDescending(pr => pr.CreatedAt)
            .Take(20)
            .ToListAsync(token);

        if (placementResults.Count < 1)
        {
            return Results.Ok(new
            {
                isSuccess = false,
                message = "Need at least 1 placement test for AI insights",
                data = (object?)null
            });
        }

        // Calculate bands (simplified - reusing logic from BandPredictorService)
        var overallBand = placementResults.Average(p => p.Band);
        var readingBand = CalculateSkillBand(placementResults, p => p.ReadingCorrect, p => p.ReadingTotal);
        var listeningBand = CalculateSkillBand(placementResults, p => p.ListeningCorrect, p => p.ListeningTotal);
        var writingBand = placementResults.Where(p => p.WritingBand > 0).Select(p => p.WritingBand).DefaultIfEmpty(0).Average();
        var speakingBand = placementResults.Where(p => p.SpeakingBand > 0).Select(p => p.SpeakingBand).DefaultIfEmpty(0).Average();
        
        // Get strengths/weaknesses from analytics
        var strengthsWeaknesses = await GetStrengthsWeaknesses(userId, token);

        // Build prompt
        var userPrompt = AiInsightsPrompt.BuildUserPrompt(
            (decimal)overallBand,
            readingBand > 0 ? (decimal?)readingBand : null,
            listeningBand > 0 ? (decimal?)listeningBand : null,
            writingBand > 0 ? (decimal?)writingBand : null,
            speakingBand > 0 ? (decimal?)speakingBand : null,
            placementResults.Count >= 5 ? "High" : placementResults.Count >= 3 ? "Medium" : "Low",
            placementResults.Count,
            strengthsWeaknesses.strengths,
            strengthsWeaknesses.weaknesses
        );

        try
        {
            var history = new ChatHistory();
            history.AddSystemMessage(AiInsightsPrompt.SystemPrompt);
            history.AddUserMessage(userPrompt);

            var settings = new OpenAIPromptExecutionSettings
            {
                Temperature = 0.3,
                MaxTokens = 800,
                ResponseFormat = "json_object",
            };

            var messages = await _chat.GetChatMessageContentsAsync(
                history,
                executionSettings: settings,
                kernel: _kernel,
                cancellationToken: token);

            var content = messages.LastOrDefault()?.Content;
            if (string.IsNullOrWhiteSpace(content))
            {
                _logger.LogWarning("Azure OpenAI returned empty content for AI insights");
                return Results.Ok(new
                {
                    isSuccess = false,
                    message = "AI could not generate insights",
                    data = (object?)null
                });
            }

            var trimmed = content.Trim();
            // Remove markdown code blocks if present
            if (trimmed.StartsWith("```"))
            {
                var lines = trimmed.Split('\n');
                trimmed = string.Join('\n', lines.Skip(1).TakeWhile(l => !l.StartsWith("```")));
            }

            var llmResponse = JsonSerializer.Deserialize<LlmInsightsResponse>(trimmed, new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true
            });

            if (llmResponse == null)
            {
                return Results.Ok(new
                {
                    isSuccess = false,
                    message = "Failed to parse AI response",
                    data = (object?)null
                });
            }

            var result = new AiInsightsDto(
                llmResponse.Summary,
                llmResponse.TrendAnalysis,
                llmResponse.Recommendations,
                llmResponse.FocusAreas.Select(f => new FocusAreaDto(f.Skill, f.Area, f.Reason, f.Priority)).ToList(),
                DateTime.UtcNow
            );

            return Results.Ok(new
            {
                isSuccess = true,
                message = "AI insights generated",
                data = result
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to generate AI insights for user {UserId}", userId);
            return Results.Ok(new
            {
                isSuccess = false,
                message = "Failed to generate AI insights",
                data = (object?)null
            });
        }
    }

    private decimal CalculateSkillBand<T>(List<T> results, Func<T, int> getCorrect, Func<T, int> getTotal)
    {
        var validResults = results.Where(r => getTotal(r) > 0).ToList();
        if (!validResults.Any()) return 0;
        
        var avgAccuracy = validResults.Average(r => (decimal)getCorrect(r) / getTotal(r));
        return Math.Round(1.0m + (avgAccuracy * 8.0m), 1);
    }

    private Task<(List<(string type, decimal accuracy)>? strengths, List<(string type, decimal accuracy)>? weaknesses)> 
        GetStrengthsWeaknesses(Guid userId, CancellationToken token)
    {
        // Note: AttemptAnswer doesn't have QuestionType field
        // This data is optional for AI insights - can be enhanced later
        return Task.FromResult<(List<(string type, decimal accuracy)>? strengths, List<(string type, decimal accuracy)>? weaknesses)>((null, null));
    }
}
