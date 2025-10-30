using vocabulary_service.Features.User;

namespace vocabulary_service.Features.Public;

public static class PublicHandler
{
    public static Task<IResult> GetAllPublishedHandler(
        string? status, string? category,
        CancellationToken token, int page, int? pageSize,
        IPublicService service
    ) => service.GetAllPublished(status, category, token, page, pageSize);

    public static Task<IResult> GetBySlugHandler(
        string slug, CancellationToken token, IPublicService service)
        => service.GetBySlug(slug, token);

    public static Task<IResult> GetCardsBySlugHandler(
        string slug, CancellationToken token,
        IPublicService service
    ) => service.GetCardsBySlug(slug, token);

}