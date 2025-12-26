namespace attempt_service.Features.Bookmarks;

public record BookmarkDto(
    Guid Id,
    Guid QuestionId,
    string? QuestionContent,
    string? QuestionType,
    string? Skill,
    string? Note,
    DateTime CreatedAt,
    DateTime? UpdatedAt
);

public record CreateBookmarkRequest(
    Guid QuestionId,
    string? QuestionContent,
    string? Skill,
    string? QuestionType,
    string? Note
);

public record UpdateBookmarkRequest(
    string? Note
);

public record BookmarkListResponse(
    List<BookmarkDto> Items,
    int Total,
    int Page,
    int PageSize
);
