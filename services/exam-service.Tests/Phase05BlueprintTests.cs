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
public class Phase05BlueprintTests
{
    private static ExamBlueprint CreateValidExamBlueprint(
        int? parentCap = 45000,
        string graphStatus = "ACCEPTED",
        bool isCalibrated = false,
        int candidatesPerSlot = 1)
    {
        var sections = new List<SectionBlueprint>();

        // Section 1
        var sec1Slots = new List<QuestionSlot>();
        for (int q = 1; q <= 7; q++)
        {
            sec1Slots.Add(new QuestionSlot(
                QuestionNumber: q,
                SectionId: 1,
                GroupIndex: 0,
                QuestionType: QuestionType.TRUE_FALSE_NOT_GIVEN,
                TargetSkill: "factual_identification",
                TargetDifficulty: new TargetDifficulty(DifficultyLevel.FOUNDATION, "Direct fact check", isCalibrated),
                ClaimRefIds: new List<string> { $"claim_s1_{q}" },
                IsNotGivenTarget: q == 3 || q == 7
            ));
        }
        for (int q = 8; q <= 13; q++)
        {
            sec1Slots.Add(new QuestionSlot(
                QuestionNumber: q,
                SectionId: 1,
                GroupIndex: 1,
                QuestionType: QuestionType.SENTENCE_COMPLETION,
                TargetSkill: "detail_scanning",
                TargetDifficulty: new TargetDifficulty(DifficultyLevel.FOUNDATION, "Verbatim scanning", isCalibrated),
                ClaimRefIds: new List<string> { $"claim_s1_{q}" }
            ));
        }
        sections.Add(new SectionBlueprint(
            SectionId: 1,
            Topic: "Early Agriculture in the Fertile Crescent",
            TargetWordCount: 800,
            EvidenceGraphRef: new EvidenceGraphRef("graph-001", "pack-001", "v1.0.0", "hash-abc-001", graphStatus, 13),
            PassageObjectives: new List<PassageObjective>
            {
                new("obj_1", "Describe Neolithic farming origins", new List<string> { "claim_s1_1" }, "factual_foundation")
            },
            QuestionAllocations: new List<QuestionTypeAllocation>
            {
                new(QuestionType.TRUE_FALSE_NOT_GIVEN, 7, 1, 7),
                new(QuestionType.SENTENCE_COMPLETION, 6, 8, 13)
            },
            QuestionSlots: sec1Slots,
            BudgetAllocation: new BudgetAllocation(candidatesPerSlot, 2, 14000),
            TotalQuestions: 13
        ));

        // Section 2
        var sec2Slots = new List<QuestionSlot>();
        for (int q = 14; q <= 19; q++)
        {
            sec2Slots.Add(new QuestionSlot(
                QuestionNumber: q,
                SectionId: 2,
                GroupIndex: 0,
                QuestionType: QuestionType.MULTIPLE_CHOICE_SINGLE,
                TargetSkill: "mechanism_comprehension",
                TargetDifficulty: new TargetDifficulty(DifficultyLevel.MODERATE, "Process mechanism", isCalibrated),
                ClaimRefIds: new List<string> { $"claim_s2_{q}" }
            ));
        }
        for (int q = 20; q <= 26; q++)
        {
            sec2Slots.Add(new QuestionSlot(
                QuestionNumber: q,
                SectionId: 2,
                GroupIndex: 1,
                QuestionType: QuestionType.SUMMARY_COMPLETION,
                TargetSkill: "process_synthesis",
                TargetDifficulty: new TargetDifficulty(DifficultyLevel.MODERATE, "Causal summary", isCalibrated),
                ClaimRefIds: new List<string> { $"claim_s2_{q}" }
            ));
        }
        sections.Add(new SectionBlueprint(
            SectionId: 2,
            Topic: "Mechanisms of Cellular Respiration",
            TargetWordCount: 820,
            EvidenceGraphRef: new EvidenceGraphRef("graph-002", "pack-002", "v1.0.0", "hash-abc-002", graphStatus, 13),
            PassageObjectives: new List<PassageObjective>
            {
                new("obj_2", "Explain Krebs cycle electron transport", new List<string> { "claim_s2_14" }, "process_mechanism")
            },
            QuestionAllocations: new List<QuestionTypeAllocation>
            {
                new(QuestionType.MULTIPLE_CHOICE_SINGLE, 6, 14, 19),
                new(QuestionType.SUMMARY_COMPLETION, 7, 20, 26)
            },
            QuestionSlots: sec2Slots,
            BudgetAllocation: new BudgetAllocation(candidatesPerSlot, 2, 14000),
            TotalQuestions: 13
        ));

        // Section 3
        var sec3Slots = new List<QuestionSlot>();
        for (int q = 27; q <= 33; q++)
        {
            sec3Slots.Add(new QuestionSlot(
                QuestionNumber: q,
                SectionId: 3,
                GroupIndex: 0,
                QuestionType: QuestionType.YES_NO_NOT_GIVEN,
                TargetSkill: "viewpoint_evaluation",
                TargetDifficulty: new TargetDifficulty(DifficultyLevel.ADVANCED, "Author argument check", isCalibrated),
                ClaimRefIds: new List<string> { $"claim_s3_{q}" },
                IsNotGivenTarget: q == 30 || q == 33
            ));
        }
        for (int q = 34; q <= 40; q++)
        {
            sec3Slots.Add(new QuestionSlot(
                QuestionNumber: q,
                SectionId: 3,
                GroupIndex: 1,
                QuestionType: QuestionType.SHORT_ANSWER,
                TargetSkill: "complex_inference",
                TargetDifficulty: new TargetDifficulty(DifficultyLevel.ADVANCED, "Nuanced view extraction", isCalibrated),
                ClaimRefIds: new List<string> { $"claim_s3_{q}" }
            ));
        }
        sections.Add(new SectionBlueprint(
            SectionId: 3,
            Topic: "Ethical Perspectives on Algorithmic Governance",
            TargetWordCount: 850,
            EvidenceGraphRef: new EvidenceGraphRef("graph-003", "pack-003", "v1.0.0", "hash-abc-003", graphStatus, 14),
            PassageObjectives: new List<PassageObjective>
            {
                new("obj_3", "Examine competing AI governance frameworks", new List<string> { "claim_s3_27" }, "argument_viewpoint")
            },
            QuestionAllocations: new List<QuestionTypeAllocation>
            {
                new(QuestionType.YES_NO_NOT_GIVEN, 7, 27, 33),
                new(QuestionType.SHORT_ANSWER, 7, 34, 40)
            },
            QuestionSlots: sec3Slots,
            BudgetAllocation: new BudgetAllocation(candidatesPerSlot, 2, 15000),
            TotalQuestions: 14
        ));

        return new ExamBlueprint(
            BlueprintId: "bp-test-001",
            RunId: "run-test-001",
            PolicyVersion: "v2.0.0",
            SchemaVersion: "v2.0.0",
            Sections: sections,
            TotalQuestions: 40,
            TargetWordCountMin: 2150,
            TargetWordCountMax: 2750,
            ParentBudgetCapTokens: parentCap,
            ContentHash: "hash-bp-12345",
            InvalidatedDescendants: false,
            CreatedAt: DateTime.UtcNow
        );
    }

