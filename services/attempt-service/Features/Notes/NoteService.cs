using attempt_service.Domain.Entities;
using attempt_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts;

namespace attempt_service.Features.Notes;

public class NoteService(AttemptDbContext db)
{
    public async Task<IResult> CreateNote(
        Guid userId,
        CreateNoteRequest req,
        CancellationToken ct)
    {
        var note = new Note
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            AttemptId = req.AttemptId,
            SectionId = req.SectionId,
            SelectedText = req.SelectedText,
            Content = req.Content,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        
        db.Notes.Add(note);
        await db.SaveChangesAsync(ct);
        
        return Results.Ok(new ApiResultDto(true, "Note created", new NoteDto(
            note.Id,
            note.AttemptId,
            note.SectionId,
            note.SelectedText,
            note.Content,
            note.CreatedAt,
            note.UpdatedAt
        )));
    }

    public async Task<IResult> GetNotes(
        Guid userId,
        Guid? attemptId = null,
        int page = 1,
        int pageSize = 20,
        CancellationToken ct = default)
    {
        var query = db.Notes
            .Where(n => n.UserId == userId)
            .OrderByDescending(n => n.CreatedAt)
            .AsQueryable();

        if (attemptId.HasValue)
        {
            query = query.Where(n => n.AttemptId == attemptId.Value);
        }

        var total = await query.CountAsync(ct);
        
        var notes = await query
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(n => new NoteDto(
                n.Id,
                n.AttemptId,
                n.SectionId,
                n.SelectedText,
                n.Content,
                n.CreatedAt,
                n.UpdatedAt
            ))
            .ToListAsync(ct);

        var result = new NoteListResponse(notes, total, page, pageSize);
        return Results.Ok(new ApiResultDto(true, "Notes fetched", result));
    }

    public async Task<IResult> GetNoteById(
        Guid userId,
        Guid noteId,
        CancellationToken ct)
    {
        var note = await db.Notes
            .FirstOrDefaultAsync(n => n.UserId == userId && n.Id == noteId, ct);

        if (note == null)
        {
            return Results.NotFound(new ApiResultDto(false, "Note not found", null!));
        }

        return Results.Ok(new ApiResultDto(true, "Note fetched", new NoteDto(
            note.Id,
            note.AttemptId,
            note.SectionId,
            note.SelectedText,
            note.Content,
            note.CreatedAt,
            note.UpdatedAt
        )));
    }

    public async Task<IResult> UpdateNote(
        Guid userId,
        Guid noteId,
        UpdateNoteRequest req,
        CancellationToken ct)
    {
        var note = await db.Notes
            .FirstOrDefaultAsync(n => n.UserId == userId && n.Id == noteId, ct);

        if (note == null)
        {
            return Results.NotFound(new ApiResultDto(false, "Note not found", null!));
        }

        note.Content = req.Content;
        note.UpdatedAt = DateTime.UtcNow;
        
        await db.SaveChangesAsync(ct);
        
        return Results.Ok(new ApiResultDto(true, "Note updated", new NoteDto(
            note.Id,
            note.AttemptId,
            note.SectionId,
            note.SelectedText,
            note.Content,
            note.CreatedAt,
            note.UpdatedAt
        )));
    }

    public async Task<IResult> DeleteNote(
        Guid userId,
        Guid noteId,
        CancellationToken ct)
    {
        var note = await db.Notes
            .FirstOrDefaultAsync(n => n.UserId == userId && n.Id == noteId, ct);

        if (note == null)
        {
            return Results.NotFound(new ApiResultDto(false, "Note not found", null!));
        }

        db.Notes.Remove(note);
        await db.SaveChangesAsync(ct);
        
        return Results.Ok(new ApiResultDto(true, "Note deleted", null!));
    }
}

// DTOs
public record CreateNoteRequest(
    Guid? AttemptId,
    Guid? SectionId,
    string? SelectedText,
    string Content
);

public record UpdateNoteRequest(string Content);

public record NoteDto(
    Guid Id,
    Guid? AttemptId,
    Guid? SectionId,
    string? SelectedText,
    string Content,
    DateTime CreatedAt,
    DateTime UpdatedAt
);

public record NoteListResponse(
    List<NoteDto> Items,
    int Total,
    int Page,
    int PageSize
);
