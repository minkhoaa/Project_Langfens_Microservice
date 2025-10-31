using Microsoft.AspNetCore.Mvc;

namespace vocabulary_service.Features.Public;

public static class PublicHandler
{
    public static Task<IResult> GetAllPublishedHandler(
        [FromQuery] string? status,[FromQuery] string? category,
        CancellationToken token, int page, int? pageSize,
        [FromServices] IPublicService service
    ) => service.GetAllPublished(status, category, token, page, pageSize);

    public static Task<IResult> GetBySlugHandler(
        [FromRoute] string slug, CancellationToken token,
        [FromServices] IPublicService service)
        => service.GetBySlug(slug, token);

    
    public static Task<IResult> GetCardsBySlugHandler(
        [FromRoute] string slug, CancellationToken token,
        IPublicService service
    ) => service.GetCardsBySlug(slug, token);
    public static Task<IResult> GetCardsByDeckIdHandler(
        [FromRoute] Guid deckId, CancellationToken token,
        IPublicService service
    ) => service.GetCardsByDeckId(deckId, token);
}