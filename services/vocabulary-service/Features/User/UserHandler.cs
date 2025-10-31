using Microsoft.AspNetCore.Mvc;
using vocabulary_service.Contracts.User;

namespace vocabulary_service.Features.User;

public static class UserHandler
{
  

    public static Task<IResult> SubscribeDecksHandler(Guid deckId, Guid userId, CancellationToken token,
        IUserService service)
        => service.SubscribeDecks(deckId, userId, token);

    public static Task<IResult> GetDueFlashcardHandler([FromRoute] Guid userId, CancellationToken token,
        IUserService service,
        int limit = 20) => service.GetDueFlashcard(userId, token, limit);

    public static Task<IResult> ReviewFlashcardHandler(Guid userId, Guid cardId,
        ReviewRequest request, CancellationToken token, IUserService service)
        => service.ReviewFlashcard(userId, cardId, request, token);

    public static Task<IResult> GetFlashcardProgressHandler(Guid userId, CancellationToken token,
        IUserService service
    ) => service.GetFlashcardProgress(userId, token);

}