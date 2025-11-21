using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;
using Shared.ExamDto.Contracts.Exam.Enums;
using writing_service.Contracts;

namespace writing_service.Domains.Entities;

public class WritingSubmission
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public Guid Id { get; set; } 
    public Guid? UserId { get; set; }

    public Guid? ExamId { get; set; }
    public string TaskTextSnapshot { get; set; } = string.Empty; 

    public string EssayRaw { get; set; } = string.Empty;
    public string EssayNormalized { get; set; } = string.Empty;
    public int WordCount { get; set; }

    public WritingCategory ExamType { get; set; } = WritingCategory.TOEIC;
    public string? Level { get; set; } = ExamLevel.B1;
    public int? TimeSpentSeconds { get; set; }

    public DateTime SubmittedAt { get; set; } = DateTime.UtcNow;

    [JsonIgnore]
    public WritingExam WritingExam { get; set; } = null!;

    [JsonIgnore]
    public ICollection<WritingEvaluation> WritingEvaluations { get; set; } = new List<WritingEvaluation>();

}
