using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Shared.ExamDto.Contracts.Exam.Enums;

namespace exam_service.Domains.Entities;

public class Exam
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int Id { get; set; }

    [Required] public string Slug { get; set; } = default!;

    [Required] public string Title { get; set; } = default!;

    public string? DescriptionMd { get; set; }

    // IELTS/TOEIC/...
    [Required] public string Category { get; set; } = ExamCategory.IELTS!;

    // A1..C2 hoặc Beginner/Intermediate...
    [Required] public string Level { get; set; } = ExamLevel.B1!;

    // Draft = 0, Published = 1, Archived = 2  
    public string Status { get; set; } = ExamStatus.Draft;

    public int DurationMin { get; set; } = 60;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; }

    public List<ExamSection> Sections { get; set; } = new();
}