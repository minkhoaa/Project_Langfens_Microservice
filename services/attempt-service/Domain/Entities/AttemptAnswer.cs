using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace attempt_service.Domain.Entities;

public class AttemptAnswer
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int Id { get; set; }

    [Required] public int AttemptId { get; set; }
    public Attempt Attempt { get; set; } = null!;

    [Required] public int SectionId { get; set; }
    [Required] public int QuestionId { get; set; }

    public List<int>? SelectedOptionIds { get; set; }

    public string? TextAnswer { get; set; } = string.Empty;

    public bool? IsCorrect { get; set; }
    public double? AwardedPoints { get; set; }
}