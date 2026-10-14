using System.Net;
using System.Net.Http.Json;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using exam_service.Domains.Entities;
using exam_service.Features.ReadingPaper;
using exam_service.Features.ReadingPaper.Contracts;
using exam_service.Infrastructure.Persistence;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Npgsql;
using Xunit;

namespace exam_service.Tests;

public static class FaultTraceRecorder
{
    private static readonly object FileLock = new();
    private static readonly string TraceFilePath = Path.Combine(
        Path.GetTempPath(),
        "transaction-fault-traces.jsonl");
    public static void RecordTrace(
        string testId,
        string scenario,
        string fault,
        string resolution,
        bool verified,
        Dictionary<string, object>? executionMetrics = null)
    {
        lock (FileLock)
        {
            var dir = Path.GetDirectoryName(TraceFilePath);
            if (!string.IsNullOrEmpty(dir) && !Directory.Exists(dir))
            {
                Directory.CreateDirectory(dir);
            }

            var entry = new Dictionary<string, object>
            {
                ["testId"] = testId,
                ["timestamp"] = DateTime.UtcNow.ToString("o"),
                ["scenario"] = scenario,
                ["fault"] = fault,
                ["resolution"] = resolution,
                ["verified"] = verified,
            };

            if (executionMetrics != null)
            {
                foreach (var (k, v) in executionMetrics)
                {
                    entry[k] = v;
                }
            }

            File.AppendAllText(TraceFilePath, JsonSerializer.Serialize(entry) + "\n");
        }
    }
}

public sealed class ExamApiFactory : WebApplicationFactory<exam_service.Program>
{
    private readonly string _connection;

    public ExamApiFactory(string connection)
    {
        _connection = connection;
    }

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseEnvironment("Testing");
        builder.UseSetting("JwtSettings__Issuer", "https://auth.langfens.local");
        builder.UseSetting("JwtSettings__Audience", "langfens-api");
        builder.UseSetting("JwtSettings__SignKey", "SuperSecretTestingKeyAtLeast32BytesLong!!");
        builder.UseSetting("ConnectionStrings__exam-db", _connection);
        builder.UseSetting("EXAMSERVICE__INTERNAL__API__KEY", Phase02DurabilityTests.TestInternalApiKey);

        var envPath = Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, "../../../../../deploy/envs/loop-caps.env"));
        if (!File.Exists(envPath))
            envPath = Path.GetFullPath("deploy/envs/loop-caps.env");
        if (File.Exists(envPath))
        {
            foreach (var line in File.ReadAllLines(envPath))
            {
                var trimmed = line.Trim();
                if (string.IsNullOrWhiteSpace(trimmed) || trimmed.StartsWith("#")) continue;
                var eqIdx = trimmed.IndexOf('=');
                if (eqIdx > 0)
                    builder.UseSetting(trimmed[..eqIdx].Trim(), trimmed[(eqIdx + 1)..].Trim());
            }
        }
        builder.ConfigureServices(services =>
        {
            var workerDescriptors = services.Where(d => d.ServiceType == typeof(IHostedService) && d.ImplementationType == typeof(ReadingPaperWorker)).ToList();
            foreach (var w in workerDescriptors) services.Remove(w);

            // Replace ExamDbContext to point to our isolated test database
            var dbDescriptors = services.Where(d =>
                d.ServiceType == typeof(DbContextOptions<ExamDbContext>) ||
                d.ServiceType == typeof(ExamDbContext)).ToList();
            foreach (var d in dbDescriptors) services.Remove(d);

            services.AddDbContext<ExamDbContext>(options => options.UseNpgsql(_connection, npg =>
            {
                npg.ConfigureDataSource(dataSource => dataSource.EnableDynamicJson());
                npg.EnableRetryOnFailure();
            }));
        });
    }
}

[Collection("DatabaseTests")]
public class Phase02DurabilityTests
{
    private const string DefaultConn = "Host=localhost;Port=5433;Database=exam_test_phase02;Username=exam;Password=exam";
    public const string TestInternalApiKey = "test-only-ephemeral-secret-key-32chars";

    // Frozen pre-Phase-02 EF model: old application SQL must not depend on additive V2 columns.
    private sealed class LegacyReadingPaperContext(DbContextOptions<LegacyReadingPaperContext> options) : DbContext(options)
    {
        public DbSet<LegacyReadingPaperJob> Jobs => Set<LegacyReadingPaperJob>();
        public DbSet<Exam> Exams => Set<Exam>();
        public DbSet<ExamSection> Sections => Set<ExamSection>();
        public DbSet<ExamQuestionGroup> QuestionGroups => Set<ExamQuestionGroup>();
        public DbSet<ExamQuestion> Questions => Set<ExamQuestion>();
        public DbSet<ExamOption> Options => Set<ExamOption>();

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            var job = modelBuilder.Entity<LegacyReadingPaperJob>();
            job.ToTable("reading_paper_jobs");
            job.HasKey(x => x.Id);
            job.Property(x => x.Id).HasColumnName("Id");
            job.Property(x => x.Topic).HasColumnName("Topic");
            job.Property(x => x.Status).HasColumnName("Status");
            job.Property(x => x.CompletedSections).HasColumnName("CompletedSections");
            job.Property(x => x.SourcesJson).HasColumnName("SourcesJson");
            job.Property(x => x.SectionsJson).HasColumnName("SectionsJson");
            job.Property(x => x.Logs).HasColumnName("Logs");
            job.Property(x => x.Error).HasColumnName("Error");
            job.Property(x => x.ExamId).HasColumnName("ExamId");
            job.Property(x => x.LeaseUntil).HasColumnName("LeaseUntil");
            job.Property(x => x.LeaseOwner).HasColumnName("LeaseOwner");
            job.Property(x => x.CreatedAt).HasColumnName("CreatedAt");
            job.Property(x => x.UpdatedAt).HasColumnName("UpdatedAt");

