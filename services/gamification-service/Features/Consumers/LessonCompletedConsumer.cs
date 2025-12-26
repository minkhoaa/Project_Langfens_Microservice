using gamification_service.Domains.Entities;
using gamification_service.Infrastructure.Persistence;
using MassTransit;
using Microsoft.EntityFrameworkCore;
using Shared.PublicContracts.Events;

namespace gamification_service.Features.Consumers;

public class LessonCompletedConsumer : IConsumer<LessonCompletedEvent>
{
    private readonly GamificationDbContext _context;

    public LessonCompletedConsumer(GamificationDbContext context)
    {
        _context = context;
    }

    public async Task Consume(ConsumeContext<LessonCompletedEvent> context)
    {
        var msg = context.Message;
        var token = context.CancellationToken;

        var stats = await GetOrCreateUserStats(msg.UserId, token);
        stats.TotalLessonsCompleted++;
        stats.TotalXp += XpRewards.LessonCompleted;
        stats.Level = UserStats.CalculateLevel(stats.TotalXp);
        stats.UpdatedAt = DateTime.UtcNow;

        // Record activity
        await RecordActivity(stats);

        _context.XpTransactions.Add(new XpTransaction
        {
            Id = Guid.NewGuid(),
            UserId = msg.UserId,
            Amount = XpRewards.LessonCompleted,
            Source = XpSource.LessonCompleted,
            SourceId = msg.LessonId.ToString(),
            CreatedAt = DateTime.UtcNow
        });

        // Check course achievements
        await CheckCourseAchievements(msg.UserId, stats, token);

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

    private async Task RecordActivity(UserStats stats)
    {
        var today = DateTime.UtcNow.Date;
        var lastActivity = stats.LastActivityDate?.Date;

        if (lastActivity != today)
        {
            if (lastActivity == today.AddDays(-1))
            {
                stats.CurrentStreak++;
                if (stats.CurrentStreak > stats.LongestStreak)
                    stats.LongestStreak = stats.CurrentStreak;
            }
            else
            {
                stats.CurrentStreak = 1;
            }
            stats.LastActivityDate = today;
        }
    }

    private async Task CheckCourseAchievements(Guid userId, UserStats stats, CancellationToken token)
    {
        var achievements = await _context.Achievements
            .Where(a => a.Category == AchievementCategory.Course)
            .ToListAsync(token);

        var unlocked = await _context.UserAchievements
            .Where(x => x.UserId == userId)
            .Select(x => x.AchievementId)
            .ToListAsync(token);

        foreach (var achievement in achievements.Where(a => !unlocked.Contains(a.Id)))
        {
            if (stats.TotalLessonsCompleted >= achievement.RequiredValue)
            {
                _context.UserAchievements.Add(new UserAchievement
                {
                    Id = Guid.NewGuid(),
                    UserId = userId,
                    AchievementId = achievement.Id,
                    UnlockedAt = DateTime.UtcNow
                });

                stats.TotalXp += achievement.XpReward;
                _context.XpTransactions.Add(new XpTransaction
                {
                    Id = Guid.NewGuid(),
                    UserId = userId,
                    Amount = achievement.XpReward,
                    Source = XpSource.AchievementUnlocked,
                    SourceId = achievement.Slug,
                    CreatedAt = DateTime.UtcNow
                });
            }
        }
    }
}
