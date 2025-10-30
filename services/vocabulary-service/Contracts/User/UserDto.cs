namespace vocabulary_service.Contracts.User;

public record SubscribeResponse(Guid SubscriptionId, string Status);
public record DueCardDto(
    Guid CardId,
    Guid DeckId,
    string DeckSlug,
    int Idx,
    string FrontMd,
    string BackMd,
    string? HintMd,
    DateTime DueAt
);
public record ReviewRequest(int Grade); // 0..5
public record ReviewResponse(Guid CardId, int Repetition, double EaseFactor, int IntervalDays, DateTime NextDue);

public record DeckProgressItem(Guid DeckId, string Slug, string Title, int TotalCards, int ReviewedCards, int DueCount, double AvgEaseFactor);
public record MyFlashProgressDto(IReadOnlyList<DeckProgressItem> Decks);