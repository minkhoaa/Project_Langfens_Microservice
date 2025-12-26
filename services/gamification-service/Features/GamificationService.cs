using gamification_service.Contracts;
using gamification_service.Domains.Entities;
using gamification_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts;

namespace gamification_service.Features;

public interface IGamificationService
{
    Task<UserStatsResponse> GetUserStats(Guid userId, CancellationToken token);
    Task<List<AchievementResponse>> GetAllAchievements(Guid userId, CancellationToken token);
    Task<List<LeaderboardEntry>> GetLeaderboard(int limit, CancellationToken token);
    Task<List<XpHistoryItem>> GetXpHistory(Guid userId, int limit, CancellationToken token);
    Task<DailyCheckinResponse> DailyCheckin(Guid userId, CancellationToken token);
    Task AddXp(Guid userId, int amount, string source, string? sourceId, CancellationToken token);
    Task RecordActivity(Guid userId, CancellationToken token);
}

public class GamificationService : IGamificationService
{
    private readonly GamificationDbContext _context;

    public GamificationService(GamificationDbContext context)
    {
        _context = context;
    }

    public async Task<UserStatsResponse> GetUserStats(Guid userId, CancellationToken token)
    {
        var stats = await GetOrCreateUserStats(userId, token);
        var recentAchievements = await _context.UserAchievements
            .AsNoTracking()
            .Where(x => x.UserId == userId)
            .OrderByDescending(x => x.UnlockedAt)
            .Take(5)
            .Include(x => x.Achievement)
            .Select(x => new AchievementResponse(
                x.Achievement.Id, x.Achievement.Slug, x.Achievement.Title,
                x.Achievement.Description, x.Achievement.IconUrl, x.Achievement.Category,
                x.Achievement.RequiredValue, x.Achievement.XpReward, true, x.UnlockedAt))
            .ToListAsync(token);

        return new UserStatsResponse(
            userId,
            stats.TotalXp,
            stats.Level,
            UserStats.GetXpForNextLevel(stats.Level),
            stats.CurrentStreak,
            stats.LongestStreak,
            stats.TotalTestsCompleted,
            stats.TotalCardsReviewed,
            stats.TotalLessonsCompleted,
            recentAchievements
        );
    }

    public async Task<List<AchievementResponse>> GetAllAchievements(Guid userId, CancellationToken token)
    {
        var allAchievements = await _context.Achievements.AsNoTracking().ToListAsync(token);
        var unlocked = await _context.UserAchievements
            .AsNoTracking()
            .Where(x => x.UserId == userId)
            .ToDictionaryAsync(x => x.AchievementId, x => x.UnlockedAt, token);

        return allAchievements.Select(a => new AchievementResponse(
            a.Id, a.Slug, a.Title, a.Description, a.IconUrl, a.Category,
            a.RequiredValue, a.XpReward,
            unlocked.ContainsKey(a.Id),
            unlocked.GetValueOrDefault(a.Id)
        )).OrderBy(a => a.Category).ThenBy(a => a.RequiredValue).ToList();
    }

    public async Task<List<LeaderboardEntry>> GetLeaderboard(int limit, CancellationToken token)
    {
        limit = Math.Clamp(limit, 10, 100);
        var topUsers = await _context.UserStats
            .AsNoTracking()
            .OrderByDescending(x => x.TotalXp)
            .Take(limit)
            .ToListAsync(token);

        return topUsers.Select((u, index) => new LeaderboardEntry(
            index + 1, u.UserId, null, u.TotalXp, u.Level, u.CurrentStreak
        )).ToList();
    }

    public async Task<List<XpHistoryItem>> GetXpHistory(Guid userId, int limit, CancellationToken token)
    {
        limit = Math.Clamp(limit, 10, 100);
        return await _context.XpTransactions
            .AsNoTracking()
            .Where(x => x.UserId == userId)
            .OrderByDescending(x => x.CreatedAt)
            .Take(limit)
            .Select(x => new XpHistoryItem(x.Id, x.Amount, x.Source, x.CreatedAt))
            .ToListAsync(token);
    }

    public async Task<DailyCheckinResponse> DailyCheckin(Guid userId, CancellationToken token)
    {
        var stats = await GetOrCreateUserStats(userId, token);
        var today = DateTime.UtcNow.Date;

        // Check if already checked in today
        var alreadyCheckedIn = await _context.XpTransactions
            .AnyAsync(x => x.UserId == userId && x.Source == XpSource.DailyLogin && x.CreatedAt.Date == today, token);

        if (alreadyCheckedIn)
        {
            return new DailyCheckinResponse(false, 0, stats.CurrentStreak, stats.TotalXp, stats.Level, null);
        }

        // Add daily XP
        await AddXpInternal(stats, XpRewards.DailyLogin, XpSource.DailyLogin, null, token);

        // Update streak
        await RecordActivityInternal(stats, token);

        // Check for streak-based achievements
        var newAchievements = await CheckAndUnlockAchievements(userId, stats, token);

        await _context.SaveChangesAsync(token);

        return new DailyCheckinResponse(
            true,
            XpRewards.DailyLogin,
            stats.CurrentStreak,
            stats.TotalXp,
            stats.Level,
            newAchievements
        );
    }

