namespace gamification_service.Domains.Entities;

public class UserStats
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string? DisplayName { get; set; } // Email or name for leaderboard display
    public int TotalXp { get; set; }
    public int Level { get; set; } = 1;
    public int CurrentStreak { get; set; }
    public int LongestStreak { get; set; }
    public DateTime? LastActivityDate { get; set; }
    public int TotalTestsCompleted { get; set; }
    public int TotalCardsReviewed { get; set; }
    public int TotalLessonsCompleted { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    public static int CalculateLevel(int totalXp)
    {
        // Formula: Level up at 100, 300, 600, 1000, 1500...
        // RequiredXP = Level * 100 + (Level - 1) * 50
        int level = 1;
        int requiredXp = 100;
        while (totalXp >= requiredXp)
        {
            level++;
            requiredXp += level * 100 + (level - 1) * 50;
        }
        return level;
    }

    public static int GetXpForNextLevel(int currentLevel)
    {
        int totalRequired = 0;
        for (int l = 1; l <= currentLevel; l++)
        {
            totalRequired += l * 100 + (l - 1) * 50;
        }
        return totalRequired;
    }
}
