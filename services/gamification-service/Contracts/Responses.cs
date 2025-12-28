namespace gamification_service.Contracts;

public record ApiResponse<T>(bool IsSuccess, string Message, T? Data);

public record UserStatsResponse(
    Guid UserId,
    int TotalXp,
    int Level,
    int XpForNextLevel,
    int CurrentStreak,
    int LongestStreak,
    int TotalTestsCompleted,
    int TotalCardsReviewed,
    int TotalLessonsCompleted,
    List<AchievementResponse> RecentAchievements
);

public record AchievementResponse(
    Guid Id,
    string Slug,
    string Title,
    string Description,
    string? IconUrl, // Material Symbol name e.g., "local_fire_department"
    string Category,
    string Tier, // COMMON, RARE, EPIC, LEGENDARY
    int RequiredValue,
    int XpReward,
    bool IsUnlocked,
    DateTime? UnlockedAt
);

public record LeaderboardEntry(
    int Rank,
    Guid UserId,
    string? DisplayName,
    int TotalXp,
    int Level,
    int CurrentStreak
);

public record XpHistoryItem(
    Guid Id,
    int Amount,
    string Source,
    DateTime CreatedAt
);

public record DailyCheckinResponse(
    bool Success,
    int XpEarned,
    int NewStreak,
    int TotalXp,
    int Level,
    List<AchievementResponse>? NewAchievements
);
