using attempt_service.Domains.Entities;
using attempt_service.Features.Helpers;
using attempt_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts;

namespace attempt_service.Features.Bookmarks;

public class BookmarkService(AttemptDbContext db)
{
    public async Task<IResult> CreateOrUpdateBookmark(
        Guid userId,
        CreateBookmarkRequest req,
        CancellationToken ct)
    {
        var existing = await db.QuestionBookmarks
            .FirstOrDefaultAsync(b => b.UserId == userId && b.QuestionId == req.QuestionId, ct);

        if (existing != null)
        {
            existing.Note = req.Note;
            existing.AttemptId = req.AttemptId ?? existing.AttemptId;
            existing.QuestionContent = req.QuestionContent ?? existing.QuestionContent;
            existing.Skill = req.Skill ?? existing.Skill;
            existing.QuestionType = req.QuestionType ?? existing.QuestionType;
            existing.UpdatedAt = DateTime.UtcNow;
        }
        else
        {
            var bookmark = new QuestionBookmark
            {
                Id = Guid.NewGuid(),
                UserId = userId,
                QuestionId = req.QuestionId,
                AttemptId = req.AttemptId,
                QuestionContent = req.QuestionContent,
                Skill = req.Skill,
                QuestionType = req.QuestionType,
                Note = req.Note,
                CreatedAt = DateTime.UtcNow
            };
            db.QuestionBookmarks.Add(bookmark);
        }

        await db.SaveChangesAsync(ct);
        return Results.Ok(new ApiResultDto(true, "Bookmark saved", null!));
    }

    public async Task<IResult> GetBookmarks(
        Guid userId,
        string? skill = null,
        string? questionType = null,
        bool? hasNote = null,
        int page = 1,
        int pageSize = 20,
        CancellationToken ct = default)
    {
        var query = db.QuestionBookmarks
            .Where(b => b.UserId == userId)
            .OrderByDescending(b => b.CreatedAt)
            .AsQueryable();

        if (hasNote == true)
        {
            query = query.Where(b => b.Note != null && b.Note != "");
        }
        else if (hasNote == false)
        {
            query = query.Where(b => b.Note == null || b.Note == "");
        }

        var total = await query.CountAsync(ct);
        
        var bookmarks = await query
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(b => new BookmarkDto(
                b.Id,
                b.QuestionId,
                b.AttemptId,
                b.QuestionContent,
                b.QuestionType,
                b.Skill,
                b.Note,
                b.CreatedAt,
                b.UpdatedAt
            ))
            .ToListAsync(ct);

        var result = new BookmarkListResponse(bookmarks, total, page, pageSize);
        return Results.Ok(new ApiResultDto(true, "Bookmarks fetched", result));
    }

    public async Task<IResult> DeleteBookmark(
        Guid userId,
        Guid questionId,
        CancellationToken ct)
    {
        var bookmark = await db.QuestionBookmarks
            .FirstOrDefaultAsync(b => b.UserId == userId && b.QuestionId == questionId, ct);

        if (bookmark == null)
        {
            return Results.NotFound(new ApiResultDto(false, "Bookmark not found", null!));
        }

        db.QuestionBookmarks.Remove(bookmark);
        await db.SaveChangesAsync(ct);
        
        return Results.Ok(new ApiResultDto(true, "Bookmark deleted", null!));
    }

    public async Task<bool> IsBookmarked(
        Guid userId,
        Guid questionId,
        CancellationToken ct)
    {
        return await db.QuestionBookmarks
            .AnyAsync(b => b.UserId == userId && b.QuestionId == questionId, ct);
    }
}
