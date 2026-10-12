using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Text.RegularExpressions;
using exam_service.Domains.Entities;
using exam_service.Features.ReadingPaper.Contracts;
using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Npgsql;

namespace exam_service.Features.ReadingPaper;

public static class BenchmarkCampaignService
{
    private static readonly TimeSpan ChildLeaseDuration = TimeSpan.FromHours(1);
    private static readonly Regex Sha256Pattern = new("^[a-fA-F0-9]{64}$", RegexOptions.Compiled);

    public static async Task<BenchmarkCampaignStatus> CreateAsync(
        ExamDbContext db,
        BenchmarkCampaignCreateRequest request,
        CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(request.CampaignId) || request.CampaignId.Length > 128)
            throw new CheckpointValidationException(400, "CampaignId must contain 1-128 characters");
        if (string.IsNullOrWhiteSpace(request.AuthorizationId) || request.AuthorizationId.Length > 128)
            throw new CheckpointValidationException(400, "AuthorizationId must contain 1-128 characters");
        if (string.IsNullOrWhiteSpace(request.AuthorizedBy) || request.AuthorizedBy.Length > 200)
            throw new CheckpointValidationException(400, "AuthorizedBy must contain 1-200 characters");
        if (!Sha256Pattern.IsMatch(request.CorpusSha256) || !Sha256Pattern.IsMatch(request.ConfigSha256))
            throw new CheckpointValidationException(400, "CorpusSha256 and ConfigSha256 must be 64-character SHA-256 hex digests");
        var isUnlimited = request.BudgetCapCalls == -1 && request.BudgetCapTokens == -1 && request.BudgetCapWallTimeSeconds == -1;
        if (!isUnlimited && (request.BudgetCapCalls <= 0 || request.BudgetCapTokens <= 0 || request.BudgetCapWallTimeSeconds <= 0))
            throw new CheckpointValidationException(400, "Authorized campaign call, token, and wall-time caps must all be positive, or all -1 for unlimited benchmark");

        var existing = await db.ReadingPaperBenchmarkCampaigns.AsNoTracking()
            .SingleOrDefaultAsync(x => x.CampaignId == request.CampaignId, ct);
        if (existing != null)
            return EnsureSameAuthorization(existing, request);

        var campaign = new ReadingPaperBenchmarkCampaign
        {
            CampaignId = request.CampaignId,
            AuthorizationId = request.AuthorizationId,
            AuthorizedBy = request.AuthorizedBy,
            CorpusSha256 = request.CorpusSha256.ToLowerInvariant(),
            ConfigSha256 = request.ConfigSha256.ToLowerInvariant(),
            BudgetCapCalls = request.BudgetCapCalls,
            BudgetCapTokens = request.BudgetCapTokens,
            BudgetCapWallTimeSeconds = request.BudgetCapWallTimeSeconds,
            Status = "AUTHORIZED",
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        db.ReadingPaperBenchmarkCampaigns.Add(campaign);
        try
        {
            await db.SaveChangesAsync(ct);
        }
        catch (DbUpdateException ex) when (ex.InnerException is PostgresException { SqlState: "23505" })
        {
            db.ChangeTracker.Clear();
            existing = await db.ReadingPaperBenchmarkCampaigns.AsNoTracking()
                .SingleOrDefaultAsync(x => x.CampaignId == request.CampaignId, ct);
            if (existing != null)
                return EnsureSameAuthorization(existing, request);
            throw;
        }

        return ToStatus(campaign, []);
    }

    public static async Task<BenchmarkCaseProvisionResult> ProvisionCaseAsync(
        ExamDbContext db,
        BenchmarkCaseProvisionRequest request,
        ReadingPaperCapsProfile caps,
        CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(request.CampaignId) || request.CampaignId.Length > 128 ||
            string.IsNullOrWhiteSpace(request.CaseId) || request.CaseId.Length > 128 ||
            string.IsNullOrWhiteSpace(request.ClaimId) || request.ClaimId.Length > 128 ||
            request.LeaseOwner == Guid.Empty)
            throw new CheckpointValidationException(400, "CampaignId, CaseId, ClaimId, and a non-empty LeaseOwner are required");
        var workerInput = request.WorkerInput;
        var sourcesJson = "[]";
        if (workerInput != null)
        {
            var (_, error) = ReadingPaperEndpoints.ValidateSources(workerInput.Sources);
            if (error != null || workerInput.Sources.Count != 3 || workerInput.Topic?.Trim().Length is not (>= 3 and <= 120)
                || workerInput.Sources.Any(s => string.IsNullOrWhiteSpace(s.Content) || ReadingPaperRules.WordCount(s.Content) < 600
                    || string.IsNullOrWhiteSpace(s.License)))
                throw new CheckpointValidationException(422, error ?? "Worker input requires a topic and three verified source texts/licenses");
            sourcesJson = JsonSerializer.Serialize(workerInput.Sources, ReadingPaperRules.Json);
        }

