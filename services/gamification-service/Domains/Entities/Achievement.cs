namespace gamification_service.Domains.Entities;

public class Achievement
{
    public Guid Id { get; set; }
    public string Slug { get; set; } = null!;
    public string Title { get; set; } = null!;
    public string Description { get; set; } = null!;
    public string? IconUrl { get; set; } // Material Symbol name e.g., "local_fire_department"
    public string Category { get; set; } = null!; // STREAK, TEST, VOCABULARY, COURSE
    public string Tier { get; set; } = "COMMON"; // COMMON, RARE, EPIC, LEGENDARY
    public int RequiredValue { get; set; }
    public int XpReward { get; set; }

    public ICollection<UserAchievement> UserAchievements { get; set; } = [];
}

public static class AchievementCategory
{
    public const string Streak = "STREAK";
    public const string Test = "TEST";
    public const string Vocabulary = "VOCABULARY";
    public const string Course = "COURSE";
}
