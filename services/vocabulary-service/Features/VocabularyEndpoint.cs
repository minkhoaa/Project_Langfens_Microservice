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
        app.MapGet("/{slug}/cards", PublicHandler.GetCardsBySlugHandler);
        
        
        
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
}