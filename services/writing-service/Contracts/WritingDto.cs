namespace writing_service.Contracts;


public record WritingSubmissionRequest(Guid ExamId, string Answer, int? TimeSpentSeconds);
public record CreateExamRequest(string Title, string TaskText, WritingCategory ExamType, string? Level, string? Tag, List<string>? ModelAnswers, DateTime CreatedAt);
public record UpdateExamRequest(string Title, string TaskText, WritingCategory ExamType, string? Level, string? Tag, List<string>? ModelAnswers);
public record WritingExamResponse(Guid Id, string Title, string TaskText, WritingCategory ExamType, string? Level, string? Tag, List<string>? ModelAnswers, DateTime CreatedAt, Guid CreatedBy);
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
public record StartWritingExamResponse(Guid Id, string Title, string TaskText, string? Tag, List<string>? ModelAnswers, DateTime CreatedAt, Guid CreatedBy, Guid StartedBy);

