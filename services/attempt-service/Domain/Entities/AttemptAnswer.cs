using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace attempt_service.Domain.Entities;

public class AttemptAnswer
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public Guid Id { get; set; }

    [Required] public Guid AttemptId { get; set; }
    public Attempt Attempt { get; set; } = null!;

    [Required] public Guid SectionId { get; set; }
    [Required] public Guid QuestionId { get; set; }

    public List<Guid>? SelectedOptionIds { get; set; }

    public string? TextAnswer { get; set; } = string.Empty;

    public bool? IsCorrect { get; set; }
    public decimal? AwardedPoints { get; set; }
}
