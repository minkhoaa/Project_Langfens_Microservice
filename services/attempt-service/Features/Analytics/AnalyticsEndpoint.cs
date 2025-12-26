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
    }
}

