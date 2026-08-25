using attempt_service.Features.Helpers;
using Microsoft.AspNetCore.Mvc;

namespace attempt_service.Features.Notes;

public static class NoteEndpoint
{
    public static void MapNoteEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/notes")
            .WithTags("Notes")
            .RequireAuthorization();

        group.MapPost("/", Handler.CreateNote);
        group.MapGet("/", Handler.GetNotes);
        group.MapGet("/{noteId:guid}", Handler.GetNoteById);
        group.MapPut("/{noteId:guid}", Handler.UpdateNote);
        group.MapDelete("/{noteId:guid}", Handler.DeleteNote);
    }

    private static class Handler
    {
        public static Task<IResult> CreateNote(
            [FromBody] CreateNoteRequest req,
            NoteService service,
            IUserContext userContext,
            CancellationToken ct) =>
            service.CreateNote(userContext.UserId, req, ct);

        public static Task<IResult> GetNotes(
            [FromQuery] Guid? attemptId,
            [FromQuery] int page,
            [FromQuery] int pageSize,
            NoteService service,
            IUserContext userContext,
            CancellationToken ct) =>
            service.GetNotes(userContext.UserId, attemptId, page > 0 ? page : 1, pageSize > 0 ? pageSize : 20, ct);

        public static Task<IResult> GetNoteById(
            Guid noteId,
            NoteService service,
            IUserContext userContext,
            CancellationToken ct) =>
            service.GetNoteById(userContext.UserId, noteId, ct);

        public static Task<IResult> UpdateNote(
            Guid noteId,
            [FromBody] UpdateNoteRequest req,
            NoteService service,
            IUserContext userContext,
            CancellationToken ct) =>
            service.UpdateNote(userContext.UserId, noteId, req, ct);

        public static Task<IResult> DeleteNote(
            Guid noteId,
            NoteService service,
            IUserContext userContext,
            CancellationToken ct) =>
            service.DeleteNote(userContext.UserId, noteId, ct);
    }
}
