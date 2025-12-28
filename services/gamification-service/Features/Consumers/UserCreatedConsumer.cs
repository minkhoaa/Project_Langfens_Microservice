using gamification_service.Domains.Entities;
using gamification_service.Infrastructure.Persistence;
using MassTransit;
using Microsoft.EntityFrameworkCore;
using Shared.PublicContracts.Events;

namespace gamification_service.Features.Consumers;

public class UserCreatedConsumer : IConsumer<UserCreatedEvent>
{
    private readonly GamificationDbContext _context;
    private readonly INotificationService _notificationService;

    public UserCreatedConsumer(GamificationDbContext context, INotificationService notificationService)
    {
        _context = context;
        _notificationService = notificationService;
    }

    public async Task Consume(ConsumeContext<UserCreatedEvent> context)
    {
        var msg = context.Message;
        var token = context.CancellationToken;

        // Create initial user stats if not exists
        var existingStats = await _context.UserStats.FirstOrDefaultAsync(x => x.UserId == msg.UserId, token);
        if (existingStats == null)
        {
            var stats = new UserStats
            {
                Id = Guid.NewGuid(),
                UserId = msg.UserId,
                TotalXp = 0,
                Level = 1,
                CurrentStreak = 0,
                LongestStreak = 0,
                TotalTestsCompleted = 0,
                TotalCardsReviewed = 0,
                TotalLessonsCompleted = 0,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };
            _context.UserStats.Add(stats);
            await _context.SaveChangesAsync(token);
        }

        // Send welcome notification
        await _notificationService.CreateNotification(
            msg.UserId,
            Notification.Types.Welcome,
            "Chào mừng bạn đến với Langfens! 🎉",
            "Chúc mừng bạn đã gia nhập cộng đồng học tiếng Anh Langfens! Hãy bắt đầu hành trình chinh phục IELTS của bạn ngay hôm nay.",
            $"{{\"email\":\"{msg.Email}\",\"joinedAt\":\"{msg.CreatedAt:O}\"}}"
        );

        // Send first tip notification
        await _notificationService.CreateNotification(
            msg.UserId,
            Notification.Types.StudyReminder,
            "Mẹo học tập 💡",
            "Hãy thử làm bài Placement Test để đánh giá trình độ hiện tại của bạn. Sau đó, hệ thống sẽ đề xuất lộ trình học phù hợp nhất!",
            null
        );
    }
}
