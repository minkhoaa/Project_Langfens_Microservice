using System.Net;
using System.Security.Cryptography;
using System.Text.Json;
using exam_service.Domains.Entities;
using exam_service.Features.ReadingPaper;
using exam_service.Features.ReadingPaper.Contracts;
using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Xunit;

namespace exam_service.Tests;

[Collection("DatabaseTests")]
public class Phase06DurabilityTests
{
    private const string DefaultConn = "Host=localhost;Port=5433;Database=exam_test_phase06;Username=exam;Password=exam";

    private static ServiceProvider CreateTestProvider(string connection = DefaultConn)
    {
        var services = new ServiceCollection();
        services.AddDbContext<ExamDbContext>(options => options.UseNpgsql(connection, npg =>
        {
            npg.ConfigureDataSource(dataSource => dataSource.EnableDynamicJson());
            npg.EnableRetryOnFailure();
        }));
        return services.BuildServiceProvider();
    }

    private static async Task<(ReadingPaperJob Job, ReadingPaperRun Run)> CreateJobAndRunAsync(
        ExamDbContext db,
        Guid owner,
        int epoch = 1,
        int cancelVersion = 0)
    {
        await db.Database.MigrateAsync();

        var job = new ReadingPaperJob
        {
            Id = Guid.NewGuid(),
            Topic = "Loop Engine V2 Runtime Durability Verification",
            Status = "Running",
            Epoch = epoch,
            CancelVersion = cancelVersion,
            LeaseOwner = owner,
            LeaseUntil = DateTime.UtcNow.AddMinutes(5),
            SourcesJson = "[]",
            SectionsJson = "[]",
            CompletedSections = 0,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        db.ReadingPaperJobs.Add(job);

        var runId = $"run_{job.Id:N}";
        job.ActiveRunId = runId;

        var run = new ReadingPaperRun
        {
            Id = Guid.NewGuid(),
            JobId = job.Id,
            RunId = runId,
            Epoch = epoch,
            CancelVersion = cancelVersion,
            Status = "RUNNING",
            LeaseOwner = owner,
            LeaseUntil = job.LeaseUntil,
            EngineVersion = "2.0.0",
            SchemaVersion = "2.0.0",
            PolicyVersion = "2.0.0",
            BudgetCapCalls = 25,
            BudgetCapTokens = 150000,
            BudgetUsedCalls = 0,
            BudgetUsedTokens = 0,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        db.ReadingPaperRuns.Add(run);
        await db.SaveChangesAsync();

        return (job, run);
    }

    [Fact]
    public async Task T06_01_LoopCursor_SaveAndAdvance_RevisionIncrements()
    {
        await using var provider = CreateTestProvider();
        using var scope = provider.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();

        var owner = Guid.NewGuid();
        var (job, run) = await CreateJobAndRunAsync(db, owner);

        var state1 = """{"stepIndex":1,"currentState":"DRAFTING","targetArtifactId":"passage_01"}""";
        var req1 = new LoopCursorCheckpointRequest(run.RunId, 1, owner, "passage_01", 0, state1, null);

        var result1 = await LoopCursorService.SaveAsync(db, req1, CancellationToken.None);
        Assert.Equal("passage_01", result1.ArtifactId);
        Assert.Equal(1, result1.Revision);
        Assert.Equal(state1, result1.StateJson);

        var state2 = """{"stepIndex":2,"currentState":"EVALUATING","targetArtifactId":"passage_01"}""";
        var req2 = new LoopCursorCheckpointRequest(run.RunId, 1, owner, "passage_01", 1, state2, null);

        var result2 = await LoopCursorService.SaveAsync(db, req2, CancellationToken.None);
        Assert.Equal("passage_01", result2.ArtifactId);
        Assert.Equal(2, result2.Revision);
        Assert.Equal(state2, result2.StateJson);

        var persisted = await db.ReadingPaperLoopCursors.SingleAsync(c => c.RunId == run.RunId && c.ArtifactId == "passage_01");
        Assert.Equal(2, persisted.Revision);
        Assert.Equal(state2, persisted.StateJson);
    }

    [Fact]
    public async Task T06_02_LoopCursor_Conflict_ExpectedRevisionMismatch_Throws409()
    {
        await using var provider = CreateTestProvider();
        using var scope = provider.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();

        var owner = Guid.NewGuid();
        var (job, run) = await CreateJobAndRunAsync(db, owner);

        var state1 = """{"stepIndex":1,"currentState":"DRAFTING"}""";
        var req1 = new LoopCursorCheckpointRequest(run.RunId, 1, owner, "passage_01", 0, state1, null);
        await LoopCursorService.SaveAsync(db, req1, CancellationToken.None);

        // Stale client sends expectedRevision = 0 again with different payload
        var state2 = """{"stepIndex":2,"currentState":"DIFFERENT_STATE"}""";
        var reqStale = new LoopCursorCheckpointRequest(run.RunId, 1, owner, "passage_01", 0, state2, null);

        var ex = await Assert.ThrowsAsync<CheckpointValidationException>(() =>
            LoopCursorService.SaveAsync(db, reqStale, CancellationToken.None));

        Assert.Equal(409, ex.StatusCode);
        Assert.Contains("revision conflict", ex.Message, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public async Task T06_03_LoopCursor_IdempotentReplay_SameRevisionAndPayload_ReturnsSuccess()
    {
        await using var provider = CreateTestProvider();
        using var scope = provider.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();

        var owner = Guid.NewGuid();
        var (job, run) = await CreateJobAndRunAsync(db, owner);

        var state1 = """{"stepIndex":1,"currentState":"DRAFTING"}""";
        var req1 = new LoopCursorCheckpointRequest(run.RunId, 1, owner, "passage_01", 0, state1, null);
        var res1 = await LoopCursorService.SaveAsync(db, req1, CancellationToken.None);

        // Idempotent retry with exact same expectedRevision and payload
        var resReplay = await LoopCursorService.SaveAsync(db, req1, CancellationToken.None);

        Assert.Equal(res1.Revision, resReplay.Revision);
        Assert.Equal(res1.StateJson, resReplay.StateJson);
    }

    [Fact]
    public async Task T06_04_LoopCursor_Fencing_StaleEpochOrRevokedLease_Throws409()
    {
        await using var provider = CreateTestProvider();
        using var scope = provider.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();

        var owner = Guid.NewGuid();
        var (job, run) = await CreateJobAndRunAsync(db, owner);

        // Advance job epoch simulating lease takeover
        job.Epoch = 2;
        await db.SaveChangesAsync();

        var state1 = """{"stepIndex":1,"currentState":"DRAFTING"}""";
        var staleEpochReq = new LoopCursorCheckpointRequest(run.RunId, 1, owner, "passage_01", 0, state1, null);

        var ex = await Assert.ThrowsAsync<CheckpointValidationException>(() =>
            LoopCursorService.SaveAsync(db, staleEpochReq, CancellationToken.None));

        Assert.Equal(409, ex.StatusCode);
        Assert.True(ex.Message.Contains("authority", StringComparison.OrdinalIgnoreCase) ||
                    ex.Message.Contains("Epoch fencing", StringComparison.OrdinalIgnoreCase));
    }

    [Fact]
    public async Task T06_05_LoopCursor_UnacknowledgedOperation_Throws409()
    {
        await using var provider = CreateTestProvider();
        using var scope = provider.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();

        var owner = Guid.NewGuid();
        var (job, run) = await CreateJobAndRunAsync(db, owner);

        var state1 = """{"stepIndex":1,"currentState":"DRAFTING"}""";
        // Refers to non-existent operation
        var req = new LoopCursorCheckpointRequest(run.RunId, 1, owner, "passage_01", 0, state1, "non_existent_op_id");

        var ex = await Assert.ThrowsAsync<CheckpointValidationException>(() =>
            LoopCursorService.SaveAsync(db, req, CancellationToken.None));

        Assert.Equal(409, ex.StatusCode);
        Assert.Contains("unacknowledged operation", ex.Message, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public async Task T06_06_LoopCursor_PayloadValidation_Throws422()
    {
        await using var provider = CreateTestProvider();
        using var scope = provider.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();

        var owner = Guid.NewGuid();
        var (job, run) = await CreateJobAndRunAsync(db, owner);

        // 1. Invalid JSON
        var reqMalformed = new LoopCursorCheckpointRequest(run.RunId, 1, owner, "passage_01", 0, "not_json", null);
        var ex1 = await Assert.ThrowsAsync<CheckpointValidationException>(() =>
            LoopCursorService.SaveAsync(db, reqMalformed, CancellationToken.None));
        Assert.Equal(422, ex1.StatusCode);

        // 2. JSON array instead of object
        var reqArray = new LoopCursorCheckpointRequest(run.RunId, 1, owner, "passage_01", 0, "[1, 2, 3]", null);
        var ex2 = await Assert.ThrowsAsync<CheckpointValidationException>(() =>
            LoopCursorService.SaveAsync(db, reqArray, CancellationToken.None));
        Assert.Equal(422, ex2.StatusCode);
    }

    [Fact]
    public async Task T06_07_ResumeState_ReturnsLoopCursors()
    {
        await using var provider = CreateTestProvider();
        using var scope = provider.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();

        var owner = Guid.NewGuid();
        var (job, run) = await CreateJobAndRunAsync(db, owner);

        var state = """{"stepIndex":3,"currentState":"EVALUATING","policyVersion":"2.0.0"}""";
        var req = new LoopCursorCheckpointRequest(run.RunId, 1, owner, "passage_01", 0, state, null);
        await LoopCursorService.SaveAsync(db, req, CancellationToken.None);

        var resume = await CheckpointService.ResumeStateAsync(db, run.RunId, CancellationToken.None);

        Assert.NotNull(resume.LoopCursors);
        var cursor = Assert.Single(resume.LoopCursors);
        Assert.Equal("passage_01", cursor.ArtifactId);
        Assert.Equal(1, cursor.Revision);
        Assert.Equal(state, cursor.StateJson);
    }

    [Fact]
    public async Task T06_08_DependencyInvalidation_TransitiveClosure_RemovesDescendantHeads()
    {
        await using var provider = CreateTestProvider();
        using var scope = provider.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();

        var owner = Guid.NewGuid();
        var (job, run) = await CreateJobAndRunAsync(db, owner);

        // Add artifact heads: passage_01, q_01, grp_01, unrelated_passage_02
        db.ReadingPaperArtifactHeads.AddRange(
            new ReadingPaperArtifactHead { RunId = run.RunId, ArtifactId = "passage_01", AcceptedVersion = 1, AcceptedHash = "h1" },
            new ReadingPaperArtifactHead { RunId = run.RunId, ArtifactId = "q_01", AcceptedVersion = 1, AcceptedHash = "hq1" },
            new ReadingPaperArtifactHead { RunId = run.RunId, ArtifactId = "grp_01", AcceptedVersion = 1, AcceptedHash = "hg1" },
            new ReadingPaperArtifactHead { RunId = run.RunId, ArtifactId = "unrelated_passage_02", AcceptedVersion = 1, AcceptedHash = "h2" }
        );

        // Dependencies: q_01 depends on passage_01; grp_01 depends on q_01
        db.ReadingPaperArtifactDependencies.AddRange(
            new ReadingPaperArtifactDependency { RunId = run.RunId, ArtifactId = "q_01", Version = 1, ParentArtifactId = "passage_01", ParentVersion = 1, ParentContentHash = "h1" },
            new ReadingPaperArtifactDependency { RunId = run.RunId, ArtifactId = "grp_01", Version = 1, ParentArtifactId = "q_01", ParentVersion = 1, ParentContentHash = "hq1" }
        );
        await db.SaveChangesAsync();

        var invReq = new InvalidateDependencyRequest(run.RunId, 1, owner, "passage_01", "passage repair invalidation");
        var invResult = await CheckpointService.InvalidateDependencyClosureAsync(db, invReq, CancellationToken.None);

        // Invalidation closure must include passage_01, q_01, grp_01
        Assert.Contains("passage_01", invResult.InvalidatedArtifactIds);
        Assert.Contains("q_01", invResult.InvalidatedArtifactIds);
        Assert.Contains("grp_01", invResult.InvalidatedArtifactIds);

        // Preserved must include unrelated_passage_02
        Assert.Contains("unrelated_passage_02", invResult.PreservedArtifactIds);

        // Verify database: only unrelated_passage_02 remains in heads
        var remainingHeads = await db.ReadingPaperArtifactHeads.Where(h => h.RunId == run.RunId).Select(h => h.ArtifactId).ToListAsync();
        Assert.Equal(new[] { "unrelated_passage_02" }, remainingHeads);
    }
}
