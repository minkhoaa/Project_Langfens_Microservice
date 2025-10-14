namespace course_service.Contracts;
public record LessonItemDto(Guid Id, int Idx, string Title, int? DurationMin);
public record EnrollResponse(Guid EnrollmentId, string Status);
public record CompleteResponse(Guid CompletionId, DateTime CompletedAt);
public record CourseProgressItem(
    Guid CourseId,
    string Slug,
    string Title,
    int TotalLessons,
    int CompletedLessons,
    double Percent
);
public record MyProgressDto(IReadOnlyList<CourseProgressItem> Courses);

