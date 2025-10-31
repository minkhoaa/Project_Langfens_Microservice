using vocabulary_service.Features.Admin;
using vocabulary_service.Features.Public;
using vocabulary_service.Features.User;

namespace vocabulary_service.Features;

public static class VocabularyEndpoint
{
    public static void MapPublicVocabularyEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapGroup("/api/decks");
        // public
        app.MapGet("/", PublicHandler.GetAllPublishedHandler);
        app.MapGet("/{slug}", PublicHandler.GetBySlugHandler);
        app.MapGet("/slug:{slug}/cards", PublicHandler.GetCardsBySlugHandler);
        app.MapGet("/deck:{deckId}/cards", PublicHandler.GetCardsByDeckIdHandler);
        
        
        
    }
    public static void MapUserVocabularyEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapGroup("/api/users/");
        // public
        app.MapPost("/{userId}/subscribe/{deckId}", UserHandler.SubscribeDecksHandler);
        app.MapGet("/{userId}/flashcard/due", UserHandler.GetDueFlashcardHandler);
        app.MapPost("/{userId}/flashcard/{cardId}/review", UserHandler.ReviewFlashcardHandler);
        app.MapGet("/{userId}/flashcard/progress", UserHandler.GetFlashcardProgressHandler);
    }
    public static void MapAdminVocabularyEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapGroup("/api/admin/");
        app.MapPost("/deck/", AdminHandler.CreateDeckHandler);
        app.MapPut("/deck/{deckId}", AdminHandler.UpdateDeckHandler);
        app.MapDelete("/deck/{deckId}", AdminHandler.DeleteDeckHandler);
        app.MapPost("/deck/{deckId}/card", AdminHandler.CreateCardHandler);
        app.MapPut("/deck/card/{cardId}", AdminHandler.UpdateCardHandler);
        app.MapDelete("/deck/card/{cardId}", AdminHandler.DeleteCardHandler);
        
    }
}