    [Fact]
    public void T05_01_SectionAllocations_AndSlots1To40_Contiguous_ValidatesCleanly()
    {
        var bp = CreateValidExamBlueprint();
        var issues = BlueprintValidator.ValidateBlueprint(bp);

        Assert.Empty(issues);
    }

    [Fact]
    public void T05_04_RejectedOrStaleGraphRef_ProducesBlockingIssue()
    {
        var bp = CreateValidExamBlueprint(graphStatus: "REJECTED");
        var issues = BlueprintValidator.ValidateBlueprint(bp);

        Assert.Contains(issues, i => i.Code == "BLUEPRINT_GRAPH_REF_NOT_ACCEPTED");
    }

    [Fact]
    public void T05_05_CandidateAllocation_ExceedsCap_ProducesBlockingIssue()
    {
        var bp = CreateValidExamBlueprint(candidatesPerSlot: 4);
        var issues = BlueprintValidator.ValidateBlueprint(bp);

        Assert.Contains(issues, i => i.Code == "BLUEPRINT_CANDIDATE_ALLOCATION_EXCEEDS_CAP");
    }

    [Fact]
    public void T05_05_BudgetExceedingParentCap_ProducesBlockingIssue()
    {
        // Total allocated is 14000 + 14000 + 15000 = 43000; set parent cap to 40000
        var bp = CreateValidExamBlueprint(parentCap: 40000);
        var issues = BlueprintValidator.ValidateBlueprint(bp);

        Assert.Contains(issues, i => i.Code == "BLUEPRINT_BUDGET_EXCEEDS_PARENT_CAP");
    }

