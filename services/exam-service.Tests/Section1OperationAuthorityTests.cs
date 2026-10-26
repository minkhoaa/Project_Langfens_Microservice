using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using exam_service.Domains.Entities;
using exam_service.Features.ReadingPaper;
using exam_service.Features.ReadingPaper.Contracts;
using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace exam_service.Tests;

// Deliberately not part of any destructive shared fixture. The operator must
// explicitly select this class and supply the session-owned disposable database.
public class Section1OperationAuthorityTests
{
    private static ExamDbContext Open()
    {
        var connection = Environment.GetEnvironmentVariable("READING_CLOSURE_TEST_POSTGRES")
            ?? throw new InvalidOperationException("Explicit disposable PostgreSQL DSN required");
        var parsed = new Npgsql.NpgsqlConnectionStringBuilder(connection);
        var closureTarget = parsed.Database == "section1_closure" && parsed.Host == "127.0.0.1" && parsed.Port == 55449;
        var verifiedPipelineTarget = parsed.Database == "section1_pipeline" && parsed.Port == 5432 &&
            parsed.Host == Environment.GetEnvironmentVariable("SECTION1_PIPELINE_RESOURCE_HOST") &&
            Environment.GetEnvironmentVariable("SECTION1_PIPELINE_RESOURCE_VERIFIED")?.StartsWith(
                "section1-pipeline-postgres-", StringComparison.Ordinal) == true;
        if (!closureTarget && !verifiedPipelineTarget)
            throw new InvalidOperationException("Only the explicitly verified disposable Section1 database is authorized");
        var options = new DbContextOptionsBuilder<ExamDbContext>().UseNpgsql(connection, n =>
            n.ConfigureDataSource(source => source.EnableDynamicJson())).Options;
        return new ExamDbContext(options);
    }

