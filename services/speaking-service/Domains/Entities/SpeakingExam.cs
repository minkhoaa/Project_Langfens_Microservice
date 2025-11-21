using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;
using Shared.ExamDto.Contracts.Exam.Enums;
using speaking_service.Contracts;

namespace speaking_service.Domains.Entities;

public class SpeakingExam
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public Guid Id { get; set; }

    public string Title { get; set; } = string.Empty;
    public string TaskText { get; set; } = string.Empty;

    public SpeakingCategory ExamType { get; set; } = SpeakingCategory.TOEIC;
    public string? Level { get; set; } = ExamLevel.B1;

    public string? Tags { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public Guid CreatedBy { get; set; }

    [JsonIgnore]
    public ICollection<SpeakingSubmission> SpeakingSubmissions { get; set; } = new List<SpeakingSubmission>();
}