        var strategy = db.Database.CreateExecutionStrategy();
        return await strategy.ExecuteAsync(async () =>
        {
            db.ChangeTracker.Clear();
            await using var tx = await db.Database.BeginTransactionAsync(ct);
            var campaignLocked = await db.ReadingPaperBenchmarkCampaigns
                .Where(x => x.CampaignId == request.CampaignId && x.Status == "AUTHORIZED")
                .ExecuteUpdateAsync(s => s.SetProperty(x => x.UpdatedAt, DateTime.UtcNow), ct);
            if (campaignLocked != 1)
            {
                var exists = await db.ReadingPaperBenchmarkCampaigns.AsNoTracking()
                    .AnyAsync(x => x.CampaignId == request.CampaignId, ct);
                throw new CheckpointValidationException(exists ? 409 : 404,
                    exists ? "Campaign is not authorized for new child runs" : $"Campaign '{request.CampaignId}' was not found");
            }

            var campaign = await db.ReadingPaperBenchmarkCampaigns.AsNoTracking()
                .SingleAsync(x => x.CampaignId == request.CampaignId, ct);
            var run = await db.ReadingPaperRuns
                .Include(x => x.Job)
                .SingleOrDefaultAsync(x => x.BenchmarkCampaignId == request.CampaignId && x.BenchmarkCaseId == request.CaseId, ct);
            var now = DateTime.UtcNow;
            if (run != null)
            {
                if (run.Job == null)
                    throw new CheckpointValidationException(500, "Benchmark child run is missing its owning job");

                var operationCount = await db.ReadingPaperOperations.CountAsync(x => x.RunId == run.RunId, ct);
                var unknownCount = await db.ReadingPaperOperations.CountAsync(
                    x => x.RunId == run.RunId && x.Status == "UNKNOWN_OUTCOME", ct);
                var completedCount = await db.ReadingPaperOperations.CountAsync(
                    x => x.RunId == run.RunId && x.Status == "COMPLETED", ct);
                if (workerInput != null || run.Job.SourcesJson != "[]")
                {
                    using var storedInputs = JsonDocument.Parse(run.Job.SourcesJson);
                    using var requestedInputs = JsonDocument.Parse(sourcesJson);
                    if (workerInput == null || run.Job.Topic != workerInput.Topic.Trim()
                        || run.BenchmarkClaimId != request.ClaimId
                        || ArtifactEnvelope.ComputeContentHash(storedInputs.RootElement)
                           != ArtifactEnvelope.ComputeContentHash(requestedInputs.RootElement))
                        throw new CheckpointValidationException(409, "Campaign case is bound to different immutable worker inputs or claim; use a new case/campaign");
                    await tx.CommitAsync(ct);
                    return ToProvisionResult(run, run.Status == "COMPLETED", operationCount, unknownCount, completedCount);
                }

                if (string.Equals(run.Status, "COMPLETED", StringComparison.OrdinalIgnoreCase))
                {
                    await tx.CommitAsync(ct);
                    return ToProvisionResult(run, alreadyCompleted: true, operationCount, unknownCount, completedCount);
                }
                if (string.Equals(run.Status, "INTERRUPTED", StringComparison.OrdinalIgnoreCase))
                {
                    await tx.CommitAsync(ct);
                    return ToProvisionResult(run, alreadyCompleted: false, operationCount, unknownCount, completedCount);
                }

                if (run.Status == "RUNNING" && run.LeaseUntil > now)
                {
                    if (!string.Equals(run.BenchmarkClaimId, request.ClaimId, StringComparison.Ordinal) ||
                        run.LeaseOwner != request.LeaseOwner)
                        throw new CheckpointValidationException(409, "Benchmark child run is leased by a different campaign claim");

                    await tx.CommitAsync(ct);
                    return ToProvisionResult(run, alreadyCompleted: false, operationCount, unknownCount, completedCount);
                }

                if (operationCount > 0)
                {
                    run.Status = "INTERRUPTED";
                    run.UpdatedAt = now;
                    run.Job.Status = "Failed";
                    run.Job.LeaseUntil = null;
                    run.Job.LeaseOwner = null;
                    run.Job.UpdatedAt = now;
                    await db.SaveChangesAsync(ct);
                    await tx.CommitAsync(ct);
                    return ToProvisionResult(run, alreadyCompleted: false, operationCount, unknownCount, completedCount);
                }

                // No provider operation was ever granted, so a new fenced epoch is safe to resume.
                run.Epoch++;
                run.BenchmarkClaimId = request.ClaimId;
                run.LeaseOwner = request.LeaseOwner;
                run.LeaseUntil = now + ChildLeaseDuration;
                run.CreatedAt = now;
                run.UpdatedAt = now;
                run.Status = "RUNNING";
                run.BudgetUsedCalls = 0;
                run.BudgetUsedTokens = 0;
                run.BudgetUsedWallTimeSeconds = 0;
                run.Job.Epoch = run.Epoch;
                run.Job.LeaseOwner = request.LeaseOwner;
                run.Job.LeaseUntil = run.LeaseUntil;
                run.Job.Status = "Running";
                run.Job.UpdatedAt = now;
                await db.SaveChangesAsync(ct);
                await tx.CommitAsync(ct);
                return ToProvisionResult(run, alreadyCompleted: false, 0, 0, 0);
            }

            var suffix = Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes($"{request.CampaignId}\n{request.CaseId}")))
                .Substring(0, 32).ToLowerInvariant();
            var runId = $"bench_{suffix}";
            var job = new ReadingPaperJob
            {
                Topic = workerInput?.Topic.Trim() ?? $"Benchmark {request.CampaignId}/{request.CaseId}",
                Status = workerInput == null ? "Running" : "Pending",
                SourcesJson = sourcesJson,
                SectionsJson = "[]",
                Logs = "Acceptance benchmark child run",
                Epoch = 1,
                LeaseOwner = workerInput == null ? request.LeaseOwner : null,
                LeaseUntil = workerInput == null ? now + ChildLeaseDuration : null,
                ActiveRunId = runId,
                CreatedAt = now,
                UpdatedAt = now
            };
            var isUnlimited = campaign.BudgetCapCalls == -1 && campaign.BudgetCapTokens == -1 && campaign.BudgetCapWallTimeSeconds == -1;
            var childProfile = isUnlimited
                ? (caps.IsBenchmarkUnlimited ? caps : caps.ToUnlimitedBenchmarkProfile())
                : caps;
            run = new ReadingPaperRun
            {
                JobId = job.Id,
                RunId = runId,
                Epoch = 1,
                Status = workerInput == null ? "RUNNING" : "QUEUED",
                LeaseOwner = job.LeaseOwner,
                LeaseUntil = job.LeaseUntil,
                SourceRevisionsJson = sourcesJson,
                EngineVersion = "2.0.0",
                BenchmarkCampaignId = request.CampaignId,
                BenchmarkCaseId = request.CaseId,
                BenchmarkClaimId = request.ClaimId,
                BudgetCapCalls = isUnlimited ? -1 : caps.BenchmarkChildRunCallCap,
                BudgetCapTokens = isUnlimited ? -1 : caps.BenchmarkChildRunTokenCap,
                BudgetCapWallTimeSeconds = isUnlimited ? -1 : caps.BenchmarkChildRunWallTimeCapSeconds,
                BudgetProfileVersion = childProfile.Version,
                BudgetProfileSha256 = childProfile.Sha256,
                BudgetProfileSource = childProfile.Source,
                BudgetProfileJson = childProfile.SnapshotJson,
                CreatedAt = now,
                UpdatedAt = now,
                Job = job
            };
            db.ReadingPaperJobs.Add(job);
            db.ReadingPaperRuns.Add(run);
            try
            {
                await db.SaveChangesAsync(ct);
                await tx.CommitAsync(ct);
            }
            catch (DbUpdateException ex) when (ex.InnerException is PostgresException { SqlState: "23505" })
            {
                await tx.RollbackAsync(ct);
                db.ChangeTracker.Clear();
                var concurrentRun = await db.ReadingPaperRuns.AsNoTracking()
                    .SingleOrDefaultAsync(x => x.BenchmarkCampaignId == request.CampaignId && x.BenchmarkCaseId == request.CaseId, ct);
                if (concurrentRun != null)
                    throw new CheckpointValidationException(409, "Benchmark case was concurrently provisioned; query its persisted state before retrying");
                throw;
            }

