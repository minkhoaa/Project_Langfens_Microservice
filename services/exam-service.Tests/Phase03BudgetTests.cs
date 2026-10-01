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

    private static async Task<(string RunId, Guid Owner, ReadingPaperJob Job, ReadingPaperRun Run)> SeedJobAndRunAsync(
        ExamDbContext db,
        int budgetCapTokens = 150000,
        int budgetCapCalls = 25,
        int budgetCapWallTime = 900)
    {
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

        // Verify run token usage after parent grant is exactly 5,000
        var runAfterParent = await db.ReadingPaperRuns.AsNoTracking().FirstAsync(r => r.RunId == runId);
        Assert.Equal(5000, runAfterParent.BudgetUsedTokens);
        Assert.Equal(1, runAfterParent.BudgetUsedCalls);

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

        // Child grant under parent should NOT double-charge run tokens
        var runAfterChild1 = await db.ReadingPaperRuns.AsNoTracking().FirstAsync(r => r.RunId == runId);
        Assert.Equal(5000, runAfterChild1.BudgetUsedTokens); // Still 5000!

        // Reconcile child 1
        var rec1 = await CheckpointService.ReconcileOperationAsync(
            db,
            new OperationReconcileRequest(
                runId, 1, owner, child1Id,
                TokensUsed: 1200, WallTimeUsedSeconds: 18.5, AccountingType: "REPORTED"
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
                TokensUsed: 1600, WallTimeUsedSeconds: 22.0, AccountingType: "REPORTED"
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

        // Verify run token usage reconciled from parent reservation (5000) to actual (2800)
        var finalRun = await db.ReadingPaperRuns.AsNoTracking().FirstAsync(r => r.RunId == runId);
        Assert.Equal(2800, finalRun.BudgetUsedTokens); // 5000 + (2800 - 5000) = 2800! Exactly reconciled!
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
