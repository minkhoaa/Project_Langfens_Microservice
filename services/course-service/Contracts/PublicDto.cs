namespace course_service.Contracts;

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
    
