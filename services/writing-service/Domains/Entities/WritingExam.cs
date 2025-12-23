using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;
using Shared.ExamDto.Contracts.Exam.Enums;
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
    public string? Level { get; set; } = ExamLevel.B1;

    // "technology,education"
    public string? Tags { get; set; }
    
    /// <summary>
    /// Model/sample answers for this writing task. Stored as JSONB array.
    /// </summary>
    [Column(TypeName = "jsonb")]
    public List<string>? ModelAnswers { get; set; }
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public Guid CreatedBy { get; set; }

    [JsonIgnore]
    public ICollection<WritingSubmission> WritingSubmissions { get; set; } = new List<WritingSubmission>();
}
