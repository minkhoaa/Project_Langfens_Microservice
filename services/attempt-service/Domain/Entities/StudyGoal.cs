using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace attempt_service.Domain.Entities;

public class StudyGoal
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public Guid Id { get; set; }

    [Required]
    public Guid UserId { get; set; }

    /// <summary>
    /// Target IELTS band score (5.0 - 9.0)
    /// </summary>
    [Required]
    public decimal TargetBandScore { get; set; }

    /// <summary>
    /// Deadline to achieve the goal
    /// </summary>
    [Required]
    public DateTime TargetDate { get; set; }

    /// <summary>
    /// Skills to focus on: READING, LISTENING, WRITING, SPEAKING
    /// </summary>
    [Column(TypeName = "text[]")]
    public List<string> FocusSkills { get; set; } = new();

    /// <summary>
    /// Hours per day dedicated to study (0.5 - 8.0)
    /// </summary>
    public decimal StudyHoursPerDay { get; set; } = 2.0m;

    /// <summary>
    /// Only one goal can be active per user
    /// </summary>
    public bool IsActive { get; set; } = true;

    [Required]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}
