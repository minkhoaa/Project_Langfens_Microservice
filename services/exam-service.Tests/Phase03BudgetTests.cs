using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using exam_service.Domains.Entities;
using exam_service.Features.ReadingPaper;
using exam_service.Features.ReadingPaper.Contracts;
using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Xunit;

namespace exam_service.Tests;

public class Phase03BudgetTests
{
    private const string DefaultConn = "Host=localhost;Port=5433;Database=exam_test_phase02;Username=exam;Password=exam";

    private static ServiceProvider CreateTestProvider()
    {
        var services = new ServiceCollection();
        services.AddDbContext<ExamDbContext>(options => options.UseNpgsql(DefaultConn, npg =>
        {
            npg.ConfigureDataSource(dataSource => dataSource.EnableDynamicJson());
            npg.EnableRetryOnFailure();
        }));
        return services.BuildServiceProvider();
    }
    private static (string Version, string Source, string Json, string Sha256) BuildTestCapProfile(int calls, int tokens, int wallTime)
    {
        const string version = "phase03-test-v1";
        const string source = "Phase03BudgetTests";
        var caps = new SortedDictionary<string, int>(StringComparer.Ordinal)
        {
            ["standaloneRunBudgetCapCalls"] = calls,
            ["standaloneRunBudgetCapTokens"] = tokens,
            ["standaloneRunBudgetCapWallTimeSeconds"] = wallTime
        };
        var snapshot = new SortedDictionary<string, object>(StringComparer.Ordinal)
        {
            ["caps"] = caps,
            ["profileSource"] = source,
            ["profileVersion"] = version
        };
        var json = JsonSerializer.Serialize(snapshot);
        var sha = Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(json))).ToLowerInvariant();
        return (version, source, json, sha);
    }

    private static async Task<(string RunId, Guid Owner, ReadingPaperJob Job, ReadingPaperRun Run)> SeedJobAndRunAsync(
        ExamDbContext db,
        int budgetCapTokens = 150000,
        int budgetCapCalls = 25,
        int budgetCapWallTime = 900)
    {
        var testProfile = BuildTestCapProfile(budgetCapCalls, budgetCapTokens, budgetCapWallTime);
        var owner = Guid.NewGuid();
        var job = new ReadingPaperJob
        {
            Id = Guid.NewGuid(),
            Topic = "Ecosystem Restoration",
            Status = "Running",
            CompletedSections = 0,
            SourcesJson = "[]",
            SectionsJson = "[]",
            Logs = "Initial",
            LeaseOwner = owner,
            LeaseUntil = DateTime.UtcNow.AddMinutes(30),
            Epoch = 1,
            CancelVersion = 0,
            EngineVersion = "2.0.0",
            SchemaVersion = "2.0.0",
            PolicyVersion = "2.0.0",
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
            Epoch = 1,
            Status = "RUNNING",
            LeaseOwner = owner,
            LeaseUntil = job.LeaseUntil,
            CancelVersion = 0,
            EngineVersion = "2.0.0",
            SchemaVersion = "2.0.0",
            PolicyVersion = "2.0.0",
            BudgetCapCalls = budgetCapCalls,
            BudgetCapTokens = budgetCapTokens,
            BudgetCapWallTimeSeconds = budgetCapWallTime,
            BudgetProfileVersion = testProfile.Version,
            BudgetProfileSha256 = testProfile.Sha256,
            BudgetProfileSource = testProfile.Source,
            BudgetProfileJson = testProfile.Json,
            BudgetUsedCalls = 0,
            BudgetUsedTokens = 0,
            BudgetUsedWallTimeSeconds = 0.0,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        db.ReadingPaperRuns.Add(run);

        await db.SaveChangesAsync();
        return (runId, owner, job, run);
    }

    [Fact]
    public async Task T03_05_SetBudgetAllocations_HierarchyValidation_RejectsOverCapAndOrphans()
    {
        using var provider = CreateTestProvider();
        using var scope = provider.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
        await db.Database.MigrateAsync();

        var (runId, owner, _, _) = await SeedJobAndRunAsync(db, budgetCapTokens: 100000, budgetCapCalls: 20, budgetCapWallTime: 600);

        // 1. Rejects when sum of sections exceeds run token cap
        var overTokenReq = new SetBudgetAllocationsRequest(
            runId, 1, owner,
            new List<BudgetAllocationItem>
            {
                new("SECTION", "section_1", null, 60000, 5, 200),
                new("SECTION", "section_2", null, 50000, 5, 200) // 60k + 50k = 110k > 100k
            }
        );
        var exToken = await Assert.ThrowsAsync<CheckpointValidationException>(
            () => CheckpointService.SetBudgetAllocationsAsync(db, overTokenReq, default));
        Assert.Equal(422, exToken.StatusCode);
        Assert.Contains("exceeds run budget cap", exToken.Message);

        // 2. Rejects when child artifact sum exceeds parent section cap
        var overArtifactReq = new SetBudgetAllocationsRequest(
            runId, 1, owner,
            new List<BudgetAllocationItem>
            {
                new("SECTION", "section_1", null, 40000, 10, 300),
                new("ARTIFACT", "passage_section_1", "section_1", 25000, 3, 100),
                new("ARTIFACT", "questions_section_1", "section_1", 20000, 4, 150) // 25k + 20k = 45k > 40k
            }
        );
        var exArt = await Assert.ThrowsAsync<CheckpointValidationException>(
            () => CheckpointService.SetBudgetAllocationsAsync(db, overArtifactReq, default));
        Assert.Equal(422, exArt.StatusCode);
        Assert.Contains("exceeds parent section cap", exArt.Message);

        // 3. Rejects orphan artifact whose parent section is not declared
        var orphanReq = new SetBudgetAllocationsRequest(
            runId, 1, owner,
            new List<BudgetAllocationItem>
            {
                new("SECTION", "section_1", null, 40000, 10, 300),
                new("ARTIFACT", "passage_section_99", "section_99", 10000, 2, 50)
            }
        );
        var exOrphan = await Assert.ThrowsAsync<CheckpointValidationException>(
            () => CheckpointService.SetBudgetAllocationsAsync(db, orphanReq, default));
        Assert.Equal(422, exOrphan.StatusCode);
        Assert.Contains("Orphan artifact scope", exOrphan.Message);

        // 4. Rejects invalid ScopeType
        var invalidTypeReq = new SetBudgetAllocationsRequest(
            runId, 1, owner,
            new List<BudgetAllocationItem>
            {
                new("GLOBAL_CUSTOM", "scope_1", null, 10000, 2, 50)
            }
        );
        var exType = await Assert.ThrowsAsync<CheckpointValidationException>(
            () => CheckpointService.SetBudgetAllocationsAsync(db, invalidTypeReq, default));
        Assert.Equal(422, exType.StatusCode);
        Assert.Contains("Invalid scopeType", exType.Message);
    }

    [Fact]
    public async Task T03_05_SetBudgetAllocations_ImmutableOnceOperationsExist_RejectsMutation()
    {
        using var provider = CreateTestProvider();
        using var scope = provider.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
        await db.Database.MigrateAsync();

        var (runId, owner, _, _) = await SeedJobAndRunAsync(db);

        // Initial setup of valid budget allocations
        var initialAllocs = new List<BudgetAllocationItem>
        {
            new("SECTION", "section_1", null, 45000, 8, 280),
            new("ARTIFACT", "passage_section_1", "section_1", 15000, 2, 90),
            new("ARTIFACT", "questions_section_1", "section_1", 18000, 3, 100),
            new("ARTIFACT", "solver_section_1", "section_1", 6000, 2, 50),
            new("ARTIFACT", "review_section_1", "section_1", 6000, 1, 40)
        };

        var res = await CheckpointService.SetBudgetAllocationsAsync(
            db, new SetBudgetAllocationsRequest(runId, 1, owner, initialAllocs), default);
        Assert.Equal(5, res.AllocationsCount);

        // Perform an initial operation grant
        var grantRes = await CheckpointService.GrantOperationAsync(
            db,
            new OperationGrantRequest(
                runId, 1, owner, $"op_initial_{Guid.NewGuid():N}", "PROVIDER_CALL", "hash_init",
                TokenReservation: 3000, WallTimeReservationSeconds: 45.0,
                SectionId: "section_1", ArtifactId: "passage_section_1"
            ),
            default
        );
        Assert.False(grantRes.IsReplay);

        // Now attempt to raise section_1 cap mid-run
        var mutatedAllocs = new List<BudgetAllocationItem>
        {
            new("SECTION", "section_1", null, 60000, 10, 350), // Raised!
            new("ARTIFACT", "passage_section_1", "section_1", 20000, 3, 120),
            new("ARTIFACT", "questions_section_1", "section_1", 20000, 4, 130)
        };

        var exMutate = await Assert.ThrowsAsync<CheckpointValidationException>(
            () => CheckpointService.SetBudgetAllocationsAsync(db, new SetBudgetAllocationsRequest(runId, 1, owner, mutatedAllocs), default));
        Assert.Equal(409, exMutate.StatusCode);
        Assert.Contains("immutable once operations have commenced", exMutate.Message);

        // Idempotent retry with exact same initial allocations succeeds
        var replayRes = await CheckpointService.SetBudgetAllocationsAsync(
            db, new SetBudgetAllocationsRequest(runId, 1, owner, initialAllocs), default);
        Assert.Equal(5, replayRes.AllocationsCount);
    }

    [Fact]
    public async Task T03_05_ConcurrentCandidates_NearSectionCap_OnlyRequestsWithinAllocationSucceed()
    {
        using var provider = CreateTestProvider();
        using var scope = provider.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
        await db.Database.MigrateAsync();

        var (runId, owner, _, _) = await SeedJobAndRunAsync(db);

        // Configure section_1 with cap of 5,000 tokens
        var allocs = new List<BudgetAllocationItem>
        {
            new("SECTION", "section_1", null, 5000, 10, 300),
            new("ARTIFACT", "passage_section_1", "section_1", 5000, 10, 300)
        };
        await CheckpointService.SetBudgetAllocationsAsync(
            db, new SetBudgetAllocationsRequest(runId, 1, owner, allocs), default);

        // Two competing candidates each request 3,000 tokens for section_1 concurrently.
        // Total requested = 6,000 > 5,000. Exactly ONE must succeed and the other must fail with HTTP 422!
        var t1 = Task.Run(async () =>
        {
            using var s1 = provider.CreateScope();
            var db1 = s1.ServiceProvider.GetRequiredService<ExamDbContext>();
            try
            {
                var r = await CheckpointService.GrantOperationAsync(
                    db1,
                    new OperationGrantRequest(
                        runId, 1, owner, $"op_cand1_{Guid.NewGuid():N}", "PROVIDER_CALL", "hash_cand1",
                        TokenReservation: 3000, SectionId: "section_1", ArtifactId: "passage_section_1"
                    ),
                    default
                );
                return (Success: true, Status: 200, Error: string.Empty);
            }
            catch (CheckpointValidationException ex)
            {
                return (Success: false, Status: ex.StatusCode, Error: ex.Message);
            }
        });

        var t2 = Task.Run(async () =>
        {
            using var s2 = provider.CreateScope();
            var db2 = s2.ServiceProvider.GetRequiredService<ExamDbContext>();
            try
            {
                var r = await CheckpointService.GrantOperationAsync(
                    db2,
                    new OperationGrantRequest(
                        runId, 1, owner, $"op_cand2_{Guid.NewGuid():N}", "PROVIDER_CALL", "hash_cand2",
                        TokenReservation: 3000, SectionId: "section_1", ArtifactId: "passage_section_1"
                    ),
                    default
                );
                return (Success: true, Status: 200, Error: string.Empty);
            }
            catch (CheckpointValidationException ex)
            {
                return (Success: false, Status: ex.StatusCode, Error: ex.Message);
            }
        });

        var results = await Task.WhenAll(t1, t2);
        var successCount = results.Count(r => r.Success);
        var failCount = results.Count(r => !r.Success && r.Status == 422);

        Assert.Equal(1, successCount);
        Assert.Equal(1, failCount);

        var failedResult = results.First(r => !r.Success);
        Assert.Contains("Section budget exhausted", failedResult.Error);

        // Verify total reserved in DB is exactly 3000 <= 5000
        var totalAllocated = await db.ReadingPaperOperations
            .Where(o => o.RunId == runId && o.SectionId == "section_1")
            .SumAsync(o => o.TokenReservation);
        Assert.Equal(3000, totalAllocated);
    }

    [Fact]
    public async Task T03_06_UnknownOutcome_PreservesReservation_NoFreeRetry()
    {
        using var provider = CreateTestProvider();
        using var scope = provider.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
        await db.Database.MigrateAsync();

        var (runId, owner, _, _) = await SeedJobAndRunAsync(db);

        // Configure section_1 cap = 4,000 tokens
        var allocs = new List<BudgetAllocationItem>
        {
            new("SECTION", "section_1", null, 4000, 5, 200),
            new("ARTIFACT", "passage_section_1", "section_1", 4000, 5, 200)
        };
        await CheckpointService.SetBudgetAllocationsAsync(
            db, new SetBudgetAllocationsRequest(runId, 1, owner, allocs), default);

        var opId = $"op_timeout_{Guid.NewGuid():N}";
        var grantRes = await CheckpointService.GrantOperationAsync(
            db,
            new OperationGrantRequest(
                runId, 1, owner, opId, "PROVIDER_CALL", "hash_to",
                TokenReservation: 2500, SectionId: "section_1", ArtifactId: "passage_section_1"
            ),
            default
        );
        Assert.Equal(2500, grantRes.TokenReservation);

        // Simulate provider timeout and record UNKNOWN_OUTCOME
        var unkAck = await CheckpointService.RecordUnknownOutcomeAsync(
            db,
            new UnknownOutcomeRequest(runId, 1, owner, opId, "Cloud provider timed out after 60s"),
            default
        );
        Assert.True(unkAck.ReservationPreserved);
        Assert.Equal("UNKNOWN_OUTCOME", unkAck.Status);
        using var restartScope = provider.CreateScope();
        var restartDb = restartScope.ServiceProvider.GetRequiredService<ExamDbContext>();
        var resumed = await CheckpointService.ResumeStateAsync(restartDb, runId, default);
        Assert.True(resumed.IsCompatible);
        Assert.Equal(2500, resumed.TokensUsed);
        Assert.Equal(1, resumed.CallsUsed);
        var resumedOperation = Assert.Single(resumed.Operations!.Where(item => item.OperationId == opId));
        Assert.Equal("UNKNOWN_OUTCOME", resumedOperation.Status);
        Assert.Equal(2500, resumedOperation.TokenReservation);
        // A second request for 2,000 tokens must FAIL because remaining allowance is 4,000 - 2,500 = 1,500 < 2,000
        // (UNKNOWN_OUTCOME does NOT refund the tokens or give a free retry)
        var exSubsequent = await Assert.ThrowsAsync<CheckpointValidationException>(
            () => CheckpointService.GrantOperationAsync(
                db,
                new OperationGrantRequest(
                    runId, 1, owner, $"op_next_{Guid.NewGuid():N}", "PROVIDER_CALL", "hash_next",
                    TokenReservation: 2000, SectionId: "section_1", ArtifactId: "passage_section_1"
                ),
                default
            )
        );
        Assert.Equal(422, exSubsequent.StatusCode);
        Assert.Contains("Section budget exhausted", exSubsequent.Message);
    }

    [Fact]
    public async Task T03_ParentOperationAccounting_ReconcilesWithoutDoubleCharging()
    {
        using var provider = CreateTestProvider();
        using var scope = provider.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
        await db.Database.MigrateAsync();

        var (runId, owner, job, run) = await SeedJobAndRunAsync(db, budgetCapTokens: 50000, budgetCapCalls: 10, budgetCapWallTime: 600);

        // Parent operation granted by worker
        var parentOpId = $"op_parent_sec_1_{Guid.NewGuid():N}";
        var parentGrant = await CheckpointService.GrantOperationAsync(
            db,
            new OperationGrantRequest(
                runId, 1, owner, parentOpId, "GENERATE_SECTION", "hash_parent",
                TokenReservation: 5000, WallTimeReservationSeconds: 120.0
            ),
            default
        );
        Assert.False(parentGrant.IsReplay);

        // Logical parent intents allocate child capacity but do not consume provider call or token counters.
        var runAfterParent = await db.ReadingPaperRuns.AsNoTracking().FirstAsync(r => r.RunId == runId);
        Assert.Equal(0, runAfterParent.BudgetUsedTokens);
        Assert.Equal(0, runAfterParent.BudgetUsedCalls);

        // Child operations under parentOperationId:
        // Child 1: passage synthesis (1,200 tokens used)
        var child1Id = $"{parentOpId}_synthesis";
        var child1Grant = await CheckpointService.GrantOperationAsync(
            db,
            new OperationGrantRequest(
                runId, 1, owner, child1Id, "PROVIDER_CALL", "hash_child1",
                TokenReservation: 1500, WallTimeReservationSeconds: 40.0,
                SectionId: "section_1", ArtifactId: "passage_section_1",
                ParentOperationId: parentOpId
            ),
            default
        );

        // Each physical provider attempt charges the run when granted, even under a parent intent.
        var runAfterChild1 = await db.ReadingPaperRuns.AsNoTracking().FirstAsync(r => r.RunId == runId);
        Assert.Equal(1500, runAfterChild1.BudgetUsedTokens);
        Assert.Equal(1, runAfterChild1.BudgetUsedCalls);

        // Reconcile child 1
        var rec1 = await CheckpointService.ReconcileOperationAsync(
            db,
            new OperationReconcileRequest(
                runId, 1, owner, child1Id,
                TokensUsed: 1200, WallTimeUsedSeconds: 18.5, AccountingType: "REPORTED",
                PromptTokensUsed: 800, CompletionTokensUsed: 400, ReasoningTokensUsed: 100
            ),
            default
        );
        Assert.Equal("COMPLETED", rec1.Status);
        Assert.Equal(1200, rec1.TokensUsed);

        // Child 2: questions (1,600 tokens used)
        var child2Id = $"{parentOpId}_questions";
        var child2Grant = await CheckpointService.GrantOperationAsync(
            db,
            new OperationGrantRequest(
                runId, 1, owner, child2Id, "PROVIDER_CALL", "hash_child2",
                TokenReservation: 2000, WallTimeReservationSeconds: 50.0,
                SectionId: "section_1", ArtifactId: "questions_section_1",
                ParentOperationId: parentOpId
            ),
            default
        );

        var rec2 = await CheckpointService.ReconcileOperationAsync(
            db,
            new OperationReconcileRequest(
                runId, 1, owner, child2Id,
                TokensUsed: 1600, WallTimeUsedSeconds: 22.0, AccountingType: "REPORTED",
                PromptTokensUsed: 1100, CompletionTokensUsed: 500, ReasoningTokensUsed: 200
            ),
            default
        );
        Assert.Equal("COMPLETED", rec2.Status);
        Assert.Equal(1600, rec2.TokensUsed);

        // Total actual tokens across child operations = 1200 + 1600 = 2,800
        var totalChildTokens = await db.ReadingPaperOperations
            .Where(o => o.RunId == runId && o.ParentOperationId == parentOpId)
            .SumAsync(o => o.TokensUsed);
        Assert.Equal(2800, totalChildTokens);

        // Parent commits section with actual aggregated tokens (2,800)
        using var doc = JsonDocument.Parse("{\"title\":\"Section 1\"}");
        var contentHash = ArtifactEnvelope.ComputeContentHash(doc.RootElement, new List<ArtifactRef>());
        var sampleArtifact = new ArtifactEnvelope(
            "art_section_1", ArtifactType.Section, 1, runId, 1, "2.0.0",
            contentHash, DateTime.UtcNow, "2.0.0",
            doc.RootElement.Clone(),
            new List<ArtifactRef>()
        );

        var ack = await CheckpointService.CommitCheckpointAsync(
            db,
            new CheckpointCommitRequest(
                runId, 1, owner, parentOpId, "hash_parent", sampleArtifact,
                TokensUsed: totalChildTokens, WallTimeUsedSeconds: 40.5
            ),
            default
        );
        Assert.Equal(1, ack.Version);

        // The run total is the sum of reported usage for both physical provider attempts.
        var finalRun = await db.ReadingPaperRuns.AsNoTracking().FirstAsync(r => r.RunId == runId);
        Assert.Equal(2800, finalRun.BudgetUsedTokens);
        Assert.Equal(2, finalRun.BudgetUsedCalls);
    }

    [Fact]
    public async Task T03_05_ConcurrentProviderAttempts_ReserveRunCapAtomically()
    {
        using var provider = CreateTestProvider();
        using var scope = provider.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
        await db.Database.MigrateAsync();
        var (runId, owner, _, _) = await SeedJobAndRunAsync(db, budgetCapTokens: 10000, budgetCapCalls: 10, budgetCapWallTime: 600);

        var attempts = Enumerable.Range(0, 2).Select(index => Task.Run(async () =>
        {
            using var attemptScope = provider.CreateScope();
            var attemptDb = attemptScope.ServiceProvider.GetRequiredService<ExamDbContext>();
            try
            {
                await CheckpointService.GrantOperationAsync(
                    attemptDb,
                    new OperationGrantRequest(
                        runId, 1, owner, $"run_cap_attempt_{index}_{Guid.NewGuid():N}", "PROVIDER_CALL", $"hash_{index}",
                        TokenReservation: 6000, WallTimeReservationSeconds: 15),
                    default);
                return 200;
            }
            catch (CheckpointValidationException ex)
            {
                return ex.StatusCode;
            }
        })).ToArray();
        var statuses = await Task.WhenAll(attempts);
        Assert.Equal(1, statuses.Count(status => status == 200));
        Assert.Equal(1, statuses.Count(status => status == 422));

        var run = await db.ReadingPaperRuns.AsNoTracking().SingleAsync(item => item.RunId == runId);
        Assert.Equal(1, run.BudgetUsedCalls);
        Assert.Equal(6000, run.BudgetUsedTokens);
        Assert.Equal(1, await db.ReadingPaperOperations.CountAsync(item => item.RunId == runId && item.OperationType == "PROVIDER_CALL"));
    }

    [Fact]
    public async Task T03_UnexpectedUsageOverage_IsPersistedAndBlocksDispatchAcrossRestart()
    {
        using var provider = CreateTestProvider();
        using var scope = provider.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
        await db.Database.MigrateAsync();
        var (runId, owner, _, _) = await SeedJobAndRunAsync(db, budgetCapTokens: 10000, budgetCapCalls: 10, budgetCapWallTime: 600);
        var operationId = $"overage_{Guid.NewGuid():N}";
        var request = new OperationGrantRequest(
            runId, 1, owner, operationId, "PROVIDER_CALL", "overage-hash",
            TokenReservation: 1000, WallTimeReservationSeconds: 10);
        await CheckpointService.GrantOperationAsync(db, request, default);
        var resultJson = JsonSerializer.Serialize(new { text = "durably replayable response" });

        var reconciliation = await CheckpointService.ReconcileOperationAsync(
            db,
            new OperationReconcileRequest(
                runId, 1, owner, operationId,
                TokensUsed: 1500,
                WallTimeUsedSeconds: 2.5,
                AccountingType: "REPORTED",
                ResultRefJson: resultJson,
                PromptTokensUsed: 1100,
                CompletionTokensUsed: 400,
                ReasoningTokensUsed: 100),
            default);
        Assert.True(reconciliation.ReservationBreached);
        Assert.True(reconciliation.BudgetBreachDetected);
        Assert.Equal(1500, reconciliation.TokensUsed);

        using var restartScope = provider.CreateScope();
        var restartDb = restartScope.ServiceProvider.GetRequiredService<ExamDbContext>();
        var replay = await CheckpointService.GrantOperationAsync(restartDb, request, default);
        Assert.True(replay.IsReplay);
        Assert.Equal("COMPLETED", replay.Status);
        Assert.Equal(resultJson, replay.ResultRefJson);
        Assert.True(replay.ReservationBreached);
        Assert.True(replay.BudgetBreachDetected);

        var persisted = await restartDb.ReadingPaperOperations.AsNoTracking()
            .SingleAsync(item => item.RunId == runId && item.OperationId == operationId);
        Assert.Equal(1000, persisted.TokenReservation);
        Assert.Equal(1500, persisted.TokensUsed);
        Assert.Equal(1100, persisted.PromptTokensUsed);
        Assert.Equal(400, persisted.CompletionTokensUsed);
        Assert.Equal(100, persisted.ReasoningTokensUsed);
        Assert.Equal("REPORTED", persisted.AccountingType);
        Assert.True(persisted.ReservationBreached);
        Assert.False(string.IsNullOrWhiteSpace(persisted.BudgetBreachReason));

        var resumed = await CheckpointService.ResumeStateAsync(restartDb, runId, default);
        Assert.True(resumed.IsCompatible);
        Assert.True(resumed.BudgetBreachDetected);
        Assert.Equal(1500, resumed.TokensUsed);
        Assert.Equal(1, resumed.CallsUsed);
        var resumedOperation = Assert.Single(resumed.Operations!.Where(item => item.OperationId == operationId));
        Assert.Equal(1100, resumedOperation.PromptTokensUsed);
        Assert.Equal(400, resumedOperation.CompletionTokensUsed);

        var blocked = await Assert.ThrowsAsync<CheckpointValidationException>(() =>
            CheckpointService.GrantOperationAsync(
                restartDb,
                new OperationGrantRequest(
                    runId, 1, owner, $"after_breach_{Guid.NewGuid():N}", "PROVIDER_CALL", "next-hash",
                    TokenReservation: 100, WallTimeReservationSeconds: 1),
                default));
        Assert.Equal(422, blocked.StatusCode);
        Assert.Contains("breach", blocked.Message, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public async Task T03_ChildGrant_MissingParent_FailsClosedWith422()
    {
        using var provider = CreateTestProvider();
        using var scope = provider.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
        await db.Database.MigrateAsync();

        var (runId, owner, _, _) = await SeedJobAndRunAsync(db);

        var ex = await Assert.ThrowsAsync<CheckpointValidationException>(
            () => CheckpointService.GrantOperationAsync(
                db,
                new OperationGrantRequest(
                    runId, 1, owner, $"op_child_{Guid.NewGuid():N}", "PROVIDER_CALL", "hash_ch",
                    TokenReservation: 1000, SectionId: "section_1", ArtifactId: "passage_section_1",
                    ParentOperationId: "op_nonexistent_parent"
                ),
                default
            )
        );
        Assert.Equal(422, ex.StatusCode);
        Assert.Contains("Parent operation 'op_nonexistent_parent' not found", ex.Message);
    }

    [Fact]
    public async Task T03_ChildGrant_OverParentReservation_FailsClosedWith422()
    {
        using var provider = CreateTestProvider();
        using var scope = provider.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
        await db.Database.MigrateAsync();

        var (runId, owner, _, _) = await SeedJobAndRunAsync(db);

        var parentOpId = $"op_parent_{Guid.NewGuid():N}";
        await CheckpointService.GrantOperationAsync(
            db,
            new OperationGrantRequest(
                runId, 1, owner, parentOpId, "GENERATE_SECTION", "hash_par",
                TokenReservation: 3000, WallTimeReservationSeconds: 60.0,
                SectionId: "section_1", ArtifactId: "passage_section_1"
            ),
            default
        );

        var ch1 = await CheckpointService.GrantOperationAsync(
            db,
            new OperationGrantRequest(
                runId, 1, owner, $"{parentOpId}_c1", "PROVIDER_CALL", "hash_c1",
                TokenReservation: 2500, WallTimeReservationSeconds: 30.0,
                SectionId: "section_1", ArtifactId: "passage_section_1",
                ParentOperationId: parentOpId
            ),
            default
        );
        Assert.False(ch1.IsReplay);

        // Child 2 asks for 1000 tokens (2500 + 1000 = 3500 > 3000) -> Fails with 422!
        var ex = await Assert.ThrowsAsync<CheckpointValidationException>(
            () => CheckpointService.GrantOperationAsync(
                db,
                new OperationGrantRequest(
                    runId, 1, owner, $"{parentOpId}_c2", "PROVIDER_CALL", "hash_c2",
                    TokenReservation: 1000, WallTimeReservationSeconds: 20.0,
                    SectionId: "section_1", ArtifactId: "passage_section_1",
                    ParentOperationId: parentOpId
                ),
                default
            )
        );
        Assert.Equal(422, ex.StatusCode);
        Assert.Contains("Parent operation reservation exceeded", ex.Message);
    }

    [Fact]
    public async Task T03_ChildGrant_ParentScopeMismatch_FailsClosedWith422()
    {
        using var provider = CreateTestProvider();
        using var scope = provider.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
        await db.Database.MigrateAsync();

        var (runId, owner, _, _) = await SeedJobAndRunAsync(db);

        var parentOpId = $"op_parent_sec1_{Guid.NewGuid():N}";
        await CheckpointService.GrantOperationAsync(
            db,
            new OperationGrantRequest(
                runId, 1, owner, parentOpId, "GENERATE_SECTION", "hash_p",
                TokenReservation: 5000, WallTimeReservationSeconds: 60.0,
                SectionId: "section_1", ArtifactId: "passage_section_1"
            ),
            default
        );

        // Child claims section_2 when parent belongs to section_1
        var ex = await Assert.ThrowsAsync<CheckpointValidationException>(
            () => CheckpointService.GrantOperationAsync(
                db,
                new OperationGrantRequest(
                    runId, 1, owner, $"{parentOpId}_c_mismatch", "PROVIDER_CALL", "hash_cm",
                    TokenReservation: 1000, SectionId: "section_2", ArtifactId: "passage_section_2",
                    ParentOperationId: parentOpId
                ),
                default
            )
        );
        Assert.Equal(422, ex.StatusCode);
        Assert.Contains("belongs to section 'section_1', but child requested section 'section_2'", ex.Message);
    }

    [Fact]
    public async Task T03_ChildGrant_ParentNotReserved_FailsClosedWith422()
    {
        using var provider = CreateTestProvider();
        using var scope = provider.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
        await db.Database.MigrateAsync();

        var (runId, owner, _, _) = await SeedJobAndRunAsync(db);

        var parentOpId = $"op_parent_closed_{Guid.NewGuid():N}";
        await CheckpointService.GrantOperationAsync(
            db,
            new OperationGrantRequest(
                runId, 1, owner, parentOpId, "GENERATE_SECTION", "hash_pc",
                TokenReservation: 3000, SectionId: "section_1", ArtifactId: "passage_section_1"
            ),
            default
        );

        // Simulate parent marked UNKNOWN_OUTCOME
        await CheckpointService.RecordUnknownOutcomeAsync(
            db, new UnknownOutcomeRequest(runId, 1, owner, parentOpId, "Parent timed out"), default);

        // Attempting child grant under non-RESERVED parent fails
        var ex = await Assert.ThrowsAsync<CheckpointValidationException>(
            () => CheckpointService.GrantOperationAsync(
                db,
                new OperationGrantRequest(
                    runId, 1, owner, $"{parentOpId}_child_late", "PROVIDER_CALL", "hash_late",
                    TokenReservation: 1000, SectionId: "section_1", ArtifactId: "passage_section_1",
                    ParentOperationId: parentOpId
                ),
                default
            )
        );
        Assert.Equal(422, ex.StatusCode);
        Assert.Contains("must be in status 'RESERVED' to authorize child operations", ex.Message);
    }
}
