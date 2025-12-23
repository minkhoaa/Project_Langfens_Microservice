using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace exam_service.Domains.Entities;

public class ExamQuestion
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public Guid Id { get; set; }

    public Guid SectionId { get; set; }
    public ExamSection Section { get; set; } = default!;

    public int Idx { get; set; }

    // ví dụ: MULTIPLE_CHOICE_SINGLE, TRUE_FALSE_NOT_GIVEN...
    [Required] public string Type { get; set; } = default!;

    // READING/LISTENING/WRITING/SPEAKING
    [Required] public string Skill { get; set; } = default!;

    public int Difficulty { get; set; } = 1;

    [Required] public string? PromptMd { get; set; } = default!;

    public string? ExplanationMd { get; set; }

    [Column(TypeName = "jsonb")]
    public Dictionary<string, string[]?>? BlankAcceptTexts { get; set; }

    [Column(TypeName = "jsonb")]
    public Dictionary<string, string[]?>? BlankAcceptRegex { get; set; }

    [Column(TypeName = "jsonb")]
    public Dictionary<string, string[]?>? MatchPairs { get; set; }

    [Column(TypeName = "text[]")]
    public List<string>? OrderCorrects { get; set; }

    [Column(TypeName = "text[]")]
    public List<string>? ShortAnswerAcceptTexts { get; set; }

    [Column(TypeName = "text[]")]
    public List<string>? ShortAnswerAcceptRegex { get; set; }

    /// <summary>
    /// Model/sample answers for ESSAY/WRITING type questions.
    /// Stored as JSONB array of strings.
    /// </summary>
    [Column(TypeName = "jsonb")]
    public List<string>? ModelAnswers { get; set; }

    public List<ExamOption> Options { get; set; } = new();
}
