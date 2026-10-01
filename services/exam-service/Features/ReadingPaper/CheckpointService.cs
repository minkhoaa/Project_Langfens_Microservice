using System.Text.Json;
using exam_service.Domains.Entities;
using exam_service.Features.ReadingPaper.Contracts;
using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts.Exam.Enums;

namespace exam_service.Features.ReadingPaper;

public class CheckpointValidationException : Exception
{
    public int StatusCode { get; }
    public CheckpointValidationException(int statusCode, string message) : base(message)
    {
        StatusCode = statusCode;
    }
}

public static class CheckpointService
{
    public const string InternalApiKeyHeader = "X-Internal-Service-Key";

    public static async Task<(ReadingPaperRun Run, ReadingPaperJob Job)> ValidateRunAuthorityAndFencingAsync(
        ExamDbContext db,
        string runId,
        int epoch,
        Guid leaseOwner,
        CancellationToken ct)
    {
        var run = await db.ReadingPaperRuns
            .Include(r => r.Job)
            .FirstOrDefaultAsync(r => r.RunId == runId, ct);

        if (run == null)
            throw new CheckpointValidationException(404, $"Run '{runId}' not found");

        var job = run.Job ?? await db.ReadingPaperJobs.FirstOrDefaultAsync(j => j.Id == run.JobId, ct);
        if (job == null)
            throw new CheckpointValidationException(404, $"Job '{run.JobId}' not found");

        // 1. Cancellation check
        if (string.Equals(job.Status, "Cancelled", StringComparison.OrdinalIgnoreCase) ||
            string.Equals(run.Status, "CANCELLED", StringComparison.OrdinalIgnoreCase) ||
            job.CancelVersion != run.CancelVersion)
        {
            throw new CheckpointValidationException(409, "Run or Job has been cancelled; late operations rejected fail-closed");
        }

        // 2. Epoch fencing check
        if (run.Epoch != epoch || job.Epoch != epoch)
        {
            throw new CheckpointValidationException(409,
                $"Epoch fencing violation: requested epoch {epoch} does not match authoritative epoch (run: {run.Epoch}, job: {job.Epoch})");
        }

        // 3. Lease ownership check
        if (run.LeaseOwner != leaseOwner || job.LeaseOwner != leaseOwner)
        {
            throw new CheckpointValidationException(409,
                $"Lease fencing violation: requested leaseOwner '{leaseOwner}' does not match active lease owner");
        }

        // 4. Lease expiration check
        if (job.LeaseUntil is null || job.LeaseUntil < DateTime.UtcNow)
        {
            throw new CheckpointValidationException(409, "Lease has expired; worker must renew before writing");
        }

        return (run, job);
    }
    public static async Task<SetBudgetAllocationsResult> SetBudgetAllocationsAsync(
        ExamDbContext db,
        SetBudgetAllocationsRequest request,
        CancellationToken ct)
    {
        var (run, job) = await ValidateRunAuthorityAndFencingAsync(db, request.RunId, request.Epoch, request.LeaseOwner, ct);

        // Validate ScopeType and scopeIds
        foreach (var alloc in request.Allocations)
        {
            var st = alloc.ScopeType.ToUpperInvariant();
            if (st != "SECTION" && st != "ARTIFACT")
            {
                throw new CheckpointValidationException(422, $"Invalid scopeType '{alloc.ScopeType}'; must be 'SECTION' or 'ARTIFACT'");
            }
            if (string.IsNullOrWhiteSpace(alloc.ScopeId))
            {
                throw new CheckpointValidationException(422, "ScopeId cannot be empty");
            }
        }

        // 1. Validate SECTION sums vs Run Caps across all 3 dimensions (tokens, calls, wall-time)
        var sections = request.Allocations
            .Where(a => string.Equals(a.ScopeType, "SECTION", StringComparison.OrdinalIgnoreCase))
            .ToList();

        var sectionTotalTokens = sections.Sum(a => a.TokenCap);
        if (sectionTotalTokens > run.BudgetCapTokens)
        {
            throw new CheckpointValidationException(422,
                $"Invalid budget allocation hierarchy: sum of section token caps ({sectionTotalTokens}) exceeds run budget cap ({run.BudgetCapTokens})");
        }

        var sectionTotalCalls = sections.Sum(a => a.CallCap);
        if (sectionTotalCalls > run.BudgetCapCalls)
        {
            throw new CheckpointValidationException(422,
                $"Invalid budget allocation hierarchy: sum of section call caps ({sectionTotalCalls}) exceeds run budget cap ({run.BudgetCapCalls})");
        }

        var sectionTotalWallTime = sections.Sum(a => a.WallTimeCapSeconds);
        if (sectionTotalWallTime > run.BudgetCapWallTimeSeconds)
        {
            throw new CheckpointValidationException(422,
                $"Invalid budget allocation hierarchy: sum of section wall-time caps ({sectionTotalWallTime}s) exceeds run budget cap ({run.BudgetCapWallTimeSeconds}s)");
        }

        var sectionAllocMap = sections.ToDictionary(a => a.ScopeId, a => a);

        // 2. Validate ARTIFACT scopes: no orphans, and sum of children <= parent section across all 3 dimensions
        var artifacts = request.Allocations
            .Where(a => string.Equals(a.ScopeType, "ARTIFACT", StringComparison.OrdinalIgnoreCase))
            .ToList();

        foreach (var art in artifacts)
        {
            if (string.IsNullOrWhiteSpace(art.ParentScopeId) || !sectionAllocMap.ContainsKey(art.ParentScopeId))
            {
                throw new CheckpointValidationException(422,
                    $"Orphan artifact scope '{art.ScopeId}': parentScopeId '{art.ParentScopeId}' does not match any declared section in this allocation");
            }
        }

        var artifactGroups = artifacts.GroupBy(a => a.ParentScopeId!);
        foreach (var group in artifactGroups)
        {
            var parentSec = sectionAllocMap[group.Key];
            var childTokensSum = group.Sum(a => a.TokenCap);
            if (childTokensSum > parentSec.TokenCap)
            {
                throw new CheckpointValidationException(422,
                    $"Invalid budget allocation hierarchy: sum of artifact token caps ({childTokensSum}) for section '{group.Key}' exceeds parent section cap ({parentSec.TokenCap})");
            }

            var childCallsSum = group.Sum(a => a.CallCap);
            if (childCallsSum > parentSec.CallCap)
            {
                throw new CheckpointValidationException(422,
                    $"Invalid budget allocation hierarchy: sum of artifact call caps ({childCallsSum}) for section '{group.Key}' exceeds parent section cap ({parentSec.CallCap})");
            }

            var childWallTimeSum = group.Sum(a => a.WallTimeCapSeconds);
            if (childWallTimeSum > parentSec.WallTimeCapSeconds)
            {
                throw new CheckpointValidationException(422,
                    $"Invalid budget allocation hierarchy: sum of artifact wall-time caps ({childWallTimeSum}s) for section '{group.Key}' exceeds parent section cap ({parentSec.WallTimeCapSeconds}s)");
            }
        }

        var strategy = db.Database.CreateExecutionStrategy();
        return await strategy.ExecuteAsync(async () =>
        {
            db.ChangeTracker.Clear();
            await using var tx = await db.Database.BeginTransactionAsync(ct);

            // In-transaction conditional lock on Job
            var fencedJobRows = await db.ReadingPaperJobs
                .Where(j => j.Id == job.Id && j.Epoch == request.Epoch && j.LeaseOwner == request.LeaseOwner && j.Status == "Running" && j.LeaseUntil > DateTime.UtcNow && j.CancelVersion == job.CancelVersion)
                .ExecuteUpdateAsync(s => s.SetProperty(j => j.UpdatedAt, DateTime.UtcNow), ct);

            if (fencedJobRows != 1)
            {
                throw new CheckpointValidationException(409,
                    $"Epoch fencing violation: atomic conditional lock failed for job '{job.Id}' in budget allocation");
            }

            var existingAllocations = await db.ReadingPaperBudgetAllocations
                .Where(b => b.RunId == request.RunId)
                .ToListAsync(ct);

            var operationsExist = await db.ReadingPaperOperations
                .AnyAsync(o => o.RunId == request.RunId, ct);

            if (operationsExist)
            {
                // Write-once / immutable rule: once operations exist, allocations cannot be mutated
                if (existingAllocations.Count == request.Allocations.Count)
                {
                    var isExactMatch = request.Allocations.All(req =>
                        existingAllocations.Any(ex =>
                            string.Equals(ex.ScopeId, req.ScopeId, StringComparison.OrdinalIgnoreCase) &&
                            string.Equals(ex.ScopeType, req.ScopeType, StringComparison.OrdinalIgnoreCase) &&
                            string.Equals(ex.ParentScopeId, req.ParentScopeId, StringComparison.OrdinalIgnoreCase) &&
                            ex.TokenCap == req.TokenCap &&
                            ex.CallCap == req.CallCap &&
                            ex.WallTimeCapSeconds == req.WallTimeCapSeconds));

                    if (isExactMatch)
                    {
                        return new SetBudgetAllocationsResult(request.RunId, existingAllocations.Count, DateTime.UtcNow);
                    }
                }

                throw new CheckpointValidationException(409,
                    $"Budget allocations are immutable once operations have commenced for run '{request.RunId}'; mutation forbidden");
            }

            // No operations exist yet: safe to set or replace allocations
            if (existingAllocations.Count > 0)
            {
                db.ReadingPaperBudgetAllocations.RemoveRange(existingAllocations);
            }

            foreach (var item in request.Allocations)
            {
                db.ReadingPaperBudgetAllocations.Add(new ReadingPaperBudgetAllocation
                {
                    Id = Guid.NewGuid(),
                    RunId = request.RunId,
                    ScopeType = item.ScopeType.ToUpperInvariant(),
                    ScopeId = item.ScopeId,
                    ParentScopeId = item.ParentScopeId,
                    TokenCap = item.TokenCap,
                    CallCap = item.CallCap,
                    WallTimeCapSeconds = item.WallTimeCapSeconds,
                    CreatedAt = DateTime.UtcNow
                });
            }

            await db.SaveChangesAsync(ct);
            await tx.CommitAsync(ct);

            return new SetBudgetAllocationsResult(request.RunId, request.Allocations.Count, DateTime.UtcNow);
        });
    }

