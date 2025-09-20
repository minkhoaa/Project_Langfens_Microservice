using System.Text.Json;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace exam_service.Data;

public class Exam
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int Id { get; set; }
    [Required]
    public string Slug { get; set; } = default!;

    [Required]
    public string Title { get; set; } = default!;

    public string? DescriptionMd { get; set; }

    // IELTS/TOEIC/...
    [Required]
    public string Category { get; set; } = default!;

    // A1..C2 hoặc Beginner/Intermediate...
    [Required]
    public string Level { get; set; } = default!;

    // "DRAFT" | "PUBLISHED" (để dạng string cho MVP, dễ mở rộng)
    [Required]
    public string Status { get; set; } = "DRAFT";

    public int DurationMin { get; set; } = 60;

    public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.UtcNow;
    public DateTimeOffset? UpdatedAt { get; set; }

    public List<ExamSection> Sections { get; set; } = new();
}

public class ExamSection
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int Id { get; set; }

    public int ExamId { get; set; }
    public Exam Exam { get; set; } = default!;

    public int Idx { get; set; } // thứ tự trong đề

    [Required]
    public string Title { get; set; } = default!;

    public string? InstructionsMd { get; set; }

    public List<ExamQuestion> Questions { get; set; } = new();
}

public class ExamQuestion
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int Id { get; set; }

    public int SectionId { get; set; }
    public ExamSection Section { get; set; } = default!;

    public int Idx { get; set; }

    // ví dụ: MULTIPLE_CHOICE_SINGLE, TRUE_FALSE_NOT_GIVEN...
    [Required]
    public string Type { get; set; } = default!;

    // READING/LISTENING/WRITING/SPEAKING
    [Required]
    public string Skill { get; set; } = default!;

    public int Difficulty { get; set; } = 1;

    [Required]
    public string PromptMd { get; set; } = default!;

    public string? ExplanationMd { get; set; }

    public List<ExamOption> Options { get; set; } = new();
}

public class ExamOption
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int Id { get; set; }

    public int QuestionId { get; set; }
    public ExamQuestion Question { get; set; } = default!;

    public int Idx { get; set; }

    [Required]
    public string ContentMd { get; set; } = default!;

    public bool IsCorrect { get; set; }
}
