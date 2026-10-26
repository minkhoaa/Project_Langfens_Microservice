using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace exam_service.Features.ReadingPaper;

public static class ReadingPaperLifecycle
{
    // The job row is the lock/authority for every transition. Never use a tracked
    // entity after ExecuteUpdate, and never let an expired worker finish a new epoch.
    public static Task<bool> FailAsync(ExamDbContext db, Guid id, Guid owner, int epoch,
        int cancelVersion, string status, string error, CancellationToken ct) => db.Database.CreateExecutionStrategy().ExecuteAsync(async () =>
    {
        if (status is not ("Failed" or "NeedsSources")) throw new ArgumentException("Invalid failure status");
        await using var tx = await db.Database.BeginTransactionAsync(ct);
        var now = DateTime.UtcNow;
        var locked = await db.ReadingPaperJobs.Where(j => j.Id == id && j.Status == "Running" && j.LeaseOwner == owner &&
            j.Epoch == epoch && j.CancelVersion == cancelVersion && j.LeaseUntil > now)
            .ExecuteUpdateAsync(s => s.SetProperty(j => j.UpdatedAt, now), ct);
        if (locked != 1) return false;
        var job = await db.ReadingPaperJobs.AsNoTracking().SingleAsync(j => j.Id == id, ct);
        var changed = await db.ReadingPaperRuns.Where(r => r.JobId == id && r.RunId == job.ActiveRunId && r.Status == "RUNNING" &&
            r.LeaseOwner == owner && r.Epoch == epoch && r.CancelVersion == cancelVersion && r.LeaseUntil > now)
            .ExecuteUpdateAsync(s => s.SetProperty(r => r.Status, status == "Failed" ? "FAILED" : "NEEDS_SOURCES")
                .SetProperty(r => r.LeaseOwner, (Guid?)null).SetProperty(r => r.LeaseUntil, (DateTime?)null).SetProperty(r => r.UpdatedAt, now), ct);
        if (changed != 1) return false; // rollback job lock as well
        await db.ReadingPaperJobs.Where(j => j.Id == id).ExecuteUpdateAsync(s => s.SetProperty(j => j.Status, status)
            .SetProperty(j => j.Error, error.Length > 1000 ? error[..1000] : error)
            .SetProperty(j => j.LeaseOwner, (Guid?)null).SetProperty(j => j.LeaseUntil, (DateTime?)null), ct);
        await tx.CommitAsync(ct);
        return true;
    });

    // Explicit, idempotent historical reconciliation, NOT a startup migration.
    // Unknown/reserved physical operations remain untouched and block this path.
    public static Task<bool> ReconcileTerminalAsync(ExamDbContext db, Guid id, int epoch, CancellationToken ct) =>
        db.Database.CreateExecutionStrategy().ExecuteAsync(async () =>
    {
        await using var tx = await db.Database.BeginTransactionAsync(ct);
        var locked = await db.ReadingPaperJobs.Where(j => j.Id == id && j.Epoch == epoch && j.LeaseOwner == null &&
            (j.Status == "Failed" || j.Status == "NeedsSources" || j.Status == "Cancelled") &&
            (j.LeaseUntil == null || j.LeaseUntil < DateTime.UtcNow))
            .ExecuteUpdateAsync(s => s.SetProperty(j => j.Epoch, j => j.Epoch), ct);
        if (locked != 1) return false;
        var job = await db.ReadingPaperJobs.AsNoTracking().SingleAsync(j => j.Id == id, ct);
        var target = job.Status == "Failed" ? "FAILED" : job.Status == "Cancelled" ? "CANCELLED" : "NEEDS_SOURCES";
        var run = await db.ReadingPaperRuns.AsNoTracking().SingleOrDefaultAsync(r => r.JobId == id && r.RunId == job.ActiveRunId, ct);
        if (run == null || run.Epoch != epoch || run.CancelVersion != job.CancelVersion ||
            (run.LeaseUntil > DateTime.UtcNow) || (run.Status != "RUNNING" && run.Status != target)) return false;
        if (await HasUnresolvedAsync(db, run.RunId, ct)) return false;
        if (run.Status != target || run.LeaseOwner != null || run.LeaseUntil != null)
            await db.ReadingPaperRuns.Where(r => r.Id == run.Id).ExecuteUpdateAsync(s => s.SetProperty(r => r.Status, target)
                .SetProperty(r => r.LeaseOwner, (Guid?)null).SetProperty(r => r.LeaseUntil, (DateTime?)null)
                .SetProperty(r => r.UpdatedAt, DateTime.UtcNow), ct);
        await tx.CommitAsync(ct);
        return true;
    });

    public static Task<bool> HasUnresolvedAsync(ExamDbContext db, string run, CancellationToken ct) =>
        db.ReadingPaperOperations.AnyAsync(o => o.RunId == run && o.OperationType == "PROVIDER_CALL" &&
            (o.Status == "RESERVED" || o.Status == "UNKNOWN_OUTCOME" || o.AccountingType == "UNKNOWN"), ct);
}