            run.Job = job;
            return ToProvisionResult(run, alreadyCompleted: false, 0, 0, 0);
        });
    }

    public static async Task<BenchmarkCaseProvisionResult> CompleteCaseAsync(
        ExamDbContext db,
        BenchmarkCaseCompleteRequest request,
        CancellationToken ct)
    {
        var strategy = db.Database.CreateExecutionStrategy();
        return await strategy.ExecuteAsync(async () =>
        {
            db.ChangeTracker.Clear();
            await using var tx = await db.Database.BeginTransactionAsync(ct);
            var campaignLocked = await db.ReadingPaperBenchmarkCampaigns
                .Where(x => x.CampaignId == request.CampaignId && x.Status == "AUTHORIZED")
                .ExecuteUpdateAsync(s => s.SetProperty(x => x.UpdatedAt, DateTime.UtcNow), ct);
            if (campaignLocked != 1)
                throw new CheckpointValidationException(404, $"Authorized campaign '{request.CampaignId}' was not found");

            var run = await db.ReadingPaperRuns.Include(x => x.Job)
                .SingleOrDefaultAsync(x => x.BenchmarkCampaignId == request.CampaignId && x.BenchmarkCaseId == request.CaseId, ct);
            if (run?.Job == null)
                throw new CheckpointValidationException(404, "Benchmark case was not provisioned");

            var operationCount = await db.ReadingPaperOperations.CountAsync(x => x.RunId == run.RunId, ct);
            var unknownCount = await db.ReadingPaperOperations.CountAsync(
                x => x.RunId == run.RunId && x.Status == "UNKNOWN_OUTCOME", ct);
            var completedCount = await db.ReadingPaperOperations.CountAsync(
                x => x.RunId == run.RunId && x.Status == "COMPLETED", ct);
            if (run.Status == "COMPLETED")
            {
                await tx.CommitAsync(ct);
                return ToProvisionResult(run, alreadyCompleted: true, operationCount, unknownCount, completedCount);
            }

            if (operationCount != completedCount)
                throw new CheckpointValidationException(409, "Benchmark case cannot complete with unreconciled provider operations");

            if (run.Status != "RUNNING" || run.Epoch != request.Epoch || run.LeaseOwner != request.LeaseOwner ||
                !string.Equals(run.BenchmarkClaimId, request.ClaimId, StringComparison.Ordinal) ||
                run.LeaseUntil <= DateTime.UtcNow || run.Job.Epoch != request.Epoch || run.Job.LeaseOwner != request.LeaseOwner ||
                run.Job.LeaseUntil <= DateTime.UtcNow || run.Job.Status != "Running")
                throw new CheckpointValidationException(409, "Benchmark case completion rejected by lease or epoch fencing");

            run.Status = "COMPLETED";
            run.LeaseUntil = null;
            run.UpdatedAt = DateTime.UtcNow;
            run.Job.Status = "Completed";
            run.Job.LeaseOwner = null;
            run.Job.LeaseUntil = null;
            run.Job.UpdatedAt = DateTime.UtcNow;
            await db.SaveChangesAsync(ct);
            await tx.CommitAsync(ct);
            return ToProvisionResult(run, alreadyCompleted: true, operationCount, unknownCount, completedCount);
        });
    }

    public static async Task<BenchmarkCampaignStatus> GetAsync(
        ExamDbContext db,
        string campaignId,
        CancellationToken ct)
    {
        var campaign = await db.ReadingPaperBenchmarkCampaigns.AsNoTracking()
            .SingleOrDefaultAsync(x => x.CampaignId == campaignId, ct);
        if (campaign == null)
            throw new CheckpointValidationException(404, $"Campaign '{campaignId}' was not found");

        var runs = await db.ReadingPaperRuns.AsNoTracking()
            .Where(x => x.BenchmarkCampaignId == campaignId)
            .OrderBy(x => x.BenchmarkCaseId)
            .ToListAsync(ct);
        var runIds = runs.Select(x => x.RunId).ToList();
        var operationGroups = runIds.Count == 0
            ? new Dictionary<string, (int Total, int Unknown, int Completed)>()
            : await db.ReadingPaperOperations.AsNoTracking().Where(x => runIds.Contains(x.RunId))
                .GroupBy(x => x.RunId)
                .Select(g => new
                {
                    RunId = g.Key,
                    Total = g.Count(),
                    Unknown = g.Count(x => x.Status == "UNKNOWN_OUTCOME"),
                    Completed = g.Count(x => x.Status == "COMPLETED")
                })
                .ToDictionaryAsync(x => x.RunId, x => (x.Total, x.Unknown, x.Completed), ct);

        var cases = runs.Select(run =>
        {
            var counts = operationGroups.GetValueOrDefault(run.RunId);
            return new BenchmarkCaseStatus(
                run.BenchmarkCaseId ?? string.Empty,
                run.RunId,
                run.Status,
                run.Epoch,
                run.BudgetCapCalls,
                run.BudgetUsedCalls,
                run.BudgetCapTokens,
                run.BudgetUsedTokens,
                run.BudgetCapWallTimeSeconds,
                run.BudgetUsedWallTimeSeconds,
                counts.Total,
                counts.Unknown,
                counts.Completed);
        }).ToList();
        return ToStatus(campaign, cases);
    }

    private static BenchmarkCampaignStatus EnsureSameAuthorization(
        ReadingPaperBenchmarkCampaign existing,
        BenchmarkCampaignCreateRequest request)
    {
        if (existing.AuthorizationId != request.AuthorizationId || existing.AuthorizedBy != request.AuthorizedBy ||
            !string.Equals(existing.CorpusSha256, request.CorpusSha256, StringComparison.OrdinalIgnoreCase) ||
            !string.Equals(existing.ConfigSha256, request.ConfigSha256, StringComparison.OrdinalIgnoreCase) ||
            existing.BudgetCapCalls != request.BudgetCapCalls || existing.BudgetCapTokens != request.BudgetCapTokens ||
            existing.BudgetCapWallTimeSeconds != request.BudgetCapWallTimeSeconds)
            throw new CheckpointValidationException(409, "Campaign ID is already bound to a different authorization, corpus, config, or budget");
        return ToStatus(existing, []);
    }

    private static BenchmarkCampaignStatus ToStatus(
        ReadingPaperBenchmarkCampaign campaign,
        List<BenchmarkCaseStatus> cases)
        => new(campaign.CampaignId, campaign.AuthorizationId, campaign.AuthorizedBy,
            campaign.CorpusSha256, campaign.ConfigSha256, campaign.Status,
            campaign.BudgetCapCalls, campaign.BudgetUsedCalls,
            campaign.BudgetCapTokens, campaign.BudgetUsedTokens,
            campaign.BudgetCapWallTimeSeconds, campaign.BudgetUsedWallTimeSeconds,
            campaign.CreatedAt, campaign.UpdatedAt,
            campaign.BudgetBreachDetected, campaign.BudgetBreachReason, cases);

    private static BenchmarkCaseProvisionResult ToProvisionResult(
        ReadingPaperRun run,
        bool alreadyCompleted,
        int operationCount,
        int unknownCount,
        int completedCount)
        => new(run.BenchmarkCampaignId ?? string.Empty, run.BenchmarkCaseId ?? string.Empty,
            run.RunId, run.JobId, run.Status, run.Epoch, run.LeaseOwner ?? Guid.Empty,
            run.BenchmarkClaimId ?? string.Empty, run.LeaseUntil, alreadyCompleted,
            operationCount, unknownCount, completedCount);
}

