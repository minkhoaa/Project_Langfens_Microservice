using Shared.Security.Roles;
using Shared.Security.Scopes;
using vocabulary_service.Features.Admin;
using vocabulary_service.Features.Public;
using vocabulary_service.Features.User;

namespace vocabulary_service.Features;

public static class VocabularyEndpoint
{
    public static void MapPublicVocabularyEndpoints(this IEndpointRouteBuilder app)
    {
        var decks = app.MapGroup("/api/decks").AllowAnonymous();

        decks.MapGet("/", PublicHandler.GetAllPublishedHandler);
        decks.MapGet("/{slug}", PublicHandler.GetBySlugHandler);
        decks.MapGet("/slug:{slug}/cards", PublicHandler.GetCardsBySlugHandler);
        decks.MapGet("/deck:{deckId}/cards", PublicHandler.GetCardsByDeckIdHandler);
    }

    public static void MapUserVocabularyEndpoints(this IEndpointRouteBuilder app)
    {
        var users = app.MapGroup("/api/users")
            .RequireAuthorization(Roles.User);

        users.MapPost("/{userId}/subscribe/{deckId}", UserHandler.SubscribeDecksHandler);
        users.MapGet("/{userId}/subscribe", UserHandler.GetSubscribedDecksHandler);
        users.MapGet("/{userId}/own", UserHandler.GetUserDecksHandler);
        users.MapGet("/{userId}/flashcard/due", UserHandler.GetDueFlashcardHandler);
        users.MapPost("/{userId}/flashcard/{cardId}/review", UserHandler.ReviewFlashcardHandler);
        users.MapGet("/{userId}/flashcard/progress", UserHandler.GetFlashcardProgressHandler);
        users.MapPost("/deck", AdminHandler.CreateDeckHandler);
        users.MapPut("/deck/{deckId}", AdminHandler.UpdateDeckHandler);
        users.MapDelete("/deck/{deckId}", AdminHandler.DeleteDeckHandler);
        users.MapPost("/deck/{deckId}/card", AdminHandler.CreateCardHandler);
        users.MapPut("/deck/card/{cardId}", AdminHandler.UpdateCardHandler);
        users.MapDelete("/deck/card/{cardId}", AdminHandler.DeleteCardHandler);
        users.MapDelete("/deck/{deckId}/publish", AdminHandler.PublishDeckHandler);
    }

}
