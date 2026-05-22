namespace attempt_service.Features.Attempt.AttemptEndpoint;

public record NavigatorEntry(
    Guid QuestionId,
    int Idx,
    bool IsAnswered,
    bool IsFlagged
);

public record NavigatorResponse(
    int TotalQuestions,
    int AnsweredCount,
    List<NavigatorEntry> Questions
);