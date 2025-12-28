using gamification_service.Domains.Entities;
using gamification_service.Infrastructure.Persistence;
using MassTransit;
using Microsoft.EntityFrameworkCore;
using Shared.PublicContracts.Events;

namespace gamification_service.Features.Consumers;

public class CardReviewedConsumer : IConsumer<CardReviewedEvent>
{
    private readonly GamificationDbContext _context;
    private readonly INotificationService _notificationService;

    public CardReviewedConsumer(GamificationDbContext context, INotificationService notificationService)
    {
        _context = context;
        _notificationService = notificationService;
    }

    public async Task Consume(ConsumeContext<CardReviewedEvent> context)
    {
        var msg = context.Message;
        var token = context.CancellationToken;

        var xp = msg.IsCorrect ? XpRewards.CardReviewedCorrect : XpRewards.CardReviewedWrong;

        var stats = await GetOrCreateUserStats(msg.UserId, token);
        var previousLevel = stats.Level;
        var previousStreak = stats.CurrentStreak;
        
        stats.TotalCardsReviewed++;
        stats.TotalXp += xp;
        stats.Level = UserStats.CalculateLevel(stats.TotalXp);
        stats.UpdatedAt = DateTime.UtcNow;

        // Record activity
        await RecordActivity(stats);

        _context.XpTransactions.Add(new XpTransaction
        {
            Id = Guid.NewGuid(),
            UserId = msg.UserId,
            Amount = xp,
            Source = XpSource.CardReviewed,
            SourceId = msg.CardId.ToString(),
            CreatedAt = DateTime.UtcNow
        });

        // Check vocabulary achievements
        var newAchievements = await CheckVocabAchievements(msg.UserId, stats, token);

        await _context.SaveChangesAsync(token);

        // === NOTIFICATION TRIGGERS ===

        // 1. Level up notification
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

        // 2. Achievement notifications
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

        // 3. Streak milestone notifications
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
        
        // 4. Vocabulary milestone notifications (every 50 cards)
        var vocabMilestones = new[] { 50, 100, 250, 500, 1000 };
        if (vocabMilestones.Contains(stats.TotalCardsReviewed))
        {
            await _notificationService.CreateNotification(
                msg.UserId,
                Notification.Types.Achievement,
                $"Cột mốc từ vựng: {stats.TotalCardsReviewed} từ! 📚",
                $"Bạn đã ôn tập {stats.TotalCardsReviewed} thẻ từ vựng. Vốn từ của bạn đang phát triển rất tốt!",
                $"{{\"totalCardsReviewed\":{stats.TotalCardsReviewed}}}"
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

    private async Task<List<Achievement>> CheckVocabAchievements(Guid userId, UserStats stats, CancellationToken token)
    {
        var newlyUnlocked = new List<Achievement>();
        
        var achievements = await _context.Achievements
            .Where(a => a.Category == AchievementCategory.Vocabulary)
            .ToListAsync(token);

        var unlocked = await _context.UserAchievements
            .Where(x => x.UserId == userId)
            .Select(x => x.AchievementId)
            .ToListAsync(token);

        foreach (var achievement in achievements.Where(a => !unlocked.Contains(a.Id)))
        {
            if (stats.TotalCardsReviewed >= achievement.RequiredValue)
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