    private static async Task EnsureDefaultBudgetAllocationsAsync(ExamDbContext db, ReadingPaperRun run, CancellationToken ct)
    {
        var hasAllocations = await db.ReadingPaperBudgetAllocations.AnyAsync(b => b.RunId == run.RunId, ct);
        if (hasAllocations) return;

        var defaultSections = new[] { "section_1", "section_2", "section_3" };
        foreach (var sec in defaultSections)
        {
            // Seed parent section (45,000 tokens, 8 calls, 280s)
            db.ReadingPaperBudgetAllocations.Add(new ReadingPaperBudgetAllocation
            {
                Id = Guid.NewGuid(),
                RunId = run.RunId,
                ScopeType = "SECTION",
                ScopeId = sec,
                ParentScopeId = null,
                TokenCap = 45000,
                CallCap = 8,
                WallTimeCapSeconds = 280,
                CreatedAt = DateTime.UtcNow
            });

            // Seed canonical child artifact scopes parented to section:
            // passage (15k, 2 calls, 90s)
            db.ReadingPaperBudgetAllocations.Add(new ReadingPaperBudgetAllocation
            {
                Id = Guid.NewGuid(),
                RunId = run.RunId,
                ScopeType = "ARTIFACT",
                ScopeId = $"passage_{sec}",
                ParentScopeId = sec,
                TokenCap = 15000,
                CallCap = 2,
                WallTimeCapSeconds = 90,
                CreatedAt = DateTime.UtcNow
            });
            // questions (18k, 3 calls, 100s)
            db.ReadingPaperBudgetAllocations.Add(new ReadingPaperBudgetAllocation
            {
                Id = Guid.NewGuid(),
                RunId = run.RunId,
                ScopeType = "ARTIFACT",
                ScopeId = $"questions_{sec}",
                ParentScopeId = sec,
                TokenCap = 18000,
                CallCap = 3,
                WallTimeCapSeconds = 100,
                CreatedAt = DateTime.UtcNow
            });
            // solver (6k, 2 calls, 50s)
            db.ReadingPaperBudgetAllocations.Add(new ReadingPaperBudgetAllocation
            {
                Id = Guid.NewGuid(),
                RunId = run.RunId,
                ScopeType = "ARTIFACT",
                ScopeId = $"solver_{sec}",
                ParentScopeId = sec,
                TokenCap = 6000,
                CallCap = 2,
                WallTimeCapSeconds = 50,
                CreatedAt = DateTime.UtcNow
            });
            // review (6k, 1 call, 40s)
            db.ReadingPaperBudgetAllocations.Add(new ReadingPaperBudgetAllocation
            {
                Id = Guid.NewGuid(),
                RunId = run.RunId,
                ScopeType = "ARTIFACT",
                ScopeId = $"review_{sec}",
                ParentScopeId = sec,
                TokenCap = 6000,
                CallCap = 1,
                WallTimeCapSeconds = 40,
                CreatedAt = DateTime.UtcNow
            });
        }
        await db.SaveChangesAsync(ct);
    }


