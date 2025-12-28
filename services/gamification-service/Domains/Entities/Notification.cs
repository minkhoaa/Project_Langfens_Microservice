using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace gamification_service.Domains.Entities;

public class Notification
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public Guid Id { get; set; }

    [Required]
    public Guid UserId { get; set; }

    /// <summary>
    /// ACHIEVEMENT, STREAK, GOAL_PROGRESS, STUDY_REMINDER, INACTIVITY
    /// </summary>
    [Required]
    [MaxLength(32)]
    public string Type { get; set; } = default!;

    [Required]
    [MaxLength(128)]
    public string Title { get; set; } = default!;

    [Required]
    [MaxLength(512)]
    public string Message { get; set; } = default!;

    /// <summary>
    /// Extra data like achievementId, goalId, etc.
    /// </summary>
    [Column(TypeName = "jsonb")]
    public string? Data { get; set; }

    public bool IsRead { get; set; } = false;

    [Required]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Notification type constants
    public static class Types
    {
        public const string Achievement = "ACHIEVEMENT";
        public const string Streak = "STREAK";
        public const string GoalProgress = "GOAL_PROGRESS";
        public const string StudyReminder = "STUDY_REMINDER";
        public const string Inactivity = "INACTIVITY";
        public const string Welcome = "WELCOME";
        public const string LevelUp = "LEVEL_UP";
        public const string TestCompleted = "TEST_COMPLETED";
    }
}
