using gamification_service.Domains.Entities;
using gamification_service.Infrastructure.Persistence;
using MassTransit;
using Microsoft.EntityFrameworkCore;
using Shared.PublicContracts.Events;

namespace gamification_service.Features.Consumers;

public class AttemptCompletedConsumer : IConsumer<AttemptCompletedEvent>
{
    private readonly GamificationDbContext _context;
    private readonly IGamificationService _service;

    public AttemptCompletedConsumer(GamificationDbContext context, IGamificationService service)
    {
        _context = context;
        _service = service;
    }

    public async Task Consume(ConsumeContext<AttemptCompletedEvent> context)
    {
        var msg = context.Message;
        var token = context.CancellationToken;

        // Determine XP based on skill
        var xp = msg.Skill?.ToUpperInvariant() switch
        {
            "WRITING" => XpRewards.WritingTest,
            "SPEAKING" => XpRewards.SpeakingTest,
            "LISTENING" => XpRewards.ListeningTest,
            "READING" => XpRewards.ReadingTest,
            _ => XpRewards.ReadingTest
        };

        // Update user stats
        var stats = await GetOrCreateUserStats(msg.UserId, token);
        stats.TotalTestsCompleted++;
        stats.TotalXp += xp;
        stats.Level = UserStats.CalculateLevel(stats.TotalXp);
        stats.UpdatedAt = DateTime.UtcNow;

        // Record activity for streak
        await RecordActivity(stats);

        // Add XP transaction
        _context.XpTransactions.Add(new XpTransaction
        {
            Id = Guid.NewGuid(),
            UserId = msg.UserId,
            Amount = xp,
            Source = XpSource.TestCompleted,
            SourceId = msg.AttemptId.ToString(),
            CreatedAt = DateTime.UtcNow
        });

        // Check achievements
        await CheckTestAchievements(msg.UserId, stats, token);

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

    private async Task CheckTestAchievements(Guid userId, UserStats stats, CancellationToken token)
    {
        var testAchievements = await _context.Achievements
            .Where(a => a.Category == AchievementCategory.Test)
            .ToListAsync(token);

        var unlocked = await _context.UserAchievements
            .Where(x => x.UserId == userId)
            .Select(x => x.AchievementId)
            .ToListAsync(token);

        foreach (var achievement in testAchievements.Where(a => !unlocked.Contains(a.Id)))
        {
            if (stats.TotalTestsCompleted >= achievement.RequiredValue)
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