    public static async Task<OperationGrantResult> GrantOperationAsync(
        ExamDbContext db,
        OperationGrantRequest request,
        CancellationToken ct)
    {
        var (run, job) = await ValidateRunAuthorityAndFencingAsync(db, request.RunId, request.Epoch, request.LeaseOwner, ct);

        var strategy = db.Database.CreateExecutionStrategy();
        return await strategy.ExecuteAsync(async () =>
        {
            db.ChangeTracker.Clear();
            await using var tx = await db.Database.BeginTransactionAsync(ct);

            // 1. In-transaction row lock and fencing check on Job
            var fencedJobRows = await db.ReadingPaperJobs
                .Where(j => j.Id == job.Id && j.Epoch == request.Epoch && j.LeaseOwner == request.LeaseOwner && j.Status == "Running" && j.LeaseUntil > DateTime.UtcNow && j.CancelVersion == job.CancelVersion)
                .ExecuteUpdateAsync(s => s.SetProperty(j => j.UpdatedAt, DateTime.UtcNow), ct);

            if (fencedJobRows != 1)
            {
                throw new CheckpointValidationException(409,
                    $"Epoch fencing violation: atomic conditional lock failed for job '{job.Id}' in grant operation");
            }

            // 2. Check if operation already exists (Idempotency check)
            var existing = await db.ReadingPaperOperations.FirstOrDefaultAsync(
                o => o.RunId == request.RunId && o.OperationId == request.OperationId, ct);

            if (existing != null)
            {
                if (!string.Equals(existing.RequestHash, request.RequestHash, StringComparison.OrdinalIgnoreCase))
                {
                    throw new CheckpointValidationException(409,
                        $"OperationId '{request.OperationId}' already exists with a different request hash; mutation forbidden");
                }

                return new OperationGrantResult(
                    existing.OperationId,
                    existing.RunId,
                    existing.Status,
                    existing.TokenReservation,
                    existing.WallTimeReservationSeconds,
                    existing.CreatedAt,
                    IsReplay: true
                );
            }

            // 3. Parent-Child Relationship Validation & Fencing
            ReadingPaperOperation? parentOp = null;
            if (!string.IsNullOrWhiteSpace(request.ParentOperationId))
            {
                parentOp = await db.ReadingPaperOperations.FirstOrDefaultAsync(
                    o => o.RunId == request.RunId && o.OperationId == request.ParentOperationId, ct);

                if (parentOp == null)
                {
                    throw new CheckpointValidationException(422,
                        $"Parent operation '{request.ParentOperationId}' not found in run '{request.RunId}'");
                }

                if (!string.Equals(parentOp.Status, "RESERVED", StringComparison.OrdinalIgnoreCase))
                {
                    throw new CheckpointValidationException(422,
                        $"Parent operation '{request.ParentOperationId}' is in status '{parentOp.Status}'; must be in status 'RESERVED' to authorize child operations");
                }

                if (!string.IsNullOrWhiteSpace(parentOp.SectionId) &&
                    !string.IsNullOrWhiteSpace(request.SectionId) &&
                    !string.Equals(parentOp.SectionId, request.SectionId, StringComparison.OrdinalIgnoreCase))
                {
                    throw new CheckpointValidationException(422,
                        $"Parent operation '{request.ParentOperationId}' belongs to section '{parentOp.SectionId}', but child requested section '{request.SectionId}'");
                }

                // Enforce that aggregate child reservations stay within parent reservation
                var currentChildTokens = await db.ReadingPaperOperations
                    .Where(o => o.RunId == request.RunId && o.ParentOperationId == request.ParentOperationId &&
                                (o.Status == "RESERVED" || o.Status == "COMPLETED" || o.Status == "UNKNOWN_OUTCOME"))
                    .SumAsync(o => o.Status == "COMPLETED" ? o.TokensUsed : o.TokenReservation, ct);

                if (currentChildTokens + request.TokenReservation > parentOp.TokenReservation)
                {
                    throw new CheckpointValidationException(422,
                        $"Parent operation reservation exceeded: parent '{parentOp.OperationId}' token reservation ({parentOp.TokenReservation}) would be exceeded by child reservation {request.TokenReservation} (current child allocated: {currentChildTokens})");
                }

                var currentChildWallTime = await db.ReadingPaperOperations
                    .Where(o => o.RunId == request.RunId && o.ParentOperationId == request.ParentOperationId &&
                                (o.Status == "RESERVED" || o.Status == "COMPLETED" || o.Status == "UNKNOWN_OUTCOME"))
                    .SumAsync(o => o.Status == "COMPLETED" ? o.WallTimeUsedSeconds : o.WallTimeReservationSeconds, ct);

                if (currentChildWallTime + request.WallTimeReservationSeconds > parentOp.WallTimeReservationSeconds)
                {
                    throw new CheckpointValidationException(422,
                        $"Parent operation reservation exceeded: parent '{parentOp.OperationId}' wall-time reservation ({parentOp.WallTimeReservationSeconds}s) would be exceeded by child reservation {request.WallTimeReservationSeconds}s (current child allocated: {currentChildWallTime:F1}s)");
                }
            }

            if (parentOp == null && request.OperationType != "CHECKPOINT_COMMIT")
            {
                // Standalone operation: atomically check budget caps and reserve calls, tokens, and wall-time on ReadingPaperRuns
                var reservedRunRows = await db.ReadingPaperRuns
                    .Where(r => r.RunId == request.RunId &&
                                r.Epoch == request.Epoch &&
                                r.LeaseOwner == request.LeaseOwner &&
                                r.Status == "RUNNING" &&
                                r.CancelVersion == job.CancelVersion &&
                                r.BudgetUsedCalls + 1 <= r.BudgetCapCalls &&
                                r.BudgetUsedTokens + request.TokenReservation <= r.BudgetCapTokens &&
                                r.BudgetUsedWallTimeSeconds + request.WallTimeReservationSeconds <= r.BudgetCapWallTimeSeconds)
                    .ExecuteUpdateAsync(s => s
                        .SetProperty(r => r.BudgetUsedCalls, r => r.BudgetUsedCalls + 1)
                        .SetProperty(r => r.BudgetUsedTokens, r => r.BudgetUsedTokens + request.TokenReservation)
                        .SetProperty(r => r.BudgetUsedWallTimeSeconds, r => r.BudgetUsedWallTimeSeconds + request.WallTimeReservationSeconds)
                        .SetProperty(r => r.UpdatedAt, DateTime.UtcNow), ct);

                if (reservedRunRows != 1)
                {
                    var currentRun = await db.ReadingPaperRuns.AsNoTracking().FirstOrDefaultAsync(r => r.RunId == request.RunId, ct);
                    if (currentRun != null)
                    {
                        if (currentRun.BudgetUsedCalls + 1 > currentRun.BudgetCapCalls)
                            throw new CheckpointValidationException(422, $"Budget exhausted: maximum calls ({currentRun.BudgetCapCalls}) exceeded");
                        if (currentRun.BudgetUsedTokens + request.TokenReservation > currentRun.BudgetCapTokens)
                            throw new CheckpointValidationException(422, $"Budget exhausted: token cap ({currentRun.BudgetCapTokens}) would be exceeded by reservation {request.TokenReservation}");
                        if (currentRun.BudgetUsedWallTimeSeconds + request.WallTimeReservationSeconds > currentRun.BudgetCapWallTimeSeconds)
                            throw new CheckpointValidationException(422, $"Budget exhausted: wall time cap ({currentRun.BudgetCapWallTimeSeconds}s) would be exceeded by reservation {request.WallTimeReservationSeconds}s");
                    }

                    throw new CheckpointValidationException(409, "Epoch fencing violation or lease expired during grant operation");
                }
            }
            await EnsureDefaultBudgetAllocationsAsync(db, run, ct);

            if (!string.IsNullOrWhiteSpace(request.SectionId))
            {
                var sectionId = request.SectionId;

                // 3.1 Enforce Section-level budget allocation caps across all 3 dimensions
                var sectionAllocation = await db.ReadingPaperBudgetAllocations
                    .FirstOrDefaultAsync(b => b.RunId == request.RunId && b.ScopeId == sectionId && b.ScopeType == "SECTION", ct);

                if (sectionAllocation == null)
                {
                    throw new CheckpointValidationException(422,
                        $"Section budget allocation for scope '{sectionId}' not found");
                }
                // If this is a standalone / parent operation (ParentOperationId is null), check against Section Cap:
                if (string.IsNullOrWhiteSpace(request.ParentOperationId))
                {
                    var allocatedSectionTokens = await db.ReadingPaperOperations
                        .Where(o => o.RunId == request.RunId &&
                                    o.SectionId == sectionId &&
                                    o.ParentOperationId == null &&
                                    (o.Status == "RESERVED" || o.Status == "COMPLETED" || o.Status == "UNKNOWN_OUTCOME"))
                        .SumAsync(o => o.Status == "COMPLETED" ? o.TokensUsed : o.TokenReservation, ct);

                    if (allocatedSectionTokens + request.TokenReservation > sectionAllocation.TokenCap)
                    {
                        throw new CheckpointValidationException(422,
                            $"Section budget exhausted: section '{sectionId}' token cap ({sectionAllocation.TokenCap}) would be exceeded by reservation {request.TokenReservation} (current allocated: {allocatedSectionTokens})");
                    }

                    var allocatedSectionCalls = await db.ReadingPaperOperations
                        .Where(o => o.RunId == request.RunId &&
                                    o.SectionId == sectionId &&
                                    o.ParentOperationId == null &&
                                    (o.Status == "RESERVED" || o.Status == "COMPLETED" || o.Status == "UNKNOWN_OUTCOME"))
                        .CountAsync(ct);

                    if (allocatedSectionCalls + 1 > sectionAllocation.CallCap)
                    {
                        throw new CheckpointValidationException(422,
                            $"Section budget exhausted: section '{sectionId}' call cap ({sectionAllocation.CallCap}) would be exceeded");
                    }

                    var allocatedSectionWallTime = await db.ReadingPaperOperations
                        .Where(o => o.RunId == request.RunId &&
                                    o.SectionId == sectionId &&
                                    o.ParentOperationId == null &&
                                    (o.Status == "RESERVED" || o.Status == "COMPLETED" || o.Status == "UNKNOWN_OUTCOME"))
                        .SumAsync(o => o.Status == "COMPLETED" ? o.WallTimeUsedSeconds : o.WallTimeReservationSeconds, ct);

                    if (allocatedSectionWallTime + request.WallTimeReservationSeconds > sectionAllocation.WallTimeCapSeconds)
                    {
                        throw new CheckpointValidationException(422,
                            $"Section budget exhausted: section '{sectionId}' wall-time cap ({sectionAllocation.WallTimeCapSeconds}s) would be exceeded by reservation {request.WallTimeReservationSeconds}s (current allocated: {allocatedSectionWallTime:F1}s)");
                    }
                }
                // 3.2 Enforce Artifact-level budget allocation caps across all 3 dimensions if ArtifactId is specified
                if (!string.IsNullOrWhiteSpace(request.ArtifactId))
                {
                    var artifactId = request.ArtifactId;
                    var artifactAllocation = await db.ReadingPaperBudgetAllocations
                        .FirstOrDefaultAsync(b => b.RunId == request.RunId && b.ScopeId == artifactId && b.ScopeType == "ARTIFACT", ct);

                    if (artifactAllocation == null)
                    {
                        throw new CheckpointValidationException(422,
                            $"Artifact budget allocation for scope '{artifactId}' not found");
                    }

                    if (!string.Equals(artifactAllocation.ParentScopeId, sectionId, StringComparison.OrdinalIgnoreCase))
                    {
                        throw new CheckpointValidationException(422,
                            $"Artifact scope '{artifactId}' belongs to parent section '{artifactAllocation.ParentScopeId}', but request specified section '{sectionId}'");
                    }

                    var allocatedArtifactTokens = await db.ReadingPaperOperations
                        .Where(o => o.RunId == request.RunId &&
                                    o.ArtifactId == artifactId &&
                                    (o.Status == "RESERVED" || o.Status == "COMPLETED" || o.Status == "UNKNOWN_OUTCOME"))
                        .SumAsync(o => o.Status == "COMPLETED" ? o.TokensUsed : o.TokenReservation, ct);

                    if (allocatedArtifactTokens + request.TokenReservation > artifactAllocation.TokenCap)
                    {
                        throw new CheckpointValidationException(422,
                            $"Artifact budget exhausted: artifact '{artifactId}' token cap ({artifactAllocation.TokenCap}) would be exceeded by reservation {request.TokenReservation} (current allocated: {allocatedArtifactTokens})");
                    }

                    var allocatedArtifactCalls = await db.ReadingPaperOperations
                        .Where(o => o.RunId == request.RunId &&
                                    o.ArtifactId == artifactId &&
                                    (o.Status == "RESERVED" || o.Status == "COMPLETED" || o.Status == "UNKNOWN_OUTCOME"))
                        .CountAsync(ct);

                    if (allocatedArtifactCalls + 1 > artifactAllocation.CallCap)
                    {
                        throw new CheckpointValidationException(422,
                            $"Artifact budget exhausted: artifact '{artifactId}' call cap ({artifactAllocation.CallCap}) would be exceeded");
                    }

                    var allocatedArtifactWallTime = await db.ReadingPaperOperations
                        .Where(o => o.RunId == request.RunId &&
                                    o.ArtifactId == artifactId &&
                                    (o.Status == "RESERVED" || o.Status == "COMPLETED" || o.Status == "UNKNOWN_OUTCOME"))
                        .SumAsync(o => o.Status == "COMPLETED" ? o.WallTimeUsedSeconds : o.WallTimeReservationSeconds, ct);

                    if (allocatedArtifactWallTime + request.WallTimeReservationSeconds > artifactAllocation.WallTimeCapSeconds)
                    {
                        throw new CheckpointValidationException(422,
                            $"Artifact budget exhausted: artifact '{artifactId}' wall-time cap ({artifactAllocation.WallTimeCapSeconds}s) would be exceeded by reservation {request.WallTimeReservationSeconds}s (current allocated: {allocatedArtifactWallTime:F1}s)");
                    }
                }
            }

            // 4. Persist Operation Intent in same transaction
            var op = new ReadingPaperOperation
            {
                Id = Guid.NewGuid(),
                RunId = request.RunId,
                OperationId = request.OperationId,
                OperationType = request.OperationType,
                RequestHash = request.RequestHash,
                Status = "RESERVED",
                TokenReservation = request.TokenReservation,
                TokensUsed = 0,
                CostReservationUsd = request.CostReservationUsd,
                CostUsedUsd = 0m,
                SectionId = request.SectionId,
                ArtifactId = request.ArtifactId,
                ParentOperationId = request.ParentOperationId,
                WallTimeReservationSeconds = request.WallTimeReservationSeconds,
                WallTimeUsedSeconds = 0.0,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };
            db.ReadingPaperOperations.Add(op);

            try
            {
                await db.SaveChangesAsync(ct);
                await tx.CommitAsync(ct);

                return new OperationGrantResult(
                    op.OperationId,
                    op.RunId,
                    op.Status,
                    op.TokenReservation,
                    op.WallTimeReservationSeconds,
                    op.CreatedAt,
                    IsReplay: false
                );
            }
            catch (DbUpdateException ex) when (ex.InnerException is Npgsql.PostgresException { SqlState: "23505" })
            {
                await tx.RollbackAsync(ct);
                db.ChangeTracker.Clear();
                var concurrentExisting = await db.ReadingPaperOperations.AsNoTracking().FirstOrDefaultAsync(
                    o => o.RunId == request.RunId && o.OperationId == request.OperationId, ct);
                if (concurrentExisting != null)
                {
                    if (!string.Equals(concurrentExisting.RequestHash, request.RequestHash, StringComparison.OrdinalIgnoreCase))
                    {
                        throw new CheckpointValidationException(409,
                            $"OperationId '{request.OperationId}' already exists with a different request hash; mutation forbidden");
                    }

                    return new OperationGrantResult(
                        concurrentExisting.OperationId,
                        concurrentExisting.RunId,
                        concurrentExisting.Status,
                        concurrentExisting.TokenReservation,
                        concurrentExisting.WallTimeReservationSeconds,
                        concurrentExisting.CreatedAt,
                        IsReplay: true
                    );
                }
                throw;
            }
        });
    }

