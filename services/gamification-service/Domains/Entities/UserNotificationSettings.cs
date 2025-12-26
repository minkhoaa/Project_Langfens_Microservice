using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace gamification_service.Domains.Entities;

public class UserNotificationSettings
{
    [Key]
    public Guid UserId { get; set; }

    /// <summary>
    /// Daily reminder time (null = disabled)
    /// </summary>
    public TimeOnly? DailyReminderTime { get; set; }

    /// <summary>
    /// Enable streak reminder notifications
    /// </summary>
    public bool EnableStreak { get; set; } = true;

    /// <summary>
    /// Enable goal progress notifications
    /// </summary>
    public bool EnableGoalProgress { get; set; } = true;

    /// <summary>
    /// Enable achievement notifications
    /// </summary>
    public bool EnableAchievement { get; set; } = true;

    /// <summary>
    /// Enable inactivity reminders
    /// </summary>
    public bool EnableInactivity { get; set; } = true;

    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}
