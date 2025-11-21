namespace writing_service.Contracts;


public record WritingSubmissionRequest(Guid ExamId, string Answer, int? TimeSpentSeconds);
public record CreateExamRequest(string Title, string TaskText, WritingCategory ExamType, string? Level , string? Tag, DateTime CreatedAt, Guid CreatedBy);
public record StartWritingExamResponse(Guid Id, string Title, string TaskText, string? Tag, DateTime CreatedAt, Guid CreatedBy, Guid StartedBy);