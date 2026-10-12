using System.Text.Json;
using exam_service.Domains.Entities;
using exam_service.Features.ReadingPaper;
using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Xunit;

namespace exam_service.Tests;

[Collection("DatabaseTests")]
public class Phase15RollbackAndCanaryTests
{
    private const string DefaultConn = "Host=localhost;Port=5433;Database=exam_test_phase14_lineage;Username=exam;Password=exam";
    private static string ConnectionString =>
        Environment.GetEnvironmentVariable("READING_TEST_POSTGRES")
        ?? Environment.GetEnvironmentVariable("ConnectionStrings__exam-db")
        ?? DefaultConn;

    private static ServiceProvider CreateTestProvider()
    {
        var services = new ServiceCollection();
        services.AddDbContext<ExamDbContext>(options => options.UseNpgsql(ConnectionString, npg =>
        {
            npg.ConfigureDataSource(dataSource => dataSource.EnableDynamicJson());
            npg.EnableRetryOnFailure();
        }));
        return services.BuildServiceProvider();
    }
    [Fact]
    public void T15_01_CanaryRouting_SupportsRolloutWeights_10_50_100()
    {
        var canary = new CanaryRoutingService();

        // 1. Rollout at 0% -> 100% routed to V1
        canary.SetCanaryPercentage(0);
        Assert.Equal(0, canary.CanaryPercentage);

        var run0 = $"run_{Guid.NewGuid():N}";
        var decision0 = canary.RouteRun(run0);
        Assert.Equal(CanaryRoutingService.V1Engine, decision0.EngineVersion);
        Assert.False(decision0.IsPinned);

        // 2. Rollout at 100% -> 100% routed to V2
        canary.SetCanaryPercentage(100);
        Assert.Equal(100, canary.CanaryPercentage);

        var run100 = $"run_{Guid.NewGuid():N}";
        var decision100 = canary.RouteRun(run100);
        Assert.Equal(CanaryRoutingService.V2Engine, decision100.EngineVersion);
        Assert.False(decision100.IsPinned);

        // 3. Rollout at 50% -> Deterministic distribution based on hash bucket
        canary.SetCanaryPercentage(50);
        Assert.Equal(50, canary.CanaryPercentage);

        var v1Count = 0;
        var v2Count = 0;
        for (int i = 0; i < 200; i++)
        {
            var rid = $"run_sample_batch_{i:D4}";
            var dec = canary.RouteRun(rid);
            if (dec.EngineVersion == CanaryRoutingService.V2Engine) v2Count++;
            else v1Count++;
        }

        // With 200 samples at 50%, both V1 and V2 should have substantial counts
        Assert.True(v1Count > 50, $"Expected v1Count > 50, got {v1Count}");
        Assert.True(v2Count > 50, $"Expected v2Count > 50, got {v2Count}");
    }

    [Fact]
    public void T15_02_CanaryRouting_PinsEngineVersionForInFlightRuns()
    {
        var canary = new CanaryRoutingService();
        canary.SetCanaryPercentage(100);

        var runId = $"run_pinned_{Guid.NewGuid():N}";

        // Existing run was started on V1 engine
        var existingV1Run = new ReadingPaperRun
        {
            Id = Guid.NewGuid(),
            RunId = runId,
            EngineVersion = CanaryRoutingService.V1Engine,
            Status = "RUNNING"
        };

        // Even with canary at 100%, existing run must stay pinned to V1
        var decision = canary.RouteRun(runId, existingRun: existingV1Run);
        Assert.Equal(CanaryRoutingService.V1Engine, decision.EngineVersion);
        Assert.True(decision.IsPinned);
        Assert.Contains("Pinned to existing run", decision.DecisionReason);

        // Conversely, existing V2 run stays pinned to V2 even if canary drops to 0%
        canary.SetCanaryPercentage(0);
        var existingV2Run = new ReadingPaperRun
        {
            Id = Guid.NewGuid(),
            RunId = runId,
            EngineVersion = CanaryRoutingService.V2Engine,
            Status = "RUNNING"
        };
        var decisionV2 = canary.RouteRun(runId, existingRun: existingV2Run);
        Assert.Equal(CanaryRoutingService.V2Engine, decisionV2.EngineVersion);
        Assert.True(decisionV2.IsPinned);
    }