    public async Task AddXp(Guid userId, int amount, string source, string? sourceId, CancellationToken token)
    {
        var stats = await GetOrCreateUserStats(userId, token);
        await AddXpInternal(stats, amount, source, sourceId, token);
        await _context.SaveChangesAsync(token);
    }

    public async Task RecordActivity(Guid userId, CancellationToken token)
    {
        var stats = await GetOrCreateUserStats(userId, token);
        await RecordActivityInternal(stats, token);
        await _context.SaveChangesAsync(token);
    }

    private async Task<UserStats> GetOrCreateUserStats(Guid userId, CancellationToken token)
    {
        var stats = await _context.UserStats.FirstOrDefaultAsync(x => x.UserId == userId, token);
        if (stats == null)
        {
            stats = new UserStats { Id = Guid.NewGuid(), UserId = userId };
            _context.UserStats.Add(stats);
        }
        return stats;
    }

    private async Task AddXpInternal(UserStats stats, int amount, string source, string? sourceId, CancellationToken token)
    {
        stats.TotalXp += amount;
        stats.Level = UserStats.CalculateLevel(stats.TotalXp);
        stats.UpdatedAt = DateTime.UtcNow;

        _context.XpTransactions.Add(new XpTransaction
        {
            Id = Guid.NewGuid(),
            UserId = stats.UserId,
            Amount = amount,
            Source = source,
            SourceId = sourceId,
            CreatedAt = DateTime.UtcNow
        });
    }

    private async Task RecordActivityInternal(UserStats stats, CancellationToken token)
    {
        var today = DateTime.UtcNow.Date;
        var lastActivity = stats.LastActivityDate?.Date;

        if (lastActivity == today)
        {
            // Already recorded today
            return;
        }

        if (lastActivity == today.AddDays(-1))
        {
            // Consecutive day
            stats.CurrentStreak++;
            if (stats.CurrentStreak > stats.LongestStreak)
            {
                stats.LongestStreak = stats.CurrentStreak;
            }

            // Streak bonuses
            if (stats.CurrentStreak == 7)
            {
                await AddXpInternal(stats, XpRewards.Streak7Days, XpSource.StreakBonus, "streak-7", token);
            }
            else if (stats.CurrentStreak == 30)
            {
                await AddXpInternal(stats, XpRewards.Streak30Days, XpSource.StreakBonus, "streak-30", token);
            }
        }
        else
        {
            // Streak broken or first activity
            stats.CurrentStreak = 1;
        }

        stats.LastActivityDate = today;
        stats.UpdatedAt = DateTime.UtcNow;
    }

    private async Task<List<AchievementResponse>?> CheckAndUnlockAchievements(Guid userId, UserStats stats, CancellationToken token)
    {
        var achievements = await _context.Achievements.AsNoTracking().ToListAsync(token);
        var unlocked = await _context.UserAchievements
            .Where(x => x.UserId == userId)
            .Select(x => x.AchievementId)
            .ToListAsync(token);

        var newlyUnlocked = new List<AchievementResponse>();

        foreach (var achievement in achievements.Where(a => !unlocked.Contains(a.Id)))
        {
            bool shouldUnlock = achievement.Category switch
            {
                AchievementCategory.Streak => stats.CurrentStreak >= achievement.RequiredValue,
                AchievementCategory.Test => stats.TotalTestsCompleted >= achievement.RequiredValue,
                AchievementCategory.Vocabulary => stats.TotalCardsReviewed >= achievement.RequiredValue,
                AchievementCategory.Course => stats.TotalLessonsCompleted >= achievement.RequiredValue,
                _ => false
            };

            if (shouldUnlock)
            {
                var userAchievement = new UserAchievement
                {
                    Id = Guid.NewGuid(),
                    UserId = userId,
                    AchievementId = achievement.Id,
                    UnlockedAt = DateTime.UtcNow
                };
                _context.UserAchievements.Add(userAchievement);
                await AddXpInternal(stats, achievement.XpReward, XpSource.AchievementUnlocked, achievement.Slug, token);

                newlyUnlocked.Add(new AchievementResponse(
                    achievement.Id, achievement.Slug, achievement.Title, achievement.Description,
                    achievement.IconUrl, achievement.Category, achievement.RequiredValue,
                    achievement.XpReward, true, userAchievement.UnlockedAt
                ));
            }
        }

        return newlyUnlocked.Count > 0 ? newlyUnlocked : null;
    }
}
