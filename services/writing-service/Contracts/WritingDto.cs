namespace writing_service.Contracts;


public record WritingSubmissionRequest(Guid ExamId, string Answer, int? TimeSpentSeconds);
public record CreateExamRequest(
    string Title, 
    string TaskText, 
    string Slug, 
    WritingCategory ExamType, 
    string? Level, 
    string? Tag, 
    List<string>? ModelAnswers, 
    string ImageUrl, 
    DateTime CreatedAt,
    Guid? SourceExamId = null,      // Reference to exam-service exam (for full test mode)
    Guid? SourceSectionId = null    // Reference to exam-service section (for full test mode)
);
public record UpdateExamRequest(
    string Title, 
    string TaskText, 
    string Slug, 
    WritingCategory ExamType, 
    string? Level, 
    string? Tag, 
    List<string>? ModelAnswers, 
    string ImageUrl,
    Guid? SourceExamId = null,
    Guid? SourceSectionId = null
);
public record WritingExamResponse(
    Guid Id, 
    string Title, 
    string TaskText, 
    string Slug, 
    WritingCategory ExamType, 
    string? Level, 
    string? Tag, 
    List<string>? ModelAnswers, 
    string ImageUrl, 
    DateTime CreatedAt, 
    Guid CreatedBy,
    Guid? SourceExamId = null,
    Guid? SourceSectionId = null
);
public record ListWritingExamResponse(
    Guid Id, 
    string Title, 
    string TaskText, 
    string Slug, 
    WritingCategory ExamType, 
    string? Level, 
    string? Tag, 
    string ImageUrl, 
    DateTime CreatedAt, 
    Guid CreatedBy,
    Guid? SourceExamId = null
);

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
public record StartWritingExamResponse(Guid Id, string Title, string Slug ,string TaskText, string? Tag, List<string>? ModelAnswers, string ImageUrl,DateTime CreatedAt, Guid CreatedBy, Guid StartedBy);