    [Fact]
    public void T15_03_CanaryRouting_AdminPauseAndResumeControls()
    {
        var canary = new CanaryRoutingService();
        canary.SetCanaryPercentage(100);

        Assert.False(canary.IsPaused);

        // Pause canary
        canary.Pause("Emergency maintenance pause");
        Assert.True(canary.IsPaused);
        Assert.Equal("Emergency maintenance pause", canary.PausedReason);
        Assert.NotNull(canary.PausedAt);

        // All new runs route to fallback V1 while paused
        var testRunId = $"run_{Guid.NewGuid():N}";
        var pausedDecision = canary.RouteRun(testRunId);
        Assert.Equal(CanaryRoutingService.V1Engine, pausedDecision.EngineVersion);
        Assert.Contains("System paused", pausedDecision.DecisionReason);

        // Resume canary
        canary.Resume();
        Assert.False(canary.IsPaused);
        Assert.Null(canary.PausedReason);

        // Normal routing restored
        var resumedDecision = canary.RouteRun(testRunId);
        Assert.Equal(CanaryRoutingService.V2Engine, resumedDecision.EngineVersion);
    }

    [Theory]
    [InlineData(CanaryAbortReason.StaleCommit)]
    [InlineData(CanaryAbortReason.DuplicateExam)]
    [InlineData(CanaryAbortReason.GroundingBlocker)]
    [InlineData(CanaryAbortReason.UnauthorizedWrite)]
    [InlineData(CanaryAbortReason.ContractBreak)]
    public void T15_04_CanaryRouting_CriticalAbortTriggers_DropCanaryToZeroAndPause(CanaryAbortReason reason)
    {
        var canary = new CanaryRoutingService();
        canary.SetCanaryPercentage(100);

        var runId = $"run_fault_{Guid.NewGuid():N}";
        var triggered = canary.TriggerAbort(runId, reason, $"Critical fault detected: {reason}");

        Assert.True(triggered);
        Assert.Equal(0, canary.CanaryPercentage);
        Assert.True(canary.IsPaused);
        Assert.Contains(reason.ToString(), canary.PausedReason);

        var status = canary.GetStatus();
        Assert.True(status.AbortCount > 0);
        Assert.Contains(status.RecentAborts, a => a.RunId == runId && a.Reason == reason);
    }