    public static async Task<OperationReconcileResult> ReconcileOperationAsync(
        ExamDbContext db,
        OperationReconcileRequest request,
        CancellationToken ct)
    {
        var (run, job) = await ValidateRunAuthorityAndFencingAsync(db, request.RunId, request.Epoch, request.LeaseOwner, ct);

        var strategy = db.Database.CreateExecutionStrategy();
        return await strategy.ExecuteAsync(async () =>
        {
            db.ChangeTracker.Clear();
            await using var tx = await db.Database.BeginTransactionAsync(ct);

            // Conditional lock on Job
            var fencedJobRows = await db.ReadingPaperJobs
                .Where(j => j.Id == job.Id && j.Epoch == request.Epoch && j.LeaseOwner == request.LeaseOwner && j.Status == "Running" && j.LeaseUntil > DateTime.UtcNow && j.CancelVersion == job.CancelVersion)
                .ExecuteUpdateAsync(s => s.SetProperty(j => j.UpdatedAt, DateTime.UtcNow), ct);

            if (fencedJobRows != 1)
            {
                throw new CheckpointValidationException(409,
                    $"Epoch fencing violation: atomic conditional lock failed for job '{job.Id}' in operation reconciliation");
            }

            var op = await db.ReadingPaperOperations.FirstOrDefaultAsync(
                o => o.RunId == request.RunId && o.OperationId == request.OperationId, ct);

            if (op == null)
            {
                throw new CheckpointValidationException(404, $"Operation '{request.OperationId}' not found");
            }

            if (string.Equals(op.Status, "COMPLETED", StringComparison.OrdinalIgnoreCase))
            {
                if (!string.Equals(op.ResultRefJson, request.ResultRefJson, StringComparison.Ordinal))
                    throw new CheckpointValidationException(409, "Completed operation result differs from replay");
                return new OperationReconcileResult(op.OperationId, op.Status, op.TokensUsed,
                    op.WallTimeUsedSeconds, op.UpdatedAt);
            }

            op.Status = "COMPLETED";
            op.TokensUsed = request.TokensUsed;
            op.WallTimeUsedSeconds = request.WallTimeUsedSeconds;
            op.CostUsedUsd = request.CostUsedUsd;
            EvaluationResult? evalResult = null;
            if (!string.IsNullOrWhiteSpace(request.ResultRefJson))
            {
                op.ResultRefJson = request.ResultRefJson;
                if (op.OperationType == "EVALUATE")
                {
                    try
                    {
                        evalResult = JsonSerializer.Deserialize<EvaluationResult>(request.ResultRefJson, LoopEngineJson.Options)
                            ?? throw new JsonException("Empty evaluation result");
                        {
                            var evalExists = await db.ReadingPaperEvaluations.AnyAsync(e => e.RunId == request.RunId && e.EvaluationId == evalResult.EvaluationId, ct);
                            if (!evalExists)
                            {
                                db.ReadingPaperEvaluations.Add(new ReadingPaperEvaluation
                                {
                                    Id = Guid.NewGuid(),
                                    RunId = request.RunId,
                                    EvaluationId = evalResult.EvaluationId,
                                    EvaluatorId = evalResult.EvaluatorId,
                                    EvaluatorVersion = evalResult.EvaluatorVersion,
                                    TargetArtifactId = evalResult.TargetRef.ArtifactId,
                                    TargetVersion = evalResult.TargetRef.Version,
                                    TargetContentHash = evalResult.TargetRef.ContentHash,
                                    Status = evalResult.Status.ToString(),
                                    IsPass = evalResult.Status == EvaluationStatus.PASS,
                                    PayloadJson = request.ResultRefJson,
                                    CreatedAt = DateTime.UtcNow
                                });
                            }
                            if (evalResult.Issues is { Count: > 0 })
                            {
                                foreach (var issue in evalResult.Issues)
                                {
                                    var issueExists = await db.ReadingPaperIssues.AnyAsync(i => i.RunId == request.RunId && i.Fingerprint == issue.Fingerprint, ct);
                                    if (!issueExists)
                                    {
                                        db.ReadingPaperIssues.Add(new ReadingPaperIssue
                                        {
                                            Id = Guid.NewGuid(),
                                            RunId = request.RunId,
                                            IssueId = issue.IssueId,
                                            EvaluationId = evalResult.EvaluationId,
                                            Code = issue.Code.ToString(),
                                            Severity = issue.Severity.ToString(),
                                            Scope = issue.Scope.ToString(),
                                            Message = issue.Message,
                                            Status = issue.Status.ToString(),
                                            Fingerprint = issue.Fingerprint,
                                            CreatedAt = DateTime.UtcNow
                                        });
                                    }
                                }
                            }
                        }
                    }
                    catch (JsonException ex)
                    {
                        throw new CheckpointValidationException(422, $"Malformed evaluation result: {ex.Message}");
                    }
                }
            }

            var resolvedFpList = new HashSet<string>(request.ResolvedFingerprints ?? Enumerable.Empty<string>());
            if (evalResult?.ResolvedIssueFingerprints != null)
            {
                foreach (var fp in evalResult.ResolvedIssueFingerprints)
                {
                    resolvedFpList.Add(fp);
                }
            }
            if (resolvedFpList.Count > 0)
            {
                var toResolve = await db.ReadingPaperIssues
                    .Where(i => i.RunId == request.RunId && resolvedFpList.Contains(i.Fingerprint))
                    .ToListAsync(ct);
                foreach (var iss in toResolve)
                {
                    iss.Status = "RESOLVED";
                }
            }
            if (request.SupersededFingerprints is { Count: > 0 })
            {
                var toSupersede = await db.ReadingPaperIssues
                    .Where(i => i.RunId == request.RunId && request.SupersededFingerprints.Contains(i.Fingerprint))
                    .ToListAsync(ct);
                foreach (var iss in toSupersede)
                {
                    iss.Status = "SUPERSEDED";
                }
            }
            op.UpdatedAt = DateTime.UtcNow;
            // If standalone operation (no ParentOperationId), reconcile run counters directly
            if (string.IsNullOrWhiteSpace(op.ParentOperationId))
            {
                var runEntity = await db.ReadingPaperRuns.FirstAsync(r => r.RunId == request.RunId, ct);
                runEntity.BudgetUsedTokens += (request.TokensUsed - op.TokenReservation);
                runEntity.BudgetUsedWallTimeSeconds += (request.WallTimeUsedSeconds - op.WallTimeReservationSeconds);
                runEntity.UpdatedAt = DateTime.UtcNow;
            }

            await db.SaveChangesAsync(ct);
            await tx.CommitAsync(ct);

            return new OperationReconcileResult(
                op.OperationId,
                op.Status,
                op.TokensUsed,
                op.WallTimeUsedSeconds,
                op.UpdatedAt
            );
        });
    }

