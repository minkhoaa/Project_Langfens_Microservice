using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using writing_service.Contracts;

namespace writing_service.Domains.Entities;

public class WritingExam
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public Guid Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string TaskText { get; set; } = string.Empty;

    // IELTS_W1, IELTS_W2, TOEIC
    public WritingCategory ExamType { get; set; } = WritingCategory.TOEIC;
    // "technology,education"
    public string? Tags { get; set; }           
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public Guid CreatedBy { get; set; }
    public ICollection<WritingSubmission> WritingSubmissions { get; set; }
}