using attempt_service.Features.Helpers;
using Microsoft.AspNetCore.Mvc;

namespace attempt_service.Features.Bookmarks;

public static class BookmarkEndpoint
{
    public static void MapBookmarkEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/bookmarks")
            .WithTags("Bookmarks")
            .RequireAuthorization();

        group.MapPost("/", Handler.CreateOrUpdateBookmark);
        group.MapGet("/", Handler.GetBookmarks);
        group.MapDelete("/{questionId:guid}", Handler.DeleteBookmark);
        group.MapGet("/check/{questionId:guid}", Handler.CheckBookmark);
    }

    private static class Handler
    {
        public static Task<IResult> CreateOrUpdateBookmark(
            [FromBody] CreateBookmarkRequest req,
            BookmarkService service,
            IUserContext userContext,
            CancellationToken ct) =>
            service.CreateOrUpdateBookmark(userContext.UserId, req, ct);

        public static Task<IResult> GetBookmarks(
            [FromQuery] string? skill,
            [FromQuery] string? questionType,
            [FromQuery] bool? hasNote,
            [FromQuery] int page,
            [FromQuery] int pageSize,
            BookmarkService service,
            IUserContext userContext,
            CancellationToken ct) =>
            service.GetBookmarks(userContext.UserId, skill, questionType, hasNote, page, pageSize, ct);

        public static Task<IResult> DeleteBookmark(
            Guid questionId,
            BookmarkService service,
            IUserContext userContext,
            CancellationToken ct) =>
            service.DeleteBookmark(userContext.UserId, questionId, ct);

        public static async Task<IResult> CheckBookmark(
            Guid questionId,
            BookmarkService service,
            IUserContext userContext,
            CancellationToken ct)
        {
            var isBookmarked = await service.IsBookmarked(userContext.UserId, questionId, ct);
            return Results.Ok(new { isBookmarked });
        }
    }
}