    private static async Task<(string Run, Guid Owner)> Seed(ExamDbContext db)
    {
        await db.Database.MigrateAsync();
        var owner = Guid.NewGuid();
        var id = Guid.NewGuid();
        var runId = $"run_{id:N}";
        const string version = "section1-offline-contract-v1";
        const string source = "Section1OperationAuthorityTests";
        var profile = JsonSerializer.Serialize(new SortedDictionary<string, object>(StringComparer.Ordinal) {
            ["caps"] = new SortedDictionary<string, int>(StringComparer.Ordinal) {
                ["standaloneRunBudgetCapCalls"] = 75, ["standaloneRunBudgetCapTokens"] = 380000,
                ["standaloneRunBudgetCapWallTimeSeconds"] = 900 },
            ["profileSource"] = source, ["profileVersion"] = version });
        var job = new ReadingPaperJob { Id = id, ActiveRunId = runId, Topic = "Offline Section 1",
            Status = "Running", LeaseOwner = owner, LeaseUntil = DateTime.UtcNow.AddMinutes(10), Epoch = 1,
            SourcesJson = "[]", SectionsJson = "[]", Logs = "Offline contract only",
            EngineVersion = "2.0.0", SchemaVersion = "2.0.0", PolicyVersion = "2.0.0",
            CreatedAt = DateTime.UtcNow, UpdatedAt = DateTime.UtcNow };
        db.ReadingPaperJobs.Add(job);
        db.ReadingPaperRuns.Add(new ReadingPaperRun { Id = Guid.NewGuid(), JobId = id, RunId = runId,
            Status = "RUNNING", LeaseOwner = owner, LeaseUntil = job.LeaseUntil, Epoch = 1,
            EngineVersion = "2.0.0", SchemaVersion = "2.0.0", PolicyVersion = "2.0.0",
            BudgetCapCalls = 75, BudgetCapTokens = 380000, BudgetCapWallTimeSeconds = 900,
            BudgetProfileVersion = version, BudgetProfileSource = source, BudgetProfileJson = profile,
            BudgetProfileSha256 = Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(profile))).ToLowerInvariant(),
            CreatedAt = DateTime.UtcNow, UpdatedAt = DateTime.UtcNow });
        await db.SaveChangesAsync();
        return (runId, owner);
    }

    private static OperationGrantRequest Grant(string run, Guid owner, string id, int tokens, double wall = 60,
        string? parent = null, int epoch = 1, string section = "1") => new(run, epoch, owner, id,
            parent is null ? "EVALUATE" : "PROVIDER_CALL", $"hash_{id}", TokenReservation: tokens,
            WallTimeReservationSeconds: wall, SectionId: section, ArtifactId: $"question:{run}:5", ParentOperationId: parent);

    [Fact]
    public async Task Sequential_10k_Evaluation_Refunds_And_Counts_Only_Two_Physical_Calls()
    {
        await using var db = Open();
        var (run, owner) = await Seed(db);
        await CheckpointService.GrantOperationAsync(db, Grant(run, owner, "evaluate", 10000), default);
        await CheckpointService.GrantOperationAsync(db, Grant(run, owner, "solve", 7369, parent: "evaluate"), default);
        var reconcile = new OperationReconcileRequest(run, 1, owner, "solve", TokensUsed: 1923,
            WallTimeUsedSeconds: 5, AccountingType: "REPORTED", ResultRefJson: "{\"response\":\"solver\"}");
        await CheckpointService.ReconcileOperationAsync(db, reconcile, default);
        await CheckpointService.ReconcileOperationAsync(db, reconcile, default); // idempotent, no double refund
        var tooMuchWall = await Assert.ThrowsAsync<CheckpointValidationException>(() =>
            CheckpointService.GrantOperationAsync(db, Grant(run, owner, "adv_bad_wall", 7504, parent: "evaluate"), default));
        Assert.Equal(422, tooMuchWall.StatusCode);
        await CheckpointService.GrantOperationAsync(db, Grant(run, owner, "adv", 7504, 55, "evaluate"), default);
        await CheckpointService.ReconcileOperationAsync(db, new OperationReconcileRequest(run, 1, owner, "adv",
            TokensUsed: 2259, WallTimeUsedSeconds: 6, AccountingType: "REPORTED", ResultRefJson: "{}"), default);
        await CheckpointService.ReconcileOperationAsync(db, new OperationReconcileRequest(run, 1, owner, "evaluate",
            TokensUsed: 0, WallTimeUsedSeconds: 11, AccountingType: "REPORTED"), default);
        var replay = await CheckpointService.GrantOperationAsync(db, Grant(run, owner, "adv", 7504, 55, "evaluate"), default);
        Assert.True(replay.IsReplay);
        Assert.Equal("COMPLETED", replay.Status);
        var saved = await db.ReadingPaperRuns.AsNoTracking().SingleAsync(r => r.RunId == run);
        Assert.Equal(4182, saved.BudgetUsedTokens);
        Assert.Equal(2, saved.BudgetUsedCalls);
        Assert.Equal(11, saved.BudgetUsedWallTimeSeconds);
    }

    [Theory]
    [InlineData("ESTIMATED")]
    [InlineData("UNKNOWN")]
    public async Task Uncertain_Completed_Usage_Cannot_Fund_Next_Child(string accounting)
    {
        await using var db = Open();
        var (run, owner) = await Seed(db);
        await CheckpointService.GrantOperationAsync(db, Grant(run, owner, "evaluate", 10000), default);
        await CheckpointService.GrantOperationAsync(db, Grant(run, owner, "solve", 7369, parent: "evaluate"), default);
        await CheckpointService.ReconcileOperationAsync(db, new OperationReconcileRequest(run, 1, owner, "solve",
            TokensUsed: accounting == "UNKNOWN" ? 0 : 1923, WallTimeUsedSeconds: 5, AccountingType: accounting), default);
        var blocked = await Assert.ThrowsAsync<CheckpointValidationException>(() =>
            CheckpointService.GrantOperationAsync(db, Grant(run, owner, "adv", 7504, 55, "evaluate"), default));
        Assert.Equal(422, blocked.StatusCode);
        var saved = await db.ReadingPaperRuns.AsNoTracking().SingleAsync(r => r.RunId == run);
        Assert.Equal(7369, saved.BudgetUsedTokens);
        Assert.Equal(1, saved.BudgetUsedCalls);
    }

    [Fact]
    public async Task Unknown_Timeout_Retains_Reservation_Across_Restart_And_Fences_New_Work()
    {
        string run; Guid owner;
        await using (var db = Open())
        {
            (run, owner) = await Seed(db);
            await CheckpointService.GrantOperationAsync(db, Grant(run, owner, "evaluate", 10000), default);
            await CheckpointService.GrantOperationAsync(db, Grant(run, owner, "solve", 7369, parent: "evaluate"), default);
            var request = new UnknownOutcomeRequest(run, 1, owner, "solve", "Mock transport timed out; no replay authorized");
            await CheckpointService.RecordUnknownOutcomeAsync(db, request, default);
            await CheckpointService.RecordUnknownOutcomeAsync(db, request, default);
        }
        await using var restarted = Open();
        var replay = await CheckpointService.GrantOperationAsync(restarted, Grant(run, owner, "solve", 7369, parent: "evaluate"), default);
        Assert.True(replay.IsReplay);
        Assert.Equal("UNKNOWN_OUTCOME", replay.Status);
        var blocked = await Assert.ThrowsAsync<CheckpointValidationException>(() =>
            CheckpointService.GrantOperationAsync(restarted, Grant(run, owner, "adv", 7504, 1, "evaluate"), default));
        Assert.Equal(422, blocked.StatusCode);
        var fenced = await Assert.ThrowsAsync<CheckpointValidationException>(() =>
            CheckpointService.GrantOperationAsync(restarted, Grant(run, owner, "stale", 1, 1, "evaluate", epoch: 2), default));
        Assert.Equal(409, fenced.StatusCode);
        var wrongSection = await Assert.ThrowsAsync<CheckpointValidationException>(() =>
            CheckpointService.GrantOperationAsync(restarted, Grant(run, owner, "alias", 1, 1, "evaluate", section: "section_1"), default));
        Assert.Equal(422, wrongSection.StatusCode);
        Assert.Equal(7369, (await restarted.ReadingPaperRuns.AsNoTracking().SingleAsync(r => r.RunId == run)).BudgetUsedTokens);
    }

    [Fact]
    public async Task Repair_M3_And_Text01_Share_60_Seconds_And_Terminal_Usage_Is_Immutable()
    {
        await using var db = Open();
        var (run, owner) = await Seed(db);
        await CheckpointService.GrantOperationAsync(db, Grant(run, owner, "repair", 15000) with { OperationType = "REPAIR" }, default);
        await CheckpointService.GrantOperationAsync(db, Grant(run, owner, "m3", 1500, 30, "repair"), default);
        var m3 = new OperationReconcileRequest(run, 1, owner, "m3", TokensUsed: 360,
            WallTimeUsedSeconds: 5, AccountingType: "REPORTED", ResultRefJson: "{\"plan\":\"grounded\"}");
        await CheckpointService.ReconcileOperationAsync(db, m3, default);
        var wallError = await Assert.ThrowsAsync<CheckpointValidationException>(() =>
            CheckpointService.GrantOperationAsync(db, Grant(run, owner, "text_bad_wall", 5759, 60, "repair"), default));
        Assert.Equal(422, wallError.StatusCode);
        await CheckpointService.GrantOperationAsync(db, Grant(run, owner, "text", 5759, 55, "repair"), default);
        await CheckpointService.ReconcileOperationAsync(db, new OperationReconcileRequest(run, 1, owner, "text",
            TokensUsed: 505, WallTimeUsedSeconds: 6, AccountingType: "REPORTED", ResultRefJson: "{}"), default);
        await CheckpointService.ReconcileOperationAsync(db, m3, default);
        var changed = await Assert.ThrowsAsync<CheckpointValidationException>(() =>
            CheckpointService.ReconcileOperationAsync(db, m3 with { TokensUsed = 0 }, default));
        Assert.Equal(409, changed.StatusCode);
        var saved = await db.ReadingPaperRuns.AsNoTracking().SingleAsync(r => r.RunId == run);
        Assert.Equal(865, saved.BudgetUsedTokens);
        Assert.Equal(2, saved.BudgetUsedCalls);
        Assert.Equal(11, saved.BudgetUsedWallTimeSeconds);
    }

    [Fact]
    public async Task Historical_4k_Parent_Cannot_Authorize_7369_Token_Solver()
    {
        await using var db = Open();
        var (run, owner) = await Seed(db);
        await CheckpointService.GrantOperationAsync(db, Grant(run, owner, "evaluate", 4000), default);
        var error = await Assert.ThrowsAsync<CheckpointValidationException>(() =>
            CheckpointService.GrantOperationAsync(db, Grant(run, owner, "solve", 7369, parent: "evaluate"), default));
        Assert.Equal(422, error.StatusCode);
        Assert.Equal(0, (await db.ReadingPaperRuns.AsNoTracking().SingleAsync(r => r.RunId == run)).BudgetUsedCalls);
    }
}
