using gamification_service.Features;
using Shared.ExamDto.Contracts;
using Shared.Security.Helper;

namespace gamification_service.Features;

public static class GamificationEndpoint
{
    public static void MapGamificationEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/gamification");

        group.MapGet("/me", async (IGamificationService service, IUserContext user, CancellationToken token) =>
        {
            var stats = await service.GetUserStats(user.UserId, token);
            return Results.Ok(new ApiResultDto(true, "User stats fetched", stats));
        });

        group.MapGet("/achievements", async (IGamificationService service, IUserContext user, CancellationToken token) =>
        {
            var achievements = await service.GetAllAchievements(user.UserId, token);
            return Results.Ok(new ApiResultDto(true, "Achievements fetched", achievements));
        });

        group.MapGet("/leaderboard", async (IGamificationService service, int? limit, CancellationToken token) =>
        {
            var leaderboard = await service.GetLeaderboard(limit ?? 50, token);
            return Results.Ok(new ApiResultDto(true, "Leaderboard fetched", leaderboard));
        }).AllowAnonymous();

        group.MapGet("/history", async (IGamificationService service, IUserContext user, int? limit, CancellationToken token) =>
        {
            var history = await service.GetXpHistory(user.UserId, limit ?? 20, token);
            return Results.Ok(new ApiResultDto(true, "XP history fetched", history));
        });

        group.MapPost("/daily-checkin", async (IGamificationService service, IUserContext user, CancellationToken token) =>
        {
            var result = await service.DailyCheckin(user.UserId, token);
            return Results.Ok(new ApiResultDto(result.Success, result.Success ? "Checked in!" : "Already checked in today", result));
        });
    }
}
