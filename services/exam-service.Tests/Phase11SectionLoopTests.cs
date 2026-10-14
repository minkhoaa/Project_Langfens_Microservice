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
public class Phase11SectionLoopTests
{
    private const string DefaultConn = "Host=localhost;Port=5433;Database=exam_test_phase11;Username=exam;Password=exam";
    private static string ConnectionString =>
        Environment.GetEnvironmentVariable("READING_TEST_POSTGRES")
        ?? Environment.GetEnvironmentVariable("ConnectionStrings__exam-db")
        ?? DefaultConn;

    private static ServiceProvider CreateTestProvider(string? connection = null)
    {
        var services = new ServiceCollection();
        services.AddDbContext<ExamDbContext>(options => options.UseNpgsql(connection ?? ConnectionString, npg =>
        {
            npg.ConfigureDataSource(dataSource => dataSource.EnableDynamicJson());
            npg.EnableRetryOnFailure();
        }));
        return services.BuildServiceProvider();
    }

    private static async Task<(ReadingPaperJob Job, ReadingPaperRun Run)> CreateJobAndRunAsync(
        ExamDbContext db,
        Guid owner,
        int epoch = 1)
    {
        await db.Database.MigrateAsync();

        var job = new ReadingPaperJob
        {
            Id = Guid.NewGuid(),
            Topic = "Phase 11 Section Loop Verification",
            Status = "Running",
            Epoch = epoch,
            CancelVersion = 0,
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
            Status = "RUNNING",
            LeaseOwner = owner,
            LeaseUntil = job.LeaseUntil,
            CancelVersion = 0,
            EngineVersion = "2.0.0",
            SchemaVersion = "2.0.0",
            PolicyVersion = "1.0.0",
            SourceRevisionsJson = "[]",
            BudgetCapCalls = 25,
            BudgetCapTokens = 150000,
            BudgetCapWallTimeSeconds = 900,
            BudgetProfileVersion = "v2.0.0",
            BudgetProfileSha256 = "0000000000000000000000000000000000000000000000000000000000000000",
            BudgetProfileSource = "TEST",
            BudgetProfileJson = "{}",
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        db.ReadingPaperRuns.Add(run);
        await db.SaveChangesAsync();

        return (job, run);
    }

    private static ArtifactEnvelope CreateTestSectionEnvelope(
        string runId,
        int sectionIndex,
        string passageRefHash = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
        string bpRefHash = "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb")
    {
        var passageRef = new ArtifactRef($"art_passage_s{sectionIndex}", ArtifactType.Passage, 1, passageRefHash);
        var blueprintRef = new ArtifactRef("art_blueprint_01", ArtifactType.ExamBlueprint, 1, bpRefHash);
        var questionRefs = new List<ArtifactRef>();
        var startNum = sectionIndex == 1 ? 1 : (sectionIndex == 2 ? 14 : 27);
        var count = sectionIndex == 3 ? 14 : 13;

        for (int i = 0; i < count; i++)
        {
            questionRefs.Add(new ArtifactRef($"art_q_{startNum + i}", ArtifactType.Question, 1, $"{i:x64}"));
        }

        var parentRefs = new List<ArtifactRef> { passageRef, blueprintRef };
        parentRefs.AddRange(questionRefs);

        var sectionPayload = new
        {
            sectionId = sectionIndex,
            title = $"Section {sectionIndex} Academic Reading",
            passage = "This is a comprehensive verified academic passage with more than eight hundred words describing empirical observations in linguistics and cognitive neuroscience...",
            wordCount = 820,
            source = new
            {
                pmcid = $"PMC{sectionIndex}999999",
                title = $"Source for Section {sectionIndex}",
                doi = $"10.1016/j.test.{sectionIndex}.001",
                url = $"https://europepmc.org/articles/PMC{sectionIndex}999999",
                license = "CC BY 4.0",
                wordCount = 820
            },
            groups = new[]
            {
                new
                {
                    groupId = $"grp_s{sectionIndex}_1",
                    questionType = sectionIndex == 1 ? "TrueFalseNotGiven" : (sectionIndex == 2 ? "MultipleChoiceSingle" : "YesNoNotGiven"),
                    instructions = "Answer the questions in boxes on your answer sheet.",
                    questions = new object[]
                    {
                        new
                        {
                            questionNumber = startNum,
                            prompt = $"Statement for question {startNum}",
                            answer = sectionIndex == 2 ? "A" : "TRUE",
                            options = sectionIndex == 2 ? new[] { "Option A", "Option B", "Option C", "Option D" } : Array.Empty<string>(),
                            evidenceQuote = "This is a comprehensive verified academic passage with more than eight hundred words",
                            explanation = $"Explanation for question {startNum}"
                        }
                    }
                }
            },
            passageRef = passageRef,
            blueprintRef = blueprintRef,
            questionRefs = questionRefs
        };

        var payloadJson = JsonSerializer.Serialize(sectionPayload, ReadingPaperRules.Json);
        using var doc = JsonDocument.Parse(payloadJson);
        var contentHash = ArtifactEnvelope.ComputeContentHash(doc.RootElement, parentRefs);

        return new ArtifactEnvelope(
            $"art_section_s{sectionIndex}",
            ArtifactType.Section,
            1,
            runId,
            sectionIndex,
            "2.0.0",
            contentHash,
            DateTime.UtcNow,
            "2.0.0",
            doc.RootElement.Clone(),
            parentRefs
        );
    }
    private static async Task SeedParentHeadsAsync(ExamDbContext db, string runId, int sectionIndex)
    {
        var passageId = $"art_passage_s{sectionIndex}";
        var bpId = "art_blueprint_01";
        var heads = new List<(string Id, string Type, string Hash)>
        {
            (passageId, ArtifactType.Passage.ToString(), "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"),
            (bpId, ArtifactType.ExamBlueprint.ToString(), "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb")
        };
        var startNum = sectionIndex == 1 ? 1 : (sectionIndex == 2 ? 14 : 27);
        var count = sectionIndex == 3 ? 14 : 13;
        for (int i = 0; i < count; i++)
        {
            heads.Add(($"art_q_{startNum + i}", ArtifactType.Question.ToString(), $"{i:x64}"));
        }

        foreach (var (id, type, hash) in heads)
        {
            db.ReadingPaperArtifactHeads.Add(new ReadingPaperArtifactHead
            {
                Id = Guid.NewGuid(),
                RunId = runId,
                ArtifactId = id,
                AcceptedVersion = 1,
                AcceptedHash = hash,
                UpdatedAt = DateTime.UtcNow
            });
            db.ReadingPaperArtifacts.Add(new ReadingPaperArtifact
            {
                Id = Guid.NewGuid(),
                RunId = runId,
                ArtifactId = id,
                ArtifactType = type,
                Version = 1,
                ContentHash = hash,
                PayloadJson = "{}",
                CreatedAt = DateTime.UtcNow
            });
        }
        await db.SaveChangesAsync();
    }

    [Fact]
    public async Task CommitSectionCheckpoint_SynchronizesIntoSectionsJson_Idempotently()
    {
        using var provider = CreateTestProvider();
        using var scope = provider.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();

        var owner = Guid.NewGuid();
        var (job, run) = await CreateJobAndRunAsync(db, owner);
        await SeedParentHeadsAsync(db, run.RunId, 1);

        var sectionEnv = CreateTestSectionEnvelope(run.RunId, 1);
        var reqHash = "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef";
        var opId = $"op_sec1_{Guid.NewGuid():N}";

        // Grant operation first
        await CheckpointService.GrantOperationAsync(db, new OperationGrantRequest(
            run.RunId, 1, owner, opId, "GENERATE_SECTION", reqHash, 15000, 0m, 240.0, "section_1", null
        ), CancellationToken.None);

        // 1. First Commit -> Succeeded, IsReplay = false
        var commitReq = new CheckpointCommitRequest(
            run.RunId,
            1,
            owner,
            opId,
            reqHash,
            sectionEnv,
            TokensUsed: 1200,
            WallTimeUsedSeconds: 15.0
        );

        var ack = await CheckpointService.CommitCheckpointAsync(db, commitReq, CancellationToken.None);
        Assert.NotNull(ack);
        Assert.Equal("art_section_s1", ack.ArtifactId);
        Assert.Equal(1, ack.Version);
        Assert.False(ack.IsReplay);

        // Verify synchronous sync to job.SectionsJson
        var updatedJob = await db.ReadingPaperJobs.AsNoTracking().FirstAsync(j => j.Id == job.Id);
        Assert.Equal(1, updatedJob.CompletedSections);
        var syncedSections = JsonSerializer.Deserialize<List<ReadingGeneratedSection>>(updatedJob.SectionsJson, ReadingPaperRules.Json);
        Assert.NotNull(syncedSections);
        Assert.Single(syncedSections);
        Assert.Equal("PMC1999999", syncedSections[0].Source.Pmcid);
        Assert.Equal("Section 1 Academic Reading", syncedSections[0].Title);

        // 2. Duplicate Replay Commit with exact same opId and content -> Returns IsReplay = true
        var replayAck = await CheckpointService.CommitCheckpointAsync(db, commitReq, CancellationToken.None);
        Assert.NotNull(replayAck);
        Assert.Equal(1, replayAck.Version);
        Assert.True(replayAck.IsReplay);

        // 3. Stale lease owner -> Throws 409 conflict
        var staleReq = commitReq with { LeaseOwner = Guid.NewGuid() };
        await Assert.ThrowsAsync<CheckpointValidationException>(async () =>
            await CheckpointService.CommitCheckpointAsync(db, staleReq, CancellationToken.None));
    }

    [Fact]
    public async Task SectionAcceptance_DoesNotBuildExam_PreservesJobRunning()
    {
        using var provider = CreateTestProvider();
        using var scope = provider.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();

        var owner = Guid.NewGuid();
        var (job, run) = await CreateJobAndRunAsync(db, owner);
        await SeedParentHeadsAsync(db, run.RunId, 1);

        var sectionEnv = CreateTestSectionEnvelope(run.RunId, 1);
        var reqHash = "fedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210";
        var opId = $"op_sec_nobuild_{Guid.NewGuid():N}";

        await CheckpointService.GrantOperationAsync(db, new OperationGrantRequest(
            run.RunId, 1, owner, opId, "GENERATE_SECTION", reqHash, 15000, 0m, 240.0, "section_1", null
        ), CancellationToken.None);

        await CheckpointService.CommitCheckpointAsync(db, new CheckpointCommitRequest(
            run.RunId,
            1,
            owner,
            opId,
            reqHash,
            sectionEnv,
            TokensUsed: 1000,
            WallTimeUsedSeconds: 10.0
        ), CancellationToken.None);

        // Invariant: Job status must remain Running; ExamId must remain null
        var currentJob = await db.ReadingPaperJobs.AsNoTracking().FirstAsync(j => j.Id == job.Id);
        Assert.Equal("Running", currentJob.Status);
        Assert.Null(currentJob.ExamId);
    }
}
