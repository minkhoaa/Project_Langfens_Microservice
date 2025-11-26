using Microsoft.AspNetCore.Mvc;

namespace speaking_service.Contracts;

public record SpeakingSubmissionRequest(Guid ExamId, int? TimeSpentSeconds);
public record CreateSpeakingExamRequest(string Title, string TaskText, SpeakingCategory ExamType, string? Level, string? Tag, DateTime CreatedAt, Guid CreatedBy);
public record UpdateSpeakingExamRequest(string Title, string TaskText, SpeakingCategory ExamType, string? Level, string? Tag);
public record SpeakingExamResponse(Guid Id, string Title, string TaskText, SpeakingCategory ExamType, string? Level, string? Tag, DateTime CreatedAt, Guid CreatedBy);
public record StartSpeakingExamResponse(Guid Id, string Title, string TaskText, string? Tag, DateTime CreatedAt, Guid CreatedBy, Guid StartedBy);
public record SpeakingHistoryItem(
    Guid SubmissionId,
    Guid? ExamId,
    string Title,
    string TaskText,
    SpeakingCategory ExamType,
    string? Level,
    string? Tag,
    int? TimeSpentSeconds,
    DateTime SubmittedAt,
    double OverallBand
);
public class SpeakingSubmitForm
{
    [FromForm] public Guid ExamId { get; set; }
    [FromForm] public int TimeSpentSeconds { get; set; }
    [FromForm] public IFormFile Speech { get; set; } = null!;
}
