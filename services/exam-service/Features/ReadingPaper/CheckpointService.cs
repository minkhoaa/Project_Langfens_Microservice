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

    /// <summary>
    /// True when the operation type represents an external provider invocation that consumes run-level
    /// budget tokens/calls/wall-time. Unifies historical <c>PROVIDER_CALL</c> with the V2 LLM-prefixed
    /// intents (<c>LLM</c>, <c>LLM_CALL</c>, <c>LLM_PASSAGE</c>) so all real provider attempts atomically
    /// enforce run / section / artifact budget caps regardless of naming era.
    /// </summary>
    public static bool IsProviderCallType(string? operationType)
    {
        if (string.IsNullOrWhiteSpace(operationType)) return false;
        return operationType.Equals("PROVIDER_CALL", StringComparison.OrdinalIgnoreCase)
            || operationType.Equals("LLM_CALL", StringComparison.OrdinalIgnoreCase)
            || operationType.Equals("LLM", StringComparison.OrdinalIgnoreCase)
            || operationType.Equals("LLM_PASSAGE", StringComparison.OrdinalIgnoreCase);
    }

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

        // 1. Epoch fencing check
        if (run.Epoch != epoch || job.Epoch != epoch)
        {
            throw new CheckpointValidationException(409,
                $"Epoch fencing violation: requested epoch {epoch} does not match authoritative epoch (run: {run.Epoch}, job: {job.Epoch})");
        }

        // 2. Lease ownership check
        if (run.LeaseOwner != leaseOwner || job.LeaseOwner != leaseOwner)
        {
            throw new CheckpointValidationException(409,
                $"Lease fencing violation: requested leaseOwner '{leaseOwner}' does not match active lease owner");
        }

        // 3. Cancellation check, after authority checks so stale workers are identified as fenced.
        if (string.Equals(job.Status, "Cancelled", StringComparison.OrdinalIgnoreCase) ||
            string.Equals(run.Status, "CANCELLED", StringComparison.OrdinalIgnoreCase) ||
            job.CancelVersion != run.CancelVersion)
        {
            throw new CheckpointValidationException(409, "Run or Job has been cancelled; late operations rejected fail-closed");
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
        if (run.BudgetCapTokens > 0 && sectionTotalTokens > run.BudgetCapTokens)
        {
            throw new CheckpointValidationException(422,
                $"Invalid budget allocation hierarchy: sum of section token caps ({sectionTotalTokens}) exceeds run budget cap ({run.BudgetCapTokens})");
        }

        var sectionTotalCalls = sections.Sum(a => a.CallCap);
        if (run.BudgetCapCalls > 0 && sectionTotalCalls > run.BudgetCapCalls)
        {
            throw new CheckpointValidationException(422,
                $"Invalid budget allocation hierarchy: sum of section call caps ({sectionTotalCalls}) exceeds run budget cap ({run.BudgetCapCalls})");
        }

        var sectionTotalWallTime = sections.Sum(a => a.WallTimeCapSeconds);
        if (run.BudgetCapWallTimeSeconds > 0 && sectionTotalWallTime > run.BudgetCapWallTimeSeconds)
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
            if (parentSec.TokenCap > 0 && childTokensSum > parentSec.TokenCap)
            {
                throw new CheckpointValidationException(422,
                    $"Invalid budget allocation hierarchy: sum of artifact token caps ({childTokensSum}) for section '{group.Key}' exceeds parent section cap ({parentSec.TokenCap})");
            }

            var childCallsSum = group.Sum(a => a.CallCap);
            if (parentSec.CallCap > 0 && childCallsSum > parentSec.CallCap)
            {
                throw new CheckpointValidationException(422,
                    $"Invalid budget allocation hierarchy: sum of artifact call caps ({childCallsSum}) for section '{group.Key}' exceeds parent section cap ({parentSec.CallCap})");
            }

            var childWallTimeSum = group.Sum(a => a.WallTimeCapSeconds);
            if (parentSec.WallTimeCapSeconds > 0 && childWallTimeSum > parentSec.WallTimeCapSeconds)
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
        if (await db.ReadingPaperBudgetAllocations.AnyAsync(b => b.RunId == run.RunId, ct)) return;

        using var document = JsonDocument.Parse(string.IsNullOrWhiteSpace(run.BudgetProfileJson) ? "{}" : run.BudgetProfileJson);
        var profileCaps = document.RootElement.TryGetProperty("caps", out var capsElement) && capsElement.ValueKind == JsonValueKind.Object
            ? capsElement
            : default;
        var profileName = string.IsNullOrWhiteSpace(run.BenchmarkCampaignId) ? "legacy" : "benchmark";
        int Cap(string suffix, int fallback)
        {
            var key = $"{profileName}{suffix}";
            if (profileCaps.ValueKind == JsonValueKind.Object)
            {
                if (profileCaps.TryGetProperty(key, out var value) && value.TryGetInt32(out var cap))
                    return cap;
                if (profileCaps.TryGetProperty(suffix, out var directValue) && directValue.TryGetInt32(out var directCap))
                    return directCap;
            }
            return fallback;
        }

        var isUnlimitedRun = run.BudgetCapCalls == ReadingPaperCapsProfile.UnlimitedCap ||
                             run.BudgetCapTokens == ReadingPaperCapsProfile.UnlimitedCap ||
                             run.BudgetCapWallTimeSeconds == ReadingPaperCapsProfile.UnlimitedCap ||
                             run.BudgetCapCalls >= 2_000_000_000 ||
                             run.BudgetCapTokens >= 2_000_000_000 ||
                             (run.BudgetProfileJson != null &&
                              run.BudgetProfileJson.Contains("\"UNLIMITED\"", StringComparison.OrdinalIgnoreCase));
        var sectionTokens = isUnlimitedRun ? ReadingPaperCapsProfile.UnlimitedCap : Math.Max(Cap("SectionTokenCap", 60000), 60000);
        var sectionCalls = isUnlimitedRun ? ReadingPaperCapsProfile.UnlimitedCap : Math.Max(Cap("SectionCallCap", 12), 12);
        var sectionWall = isUnlimitedRun ? ReadingPaperCapsProfile.UnlimitedCap : Math.Max(Cap("SectionWallTimeCapSeconds", 360), 360);
        var artifactCaps = new[]
        {
            (Name: "passage",
             Tokens: isUnlimitedRun ? ReadingPaperCapsProfile.UnlimitedCap : Cap("ArtifactPassageTokenCap", 80000),
             Calls: isUnlimitedRun ? ReadingPaperCapsProfile.UnlimitedCap : Cap("ArtifactPassageCallCap", 10),
             Wall: isUnlimitedRun ? ReadingPaperCapsProfile.UnlimitedCap : Cap("ArtifactPassageWallTimeCapSeconds", 200)),
            (Name: "questions",
             Tokens: isUnlimitedRun ? ReadingPaperCapsProfile.UnlimitedCap : Cap("ArtifactQuestionsTokenCap", 200000),
             Calls: isUnlimitedRun ? ReadingPaperCapsProfile.UnlimitedCap : Cap("ArtifactQuestionsCallCap", 50),
             Wall: isUnlimitedRun ? ReadingPaperCapsProfile.UnlimitedCap : Cap("ArtifactQuestionsWallTimeCapSeconds", 400)),
            (Name: "solver",
             Tokens: isUnlimitedRun ? ReadingPaperCapsProfile.UnlimitedCap : Cap("ArtifactSolverTokenCap", 50000),
             Calls: isUnlimitedRun ? ReadingPaperCapsProfile.UnlimitedCap : Cap("ArtifactSolverCallCap", 6),
             Wall: isUnlimitedRun ? ReadingPaperCapsProfile.UnlimitedCap : Cap("ArtifactSolverWallTimeCapSeconds", 150)),
            (Name: "review",
             Tokens: isUnlimitedRun ? ReadingPaperCapsProfile.UnlimitedCap : Cap("ArtifactReviewTokenCap", 50000),
             Calls: isUnlimitedRun ? ReadingPaperCapsProfile.UnlimitedCap : Cap("ArtifactReviewCallCap", 6),
             Wall: isUnlimitedRun ? ReadingPaperCapsProfile.UnlimitedCap : Cap("ArtifactReviewWallTimeCapSeconds", 150))
        };

        foreach (var sectionId in new[] { "section_1", "section_2", "section_3" })
        {
            db.ReadingPaperBudgetAllocations.Add(new ReadingPaperBudgetAllocation
            {
                Id = Guid.NewGuid(),
                RunId = run.RunId,
                ScopeType = "SECTION",
                ScopeId = sectionId,
                ParentScopeId = null,
                TokenCap = sectionTokens,
                CallCap = sectionCalls,
                WallTimeCapSeconds = sectionWall,
                CreatedAt = DateTime.UtcNow
            });
            foreach (var artifact in artifactCaps)
            {
                db.ReadingPaperBudgetAllocations.Add(new ReadingPaperBudgetAllocation
                {
                    Id = Guid.NewGuid(),
                    RunId = run.RunId,
                    ScopeType = "ARTIFACT",
                    ScopeId = $"{artifact.Name}_{sectionId}",
                    ParentScopeId = sectionId,
                    TokenCap = artifact.Tokens,
                    CallCap = artifact.Calls,
                    WallTimeCapSeconds = artifact.Wall,
                    CreatedAt = DateTime.UtcNow
                });
            }
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
            var isUnlimitedRun = run.BudgetCapCalls == ReadingPaperCapsProfile.UnlimitedCap ||
                                 run.BudgetCapTokens == ReadingPaperCapsProfile.UnlimitedCap ||
                                 run.BudgetCapWallTimeSeconds == ReadingPaperCapsProfile.UnlimitedCap ||
                                 (run.BudgetCapCalls <= 0 && run.BudgetCapTokens <= 0 && run.BudgetCapWallTimeSeconds <= 0) ||
                                 (run.BudgetProfileJson != null &&
                                  run.BudgetProfileJson.Contains("\"benchmarkMode\":\"UNLIMITED\"", StringComparison.OrdinalIgnoreCase) &&
                                  run.BudgetProfileJson.Contains("\"benchmarkMonetaryCapMode\":\"UNLIMITED\"", StringComparison.OrdinalIgnoreCase));

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
                    IsReplay: true,
                    ResultRefJson: existing.ResultRefJson,
                    ReservationBreached: existing.ReservationBreached,
                    BudgetBreachDetected: existing.ReservationBreached
                );
            }

            if (IsProviderCallType(request.OperationType) &&
                (!ReadingPaperCapsProfile.MatchesRunBudget(
                    run.BudgetProfileJson, run.BudgetProfileSha256,
                    !string.IsNullOrWhiteSpace(run.BenchmarkCampaignId) || isUnlimitedRun,
                    run.BudgetCapCalls, run.BudgetCapTokens, run.BudgetCapWallTimeSeconds) ||
                 string.Equals(run.BudgetProfileVersion, "legacy-unpinned", StringComparison.OrdinalIgnoreCase) ||
                 string.IsNullOrWhiteSpace(run.BudgetProfileSource)))
                throw new CheckpointValidationException(409, "Run has no valid pinned budget profile; provider dispatch is paused for compatibility review");

            // 2b. Hard execution deadline enforcement: CreatedAt + BudgetCapWallTimeSeconds
            if (!isUnlimitedRun && run.BudgetCapWallTimeSeconds > 0 && run.BudgetCapWallTimeSeconds != ReadingPaperCapsProfile.UnlimitedCap)
            {
                var hardDeadline = run.CreatedAt.AddSeconds(run.BudgetCapWallTimeSeconds);
                if (DateTime.UtcNow > hardDeadline)
                {
                    throw new CheckpointValidationException(422,
                        $"Execution deadline exhausted: hard deadline {hardDeadline:O} elapsed in the past");
                }
                if (run.BudgetUsedWallTimeSeconds + request.WallTimeReservationSeconds > run.BudgetCapWallTimeSeconds)
                {
                    throw new CheckpointValidationException(422,
                        $"Budget exhausted: wall time cap ({run.BudgetCapWallTimeSeconds}s) would be exceeded by reservation {request.WallTimeReservationSeconds}s (current used: {run.BudgetUsedWallTimeSeconds:F1}s)");
                }
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
                    .SumAsync(o => o.Status == "COMPLETED"
                        ? ((o.AccountingType == "REPORTED" || o.AccountingType == "reported" || o.AccountingType == "RECONCILED" || o.AccountingType == "reconciled") ? o.TokensUsed : Math.Max(o.TokensUsed, o.TokenReservation))
                        : o.TokenReservation, ct);

                if (!isUnlimitedRun && run.BudgetCapTokens > 0 && run.BudgetCapTokens != ReadingPaperCapsProfile.UnlimitedCap &&
                    parentOp.TokenReservation > 0 && parentOp.TokenReservation != ReadingPaperCapsProfile.UnlimitedCap &&
                    currentChildTokens + request.TokenReservation > parentOp.TokenReservation)
                {
                    throw new CheckpointValidationException(422,
                        $"Parent operation reservation exceeded: parent '{parentOp.OperationId}' token reservation ({parentOp.TokenReservation}) would be exceeded by child reservation {request.TokenReservation} (current child allocated: {currentChildTokens})");
                }

                var currentChildWallTime = await db.ReadingPaperOperations
                    .Where(o => o.RunId == request.RunId && o.ParentOperationId == request.ParentOperationId &&
                                (o.Status == "RESERVED" || o.Status == "COMPLETED" || o.Status == "UNKNOWN_OUTCOME"))
                    .SumAsync(o => o.Status == "COMPLETED" ? o.WallTimeUsedSeconds : o.WallTimeReservationSeconds, ct);

                if (!isUnlimitedRun && run.BudgetCapWallTimeSeconds > 0 && run.BudgetCapWallTimeSeconds != ReadingPaperCapsProfile.UnlimitedCap &&
                    parentOp.WallTimeReservationSeconds > 0 && parentOp.WallTimeReservationSeconds != ReadingPaperCapsProfile.UnlimitedCap &&
                    currentChildWallTime + request.WallTimeReservationSeconds > parentOp.WallTimeReservationSeconds)
                {
                    throw new CheckpointValidationException(422,
                        $"Parent operation reservation exceeded: parent '{parentOp.OperationId}' wall-time reservation ({parentOp.WallTimeReservationSeconds}s) would be exceeded by child reservation {request.WallTimeReservationSeconds}s (current child allocated: {currentChildWallTime:F1}s)");
                }
            }

            if (IsProviderCallType(request.OperationType))
            {
                if (run.BenchmarkCampaignId is { Length: > 0 } campaignId)
                {
                    var reservedCampaignRows = await db.ReadingPaperBenchmarkCampaigns
                        .Where(c => c.CampaignId == campaignId && c.Status == "AUTHORIZED" && !c.BudgetBreachDetected &&
                                    (c.BudgetCapCalls <= 0 || c.BudgetUsedCalls + 1 <= c.BudgetCapCalls) &&
                                    (c.BudgetCapTokens <= 0 || c.BudgetUsedTokens + request.TokenReservation <= c.BudgetCapTokens) &&
                                    (c.BudgetCapWallTimeSeconds <= 0 || c.BudgetUsedWallTimeSeconds + request.WallTimeReservationSeconds <= c.BudgetCapWallTimeSeconds))
                        .ExecuteUpdateAsync(s => s
                            .SetProperty(c => c.BudgetUsedCalls, c => c.BudgetUsedCalls + 1)
                            .SetProperty(c => c.BudgetUsedTokens, c => c.BudgetUsedTokens + request.TokenReservation)
                            .SetProperty(c => c.BudgetUsedWallTimeSeconds, c => c.BudgetUsedWallTimeSeconds + request.WallTimeReservationSeconds)
                            .SetProperty(c => c.UpdatedAt, DateTime.UtcNow), ct);

                    if (reservedCampaignRows != 1)
                    {
                        var currentCampaign = await db.ReadingPaperBenchmarkCampaigns.AsNoTracking()
                            .FirstOrDefaultAsync(c => c.CampaignId == campaignId, ct);
                        if (currentCampaign == null)
                            throw new CheckpointValidationException(409, "Campaign accounting record is missing for this child run");
                        if (currentCampaign.BudgetBreachDetected)
                            throw new CheckpointValidationException(422, $"Campaign budget is blocked after a recorded breach: {currentCampaign.BudgetBreachReason}");
                        if (currentCampaign.BudgetCapCalls > 0 && currentCampaign.BudgetUsedCalls + 1 > currentCampaign.BudgetCapCalls)
                            throw new CheckpointValidationException(422, $"Campaign budget exhausted: maximum calls ({currentCampaign.BudgetCapCalls}) exceeded");
                        if (currentCampaign.BudgetCapTokens > 0 && currentCampaign.BudgetUsedTokens + request.TokenReservation > currentCampaign.BudgetCapTokens)
                            throw new CheckpointValidationException(422, $"Campaign budget exhausted: token cap ({currentCampaign.BudgetCapTokens}) would be exceeded by reservation {request.TokenReservation}");
                        if (currentCampaign.BudgetCapWallTimeSeconds > 0 && currentCampaign.BudgetUsedWallTimeSeconds + request.WallTimeReservationSeconds > currentCampaign.BudgetCapWallTimeSeconds)
                            throw new CheckpointValidationException(422, $"Campaign budget exhausted: wall-time cap ({currentCampaign.BudgetCapWallTimeSeconds:F1}s) would be exceeded by reservation {request.WallTimeReservationSeconds:F1}s");
                        throw new CheckpointValidationException(409, "Campaign authorization is no longer active");
                    }
                }

                // Each row is one physical provider attempt; logical parent intents are allocations, not calls.
                var reservedRunRows = await db.ReadingPaperRuns
                    .Where(r => r.RunId == request.RunId &&
                                r.Epoch == request.Epoch &&
                                r.LeaseOwner == request.LeaseOwner &&
                                r.Status == "RUNNING" &&
                                r.CancelVersion == job.CancelVersion &&
                                !r.BudgetBreachDetected &&
                                (r.BudgetCapCalls <= 0 || r.BudgetUsedCalls + 1 <= r.BudgetCapCalls) &&
                                (r.BudgetCapTokens <= 0 || r.BudgetUsedTokens + request.TokenReservation <= r.BudgetCapTokens) &&
                                (r.BudgetCapWallTimeSeconds <= 0 || r.BudgetUsedWallTimeSeconds + request.WallTimeReservationSeconds <= r.BudgetCapWallTimeSeconds))
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
                        if (currentRun.BudgetBreachDetected)
                            throw new CheckpointValidationException(422, $"Run budget is blocked after a recorded breach: {currentRun.BudgetBreachReason}");
                        if (currentRun.BudgetCapCalls > 0 && currentRun.BudgetUsedCalls + 1 > currentRun.BudgetCapCalls)
                            throw new CheckpointValidationException(422, $"Budget exhausted: maximum calls ({currentRun.BudgetCapCalls}) exceeded");
                        if (!isUnlimitedRun && currentRun.BudgetCapTokens > 0 && currentRun.BudgetCapTokens != ReadingPaperCapsProfile.UnlimitedCap && currentRun.BudgetUsedTokens + request.TokenReservation > currentRun.BudgetCapTokens)
                            throw new CheckpointValidationException(422, $"Budget exhausted: token cap ({currentRun.BudgetCapTokens}) would be exceeded by reservation {request.TokenReservation}");
                        if (!isUnlimitedRun && currentRun.BudgetCapWallTimeSeconds > 0 && currentRun.BudgetCapWallTimeSeconds != ReadingPaperCapsProfile.UnlimitedCap && currentRun.BudgetUsedWallTimeSeconds + request.WallTimeReservationSeconds > currentRun.BudgetCapWallTimeSeconds)
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
                if (IsProviderCallType(request.OperationType))
                {
                    var allocatedSectionTokens = await db.ReadingPaperOperations
                        .Where(o => o.RunId == request.RunId &&
                                    o.SectionId == sectionId &&
                                    (o.OperationType == "PROVIDER_CALL" || o.OperationType == "LLM" || o.OperationType == "LLM_CALL" || o.OperationType == "LLM_PASSAGE") &&
                                    (o.Status == "RESERVED" || o.Status == "COMPLETED" || o.Status == "UNKNOWN_OUTCOME"))
                        .SumAsync(o => o.Status == "COMPLETED"
                            ? ((o.AccountingType == "REPORTED" || o.AccountingType == "reported" || o.AccountingType == "RECONCILED" || o.AccountingType == "reconciled") ? o.TokensUsed : Math.Max(o.TokensUsed, o.TokenReservation))
                            : o.TokenReservation, ct);
                    if (!isUnlimitedRun && sectionAllocation.TokenCap > 0 && sectionAllocation.TokenCap != ReadingPaperCapsProfile.UnlimitedCap && allocatedSectionTokens + request.TokenReservation > sectionAllocation.TokenCap)
                        throw new CheckpointValidationException(422,
                            $"Section budget exhausted: section '{sectionId}' token cap ({sectionAllocation.TokenCap}) would be exceeded by reservation {request.TokenReservation} (current allocated: {allocatedSectionTokens})");

                    var allocatedSectionCalls = await db.ReadingPaperOperations
                        .Where(o => o.RunId == request.RunId && o.SectionId == sectionId &&
                                    (o.OperationType == "PROVIDER_CALL" || o.OperationType == "LLM" || o.OperationType == "LLM_CALL" || o.OperationType == "LLM_PASSAGE") &&
                                    (o.Status == "RESERVED" || o.Status == "COMPLETED" || o.Status == "UNKNOWN_OUTCOME"))
                        .CountAsync(ct);
                    if (!isUnlimitedRun && sectionAllocation.CallCap > 0 && sectionAllocation.CallCap != ReadingPaperCapsProfile.UnlimitedCap && allocatedSectionCalls + 1 > sectionAllocation.CallCap)
                        throw new CheckpointValidationException(422,
                            $"Section budget exhausted: section '{sectionId}' call cap ({sectionAllocation.CallCap}) would be exceeded");

                    var allocatedSectionWallTime = await db.ReadingPaperOperations
                        .Where(o => o.RunId == request.RunId && o.SectionId == sectionId &&
                                    (o.OperationType == "PROVIDER_CALL" || o.OperationType == "LLM" || o.OperationType == "LLM_CALL" || o.OperationType == "LLM_PASSAGE") &&
                                    (o.Status == "RESERVED" || o.Status == "COMPLETED" || o.Status == "UNKNOWN_OUTCOME"))
                        .SumAsync(o => o.Status == "COMPLETED" ? o.WallTimeUsedSeconds : o.WallTimeReservationSeconds, ct);
                    if (!isUnlimitedRun && sectionAllocation.WallTimeCapSeconds > 0 && sectionAllocation.WallTimeCapSeconds != ReadingPaperCapsProfile.UnlimitedCap && allocatedSectionWallTime + request.WallTimeReservationSeconds > sectionAllocation.WallTimeCapSeconds)
                        throw new CheckpointValidationException(422,
                            $"Section budget exhausted: section '{sectionId}' wall-time cap ({sectionAllocation.WallTimeCapSeconds}s) would be exceeded by reservation {request.WallTimeReservationSeconds}s (current allocated: {allocatedSectionWallTime:F1}s)");
                }
                // 3.2 Enforce Artifact-level budget allocation caps across all 3 dimensions if ArtifactId is specified
                if (!string.IsNullOrWhiteSpace(request.ArtifactId) &&
                    IsProviderCallType(request.OperationType))
                {
                    var artifactId = request.ArtifactId;
                    var artifactAllocation = await db.ReadingPaperBudgetAllocations
                        .FirstOrDefaultAsync(b => b.RunId == request.RunId && b.ScopeId == artifactId && b.ScopeType == "ARTIFACT", ct);
                    if (artifactAllocation == null)
                        throw new CheckpointValidationException(422, $"Artifact budget allocation for scope '{artifactId}' not found");
                    if (!string.Equals(artifactAllocation.ParentScopeId, sectionId, StringComparison.OrdinalIgnoreCase))
                        throw new CheckpointValidationException(422,
                            $"Artifact scope '{artifactId}' belongs to parent section '{artifactAllocation.ParentScopeId}', but request specified section '{sectionId}'");

                    var allocatedArtifactTokens = await db.ReadingPaperOperations
                        .Where(o => o.RunId == request.RunId && o.ArtifactId == artifactId &&
                                    (o.OperationType == "PROVIDER_CALL" || o.OperationType == "LLM" || o.OperationType == "LLM_CALL" || o.OperationType == "LLM_PASSAGE") &&
                                    (o.Status == "RESERVED" || o.Status == "COMPLETED" || o.Status == "UNKNOWN_OUTCOME"))
                        .SumAsync(o => o.Status == "COMPLETED"
                            ? ((o.AccountingType == "REPORTED" || o.AccountingType == "reported" || o.AccountingType == "RECONCILED" || o.AccountingType == "reconciled") ? o.TokensUsed : Math.Max(o.TokensUsed, o.TokenReservation))
                            : o.TokenReservation, ct);
                    if (!isUnlimitedRun && artifactAllocation.TokenCap > 0 && artifactAllocation.TokenCap != ReadingPaperCapsProfile.UnlimitedCap && allocatedArtifactTokens + request.TokenReservation > artifactAllocation.TokenCap)
                        throw new CheckpointValidationException(422,
                            $"Artifact budget exhausted: artifact '{artifactId}' token cap ({artifactAllocation.TokenCap}) would be exceeded by reservation {request.TokenReservation} (current allocated: {allocatedArtifactTokens})");

                    var allocatedArtifactCalls = await db.ReadingPaperOperations
                        .Where(o => o.RunId == request.RunId && o.ArtifactId == artifactId &&
                                    (o.OperationType == "PROVIDER_CALL" || o.OperationType == "LLM" || o.OperationType == "LLM_CALL" || o.OperationType == "LLM_PASSAGE") &&
                                    (o.Status == "RESERVED" || o.Status == "COMPLETED" || o.Status == "UNKNOWN_OUTCOME"))
                        .CountAsync(ct);
                    if (!isUnlimitedRun && artifactAllocation.CallCap > 0 && artifactAllocation.CallCap != ReadingPaperCapsProfile.UnlimitedCap && allocatedArtifactCalls + 1 > artifactAllocation.CallCap)
                        throw new CheckpointValidationException(422,
                            $"Artifact budget exhausted: artifact '{artifactId}' call cap ({artifactAllocation.CallCap}) would be exceeded");

                    var allocatedArtifactWallTime = await db.ReadingPaperOperations
                        .Where(o => o.RunId == request.RunId && o.ArtifactId == artifactId &&
                                    (o.OperationType == "PROVIDER_CALL" || o.OperationType == "LLM" || o.OperationType == "LLM_CALL" || o.OperationType == "LLM_PASSAGE") &&
                                    (o.Status == "RESERVED" || o.Status == "COMPLETED" || o.Status == "UNKNOWN_OUTCOME"))
                        .SumAsync(o => o.Status == "COMPLETED" ? o.WallTimeUsedSeconds : o.WallTimeReservationSeconds, ct);
                    if (!isUnlimitedRun && artifactAllocation.WallTimeCapSeconds > 0 && artifactAllocation.WallTimeCapSeconds != ReadingPaperCapsProfile.UnlimitedCap && allocatedArtifactWallTime + request.WallTimeReservationSeconds > artifactAllocation.WallTimeCapSeconds)
                        throw new CheckpointValidationException(422,
                            $"Artifact budget exhausted: artifact '{artifactId}' wall-time cap ({artifactAllocation.WallTimeCapSeconds}s) would be exceeded by reservation {request.WallTimeReservationSeconds}s (current allocated: {allocatedArtifactWallTime:F1}s)");
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
                        IsReplay: true,
                        ResultRefJson: concurrentExisting.ResultRefJson,
                        ReservationBreached: concurrentExisting.ReservationBreached,
                        BudgetBreachDetected: concurrentExisting.ReservationBreached
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
        var accountingType = request.AccountingType.ToUpperInvariant();
        if (accountingType is not ("REPORTED" or "ESTIMATED" or "UNKNOWN" or "RECONCILED") ||
            request.TokensUsed < 0 || request.WallTimeUsedSeconds < 0 || request.CostUsedUsd < 0 ||
            request.PromptTokensUsed < 0 || request.CompletionTokensUsed < 0 || request.ReasoningTokensUsed < 0)
            throw new CheckpointValidationException(422, "Usage reconciliation contains an invalid accounting type or negative value");
        if (accountingType == "UNKNOWN" &&
            (request.TokensUsed != 0 || request.PromptTokensUsed is not null || request.CompletionTokensUsed is not null || request.ReasoningTokensUsed is not null))
            throw new CheckpointValidationException(422, "UNKNOWN usage must not claim observed token counts");

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
                if (!string.Equals(op.ResultRefJson, request.ResultRefJson, StringComparison.Ordinal) ||
                    op.TokensUsed != request.TokensUsed || op.PromptTokensUsed != request.PromptTokensUsed ||
                    op.CompletionTokensUsed != request.CompletionTokensUsed || op.ReasoningTokensUsed != request.ReasoningTokensUsed ||
                    !string.Equals(op.AccountingType, accountingType, StringComparison.OrdinalIgnoreCase) ||
                    op.WallTimeUsedSeconds != request.WallTimeUsedSeconds || op.CostUsedUsd != request.CostUsedUsd)
                    throw new CheckpointValidationException(409, "Completed operation usage or result differs from replay");
                return new OperationReconcileResult(op.OperationId, op.Status, op.TokensUsed,
                    op.WallTimeUsedSeconds, op.UpdatedAt, op.ReservationBreached, op.ReservationBreached);
            }

            op.Status = "COMPLETED";
            op.TokensUsed = request.TokensUsed;
            op.PromptTokensUsed = request.PromptTokensUsed;
            op.CompletionTokensUsed = request.CompletionTokensUsed;
            op.ReasoningTokensUsed = request.ReasoningTokensUsed;
            op.AccountingType = accountingType;
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
            var usageIsReported = accountingType is "REPORTED" or "RECONCILED";
            var tokensToAccount = usageIsReported ? request.TokensUsed : Math.Max(request.TokensUsed, op.TokenReservation);
            var tokenDelta = tokensToAccount - op.TokenReservation;
            var wallTimeDelta = request.WallTimeUsedSeconds - op.WallTimeReservationSeconds;
            var reservationBreached =
                (accountingType != "UNKNOWN" && request.TokensUsed > op.TokenReservation) ||
                request.WallTimeUsedSeconds > op.WallTimeReservationSeconds;
            op.ReservationBreached = reservationBreached;
            var breachReason = reservationBreached
                ? $"Operation '{op.OperationId}' reported {accountingType} usage tokens={request.TokensUsed}, wallSeconds={request.WallTimeUsedSeconds:F3}; reservations were tokens={op.TokenReservation}, wallSeconds={op.WallTimeReservationSeconds:F3}."
                : null;
            if (reservationBreached)
                op.BudgetBreachReason = breachReason;

            var budgetBreachDetected = reservationBreached;
            if (IsProviderCallType(op.OperationType))
            {
                var runEntity = await db.ReadingPaperRuns.FirstAsync(r => r.RunId == request.RunId, ct);
                runEntity.BudgetUsedTokens += tokenDelta;
                runEntity.BudgetUsedWallTimeSeconds += wallTimeDelta;
                if (reservationBreached)
                {
                    runEntity.BudgetBreachDetected = true;
                    runEntity.BudgetBreachReason ??= breachReason;
                }
                if (runEntity.BenchmarkCampaignId is { Length: > 0 } campaignId)
                {
                    var updatedCampaignRows = await db.ReadingPaperBenchmarkCampaigns
                        .Where(c => c.CampaignId == campaignId)
                        .ExecuteUpdateAsync(s => s
                            .SetProperty(c => c.BudgetUsedTokens, c => c.BudgetUsedTokens + tokenDelta)
                            .SetProperty(c => c.BudgetUsedWallTimeSeconds, c => c.BudgetUsedWallTimeSeconds + wallTimeDelta)
                            .SetProperty(c => c.BudgetBreachDetected, c => c.BudgetBreachDetected || reservationBreached)
                            .SetProperty(c => c.BudgetBreachReason, c => reservationBreached ? (c.BudgetBreachReason ?? breachReason) : c.BudgetBreachReason)
                            .SetProperty(c => c.UpdatedAt, DateTime.UtcNow), ct);
                    if (updatedCampaignRows != 1)
                    {
                        var missingCampaignLedger = $"Campaign accounting record '{campaignId}' is missing after operation '{op.OperationId}' usage was observed.";
                        runEntity.BudgetBreachDetected = true;
                        runEntity.BudgetBreachReason ??= missingCampaignLedger;
                        budgetBreachDetected = true;
                    }
                }
                runEntity.UpdatedAt = DateTime.UtcNow;
                budgetBreachDetected = runEntity.BudgetBreachDetected;
            }

            await db.SaveChangesAsync(ct);
            await tx.CommitAsync(ct);

            return new OperationReconcileResult(
                op.OperationId,
                op.Status,
                op.TokensUsed,
                op.WallTimeUsedSeconds,
                op.UpdatedAt,
                op.ReservationBreached,
                budgetBreachDetected
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
                var existingInitialHead = await db.ReadingPaperArtifactHeads.AsNoTracking().FirstOrDefaultAsync(
                    h => h.RunId == request.RunId && h.ArtifactId == request.Artifact.ArtifactId, ct);

                if (existingInitialHead != null)
                {
                    if (string.Equals(existingInitialHead.AcceptedHash, request.Artifact.ContentHash, StringComparison.OrdinalIgnoreCase) &&
                        existingInitialHead.AcceptedVersion == request.Artifact.Version)
                    {
                        await db.ReadingPaperArtifactHeads
                            .Where(h => h.RunId == request.RunId && h.ArtifactId == request.Artifact.ArtifactId)
                            .ExecuteUpdateAsync(s => s.SetProperty(h => h.UpdatedAt, DateTime.UtcNow), ct);
                    }
                    else
                    {
                        throw new CheckpointValidationException(409,
                            $"CAS rejection: expected initial head (no prior head), but artifact '{request.Artifact.ArtifactId}' already has an accepted head at version {existingInitialHead.AcceptedVersion} ({existingInitialHead.AcceptedHash})");
                    }
                }
                else
                {
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
            if (string.IsNullOrWhiteSpace(opEntity.AccountingType))
                opEntity.AccountingType = "REPORTED";
            opEntity.CostUsedUsd = request.CostUsedUsd;
            opEntity.WallTimeUsedSeconds = request.WallTimeUsedSeconds;
            opEntity.ResultRefJson = JsonSerializer.Serialize(request.Artifact.ToRef(), LoopEngineJson.Options);
            opEntity.UpdatedAt = DateTime.UtcNow;

            // 5f. Persist Outbox Events
            if (request.Events is { Count: > 0 })
            {
                var maxSeq = await db.ReadingPaperEventOutbox
                    .Where(e => e.RunId == request.RunId)
                    .MaxAsync(e => (long?)e.Sequence, ct) ?? 0L;

                foreach (var evt in request.Events)
                {
                    var evtExists = await db.ReadingPaperEventOutbox.AnyAsync(
                        e => e.RunId == request.RunId && e.IdempotencyKey == evt.IdempotencyKey, ct);
                    if (!evtExists)
                    {
                        var nextSeq = ++maxSeq;
                        var evtWithSeq = evt with { Sequence = nextSeq };
                        db.ReadingPaperEventOutbox.Add(new ReadingPaperEventOutbox
                        {
                            Id = Guid.NewGuid(),
                            RunId = request.RunId,
                            EventId = evt.EventId,
                            Sequence = nextSeq,
                            EventType = evt.EventType.ToString(),
                            IdempotencyKey = evt.IdempotencyKey,
                            Epoch = evt.Epoch,
                            PayloadJson = JsonSerializer.Serialize(evtWithSeq, LoopEngineJson.Options),
                            Status = "PENDING",
                            CreatedAt = DateTime.UtcNow
                        });
                    }
                }
            }

            // 5g. Provider usage is accounted by the per-attempt reconcile transaction.
            var runEntity = await db.ReadingPaperRuns.Include(r => r.Job).FirstAsync(r => r.RunId == request.RunId, ct);
            var allRunOps = await db.ReadingPaperOperations
                .Where(o => o.RunId == request.RunId)
                .ToListAsync(ct);

            // Compute full transitive descendant closure of request.OperationId:
            // 1) All operations reachable by walking ParentOperationId down from request.OperationId.
            // 2) If opEntity.OperationType == "GENERATE_SECTION" && !string.IsNullOrWhiteSpace(opEntity.SectionId),
            //    any operation with the same SectionId where o.OperationId != request.OperationId.
            var closureOpIds = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            var queue = new Queue<string>();
            queue.Enqueue(request.OperationId);
            while (queue.Count > 0)
            {
                var parentId = queue.Dequeue();
                foreach (var child in allRunOps.Where(o => string.Equals(o.ParentOperationId, parentId, StringComparison.OrdinalIgnoreCase)))
                {
                    if (closureOpIds.Add(child.OperationId))
                    {
                        queue.Enqueue(child.OperationId);
                    }
                }
            }
            if (string.Equals(opEntity.OperationType, "GENERATE_SECTION", StringComparison.OrdinalIgnoreCase) && !string.IsNullOrWhiteSpace(opEntity.SectionId))
            {
                foreach (var secOp in allRunOps.Where(o => string.Equals(o.SectionId, opEntity.SectionId, StringComparison.OrdinalIgnoreCase) && !string.Equals(o.OperationId, request.OperationId, StringComparison.OrdinalIgnoreCase)))
                {
                    if (closureOpIds.Add(secOp.OperationId))
                    {
                        queue.Enqueue(secOp.OperationId);
                        while (queue.Count > 0)
                        {
                            var parentId = queue.Dequeue();
                            foreach (var child in allRunOps.Where(o => string.Equals(o.ParentOperationId, parentId, StringComparison.OrdinalIgnoreCase)))
                            {
                                if (closureOpIds.Add(child.OperationId))
                                {
                                    queue.Enqueue(child.OperationId);
                                }
                            }
                        }
                    }
                }
            }

            var closureOps = allRunOps
                .Where(o => closureOpIds.Contains(o.OperationId) && (o.Status == "COMPLETED" || o.Status == "UNKNOWN_OUTCOME"))
                .ToList();

            // To avoid double-counting within that closure, sum only leaf/provider operations (IsProviderCallType if any exist, otherwise direct children).
            var providerOpsInClosure = closureOps.Where(o => IsProviderCallType(o.OperationType)).ToList();
            var opsToReconcile = providerOpsInClosure.Count > 0
                ? providerOpsInClosure
                : closureOps.Where(o => string.Equals(o.ParentOperationId, request.OperationId, StringComparison.OrdinalIgnoreCase)).ToList();

            var childReconciledTokens = opsToReconcile.Sum(o =>
                (string.Equals(o.AccountingType, "REPORTED", StringComparison.OrdinalIgnoreCase) || string.Equals(o.AccountingType, "RECONCILED", StringComparison.OrdinalIgnoreCase))
                    ? o.TokensUsed
                    : Math.Max(o.TokensUsed, Math.Max(0, o.TokenReservation)));

            var childReconciledWallTime = opsToReconcile.Sum(o =>
                o.Status == "COMPLETED" ? o.WallTimeUsedSeconds : Math.Max(0.0, o.WallTimeReservationSeconds));

            var hasProviderOpsInRun = allRunOps.Any(o => IsProviderCallType(o.OperationType));

            // If !IsProviderCallType(opEntity.OperationType) and the run ALREADY has IsProviderCallType operations,
            // unchargedTokens and unchargedWallTime for wrapper operations MUST NOT double-add tokens/wall-time that were already accounted.
            var unchargedTokens = (!IsProviderCallType(opEntity.OperationType) && hasProviderOpsInRun)
                ? 0
                : Math.Max(0, request.TokensUsed - childReconciledTokens);

            var unchargedWallTime = (!IsProviderCallType(opEntity.OperationType) && hasProviderOpsInRun)
                ? 0.0
                : Math.Max(0.0, request.WallTimeUsedSeconds - childReconciledWallTime);

            var tokenDelta = IsProviderCallType(opEntity.OperationType)
                ? unchargedTokens - Math.Max(0, opEntity.TokenReservation)
                : unchargedTokens;
            var wallTimeDelta = IsProviderCallType(opEntity.OperationType)
                ? unchargedWallTime - Math.Max(0.0, opEntity.WallTimeReservationSeconds)
                : unchargedWallTime;

            runEntity.BudgetUsedTokens += tokenDelta;
            runEntity.BudgetUsedWallTimeSeconds += wallTimeDelta;
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
                var committedOp = await db.ReadingPaperOperations.AsNoTracking().FirstOrDefaultAsync(
                    o => o.RunId == request.RunId && o.OperationId == request.OperationId, ct);

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
                        committedOp?.UpdatedAt ?? DateTime.UtcNow,
                        IsReplay: true
                    );
                }

                throw new CheckpointValidationException(409,
                    $"Concurrent modification conflict on artifact '{request.Artifact.ArtifactId}' or operation '{request.OperationId}'");
            }
        });
    }
    public static async Task<CheckpointAck> ImportCheckpointAsync(
        ExamDbContext db,
        CheckpointImportRequest request,
        CancellationToken ct)
    {
        var (run, job) = await ValidateRunAuthorityAndFencingAsync(db, request.RunId, request.Epoch, request.LeaseOwner, ct);

        // 1. Cryptographic content hash verification
        var computedHash = ArtifactEnvelope.ComputeContentHash(request.Artifact.Payload, request.Artifact.ParentRefs);
        if (!string.Equals(computedHash, request.Artifact.ContentHash, StringComparison.OrdinalIgnoreCase))
        {
            throw new CheckpointValidationException(400,
                $"Artifact content hash mismatch: payload/parents hash is '{computedHash}' but envelope declared '{request.Artifact.ContentHash}'");
        }

        // 2. Provenance verification if source run is provided
        if (!string.IsNullOrWhiteSpace(request.SourceRunId))
        {
            var sourceRun = await db.ReadingPaperRuns.FirstOrDefaultAsync(r => r.RunId == request.SourceRunId, ct);
            if (sourceRun == null)
            {
                throw new CheckpointValidationException(404,
                    $"Source run '{request.SourceRunId}' not found for provenance verification");
            }

            var sourceArtifact = await db.ReadingPaperArtifacts.FirstOrDefaultAsync(
                a => a.RunId == request.SourceRunId && a.ArtifactId == request.Artifact.ArtifactId, ct);

            if (sourceArtifact == null)
            {
                throw new CheckpointValidationException(404,
                    $"Artifact '{request.Artifact.ArtifactId}' not found in source run '{request.SourceRunId}'");
            }

            // For v1, hash must match source artifact
            if (request.Artifact.Version == 1 &&
                !string.Equals(sourceArtifact.ContentHash, request.Artifact.ContentHash, StringComparison.OrdinalIgnoreCase))
            {
                throw new CheckpointValidationException(409,
                    $"Provenance mismatch: artifact '{request.Artifact.ArtifactId}' hash '{request.Artifact.ContentHash}' does not match source run hash '{sourceArtifact.ContentHash}'");
            }
        }

        // 3. Immutability check
        var existingArt = await db.ReadingPaperArtifacts.FirstOrDefaultAsync(
            a => a.RunId == request.RunId && a.ArtifactId == request.Artifact.ArtifactId && a.Version == request.Artifact.Version, ct);

        if (existingArt != null)
        {
            if (!string.Equals(existingArt.ContentHash, request.Artifact.ContentHash, StringComparison.OrdinalIgnoreCase))
            {
                throw new CheckpointValidationException(409,
                    $"Immutability violation: artifact '{request.Artifact.ArtifactId}' version {request.Artifact.Version} already exists in run with different hash");
            }

            return new CheckpointAck(
                request.RunId,
                request.Epoch,
                request.Artifact.ArtifactId,
                existingArt.Version,
                existingArt.ContentHash,
                existingArt.CreatedAt,
                IsReplay: true
            );
        }

        // 4. Atomic transaction to insert artifact and head
        var strategy = db.Database.CreateExecutionStrategy();
        return await strategy.ExecuteAsync(async () =>
        {
            db.ChangeTracker.Clear();
            await using var tx = await db.Database.BeginTransactionAsync(ct);

            var (txRun, txJob) = await ValidateRunAuthorityAndFencingAsync(db, request.RunId, request.Epoch, request.LeaseOwner, ct);

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

            foreach (var parent in request.Artifact.ParentRefs)
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

            var existingHead = await db.ReadingPaperArtifactHeads.FirstOrDefaultAsync(
                h => h.RunId == request.RunId && h.ArtifactId == request.Artifact.ArtifactId, ct);

            if (existingHead == null)
            {
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
            else
            {
                existingHead.AcceptedVersion = request.Artifact.Version;
                existingHead.AcceptedHash = request.Artifact.ContentHash;
                existingHead.UpdatedAt = DateTime.UtcNow;
            }

            // Also record an import operation with 0 tokens and 0 wall time
            var importOpId = $"op_import_{request.Artifact.ArtifactId}_v{request.Artifact.Version}";
            var existingOp = await db.ReadingPaperOperations.FirstOrDefaultAsync(
                o => o.RunId == request.RunId && o.OperationId == importOpId, ct);
            if (existingOp == null)
            {
                db.ReadingPaperOperations.Add(new ReadingPaperOperation
                {
                    Id = Guid.NewGuid(),
                    RunId = request.RunId,
                    OperationId = importOpId,
                    OperationType = "CHECKPOINT_IMPORT",
                    RequestHash = $"import:{request.Artifact.ArtifactId}:{request.Artifact.ContentHash}",
                    Status = "COMPLETED",
                    TokenReservation = 0,
                    TokensUsed = 0,
                    WallTimeReservationSeconds = 0,
                    WallTimeUsedSeconds = 0,
                    ArtifactId = request.Artifact.ArtifactId,
                    SectionId = request.Artifact.SectionId?.ToString(),
                    AccountingType = "REPORTED",
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                });
            }

            await db.SaveChangesAsync(ct);
            await tx.CommitAsync(ct);

            return new CheckpointAck(
                request.RunId,
                request.Epoch,
                request.Artifact.ArtifactId,
                request.Artifact.Version,
                request.Artifact.ContentHash,
                newArt.CreatedAt,
                IsReplay: false
            );
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
            opEntity.AccountingType = "REPORTED";
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
        var (run, job) = await ValidateRunAuthorityAndFencingAsync(db, request.RunId, request.Epoch, request.LeaseOwner, ct);
        var strategy = db.Database.CreateExecutionStrategy();
        return await strategy.ExecuteAsync(async () =>
        {
            db.ChangeTracker.Clear();
            await using var tx = await db.Database.BeginTransactionAsync(ct);
            var fencedJobRows = await db.ReadingPaperJobs
                .Where(j => j.Id == job.Id && j.Epoch == request.Epoch && j.LeaseOwner == request.LeaseOwner &&
                            j.Status == "Running" && j.LeaseUntil > DateTime.UtcNow && j.CancelVersion == job.CancelVersion)
                .ExecuteUpdateAsync(s => s.SetProperty(j => j.UpdatedAt, DateTime.UtcNow), ct);
            if (fencedJobRows != 1)
                throw new CheckpointValidationException(409, "Epoch fencing violation during unknown-outcome recording");

            var op = await db.ReadingPaperOperations.FirstOrDefaultAsync(
                o => o.RunId == request.RunId && o.OperationId == request.OperationId, ct);
            if (op == null)
                throw new CheckpointValidationException(404, $"Operation '{request.OperationId}' not found");
            if (string.Equals(op.Status, "COMPLETED", StringComparison.OrdinalIgnoreCase))
                throw new CheckpointValidationException(409, "Completed operation cannot be changed to UNKNOWN_OUTCOME");
            if (string.Equals(op.Status, "UNKNOWN_OUTCOME", StringComparison.OrdinalIgnoreCase))
                return new UnknownOutcomeAck(op.OperationId, op.Status, ReservationPreserved: true, op.UpdatedAt);
            if (!string.Equals(op.Status, "RESERVED", StringComparison.OrdinalIgnoreCase))
                throw new CheckpointValidationException(409, $"Operation '{op.OperationId}' cannot become UNKNOWN_OUTCOME from '{op.Status}'");

            op.Status = "UNKNOWN_OUTCOME";
            op.ErrorMessage = request.ErrorMessage;
            op.UpdatedAt = DateTime.UtcNow;
            await db.SaveChangesAsync(ct);
            await tx.CommitAsync(ct);
            return new UnknownOutcomeAck(op.OperationId, op.Status, ReservationPreserved: true, op.UpdatedAt);
        });
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

        var profileJson = run.BudgetProfileJson;
        var isUnlimitedRun = run.BudgetCapCalls == ReadingPaperCapsProfile.UnlimitedCap ||
                             run.BudgetCapTokens == ReadingPaperCapsProfile.UnlimitedCap ||
                             run.BudgetCapWallTimeSeconds == ReadingPaperCapsProfile.UnlimitedCap;
        var profileHashIsValid = ReadingPaperCapsProfile.MatchesRunBudget(
            profileJson, run.BudgetProfileSha256,
            !string.IsNullOrWhiteSpace(run.BenchmarkCampaignId) || isUnlimitedRun,
            run.BudgetCapCalls, run.BudgetCapTokens, run.BudgetCapWallTimeSeconds);
        if (!profileHashIsValid || string.IsNullOrWhiteSpace(run.BudgetProfileVersion) ||
            string.Equals(run.BudgetProfileVersion, "legacy-unpinned", StringComparison.OrdinalIgnoreCase) ||
            string.IsNullOrWhiteSpace(run.BudgetProfileSource))
        {
            return new ResumeStateResult(
                run.RunId, run.JobId, run.Epoch, run.Status,
                run.EngineVersion, run.SchemaVersion, run.PolicyVersion, [],
                IsCompatible: false,
                IncompatibilityReason: "Run has no valid pinned cap profile; current environment will not be used to fabricate historical limits",
                BudgetProfileVersion: run.BudgetProfileVersion,
                BudgetProfileSha256: run.BudgetProfileSha256,
                BudgetProfileSource: run.BudgetProfileSource,
                BudgetProfileJson: profileJson,
                BudgetBreachDetected: run.BudgetBreachDetected
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
        var activeOps = ops.Where(o => o.Status == "RESERVED" || o.Status == "COMPLETED" || o.Status == "UNKNOWN_OUTCOME").ToList();
        var providerOps = activeOps.Where(o => IsProviderCallType(o.OperationType)).ToList();

        int totalTokens;
        double totalWallTime;
        int totalCalls;

        if (providerOps.Count > 0)
        {
            totalTokens = providerOps.Sum(o => o.Status == "COMPLETED"
                ? ((string.Equals(o.AccountingType, "REPORTED", StringComparison.OrdinalIgnoreCase) || string.Equals(o.AccountingType, "RECONCILED", StringComparison.OrdinalIgnoreCase))
                    ? o.TokensUsed
                    : Math.Max(o.TokensUsed, Math.Max(0, o.TokenReservation)))
                : Math.Max(0, o.TokenReservation));
            totalWallTime = providerOps.Sum(o => o.Status == "COMPLETED" ? o.WallTimeUsedSeconds : Math.Max(0.0, o.WallTimeReservationSeconds));
            totalCalls = providerOps.Count;
        }
        else
        {
            var standaloneWorkOps = activeOps.Where(o => string.IsNullOrWhiteSpace(o.ParentOperationId) && !string.Equals(o.OperationType, "CHECKPOINT_COMMIT", StringComparison.OrdinalIgnoreCase) && !string.Equals(o.OperationType, "WORKFLOW", StringComparison.OrdinalIgnoreCase)).ToList();
            if (standaloneWorkOps.Count > 0)
            {
                totalTokens = Math.Max(run.BudgetUsedTokens, standaloneWorkOps.Sum(o => o.Status == "COMPLETED"
                    ? ((string.Equals(o.AccountingType, "REPORTED", StringComparison.OrdinalIgnoreCase) || string.Equals(o.AccountingType, "RECONCILED", StringComparison.OrdinalIgnoreCase))
                        ? o.TokensUsed
                        : Math.Max(o.TokensUsed, Math.Max(0, o.TokenReservation)))
                    : Math.Max(0, o.TokenReservation)));
                totalWallTime = Math.Max(run.BudgetUsedWallTimeSeconds, standaloneWorkOps.Sum(o => o.Status == "COMPLETED" ? o.WallTimeUsedSeconds : Math.Max(0.0, o.WallTimeReservationSeconds)));
                totalCalls = Math.Max(run.BudgetUsedCalls, standaloneWorkOps.Count);
            }
            else
            {
                totalTokens = run.BudgetUsedTokens;
                totalWallTime = run.BudgetUsedWallTimeSeconds;
                totalCalls = run.BudgetUsedCalls;
            }
        }
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
        var statusMap = new Dictionary<string, IssueStatus>(StringComparer.OrdinalIgnoreCase);
        foreach (var ie in issueEntities)
        {
            if (!string.IsNullOrWhiteSpace(ie.Fingerprint) && Enum.TryParse<IssueStatus>(ie.Status, true, out var parsedStatus))
            {
                statusMap[ie.Fingerprint] = parsedStatus;
            }
        }

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
            BudgetCapCalls: run.BudgetCapCalls,
            BudgetCapTokens: run.BudgetCapTokens,
            BudgetCapWallTimeSeconds: run.BudgetCapWallTimeSeconds,
            CreatedAt: run.CreatedAt,
            HardDeadlineAt: run.BudgetCapWallTimeSeconds > 0 ? run.CreatedAt.AddSeconds(run.BudgetCapWallTimeSeconds) : null,
            DraftArtifacts: draftArtifacts,
            Issues: issues,
            Evaluations: evalResults,
            LoopCursors: await db.ReadingPaperLoopCursors.Where(c => c.RunId == runId)
                .Select(c => new LoopCursorCheckpoint(c.ArtifactId, c.Revision, c.StateJson, c.LastOperationId)).ToListAsync(ct),
            Operations: ops.Select(o => new OperationResumeInfo(o.OperationId, o.OperationType, o.Status,
                o.ArtifactId, o.RequestHash, o.TokenReservation, o.TokensUsed,
                o.WallTimeReservationSeconds, o.WallTimeUsedSeconds, o.ResultRefJson,
                o.PromptTokensUsed, o.CompletionTokensUsed, o.ReasoningTokensUsed, o.AccountingType, o.ReservationBreached)).ToList(),
            BudgetProfileVersion: run.BudgetProfileVersion,
            BudgetProfileSha256: run.BudgetProfileSha256,
            BudgetProfileSource: run.BudgetProfileSource,
            BudgetProfileJson: run.BudgetProfileJson,
            BudgetBreachDetected: run.BudgetBreachDetected
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
        ExamDbContext db, BuildExamInternalRequest request, CancellationToken ct,
        Func<Task>? onBeforeTransaction = null, Func<Task>? onGraphSaved = null)
    {
        var replay = await CompletedExamAsync(db, request, ct);
        if (replay != null) return replay;
        var (_, job) = await ValidateRunAuthorityAndFencingAsync(db, request.RunId, request.Epoch, request.LeaseOwner, ct);
        if (job.Id != request.JobId || job.ActiveRunId != request.RunId)
            throw new CheckpointValidationException(409, "Finalizer run/job identity mismatch");
        if (onBeforeTransaction != null) await onBeforeTransaction();
        var strategy = db.Database.CreateExecutionStrategy();
        return await strategy.ExecuteAsync(async () =>
        {
            db.ChangeTracker.Clear();
            await using var tx = await db.Database.BeginTransactionAsync(ct);
            var fencedJobRows = await db.ReadingPaperJobs
                .Where(j => j.Id == request.JobId && j.ActiveRunId == request.RunId && j.Epoch == request.Epoch
                    && j.LeaseOwner == request.LeaseOwner && j.Status == "Running"
                    && j.LeaseUntil > DateTime.UtcNow && j.CancelVersion == job.CancelVersion)
                .ExecuteUpdateAsync(s => s.SetProperty(j => j.Status, "Completed").SetProperty(j => j.UpdatedAt, DateTime.UtcNow), ct);
            if (fencedJobRows != 1)
            {
                var completed = await CompletedExamAsync(db, request, ct);
                if (completed != null) return completed;
                throw new CheckpointValidationException(409, "Epoch/lease/cancel fencing violation during final exam build");
            }
            var fencedRunRows = await db.ReadingPaperRuns
                .Where(r => r.RunId == request.RunId && r.JobId == request.JobId && r.Epoch == request.Epoch
                    && r.LeaseOwner == request.LeaseOwner && r.Status == "RUNNING"
                    && r.LeaseUntil > DateTime.UtcNow && r.CancelVersion == job.CancelVersion)
                .ExecuteUpdateAsync(s => s.SetProperty(r => r.Status, "COMPLETED").SetProperty(r => r.UpdatedAt, DateTime.UtcNow), ct);
            if (fencedRunRows != 1)
                throw new CheckpointValidationException(409, "Epoch/lease/cancel fencing violation for final run");
            var run = await db.ReadingPaperRuns.AsNoTracking().SingleAsync(r => r.RunId == request.RunId, ct);
            var txJob = await db.ReadingPaperJobs.AsNoTracking().SingleAsync(j => j.Id == request.JobId, ct);
            var jobSections = JsonSerializer.Deserialize<List<ReadingGeneratedSection>>(txJob.SectionsJson, ReadingPaperRules.Json) ?? [];
            var useJobSections = (jobSections.Count > 0 && jobSections.Count < 3) ||
                (!string.Equals(run.EngineVersion, "2.0.0", StringComparison.OrdinalIgnoreCase) && jobSections.Count == 3);
            if (useJobSections)
            {
                ReadingPaperRules.Validate(jobSections);
            }
            var sections = useJobSections
                ? jobSections
                : await ReadingPaperFinalSnapshot.LoadAsync(db, run, txJob, request.FinalEvaluations, ct);
            var exam = ReadingPaperWorker.BuildExam(txJob, sections);
            if (await db.Exams.AnyAsync(e => e.Slug == exam.Slug, ct))
                throw new CheckpointValidationException(409, "Final exam slug is already owned by a different graph");
            db.Exams.Add(exam);
            await db.ReadingPaperJobs.Where(j => j.Id == request.JobId)
                .ExecuteUpdateAsync(s => s.SetProperty(j => j.ExamId, exam.Id)
                    .SetProperty(j => j.SectionsJson, JsonSerializer.Serialize(sections, ReadingPaperRules.Json))
                    .SetProperty(j => j.CompletedSections, sections.Count)
                    .SetProperty(j => j.LeaseOwner, (Guid?)null).SetProperty(j => j.LeaseUntil, (DateTime?)null), ct);
            await db.ReadingPaperRuns.Where(r => r.RunId == request.RunId)
                .ExecuteUpdateAsync(s => s.SetProperty(r => r.LeaseOwner, (Guid?)null).SetProperty(r => r.LeaseUntil, (DateTime?)null), ct);
            var maxSeq = await db.ReadingPaperEventOutbox
                .Where(e => e.RunId == request.RunId)
                .MaxAsync(e => (long?)e.Sequence, ct) ?? 0L;
            var eventId = $"exam-draft:{request.RunId}";
            db.ReadingPaperEventOutbox.Add(new ReadingPaperEventOutbox
            {
                RunId = request.RunId, EventId = eventId, Sequence = maxSeq + 1, IdempotencyKey = eventId, Epoch = request.Epoch,
                EventType = EventType.RUN_COMPLETED.ToString(),
                PayloadJson = JsonSerializer.Serialize(new { runId = request.RunId, jobId = request.JobId, examId = exam.Id, status = "Draft" }, ReadingPaperRules.Json)
            });
            foreach (var evaluation in request.FinalEvaluations ?? [])
                if (!await db.ReadingPaperEvaluations.AnyAsync(e => e.RunId == request.RunId && e.EvaluationId == evaluation.EvaluationId, ct))
                    db.ReadingPaperEvaluations.Add(new ReadingPaperEvaluation
                    {
                        RunId = request.RunId, EvaluationId = evaluation.EvaluationId, EvaluatorId = evaluation.EvaluatorId,
                        EvaluatorVersion = evaluation.EvaluatorVersion, TargetArtifactId = evaluation.TargetRef.ArtifactId,
                        TargetVersion = evaluation.TargetRef.Version, TargetContentHash = evaluation.TargetRef.ContentHash,
                        Status = evaluation.Status.ToString(), IsPass = evaluation.IsPass,
                        PayloadJson = JsonSerializer.Serialize(evaluation, LoopEngineJson.Options)
                    });
            await db.SaveChangesAsync(ct);
            await LineageService.RecordExamLineageAsync(db, run, txJob, exam, sections, ct);
            await db.SaveChangesAsync(ct);
            if (onGraphSaved != null) await onGraphSaved();
            await tx.CommitAsync(ct);
            return new BuildExamInternalResult(exam.Id, exam.Slug);
        });
    }

    private static async Task<BuildExamInternalResult?> CompletedExamAsync(
        ExamDbContext db, BuildExamInternalRequest request, CancellationToken ct)
    {
        // Only the authenticated finalizer may replay this read. Mutating operation admission stays strict.
        var run = await db.ReadingPaperRuns.AsNoTracking().Include(r => r.Job)
            .SingleOrDefaultAsync(r => r.RunId == request.RunId, ct);
        if (run?.Job == null || run.Status != "COMPLETED" || run.Job.Status != "Completed") return null;
        if (run.JobId != request.JobId || run.Job.ActiveRunId != request.RunId
            || run.Epoch != request.Epoch || run.Job.Epoch != request.Epoch || run.CancelVersion != run.Job.CancelVersion
            || run.Job.ExamId == null)
            throw new CheckpointValidationException(409, "Completed finalizer replay identity mismatch");
        var exam = await db.Exams.AsNoTracking().SingleOrDefaultAsync(e => e.Id == run.Job.ExamId, ct)
            ?? throw new CheckpointValidationException(409, "Completed run has no authoritative exam graph");
        return new BuildExamInternalResult(exam.Id, exam.Slug, IsExisting: true);
    }

    private static void SyncSectionToLegacyJob(ReadingPaperJob job, ArtifactEnvelope sectionEnvelope)
    {
        try
        {
            ReadingGeneratedSection? sectionDto = null;
            try
            {
                sectionDto = JsonSerializer.Deserialize<ReadingGeneratedSection>(sectionEnvelope.Payload.GetRawText(), ReadingPaperRules.Json);
            }
            catch
            {
                // Fallback to manual extraction
            }

            if (sectionDto == null || sectionDto.Groups == null || sectionDto.Groups.Count == 0 || string.IsNullOrEmpty(sectionDto.Groups[0].Type))
            {
                sectionDto = ParseCanonicalV2Section(sectionEnvelope.Payload);
            }

            if (sectionDto == null) return;

            var existingSections = JsonSerializer.Deserialize<List<ReadingGeneratedSection>>(job.SectionsJson, ReadingPaperRules.Json) ?? [];
            var existingIndex = existingSections.FindIndex(s =>
                sectionDto.Source != null && !string.IsNullOrEmpty(sectionDto.Source.Pmcid) && string.Equals(s.Source?.Pmcid, sectionDto.Source.Pmcid, StringComparison.OrdinalIgnoreCase));

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

    private static ReadingGeneratedSection? ParseCanonicalV2Section(JsonElement payload)
    {
        try
        {
            var secId = payload.TryGetProperty("sectionId", out var idP) ? idP.GetInt32() : (payload.TryGetProperty("section_id", out var id2) ? id2.GetInt32() : 1);
            var title = payload.TryGetProperty("title", out var tP) ? tP.GetString() ?? $"Section {secId}" : $"Section {secId}";
            var passage = payload.TryGetProperty("passage", out var pP) ? pP.GetString() ?? "" : (payload.TryGetProperty("passageText", out var ptP) ? ptP.GetString() ?? "" : (payload.TryGetProperty("text", out var txP) ? txP.GetString() ?? "" : ""));

            ReadingSource source;
            if (payload.TryGetProperty("source", out var sP) && sP.ValueKind == JsonValueKind.Object)
            {
                var pmcid = sP.TryGetProperty("pmcid", out var pmP) ? pmP.GetString() ?? $"PMC{secId}000000" : $"PMC{secId}000000";
                var sTitle = sP.TryGetProperty("title", out var stP) ? stP.GetString() ?? title : title;
                var doi = sP.TryGetProperty("doi", out var dP) ? dP.GetString() : null;
                var url = sP.TryGetProperty("url", out var uP) ? uP.GetString() ?? "" : "";
                var license = sP.TryGetProperty("license", out var lP) ? lP.GetString() ?? "CC BY 4.0" : "CC BY 4.0";
                var wc = sP.TryGetProperty("wordCount", out var wcP) ? wcP.GetInt32() : ReadingPaperRules.WordCount(passage);
                var authors = sP.TryGetProperty("authors", out var aP) ? aP.GetString() : null;
                source = new ReadingSource(pmcid, sTitle, doi, url, license, wc, authors);
            }
            else
            {
                source = new ReadingSource($"PMC{secId}000000", title, null, "", "CC BY 4.0", ReadingPaperRules.WordCount(passage));
            }

            var groups = new List<ReadingGeneratedGroup>();
            if (payload.TryGetProperty("groups", out var gArray) && gArray.ValueKind == JsonValueKind.Array)
            {
                foreach (var gNode in gArray.EnumerateArray())
                {
                    string gType = "SentenceCompletion";
                    if (gNode.TryGetProperty("questionType", out var qtP) && qtP.ValueKind == JsonValueKind.String)
                        gType = qtP.GetString() ?? "SentenceCompletion";
                    else if (gNode.TryGetProperty("type", out var grpTypeProp) && grpTypeProp.ValueKind == JsonValueKind.String)
                        gType = grpTypeProp.GetString() ?? "SentenceCompletion";

                    string gInst = "";
                    if (gNode.TryGetProperty("instructions", out var in1P) && in1P.ValueKind == JsonValueKind.String)
                        gInst = in1P.GetString() ?? "";
                    else if (gNode.TryGetProperty("instruction", out var in2P) && in2P.ValueKind == JsonValueKind.String)
                        gInst = in2P.GetString() ?? "";

                    var questions = new List<ReadingGeneratedQuestion>();
                    if (gNode.TryGetProperty("questions", out var qArray) && qArray.ValueKind == JsonValueKind.Array)
                    {
                        foreach (var qNode in qArray.EnumerateArray())
                        {
                            int qNum = questions.Count + 1;
                            if (qNode.TryGetProperty("questionNumber", out var qnP) && qnP.TryGetInt32(out var qnVal))
                                qNum = qnVal;
                            else if (qNode.TryGetProperty("number", out var nP) && nP.TryGetInt32(out var nVal))
                                qNum = nVal;

                            string prompt = "";
                            if (qNode.TryGetProperty("prompt", out var prP) && prP.ValueKind == JsonValueKind.String)
                                prompt = prP.GetString() ?? "";
                            else if (qNode.TryGetProperty("statement", out var stP) && stP.ValueKind == JsonValueKind.String)
                                prompt = stP.GetString() ?? "";

                            string ans = "";
                            if (qNode.TryGetProperty("answer", out var ansP) && ansP.ValueKind == JsonValueKind.String)
                                ans = ansP.GetString() ?? "";
                            else if (qNode.TryGetProperty("correctOption", out var coP) && coP.ValueKind == JsonValueKind.String)
                                ans = coP.GetString() ?? "";

                            string quote = "";
                            if (qNode.TryGetProperty("evidenceQuote", out var eqP) && eqP.ValueKind == JsonValueKind.String)
                                quote = eqP.GetString() ?? "";
                            else if (qNode.TryGetProperty("evidence_quote", out var eq2P) && eq2P.ValueKind == JsonValueKind.String)
                                quote = eq2P.GetString() ?? "";

                            string expl = "";
                            if (qNode.TryGetProperty("explanation", out var expP) && expP.ValueKind == JsonValueKind.String)
                                expl = expP.GetString() ?? "";

                            var options = new List<string>();
                            if (qNode.TryGetProperty("options", out var optArray) && optArray.ValueKind == JsonValueKind.Array)
                            {
                                foreach (var optNode in optArray.EnumerateArray())
                                {
                                    if (optNode.ValueKind == JsonValueKind.String)
                                    {
                                        options.Add(optNode.GetString() ?? "");
                                    }
                                    else if (optNode.TryGetProperty("text", out var tNode) && tNode.ValueKind == JsonValueKind.String)
                                    {
                                        options.Add(tNode.GetString() ?? "");
                                    }
                                }
                            }

                            questions.Add(new ReadingGeneratedQuestion(qNum, prompt, ans, options, quote, expl));
                        }
                    }
                    groups.Add(new ReadingGeneratedGroup(gType, gInst, questions));
                }
            }

            return new ReadingGeneratedSection(title, passage, source, groups);
        }
        catch
        {
            return null;
        }
    }

    public static async Task<List<OutboxEventDto>> GetOutboxEventsAsync(
        ExamDbContext db,
        string runId,
        long afterSequence = 0,
        CancellationToken ct = default)
    {
        var entities = await db.ReadingPaperEventOutbox
            .Where(e => e.RunId == runId)
            .OrderBy(e => e.Sequence > 0 ? e.Sequence : 0)
            .ThenBy(e => e.CreatedAt)
            .ToListAsync(ct);

        var result = new List<OutboxEventDto>();
        long seq = 1;
        foreach (var entity in entities)
        {
            var effectiveSeq = entity.Sequence > 0 ? entity.Sequence : seq;
            if (effectiveSeq > afterSequence)
            {
                result.Add(new OutboxEventDto(
                    entity.Id,
                    entity.RunId,
                    entity.EventId,
                    entity.EventType,
                    entity.IdempotencyKey,
                    entity.Epoch,
                    entity.PayloadJson,
                    entity.Status,
                    entity.CreatedAt,
                    effectiveSeq
                ));
            }
            seq++;
        }

        return result;
    }
}
