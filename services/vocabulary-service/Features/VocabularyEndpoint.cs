using Shared.Security.Roles;
using Shared.Security.Scopes;
using vocabulary_service.Application;
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
        
        // AI enrichment endpoint (public for now)
        var ai = app.MapGroup("/api/vocabulary").AllowAnonymous();
        ai.MapGet("/enrich", async (string word, IAiEnrichmentService service, CancellationToken token) =>
        {
            if (string.IsNullOrWhiteSpace(word))
                return Results.BadRequest("word is required");
            
            var result = await service.EnrichWord(word, token);
            return Results.Ok(result);
        });
        
        ai.MapPost("/extract", async (ExtractRequest request, IVocabularyExtractionService service, CancellationToken token) =>
        {
            if (string.IsNullOrWhiteSpace(request.PassageText))
                return Results.BadRequest("passageText is required");
            
            var maxWords = request.MaxWords > 0 ? request.MaxWords : 10;
            var result = await service.ExtractFromPassage(request.PassageText, maxWords, token);
            return Results.Ok(result);
        });
    }

    public record ExtractRequest(string PassageText, int MaxWords = 10);

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
