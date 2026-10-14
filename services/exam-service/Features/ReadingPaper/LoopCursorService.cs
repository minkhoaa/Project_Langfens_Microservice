using System.Text.Json;
using exam_service.Domains.Entities;
using exam_service.Features.ReadingPaper.Contracts;
using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Npgsql;

namespace exam_service.Features.ReadingPaper;

public static class LoopCursorService
{
    public static async Task<LoopCursorCheckpoint> SaveAsync(
        ExamDbContext db, LoopCursorCheckpointRequest request, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(request.ArtifactId) || request.ExpectedRevision < 0 ||
            string.IsNullOrWhiteSpace(request.StateJson) || request.StateJson.Length > 1048576)
            throw new CheckpointValidationException(422, "Invalid loop cursor target, revision or payload");
        try
        {
            using var document = JsonDocument.Parse(request.StateJson);
            if (document.RootElement.ValueKind != JsonValueKind.Object)
                throw new JsonException("Cursor must be an object");
        }
        catch (JsonException)
        {
            throw new CheckpointValidationException(422, "Malformed loop cursor JSON");
        }

        var (_, job) = await CheckpointService.ValidateRunAuthorityAndFencingAsync(
            db, request.RunId, request.Epoch, request.LeaseOwner, ct);
        var strategy = db.Database.CreateExecutionStrategy();
        return await strategy.ExecuteAsync(async () =>
        {
            db.ChangeTracker.Clear();
            await using var tx = await db.Database.BeginTransactionAsync(ct);
            // Serialize cursor writers with the same job lock used by operation grants and commits.
            var fenced = await db.ReadingPaperJobs
                .Where(j => j.Id == job.Id && j.Status == "Running" && j.Epoch == request.Epoch &&
                            j.LeaseOwner == request.LeaseOwner && j.LeaseUntil > DateTime.UtcNow &&
                            j.CancelVersion == job.CancelVersion)
                .ExecuteUpdateAsync(s => s.SetProperty(j => j.UpdatedAt, DateTime.UtcNow), ct);
            var run = await db.ReadingPaperRuns.AsNoTracking().SingleAsync(r => r.RunId == request.RunId, ct);
            if (fenced != 1 || run.Status != "RUNNING" || run.Epoch != request.Epoch ||
                run.LeaseOwner != request.LeaseOwner || run.CancelVersion != job.CancelVersion)
                throw new CheckpointValidationException(409, "Loop cursor writer has lost authority");

            if (request.LastOperationId is not null)
            {
                var operation = await db.ReadingPaperOperations.AsNoTracking().SingleOrDefaultAsync(
                    o => o.RunId == request.RunId && o.OperationId == request.LastOperationId, ct);
                if (operation is null || operation.Status != "COMPLETED" ||
                    operation.ArtifactId != request.ArtifactId)
                    throw new CheckpointValidationException(409, "Loop cursor refers to an unacknowledged operation");
            }

            var row = await db.ReadingPaperLoopCursors.SingleOrDefaultAsync(
                c => c.RunId == request.RunId && c.ArtifactId == request.ArtifactId, ct);
            if (row is not null && row.Revision == request.ExpectedRevision + 1 &&
                row.StateJson == request.StateJson && row.LastOperationId == request.LastOperationId)
                return new LoopCursorCheckpoint(row.ArtifactId, row.Revision, row.StateJson, row.LastOperationId);
            if ((row?.Revision ?? 0) != request.ExpectedRevision)
                throw new CheckpointValidationException(409, "Loop cursor revision conflict");
            if (row is null)
            {
                row = new ReadingPaperLoopCursor { RunId = request.RunId, ArtifactId = request.ArtifactId };
                db.ReadingPaperLoopCursors.Add(row);
            }
            row.Revision = request.ExpectedRevision + 1;
            row.StateJson = request.StateJson;
            row.LastOperationId = request.LastOperationId;
            row.UpdatedAt = DateTime.UtcNow;
            try
            {
                await db.SaveChangesAsync(ct);
                await tx.CommitAsync(ct);
            }
            catch (DbUpdateException ex) when (ex.InnerException is PostgresException { SqlState: "23505" })
            {
                throw new CheckpointValidationException(409, "Concurrent loop cursor writer");
            }
            return new LoopCursorCheckpoint(row.ArtifactId, row.Revision, row.StateJson, row.LastOperationId);
        });
    }
}