    public static async Task<CheckpointAck> CommitCheckpointAsync(
        ExamDbContext db,
        CheckpointCommitRequest request,
        CancellationToken ct,
        Func<Task>? onBeforeTransaction = null)
    {
        var (run, job) = await ValidateRunAuthorityAndFencingAsync(db, request.RunId, request.Epoch, request.LeaseOwner, ct);

        // 1. Operation validation
        var op = await db.ReadingPaperOperations.FirstOrDefaultAsync(
            o => o.RunId == request.RunId && o.OperationId == request.OperationId, ct);

        if (op == null)
        {
            throw new CheckpointValidationException(404,
                $"Operation '{request.OperationId}' not found; prior grant is required before commit");
        }

        if (!string.Equals(op.RequestHash, request.RequestHash, StringComparison.OrdinalIgnoreCase))
        {
            throw new CheckpointValidationException(409,
                $"Request hash mismatch for operation '{request.OperationId}'");
        }

        if (string.Equals(op.Status, "COMPLETED", StringComparison.OrdinalIgnoreCase))
        {
            // If already completed, check if committed artifact matches
            var existingHead = await db.ReadingPaperArtifactHeads.FirstOrDefaultAsync(
                h => h.RunId == request.RunId && h.ArtifactId == request.Artifact.ArtifactId, ct);

            if (existingHead != null && string.Equals(existingHead.AcceptedHash, request.Artifact.ContentHash, StringComparison.OrdinalIgnoreCase))
            {
                return new CheckpointAck(
                    request.RunId,
                    request.Epoch,
                    request.Artifact.ArtifactId,
                    existingHead.AcceptedVersion,
                    existingHead.AcceptedHash,
                    op.UpdatedAt,
                    IsReplay: true
                );
            }

            throw new CheckpointValidationException(409,
                $"Operation '{request.OperationId}' was already completed with a different artifact payload");
        }

        // 2. Cryptographic content hash verification
        var computedHash = ArtifactEnvelope.ComputeContentHash(request.Artifact.Payload, request.Artifact.ParentRefs);
        if (!string.Equals(computedHash, request.Artifact.ContentHash, StringComparison.OrdinalIgnoreCase))
        {
            throw new CheckpointValidationException(400,
                $"Artifact content hash mismatch: payload/parents hash is '{computedHash}' but envelope declared '{request.Artifact.ContentHash}'");
        }

        // 3. Immutability check
        var existingArt = await db.ReadingPaperArtifacts.FirstOrDefaultAsync(
            a => a.RunId == request.RunId && a.ArtifactId == request.Artifact.ArtifactId && a.Version == request.Artifact.Version, ct);

        if (existingArt != null)
        {
            if (!string.Equals(existingArt.ContentHash, request.Artifact.ContentHash, StringComparison.OrdinalIgnoreCase))
            {
                throw new CheckpointValidationException(409,
                    $"Immutability violation: artifact '{request.Artifact.ArtifactId}' version {request.Artifact.Version} already exists with different hash");
            }
        }

        // 4. Decision fail-closed admissibility
        if (request.Decision != null)
        {
            if (request.Decision.Decision == DecisionType.PASS || request.Decision.NextState == LoopState.COMPLETED)
            {
                EvaluationResult? eval = null;
                if (!string.IsNullOrWhiteSpace(request.Decision.EvaluationRef))
                {
                    eval = request.Evaluations?.FirstOrDefault(e => e.EvaluationId == request.Decision.EvaluationRef);
                    if (eval == null)
                    {
                        var storedEval = await db.ReadingPaperEvaluations.FirstOrDefaultAsync(
                            e => e.RunId == request.RunId && e.EvaluationId == request.Decision.EvaluationRef, ct);
                        if (storedEval != null)
                        {
                            eval = JsonSerializer.Deserialize<EvaluationResult>(storedEval.PayloadJson, LoopEngineJson.Options);
                        }
                    }
                }

                var (isValid, errMsg) = LoopDecision.ValidateDecision(request.Decision, eval);
                if (!isValid)
                {
                    throw new CheckpointValidationException(422, errMsg ?? "Decision rejected fail-closed");
                }
            }
        }
        if (onBeforeTransaction != null)
        {
            await onBeforeTransaction();
        }

        // 5. Atomic Transaction
        var strategy = db.Database.CreateExecutionStrategy();
        return await strategy.ExecuteAsync(async () =>
        {
            db.ChangeTracker.Clear();
            await using var tx = await db.Database.BeginTransactionAsync(ct);

            // Re-validate authority and fencing INSIDE the active transaction
            var txRun = await db.ReadingPaperRuns.Include(r => r.Job).FirstOrDefaultAsync(r => r.RunId == request.RunId, ct);
            if (txRun == null)
                throw new CheckpointValidationException(404, $"Run '{request.RunId}' not found in transaction");

            var txJob = txRun.Job ?? await db.ReadingPaperJobs.FirstOrDefaultAsync(j => j.Id == txRun.JobId, ct);
            if (txJob == null)
                throw new CheckpointValidationException(404, $"Job '{txRun.JobId}' not found in transaction");

            if (string.Equals(txJob.Status, "Cancelled", StringComparison.OrdinalIgnoreCase) ||
                string.Equals(txRun.Status, "CANCELLED", StringComparison.OrdinalIgnoreCase) ||
                txJob.CancelVersion != txRun.CancelVersion)
            {
                throw new CheckpointValidationException(409, "Run or Job has been cancelled; late operations rejected fail-closed");
            }

            if (txRun.Epoch != request.Epoch || txJob.Epoch != request.Epoch)
            {
                throw new CheckpointValidationException(409,
                    $"Epoch fencing violation: requested epoch {request.Epoch} does not match authoritative epoch (run: {txRun.Epoch}, job: {txJob.Epoch})");
            }

            if (txRun.LeaseOwner != request.LeaseOwner || txJob.LeaseOwner != request.LeaseOwner)
            {
                throw new CheckpointValidationException(409,
                    $"Lease fencing violation: requested leaseOwner '{request.LeaseOwner}' does not match active lease owner");
            }

            if (txJob.LeaseUntil is null || txJob.LeaseUntil < DateTime.UtcNow)
            {
                throw new CheckpointValidationException(409, "Lease has expired; worker must renew before writing");
            }

            // Acquire exclusive row locks and verify fencing predicates atomically inside transaction
            var fencedJobRows = await db.ReadingPaperJobs
                .Where(j => j.Id == txJob.Id && j.Epoch == request.Epoch && j.LeaseOwner == request.LeaseOwner && j.Status == "Running" && j.LeaseUntil > DateTime.UtcNow && j.CancelVersion == txJob.CancelVersion)
                .ExecuteUpdateAsync(s => s.SetProperty(j => j.UpdatedAt, DateTime.UtcNow), ct);

            if (fencedJobRows != 1)
            {
                throw new CheckpointValidationException(409,
                    $"Epoch fencing violation: atomic conditional lock failed for job '{txJob.Id}' (stale epoch {request.Epoch}, lease owner mismatch, cancelled, or lease expired)");
            }

            var fencedRunRows = await db.ReadingPaperRuns
                .Where(r => r.RunId == request.RunId && r.Epoch == request.Epoch && r.LeaseOwner == request.LeaseOwner && r.Status == "RUNNING" && r.CancelVersion == txRun.CancelVersion)
                .ExecuteUpdateAsync(s => s.SetProperty(r => r.UpdatedAt, DateTime.UtcNow), ct);

            if (fencedRunRows != 1)
            {
                throw new CheckpointValidationException(409,
                    $"Epoch fencing violation: atomic conditional lock failed for run '{request.RunId}'");
            }

            // Re-read operation inside transaction to verify its status under the acquired row lock
            var txOp = await db.ReadingPaperOperations.FirstOrDefaultAsync(
                o => o.RunId == request.RunId && o.OperationId == request.OperationId, ct);

            if (txOp == null)
            {
                throw new CheckpointValidationException(404,
                    $"Operation '{request.OperationId}' not found; prior grant is required before commit");
            }

            if (!string.Equals(txOp.RequestHash, request.RequestHash, StringComparison.OrdinalIgnoreCase))
            {
                throw new CheckpointValidationException(409,
                    $"Request hash mismatch for operation '{request.OperationId}'");
            }

            if (string.Equals(txOp.Status, "COMPLETED", StringComparison.OrdinalIgnoreCase))
            {
                var existingHead = await db.ReadingPaperArtifactHeads.AsNoTracking().FirstOrDefaultAsync(
                    h => h.RunId == request.RunId && h.ArtifactId == request.Artifact.ArtifactId, ct);

                if (existingHead != null && string.Equals(existingHead.AcceptedHash, request.Artifact.ContentHash, StringComparison.OrdinalIgnoreCase))
                {
                    return new CheckpointAck(
                        request.RunId,
                        request.Epoch,
                        request.Artifact.ArtifactId,
                        existingHead.AcceptedVersion,
                        existingHead.AcceptedHash,
                        txOp.UpdatedAt,
                        IsReplay: true
                    );
                }

                throw new CheckpointValidationException(409,
                    $"Operation '{request.OperationId}' was already completed with a different artifact payload");
            }
            // 5a. Persist Artifact
            if (existingArt == null)
            {
                var newArt = new ReadingPaperArtifact
                {
                    Id = Guid.NewGuid(),
                    RunId = request.RunId,
                    ArtifactId = request.Artifact.ArtifactId,
                    ArtifactType = request.Artifact.ArtifactType.ToString(),
                    Version = request.Artifact.Version,
                    ContentHash = request.Artifact.ContentHash,
                    PayloadJson = request.Artifact.Payload.GetRawText(),
                    ParentRefsJson = JsonSerializer.Serialize(request.Artifact.ParentRefs, LoopEngineJson.Options),
                    ProducerVersion = request.Artifact.ProducerVersion,
                    EnvelopeJson = JsonSerializer.Serialize(request.Artifact, LoopEngineJson.Options),
                    CreatedAt = DateTime.UtcNow
                }; 
                db.ReadingPaperArtifacts.Add(newArt);
            }

            foreach (var parent in request.Artifact.ParentRefs)
            {
                var depExists = await db.ReadingPaperArtifactDependencies.AnyAsync(
                    d => d.RunId == request.RunId && d.ArtifactId == request.Artifact.ArtifactId &&
                         d.Version == request.Artifact.Version && d.ParentArtifactId == parent.ArtifactId, ct);
                if (!depExists)
                {
                    db.ReadingPaperArtifactDependencies.Add(new ReadingPaperArtifactDependency
                    {
                        Id = Guid.NewGuid(),
                        RunId = request.RunId,
                        ArtifactId = request.Artifact.ArtifactId,
                        Version = request.Artifact.Version,
                        ParentArtifactId = parent.ArtifactId,
                        ParentVersion = parent.Version,
                        ParentContentHash = parent.ContentHash
                    });
                }
            }

            // 5b. Persist Evaluations & Issues
            if (request.Evaluations is { Count: > 0 })
            {
                foreach (var eval in request.Evaluations)
                {
                    var evalExists = await db.ReadingPaperEvaluations.AnyAsync(
                        e => e.RunId == request.RunId && e.EvaluationId == eval.EvaluationId, ct);

                    if (!evalExists)
                    {
                        db.ReadingPaperEvaluations.Add(new ReadingPaperEvaluation
                        {
                            Id = Guid.NewGuid(),
                            RunId = request.RunId,
                            EvaluationId = eval.EvaluationId,
                            EvaluatorId = eval.EvaluatorId,
                            EvaluatorVersion = eval.EvaluatorVersion,
                            TargetArtifactId = eval.TargetRef.ArtifactId,
                            TargetVersion = eval.TargetRef.Version,
                            TargetContentHash = eval.TargetRef.ContentHash,
                            Status = eval.Status.ToString(),
                            IsPass = eval.IsPass,
                            PayloadJson = JsonSerializer.Serialize(eval, LoopEngineJson.Options),
                            CreatedAt = DateTime.UtcNow
                        });

                        foreach (var issue in eval.Issues)
                        {
                            var issueExists = await db.ReadingPaperIssues.AnyAsync(
                                i => i.RunId == request.RunId && i.IssueId == issue.IssueId, ct);
                            if (!issueExists)
                            {
                                db.ReadingPaperIssues.Add(new ReadingPaperIssue
                                {
                                    Id = Guid.NewGuid(),
                                    RunId = request.RunId,
                                    IssueId = issue.IssueId,
                                    EvaluationId = eval.EvaluationId,
                                    Code = issue.Code.ToString(),
                                    Severity = issue.Severity.ToString(),
                                    Scope = issue.Scope.ToString(),
                                    Message = issue.Message,
                                    Status = issue.Status.ToString(),
                                    Fingerprint = issue.Fingerprint,
                                    CreatedAt = DateTime.UtcNow
                                });
                            }
                        }
                    }

                    if (eval.ResolvedIssueFingerprints is { Count: > 0 })
                    {
                        var toResolve = await db.ReadingPaperIssues
                            .Where(i => i.RunId == request.RunId && eval.ResolvedIssueFingerprints.Contains(i.Fingerprint))
                            .ToListAsync(ct);
                        foreach (var iss in toResolve)
                        {
                            iss.Status = "RESOLVED";
                        }
                    }
                }
            }

            // 5c. Persist Decision
            if (request.Decision != null)
            {
                var decExists = await db.ReadingPaperDecisions.AnyAsync(
                    d => d.RunId == request.RunId && d.DecisionId == request.Decision.DecisionId, ct);
                if (!decExists)
                {
                    db.ReadingPaperDecisions.Add(new ReadingPaperDecision
                    {
                        Id = Guid.NewGuid(),
                        RunId = request.RunId,
                        DecisionId = request.Decision.DecisionId,
                        Decision = request.Decision.Decision.ToString(),
                        CurrentState = request.Decision.CurrentState.ToString(),
                        NextState = request.Decision.NextState.ToString(),
                        Reason = request.Decision.Reason,
                        TargetScope = request.Decision.TargetScope.ToString(),
                        EvaluationRef = request.Decision.EvaluationRef,
                        BudgetReservationId = request.Decision.BudgetReservationId,
                        ExpectedVersion = request.Decision.ExpectedVersion,
                        PayloadJson = JsonSerializer.Serialize(request.Decision, LoopEngineJson.Options),
                        CreatedAt = DateTime.UtcNow
                    });
                }
            }
            // 5c2. Verify ParentRefs Freshness: declared parents must match current accepted heads
            if (request.Artifact.ParentRefs is { Count: > 0 })
            {
                var parentIds = request.Artifact.ParentRefs.Select(p => p.ArtifactId).Distinct().ToList();
                var currentParentHeads = await db.ReadingPaperArtifactHeads
                    .Where(h => h.RunId == request.RunId && parentIds.Contains(h.ArtifactId))
                    .ToDictionaryAsync(h => h.ArtifactId, StringComparer.OrdinalIgnoreCase, ct);

                foreach (var parentRef in request.Artifact.ParentRefs)
                {
                    if (!currentParentHeads.TryGetValue(parentRef.ArtifactId, out var currentHead))
                    {
                        throw new CheckpointValidationException(409,
                            $"Missing parent dependency: artifact '{request.Artifact.ArtifactId}' declares parent '{parentRef.ArtifactId}', but no accepted head exists in run '{request.RunId}'");
                    }

                    if (currentHead.AcceptedVersion != parentRef.Version ||
                        !string.Equals(currentHead.AcceptedHash, parentRef.ContentHash, StringComparison.Ordinal))
                    {
                        throw new CheckpointValidationException(409,
                            $"Stale parent dependency: artifact '{request.Artifact.ArtifactId}' declares parent '{parentRef.ArtifactId}' v{parentRef.Version} ({parentRef.ContentHash}), but current accepted head is v{currentHead.AcceptedVersion} ({currentHead.AcceptedHash})");
                    }
                }
            }


            // 5d. Atomic Conditional SQL Compare-And-Swap (CAS) on Accepted Head
            if (request.ExpectedHeadVersion is not null && request.ExpectedHeadVersion > 0)
            {
                var affected = await db.ReadingPaperArtifactHeads
                    .Where(h => h.RunId == request.RunId && h.ArtifactId == request.Artifact.ArtifactId && h.AcceptedVersion == request.ExpectedHeadVersion.Value)
                    .ExecuteUpdateAsync(setter => setter
                        .SetProperty(h => h.AcceptedVersion, request.Artifact.Version)
                        .SetProperty(h => h.AcceptedHash, request.Artifact.ContentHash)
                        .SetProperty(h => h.UpdatedAt, DateTime.UtcNow), ct);

                if (affected != 1)
                {
                    var currentHead = await db.ReadingPaperArtifactHeads.AsNoTracking().FirstOrDefaultAsync(
                        h => h.RunId == request.RunId && h.ArtifactId == request.Artifact.ArtifactId, ct);
                    var currentVersion = currentHead?.AcceptedVersion.ToString() ?? "none";
                    throw new CheckpointValidationException(409,
                        $"CAS rejection: current head version is {currentVersion} but expected {request.ExpectedHeadVersion} for artifact '{request.Artifact.ArtifactId}'");
                }
            }
            else
            {
                var headExists = await db.ReadingPaperArtifactHeads.AnyAsync(
                    h => h.RunId == request.RunId && h.ArtifactId == request.Artifact.ArtifactId, ct);

                if (headExists)
                {
                    throw new CheckpointValidationException(409,
                        $"CAS rejection: expected initial head (no prior head), but artifact '{request.Artifact.ArtifactId}' already has an accepted head");
                }

                db.ReadingPaperArtifactHeads.Add(new ReadingPaperArtifactHead
                {
                    Id = Guid.NewGuid(),
                    RunId = request.RunId,
                    ArtifactId = request.Artifact.ArtifactId,
                    AcceptedVersion = request.Artifact.Version,
                    AcceptedHash = request.Artifact.ContentHash,
                    UpdatedAt = DateTime.UtcNow
                });
            }
            // Invalidate only accepted descendants whose exact lineage is now stale.
            // This is in the same fenced transaction as the new accepted head.
            var acceptedChildren = await db.ReadingPaperArtifactHeads
                .Where(h => h.RunId == request.RunId && h.ArtifactId != request.Artifact.ArtifactId)
                .ToListAsync(ct);
            var childEdges = await db.ReadingPaperArtifactDependencies
                .Where(d => d.RunId == request.RunId)
                .ToListAsync(ct);
            var stale = new HashSet<string>(StringComparer.Ordinal);
            var changed = true;
            while (changed)
            {
                changed = false;
                foreach (var child in acceptedChildren)
                {
                    if (stale.Contains(child.ArtifactId)) continue;
                    if (childEdges.Any(d => d.ArtifactId == child.ArtifactId && d.Version == child.AcceptedVersion &&
                        (stale.Contains(d.ParentArtifactId) ||
                         (d.ParentArtifactId == request.Artifact.ArtifactId &&
                          (d.ParentVersion != request.Artifact.Version ||
                           d.ParentContentHash != request.Artifact.ContentHash)))))
                    {
                        stale.Add(child.ArtifactId);
                        changed = true;
                    }
                }
            }
            db.ReadingPaperArtifactHeads.RemoveRange(acceptedChildren.Where(h => stale.Contains(h.ArtifactId)));

            // 5e. Mark Operation as COMPLETED
            var opEntity = await db.ReadingPaperOperations.FirstAsync(
                o => o.RunId == request.RunId && o.OperationId == request.OperationId, ct);
            opEntity.Status = "COMPLETED";
            opEntity.TokensUsed = request.TokensUsed;
            opEntity.CostUsedUsd = request.CostUsedUsd;
            opEntity.WallTimeUsedSeconds = request.WallTimeUsedSeconds;
            opEntity.ResultRefJson = JsonSerializer.Serialize(request.Artifact.ToRef(), LoopEngineJson.Options);
            opEntity.UpdatedAt = DateTime.UtcNow;

            // 5f. Persist Outbox Events
            if (request.Events is { Count: > 0 })
            {
                foreach (var evt in request.Events)
                {
                    var evtExists = await db.ReadingPaperEventOutbox.AnyAsync(
                        e => e.RunId == request.RunId && e.IdempotencyKey == evt.IdempotencyKey, ct);
                    if (!evtExists)
                    {
                        db.ReadingPaperEventOutbox.Add(new ReadingPaperEventOutbox
                        {
                            Id = Guid.NewGuid(),
                            RunId = request.RunId,
                            EventId = evt.EventId,
                            EventType = evt.EventType.ToString(),
                            IdempotencyKey = evt.IdempotencyKey,
                            Epoch = evt.Epoch,
                            PayloadJson = JsonSerializer.Serialize(evt, LoopEngineJson.Options),
                            Status = "PENDING",
                            CreatedAt = DateTime.UtcNow
                        });
                    }
                }
            }

            // 5g. Update Run Budget
            var runEntity = await db.ReadingPaperRuns.Include(r => r.Job).FirstAsync(r => r.RunId == request.RunId, ct);
            runEntity.BudgetUsedTokens += (request.TokensUsed - txOp.TokenReservation);
            runEntity.BudgetUsedWallTimeSeconds += (request.WallTimeUsedSeconds - txOp.WallTimeReservationSeconds);
            runEntity.UpdatedAt = DateTime.UtcNow;

            // 5h. Backward Compatibility sync: If Section, sync to job.SectionsJson
            if (request.Artifact.ArtifactType == ArtifactType.Section && runEntity.Job != null)
            {
                SyncSectionToLegacyJob(runEntity.Job, request.Artifact);
            }

            try
            {
                await db.SaveChangesAsync(ct);
                await tx.CommitAsync(ct);

                return new CheckpointAck(
                    request.RunId,
                    request.Epoch,
                    request.Artifact.ArtifactId,
                    request.Artifact.Version,
                    request.Artifact.ContentHash,
                    DateTime.UtcNow,
                    IsReplay: false
                );
            }
            catch (DbUpdateException ex) when (ex.InnerException is Npgsql.PostgresException { SqlState: "23505" })
            {
                await tx.RollbackAsync(ct);
                db.ChangeTracker.Clear();
                // Check if a concurrent commit of the exact SAME OperationId succeeded
                var committedOp = await db.ReadingPaperOperations.AsNoTracking().FirstOrDefaultAsync(
                    o => o.RunId == request.RunId && o.OperationId == request.OperationId, ct);

                if (committedOp != null && string.Equals(committedOp.Status, "COMPLETED", StringComparison.OrdinalIgnoreCase))
                {
                    var committedHead = await db.ReadingPaperArtifactHeads.AsNoTracking().FirstOrDefaultAsync(
                        h => h.RunId == request.RunId && h.ArtifactId == request.Artifact.ArtifactId, ct);

                    if (committedHead != null && string.Equals(committedHead.AcceptedHash, request.Artifact.ContentHash, StringComparison.OrdinalIgnoreCase))
                    {
                        return new CheckpointAck(
                            request.RunId,
                            request.Epoch,
                            request.Artifact.ArtifactId,
                            committedHead.AcceptedVersion,
                            committedHead.AcceptedHash,
                            committedOp.UpdatedAt,
                            IsReplay: true
                        );
                    }
                }

                throw new CheckpointValidationException(409,
                    $"Concurrent modification conflict on artifact '{request.Artifact.ArtifactId}' or operation '{request.OperationId}'");
            }
        });
    }