    [Fact]
    public void T05_07_CalibratedDifficulty_ProhibitedByPolicy()
    {
        var bp = CreateValidExamBlueprint(isCalibrated: true);
        var issues = BlueprintValidator.ValidateBlueprint(bp);

        Assert.Contains(issues, i => i.Code == "BLUEPRINT_CALIBRATED_DIFFICULTY_PROHIBITED");
    }

    [Fact]
    public void T05_07_BlueprintSerialization_Roundtrip()
    {
        var bp = CreateValidExamBlueprint();
        string json = JsonSerializer.Serialize(bp, LoopEngineJson.Options);
        var deserialized = JsonSerializer.Deserialize<ExamBlueprint>(json, LoopEngineJson.Options);

        Assert.NotNull(deserialized);
        Assert.Equal(bp.BlueprintId, deserialized.BlueprintId);
        Assert.Equal(40, deserialized.TotalQuestions);
        Assert.Equal(3, deserialized.Sections.Count);
        Assert.Equal(13, deserialized.Sections[0].QuestionSlots.Count);
        Assert.Equal(13, deserialized.Sections[1].QuestionSlots.Count);
        Assert.Equal(14, deserialized.Sections[2].QuestionSlots.Count);
    }

    [Fact]
    public async Task T05_08_ExamBlueprint_CheckpointCommit_Resume_And_DependencyInvalidation_OnPostgreSql()
    {
        var services = new ServiceCollection();
        services.AddDbContext<ExamDbContext>(options => options.UseNpgsql(
            "Host=localhost;Port=5433;Database=exam_test_phase02;Username=exam;Password=exam",
            npg => {
                npg.ConfigureDataSource(dataSource => dataSource.EnableDynamicJson());
                npg.EnableRetryOnFailure();
            }));
        await using var provider = services.BuildServiceProvider();

        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            await db.Database.MigrateAsync();
        }

        var worker = Guid.NewGuid();
        string runId;

        // 1. Create job and run
        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var job = new ReadingPaperJob
            {
                Id = Guid.NewGuid(),
                Topic = "Neolithic & Respiration & AI Ethics",
                Status = "Running",
                Epoch = 1,
                LeaseOwner = worker,
                LeaseUntil = DateTime.UtcNow.AddMinutes(5),
                SourcesJson = "[]",
                SectionsJson = "[]",
                CompletedSections = 0,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };
            db.ReadingPaperJobs.Add(job);
            runId = $"run_{job.Id:N}";
            job.ActiveRunId = runId;

            var run = new ReadingPaperRun
            {
                Id = Guid.NewGuid(),
                JobId = job.Id,
                RunId = runId,
                Epoch = 1,
                Status = "RUNNING",
                LeaseOwner = worker,
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
        }

        ArtifactRef sp1Ref, sp2Ref, sp3Ref;
        ArtifactRef eg1Ref, eg2Ref, eg3Ref;

        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();

            // SourcePacks
            using var p1 = JsonDocument.Parse("""{"packId":"sp_1","revision":1}""");
            var h1 = ArtifactEnvelope.ComputeContentHash(p1.RootElement, Array.Empty<ArtifactRef>());
            sp1Ref = new ArtifactRef("sp_1", ArtifactType.SourcePack, 1, h1);
            var env1 = new ArtifactEnvelope("sp_1", ArtifactType.SourcePack, 1, runId, 1, "2.0.0", h1, DateTime.UtcNow, "2.0.0", p1.RootElement.Clone(), Array.Empty<ArtifactRef>());
            await CheckpointService.GrantOperationAsync(db, new OperationGrantRequest(runId, 1, worker, "op_grant_sp1", "INGEST", "hash_sp1", 1000), CancellationToken.None);
            await CheckpointService.CommitCheckpointAsync(db, new CheckpointCommitRequest(runId, 1, worker, "op_grant_sp1", "hash_sp1", env1), CancellationToken.None);

