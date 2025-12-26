namespace gamification_service.Domains.Entities;

public class UserAchievement
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public Guid AchievementId { get; set; }
    public DateTime UnlockedAt { get; set; } = DateTime.UtcNow;

    public Achievement Achievement { get; set; } = null!;
}
