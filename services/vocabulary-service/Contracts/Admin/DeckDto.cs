namespace vocabulary_service.Contracts.Admin;
public record CreateDeckRequest(
    string Slug,
    string Title,
    string? DescriptionMd,
    string? Category,
    string? Status,
    Guid UserId
);


public record UpdateDeckRequest(
    string? Slug,
    string? Title,
    string? DescriptionMd,
    string? Category,
    string? Status
);


public record DeckCreatedDto(Guid Id, string Slug);
