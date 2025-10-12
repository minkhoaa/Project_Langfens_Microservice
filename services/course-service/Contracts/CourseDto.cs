namespace course_service.Contracts
{
    public record CourseListItemDto(Guid Id, string Slug, string Title, string? Category, string? Level, string Status);
    public record CourseDetailDto(
        Guid Id,
        string Slug,
        string Title,
        string? DescriptionMd,
        string? Category,
        string? Level,
        string Status,
        IReadOnlyList<LessonItemDto> Lessons
    );
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
}