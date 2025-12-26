using attempt_service.Domain.Enums;
using attempt_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts;

namespace attempt_service.Features.Analytics;

public interface IAnalyticsService
{
    Task<IResult> GetSummary(Guid userId, CancellationToken token);
    Task<IResult> GetScoreTrend(Guid userId, int days, CancellationToken token);
    Task<IResult> GetStrengthsWeaknesses(Guid userId, CancellationToken token);
    Task<IResult> GetRecentActivity(Guid userId, int limit, CancellationToken token);
}

public class AnalyticsService(AttemptDbContext context) : IAnalyticsService
{
    public async Task<IResult> GetSummary(Guid userId, CancellationToken token)
    {
        var attempts = await context.Attempts
            .AsNoTracking()
            .Where(a => a.UserId == userId && a.Status == AttemptStatus.Graded)
            .ToListAsync(token);

        if (attempts.Count == 0)
        {
            return Results.Ok(new ApiResultDto(true, "No data", new AnalyticsSummaryDto(0, 0, 0, 0, new())));
        }

        var totalStudyTimeMin = attempts.Sum(a => a.DurationSec) / 60;
        var avgScore = attempts.Where(a => a.ScaledScore.HasValue).Average(a => a.ScaledScore!.Value);

        // Calculate streak based on consecutive days with graded attempts
        var streak = CalculateStreak(attempts);

        // Group by exam to determine skill (using PaperJson or ExamId)
        // For simplicity, assume all are mixed - can enhance later
        var testsBySkill = new Dictionary<string, int>
        {
            ["READING"] = attempts.Count / 2,
            ["LISTENING"] = attempts.Count - attempts.Count / 2
        };

        var summary = new AnalyticsSummaryDto(
            attempts.Count,
            totalStudyTimeMin,
            Math.Round(avgScore, 1),
            streak,
            testsBySkill
        );

        return Results.Ok(new ApiResultDto(true, "Summary fetched", summary));
    }

    public async Task<IResult> GetScoreTrend(Guid userId, int days, CancellationToken token)
    {
        days = Math.Clamp(days, 7, 365);
        var startDate = DateTime.UtcNow.AddDays(-days);

        var attempts = await context.Attempts
            .AsNoTracking()
            .Where(a => a.UserId == userId 
                && a.Status == AttemptStatus.Graded 
                && a.SubmittedAt >= startDate
                && a.ScaledScore.HasValue)
            .OrderBy(a => a.SubmittedAt)
            .ToListAsync(token);

        var groupedByDate = attempts
            .GroupBy(a => DateOnly.FromDateTime(a.SubmittedAt!.Value))
            .Select(g => new ScoreTrendPointDto(
                g.Key,
                Math.Round(g.Average(a => a.ScaledScore!.Value), 1),
                g.Count()
            ))
            .ToList();

        return Results.Ok(new ApiResultDto(true, "Score trend fetched", new ScoreTrendDto(groupedByDate)));
    }

    public async Task<IResult> GetStrengthsWeaknesses(Guid userId, CancellationToken token)
    {
        // Get all answers for user's graded attempts with PaperJson for section names
        var attempts = await context.Attempts
            .AsNoTracking()
            .Include(a => a.Answers)
            .Where(a => a.UserId == userId 
                && a.Status == AttemptStatus.Graded)
            .ToListAsync(token);

        // Build section name lookup from all PaperJson
        var sectionNames = new Dictionary<Guid, string>();
        foreach (var attempt in attempts)
        {
            ExtractSectionNames(attempt.PaperJson, sectionNames);
        }

        var allAnswers = attempts.SelectMany(a => a.Answers).Where(a => a.IsCorrect.HasValue).ToList();

        if (allAnswers.Count == 0)
        {
            return Results.Ok(new ApiResultDto(true, "No data", new StrengthsWeaknessesDto(new(), new())));
        }

        // Group by section with readable names
        var bySection = allAnswers
            .GroupBy(a => a.SectionId)
            .Select(g => new QuestionTypeAccuracyDto(
                sectionNames.TryGetValue(g.Key, out var name) ? name : $"Section {g.Key.ToString()[..8]}",
                Math.Round((double)g.Count(a => a.IsCorrect == true) / g.Count() * 100, 1),
                g.Count(),
                g.Count(a => a.IsCorrect == true)
            ))
            .OrderByDescending(x => x.Accuracy)
            .ToList();

        var strengths = bySection.Where(x => x.Accuracy >= 70).Take(3).ToList();
        var weaknesses = bySection.Where(x => x.Accuracy < 60).OrderBy(x => x.Accuracy).Take(3).ToList();

        return Results.Ok(new ApiResultDto(true, "Strengths/weaknesses fetched", 
            new StrengthsWeaknessesDto(strengths, weaknesses)));
    }

    private static void ExtractSectionNames(System.Text.Json.JsonDocument? paperJson, Dictionary<Guid, string> sectionNames)
    {
        if (paperJson == null) return;
        try
        {
            if (paperJson.RootElement.TryGetProperty("sections", out var sections) && sections.ValueKind == System.Text.Json.JsonValueKind.Array)
            {
                foreach (var section in sections.EnumerateArray())
                {
                    if (section.TryGetProperty("id", out var idEl) && section.TryGetProperty("title", out var titleEl))
                    {
                        if (Guid.TryParse(idEl.GetString(), out var sectionId))
                        {
                            var title = titleEl.GetString();
                            if (!string.IsNullOrEmpty(title) && !sectionNames.ContainsKey(sectionId))
                            {
                                sectionNames[sectionId] = title;
                            }
                        }
                    }
                }
            }
        }
        catch { }
    }

    public async Task<IResult> GetRecentActivity(Guid userId, int limit, CancellationToken token)
    {
        limit = Math.Clamp(limit, 1, 50);

        var attempts = await context.Attempts
            .AsNoTracking()
            .Where(a => a.UserId == userId && a.Status == AttemptStatus.Graded)
            .OrderByDescending(a => a.SubmittedAt)
            .Take(limit)
            .ToListAsync(token);

        var activities = attempts.Select(a => new RecentActivityDto(
            "TEST",
            a.ExamId,
            ExtractExamTitle(a.PaperJson),
            a.ScaledScore,
            a.SubmittedAt ?? a.CreatedAt,
            a.DurationSec / 60
        )).ToList();

        return Results.Ok(new ApiResultDto(true, "Recent activities fetched", new RecentActivitiesDto(activities)));
    }

    private static string? ExtractExamTitle(System.Text.Json.JsonDocument? paperJson)
    {
        if (paperJson == null) return null;
        try
        {
            if (paperJson.RootElement.TryGetProperty("title", out var titleElement))
            {
                return titleElement.GetString();
            }
        }
        catch { }
        return null;
    }

    private static int CalculateStreak(List<Domain.Entities.Attempt> attempts)
    {
        if (attempts.Count == 0) return 0;

        var dates = attempts
            .Where(a => a.SubmittedAt.HasValue)
            .Select(a => DateOnly.FromDateTime(a.SubmittedAt!.Value))
            .Distinct()
            .OrderByDescending(d => d)
            .ToList();

        if (dates.Count == 0) return 0;

        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        if (dates[0] < today.AddDays(-1)) return 0; // Streak broken

        int streak = 0;
        var expectedDate = dates[0];
        foreach (var date in dates)
        {
            if (date == expectedDate || date == expectedDate.AddDays(-1))
            {
                streak++;
                expectedDate = date.AddDays(-1);
            }
            else break;
        }

        return streak;
    }
}
