using attempt_service.Features.Helpers;

namespace attempt_service.Features.Analytics;

public static class AnalyticsEndpoint
{
    public static void MapAnalyticsEndpoints(this WebApplication app)
    {
        var group = app.MapGroup("/api/analytics")
            .WithTags("Analytics")
            .RequireAuthorization();

        group.MapGet("/summary", Handler.GetSummary)
            .WithName("GetAnalyticsSummary")
            .WithDescription("Get user's overall learning summary");

        group.MapGet("/score-trend", Handler.GetScoreTrend)
            .WithName("GetScoreTrend")
            .WithDescription("Get user's score trend over time");

        group.MapGet("/strengths", Handler.GetStrengthsWeaknesses)
            .WithName("GetStrengthsWeaknesses")
            .WithDescription("Get user's strengths and weaknesses by question type");

        group.MapGet("/recent-activity", Handler.GetRecentActivity)
            .WithName("GetRecentActivity")
            .WithDescription("Get user's recent learning activities");

        group.MapGet("/errors", Handler.GetWrongAnswers)
            .WithName("GetWrongAnswers")
            .WithDescription("Get user's wrong answers for review");
        
        group.MapGet("/predicted-band", Handler.GetPredictedBand)
            .WithName("GetPredictedBand")
            .WithDescription("Get user's predicted IELTS band score");
        
        group.MapGet("/ai-insights", Handler.GetAiInsights)
            .WithName("GetAiInsights")
            .WithDescription("Get AI-generated study insights and recommendations");
        
        group.MapGet("/recommendations", Handler.GetRecommendations)
            .WithName("GetRecommendations")
            .WithDescription("Get personalized exam recommendations based on weaknesses");
    }

    private static class Handler
    {
        public static Task<IResult> GetSummary(
            CancellationToken token,
            IAnalyticsService service,
            IUserContext userContext
        ) => service.GetSummary(userContext.UserId, token);

        public static Task<IResult> GetScoreTrend(
            int days = 30,
            CancellationToken token = default,
            IAnalyticsService service = default!,
            IUserContext userContext = default!
        ) => service.GetScoreTrend(userContext.UserId, days, token);

        public static Task<IResult> GetStrengthsWeaknesses(
            CancellationToken token,
            IAnalyticsService service,
            IUserContext userContext
        ) => service.GetStrengthsWeaknesses(userContext.UserId, token);

        public static Task<IResult> GetRecentActivity(
            int limit = 10,
            CancellationToken token = default,
            IAnalyticsService service = default!,
            IUserContext userContext = default!
        ) => service.GetRecentActivity(userContext.UserId, limit, token);

        public static Task<IResult> GetWrongAnswers(
            string? skill = null,
            string? questionType = null,
            DateTime? fromDate = null,
            int page = 1,
            int pageSize = 20,
            CancellationToken token = default,
            IAnalyticsService service = default!,
            IUserContext userContext = default!
        ) => service.GetWrongAnswers(userContext.UserId, skill, questionType, fromDate, page, pageSize, token);
        
        public static Task<IResult> GetPredictedBand(
            CancellationToken token,
            IBandPredictorService service,
            IUserContext userContext
        ) => service.GetPredictedBand(userContext.UserId, token);
        
        public static async Task<IResult> GetAiInsights(
            CancellationToken token,
            IServiceProvider serviceProvider,
            IUserContext userContext
        )
        {
            var service = serviceProvider.GetService<IAiInsightsService>();
            if (service == null)
            {
                return Results.Ok(new
                {
                    isSuccess = false,
                    message = "AI insights not available - GEMINI API key not configured",
                    data = (object?)null
                });
            }
            return await service.GetAiInsights(userContext.UserId, token);
        }
        
        public static Task<IResult> GetRecommendations(
            int limit = 5,
            CancellationToken token = default,
            IRecommendationService service = default!,
            IUserContext userContext = default!
        ) => service.GetRecommendations(userContext.UserId, limit, token);
    }
}