    public static async Task<CheckpointAck> SaveDraftCheckpointAsync(
        ExamDbContext db,
        DraftCheckpointRequest request,
        CancellationToken ct)
    {
        var (run, job) = await ValidateRunAuthorityAndFencingAsync(db, request.RunId, request.Epoch, request.LeaseOwner, ct);

        // 1. Operation validation
        var op = await db.ReadingPaperOperations.FirstOrDefaultAsync(
            o => o.RunId == request.RunId && o.OperationId == request.OperationId, ct);

        if (op == null)
        {
            throw new CheckpointValidationException(404,
                $"Operation '{request.OperationId}' not found; prior grant is required before draft checkpoint");
        }

        if (!string.Equals(op.RequestHash, request.RequestHash, StringComparison.OrdinalIgnoreCase))
        {
            throw new CheckpointValidationException(409,
                $"Request hash mismatch for operation '{request.OperationId}'");
        }

        // 2. Cryptographic content hash verification
        var computedHash = ArtifactEnvelope.ComputeContentHash(request.Artifact.Payload, request.Artifact.ParentRefs);
        if (!string.Equals(computedHash, request.Artifact.ContentHash, StringComparison.OrdinalIgnoreCase))
        {
            throw new CheckpointValidationException(400,
                $"Artifact content hash mismatch: payload/parents hash is '{computedHash}' but envelope declared '{request.Artifact.ContentHash}'");
        }

        // 3. Immutability check
        var existingArt = await db.ReadingPaperArtifacts.FirstOrDefaultAsync(
            a => a.RunId == request.RunId && a.ArtifactId == request.Artifact.ArtifactId && a.Version == request.Artifact.Version, ct);

        if (existingArt != null)
        {
            if (!string.Equals(existingArt.ContentHash, request.Artifact.ContentHash, StringComparison.OrdinalIgnoreCase))
            {
                throw new CheckpointValidationException(409,
                    $"Immutability violation: artifact '{request.Artifact.ArtifactId}' version {request.Artifact.Version} already exists with different hash");
            }

            return new CheckpointAck(
                request.RunId,
                request.Epoch,
                request.Artifact.ArtifactId,
                request.Artifact.Version,
                request.Artifact.ContentHash,
                existingArt.CreatedAt,
                IsReplay: true
            );
        }

        var strategy = db.Database.CreateExecutionStrategy();
        return await strategy.ExecuteAsync(async () =>
        {
            db.ChangeTracker.Clear();
            await using var tx = await db.Database.BeginTransactionAsync(ct);

            var txRun = await db.ReadingPaperRuns.Include(r => r.Job).FirstOrDefaultAsync(r => r.RunId == request.RunId, ct);
            if (txRun == null)
                throw new CheckpointValidationException(404, $"Run '{request.RunId}' not found in transaction");

            var txJob = txRun.Job ?? await db.ReadingPaperJobs.FirstOrDefaultAsync(j => j.Id == txRun.JobId, ct);
            if (txJob == null)
                throw new CheckpointValidationException(404, $"Job '{txRun.JobId}' not found in transaction");

            if (string.Equals(txJob.Status, "Cancelled", StringComparison.OrdinalIgnoreCase) ||
                string.Equals(txRun.Status, "CANCELLED", StringComparison.OrdinalIgnoreCase) ||
                txJob.CancelVersion != txRun.CancelVersion)
            {
                throw new CheckpointValidationException(409, "Run or Job has been cancelled; late operations rejected fail-closed");
            }

            if (txRun.Epoch != request.Epoch || txJob.Epoch != request.Epoch)
            {
                throw new CheckpointValidationException(409,
                    $"Epoch fencing violation: requested epoch {request.Epoch} does not match authoritative epoch (run: {txRun.Epoch}, job: {txJob.Epoch})");
            }

            if (txRun.LeaseOwner != request.LeaseOwner || txJob.LeaseOwner != request.LeaseOwner)
            {
                throw new CheckpointValidationException(409,
                    $"Lease fencing violation: requested leaseOwner '{request.LeaseOwner}' does not match active lease owner");
            }

            if (txJob.LeaseUntil is null || txJob.LeaseUntil < DateTime.UtcNow)
            {
                throw new CheckpointValidationException(409, "Lease has expired; worker must renew before writing");
            }

            // Persist draft artifact WITHOUT touching ReadingPaperArtifactHeads!
            var entity = new ReadingPaperArtifact
            {
                Id = Guid.NewGuid(),
                RunId = request.RunId,
                ArtifactId = request.Artifact.ArtifactId,
                Version = request.Artifact.Version,
                ArtifactType = request.Artifact.ArtifactType.ToString(),
                ContentHash = request.Artifact.ContentHash,
                PayloadJson = request.Artifact.Payload.GetRawText(),
                ParentRefsJson = JsonSerializer.Serialize(request.Artifact.ParentRefs, LoopEngineJson.Options),
                ProducerVersion = request.Artifact.ProducerVersion,
                EnvelopeJson = JsonSerializer.Serialize(request.Artifact, LoopEngineJson.Options),
                CreatedAt = DateTime.UtcNow
            };
            db.ReadingPaperArtifacts.Add(entity);

            foreach (var parent in request.Artifact.ParentRefs)
            {
                var depExists = await db.ReadingPaperArtifactDependencies.AnyAsync(
                    d => d.RunId == request.RunId && d.ArtifactId == request.Artifact.ArtifactId &&
                         d.Version == request.Artifact.Version && d.ParentArtifactId == parent.ArtifactId, ct);
                if (!depExists)
                {
                    db.ReadingPaperArtifactDependencies.Add(new ReadingPaperArtifactDependency
                    {
                        Id = Guid.NewGuid(),
                        RunId = request.RunId,
                        ArtifactId = request.Artifact.ArtifactId,
                        Version = request.Artifact.Version,
                        ParentArtifactId = parent.ArtifactId,
                        ParentVersion = parent.Version,
                        ParentContentHash = parent.ContentHash
                    });
                }
            }
            // Update operation status & usage
            var opEntity = await db.ReadingPaperOperations.FirstAsync(
                o => o.RunId == request.RunId && o.OperationId == request.OperationId, ct);
            opEntity.Status = "COMPLETED";
            opEntity.TokensUsed = request.TokensUsed;
            opEntity.WallTimeUsedSeconds = request.WallTimeUsedSeconds;
            opEntity.ResultRefJson = JsonSerializer.Serialize(request.Artifact.ToRef(), LoopEngineJson.Options);
            opEntity.UpdatedAt = DateTime.UtcNow;

            await db.SaveChangesAsync(ct);
            await tx.CommitAsync(ct);

            return new CheckpointAck(
                request.RunId,
                request.Epoch,
                request.Artifact.ArtifactId,
                request.Artifact.Version,
                request.Artifact.ContentHash,
                entity.CreatedAt,
                IsReplay: false
            );
        });
    }
    public static async Task<UnknownOutcomeAck> RecordUnknownOutcomeAsync(
        ExamDbContext db,
        UnknownOutcomeRequest request,
        CancellationToken ct)
    {
        await ValidateRunAuthorityAndFencingAsync(db, request.RunId, request.Epoch, request.LeaseOwner, ct);

        var op = await db.ReadingPaperOperations.FirstOrDefaultAsync(
            o => o.RunId == request.RunId && o.OperationId == request.OperationId, ct);

        if (op == null)
            throw new CheckpointValidationException(404, $"Operation '{request.OperationId}' not found");

        op.Status = "UNKNOWN_OUTCOME";
        op.ErrorMessage = request.ErrorMessage;
        op.UpdatedAt = DateTime.UtcNow;

        await db.SaveChangesAsync(ct);

        return new UnknownOutcomeAck(
            op.OperationId,
            "UNKNOWN_OUTCOME",
            ReservationPreserved: true,
            DateTime.UtcNow
        );
    }

