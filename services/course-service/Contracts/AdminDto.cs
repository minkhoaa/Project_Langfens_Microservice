namespace course_service.Contracts;

public record CreateCourseRequest(
    string Slug,
    string Title,
    string? DescriptionMd,
    string? Category,
    string? Level,
    string? Status
);
public record CourseCreatedDto(Guid Id, string Slug);

public record UpdateCourseRequest(
    string Slug,
    string Title,
    string? DescriptionMd,
    string? Category,
    string? Level,
    string? Status
);
public record CourseUpdateDto(
    Guid Id, 
    string Slug,
    string Title,
    string? DescriptionMd,
    string? Category,
    string? Level,
    string? Status, 
    DateTime UpdateAt
);

public record CreateLessonRequest(
    int? Idx,
    string Title,
    string? ContentMd,
    int? DurationMin,
    Guid? QuizExamId
);

public record UpdateLessonRequest(
    string? Title,
    string? ContentMd,
    int? DurationMin,
    int? Idx,
    Guid? QuizExamId
);
public record LessonCreatedDto(Guid Id, int Idx);
