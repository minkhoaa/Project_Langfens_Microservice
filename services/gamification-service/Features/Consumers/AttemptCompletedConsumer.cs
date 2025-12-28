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
    private readonly INotificationService _notificationService;

    public AttemptCompletedConsumer(
        GamificationDbContext context, 
        IGamificationService service,
        INotificationService notificationService)
    {
        _context = context;
        _service = service;
        _notificationService = notificationService;
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
        var previousLevel = stats.Level;
        var previousStreak = stats.CurrentStreak;
        
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
        var newAchievements = await CheckTestAchievements(msg.UserId, stats, token);

        await _context.SaveChangesAsync(token);

        // === NOTIFICATION TRIGGERS ===
        
        // 1. Test completed notification
        var skillName = msg.Skill ?? "Reading";
        await _notificationService.CreateNotification(
            msg.UserId,
            Notification.Types.TestCompleted,
            "Bài test đã hoàn thành! 📝",
            $"Bạn vừa hoàn thành bài test {skillName} với {msg.Score} câu đúng. Tiếp tục phát huy nhé!",
            $"{{\"attemptId\":\"{msg.AttemptId}\",\"skill\":\"{skillName}\",\"score\":{msg.Score}}}"
        );

        // 2. Level up notification
        if (stats.Level > previousLevel)
        {
            await _notificationService.CreateNotification(
                msg.UserId,
                Notification.Types.LevelUp,
                $"Chúc mừng! Bạn đã lên Level {stats.Level} ⬆️",
                $"Bạn đã tích lũy đủ XP để đạt Level {stats.Level}. Hãy tiếp tục học tập để chinh phục những đỉnh cao mới!",
                $"{{\"level\":{stats.Level},\"totalXp\":{stats.TotalXp}}}"
            );
        }

        // 3. Achievement notifications
        foreach (var achievement in newAchievements)
        {
            await _notificationService.CreateNotification(
                msg.UserId,
                Notification.Types.Achievement,
                $"Thành tựu mới: {achievement.Title} 🏆",
                $"Bạn đã đạt được thành tựu \"{achievement.Title}\"! {achievement.Description}",
                $"{{\"achievementId\":\"{achievement.Id}\",\"slug\":\"{achievement.Slug}\",\"xpReward\":{achievement.XpReward}}}"
            );
        }

        // 4. Streak milestone notifications
        var streakMilestones = new[] { 7, 14, 30, 60, 100 };
        if (stats.CurrentStreak != previousStreak && streakMilestones.Contains(stats.CurrentStreak))
        {
            await _notificationService.CreateNotification(
                msg.UserId,
                Notification.Types.Streak,
                $"Chuỗi {stats.CurrentStreak} ngày! 🔥",
                $"Tuyệt vời! Bạn đã học liên tục {stats.CurrentStreak} ngày. Hãy duy trì phong độ này nhé!",
                $"{{\"streak\":{stats.CurrentStreak}}}"
            );
        }
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

    private async Task<List<Achievement>> CheckTestAchievements(Guid userId, UserStats stats, CancellationToken token)
    {
        var newlyUnlocked = new List<Achievement>();
        
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
                
                newlyUnlocked.Add(achievement);
            }
        }
        
        return newlyUnlocked;
    }
}
