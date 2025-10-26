namespace vocabulary_service.Features;

public static class VocabularyEndpoint
{
    public static void MapVocabularyEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapGroup("/api/decks");
    }
}