            using var p2 = JsonDocument.Parse("""{"packId":"sp_2","revision":1}""");
            var h2 = ArtifactEnvelope.ComputeContentHash(p2.RootElement, Array.Empty<ArtifactRef>());
            sp2Ref = new ArtifactRef("sp_2", ArtifactType.SourcePack, 1, h2);
            var env2 = new ArtifactEnvelope("sp_2", ArtifactType.SourcePack, 1, runId, 2, "2.0.0", h2, DateTime.UtcNow, "2.0.0", p2.RootElement.Clone(), Array.Empty<ArtifactRef>());
            await CheckpointService.GrantOperationAsync(db, new OperationGrantRequest(runId, 1, worker, "op_grant_sp2", "INGEST", "hash_sp2", 1000), CancellationToken.None);
            await CheckpointService.CommitCheckpointAsync(db, new CheckpointCommitRequest(runId, 1, worker, "op_grant_sp2", "hash_sp2", env2), CancellationToken.None);

            using var p3 = JsonDocument.Parse("""{"packId":"sp_3","revision":1}""");
            var h3 = ArtifactEnvelope.ComputeContentHash(p3.RootElement, Array.Empty<ArtifactRef>());
            sp3Ref = new ArtifactRef("sp_3", ArtifactType.SourcePack, 1, h3);
            var env3 = new ArtifactEnvelope("sp_3", ArtifactType.SourcePack, 1, runId, 3, "2.0.0", h3, DateTime.UtcNow, "2.0.0", p3.RootElement.Clone(), Array.Empty<ArtifactRef>());
            await CheckpointService.GrantOperationAsync(db, new OperationGrantRequest(runId, 1, worker, "op_grant_sp3", "INGEST", "hash_sp3", 1000), CancellationToken.None);
            await CheckpointService.CommitCheckpointAsync(db, new CheckpointCommitRequest(runId, 1, worker, "op_grant_sp3", "hash_sp3", env3), CancellationToken.None);

            // EvidenceGraphs (children of SourcePacks)
            using var egDoc1 = JsonDocument.Parse("""{"graphId":"eg_1","status":"ACCEPTED"}""");
            var egHash1 = ArtifactEnvelope.ComputeContentHash(egDoc1.RootElement, new[] { sp1Ref });
            eg1Ref = new ArtifactRef("eg_1", ArtifactType.EvidenceGraph, 1, egHash1);
            var egEnv1 = new ArtifactEnvelope("eg_1", ArtifactType.EvidenceGraph, 1, runId, 1, "2.0.0", egHash1, DateTime.UtcNow, "2.0.0", egDoc1.RootElement.Clone(), new[] { sp1Ref });
            await CheckpointService.GrantOperationAsync(db, new OperationGrantRequest(runId, 1, worker, "op_grant_eg1", "EXTRACT", "hash_eg1", 1000), CancellationToken.None);
            await CheckpointService.CommitCheckpointAsync(db, new CheckpointCommitRequest(runId, 1, worker, "op_grant_eg1", "hash_eg1", egEnv1), CancellationToken.None);

            using var egDoc2 = JsonDocument.Parse("""{"graphId":"eg_2","status":"ACCEPTED"}""");
            var egHash2 = ArtifactEnvelope.ComputeContentHash(egDoc2.RootElement, new[] { sp2Ref });
            eg2Ref = new ArtifactRef("eg_2", ArtifactType.EvidenceGraph, 1, egHash2);
            var egEnv2 = new ArtifactEnvelope("eg_2", ArtifactType.EvidenceGraph, 1, runId, 2, "2.0.0", egHash2, DateTime.UtcNow, "2.0.0", egDoc2.RootElement.Clone(), new[] { sp2Ref });
            await CheckpointService.GrantOperationAsync(db, new OperationGrantRequest(runId, 1, worker, "op_grant_eg2", "EXTRACT", "hash_eg2", 1000), CancellationToken.None);
            await CheckpointService.CommitCheckpointAsync(db, new CheckpointCommitRequest(runId, 1, worker, "op_grant_eg2", "hash_eg2", egEnv2), CancellationToken.None);

