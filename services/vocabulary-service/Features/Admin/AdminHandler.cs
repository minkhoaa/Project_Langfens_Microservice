using vocabulary_service.Contracts.Admin;

namespace vocabulary_service.Features.Admin;

public static class AdminHandler
{
    public static Task<IResult> CreateDeckHandler(
        CreateDeckRequest dto, 
        CancellationToken token, 
        IAdminService service)
        => service.CreateDeck(dto, token);

    public static Task<IResult> UpdateDeckHandler(UpdateDeckRequest dto,
        Guid deckId, CancellationToken token,
        IAdminService service
    ) => service.UpdateDeck(dto, deckId, token);
    
    public static Task<IResult> DeleteDeckHandler(
        Guid deckId, CancellationToken token,
        IAdminService service
    ) => service.DeleteDeck(deckId, token);

    public static Task<IResult> CreateCardHandler(Guid deckId,
        CreateCardRequest request,
        CancellationToken token, IAdminService service)
        => service.CreateCards(deckId, request, token);

    public static Task<IResult> CreateBulkCardsHandler(Guid deckId,
        CreateBulkCardsRequest request,
        CancellationToken token, IAdminService service)
        => service.CreateBulkCards(deckId, request, token);

    public static Task<IResult> UpdateCardHandler(Guid cardId,
        UpdateCardRequest request,
        CancellationToken token, IAdminService service)
        => service.UpdateCards(cardId, request, token);

    public static Task<IResult> DeleteCardHandler(Guid cardId,
        CancellationToken token, IAdminService service)
        => service.DeleteCards(cardId, token);
    public static Task<IResult> PublishDeckHandler(
        Guid deckId, CancellationToken token,
        IAdminService service
    ) => service.MakeDeckPublic(deckId, token);
}