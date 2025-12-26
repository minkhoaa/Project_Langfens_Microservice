namespace Shared.PublicContracts.Events;

/// <summary>
/// Published by attempt-service when a test is submitted
/// </summary>
public record AttemptCompletedEvent(Guid UserId, Guid AttemptId, string? Skill, int Score);

/// <summary>
/// Published by vocabulary-service when a flashcard is reviewed
/// </summary>
public record CardReviewedEvent(Guid UserId, Guid CardId, int Grade, bool IsCorrect);

/// <summary>
/// Published by course-service when a lesson is completed
/// </summary>
public record LessonCompletedEvent(Guid UserId, Guid LessonId, Guid CourseId);