            using var egDoc3 = JsonDocument.Parse("""{"graphId":"eg_3","status":"ACCEPTED"}""");
            var egHash3 = ArtifactEnvelope.ComputeContentHash(egDoc3.RootElement, new[] { sp3Ref });
            eg3Ref = new ArtifactRef("eg_3", ArtifactType.EvidenceGraph, 1, egHash3);
            var egEnv3 = new ArtifactEnvelope("eg_3", ArtifactType.EvidenceGraph, 1, runId, 3, "2.0.0", egHash3, DateTime.UtcNow, "2.0.0", egDoc3.RootElement.Clone(), new[] { sp3Ref });
            await CheckpointService.GrantOperationAsync(db, new OperationGrantRequest(runId, 1, worker, "op_grant_eg3", "EXTRACT", "hash_eg3", 1000), CancellationToken.None);
            await CheckpointService.CommitCheckpointAsync(db, new CheckpointCommitRequest(runId, 1, worker, "op_grant_eg3", "hash_eg3", egEnv3), CancellationToken.None);
        }

        // 3. Commit ExamBlueprint as child of all 3 EvidenceGraphs
        var bp = CreateValidExamBlueprint();
        string bpJson = JsonSerializer.Serialize(bp, LoopEngineJson.Options);
        using var bpDoc = JsonDocument.Parse(bpJson);
        var bpContentHash = ArtifactEnvelope.ComputeContentHash(bpDoc.RootElement, new[] { eg1Ref, eg2Ref, eg3Ref });
        var bpEnv = new ArtifactEnvelope("bp_master_001", ArtifactType.ExamBlueprint, 1, runId, null, "2.0.0", bpContentHash, DateTime.UtcNow, "2.0.0", bpDoc.RootElement.Clone(), new[] { eg1Ref, eg2Ref, eg3Ref });

        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            await CheckpointService.GrantOperationAsync(db, new OperationGrantRequest(runId, 1, worker, "op_grant_bp", "PLAN", "hash_bp", 5000), CancellationToken.None);
            var ack = await CheckpointService.CommitCheckpointAsync(db, new CheckpointCommitRequest(runId, 1, worker, "op_grant_bp", "hash_bp", bpEnv, TokensUsed: 4200), CancellationToken.None);
            Assert.Equal("bp_master_001", ack.ArtifactId);
            Assert.False(ack.IsReplay);
        }

        // 4. ResumeStateAsync verifies ExamBlueprint is restored from PostgreSQL
        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var resume = await CheckpointService.ResumeStateAsync(db, runId, CancellationToken.None);
            var bpHolder = resume.Artifacts.FirstOrDefault(a => a.ArtifactId == "bp_master_001");
            Assert.NotNull(bpHolder);
            Assert.Equal(bpContentHash, bpHolder.AcceptedHash);
            Assert.False(bpHolder.IsStale);

            // Verify budget tokens used preserved
            var run = await db.ReadingPaperRuns.FirstAsync(r => r.RunId == runId);
            Assert.Equal(4200, run.BudgetUsedTokens);
        }

        // 5. Invalidate Section 2 SourcePack -> Dependency closure invalidates sp_2, eg_2, and bp_master_001
        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var invReq = new InvalidateDependencyRequest(runId, 1, worker, "sp_2", "Source section 2 updated");
            var invRes = await CheckpointService.InvalidateDependencyClosureAsync(db, invReq, CancellationToken.None);
            Assert.Contains("sp_2", invRes.InvalidatedArtifactIds);
            Assert.Contains("eg_2", invRes.InvalidatedArtifactIds);
            Assert.Contains("bp_master_001", invRes.InvalidatedArtifactIds);

            // Section 1 and Section 3 must NOT be invalidated!
            Assert.DoesNotContain("sp_1", invRes.InvalidatedArtifactIds);
            Assert.DoesNotContain("eg_1", invRes.InvalidatedArtifactIds);
            Assert.DoesNotContain("sp_3", invRes.InvalidatedArtifactIds);
            Assert.DoesNotContain("eg_3", invRes.InvalidatedArtifactIds);

            // Re-check resume state: invalidated artifacts are pruned from accepted heads
            var resumeAfterInv = await CheckpointService.ResumeStateAsync(db, runId, CancellationToken.None);
            Assert.DoesNotContain(resumeAfterInv.Artifacts, a => a.ArtifactId == "bp_master_001");
            Assert.DoesNotContain(resumeAfterInv.Artifacts, a => a.ArtifactId == "eg_2");
            Assert.DoesNotContain(resumeAfterInv.Artifacts, a => a.ArtifactId == "sp_2");

            // Section 1 and Section 3 heads remain preserved
            Assert.Contains(resumeAfterInv.Artifacts, a => a.ArtifactId == "sp_1");
            Assert.Contains(resumeAfterInv.Artifacts, a => a.ArtifactId == "eg_1");
            Assert.Contains(resumeAfterInv.Artifacts, a => a.ArtifactId == "sp_3");
            Assert.Contains(resumeAfterInv.Artifacts, a => a.ArtifactId == "eg_3");
        }
    }
}
