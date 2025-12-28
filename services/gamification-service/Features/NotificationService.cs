using gamification_service.Contracts;
using gamification_service.Domains.Entities;
using gamification_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace gamification_service.Features;

public interface INotificationService
{
    Task<IResult> GetNotifications(Guid userId, int page, int pageSize, CancellationToken token);
    Task<IResult> GetUnreadCount(Guid userId, CancellationToken token);
    Task<IResult> MarkAsRead(Guid userId, Guid notificationId, CancellationToken token);
    Task<IResult> MarkAllAsRead(Guid userId, CancellationToken token);
    Task<IResult> GetSettings(Guid userId, CancellationToken token);
    Task<IResult> UpdateSettings(Guid userId, UpdateSettingsRequest request, CancellationToken token);
    Task CreateNotification(Guid userId, string type, string title, string message, string? data = null);
}

public class NotificationService(GamificationDbContext context) : INotificationService
{
    public async Task<IResult> GetNotifications(Guid userId, int page, int pageSize, CancellationToken token)
    {
        page = Math.Max(1, page);
        pageSize = Math.Clamp(pageSize, 10, 100);
        var skip = (page - 1) * pageSize;

        var query = context.Notifications
            .AsNoTracking()
            .Where(n => n.UserId == userId)
            .OrderByDescending(n => n.CreatedAt);

        var totalCount = await query.CountAsync(token);
        var unreadCount = await query.CountAsync(n => !n.IsRead, token);

        var items = await query
            .Skip(skip)
            .Take(pageSize)
            .Select(n => new NotificationDto(
                n.Id, n.Type, n.Title, n.Message, n.Data, n.IsRead, n.CreatedAt
            ))
            .ToListAsync(token);

        return Results.Ok(new ApiResponse<NotificationListDto>(true, "Notifications fetched",
            new NotificationListDto(items, totalCount, unreadCount)));
    }

    public async Task<IResult> GetUnreadCount(Guid userId, CancellationToken token)
    {
        var count = await context.Notifications
            .AsNoTracking()
            .CountAsync(n => n.UserId == userId && !n.IsRead, token);

        return Results.Ok(new ApiResponse<UnreadCountDto>(true, "Count fetched", new UnreadCountDto(count)));
    }

    public async Task<IResult> MarkAsRead(Guid userId, Guid notificationId, CancellationToken token)
    {
        var notification = await context.Notifications
            .FirstOrDefaultAsync(n => n.Id == notificationId && n.UserId == userId, token);

        if (notification == null)
            return Results.NotFound(new ApiResponse<object>(false, "Notification not found", null));

        notification.IsRead = true;
        await context.SaveChangesAsync(token);

        return Results.Ok(new ApiResponse<object>(true, "Marked as read", null));
    }

    public async Task<IResult> MarkAllAsRead(Guid userId, CancellationToken token)
    {
        await context.Notifications
            .Where(n => n.UserId == userId && !n.IsRead)
            .ExecuteUpdateAsync(s => s.SetProperty(n => n.IsRead, true), token);

        return Results.Ok(new ApiResponse<object>(true, "All marked as read", null));
    }

    public async Task<IResult> GetSettings(Guid userId, CancellationToken token)
    {
        var settings = await context.UserNotificationSettings
            .AsNoTracking()
            .FirstOrDefaultAsync(s => s.UserId == userId, token);

        if (settings == null)
        {
            // Return default settings
            return Results.Ok(new ApiResponse<NotificationSettingsDto>(true, "Settings fetched",
                new NotificationSettingsDto(null, true, true, true, true)));
        }

        return Results.Ok(new ApiResponse<NotificationSettingsDto>(true, "Settings fetched",
            new NotificationSettingsDto(
                settings.DailyReminderTime,
                settings.EnableStreak,
                settings.EnableGoalProgress,
                settings.EnableAchievement,
                settings.EnableInactivity
            )));
    }

    public async Task<IResult> UpdateSettings(Guid userId, UpdateSettingsRequest request, CancellationToken token)
    {
        var settings = await context.UserNotificationSettings
            .FirstOrDefaultAsync(s => s.UserId == userId, token);

        if (settings == null)
        {
            settings = new UserNotificationSettings { UserId = userId };
            context.UserNotificationSettings.Add(settings);
        }

        settings.DailyReminderTime = request.DailyReminderTime;
        settings.EnableStreak = request.EnableStreak;
        settings.EnableGoalProgress = request.EnableGoalProgress;
        settings.EnableAchievement = request.EnableAchievement;
        settings.EnableInactivity = request.EnableInactivity;
        settings.UpdatedAt = DateTime.UtcNow;

        await context.SaveChangesAsync(token);

        return Results.Ok(new ApiResponse<object>(true, "Settings updated", null));
    }

    public async Task CreateNotification(Guid userId, string type, string title, string message, string? data = null)
    {
        // Check user settings
        var settings = await context.UserNotificationSettings
            .AsNoTracking()
            .FirstOrDefaultAsync(s => s.UserId == userId);

        // Check if this notification type is enabled
        if (settings != null)
        {
            var enabled = type switch
            {
                Notification.Types.Achievement => settings.EnableAchievement,
                Notification.Types.Streak => settings.EnableStreak,
                Notification.Types.GoalProgress => settings.EnableGoalProgress,
                Notification.Types.Inactivity => settings.EnableInactivity,
                Notification.Types.Welcome => settings.EnableWelcome,
                Notification.Types.LevelUp => settings.EnableLevelUp,
                Notification.Types.TestCompleted => settings.EnableTestCompleted,
                _ => true
            };

            if (!enabled) return;
        }

        var notification = new Notification
        {
            UserId = userId,
            Type = type,
            Title = title,
            Message = message,
            Data = data
        };

        context.Notifications.Add(notification);
        await context.SaveChangesAsync();
    }
}