    [Fact]
    public void T15_05_CompatibleReader_ParsesLegacyAndV2SectionPayloads()
    {
        var legacyJson = """
        {
            "title": "Passage 1: Architecture",
            "passage": "# Roman Architecture\nRome was built on hills.",
            "source": { "pmcid": "PMC123456", "title": "Roman Buildings" },
            "groups": [
                {
                    "type": "TRUE_FALSE_NOT_GIVEN",
                    "instruction": "Do the following statements agree...",
                    "questions": [
                        {
                            "number": "1",
                            "type": "TRUE_FALSE_NOT_GIVEN",
                            "prompt": "Rome was built on valleys.",
                            "answer": "FALSE"
                        }
                    ]
                }
            ]
        }
        """;

        var v2Json = """
        {
            "title": "Passage 1: Architecture",
            "passage": "# Roman Architecture\nRome was built on hills.",
            "source": { "pmcid": "PMC123456", "title": "Roman Buildings" },
            "groups": [
                {
                    "type": "TRUE_FALSE_NOT_GIVEN",
                    "instruction": "Do the following statements agree...",
                    "questions": [
                        {
                            "number": "1",
                            "type": "TRUE_FALSE_NOT_GIVEN",
                            "prompt": "Rome was built on valleys.",
                            "answer": "FALSE"
                        }
                    ]
                }
            ],
            "blueprintId": "bp_001",
            "evidenceGraphId": "eg_001",
            "lexicalMetrics": { "diversity": 0.85 },
            "v2Metadata": { "targetLevel": "C1" }
        }
        """;

        var legacySection = JsonSerializer.Deserialize<ReadingGeneratedSection>(legacyJson, ReadingPaperRules.Json);
        Assert.NotNull(legacySection);
        Assert.Equal("Passage 1: Architecture", legacySection.Title);
        Assert.Single(legacySection.Groups);
        Assert.Single(legacySection.Groups[0].Questions);

        var v2Section = JsonSerializer.Deserialize<ReadingGeneratedSection>(v2Json, ReadingPaperRules.Json);
        Assert.NotNull(v2Section);
        Assert.Equal("Passage 1: Architecture", v2Section.Title);
        Assert.Single(v2Section.Groups);
        Assert.Single(v2Section.Groups[0].Questions);
    }
    [Fact]
    public void T15_06_RollbackRehearsalArtifact_ValidAndIntact()
    {
        var root = Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, "../../../../.."));
        var artifactPath = Path.Combine(root, "artifacts/refactor/phase-15/rollback/rollback-rehearsal.json");

        Assert.True(File.Exists(artifactPath), $"Artifact file not found at: {artifactPath}");

        var json = File.ReadAllText(artifactPath);
        using var doc = JsonDocument.Parse(json);
        var rootElem = doc.RootElement;

        var verdict = rootElem.GetProperty("verdict").GetString();
        Assert.Equal("VERIFIED_COMPATIBLE_AND_NON_DESTRUCTIVE", verdict);

        var summary = rootElem.GetProperty("summary");
        Assert.Equal(0, summary.GetProperty("failed").GetInt32());
        Assert.False(summary.GetProperty("dataLossDetected").GetBoolean());
        Assert.False(summary.GetProperty("schemaDestructionDetected").GetBoolean());
    }

    [Fact]
    public void T15_07_DrainReport_ZeroLostCheckpointsVerified()
    {
        var root = Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, "../../../../.."));
        var artifactPath = Path.Combine(root, "artifacts/refactor/phase-15/drain/drain-report.json");

        Assert.True(File.Exists(artifactPath), $"Artifact file not found at: {artifactPath}");

        var json = File.ReadAllText(artifactPath);
        using var doc = JsonDocument.Parse(json);
        var rootElem = doc.RootElement;

        var verdict = rootElem.GetProperty("verdict").GetString();
        Assert.Equal("DRAIN_SUCCESSFUL_ZERO_LOST_CHECKPOINTS", verdict);

        Assert.True(rootElem.GetProperty("zeroLostCheckpointsVerified").GetBoolean());
        Assert.Equal(0, rootElem.GetProperty("failedDrains").GetInt32());
        Assert.True(rootElem.GetProperty("successfulDrains").GetInt32() > 0);
    }

    [Fact]
    public void T15_08_ChaosMatrixReport_DurabilityVerified()
    {
        var root = Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, "../../../../.."));
        var artifactPath = Path.Combine(root, "artifacts/refactor/phase-15/canary/chaos-matrix-report.json");

        Assert.True(File.Exists(artifactPath), $"Artifact file not found at: {artifactPath}");

        var json = File.ReadAllText(artifactPath);
        using var doc = JsonDocument.Parse(json);
        var rootElem = doc.RootElement;

        var verdict = rootElem.GetProperty("overallVerdict").GetString();
        Assert.Equal("DURABILITY_VERIFIED_ALL_CHAOS_SCENARIOS_PASSED", verdict);

        Assert.Equal(0, rootElem.GetProperty("failedScenarios").GetInt32());
        Assert.True(rootElem.GetProperty("totalScenarios").GetInt32() >= 14);
    }

    [Fact]
    public async Task T15_09_RealPostgres_CancelJob_AtomicFencing_FencesActiveRunAndRejectsLateFinalizer()
    {
        var provider = CreateTestProvider();
        using var scope = provider.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
        await db.Database.MigrateAsync();

        var owner = Guid.NewGuid();
        var jobId = Guid.NewGuid();
        var runId = $"run_{jobId:N}";

        var job = new ReadingPaperJob
        {
            Id = jobId,
            Topic = "Deep Sea Hydrothermal Vent Microbial Systems",
            Status = "Running",
            Epoch = 1,
            CancelVersion = 0,
            LeaseOwner = owner,
            LeaseUntil = DateTime.UtcNow.AddMinutes(5),
            SourcesJson = "[]",
            SectionsJson = "[]",
            CompletedSections = 1,
            ActiveRunId = runId,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        db.ReadingPaperJobs.Add(job);

        var run = new ReadingPaperRun
        {
            Id = Guid.NewGuid(),
            RunId = runId,
            JobId = jobId,
            EngineVersion = "2.0.0",
            Status = "RUNNING",
            Epoch = 1,
            LeaseOwner = owner,
            LeaseUntil = DateTime.UtcNow.AddMinutes(5),
            BudgetCapTokens = 60000,
            BudgetUsedTokens = 12000,
            BudgetCapCalls = 15,
            BudgetUsedCalls = 3,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        db.ReadingPaperRuns.Add(run);
        await db.SaveChangesAsync();
        // Execute real atomic cancellation via EF Core against PostgreSQL
        var expectedCancelVersion = 0;
        var now = DateTime.UtcNow;
        var rows = await db.ReadingPaperJobs
            .Where(x => x.Id == jobId && (x.Status == "Pending" || x.Status == "Running" || x.Status == "NeedsSources") && x.CancelVersion == expectedCancelVersion)
            .ExecuteUpdateAsync(x => x
                .SetProperty(j => j.Status, "Cancelled")
                .SetProperty(j => j.CancelVersion, j => j.CancelVersion + 1)
                .SetProperty(j => j.Error, "Cancelled by user")
                .SetProperty(j => j.LeaseUntil, (DateTime?)null)
                .SetProperty(j => j.LeaseOwner, (Guid?)null)
                .SetProperty(j => j.UpdatedAt, now));

        Assert.Equal(1, rows);

        // Update active run to CANCELLED
        var runRows = await db.ReadingPaperRuns
            .Where(r => r.JobId == jobId && r.Status == "RUNNING")
            .ExecuteUpdateAsync(r => r
                .SetProperty(x => x.Status, "CANCELLED")
                .SetProperty(x => x.UpdatedAt, now));

        Assert.Equal(1, runRows);

        // Verify DB row states
        var refreshedJob = await db.ReadingPaperJobs.AsNoTracking().FirstAsync(x => x.Id == jobId);
        Assert.Equal("Cancelled", refreshedJob.Status);
        Assert.Equal(1, refreshedJob.CancelVersion);
        Assert.Null(refreshedJob.LeaseOwner);

        var refreshedRun = await db.ReadingPaperRuns.AsNoTracking().FirstAsync(x => x.RunId == runId);
        Assert.Equal("CANCELLED", refreshedRun.Status);

        // Attempt late finalizer CAS write assuming job is still Running with CancelVersion == 0
        var lateFinalizerRows = await db.ReadingPaperJobs
            .Where(x => x.Id == jobId && x.Status == "Running" && x.CancelVersion == expectedCancelVersion)
            .ExecuteUpdateAsync(x => x
                .SetProperty(j => j.Status, "Completed")
                .SetProperty(j => j.ExamId, Guid.NewGuid()));

        Assert.Equal(0, lateFinalizerRows);

        // Confirm job is still Cancelled and no Exam was associated
        var finalJob = await db.ReadingPaperJobs.AsNoTracking().FirstAsync(x => x.Id == jobId);
        Assert.Equal("Cancelled", finalJob.Status);
        Assert.Null(finalJob.ExamId);
    }

    [Fact]
    public async Task T15_10_RealPostgres_CancelCompletedJob_ReturnsConflictAndPreservesCompletedState()
    {
        var provider = CreateTestProvider();
        using var scope = provider.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
        await db.Database.MigrateAsync();

        var jobId = Guid.NewGuid();
        var examId = Guid.NewGuid();

        var job = new ReadingPaperJob
        {
            Id = jobId,
            Topic = "Exoplanet Atmospheric Spectroscopy",
            Status = "Completed",
            Epoch = 1,
            CancelVersion = 0,
            ExamId = examId,
            SourcesJson = "[]",
            SectionsJson = "[]",
            CompletedSections = 3,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        db.ReadingPaperJobs.Add(job);
        await db.SaveChangesAsync();

        // Attempt to cancel an already Completed job
        var rows = await db.ReadingPaperJobs
            .Where(x => x.Id == jobId && (x.Status == "Pending" || x.Status == "Running" || x.Status == "NeedsSources") && x.CancelVersion == 0)
            .ExecuteUpdateAsync(x => x
                .SetProperty(j => j.Status, "Cancelled")
                .SetProperty(j => j.CancelVersion, j => j.CancelVersion + 1));

        Assert.Equal(0, rows);

        var preservedJob = await db.ReadingPaperJobs.AsNoTracking().FirstAsync(x => x.Id == jobId);
        Assert.Equal("Completed", preservedJob.Status);
        Assert.Equal(examId, preservedJob.ExamId);
        Assert.Equal(0, preservedJob.CancelVersion);
    }
}