    public static async Task<ResumeStateResult> ResumeStateAsync(
        ExamDbContext db,
        string runId,
        CancellationToken ct)
    {
        var run = await db.ReadingPaperRuns
            .Include(r => r.Job)
            .FirstOrDefaultAsync(r => r.RunId == runId, ct);

        if (run == null)
            throw new CheckpointValidationException(404, $"Run '{runId}' not found");

        // Engine & Schema Compatibility check
        if (!string.Equals(run.EngineVersion, "2.0.0", StringComparison.Ordinal) ||
            !string.Equals(run.SchemaVersion, "2.0.0", StringComparison.Ordinal) ||
            !string.Equals(run.PolicyVersion, "2.0.0", StringComparison.Ordinal))
        {
            return new ResumeStateResult(
                run.RunId,
                run.JobId,
                run.Epoch,
                run.Status,
                run.EngineVersion,
                run.SchemaVersion,
                run.PolicyVersion,
                Artifacts: [],
                IsCompatible: false,
                IncompatibilityReason: $"Incompatible versions: engine={run.EngineVersion}, schema={run.SchemaVersion}, policy={run.PolicyVersion}"
            );
        }

        var heads = await db.ReadingPaperArtifactHeads
            .Where(h => h.RunId == runId)
            .ToListAsync(ct);

        var artifacts = new List<ArtifactResumeInfo>();
        var headMap = heads.ToDictionary(h => h.ArtifactId, h => h);

        foreach (var head in heads)
        {
            var art = await db.ReadingPaperArtifacts.FirstOrDefaultAsync(
                a => a.RunId == runId && a.ArtifactId == head.ArtifactId && a.Version == head.AcceptedVersion, ct);

            if (art == null)
            {
                throw new CheckpointValidationException(409,
                    $"Corrupted checkpoint: head points to missing artifact '{head.ArtifactId}' version {head.AcceptedVersion}");
            }

            // Cryptographic tamper check
            if (!string.Equals(art.ContentHash, head.AcceptedHash, StringComparison.OrdinalIgnoreCase))
            {
                throw new CheckpointValidationException(409,
                    $"Tampered checkpoint detected: artifact '{head.ArtifactId}' version {head.AcceptedVersion} hash '{art.ContentHash}' != head hash '{head.AcceptedHash}'");
            }

            var parentRefs = JsonSerializer.Deserialize<List<ArtifactRef>>(art.ParentRefsJson, LoopEngineJson.Options) ?? [];

            // Stale check against current heads
            var isStale = false;
            foreach (var parent in parentRefs)
            {
                if (!headMap.TryGetValue(parent.ArtifactId, out var parentHead) ||
                    parentHead.AcceptedVersion != parent.Version ||
                    !string.Equals(parentHead.AcceptedHash, parent.ContentHash, StringComparison.OrdinalIgnoreCase))
                {
                    isStale = true;
                    break;
                }
            }

            artifacts.Add(new ArtifactResumeInfo(
                head.ArtifactId,
                art.ArtifactType,
                head.AcceptedVersion,
                head.AcceptedHash,
                art.PayloadJson,
                parentRefs,
                isStale,
                art.EnvelopeJson
            ));
        }

        var ops = await db.ReadingPaperOperations
            .Where(o => o.RunId == runId)
            .ToListAsync(ct);
        var workOps = ops.Where(o => o.OperationType != "CHECKPOINT_COMMIT").ToList();
        var totalTokens = workOps.Sum(o => o.Status == "COMPLETED" ? o.TokensUsed : o.TokenReservation);
        var totalWallTime = workOps.Sum(o => o.Status == "COMPLETED" ? o.WallTimeUsedSeconds : o.WallTimeReservationSeconds);
        var totalCalls = workOps.Count(o => o.ParentOperationId == null);

        // Also collect unaccepted draft artifacts
        var allArts = await db.ReadingPaperArtifacts
            .Where(a => a.RunId == runId)
            .ToListAsync(ct);
        var draftArtifacts = new List<ArtifactResumeInfo>();
        foreach (var art in allArts)
        {
            var isAccepted = headMap.TryGetValue(art.ArtifactId, out var h) && h.AcceptedVersion == art.Version;
            if (!isAccepted)
            {
                var parentRefs = JsonSerializer.Deserialize<List<ArtifactRef>>(art.ParentRefsJson, LoopEngineJson.Options) ?? [];
                draftArtifacts.Add(new ArtifactResumeInfo(
                    art.ArtifactId,
                    art.ArtifactType,
                    art.Version,
                    art.ContentHash,
                    art.PayloadJson,
                    parentRefs,
                    IsStale: parentRefs.Any(p => !headMap.TryGetValue(p.ArtifactId, out var parent) ||
                        parent.AcceptedVersion != p.Version || parent.AcceptedHash != p.ContentHash),
                    EnvelopeJson: art.EnvelopeJson
                ));
            }
        }
        var evals = await db.ReadingPaperEvaluations
            .Where(e => e.RunId == runId)
            .ToListAsync(ct);

        var issueEntities = await db.ReadingPaperIssues
            .Where(i => i.RunId == runId)
            .ToListAsync(ct);
        var statusMap = issueEntities.ToDictionary(i => i.Fingerprint, i => Enum.Parse<IssueStatus>(i.Status));

        var issues = new List<Issue>();
        var seenFingerprints = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

        // Rehydrate complete issues and evaluations from evaluation payloads
        var evalResults = new List<EvaluationResult>();
        foreach (var eval in evals)
        {
            if (!string.IsNullOrWhiteSpace(eval.PayloadJson))
            {
                try
                {
                    var evalResult = JsonSerializer.Deserialize<EvaluationResult>(eval.PayloadJson, LoopEngineJson.Options)
                        ?? throw new JsonException("Empty stored evaluation");
                    {
                        evalResults.Add(evalResult);
                        if (evalResult.Issues is { Count: > 0 })
                        {
                            foreach (var iss in evalResult.Issues)
                            {
                                if (seenFingerprints.Add(iss.Fingerprint))
                                {
                                    var currentStatus = statusMap.TryGetValue(iss.Fingerprint, out var s) ? s : iss.Status;
                                    var rehydrated = iss with
                                    {
                                        Status = currentStatus,
                                        EvaluatorId = iss.EvaluatorId ?? eval.EvaluatorId
                                    };
                                    issues.Add(rehydrated);
                                }
                            }
                        }
                    }
                }
                catch (JsonException ex)
                {
                    throw new CheckpointValidationException(409, $"Corrupt evaluation '{eval.EvaluationId}': {ex.Message}");
                }
            }
        }
        // Fallback for any standalone issues recorded directly in table
        foreach (var ie in issueEntities)
        {
            if (seenFingerprints.Add(ie.Fingerprint))
            {
                issues.Add(new Issue(
                    ie.IssueId,
                    Enum.Parse<IssueCode>(ie.Code),
                    Enum.Parse<IssueSeverity>(ie.Severity),
                    Enum.Parse<IssueScope>(ie.Scope),
                    new List<ArtifactRef>(),
                    ie.Message,
                    null,
                    null,
                    Enum.Parse<IssueStatus>(ie.Status),
                    ie.Fingerprint,
                    ie.CreatedAt,
                    null,
                    null
                ));
            }
        }

        return new ResumeStateResult(
            run.RunId,
            run.JobId,
            run.Epoch,
            run.Status,
            run.EngineVersion,
            run.SchemaVersion,
            run.PolicyVersion,
            artifacts,
            IsCompatible: true,
            IncompatibilityReason: null,
            TokensUsed: totalTokens,
            CallsUsed: totalCalls,
            WallTimeUsedSeconds: totalWallTime,
            DraftArtifacts: draftArtifacts,
            Issues: issues,
            Evaluations: evalResults,
            LoopCursors: await db.ReadingPaperLoopCursors.Where(c => c.RunId == runId)
                .Select(c => new LoopCursorCheckpoint(c.ArtifactId, c.Revision, c.StateJson, c.LastOperationId)).ToListAsync(ct),
            Operations: ops.Select(o => new OperationResumeInfo(o.OperationId, o.OperationType, o.Status,
                o.ArtifactId, o.RequestHash, o.TokenReservation, o.TokensUsed,
                o.WallTimeReservationSeconds, o.WallTimeUsedSeconds, o.ResultRefJson)).ToList()
        );
    }

