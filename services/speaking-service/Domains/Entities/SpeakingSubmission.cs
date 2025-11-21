using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;
using Shared.ExamDto.Contracts.Exam.Enums;
using speaking_service.Contracts;

namespace speaking_service.Domains.Entities;

public class SpeakingSubmission
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public Guid Id { get; set; }

    public Guid? UserId { get; set; }
    public Guid? ExamId { get; set; }
    public string TaskTextSnapshot { get; set; } = string.Empty;

    public string TranscriptRaw { get; set; } = string.Empty;
    public string TranscriptNormalized { get; set; } = string.Empty;
    public int WordCount { get; set; }

    public SpeakingCategory ExamType { get; set; } = SpeakingCategory.TOEIC;
    public string? Level { get; set; } = ExamLevel.B1;
    public int? TimeSpentSeconds { get; set; }

    public DateTime SubmittedAt { get; set; } = DateTime.UtcNow;

    [JsonIgnore]
    public SpeakingExam SpeakingExam { get; set; } = null!;

    [JsonIgnore]
    public ICollection<SpeakingEvaluation> SpeakingEvaluations { get; set; } = new List<SpeakingEvaluation>();
}