public sealed record BenchmarkCampaignStatus(
    string CampaignId,
    string AuthorizationId,
    string AuthorizedBy,
    string CorpusSha256,
    string ConfigSha256,
    string Status,
    int BudgetCapCalls,
    int BudgetUsedCalls,
    int BudgetCapTokens,
    int BudgetUsedTokens,
    double BudgetCapWallTimeSeconds,
    double BudgetUsedWallTimeSeconds,
    DateTime CreatedAt,
    DateTime UpdatedAt,
    bool BudgetBreachDetected,
    string? BudgetBreachReason,
    List<BenchmarkCaseStatus> Cases);

public sealed record BenchmarkCaseStatus(
    string CaseId,
    string RunId,
    string Status,
    int Epoch,
    int RunCallCap,
    int RunCallsUsed,
    int RunTokenCap,
    int RunTokensUsed,
    double RunWallTimeCapSeconds,
    double RunWallTimeUsedSeconds,
    int OperationCount,
    int UnknownOperationCount,
    int CompletedOperationCount);

public sealed record BenchmarkCaseProvisionResult(
    string CampaignId,
    string CaseId,
    string RunId,
    Guid JobId,
    string Status,
    int Epoch,
    Guid LeaseOwner,
    string ClaimId,
    DateTime? LeaseUntil,
    bool AlreadyCompleted,
    int OperationCount,
    int UnknownOperationCount,
    int CompletedOperationCount);