    public static async Task<InvalidateDependencyResult> InvalidateDependencyClosureAsync(
        ExamDbContext db,
        InvalidateDependencyRequest request,
        CancellationToken ct)
    {
        await ValidateRunAuthorityAndFencingAsync(db, request.RunId, request.Epoch, request.LeaseOwner, ct);

        // Fetch all dependencies for this run
        var allDeps = await db.ReadingPaperArtifactDependencies
            .Where(d => d.RunId == request.RunId)
            .ToListAsync(ct);

        // Build adjacency list: Parent -> Children
        var childrenMap = new Dictionary<string, HashSet<string>>(StringComparer.OrdinalIgnoreCase);
        foreach (var dep in allDeps)
        {
            if (!childrenMap.ContainsKey(dep.ParentArtifactId))
                childrenMap[dep.ParentArtifactId] = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            childrenMap[dep.ParentArtifactId].Add(dep.ArtifactId);
        }

        // BFS / DFS to find full downstream closure
        var invalidated = new HashSet<string>(StringComparer.OrdinalIgnoreCase) { request.TargetArtifactId };
        var queue = new Queue<string>();
        queue.Enqueue(request.TargetArtifactId);

        while (queue.Count > 0)
        {
            var current = queue.Dequeue();
            if (childrenMap.TryGetValue(current, out var children))
            {
                foreach (var child in children)
                {
                    if (invalidated.Add(child))
                    {
                        queue.Enqueue(child);
                    }
                }
            }
        }

        // Remove accepted heads for invalidated artifacts
        var heads = await db.ReadingPaperArtifactHeads
            .Where(h => h.RunId == request.RunId)
            .ToListAsync(ct);

        var preserved = new List<string>();
        foreach (var head in heads)
        {
            if (invalidated.Contains(head.ArtifactId))
            {
                db.ReadingPaperArtifactHeads.Remove(head);
            }
            else
            {
                preserved.Add(head.ArtifactId);
            }
        }

        await db.SaveChangesAsync(ct);

        return new InvalidateDependencyResult(
            request.RunId,
            invalidated.ToList(),
            preserved
        );
    }

    public static async Task<BuildExamInternalResult> BuildExamIdempotentAsync(
        ExamDbContext db,
        BuildExamInternalRequest request,
        CancellationToken ct,
        Func<Task>? onBeforeTransaction = null)
    {
        var (run, job) = await ValidateRunAuthorityAndFencingAsync(db, request.RunId, request.Epoch, request.LeaseOwner, ct);

        // Pre-transaction read-only idempotency check (zero mutations outside transaction):
        if (job.ExamId != null && string.Equals(job.Status, "Completed", StringComparison.OrdinalIgnoreCase))
        {
            var existingExam = await db.Exams.AsNoTracking().FirstOrDefaultAsync(e => e.Id == job.ExamId.Value, ct);
            if (existingExam != null)
            {
                return new BuildExamInternalResult(existingExam.Id, existingExam.Slug, IsExisting: true);
            }
        }

        var expectedSlug = $"reading-{job.Id:N}";
        // Deserialize and validate sections
        var sections = JsonSerializer.Deserialize<List<ReadingGeneratedSection>>(job.SectionsJson, ReadingPaperRules.Json) ?? [];
        if (sections.Count == 0)
            throw new InvalidOperationException("No completed sections found to build exam");

        var exam = ReadingPaperWorker.BuildExam(job, sections);

        // Optional fault-injection hook before opening transaction
        if (onBeforeTransaction != null)
        {
            await onBeforeTransaction();
        }

        var strategy = db.Database.CreateExecutionStrategy();
        return await strategy.ExecuteAsync(async () =>
        {
            db.ChangeTracker.Clear();
            await using var tx = await db.Database.BeginTransactionAsync(ct);

            // Worker takeover claims this same job row with a conditional UPDATE. This job-row CAS is
            // the serialization point: require matching epoch/owner, an unexpired lease, Running
            // (non-cancelled) status, and unchanged cancel version before any exam graph writes.
            var fencedJobRows = await db.ReadingPaperJobs
                .Where(j => j.Id == job.Id && j.Epoch == request.Epoch && j.LeaseOwner == request.LeaseOwner && j.Status == "Running" && j.LeaseUntil > DateTime.UtcNow && j.CancelVersion == job.CancelVersion)
                .ExecuteUpdateAsync(s => s
                    .SetProperty(j => j.Status, "Completed")
                    .SetProperty(j => j.UpdatedAt, DateTime.UtcNow), ct);

            if (fencedJobRows != 1)
            {
                // Recheck if an earlier commit already completed it
                var recheckedJob = await db.ReadingPaperJobs.AsNoTracking().FirstOrDefaultAsync(j => j.Id == job.Id, ct);
                if (recheckedJob != null && recheckedJob.ExamId != null && string.Equals(recheckedJob.Status, "Completed", StringComparison.OrdinalIgnoreCase))
                {
                    var existingExam = await db.Exams.AsNoTracking().FirstOrDefaultAsync(e => e.Id == recheckedJob.ExamId.Value, ct);
                    if (existingExam != null)
                    {
                        return new BuildExamInternalResult(existingExam.Id, existingExam.Slug, IsExisting: true);
                    }
                }

                throw new CheckpointValidationException(409,
                    $"Epoch fencing violation: atomic conditional lock failed during final exam build for job '{job.Id}' (stale epoch {request.Epoch}, lease owner mismatch, cancelled, or lease expired)");
            }

            // 2. In-transaction atomic conditional lock on run:
            var fencedRunRows = await db.ReadingPaperRuns
                .Where(r => r.RunId == request.RunId && r.Epoch == request.Epoch && r.LeaseOwner == request.LeaseOwner && r.Status == "RUNNING" && r.CancelVersion == job.CancelVersion)
                .ExecuteUpdateAsync(s => s
                    .SetProperty(r => r.Status, "COMPLETED")
                    .SetProperty(r => r.UpdatedAt, DateTime.UtcNow), ct);

            if (fencedRunRows != 1)
            {
                throw new CheckpointValidationException(409,
                    $"Epoch fencing violation: atomic conditional lock failed for run '{request.RunId}' in final exam build");
            }

            // 3. Atomically check slug in transaction
            var existingSlug = await db.Exams.AsNoTracking().FirstOrDefaultAsync(e => e.Slug == expectedSlug, ct);
            if (existingSlug != null)
            {
                await db.ReadingPaperJobs.Where(j => j.Id == job.Id).ExecuteUpdateAsync(s => s.SetProperty(j => j.ExamId, existingSlug.Id), ct);
                await tx.CommitAsync(ct);
                return new BuildExamInternalResult(existingSlug.Id, existingSlug.Slug, IsExisting: true);
            }

            // 4. Save Exam & Link to Job atomically
            db.Exams.Add(exam);
            await db.ReadingPaperJobs.Where(j => j.Id == job.Id).ExecuteUpdateAsync(s => s.SetProperty(j => j.ExamId, exam.Id), ct);

            await db.SaveChangesAsync(ct);
            await tx.CommitAsync(ct);

            return new BuildExamInternalResult(exam.Id, exam.Slug, IsExisting: false);
        });
    }

    private static void SyncSectionToLegacyJob(ReadingPaperJob job, ArtifactEnvelope sectionEnvelope)
    {
        try
        {
            var sectionDto = JsonSerializer.Deserialize<ReadingGeneratedSection>(sectionEnvelope.Payload.GetRawText(), ReadingPaperRules.Json);
            if (sectionDto == null) return;

            var existingSections = JsonSerializer.Deserialize<List<ReadingGeneratedSection>>(job.SectionsJson, ReadingPaperRules.Json) ?? [];
            var existingIndex = existingSections.FindIndex(s =>
                string.Equals(s.Source.Pmcid, sectionDto.Source.Pmcid, StringComparison.OrdinalIgnoreCase) ||
                string.Equals(s.Title, sectionDto.Title, StringComparison.OrdinalIgnoreCase));

            if (existingIndex >= 0)
            {
                existingSections[existingIndex] = sectionDto;
            }
            else
            {
                existingSections.Add(sectionDto);
            }

            job.SectionsJson = JsonSerializer.Serialize(existingSections, ReadingPaperRules.Json);
            job.CompletedSections = existingSections.Count;
            job.UpdatedAt = DateTime.UtcNow;
        }
        catch
        {
            // If cannot deserialize to legacy format, do not block the V2 commit
        }
    }
}
