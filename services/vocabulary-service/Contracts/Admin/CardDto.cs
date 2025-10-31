namespace vocabulary_service.Contracts.Admin;

public record CreateCardRequest(
    int? Idx, 
    string FrontMd,
    string BackMd,
    string? HintMd
);

public record UpdateCardRequest(
    int? Idx, 
    string? FrontMd,
    string? BackMd,
    string? HintMd
);

public record CardCreatedDto(Guid Id, int Idx);