namespace writing_service.Contracts;


public record WritingSubmissionRequest(Guid ExamId, string Answer, int? TimeSpentSeconds);
public record CreateExamRequest(string Title, string TaskText, WritingCategory ExamType, string? Level , string? Tag, DateTime CreatedAt, Guid CreatedBy);
public record UpdateExamRequest(string Title, string TaskText, WritingCategory ExamType, string? Level , string? Tag);
public record WritingExamResponse(Guid Id, string Title, string TaskText, WritingCategory ExamType, string? Level , string? Tag, DateTime CreatedAt, Guid CreatedBy);
public record WritingHistoryItem(
    Guid SubmissionId,
    Guid? ExamId,
    string Title,
    string TaskText,
    WritingCategory ExamType,
    string? Level,
    string? Tag,
    int? TimeSpentSeconds,
    DateTime SubmittedAt,
    double OverallBand
);
public record StartWritingExamResponse(Guid Id, string Title, string TaskText, string? Tag, DateTime CreatedAt, Guid CreatedBy, Guid StartedBy);
