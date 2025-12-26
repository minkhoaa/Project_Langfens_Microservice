namespace gamification_service.Features;

// Response DTOs
public record NotificationDto(
    Guid Id,
    string Type,
    string Title,
    string Message,
    string? Data,
    bool IsRead,
    DateTime CreatedAt
);

public record NotificationListDto(
    List<NotificationDto> Items,
    int TotalCount,
    int UnreadCount
);

public record UnreadCountDto(int Count);

// Settings DTOs
public record NotificationSettingsDto(
    TimeOnly? DailyReminderTime,
    bool EnableStreak,
    bool EnableGoalProgress,
    bool EnableAchievement,
    bool EnableInactivity
);

public record UpdateSettingsRequest(
    TimeOnly? DailyReminderTime,
    bool EnableStreak,
    bool EnableGoalProgress,
    bool EnableAchievement,
    bool EnableInactivity
);
