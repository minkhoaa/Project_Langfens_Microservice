using Microsoft.AspNetCore.Mvc;

namespace speaking_service.Contracts;

public record SpeakingSubmissionRequest(Guid ExamId, int? TimeSpentSeconds);
public record CreateSpeakingExamRequest(string Title, string TaskText, SpeakingCategory ExamType, string? Level, string? Tag, DateTime CreatedAt, Guid CreatedBy);
public record StartSpeakingExamResponse(Guid Id, string Title, string TaskText, string? Tag, DateTime CreatedAt, Guid CreatedBy, Guid StartedBy);
public class SpeakingSubmitForm
{
    [FromForm] public Guid ExamId { get; set; }
    [FromForm] public int TimeSpentSeconds { get; set; }
    [FromForm] public IFormFile Speech { get; set; } = null!;
}