            // These are the legacy exam graph mappings used by the pre-V2 worker.
            modelBuilder.Entity<Exam>(e =>
            {
                e.ToTable("exams");
                e.HasKey(x => x.Id);
                e.Property(x => x.Slug).IsRequired();
                e.HasIndex(x => x.Slug).IsUnique();
                e.Property(x => x.CreatedAt).HasDefaultValueSql("now()");
            });
            modelBuilder.Entity<ExamSection>(e =>
            {
                e.ToTable("exam_sections");
                e.HasKey(x => x.Id);
                e.Property(x => x.Title).IsRequired();
                e.HasIndex(x => new { x.ExamId, x.Idx });
                e.HasOne(x => x.Exam).WithMany(x => x.Sections).HasForeignKey(x => x.ExamId)
                    .OnDelete(DeleteBehavior.Cascade).IsRequired();
            });
            modelBuilder.Entity<ExamQuestionGroup>(e =>
            {
                e.ToTable("exam_question_groups");
                e.HasKey(x => x.Id);
                e.Property(x => x.InstructionMd).IsRequired();
                e.HasIndex(x => new { x.SectionId, x.Idx });
                e.HasOne(x => x.Section).WithMany(x => x.QuestionGroups).HasForeignKey(x => x.SectionId)
                    .OnDelete(DeleteBehavior.Cascade).IsRequired();
            });
            modelBuilder.Entity<ExamQuestion>(e =>
            {
                e.ToTable("exam_questions");
                e.HasKey(x => x.Id);
                e.Property(x => x.Type).IsRequired();
                e.Property(x => x.Skill).IsRequired();
                e.Property(x => x.PromptMd).IsRequired();
                e.Property(x => x.BlankAcceptTexts).HasColumnType("jsonb");
                e.Property(x => x.BlankAcceptRegex).HasColumnType("jsonb");
                e.Property(x => x.MatchPairs).HasColumnType("jsonb");
                e.Property(x => x.OrderCorrects).HasColumnType("text[]");
                e.Property(x => x.ShortAnswerAcceptTexts).HasColumnType("text[]");
                e.Property(x => x.ShortAnswerAcceptRegex).HasColumnType("text[]");
                e.Property(x => x.WordList).HasColumnType("text[]");
                e.HasIndex(x => new { x.SectionId, x.Idx });
                e.HasOne(x => x.Section).WithMany(x => x.Questions).HasForeignKey(x => x.SectionId)
                    .OnDelete(DeleteBehavior.Cascade).IsRequired();
                e.HasOne(x => x.Group).WithMany(x => x.Questions).HasForeignKey(x => x.GroupId)
                    .OnDelete(DeleteBehavior.SetNull).IsRequired(false);
            });
            modelBuilder.Entity<ExamOption>(e =>
            {
                e.ToTable("exam_options");
                e.HasKey(x => x.Id);
                e.Property(x => x.ContentMd).IsRequired();
                e.HasIndex(x => new { x.QuestionId, x.Idx });
                e.HasOne(x => x.Question).WithMany(x => x.Options).HasForeignKey(x => x.QuestionId)
                    .OnDelete(DeleteBehavior.Cascade).IsRequired();
            });
        }
    }

    private sealed class LegacyReadingPaperJob
    {
        public Guid Id { get; set; }
        public string Topic { get; set; } = "";
        public string Status { get; set; } = "Pending";
        public int CompletedSections { get; set; }
        public string SourcesJson { get; set; } = "[]";
        public string SectionsJson { get; set; } = "[]";
        public string Logs { get; set; } = "";
        public string? Error { get; set; }
        public Guid? ExamId { get; set; }
        public DateTime? LeaseUntil { get; set; }
        public Guid? LeaseOwner { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }

    private static async Task<string> SnapshotColumnsAsync<TEntity>(ExamDbContext db, IQueryable<TEntity> query)
        where TEntity : class
    {
        var entityType = db.Model.FindEntityType(typeof(TEntity))
            ?? throw new InvalidOperationException($"Entity type {typeof(TEntity).Name} is not in the V2 model.");
        var properties = entityType.GetProperties().OrderBy(property => property.Name, StringComparer.Ordinal).ToArray();
        var entities = await query.ToListAsync();
        var rows = new List<SortedDictionary<string, object?>>(entities.Count);

        foreach (var entity in entities)
        {
            var entry = db.Entry(entity);
            var row = new SortedDictionary<string, object?>(StringComparer.Ordinal);
            foreach (var property in properties)
                row[property.Name] = entry.Property(property.Name).CurrentValue;
            rows.Add(row);
        }

        rows.Sort((left, right) => StringComparer.Ordinal.Compare(JsonSerializer.Serialize(left), JsonSerializer.Serialize(right)));
        return JsonSerializer.Serialize(rows);
    }

    private static async Task<string> SnapshotDurableRunStateAsync(ExamDbContext db, string runId)
    {
        var state = new SortedDictionary<string, string>(StringComparer.Ordinal)
        {
            ["artifacts"] = await SnapshotColumnsAsync(db, db.ReadingPaperArtifacts.Where(row => row.RunId == runId)),
            ["heads"] = await SnapshotColumnsAsync(db, db.ReadingPaperArtifactHeads.Where(row => row.RunId == runId)),
            ["operations"] = await SnapshotColumnsAsync(db, db.ReadingPaperOperations.Where(row => row.RunId == runId)),
            ["outbox"] = await SnapshotColumnsAsync(db, db.ReadingPaperEventOutbox.Where(row => row.RunId == runId))
        };
        return JsonSerializer.Serialize(state);
    }

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

    private static async Task EnsureCleanMigratedDatabaseAsync(ServiceProvider provider)
    {
        using var scope = provider.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
        await db.Database.MigrateAsync();

        // Clear existing reading paper data for clean test runs
        await db.ReadingPaperEventOutbox.ExecuteDeleteAsync();
        await db.ReadingPaperOperations.ExecuteDeleteAsync();
        await db.ReadingPaperDecisions.ExecuteDeleteAsync();
        await db.ReadingPaperIssues.ExecuteDeleteAsync();
        await db.ReadingPaperEvaluations.ExecuteDeleteAsync();
        await db.ReadingPaperArtifactDependencies.ExecuteDeleteAsync();
        await db.ReadingPaperArtifactHeads.ExecuteDeleteAsync();
        await db.ReadingPaperArtifacts.ExecuteDeleteAsync();
        await db.ReadingPaperRuns.ExecuteDeleteAsync();
        await db.ReadingPaperJobs.ExecuteDeleteAsync();
    }

    private static ArtifactEnvelope CreateSampleArtifact(
        string artifactId,
        ArtifactType type,
        string runId,
        int version = 1,
        List<ArtifactRef>? parentRefs = null)
    {
        var refs = parentRefs ?? new List<ArtifactRef>();
        var payloadObj = new { title = $"Title for {artifactId}", version, timestamp = DateTime.UtcNow };
        var payloadJson = JsonSerializer.Serialize(payloadObj, LoopEngineJson.Options);
        using var doc = JsonDocument.Parse(payloadJson);
        var contentHash = ArtifactEnvelope.ComputeContentHash(doc.RootElement, refs);

        return new ArtifactEnvelope(
            artifactId,
            type,
            version,
            runId,
            1,
            "2.0.0",
            contentHash,
            DateTime.UtcNow,
            "2.0.0",
            doc.RootElement.Clone(),
            refs
        );
    }

    private static (string Version, string Source, string Json, string Sha256) BuildTestCapProfile(int calls, int tokens, int wallTime)
    {
        const string version = "phase02-test-v1";
        const string source = "Phase02DurabilityTests";
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

    private static async Task<(ReadingPaperJob Job, ReadingPaperRun Run)> CreateJobAndRunAsync(
        ExamDbContext db,
        Guid owner,
        int epoch = 1,
        int cancelVersion = 0)
    {
        var fixture = ReadingPaperTests.Paper();
        var job = new ReadingPaperJob
        {
            Id = Guid.NewGuid(),
            Topic = "Renewable Energy In Geothermal Reservoirs",
            Status = "Running",
            Epoch = epoch,
            CancelVersion = cancelVersion,
            LeaseOwner = owner,
            LeaseUntil = DateTime.UtcNow.AddMinutes(5),
            SourcesJson = JsonSerializer.Serialize(new[] { fixture[0].Source, fixture[1].Source, fixture[2].Source }, ReadingPaperRules.Json),
            SectionsJson = "[]",
            CompletedSections = 0,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        db.ReadingPaperJobs.Add(job);

        // RunId is stable per job
        var runId = $"run_{job.Id:N}";
        job.ActiveRunId = runId;

        var (pVer, pSrc, pJson, pSha) = BuildTestCapProfile(25, 150000, 900);
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
            BudgetCapWallTimeSeconds = 900,
            BudgetProfileVersion = pVer,
            BudgetProfileSha256 = pSha,
            BudgetProfileSource = pSrc,
            BudgetProfileJson = pJson,
            BudgetUsedCalls = 0,
            BudgetUsedTokens = 0,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        db.ReadingPaperRuns.Add(run);

        await db.SaveChangesAsync();
        return (job, run);
    }
    private static async Task<(ArtifactEnvelope PaperEnvelope, List<EvaluationResult> ValidEvaluations)> SeedFullAcceptedPaperGraphAsync(
        ExamDbContext db, ReadingPaperRun run, List<ReadingGeneratedSection> sections)
    {
        var runId = run.RunId;
        var sources = sections.Select(s => s.Source).ToList();
        run.SourceRevisionsJson = JsonSerializer.Serialize(sources, ReadingPaperRules.Json);
        await db.SaveChangesAsync();

        // 1. Blueprint
        var bpId = $"art_blueprint_{runId[..Math.Min(8, runId.Length)]}";
        var bpPayload = new { totalQuestions = 40, targetWordCountMin = 2150, targetWordCountMax = 2750 };
        var bpDoc = JsonDocument.Parse(JsonSerializer.Serialize(bpPayload, ReadingPaperRules.Json));
        var bpHash = ArtifactEnvelope.ComputeContentHash(bpDoc.RootElement, Array.Empty<ArtifactRef>());
        var bpEnv = new ArtifactEnvelope(bpId, ArtifactType.ExamBlueprint, 1, runId, null, "2.0.0", bpHash, DateTime.UtcNow.AddMinutes(-5), "2.0.0", bpDoc.RootElement.Clone(), Array.Empty<ArtifactRef>());

        db.ReadingPaperArtifacts.Add(new ReadingPaperArtifact
        {
            Id = Guid.NewGuid(), RunId = runId, ArtifactId = bpId, ArtifactType = ArtifactType.ExamBlueprint.ToString(),
            Version = 1, ContentHash = bpHash, PayloadJson = bpDoc.RootElement.GetRawText(), ParentRefsJson = "[]",
            EnvelopeJson = JsonSerializer.Serialize(bpEnv, LoopEngineJson.Options), CreatedAt = bpEnv.CreatedAt
        });
        db.ReadingPaperArtifactHeads.Add(new ReadingPaperArtifactHead
        {
            Id = Guid.NewGuid(), RunId = runId, ArtifactId = bpId, AcceptedVersion = 1, AcceptedHash = bpHash, UpdatedAt = bpEnv.CreatedAt
        });

        var bpRef = bpEnv.ToRef();

        // 2. Passages & Questions for each section
        var passageRefs = new List<ArtifactRef>();
        var sectionRefs = new List<ArtifactRef>();
        var allQuestionRefs = new List<ArtifactRef>();
        var sectionEnvelopes = new List<ArtifactEnvelope>();

        for (int i = 0; i < 3; i++)
        {
            var secIdx = i + 1;
            var sec = sections[i];

            // Passage
            var pId = $"art_passage_s{secIdx}";
            var pPayload = new { text = sec.Passage, passage = sec.Passage, wordCount = ReadingPaperRules.WordCount(sec.Passage), source = sec.Source };
            var pDoc = JsonDocument.Parse(JsonSerializer.Serialize(pPayload, ReadingPaperRules.Json));
            var pParents = new List<ArtifactRef> { bpRef };
            var pHash = ArtifactEnvelope.ComputeContentHash(pDoc.RootElement, pParents);
            var pEnv = new ArtifactEnvelope(pId, ArtifactType.Passage, 1, runId, secIdx, "2.0.0", pHash, DateTime.UtcNow.AddMinutes(-4), "2.0.0", pDoc.RootElement.Clone(), pParents);

            db.ReadingPaperArtifacts.Add(new ReadingPaperArtifact
            {
                Id = Guid.NewGuid(), RunId = runId, ArtifactId = pId, ArtifactType = ArtifactType.Passage.ToString(),
                Version = 1, ContentHash = pHash, PayloadJson = pDoc.RootElement.GetRawText(),
                ParentRefsJson = JsonSerializer.Serialize(pParents, LoopEngineJson.Options),
                EnvelopeJson = JsonSerializer.Serialize(pEnv, LoopEngineJson.Options), CreatedAt = pEnv.CreatedAt
            });
            db.ReadingPaperArtifactHeads.Add(new ReadingPaperArtifactHead
            {
                Id = Guid.NewGuid(), RunId = runId, ArtifactId = pId, AcceptedVersion = 1, AcceptedHash = pHash, UpdatedAt = pEnv.CreatedAt
            });

            var pRef = pEnv.ToRef();
            passageRefs.Add(pRef);

            // Questions in this section
            var secQuestionRefs = new List<ArtifactRef>();
            var secQuestions = sec.Groups.SelectMany(g => g.Questions).ToList();
            foreach (var q in secQuestions)
            {
                var qId = $"art_q_{q.Number}";
                var qPayload = new
                {
                    number = q.Number,
                    questionNumber = q.Number,
                    prompt = q.Prompt,
                    answer = q.Answer,
                    options = q.Options,
                    evidenceQuote = q.EvidenceQuote,
                    explanation = q.Explanation
                };
                var qDoc = JsonDocument.Parse(JsonSerializer.Serialize(qPayload, ReadingPaperRules.Json));
                var qParents = new List<ArtifactRef> { pRef, bpRef };
                var qHash = ArtifactEnvelope.ComputeContentHash(qDoc.RootElement, qParents);
                var qEnv = new ArtifactEnvelope(qId, ArtifactType.Question, 1, runId, secIdx, "2.0.0", qHash, DateTime.UtcNow.AddMinutes(-3), "2.0.0", qDoc.RootElement.Clone(), qParents);

                db.ReadingPaperArtifacts.Add(new ReadingPaperArtifact
                {
                    Id = Guid.NewGuid(), RunId = runId, ArtifactId = qId, ArtifactType = ArtifactType.Question.ToString(),
                    Version = 1, ContentHash = qHash, PayloadJson = qDoc.RootElement.GetRawText(),
                    ParentRefsJson = JsonSerializer.Serialize(qParents, LoopEngineJson.Options),
                    EnvelopeJson = JsonSerializer.Serialize(qEnv, LoopEngineJson.Options), CreatedAt = qEnv.CreatedAt
                });
                db.ReadingPaperArtifactHeads.Add(new ReadingPaperArtifactHead
                {
                    Id = Guid.NewGuid(), RunId = runId, ArtifactId = qId, AcceptedVersion = 1, AcceptedHash = qHash, UpdatedAt = qEnv.CreatedAt
                });

                var qRef = qEnv.ToRef();
                secQuestionRefs.Add(qRef);
                allQuestionRefs.Add(qRef);
            }

            // Section envelope
            var secId = $"art_section_{secIdx}";
            var secPayloadObj = new
            {
                sectionId = secIdx,
                title = sec.Title,
                passage = sec.Passage,
                source = sec.Source,
                passageRef = pRef,
                blueprintRef = bpRef,
                questionRefs = secQuestionRefs,
                groups = sec.Groups.Select(g => new
                {
                    type = g.Type,
                    instruction = g.Instruction,
                    questions = g.Questions.Select(q => new
                    {
                        number = q.Number,
                        questionNumber = q.Number,
                        prompt = q.Prompt,
                        answer = q.Answer,
                        options = q.Options,
                        evidenceQuote = q.EvidenceQuote,
                        explanation = q.Explanation
                    }).ToList()
                }).ToList()
            };
            var secDoc = JsonDocument.Parse(JsonSerializer.Serialize(secPayloadObj, ReadingPaperRules.Json));
            var secParents = new List<ArtifactRef> { pRef, bpRef }.Concat(secQuestionRefs).ToList();
            var secHash = ArtifactEnvelope.ComputeContentHash(secDoc.RootElement, secParents);
            var secEnv = new ArtifactEnvelope(secId, ArtifactType.Section, 1, runId, secIdx, "2.0.0", secHash, DateTime.UtcNow.AddMinutes(-2), "2.0.0", secDoc.RootElement.Clone(), secParents);

            db.ReadingPaperArtifacts.Add(new ReadingPaperArtifact
            {
                Id = Guid.NewGuid(), RunId = runId, ArtifactId = secId, ArtifactType = ArtifactType.Section.ToString(),
                Version = 1, ContentHash = secHash, PayloadJson = secDoc.RootElement.GetRawText(),
                ParentRefsJson = JsonSerializer.Serialize(secParents, LoopEngineJson.Options),
                EnvelopeJson = JsonSerializer.Serialize(secEnv, LoopEngineJson.Options), CreatedAt = secEnv.CreatedAt
            });
            db.ReadingPaperArtifactHeads.Add(new ReadingPaperArtifactHead
            {
                Id = Guid.NewGuid(), RunId = runId, ArtifactId = secId, AcceptedVersion = 1, AcceptedHash = secHash, UpdatedAt = secEnv.CreatedAt
            });

            var secRef = secEnv.ToRef();
            sectionRefs.Add(secRef);
            sectionEnvelopes.Add(secEnv);
        }

        // 3. Paper Envelope
        var paperId = $"art_paper_{runId[..Math.Min(8, runId.Length)]}";
        var paperPayloadObj = new
        {
            paperId = paperId,
            runId = runId,
            title = "IELTS Academic Reading Paper",
            totalQuestions = 40,
            blueprintRef = bpRef,
            sectionRefs = sectionRefs,
            passageRefs = passageRefs,
            questionRefs = allQuestionRefs,
            sections = sectionEnvelopes.Select(s => s.Payload).ToList()
        };
        var paperDoc = JsonDocument.Parse(JsonSerializer.Serialize(paperPayloadObj, ReadingPaperRules.Json));
        var paperParents = new List<ArtifactRef> { bpRef }.Concat(sectionRefs).Concat(passageRefs).Concat(allQuestionRefs).ToList();
        var paperHash = ArtifactEnvelope.ComputeContentHash(paperDoc.RootElement, paperParents);
        var paperEnv = new ArtifactEnvelope(paperId, ArtifactType.ReadingPaper, 1, runId, null, "2.0.0", paperHash, DateTime.UtcNow.AddMinutes(-1), "2.0.0", paperDoc.RootElement.Clone(), paperParents);

        db.ReadingPaperArtifacts.Add(new ReadingPaperArtifact
        {
            Id = Guid.NewGuid(), RunId = runId, ArtifactId = paperId, ArtifactType = ArtifactType.ReadingPaper.ToString(),
            Version = 1, ContentHash = paperHash, PayloadJson = paperDoc.RootElement.GetRawText(),
            ParentRefsJson = JsonSerializer.Serialize(paperParents, LoopEngineJson.Options),
            EnvelopeJson = JsonSerializer.Serialize(paperEnv, LoopEngineJson.Options), CreatedAt = paperEnv.CreatedAt
        });
        db.ReadingPaperArtifactHeads.Add(new ReadingPaperArtifactHead
        {
            Id = Guid.NewGuid(), RunId = runId, ArtifactId = paperId, AcceptedVersion = 1, AcceptedHash = paperHash, UpdatedAt = paperEnv.CreatedAt
        });

        await db.SaveChangesAsync();

        // 4. Default Valid Evaluations
        var validEvaluations = ReadingPaperFinalSnapshot.RequiredEvaluators.Select(kv => new EvaluationResult(
            EvaluationId: $"eval_{kv.Key}_{Guid.NewGuid():N}"[..24],
            EvaluatorId: kv.Key,
            EvaluatorVersion: kv.Value,
            TargetRef: paperEnv.ToRef(),
            Status: EvaluationStatus.PASS,
            Issues: new List<Issue>(),
            Score: 1.0,
            InputDependencyRefs: paperParents,
            Provider: "test-provider",
            Model: "test-model",
            PromptVersion: "1.0.0",
            ElapsedMs: 120.0,
            Usage: new UsageMetrics(100, 50, 150, 0.001),
            EvaluatedAt: DateTime.UtcNow
        )).ToList();

        return (paperEnv, validEvaluations);
    }

    [Fact]
    public async Task T02_01_ConcurrentWriters_SameOperationId_YieldsSingleCommitAndReplay()
    {
        await using var provider = CreateTestProvider();
        await EnsureCleanMigratedDatabaseAsync(provider);

        var owner = Guid.NewGuid();
        Guid jobId;
        string runId;

        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var (_, run) = await CreateJobAndRunAsync(db, owner, epoch: 1);
            jobId = run.JobId;
            runId = run.RunId;
        }

        var operationId = "op_concurrent_01";
        var requestHash = "hash_request_concurrent_01";
        var artifact = CreateSampleArtifact("art_passage_01", ArtifactType.Passage, runId, version: 1);

        var task1 = Task.Run(async () =>
        {
            using var scope = provider.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var grantReq = new OperationGrantRequest(runId, 1, owner, operationId, "LLM_PASSAGE", requestHash, 2000);
            await CheckpointService.GrantOperationAsync(db, grantReq, CancellationToken.None);

            var commitReq = new CheckpointCommitRequest(
                runId, 1, owner, operationId, requestHash, artifact,
                TokensUsed: 1500
            );
            return await CheckpointService.CommitCheckpointAsync(db, commitReq, CancellationToken.None);
        });

        var task2 = Task.Run(async () =>
        {
            using var scope = provider.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var grantReq = new OperationGrantRequest(runId, 1, owner, operationId, "LLM_PASSAGE", requestHash, 2000);
            await CheckpointService.GrantOperationAsync(db, grantReq, CancellationToken.None);

            var commitReq = new CheckpointCommitRequest(
                runId, 1, owner, operationId, requestHash, artifact,
                TokensUsed: 1500
            );
            return await CheckpointService.CommitCheckpointAsync(db, commitReq, CancellationToken.None);
        });

        var results = await Task.WhenAll(task1, task2);
        Assert.NotNull(results[0]);
        Assert.NotNull(results[1]);

        Assert.Equal(artifact.ArtifactId, results[0].ArtifactId);
        Assert.Equal(artifact.ArtifactId, results[1].ArtifactId);
        Assert.Equal(artifact.ContentHash, results[0].ContentHash);
        Assert.Equal(artifact.ContentHash, results[1].ContentHash);

        int opsCount;
        int artsCount;
        int headsCount;
        int usedCalls;

        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            opsCount = await db.ReadingPaperOperations.CountAsync(o => o.RunId == runId && o.OperationId == operationId);
            artsCount = await db.ReadingPaperArtifacts.CountAsync(a => a.RunId == runId && a.ArtifactId == artifact.ArtifactId);
            headsCount = await db.ReadingPaperArtifactHeads.CountAsync(h => h.RunId == runId && h.ArtifactId == artifact.ArtifactId);
            var run = await db.ReadingPaperRuns.FirstAsync(r => r.RunId == runId);
            usedCalls = run.BudgetUsedCalls;
        }

        Assert.Equal(1, opsCount);
        Assert.Equal(1, artsCount);
        Assert.Equal(1, headsCount);
        Assert.Equal(1, usedCalls);

        FaultTraceRecorder.RecordTrace(
            "T02-01",
            "Concurrent writers with identical operationId and requestHash",
            "PostgreSQL unique constraint race on simultaneous grant and commit",
            "One transaction wins insert; second transaction catches PostgreSQL 23505, detects committed head, and returns idempotent replay CheckpointAck.",
            verified: true,
            new Dictionary<string, object>
            {
                ["runId"] = runId,
                ["operationId"] = operationId,
                ["operationsInDb"] = opsCount,
                ["artifactsInDb"] = artsCount,
                ["headsInDb"] = headsCount,
                ["ack1Replay"] = results[0].IsReplay,
                ["ack2Replay"] = results[1].IsReplay,
            }
        );
    }

    [Fact]
    public async Task T02_01_BudgetReservation_AtomicCapEnforcement_RejectsConcurrentOversubscription()
    {
        await using var provider = CreateTestProvider();
        await EnsureCleanMigratedDatabaseAsync(provider);

        var owner = Guid.NewGuid();
        string runId;

        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var (_, run) = await CreateJobAndRunAsync(db, owner, epoch: 1);
            runId = run.RunId;

            // Set tight cap: 5000 tokens
            run.BudgetCapTokens = 5000;
            var (pVer, pSrc, pJson, pSha) = BuildTestCapProfile(25, 5000, 900);
            run.BudgetProfileJson = pJson;
            run.BudgetProfileSha256 = pSha;
            await db.SaveChangesAsync();
        }

        // Two concurrent grants requesting 3000 tokens each (total 6000 > cap 5000)
        var t1 = Task.Run(async () =>
        {
            using var scope = provider.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var req = new OperationGrantRequest(runId, 1, owner, "op_budget_1", "LLM", "hash_b1", 3000);
            try
            {
                var res = await CheckpointService.GrantOperationAsync(db, req, CancellationToken.None);
                return (Success: true, Status: res.Status, ErrorCode: 0);
            }
            catch (CheckpointValidationException ex)
            {
                return (Success: false, Status: "EXHAUSTED", ErrorCode: ex.StatusCode);
            }
        });

        var t2 = Task.Run(async () =>
        {
            using var scope = provider.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var req = new OperationGrantRequest(runId, 1, owner, "op_budget_2", "LLM", "hash_b2", 3000);
            try
            {
                var res = await CheckpointService.GrantOperationAsync(db, req, CancellationToken.None);
                return (Success: true, Status: res.Status, ErrorCode: 0);
            }
            catch (CheckpointValidationException ex)
            {
                return (Success: false, Status: "EXHAUSTED", ErrorCode: ex.StatusCode);
            }
        });

        var results = await Task.WhenAll(t1, t2);

        // Exactly one must succeed, and exactly one must fail with 422 Unprocessable (Budget Exhausted)
        var successes = results.Count(r => r.Success);
        var exhausted = results.Count(r => !r.Success && r.ErrorCode == 422);

        Assert.Equal(1, successes);
        Assert.Equal(1, exhausted);

        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var run = await db.ReadingPaperRuns.FirstAsync(r => r.RunId == runId);
            Assert.True(run.BudgetUsedTokens <= run.BudgetCapTokens);
            Assert.Equal(3000, run.BudgetUsedTokens);
        }
    }
    [Fact]
    public async Task T02_02_SameOperationId_DifferentRequestHash_RejectsWithConflict()
    {
        await using var provider = CreateTestProvider();
        await EnsureCleanMigratedDatabaseAsync(provider);

        var owner = Guid.NewGuid();
        string runId;

        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var (_, run) = await CreateJobAndRunAsync(db, owner, epoch: 1);
            runId = run.RunId;

            var reqA = new OperationGrantRequest(runId, 1, owner, "op_unique_test", "LLM_CALL", "hash_alpha_12345", 2500);
            var resA = await CheckpointService.GrantOperationAsync(db, reqA, CancellationToken.None);
            Assert.Equal("RESERVED", resA.Status);
            Assert.False(resA.IsReplay);

            var reqB = new OperationGrantRequest(runId, 1, owner, "op_unique_test", "LLM_CALL", "hash_beta_98765", 2500);
            var ex = await Assert.ThrowsAsync<CheckpointValidationException>(() =>
                CheckpointService.GrantOperationAsync(db, reqB, CancellationToken.None));

            Assert.Equal(409, ex.StatusCode);
            Assert.Contains("different request hash", ex.Message);

            var op = await db.ReadingPaperOperations.FirstAsync(o => o.RunId == runId && o.OperationId == "op_unique_test");
            Assert.Equal("hash_alpha_12345", op.RequestHash);

            FaultTraceRecorder.RecordTrace(
                "T02-02",
                "OperationId reuse with conflicting requestHash",
                "Re-grant attempt with different request parameters under same operation ID",
                "CheckpointValidationException HTTP 409 Conflict thrown. Existing operation and requestHash retained without mutation.",
                verified: true,
                new Dictionary<string, object>
                {
                    ["runId"] = runId,
                    ["operationId"] = "op_unique_test",
                    ["initialHash"] = "hash_alpha_12345",
                    ["conflictingHash"] = "hash_beta_98765",
                    ["statusCode"] = ex.StatusCode,
                }
            );
        }
    }

    [Fact]
    public async Task T02_03_CrashScenarios_CrashBeforeCommit_LostAck_DurableResume()
    {
        await using var provider = CreateTestProvider();
        await EnsureCleanMigratedDatabaseAsync(provider);

        var owner = Guid.NewGuid();
        string runId;

        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var (_, run) = await CreateJobAndRunAsync(db, owner, epoch: 1);
            runId = run.RunId;
        }

        var artifact = CreateSampleArtifact("art_section_01", ArtifactType.Section, runId, version: 1);
        var opId = "op_crash_recovery_01";
        var reqHash = "hash_crash_recovery_01";

        // Scenario A: Crash before commit
        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var grantReq = new OperationGrantRequest(runId, 1, owner, opId, "LLM_SECTION", reqHash, 3000);
            await CheckpointService.GrantOperationAsync(db, grantReq, CancellationToken.None);
        }

        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var resume = await CheckpointService.ResumeStateAsync(db, runId, CancellationToken.None);
            Assert.Empty(resume.Artifacts);
        }

        // Scenario B: Commit succeeds, but ACK is lost in flight
        CheckpointAck ack1;
        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var commitReq = new CheckpointCommitRequest(
                runId, 1, owner, opId, reqHash, artifact,
                TokensUsed: 2200
            );
            ack1 = await CheckpointService.CommitCheckpointAsync(db, commitReq, CancellationToken.None);
            Assert.Equal(artifact.ContentHash, ack1.ContentHash);
            Assert.False(ack1.IsReplay);
        }

        // Retrying identical commit (lost ACK recovery)
        CheckpointAck ack2;
        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var retryReq = new CheckpointCommitRequest(
                runId, 1, owner, opId, reqHash, artifact,
                TokensUsed: 2200
            );
            ack2 = await CheckpointService.CommitCheckpointAsync(db, retryReq, CancellationToken.None);
            Assert.Equal(ack1.ContentHash, ack2.ContentHash);
            Assert.True(ack2.IsReplay);
        }

        // Scenario C: Durable resume
        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var resume = await CheckpointService.ResumeStateAsync(db, runId, CancellationToken.None);
            Assert.Single(resume.Artifacts);
            Assert.Equal(artifact.ArtifactId, resume.Artifacts[0].ArtifactId);
            Assert.Equal(artifact.ContentHash, resume.Artifacts[0].AcceptedHash);

            FaultTraceRecorder.RecordTrace(
                "T02-03",
                "Crash before commit, lost ACK in flight, and durable resume",
                "Process killed post-grant (before commit) and network packet loss after database commit",
                "Pre-commit crash leaves 0 artifacts; network lost ACK recovery re-sends operation and gets replay CheckpointAck; resume API returns exact committed accepted head.",
                verified: true,
                new Dictionary<string, object>
                {
                    ["runId"] = runId,
                    ["operationId"] = opId,
                    ["resumedArtifactsCount"] = resume.Artifacts.Count,
                    ["isReplayAck"] = ack2.IsReplay,
                }
            );
        }
    }

    [Fact]
    public async Task T06_06_DurableResumeCursor_And_Issues_Rehydrated_OnPostgreSql()
    {
        await using var provider = CreateTestProvider();
        await EnsureCleanMigratedDatabaseAsync(provider);

        var owner = Guid.NewGuid();
        string runId;

        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var (_, run) = await CreateJobAndRunAsync(db, owner, epoch: 1);
            runId = run.RunId;
        }

        var artifact = CreateSampleArtifact("passage_01", ArtifactType.Passage, runId, version: 1);
        var opGenId = "op_gen_01";
        var reqGenHash = "hash_gen_01";

        // 1. Grant generation and save draft checkpoint (without promoting accepted head)
        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            await CheckpointService.GrantOperationAsync(db, new OperationGrantRequest(runId, 1, owner, opGenId, "GENERATE", reqGenHash, 2500), CancellationToken.None);
            var draftAck = await CheckpointService.SaveDraftCheckpointAsync(db, new DraftCheckpointRequest(runId, 1, owner, opGenId, reqGenHash, artifact, TokensUsed: 2100), CancellationToken.None);
            Assert.Equal("passage_01", draftAck.ArtifactId);
        }

        // 2. Grant evaluation, evaluate with issue (Status = OPEN), and reconcile with ResultRefJson
        var opEvalId = "op_eval_01";
        var reqEvalHash = "hash_eval_01";
        var fp = Issue.ComputeFingerprint(IssueCode.WORD_LIMIT_EXCEEDED, IssueScope.SECTION, new[] { artifact.ToRef() }, "Exceeds word limit");
        var issue1 = new Issue(
            "iss_01",
            IssueCode.WORD_LIMIT_EXCEEDED,
            IssueSeverity.CRITICAL,
            IssueScope.SECTION,
            new List<ArtifactRef> { artifact.ToRef() },
            "Exceeds word limit",
            null,
            "proposed_trim",
            IssueStatus.OPEN,
            fp,
            DateTime.UtcNow,
            null,
            "eval_word_count"
        );
        var evalResult = new EvaluationResult(
            "eval_01",
            "eval_word_count",
            "1.0.0",
            artifact.ToRef(),
            EvaluationStatus.FAIL,
            new List<Issue> { issue1 },
            Score: 0.6,
            InputDependencyRefs: new List<ArtifactRef>(),
            Provider: "fake_provider",
            Model: "fake_model",
            PromptVersion: "1.0",
            ElapsedMs: 120.0,
            Usage: new UsageMetrics(PromptTokens: 200, CompletionTokens: 100, TotalTokens: 300, CostUsd: 0.001),
            EvaluatedAt: DateTime.UtcNow
        );

        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            await CheckpointService.GrantOperationAsync(db, new OperationGrantRequest(runId, 1, owner, opEvalId, "EVALUATE", reqEvalHash, 1000), CancellationToken.None);
            await CheckpointService.ReconcileOperationAsync(db, new OperationReconcileRequest(
                runId, 1, owner, opEvalId, TokensUsed: 500, WallTimeUsedSeconds: 0.2,
                AccountingType: "REPORTED",
                ResultRefJson: JsonSerializer.Serialize(evalResult, LoopEngineJson.Options)
            ), CancellationToken.None);
        }

        // 3. Mark issue as RESOLVED on subsequent operation reconciliation
        var opEval2Id = "op_eval_02";
        var reqEval2Hash = "hash_eval_02";
        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            await CheckpointService.GrantOperationAsync(db, new OperationGrantRequest(runId, 1, owner, opEval2Id, "EVALUATE", reqEval2Hash, 1000), CancellationToken.None);
            await CheckpointService.ReconcileOperationAsync(db, new OperationReconcileRequest(
                runId, 1, owner, opEval2Id, TokensUsed: 400, WallTimeUsedSeconds: 0.1,
                AccountingType: "REPORTED",
                ResolvedFingerprints: new List<string> { fp }
            ), CancellationToken.None);
        }

        // 4. Simulate crash and resume: ResumeStateAsync on fresh DbContext from PostgreSQL
        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var resume = await CheckpointService.ResumeStateAsync(db, runId, CancellationToken.None);

            // Invariant: Draft artifact exists, accepted heads is empty (not prematurely promoted!)
            Assert.Empty(resume.Artifacts);
            Assert.NotNull(resume.DraftArtifacts);
            Assert.Single(resume.DraftArtifacts);
            Assert.Equal("passage_01", resume.DraftArtifacts[0].ArtifactId);
            Assert.Equal(1, resume.DraftArtifacts[0].AcceptedVersion);

            // Invariant: Issues rehydrated from evaluation with full AffectedRefs, EvaluatorId, and status RESOLVED!
            Assert.NotNull(resume.Issues);
            Assert.Single(resume.Issues);
            var rehydrated = resume.Issues[0];
            Assert.Equal(fp, rehydrated.Fingerprint);
            Assert.Equal(IssueStatus.RESOLVED, rehydrated.Status);
            Assert.Equal("eval_word_count", rehydrated.EvaluatorId);
            Assert.Single(rehydrated.AffectedRefs);
            Assert.Equal("passage_01", rehydrated.AffectedRefs[0].ArtifactId);

            // Invariant: Cumulative tokens used preserved across PostgreSQL
            Assert.Equal(2100 + 500 + 400, resume.TokensUsed);
            Assert.Equal(3, resume.CallsUsed);
        }
    }

    [Fact]
    public async Task T02_04_LeaseExpiry_WorkerTakeover_RejectsOldEpochWrites_And_ResumesOnSameRun()
    {
        await using var provider = CreateTestProvider();
        await EnsureCleanMigratedDatabaseAsync(provider);

        var workerA = Guid.NewGuid();
        var workerB = Guid.NewGuid();
        Guid jobId;
        string runId;

        // Worker A claims job at Epoch 1 and commits section 1
        var art1 = CreateSampleArtifact("art_section_1", ArtifactType.Section, "placeholder", version: 1);
        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var (job, run) = await CreateJobAndRunAsync(db, workerA, epoch: 1);
            jobId = job.Id;
            runId = run.RunId;

            // Commit section 1 under Worker A
            var art1Corrected = CreateSampleArtifact("art_section_1", ArtifactType.Section, runId, version: 1);
            await CheckpointService.GrantOperationAsync(db, new OperationGrantRequest(runId, 1, workerA, "op_a_1", "GEN", "hash_a_1", 1000), CancellationToken.None);
            await CheckpointService.CommitCheckpointAsync(db, new CheckpointCommitRequest(runId, 1, workerA, "op_a_1", "hash_a_1", art1Corrected), CancellationToken.None);

            // Worker A's lease expires
            await db.ReadingPaperJobs.Where(j => j.Id == jobId).ExecuteUpdateAsync(x => x.SetProperty(j => j.LeaseUntil, DateTime.UtcNow.AddSeconds(-10)));
            await db.ReadingPaperRuns.Where(r => r.JobId == jobId).ExecuteUpdateAsync(x => x.SetProperty(r => r.LeaseUntil, DateTime.UtcNow.AddSeconds(-10)));
        }

        // Worker B takes over: increments Epoch to 2 on the SAME job and run
        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var claimed = await db.ReadingPaperJobs
                .Where(j => j.Id == jobId && j.Status == "Running" && j.LeaseUntil < DateTime.UtcNow)
                .ExecuteUpdateAsync(x => x.SetProperty(j => j.Epoch, j => j.Epoch + 1)
                    .SetProperty(j => j.LeaseOwner, workerB)
                    .SetProperty(j => j.LeaseUntil, DateTime.UtcNow.AddMinutes(3)));
            Assert.Equal(1, claimed);

            // Update the SAME run to epoch 2
            await db.ReadingPaperRuns
                .Where(r => r.JobId == jobId)
                .ExecuteUpdateAsync(x => x.SetProperty(r => r.Epoch, 2)
                    .SetProperty(r => r.LeaseOwner, workerB)
                    .SetProperty(r => r.LeaseUntil, DateTime.UtcNow.AddMinutes(3)));
        }

        // Stale Worker A wakes up and attempts to commit with Epoch 1 on the run -> Must 409
        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var staleArtifact = CreateSampleArtifact("art_zombie_section", ArtifactType.Section, runId, version: 1);
            var staleReq = new CheckpointCommitRequest(
                runId, 1, workerA, "op_stale_worker_a", "hash_stale", staleArtifact,
                TokensUsed: 1000
            );

            var ex = await Assert.ThrowsAsync<CheckpointValidationException>(() =>
                CheckpointService.CommitCheckpointAsync(db, staleReq, CancellationToken.None));

            Assert.Equal(409, ex.StatusCode);
            Assert.Contains("fencing violation", ex.Message);
        }

        // Worker B resumes on the exact SAME runId and sees Worker A's committed section 1!
        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var resume = await CheckpointService.ResumeStateAsync(db, runId, CancellationToken.None);
            Assert.Single(resume.Artifacts);
            Assert.Equal("art_section_1", resume.Artifacts[0].ArtifactId);

            // Worker B commits section 2 at Epoch 2 -> Succeeded!
            var art2 = CreateSampleArtifact("art_section_2", ArtifactType.Section, runId, version: 1);
            await CheckpointService.GrantOperationAsync(db, new OperationGrantRequest(runId, 2, workerB, "op_b_2", "GEN", "hash_b_2", 1000), CancellationToken.None);
            var ackB = await CheckpointService.CommitCheckpointAsync(db, new CheckpointCommitRequest(runId, 2, workerB, "op_b_2", "hash_b_2", art2), CancellationToken.None);
            Assert.Equal("art_section_2", ackB.ArtifactId);
            Assert.Equal(2, ackB.Epoch);

            FaultTraceRecorder.RecordTrace(
                "T02-04",
                "Lease expiry and takeover by new worker",
                "Zombie worker attempts write using expired lease and stale epoch",
                "Epoch fencing violation detected. Checkpoint API rejects write with HTTP 409 Conflict; worker B resumes exact prior artifacts and continues under new epoch.",
                verified: true,
                new Dictionary<string, object>
                {
                    ["runId"] = runId,
                    ["staleWorkerEpoch"] = 1,
                    ["activeWorkerEpoch"] = 2,
                    ["preservedArtifactsCount"] = resume.Artifacts.Count,
                }
            );
        }
    }

    [Fact]
    public async Task T02_04_Race_TakeoverStartsAfterAuthorityValidation_FailsAtConditionalCommitFence()
    {
        await using var provider = CreateTestProvider();
        await EnsureCleanMigratedDatabaseAsync(provider);

        var workerA = Guid.NewGuid();
        var workerB = Guid.NewGuid();
        Guid jobId;
        string runId;

        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var (job, run) = await CreateJobAndRunAsync(db, workerA, epoch: 1);
            jobId = job.Id;
            runId = run.RunId;

            var opReq = new OperationGrantRequest(runId, 1, workerA, "op_race_fence", "LLM", "hash_race", 1000);
            await CheckpointService.GrantOperationAsync(db, opReq, CancellationToken.None);

            var art = CreateSampleArtifact("art_race_section", ArtifactType.Section, runId);
            var commitReq = new CheckpointCommitRequest(runId, 1, workerA, "op_race_fence", "hash_race", art);

            // Hook intercepts execution AFTER initial authority validation succeeds,
            // but BEFORE the in-transaction conditional lock executes!
            var ex = await Assert.ThrowsAsync<CheckpointValidationException>(() =>
                CheckpointService.CommitCheckpointAsync(db, commitReq, CancellationToken.None, onBeforeTransaction: async () =>
                {
                    // Worker B takes over in the database right after initial validation passed!
                    using var takeoverScope = provider.CreateScope();
                    var takeoverDb = takeoverScope.ServiceProvider.GetRequiredService<ExamDbContext>();
                    await takeoverDb.ReadingPaperJobs.Where(j => j.Id == jobId).ExecuteUpdateAsync(x => x
                        .SetProperty(j => j.Epoch, 2)
                        .SetProperty(j => j.LeaseOwner, workerB));
                    await takeoverDb.ReadingPaperRuns.Where(r => r.RunId == runId).ExecuteUpdateAsync(x => x
                        .SetProperty(r => r.Epoch, 2)
                        .SetProperty(r => r.LeaseOwner, workerB));
                }));

            // Must be rejected specifically by the in-transaction fencing validation
            Assert.Equal(409, ex.StatusCode);
            Assert.Contains("Epoch fencing violation", ex.Message);
        }
    }

    [Fact]
    public async Task T02_05_CancellationDuringProviderCall_RejectsLateResult()
    {
        await using var provider = CreateTestProvider();
        await EnsureCleanMigratedDatabaseAsync(provider);

        var owner = Guid.NewGuid();
        string runId;
        Guid jobId;

        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var (job, run) = await CreateJobAndRunAsync(db, owner, epoch: 1);
            jobId = job.Id;
            runId = run.RunId;

            var grantReq = new OperationGrantRequest(runId, 1, owner, "op_cancel_test", "LLM_CALL", "hash_cancel", 3000);
            await CheckpointService.GrantOperationAsync(db, grantReq, CancellationToken.None);

            // Admin cancels the job while provider call was in flight
            await db.ReadingPaperJobs.Where(j => j.Id == jobId).ExecuteUpdateAsync(x => x.SetProperty(j => j.Status, "Cancelled").SetProperty(j => j.CancelVersion, 1));
            await db.ReadingPaperRuns.Where(r => r.RunId == runId).ExecuteUpdateAsync(x => x.SetProperty(r => r.Status, "CANCELLED").SetProperty(r => r.CancelVersion, 1));
        }

        // Late provider result arrives and tries to commit
        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var artifact = CreateSampleArtifact("art_late_passage", ArtifactType.Passage, runId, version: 1);
            var commitReq = new CheckpointCommitRequest(
                runId, 1, owner, "op_cancel_test", "hash_cancel", artifact,
                TokensUsed: 1000
            );

            var ex = await Assert.ThrowsAsync<CheckpointValidationException>(() =>
                CheckpointService.CommitCheckpointAsync(db, commitReq, CancellationToken.None));

            Assert.Equal(409, ex.StatusCode);
            Assert.Contains("cancelled", ex.Message);

            var job = await db.ReadingPaperJobs.FirstAsync(j => j.Id == jobId);
            Assert.Equal("Cancelled", job.Status);
            var headExists = await db.ReadingPaperArtifactHeads.AnyAsync(h => h.RunId == runId);
            Assert.False(headExists);

            FaultTraceRecorder.RecordTrace(
                "T02-05",
                "Job cancellation while provider computation is in flight",
                "Late provider response arrives after admin cancelled the job",
                "CancelVersion mismatch and Cancelled status check rejects late result with HTTP 409 Conflict. Job and run remain cancelled; no artifacts accepted.",
                verified: true,
                new Dictionary<string, object>
                {
                    ["runId"] = runId,
                    ["statusCode"] = ex.StatusCode,
                    ["jobStatus"] = job.Status,
                }
            );
        }
    }

    [Fact]
    public async Task T02_06_SourceSection2Replacement_InvalidatesOnlySection2ClosureAndPaper()
    {
        await using var provider = CreateTestProvider();
        await EnsureCleanMigratedDatabaseAsync(provider);

        var owner = Guid.NewGuid();
        string runId;
        Guid jobId;

        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var (job, run) = await CreateJobAndRunAsync(db, owner, epoch: 1);
            jobId = job.Id;
            runId = run.RunId;

            var fixture = ReadingPaperTests.Paper();
            job.SectionsJson = JsonSerializer.Serialize(fixture, ReadingPaperRules.Json);
            job.CompletedSections = 3;
            await db.SaveChangesAsync();

            // Commit DAG:
            // Section 1: Source 1 -> Passage 1 -> Section 1
            // Section 2: Source 2 -> Passage 2 -> Section 2
            // Section 3: Source 3 -> Passage 3 -> Section 3
            // Paper: depends on Section 1, Section 2, Section 3
            var src1 = CreateSampleArtifact("art_source_1", ArtifactType.SourcePack, runId);
            var pas1 = CreateSampleArtifact("art_passage_1", ArtifactType.Passage, runId, parentRefs: [src1.ToRef()]);
            var sec1 = CreateSampleArtifact("art_section_1", ArtifactType.Section, runId, parentRefs: [pas1.ToRef()]);

            var src2 = CreateSampleArtifact("art_source_2", ArtifactType.SourcePack, runId);
            var pas2 = CreateSampleArtifact("art_passage_2", ArtifactType.Passage, runId, parentRefs: [src2.ToRef()]);
            var sec2 = CreateSampleArtifact("art_section_2", ArtifactType.Section, runId, parentRefs: [pas2.ToRef()]);

            var src3 = CreateSampleArtifact("art_source_3", ArtifactType.SourcePack, runId);
            var pas3 = CreateSampleArtifact("art_passage_3", ArtifactType.Passage, runId, parentRefs: [src3.ToRef()]);
            var sec3 = CreateSampleArtifact("art_section_3", ArtifactType.Section, runId, parentRefs: [pas3.ToRef()]);

            var paper = CreateSampleArtifact("art_paper", ArtifactType.ReadingPaper, runId, parentRefs: [sec1.ToRef(), sec2.ToRef(), sec3.ToRef()]);

            foreach (var art in new[] { src1, pas1, sec1, src2, pas2, sec2, src3, pas3, sec3, paper })
            {
                var opId = $"op_{art.ArtifactId}";
                var reqHash = $"hash_{art.ArtifactId}";
                await CheckpointService.GrantOperationAsync(db, new OperationGrantRequest(runId, 1, owner, opId, "GEN", reqHash, 500), CancellationToken.None);
                await CheckpointService.CommitCheckpointAsync(db, new CheckpointCommitRequest(runId, 1, owner, opId, reqHash, art), CancellationToken.None);
            }

            var initialHeads = await db.ReadingPaperArtifactHeads.CountAsync(h => h.RunId == runId);
            Assert.Equal(10, initialHeads);

            // Test replacement through ReadingPaperEndpoints.InvalidateChangedSourcesAsync
            // Replace Section 2 source with new content & different provider metadata
            var existingSources = JsonSerializer.Deserialize<List<ReadingSource>>(job.SourcesJson, ReadingPaperRules.Json)!;
            var modifiedSource2 = existingSources[1] with
            {
                Content = "Modified content for geothermal reservoir dynamics in new geological basin.",
                Metadata = new Dictionary<string, string> { ["provider"] = "groq" }
            };

            // Assert ComputeSourceHash divergence
            Assert.NotEqual(
                ReadingPaperEndpoints.ComputeSourceHash(existingSources[1]),
                ReadingPaperEndpoints.ComputeSourceHash(modifiedSource2)
            );

            var newSources = new List<ReadingSource> { existingSources[0], modifiedSource2, existingSources[2] };

            await ReadingPaperEndpoints.InvalidateChangedSourcesAsync(db, job, newSources, CancellationToken.None);
            await db.SaveChangesAsync();

            // Verify: Section 2 closure & Paper invalidated; Section 1 & Section 3 preserved in Heads
            var remainingHeads = await db.ReadingPaperArtifactHeads.Where(h => h.RunId == runId).Select(h => h.ArtifactId).ToListAsync();

            Assert.Contains("art_source_1", remainingHeads);
            Assert.Contains("art_passage_1", remainingHeads);
            Assert.Contains("art_section_1", remainingHeads);

            Assert.Contains("art_source_3", remainingHeads);
            Assert.Contains("art_passage_3", remainingHeads);
            Assert.Contains("art_section_3", remainingHeads);

            Assert.DoesNotContain("art_source_2", remainingHeads);
            Assert.DoesNotContain("art_passage_2", remainingHeads);
            Assert.DoesNotContain("art_section_2", remainingHeads);
            Assert.DoesNotContain("art_paper", remainingHeads);

            // Verify: SectionsJson preserved Section 1 and Section 3
            var remainingSections = JsonSerializer.Deserialize<List<ReadingGeneratedSection>>(job.SectionsJson, ReadingPaperRules.Json)!;
            Assert.Equal(2, remainingSections.Count);
            Assert.Equal(existingSources[0].Pmcid, remainingSections[0].Source.Pmcid);
            Assert.Equal(existingSources[2].Pmcid, remainingSections[1].Source.Pmcid);

            FaultTraceRecorder.RecordTrace(
                "T02-06",
                "Source replacement on section 2 with metadata & content change",
                "Upstream source modified (provider and content change detected by ComputeSourceHash)",
                "Transitive downstream closure calculation invalidates section 2 source, passage, questions, section, and paper aggregate. Section 1 and section 3 artifacts remain accepted in Heads and preserved in SectionsJson.",
                verified: true,
                new Dictionary<string, object>
                {
                    ["runId"] = runId,
                    ["remainingHeadsCount"] = remainingHeads.Count,
                    ["preservedSectionsCount"] = remainingSections.Count,
                }
            );
        }
    }

    [Fact]
    public async Task T02_07_CrashImmediatelyAfterFinalExamCommit_RetryYieldsIdenticalExamId()
    {
        await using var provider = CreateTestProvider();
        await EnsureCleanMigratedDatabaseAsync(provider);

        var owner = Guid.NewGuid();
        Guid jobId;
        string runId;

        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var (job, run) = await CreateJobAndRunAsync(db, owner, epoch: 1);
            jobId = job.Id;
            runId = run.RunId;

            var fixture = ReadingPaperTests.Paper();
            job.SectionsJson = JsonSerializer.Serialize(fixture, ReadingPaperRules.Json);
            job.CompletedSections = 3;
            await db.SaveChangesAsync();
            var (paperEnv, validEvaluations) = await SeedFullAcceptedPaperGraphAsync(db, run, fixture);

            var req = new BuildExamInternalRequest(runId, 1, owner, jobId, FinalEvaluations: validEvaluations);
            var res1 = await CheckpointService.BuildExamIdempotentAsync(db, req, CancellationToken.None);
            Assert.NotEqual(Guid.Empty, res1.ExamId);
            Assert.False(res1.IsExisting);

            // Retry after lost ACK
            var res2 = await CheckpointService.BuildExamIdempotentAsync(db, req, CancellationToken.None);
            Assert.Equal(res1.ExamId, res2.ExamId);
            Assert.Equal(res1.Slug, res2.Slug);
            Assert.True(res2.IsExisting);

            var examCount = await db.Exams.CountAsync(e => e.Slug == res1.Slug);
            Assert.Equal(1, examCount);

            FaultTraceRecorder.RecordTrace(
                "T02-07",
                "Crash immediately after final exam commit",
                "Network disconnect after final exam database transaction commits before client receives response",
                "Idempotent BuildExam returns existing ExamId with isExisting=True. Database contains exactly 1 exam with no duplicated sections or questions.",
                verified: true,
                new Dictionary<string, object>
                {
                    ["examId"] = res1.ExamId.ToString(),
                    ["slug"] = res1.Slug,
                    ["isExistingOnRetry"] = res2.IsExisting,
                    ["examCountInDb"] = examCount,
                }
            );
        }
    }

    [Fact]
    public async Task T02_07_Race_TakeoverDuringFinalization_FailsAtConditionalCommitFence()
    {
        await using var provider = CreateTestProvider();
        await EnsureCleanMigratedDatabaseAsync(provider);

        var workerA = Guid.NewGuid();
        var workerB = Guid.NewGuid();
        Guid jobId;
        string runId;

        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var (job, run) = await CreateJobAndRunAsync(db, workerA, epoch: 1);
            jobId = job.Id;
            runId = run.RunId;

            var fixture = ReadingPaperTests.Paper();
            job.SectionsJson = JsonSerializer.Serialize(fixture, ReadingPaperRules.Json);
            job.CompletedSections = 3;
            await db.SaveChangesAsync();
            var (paperEnv, validEvaluations) = await SeedFullAcceptedPaperGraphAsync(db, run, fixture);

            var req = new BuildExamInternalRequest(runId, 1, workerA, jobId, FinalEvaluations: validEvaluations);

            // Hook intercepts execution AFTER initial authority validation succeeds,
            // but BEFORE the in-transaction conditional lock executes!
            var ex = await Assert.ThrowsAsync<CheckpointValidationException>(() =>
                CheckpointService.BuildExamIdempotentAsync(db, req, CancellationToken.None, onBeforeTransaction: async () =>
                {
                    using var takeoverScope = provider.CreateScope();
                    var takeoverDb = takeoverScope.ServiceProvider.GetRequiredService<ExamDbContext>();
                    await takeoverDb.ReadingPaperJobs.Where(j => j.Id == jobId).ExecuteUpdateAsync(x => x
                        .SetProperty(j => j.Epoch, 2)
                        .SetProperty(j => j.LeaseOwner, workerB));
                    await takeoverDb.ReadingPaperRuns.Where(r => r.RunId == runId).ExecuteUpdateAsync(x => x
                        .SetProperty(r => r.Epoch, 2)
                        .SetProperty(r => r.LeaseOwner, workerB));
                }));

            Assert.Equal(409, ex.StatusCode);
            Assert.Contains("fencing violation", ex.Message);
            var takenOverJob = await db.ReadingPaperJobs.AsNoTracking().SingleAsync(j => j.Id == jobId);
            var takenOverRun = await db.ReadingPaperRuns.AsNoTracking().SingleAsync(r => r.RunId == runId);
            Assert.Equal(2, takenOverJob.Epoch);
            Assert.Equal(workerB, takenOverJob.LeaseOwner);
            Assert.Equal(2, takenOverRun.Epoch);
            Assert.Equal(workerB, takenOverRun.LeaseOwner);
            Assert.NotEqual("Completed", takenOverJob.Status);
            Assert.Equal(0, await db.Exams.CountAsync(e => e.Slug == $"reading-{jobId:N}"));
        }
    }

    [Fact]
    public async Task T02_08_TamperedContentHash_Or_IncompatibleSchema_FailsClosed()
    {
        await using var provider = CreateTestProvider();
        await EnsureCleanMigratedDatabaseAsync(provider);

        var owner = Guid.NewGuid();
        string runId;

        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var (_, run) = await CreateJobAndRunAsync(db, owner, epoch: 1);
            runId = run.RunId;

            var art = CreateSampleArtifact("art_tamper_test", ArtifactType.Passage, runId);
            var opReq = new OperationGrantRequest(runId, 1, owner, "op_tamper", "TEST", "hash_tamper", 1000);
            await CheckpointService.GrantOperationAsync(db, opReq, CancellationToken.None);
            await CheckpointService.CommitCheckpointAsync(db, new CheckpointCommitRequest(
                runId, 1, owner, "op_tamper", "hash_tamper", art
            ), CancellationToken.None);

            var storedArt = await db.ReadingPaperArtifacts.FirstAsync(a => a.RunId == runId && a.ArtifactId == art.ArtifactId);
            storedArt.ContentHash = "tampered_hash_0000000000000000000000000000000000000000000000000000000";
            await db.SaveChangesAsync();

            var ex = await Assert.ThrowsAsync<CheckpointValidationException>(() =>
                CheckpointService.ResumeStateAsync(db, runId, CancellationToken.None));

            Assert.Equal(409, ex.StatusCode);
            Assert.Contains("Tampered checkpoint detected", ex.Message);
        }

        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var run = await db.ReadingPaperRuns.FirstAsync(r => r.RunId == runId);
            run.EngineVersion = "1.0.0-legacy";
            await db.SaveChangesAsync();

            var res = await CheckpointService.ResumeStateAsync(db, runId, CancellationToken.None);
            Assert.False(res.IsCompatible);
            Assert.NotNull(res.IncompatibilityReason);

            FaultTraceRecorder.RecordTrace(
                "T02-08",
                "Tampered checkpoint hash or incompatible engine/schema/policy version",
                "Bit-rot or unauthorized DB alteration of stored contentHash; legacy engineVersion",
                "Tampered hash triggers HTTP 409 tamper detection; incompatible engine version fails closed with isCompatible=False and clear incompatibility reason.",
                verified: true,
                new Dictionary<string, object>
                {
                    ["runId"] = runId,
                    ["isCompatible"] = res.IsCompatible,
                    ["incompatibilityReason"] = res.IncompatibilityReason,
                }
            );
        }
    }

    [Fact]
    public async Task T02_09_Security_MissingOrInvalidInternalApiKey_RejectsWith401Or403()
    {
        Environment.SetEnvironmentVariable("JwtSettings__Issuer", "https://auth.langfens.local");
        Environment.SetEnvironmentVariable("JwtSettings__Audience", "langfens-api");
        Environment.SetEnvironmentVariable("JwtSettings__SignKey", "SuperSecretTestingKeyAtLeast32BytesLong!!");
        Environment.SetEnvironmentVariable("ConnectionStrings__exam-db", DefaultConn);
        Environment.SetEnvironmentVariable("EXAMSERVICE__INTERNAL__API__KEY", TestInternalApiKey);
        await using var provider = CreateTestProvider();
        await EnsureCleanMigratedDatabaseAsync(provider);
        var owner = Guid.NewGuid();
        string runId;

        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var (_, run) = await CreateJobAndRunAsync(db, owner, epoch: 1);
            runId = run.RunId;
        }

        // Test with real HTTP requests through ExamApiFactory / WebApplicationFactory
        await using var factory = new ExamApiFactory(DefaultConn);
        var client = factory.CreateClient();

        // 1. Missing header:
        var reqNoAuth = new HttpRequestMessage(HttpMethod.Post, "/api/internal/reading-paper/checkpoints/grant-operation")
        {
            Content = JsonContent.Create(new OperationGrantRequest(runId, 1, owner, "op_no_auth", "LLM", "hash_0", 100))
        };
        var respNoAuth = await client.SendAsync(reqNoAuth);
        Assert.Equal(HttpStatusCode.Unauthorized, respNoAuth.StatusCode);

        // 2. Invalid malicious header:
        var reqBadAuth = new HttpRequestMessage(HttpMethod.Post, "/api/internal/reading-paper/checkpoints/grant-operation")
        {
            Content = JsonContent.Create(new OperationGrantRequest(runId, 1, owner, "op_bad_auth", "LLM", "hash_0", 100))
        };
        reqBadAuth.Headers.Add("X-Internal-Service-Key", "malicious-attacker-key");
        var respBadAuth = await client.SendAsync(reqBadAuth);
        Assert.Equal(HttpStatusCode.Forbidden, respBadAuth.StatusCode);

        // 3. Valid key with non-existent run:
        var reqWrongRun = new HttpRequestMessage(HttpMethod.Post, "/api/internal/reading-paper/checkpoints/grant-operation")
        {
            Content = JsonContent.Create(new OperationGrantRequest("run_non_existent", 1, owner, "op_wrong_run", "LLM", "hash_0", 100))
        };
        reqWrongRun.Headers.Add("X-Internal-Service-Key", TestInternalApiKey);
        var respWrongRun = await client.SendAsync(reqWrongRun);
        Assert.Equal(HttpStatusCode.NotFound, respWrongRun.StatusCode);
        // 4. Valid key with stale epoch:
        var reqStaleEpoch = new HttpRequestMessage(HttpMethod.Post, "/api/internal/reading-paper/checkpoints/grant-operation")
        {
            Content = JsonContent.Create(new OperationGrantRequest(runId, 999, owner, "op_stale_epoch", "LLM", "hash_0", 100))
        };
        reqStaleEpoch.Headers.Add("X-Internal-Service-Key", TestInternalApiKey);
        var respStaleEpoch = await client.SendAsync(reqStaleEpoch);
        Assert.Equal(HttpStatusCode.Conflict, respStaleEpoch.StatusCode);
        // 5. Verify database remained completely unchanged after all 4 rejected requests:
        int opsAfter;
        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            opsAfter = await db.ReadingPaperOperations.CountAsync();
            Assert.Equal(0, opsAfter);
        }

        FaultTraceRecorder.RecordTrace(
            "T02-09",
            "Security authentication check on internal checkpoint endpoints",
            "Request without X-Internal-Service-Key or with malicious attacker key; stale grant",
            "Endpoint filter returns HTTP 401 Unauthorized or HTTP 403 Forbidden. Zero database mutation verified on PostgreSQL.",
            verified: true,
            new Dictionary<string, object>
            {
                ["runId"] = runId,
                ["noAuthStatus"] = (int)respNoAuth.StatusCode,
                ["badAuthStatus"] = (int)respBadAuth.StatusCode,
                ["wrongRunStatus"] = (int)respWrongRun.StatusCode,
                ["staleEpochStatus"] = (int)respStaleEpoch.StatusCode,
                ["dbOperationsCount"] = opsAfter,
            }
        );
    }

    [Fact]
    public async Task T02_Migration_AppFirstRollback_PreservesAdditiveData_And_RunsOldAppFlawlessly()
    {
        await using var provider = CreateTestProvider();
        await EnsureCleanMigratedDatabaseAsync(provider);

        var owner = Guid.NewGuid();
        string runId;
        string v2SnapshotBefore;

        // Persist V2 state before rolling application code back.
        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var (_, run) = await CreateJobAndRunAsync(db, owner, epoch: 1);
            runId = run.RunId;

            var artifact = CreateSampleArtifact("art_v2_persisted", ArtifactType.Section, runId);
            await CheckpointService.GrantOperationAsync(db, new OperationGrantRequest(runId, 1, owner, "op_v2_grant", "LLM", "hash_v2", 1000), CancellationToken.None);
            await CheckpointService.CommitCheckpointAsync(db, new CheckpointCommitRequest(
                runId, 1, owner, "op_v2_grant", "hash_v2", artifact,
                Events: [new DomainEvent("evt_v2_persisted", EventType.ARTIFACT_PRODUCED, runId, 1, 1, "evt_v2_persisted", DateTime.UtcNow, JsonSerializer.SerializeToElement(new { artifactId = artifact.ArtifactId }))]
            ), CancellationToken.None);

            db.ChangeTracker.Clear(); // Read the database-normalized timestamp precision for a stable baseline.
            v2SnapshotBefore = await SnapshotDurableRunStateAsync(db, runId);
        }

        // Run the old job/exam persistence shape with no V2 EF mappings on the database.
        var legacyOptions = new DbContextOptionsBuilder<LegacyReadingPaperContext>()
            .UseNpgsql(DefaultConn, npg => npg.ConfigureDataSource(dataSource => dataSource.EnableDynamicJson()))
            .Options;
        var fixture = ReadingPaperTests.Paper();
        var legacyJobId = Guid.NewGuid();
        Guid legacyExamId;
        await using (var legacyDb = new LegacyReadingPaperContext(legacyOptions))
        {
            var legacyJobModel = legacyDb.Model.FindEntityType(typeof(LegacyReadingPaperJob))!;
            Assert.Null(legacyJobModel.FindProperty("Epoch"));
            Assert.Null(legacyJobModel.FindProperty("CancelVersion"));
            Assert.Equal(1, legacyDb.Model.GetEntityTypes().Count(entity =>
                entity.GetTableName()?.StartsWith("reading_paper_", StringComparison.Ordinal) == true));

            var legacyJob = new LegacyReadingPaperJob
            {
                Id = legacyJobId,
                Topic = "Legacy App on Additive Database",
                Status = "Pending",
                SourcesJson = JsonSerializer.Serialize(fixture.Select(section => section.Source).ToArray(), ReadingPaperRules.Json),
                SectionsJson = "[]",
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };
            legacyDb.Jobs.Add(legacyJob);
            await legacyDb.SaveChangesAsync();

            legacyDb.ChangeTracker.Clear();
            var loaded = await legacyDb.Jobs.SingleAsync(job => job.Id == legacyJobId);
            Assert.Equal("Pending", loaded.Status);
            Assert.Equal(0, loaded.CompletedSections);

            // The pre-V2 worker stores completed sections, builds the unchanged exam graph,
            // then persists the exam and legacy job link through its legacy-only model.
            loaded.SectionsJson = JsonSerializer.Serialize(fixture, ReadingPaperRules.Json);
            var loadedSections = JsonSerializer.Deserialize<List<ReadingGeneratedSection>>(
                loaded.SectionsJson, ReadingPaperRules.Json)
                ?? throw new InvalidOperationException("Legacy SectionsJson did not deserialize.");
            loaded.CompletedSections = loadedSections.Count;
            var exam = ReadingPaperWorker.BuildExam(
                new ReadingPaperJob { Id = loaded.Id, Topic = loaded.Topic }, loadedSections);
            legacyDb.Exams.Add(exam);
            loaded.ExamId = exam.Id;
            loaded.Status = "Completed";
            loaded.UpdatedAt = DateTime.UtcNow;
            await legacyDb.SaveChangesAsync();
            legacyExamId = exam.Id;

            legacyDb.ChangeTracker.Clear();
            var persistedJob = await legacyDb.Jobs.AsNoTracking().SingleAsync(job => job.Id == legacyJobId);
            Assert.Equal("Completed", persistedJob.Status);
            Assert.Equal(fixture.Count, persistedJob.CompletedSections);
            Assert.Equal(legacyExamId, persistedJob.ExamId);
            var persistedSections = JsonSerializer.Deserialize<List<ReadingGeneratedSection>>(
                persistedJob.SectionsJson, ReadingPaperRules.Json)
                ?? throw new InvalidOperationException("Legacy SectionsJson did not survive app rollback.");
            Assert.Equal(fixture.Select(section => section.Title), persistedSections.Select(section => section.Title));

            var persistedExam = await legacyDb.Exams.AsNoTracking()
                .Include(item => item.Sections).ThenInclude(section => section.Questions).ThenInclude(question => question.Options)
                .Include(item => item.Sections).ThenInclude(section => section.QuestionGroups).ThenInclude(group => group.Questions)
                .SingleAsync(item => item.Id == legacyExamId);
            Assert.Equal($"reading-{legacyJobId:N}", persistedExam.Slug);
            Assert.Equal("IELTS Academic Reading: Legacy App on Additive Database", persistedExam.Title);
            Assert.Equal("IELTS", persistedExam.Category);
            Assert.Equal("B2", persistedExam.Level);
            Assert.Equal("DRAFT", persistedExam.Status);
            Assert.Equal(60, persistedExam.DurationMin);
            Assert.Equal(fixture.Count, persistedExam.Sections.Count);
            Assert.Equal(fixture.Sum(section => section.Groups.Count), persistedExam.Sections.Sum(section => section.QuestionGroups.Count));
            Assert.Equal(fixture.Sum(section => section.Groups.Sum(group => group.Questions.Count)), persistedExam.Sections.Sum(section => section.Questions.Count));
            Assert.Equal(fixture.Sum(section => section.Groups.Sum(group => group.Questions.Sum(question => question.Options.Count))),
                persistedExam.Sections.Sum(section => section.Questions.Sum(question => question.Options.Count)));
            Assert.All(persistedExam.Sections, section => Assert.NotEmpty(section.Questions));

            foreach (var (generated, index) in fixture.Select((section, index) => (section, index)))
            {
                var persisted = persistedExam.Sections.Single(section => section.Idx == index + 1);
                Assert.Equal(generated.Title, persisted.Title);
                Assert.Equal(generated.Source.Pmcid, persisted.SourcePmcid);
                Assert.Equal(generated.Source.Title, persisted.SourceTitle);
                Assert.Equal(generated.Source.Url, persisted.SourceUrl);
                Assert.Contains(generated.Passage, persisted.PassageMd);
            }
        }

        // Verify old-app changes while every scalar column in seeded V2 records stays unchanged.
        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var legacyAfterUpdate = await db.ReadingPaperJobs.AsNoTracking().SingleAsync(job => job.Id == legacyJobId);
            Assert.Equal(1, legacyAfterUpdate.Epoch);
            Assert.Equal(fixture.Count, legacyAfterUpdate.CompletedSections);
            Assert.Equal("Completed", legacyAfterUpdate.Status);
            Assert.Equal(legacyExamId, legacyAfterUpdate.ExamId);

            Assert.Equal(1, await db.ReadingPaperArtifacts.CountAsync(row => row.RunId == runId));
            Assert.Equal(1, await db.ReadingPaperArtifactHeads.CountAsync(row => row.RunId == runId));
            Assert.Equal(1, await db.ReadingPaperOperations.CountAsync(row => row.RunId == runId));
            Assert.Equal(1, await db.ReadingPaperEventOutbox.CountAsync(row => row.RunId == runId));
            Assert.Equal(v2SnapshotBefore, await SnapshotDurableRunStateAsync(db, runId));

            var conn = db.Database.GetDbConnection();
            await db.Database.OpenConnectionAsync();
            try
            {
                await using var command = conn.CreateCommand();
                command.CommandText = "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name LIKE 'reading_paper_%';";
                await using var reader = await command.ExecuteReaderAsync();
                var tables = new HashSet<string>(StringComparer.Ordinal);
                while (await reader.ReadAsync())
                    tables.Add(reader.GetString(0));

                foreach (var table in new[]
                {
                    "reading_paper_jobs", "reading_paper_runs", "reading_paper_artifacts",
                    "reading_paper_artifact_heads", "reading_paper_artifact_dependencies",
                    "reading_paper_evaluations", "reading_paper_issues", "reading_paper_decisions",
                    "reading_paper_operations", "reading_paper_event_outbox"
                })
                    Assert.Contains(table, tables);
            }
            finally
            {
                await db.Database.CloseConnectionAsync();
            }
        }
    }

    [Fact]
    public async Task T06_ParentUpdatedDuringEvaluation_FailsCommitWith409()
    {
        await using var provider = CreateTestProvider();
        await EnsureCleanMigratedDatabaseAsync(provider);

        var owner = Guid.NewGuid();
        string runId;

        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var (_, run) = await CreateJobAndRunAsync(db, owner, epoch: 1);
            runId = run.RunId;

            // 1. Commit parent artifact: passage v1
            using var p1 = JsonDocument.Parse("""{"text":"passage v1"}""");
            var h1 = ArtifactEnvelope.ComputeContentHash(p1.RootElement, Array.Empty<ArtifactRef>());
            var sp1Ref = new ArtifactRef("passage_01", ArtifactType.Passage, 1, h1);
            var env1 = new ArtifactEnvelope("passage_01", ArtifactType.Passage, 1, runId, 1, "2.0.0", h1, DateTime.UtcNow, "2.0.0", p1.RootElement.Clone(), Array.Empty<ArtifactRef>());
            await CheckpointService.GrantOperationAsync(db, new OperationGrantRequest(runId, 1, owner, "op_grant_p1", "GENERATE", "hash_p1", 1000), CancellationToken.None);
            await CheckpointService.CommitCheckpointAsync(db, new CheckpointCommitRequest(runId, 1, owner, "op_grant_p1", "hash_p1", env1), CancellationToken.None);

            // 2. Child question is evaluated with parent passage_01 v1
            using var qDoc = JsonDocument.Parse("""{"text":"question 1"}""");
            var qHash = ArtifactEnvelope.ComputeContentHash(qDoc.RootElement, new[] { sp1Ref });
            var qEnv = new ArtifactEnvelope("q_01", ArtifactType.Question, 1, runId, 2, "2.0.0", qHash, DateTime.UtcNow, "2.0.0", qDoc.RootElement.Clone(), new[] { sp1Ref });
            await CheckpointService.GrantOperationAsync(db, new OperationGrantRequest(runId, 1, owner, "op_grant_q1", "GENERATE", "hash_q1", 1000), CancellationToken.None);

            // 3. Concurrently, passage_01 is updated to v2 in accepted heads!
            using var p2 = JsonDocument.Parse("""{"text":"passage v2 updated"}""");
            var h2 = ArtifactEnvelope.ComputeContentHash(p2.RootElement, Array.Empty<ArtifactRef>());
            var env2 = new ArtifactEnvelope("passage_01", ArtifactType.Passage, 2, runId, 3, "2.0.0", h2, DateTime.UtcNow, "2.0.0", p2.RootElement.Clone(), Array.Empty<ArtifactRef>());
            await CheckpointService.GrantOperationAsync(db, new OperationGrantRequest(runId, 1, owner, "op_grant_p2", "REGENERATE", "hash_p2", 1000), CancellationToken.None);
            await CheckpointService.CommitCheckpointAsync(db, new CheckpointCommitRequest(runId, 1, owner, "op_grant_p2", "hash_p2", env2, ExpectedHeadVersion: 1), CancellationToken.None);

            // 4. Now child question tries to commit with stale parent v1 -> Must throw CheckpointValidationException 409!
            var ex = await Assert.ThrowsAsync<CheckpointValidationException>(() =>
                CheckpointService.CommitCheckpointAsync(db, new CheckpointCommitRequest(runId, 1, owner, "op_grant_q1", "hash_q1", qEnv), CancellationToken.None));

            Assert.Equal(409, ex.StatusCode);
            Assert.Contains("Stale parent dependency", ex.Message);

            // Verify child question was NOT accepted as head
            var heads = await db.ReadingPaperArtifactHeads.Where(h => h.RunId == runId).ToListAsync();
            Assert.DoesNotContain(heads, h => h.ArtifactId == "q_01");
        }
    }
}
