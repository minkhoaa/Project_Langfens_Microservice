using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using exam_service.Domains.Entities;
using exam_service.Features.ReadingPaper;
using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging.Abstractions;
using Npgsql;
using Shared.ExamDto.Contracts.Exam.Enums;
using exam_service.Features.ReadingPaper.Contracts;
using Xunit;
namespace exam_service.Tests;
[Collection("DatabaseTests")]
public class ReadingPaperWorkerCrashSection2Tests
{
    private const string DefaultConn = "Host=localhost;Port=5433;Database=exam_test_crash_t004;Username=exam;Password=exam";

    private sealed class SectionCrashHandler(List<ReadingGeneratedSection> sections, string? connectionString = null) : HttpMessageHandler
    {
        public Dictionary<int, int> Calls { get; } = new() { [1] = 0, [2] = 0, [3] = 0 };
        public bool FailOnSection3 { get; set; } = true;

        protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken ct)
        {
            var uri = request.RequestUri?.ToString() ?? "";
            var body = request.Content?.ReadAsStringAsync(ct).GetAwaiter().GetResult() ?? "";
            using var doc = JsonDocument.Parse(string.IsNullOrWhiteSpace(body) ? "{}" : body);

            if (doc.RootElement.TryGetProperty("index", out var idxProp))
            {
                var index = idxProp.GetInt32();
                Calls[index]++;

                if (index == 3 && FailOnSection3)
                {
                    return Task.FromResult(new HttpResponseMessage(HttpStatusCode.BadGateway)
                    {
                        Content = new StringContent("{\"error\":\"Simulated crash after section 2 during section 3\"}", Encoding.UTF8, "application/json")
                    });
                }

                var section = sections[index - 1];
                return Task.FromResult(new HttpResponseMessage(HttpStatusCode.OK)
                {
                    Content = new StringContent(JsonSerializer.Serialize(section, ReadingPaperRules.Json), Encoding.UTF8, "application/json")
                });
            }

            if (uri.Contains("paper-v2"))
            {
                var runId = doc.RootElement.TryGetProperty("runId", out var rP) ? rP.GetString() ?? "" : "";
                var epoch = doc.RootElement.TryGetProperty("epoch", out var eP) ? eP.GetInt32() : 1;
                var leaseOwner = doc.RootElement.TryGetProperty("leaseOwner", out var lP) && lP.TryGetGuid(out var lGuid) ? lGuid : Guid.Empty;

                var conn = connectionString ?? Environment.GetEnvironmentVariable("READING_TEST_POSTGRES") ?? DefaultConn;
                var options = new DbContextOptionsBuilder<ExamDbContext>()
                    .UseNpgsql(conn, npg => {
                        npg.ConfigureDataSource(dataSource => dataSource.EnableDynamicJson());
                        npg.EnableRetryOnFailure();
                    }).Options;
                using var db = new ExamDbContext(options);

                var allHeads = db.ReadingPaperArtifactHeads.AsNoTracking().Where(h => h.RunId == runId).ToDictionary(h => h.ArtifactId);
                var bpId = $"art_blueprint_{runId[..Math.Min(8, runId.Length)]}";
                var bpHead = allHeads.TryGetValue(bpId, out var bph) ? bph : allHeads.Values.First(h => h.ArtifactId.StartsWith("art_blueprint_"));
                var bpRef = new ArtifactRef(bpHead.ArtifactId, ArtifactType.ExamBlueprint, bpHead.AcceptedVersion, bpHead.AcceptedHash);

                var s1Head = allHeads["art_section_1"];
                var s2Head = allHeads["art_section_2"];
                var s3Head = allHeads["art_section_3"];
                var secRefs = new List<ArtifactRef>
                {
                    new(s1Head.ArtifactId, ArtifactType.Section, s1Head.AcceptedVersion, s1Head.AcceptedHash),
                    new(s2Head.ArtifactId, ArtifactType.Section, s2Head.AcceptedVersion, s2Head.AcceptedHash),
                    new(s3Head.ArtifactId, ArtifactType.Section, s3Head.AcceptedVersion, s3Head.AcceptedHash),
                };

                var pRefs = new List<ArtifactRef>();
                for (int i = 1; i <= 3; i++)
                {
                    var pHead = allHeads.TryGetValue($"art_passage_s{i}", out var ph) ? ph : allHeads[$"art_passage_{i}"];
                    pRefs.Add(new ArtifactRef(pHead.ArtifactId, ArtifactType.Passage, pHead.AcceptedVersion, pHead.AcceptedHash));
                }

                var qRefs = new List<ArtifactRef>();
                for (int i = 1; i <= 40; i++)
                {
                    var qHead = allHeads[$"art_q_{i}"];
                    qRefs.Add(new ArtifactRef(qHead.ArtifactId, ArtifactType.Question, qHead.AcceptedVersion, qHead.AcceptedHash));
                }

                var pParents = new List<ArtifactRef> { bpRef }.Concat(secRefs).Concat(pRefs).Concat(qRefs).ToList();

                var secArtifacts = db.ReadingPaperArtifacts.AsNoTracking()
                    .Where(a => a.RunId == runId && a.ArtifactType == "Section")
                    .OrderBy(a => a.ArtifactId)
                    .ToList();
                var secPayloads = secArtifacts.Select(a => JsonDocument.Parse(a.PayloadJson).RootElement.Clone()).ToList();

                var paperId = $"art_paper_{runId[..Math.Min(8, runId.Length)]}";
                var payload = new
                {
                    paperId,
                    runId,
                    title = "Marine Ecosystem Dynamics",
                    totalQuestions = 40,
                    blueprintRef = bpRef,
                    sectionRefs = secRefs,
                    passageRefs = pRefs,
                    questionRefs = qRefs,
                    sections = secPayloads
                };
                var pDoc = JsonDocument.Parse(JsonSerializer.Serialize(payload, ReadingPaperRules.Json));
                var pHash = ArtifactEnvelope.ComputeContentHash(pDoc.RootElement, pParents);
                var pEnv = new ArtifactEnvelope(paperId, ArtifactType.ReadingPaper, 1, runId, null, "2.0.0", pHash, DateTime.UtcNow, "2.0.0", pDoc.RootElement.Clone(), pParents);

                var existingPaper = db.ReadingPaperArtifacts.FirstOrDefault(a => a.RunId == runId && a.ArtifactId == paperId);
                if (existingPaper == null)
                {
                    db.ReadingPaperArtifacts.Add(new ReadingPaperArtifact
                    {
                        Id = Guid.NewGuid(),
                        RunId = runId,
                        ArtifactId = paperId,
                        ArtifactType = ArtifactType.ReadingPaper.ToString(),
                        Version = 1,
                        ContentHash = pHash,
                        PayloadJson = pDoc.RootElement.GetRawText(),
                        ParentRefsJson = JsonSerializer.Serialize(pParents, LoopEngineJson.Options),
                        EnvelopeJson = JsonSerializer.Serialize(pEnv, LoopEngineJson.Options),
                        CreatedAt = pEnv.CreatedAt
                    });
                }
                var existingHead = db.ReadingPaperArtifactHeads.FirstOrDefault(h => h.RunId == runId && h.ArtifactId == paperId);
                if (existingHead == null)
                {
                    db.ReadingPaperArtifactHeads.Add(new ReadingPaperArtifactHead
                    {
                        Id = Guid.NewGuid(),
                        RunId = runId,
                        ArtifactId = paperId,
                        AcceptedVersion = 1,
                        AcceptedHash = pHash,
                        UpdatedAt = pEnv.CreatedAt
                    });
                }
                db.SaveChanges();
                return Task.FromResult(new HttpResponseMessage(HttpStatusCode.OK)
                {
                    Content = new StringContent(JsonSerializer.Serialize(pEnv, LoopEngineJson.Options), Encoding.UTF8, "application/json")
                });
            }

            if (uri.Contains("paper-evaluate"))
            {
                var paperEnvObj = JsonSerializer.Deserialize<ArtifactEnvelope>(doc.RootElement.GetProperty("paperEnvelope").GetRawText(), LoopEngineJson.Options)!;
                var targetRef = paperEnvObj.ToRef();
                var inputDeps = paperEnvObj.ParentRefs;

                var evals = ReadingPaperFinalSnapshot.RequiredEvaluators.Select(kv => new EvaluationResult(
                    EvaluationId: $"eval_{kv.Key}_{Guid.NewGuid():N}"[..24],
                    EvaluatorId: kv.Key,
                    EvaluatorVersion: kv.Value,
                    TargetRef: targetRef,
                    Status: EvaluationStatus.PASS,
                    Issues: new List<Issue>(),
                    Score: 1.0,
                    InputDependencyRefs: inputDeps,
                    Provider: "test-provider",
                    Model: "test-model",
                    PromptVersion: "1.0.0",
                    ElapsedMs: 100.0,
                    Usage: new UsageMetrics(100, 50, 150, 0.001),
                    EvaluatedAt: DateTime.UtcNow
                )).ToList();

                var conn = connectionString ?? Environment.GetEnvironmentVariable("READING_TEST_POSTGRES") ?? DefaultConn;
                var options = new DbContextOptionsBuilder<ExamDbContext>()
                    .UseNpgsql(conn, npg => {
                        npg.ConfigureDataSource(dataSource => dataSource.EnableDynamicJson());
                        npg.EnableRetryOnFailure();
                    }).Options;
                using var db = new ExamDbContext(options);

                var runId = doc.RootElement.TryGetProperty("runId", out var rP) ? rP.GetString() ?? "" : "";
                foreach (var eval in evals)
                {
                    if (!db.ReadingPaperEvaluations.Any(e => e.RunId == runId && e.EvaluationId == eval.EvaluationId))
                    {
                        db.ReadingPaperEvaluations.Add(new ReadingPaperEvaluation
                        {
                            Id = Guid.NewGuid(),
                            RunId = runId,
                            EvaluationId = eval.EvaluationId,
                            EvaluatorId = eval.EvaluatorId,
                            EvaluatorVersion = eval.EvaluatorVersion,
                            TargetArtifactId = eval.TargetRef.ArtifactId,
                            TargetVersion = eval.TargetRef.Version,
                            TargetContentHash = eval.TargetRef.ContentHash,
                            Status = eval.Status.ToString(),
                            IsPass = eval.Status == EvaluationStatus.PASS,
                            PayloadJson = JsonSerializer.Serialize(eval, LoopEngineJson.Options),
                            CreatedAt = eval.EvaluatedAt
                        });
                    }
                }
                db.SaveChanges();

                return Task.FromResult(new HttpResponseMessage(HttpStatusCode.OK)
                {
                    Content = new StringContent(JsonSerializer.Serialize(evals, LoopEngineJson.Options), Encoding.UTF8, "application/json")
                });
            }

            return Task.FromResult(new HttpResponseMessage(HttpStatusCode.OK)
            {
                Content = new StringContent("{}", Encoding.UTF8, "application/json")
            });
        }
    }
    [Fact]
    public async Task WorkerCrashAfterSection2_PreservesCheckpoints1And2_AndRetryOnlyExecutesSection3()
    {
        var connection = Environment.GetEnvironmentVariable("READING_TEST_POSTGRES") ?? DefaultConn;

        // Reset isolated schema
        await using (var conn = new NpgsqlConnection(connection))
        {
            await conn.OpenAsync();
            await using var cmd = new NpgsqlCommand("DROP SCHEMA IF EXISTS public CASCADE; CREATE SCHEMA public;", conn);
            await cmd.ExecuteNonQueryAsync();
        }

        var fixture = ReadingPaperTests.Paper();
        var handler = new SectionCrashHandler(fixture, connection);

        var services = new ServiceCollection();
        services.AddDbContext<ExamDbContext>(options => options.UseNpgsql(connection, npg =>
        {
            npg.ConfigureDataSource(dataSource => dataSource.EnableDynamicJson());
            npg.EnableRetryOnFailure();
        }));
        services.AddHttpClient<ReadingPaperAiClient>(client =>
        {
            client.BaseAddress = new Uri("http://fake-ai/");
            client.Timeout = TimeSpan.FromSeconds(10);
        }).ConfigurePrimaryHttpMessageHandler(() => handler);

        await using var provider = services.BuildServiceProvider();

        // Apply migrations
        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            await db.Database.MigrateAsync();
        }

        // Create 3-passage job
        Guid jobId;
        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var job = new ReadingPaperJob
            {
                Topic = "Marine Ecosystem Dynamics",
                SourcesJson = JsonSerializer.Serialize(fixture.Select(x => x.Source).ToList(), ReadingPaperRules.Json)
            };
            db.ReadingPaperJobs.Add(job);
            await db.SaveChangesAsync();
            jobId = job.Id;
        }

        var worker = new ReadingPaperWorker(
            provider.GetRequiredService<IServiceScopeFactory>(),
            NullLogger<ReadingPaperWorker>.Instance,
            R03CapsProfileTests.ApprovedFromDeployEnvFile()
        );

        await worker.StartAsync(CancellationToken.None);
        try
        {
            // 1. Wait for worker to encounter crash on section 3
            await WaitForStatus(provider, jobId, "Failed");

            // 2. Verify Checkpoints: Section 1 & 2 MUST be preserved!
            using (var scope = provider.CreateScope())
            {
                var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
                var job = await db.ReadingPaperJobs.FirstAsync(x => x.Id == jobId);

                Assert.Equal(2, job.CompletedSections);
                Assert.Equal("Failed", job.Status);
                Assert.NotNull(job.Error);

                var savedSections = JsonSerializer.Deserialize<List<ReadingGeneratedSection>>(job.SectionsJson, ReadingPaperRules.Json);
                Assert.NotNull(savedSections);
                Assert.Equal(2, savedSections.Count);
                Assert.Equal("Passage 1", savedSections[0].Title);
                Assert.Equal("Passage 2", savedSections[1].Title);

                Assert.Equal(0, await db.Exams.CountAsync());

                // Assert calls so far: Section 1 (1 call), Section 2 (1 call), Section 3 (1 call which failed)
                Assert.Equal(1, handler.Calls[1]);
                Assert.Equal(1, handler.Calls[2]);
                Assert.Equal(1, handler.Calls[3]);

                // 3. Admin requests Retry
                handler.FailOnSection3 = false;
                job.Status = "Pending";
                job.Error = null;
                job.LeaseUntil = null;
                job.LeaseOwner = null;
                await db.SaveChangesAsync();
            }

            // 4. Wait for worker to resume and complete
            await WaitForStatus(provider, jobId, "Completed");

            // 5. Verify that ONLY Section 3 was executed during retry!
            using (var scope = provider.CreateScope())
            {
                var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
                var job = await db.ReadingPaperJobs.FirstAsync(x => x.Id == jobId);

                Assert.Equal(3, job.CompletedSections);
                Assert.Equal("Completed", job.Status);
                Assert.Null(job.Error);
                Assert.NotNull(job.ExamId);

                // Invariant: Calls for section 1 and 2 must STILL be exactly 1!
                Assert.Equal(1, handler.Calls[1]);
                Assert.Equal(1, handler.Calls[2]);
                // Calls for section 3 is now 2 (1 failed + 1 successful)
                Assert.Equal(2, handler.Calls[3]);

                // Verify Exam in DB
                var exam = await db.Exams.Include(e => e.Sections)
                    .ThenInclude(s => s.Questions)
                    .SingleAsync(e => e.Id == job.ExamId);

                Assert.Equal(ExamStatus.Draft, exam.Status);
                Assert.Equal(3, exam.Sections.Count);
                Assert.Equal(40, exam.Sections.Sum(s => s.Questions.Count));
            }
        }
        finally
        {
            await worker.StopAsync(CancellationToken.None);
        }
    }

    public sealed record QuestionCallRecord(
        string RunId,
        int Epoch,
        int SectionIndex,
        string PassageArtifactId,
        string PassageHash,
        string BlueprintArtifactId,
        string BlueprintHash,
        string RequestHash,
        string RawBody,
        List<int> RequestedSlots
    );

    private sealed class V2QuestionConsumerHandler(string? connectionString = null) : HttpMessageHandler
    {
        public int QuestionCalls { get; private set; }
        public List<string> RequestedPassageRefs { get; } = [];
        public List<int> RequestedSlotNumbers { get; } = [];
        public List<QuestionCallRecord> QuestionCallRecords { get; } = [];
        public bool SeedPartialGroupOnSection1 { get; set; } = false;
        public bool FailQuestionsOnFirstAttempt { get; set; } = false;

        protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken ct)
        {
            var uri = request.RequestUri?.ToString() ?? "";
            var body = request.Content?.ReadAsStringAsync(ct).GetAwaiter().GetResult() ?? "";

            if (uri.Contains("questions"))
            {
                QuestionCalls++;
                if (FailQuestionsOnFirstAttempt && QuestionCalls == 1)
                {
                    return Task.FromResult(new HttpResponseMessage(HttpStatusCode.BadGateway)
                    {
                        Content = new StringContent("{\"error\":\"Simulated network failure during question candidate generation\"}", Encoding.UTF8, "application/json")
                    });
                }
                using var doc = JsonDocument.Parse(body);
                var runId = doc.RootElement.TryGetProperty("runId", out var rP) ? rP.GetString() ?? "" : "";
                var epoch = doc.RootElement.TryGetProperty("epoch", out var eP) ? eP.GetInt32() : 1;
                var secIdx = doc.RootElement.TryGetProperty("sectionIndex", out var secP) ? secP.GetInt32() : 1;

                var pArtId = "";
                var pHash = "";
                if (doc.RootElement.TryGetProperty("passageRef", out var pRef))
                {
                    pArtId = pRef.TryGetProperty("artifactId", out var aP) ? aP.GetString() ?? "" : "";
                    pHash = pRef.TryGetProperty("contentHash", out var chP) ? chP.GetString() ?? "" : (pRef.TryGetProperty("acceptedHash", out var ahP) ? ahP.GetString() ?? "" : "");
                    RequestedPassageRefs.Add(pArtId);
                }

                var bpArtId = "";
                var bpHash = "";
                if (doc.RootElement.TryGetProperty("blueprintRef", out var bpRef))
                {
                    bpArtId = bpRef.TryGetProperty("artifactId", out var baP) ? baP.GetString() ?? "" : "";
                    bpHash = bpRef.TryGetProperty("contentHash", out var bchP) ? bchP.GetString() ?? "" : (bpRef.TryGetProperty("acceptedHash", out var bahP) ? bahP.GetString() ?? "" : "");
                }

                var requestedSlots = new List<int>();
                if (doc.RootElement.TryGetProperty("slots", out var slotsEl) && slotsEl.ValueKind == JsonValueKind.Array)
                {
                    foreach (var s in slotsEl.EnumerateArray())
                    {
                        if (s.TryGetProperty("number", out var n))
                        {
                            var numVal = n.GetInt32();
                            RequestedSlotNumbers.Add(numVal);
                            requestedSlots.Add(numVal);
                        }
                    }
                }

                var reqHash = Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(body)));
                QuestionCallRecords.Add(new QuestionCallRecord(runId, epoch, secIdx, pArtId, pHash, bpArtId, bpHash, reqHash, body, requestedSlots));

                if (secIdx == 3)
                {
                    // Section 3: 7 YNNG (27..33), 7 ShortAnswer (34..40)
                    var ynngOptions = new[] { "YES", "NO", "NOT GIVEN" };
                    var s3Quote = "Smart meters deployed in low-voltage distribution networks operate under harsh conditions.";
                    var s3Ans = "harsh conditions";
                    var qDict = new Dictionary<string, object>();
                    for (var n = 27; n <= 33; n++)
                    {
                        var ans = n % 3 == 0 ? "YES" : n % 3 == 1 ? "NO" : "NOT GIVEN";
                        qDict[n.ToString()] = new { questionNumber = n, questionType = "YesNoNotGiven", prompt = $"Do smart meter conditions in grid district [{n}] affect measurement reliability?", answer = ans, options = ynngOptions, evidenceQuote = s3Quote, explanation = "Smart meters deployed in low-voltage distribution networks operate under harsh conditions." };
                    }
                    for (var n = 34; n <= 40; n++)
                    {
                        qDict[n.ToString()] = new { questionNumber = n, questionType = "ShortAnswer", prompt = $"Under what conditions do low-voltage smart meters operate in district [{n}]?", answer = s3Ans, evidenceQuote = s3Quote, explanation = "Smart meters deployed in low-voltage distribution networks operate under harsh conditions." };
                    }
                    var s3Res = new ReadingGeneratedQuestionsResult("COMPLETED", 14, 0, 14, qDict);
                    return Task.FromResult(new HttpResponseMessage(HttpStatusCode.OK)
                    {
                        Content = new StringContent(JsonSerializer.Serialize(s3Res, ReadingPaperRules.Json), Encoding.UTF8, "application/json")
                    });
                }

                if (secIdx == 2)
                {
                    // Section 2: 6 MCQ (14..19), 7 SummaryCompletion (20..26)
                    var mcqOpts = new[] { "A. First choice", "B. Second choice", "C. Third choice", "D. Fourth choice" };
                    var s2Quote = "Quantum processor executes syndrome measurements for logical qubits.";
                    var qDict = new Dictionary<string, object>();
                    for (var n = 14; n <= 19; n++)
                    {
                        qDict[n.ToString()] = new { questionNumber = n, questionType = "MultipleChoiceSingle", prompt = $"Which architecture applies to physical qubit [{n}]?", answer = "A. First choice", options = mcqOpts, evidenceQuote = s2Quote, explanation = "Quantum processor executes syndrome measurements for logical qubits." };
                    }
                    for (var n = 20; n <= 26; n++)
                    {
                        qDict[n.ToString()] = new { questionNumber = n, questionType = "SummaryCompletion", prompt = $"Syndrome measurements evaluate [{n}].", answer = "logical qubits", evidenceQuote = s2Quote, explanation = "Quantum processor executes syndrome measurements for logical qubits." };
                    }
                    var s2Res = new ReadingGeneratedQuestionsResult("COMPLETED", 13, 0, 13, qDict);
                    return Task.FromResult(new HttpResponseMessage(HttpStatusCode.OK)
                    {
                        Content = new StringContent(JsonSerializer.Serialize(s2Res, ReadingPaperRules.Json), Encoding.UTF8, "application/json")
                    });
                }

                // Section 1: 7 TFNG (1..7), 6 SentenceCompletion (8..13)
                var quoteStr = "Academic research discusses marine ecosystem and ocean biodiversity.";
                var tfngOptions = new[] { "TRUE", "FALSE", "NOT GIVEN" };
                var questionsDict = new Dictionary<string, object>();

                var targetSlots = requestedSlots.Count > 0 ? requestedSlots : Enumerable.Range(1, 13).ToList();
                foreach (var qNum in targetSlots)
                {
                    if (qNum <= 7)
                    {
                        var ans = qNum % 3 == 1 ? "TRUE" : qNum % 3 == 2 ? "FALSE" : "NOT GIVEN";
                        questionsDict[qNum.ToString()] = new { questionNumber = qNum, questionType = "TrueFalseNotGiven", prompt = $"Statement {qNum} discusses marine biodiversity.", answer = ans, options = tfngOptions, evidenceQuote = quoteStr, explanation = "Detailed research confirms that marine biodiversity is actively studied in the ocean." };
                    }
                    else
                    {
                        questionsDict[qNum.ToString()] = new { questionNumber = qNum, questionType = "SentenceCompletion", prompt = $"Academic research analyzes marine [{qNum}].", answer = "ocean biodiversity", evidenceQuote = quoteStr, explanation = "The passage explicitly notes that research focuses on ocean biodiversity in ecosystems." };
                    }
                }

                var res = new ReadingGeneratedQuestionsResult("COMPLETED", 13, 13 - questionsDict.Count, questionsDict.Count, questionsDict);
                return Task.FromResult(new HttpResponseMessage(HttpStatusCode.OK)
                {
                    Content = new StringContent(JsonSerializer.Serialize(res, ReadingPaperRules.Json), Encoding.UTF8, "application/json")
                });
            }

            // Section generation
            using var sDoc = JsonDocument.Parse(string.IsNullOrWhiteSpace(body) ? "{}" : body);

            if (uri.Contains("paper-v2"))
            {
                var pRunId = sDoc.RootElement.TryGetProperty("runId", out var rP) ? rP.GetString() ?? "" : "";
                var epoch = sDoc.RootElement.TryGetProperty("epoch", out var eP) ? eP.GetInt32() : 1;
                var leaseOwner = sDoc.RootElement.TryGetProperty("leaseOwner", out var lP) && lP.TryGetGuid(out var lGuid) ? lGuid : Guid.Empty;

                var conn = connectionString ?? Environment.GetEnvironmentVariable("READING_TEST_POSTGRES") ?? DefaultConn;
                var options = new DbContextOptionsBuilder<ExamDbContext>()
                    .UseNpgsql(conn, npg => {
                        npg.ConfigureDataSource(dataSource => dataSource.EnableDynamicJson());
                        npg.EnableRetryOnFailure();
                    }).Options;
                using var db = new ExamDbContext(options);

                var allHeads = db.ReadingPaperArtifactHeads.AsNoTracking().Where(h => h.RunId == pRunId).ToDictionary(h => h.ArtifactId);
                var bpId = $"art_blueprint_{pRunId[..Math.Min(8, pRunId.Length)]}";
                var bpHead = allHeads.TryGetValue(bpId, out var bph) ? bph : allHeads.Values.First(h => h.ArtifactId.StartsWith("art_blueprint_"));
                var bpRef = new ArtifactRef(bpHead.ArtifactId, ArtifactType.ExamBlueprint, bpHead.AcceptedVersion, bpHead.AcceptedHash);

                var s1Head = allHeads["art_section_1"];
                var secRefs = new List<ArtifactRef>
                {
                    new(s1Head.ArtifactId, ArtifactType.Section, s1Head.AcceptedVersion, s1Head.AcceptedHash),
                };
                if (allHeads.TryGetValue("art_section_2", out var s2Head))
                {
                    secRefs.Add(new ArtifactRef(s2Head.ArtifactId, ArtifactType.Section, s2Head.AcceptedVersion, s2Head.AcceptedHash));
                }
                if (allHeads.TryGetValue("art_section_3", out var s3Head))
                {
                    secRefs.Add(new ArtifactRef(s3Head.ArtifactId, ArtifactType.Section, s3Head.AcceptedVersion, s3Head.AcceptedHash));
                }

                var pRefs = new List<ArtifactRef>();
                for (int i = 1; i <= secRefs.Count; i++)
                {
                    var pHead = allHeads.TryGetValue($"art_passage_s{i}", out var ph) ? ph : allHeads[$"art_passage_{i}"];
                    pRefs.Add(new ArtifactRef(pHead.ArtifactId, ArtifactType.Passage, pHead.AcceptedVersion, pHead.AcceptedHash));
                }

                var totalQs = secRefs.Count == 1 ? 13 : 40;
                var qRefs = new List<ArtifactRef>();
                for (int i = 1; i <= totalQs; i++)
                {
                    var qHead = allHeads[$"art_q_{i}"];
                    qRefs.Add(new ArtifactRef(qHead.ArtifactId, ArtifactType.Question, qHead.AcceptedVersion, qHead.AcceptedHash));
                }

                var pParents = new List<ArtifactRef> { bpRef }.Concat(secRefs).Concat(pRefs).Concat(qRefs).ToList();

                var secArtifacts = db.ReadingPaperArtifacts.AsNoTracking()
                    .Where(a => a.RunId == pRunId && a.ArtifactType == "Section")
                    .OrderBy(a => a.ArtifactId)
                    .ToList();
                var secPayloads = secArtifacts.Select(a => JsonDocument.Parse(a.PayloadJson).RootElement.Clone()).ToList();

                var paperId = $"art_paper_{pRunId[..Math.Min(8, pRunId.Length)]}";
                var payload = new
                {
                    paperId,
                    runId = pRunId,
                    title = "Cross-Disciplinary Three Section Full Paper",
                    totalQuestions = totalQs,
                    blueprintRef = bpRef,
                    sectionRefs = secRefs,
                    passageRefs = pRefs,
                    questionRefs = qRefs,
                    sections = secPayloads
                };
                var pDoc = JsonDocument.Parse(JsonSerializer.Serialize(payload, ReadingPaperRules.Json));
                var pHash = ArtifactEnvelope.ComputeContentHash(pDoc.RootElement, pParents);
                var pEnv = new ArtifactEnvelope(paperId, ArtifactType.ReadingPaper, 1, pRunId, null, "2.0.0", pHash, DateTime.UtcNow, "2.0.0", pDoc.RootElement.Clone(), pParents);

                var existingPaper = db.ReadingPaperArtifacts.FirstOrDefault(a => a.RunId == pRunId && a.ArtifactId == paperId);
                if (existingPaper == null)
                {
                    db.ReadingPaperArtifacts.Add(new ReadingPaperArtifact
                    {
                        Id = Guid.NewGuid(),
                        RunId = pRunId,
                        ArtifactId = paperId,
                        ArtifactType = ArtifactType.ReadingPaper.ToString(),
                        Version = 1,
                        ContentHash = pHash,
                        PayloadJson = pDoc.RootElement.GetRawText(),
                        ParentRefsJson = JsonSerializer.Serialize(pParents, LoopEngineJson.Options),
                        EnvelopeJson = JsonSerializer.Serialize(pEnv, LoopEngineJson.Options),
                        CreatedAt = pEnv.CreatedAt
                    });
                }
                var existingHead = db.ReadingPaperArtifactHeads.FirstOrDefault(h => h.RunId == pRunId && h.ArtifactId == paperId);
                if (existingHead == null)
                {
                    db.ReadingPaperArtifactHeads.Add(new ReadingPaperArtifactHead
                    {
                        Id = Guid.NewGuid(),
                        RunId = pRunId,
                        ArtifactId = paperId,
                        AcceptedVersion = 1,
                        AcceptedHash = pHash,
                        UpdatedAt = pEnv.CreatedAt
                    });
                }
                db.SaveChanges();
                return Task.FromResult(new HttpResponseMessage(HttpStatusCode.OK)
                {
                    Content = new StringContent(JsonSerializer.Serialize(pEnv, LoopEngineJson.Options), Encoding.UTF8, "application/json")
                });
            }

            if (uri.Contains("paper-evaluate"))
            {
                var paperEnvObj = JsonSerializer.Deserialize<ArtifactEnvelope>(sDoc.RootElement.GetProperty("paperEnvelope").GetRawText(), LoopEngineJson.Options)!;
                var targetRef = paperEnvObj.ToRef();
                var inputDeps = paperEnvObj.ParentRefs;

                var evals = ReadingPaperFinalSnapshot.RequiredEvaluators.Select(kv => new EvaluationResult(
                    EvaluationId: $"eval_{kv.Key}_{Guid.NewGuid():N}"[..24],
                    EvaluatorId: kv.Key,
                    EvaluatorVersion: kv.Value,
                    TargetRef: targetRef,
                    Status: EvaluationStatus.PASS,
                    Issues: new List<Issue>(),
                    Score: 1.0,
                    InputDependencyRefs: inputDeps,
                    Provider: "test-provider",
                    Model: "test-model",
                    PromptVersion: "1.0.0",
                    ElapsedMs: 100.0,
                    Usage: new UsageMetrics(100, 50, 150, 0.001),
                    EvaluatedAt: DateTime.UtcNow
                )).ToList();

                var conn = connectionString ?? Environment.GetEnvironmentVariable("READING_TEST_POSTGRES") ?? DefaultConn;
                var options = new DbContextOptionsBuilder<ExamDbContext>()
                    .UseNpgsql(conn, npg => {
                        npg.ConfigureDataSource(dataSource => dataSource.EnableDynamicJson());
                        npg.EnableRetryOnFailure();
                    }).Options;
                using var db = new ExamDbContext(options);

                var runId = sDoc.RootElement.TryGetProperty("runId", out var rP) ? rP.GetString() ?? "" : "";
                foreach (var eval in evals)
                {
                    if (!db.ReadingPaperEvaluations.Any(e => e.RunId == runId && e.EvaluationId == eval.EvaluationId))
                    {
                        db.ReadingPaperEvaluations.Add(new ReadingPaperEvaluation
                        {
                            Id = Guid.NewGuid(),
                            RunId = runId,
                            EvaluationId = eval.EvaluationId,
                            EvaluatorId = eval.EvaluatorId,
                            EvaluatorVersion = eval.EvaluatorVersion,
                            TargetArtifactId = eval.TargetRef.ArtifactId,
                            TargetVersion = eval.TargetRef.Version,
                            TargetContentHash = eval.TargetRef.ContentHash,
                            Status = eval.Status.ToString(),
                            IsPass = eval.Status == EvaluationStatus.PASS,
                            PayloadJson = JsonSerializer.Serialize(eval, LoopEngineJson.Options),
                            CreatedAt = eval.EvaluatedAt
                        });
                    }
                }
                db.SaveChanges();

                return Task.FromResult(new HttpResponseMessage(HttpStatusCode.OK)
                {
                    Content = new StringContent(JsonSerializer.Serialize(evals, LoopEngineJson.Options), Encoding.UTF8, "application/json")
                });
            }

            if (uri.Contains("section-v2"))
            {
                var secIdx = sDoc.RootElement.TryGetProperty("sectionIndex", out var sIdx) ? sIdx.GetInt32() : (sDoc.RootElement.TryGetProperty("index", out var iIdx) ? iIdx.GetInt32() : 1);
                var passageText = secIdx switch
                {
                    1 => string.Join(" ", Enumerable.Repeat("Academic research discusses marine ecosystem and ocean biodiversity.", 100)),
                    2 => string.Join(" ", Enumerable.Repeat("Quantum processor executes syndrome measurements for logical qubits.", 100)),
                    3 => string.Join(" ", Enumerable.Repeat("Smart meters deployed in low-voltage distribution networks operate under harsh conditions.", 80)),
                    _ => string.Join(" ", Enumerable.Repeat("Academic research discusses marine ecosystem and ocean biodiversity.", 100))
                };
                var pmc = secIdx switch
                {
                    1 => "PMC13560651",
                    2 => "PMC13407692",
                    3 => "PMC13517498",
                    _ => "PMC13560651"
                };

                List<ReadingGeneratedGroup> secGroups;
                if (secIdx == 3)
                {
                    var ynngOptions = new List<string> { "YES", "NO", "NOT GIVEN" };
                    var s3Quote = "Smart meters deployed in low-voltage distribution networks operate under harsh conditions.";
                    var s3Ans = "harsh conditions";
                    var g1Qs = Enumerable.Range(27, 7).Select(n =>
                        new ReadingGeneratedQuestion(n, $"Do smart meter conditions in grid district [{n}] affect measurement reliability?", n % 3 == 0 ? "YES" : n % 3 == 1 ? "NO" : "NOT GIVEN", ynngOptions, s3Quote, s3Quote)
                    ).ToList();
                    var g2Qs = Enumerable.Range(34, 7).Select(n =>
                        new ReadingGeneratedQuestion(n, $"Under what conditions do low-voltage smart meters operate in district [{n}]?", s3Ans, new List<string>(), s3Quote, s3Quote)
                    ).ToList();
                    secGroups = new List<ReadingGeneratedGroup>
                    {
                        new("YES_NO_NOT_GIVEN", "Do the following statements agree with the views/claims of the writer in the reading passage?", g1Qs),
                        new("SHORT_ANSWER", "Answer the questions below. Choose NO MORE THAN THREE WORDS from the passage for each answer.", g2Qs)
                    };
                }
                else if (secIdx == 2)
                {
                    var mcqOpts = new List<string> { "A. First choice", "B. Second choice", "C. Third choice", "D. Fourth choice" };
                    var s2Quote = "Quantum processor executes syndrome measurements for logical qubits.";
                    var g1Qs = Enumerable.Range(14, 6).Select(n =>
                        new ReadingGeneratedQuestion(n, $"Which architecture applies to physical qubit [{n}]?", "A. First choice", mcqOpts, s2Quote, s2Quote)
                    ).ToList();
                    var g2Qs = Enumerable.Range(20, 7).Select(n =>
                        new ReadingGeneratedQuestion(n, $"Syndrome measurements evaluate [{n}].", "logical qubits", new List<string>(), s2Quote, s2Quote)
                    ).ToList();
                    secGroups = new List<ReadingGeneratedGroup>
                    {
                        new("MULTIPLE_CHOICE_SINGLE", "Choose the correct letter, A, B, C or D.", g1Qs),
                        new("SUMMARY_COMPLETION", "Complete the summary below. Choose NO MORE THAN TWO WORDS from the passage for each answer.", g2Qs)
                    };
                }
                else
                {
                    var quoteStr = "Academic research discusses marine ecosystem and ocean biodiversity.";
                    var tfngOptions = new List<string> { "TRUE", "FALSE", "NOT GIVEN" };
                    var g1Qs = Enumerable.Range(1, 7).Select(n =>
                        new ReadingGeneratedQuestion(n, $"Statement {n} discusses marine biodiversity.", n % 3 == 1 ? "TRUE" : n % 3 == 2 ? "FALSE" : "NOT GIVEN", tfngOptions, quoteStr, "Detailed research confirms that marine biodiversity is actively studied in the ocean.")
                    ).ToList();
                    var g2Qs = Enumerable.Range(8, 6).Select(n =>
                        new ReadingGeneratedQuestion(n, $"Academic research analyzes marine [{n}].", "ocean biodiversity", new List<string>(), quoteStr, "The passage explicitly notes that research focuses on ocean biodiversity in ecosystems.")
                    ).ToList();
                    secGroups = new List<ReadingGeneratedGroup>
                    {
                        new("TRUE_FALSE_NOT_GIVEN", "Do the following statements agree with the information given in the reading passage?", g1Qs),
                        new("SENTENCE_COMPLETION", "Complete the sentences below. Choose NO MORE THAN THREE WORDS from the passage for each answer.", g2Qs)
                    };
                }

                var secResult = new ReadingGeneratedSection(
                    $"Passage {secIdx} Title",
                    passageText,
                    new ReadingSource(pmc, $"Title {secIdx}", null, "https://url", "CC-BY-4.0", 800),
                    secGroups
                );
                return Task.FromResult(new HttpResponseMessage(HttpStatusCode.OK)
                {
                    Content = new StringContent(JsonSerializer.Serialize(secResult, ReadingPaperRules.Json), Encoding.UTF8, "application/json")
                });
            }

            var index = sDoc.RootElement.TryGetProperty("index", out var idxP) ? idxP.GetInt32() : (sDoc.RootElement.TryGetProperty("sectionIndex", out var secIdxP) ? secIdxP.GetInt32() : 1);
            var passageTextDefault = index switch
            {
                1 => string.Join(" ", Enumerable.Repeat("Academic research discusses marine ecosystem and ocean biodiversity.", 100)),
                2 => string.Join(" ", Enumerable.Repeat("Quantum processor executes syndrome measurements for logical qubits.", 100)),
                3 => string.Join(" ", Enumerable.Repeat("Smart meters deployed in low-voltage distribution networks operate under harsh conditions.", 80)),
                _ => string.Join(" ", Enumerable.Repeat("Academic research discusses marine ecosystem and ocean biodiversity.", 100))
            };
            var pmcDefault = index switch
            {
                1 => "PMC13560651",
                2 => "PMC13407692",
                3 => "PMC13517498",
                _ => "PMC13560651"
            };

            var initialGroups = new List<ReadingGeneratedGroup>();
            if (index == 1 && SeedPartialGroupOnSection1)
            {
                var quoteStr = "Academic research discusses marine ecosystem and ocean biodiversity.";
                var tfngOptions = new List<string> { "TRUE", "FALSE", "NOT GIVEN" };
                var partialQs = Enumerable.Range(1, 5).Select(i =>
                    new ReadingGeneratedQuestion(i, $"Statement {i} discusses marine biodiversity.", i % 2 == 1 ? "TRUE" : "FALSE", tfngOptions, quoteStr, "Detailed research confirms that marine biodiversity is actively studied in the ocean.")
                ).ToList();
                initialGroups.Add(new ReadingGeneratedGroup("TRUE_FALSE_NOT_GIVEN", "Do the following statements agree with the information given in the reading passage?", partialQs));
            }

            var section = new ReadingGeneratedSection(
                $"Passage {index} Title",
                passageTextDefault,
                new ReadingSource(pmcDefault, $"Title {index}", null, "https://url", "CC-BY-4.0", 800),
                initialGroups
            );
            return Task.FromResult(new HttpResponseMessage(HttpStatusCode.OK)
            {
                Content = new StringContent(JsonSerializer.Serialize(section, ReadingPaperRules.Json), Encoding.UTF8, "application/json")
            });
        }
    }
    [Fact]
    public async Task WorkerV2QuestionConsumer_MultiSection_SelectsDistinctSectionPassageRefs()
    {
        var connection = Environment.GetEnvironmentVariable("READING_TEST_POSTGRES") ?? DefaultConn;
        var handler = new V2QuestionConsumerHandler(connection);

        var services = new ServiceCollection();
        services.AddDbContext<ExamDbContext>(options => options.UseNpgsql(connection, npg =>
        {
            npg.ConfigureDataSource(dataSource => dataSource.EnableDynamicJson());
            npg.EnableRetryOnFailure();
        }));
        services.AddHttpClient<ReadingPaperAiClient>(client =>
        {
            client.BaseAddress = new Uri("http://fake-ai/");
            client.Timeout = TimeSpan.FromSeconds(10);
        }).ConfigurePrimaryHttpMessageHandler(() => handler);

        await using var provider = services.BuildServiceProvider();

        // Create a 3-passage job with engine=v2 metadata
        Guid jobId;
        string expectedRunId;
        string expectedBpId;
        string expectedBpHash;
        string s1PassageHash;
        string s2PassageHash;
        string s3PassageHash;

        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            await db.Database.MigrateAsync();
            jobId = Guid.NewGuid();
            expectedRunId = $"run_{jobId:N}";
            expectedBpId = $"art_blueprint_{expectedRunId[..Math.Min(8, expectedRunId.Length)]}";

            var job = new ReadingPaperJob
            {
                Id = jobId,
                ActiveRunId = expectedRunId,
                Topic = "Cross-Disciplinary Three Section Full Paper",
                SourcesJson = JsonSerializer.Serialize(new List<ReadingSource> {
                    new("PMC13560651", "Marine Title", null, "https://url/1", "CC-BY-4.0", 800, Metadata: new Dictionary<string, string> { ["engine"] = "v2" }),
                    new("PMC13407692", "Quantum Title", null, "https://url/2", "CC-BY-4.0", 800, Metadata: new Dictionary<string, string> { ["engine"] = "v2" }),
                    new("PMC13517498", "Smart Grid Title", null, "https://url/3", "CC-BY-4.0", 800, Metadata: new Dictionary<string, string> { ["engine"] = "v2" }),
                }, ReadingPaperRules.Json)
            };
            db.ReadingPaperJobs.Add(job);

            var bpDoc = JsonDocument.Parse(JsonSerializer.Serialize(new { totalQuestions = 40, targetWordCountMin = 2150, targetWordCountMax = 2750 }, ReadingPaperRules.Json));
            var bpParents = new List<ArtifactRef>();
            expectedBpHash = ArtifactEnvelope.ComputeContentHash(bpDoc.RootElement, bpParents);
            var bpEnv = new ArtifactEnvelope(expectedBpId, ArtifactType.ExamBlueprint, 1, expectedRunId, null, "2.0.0", expectedBpHash, DateTime.UtcNow, "2.0.0", bpDoc.RootElement.Clone(), bpParents);
            db.ReadingPaperArtifacts.Add(new ReadingPaperArtifact
            {
                Id = Guid.NewGuid(), RunId = expectedRunId, ArtifactId = expectedBpId, ArtifactType = ArtifactType.ExamBlueprint.ToString(),
                Version = 1, ContentHash = expectedBpHash, PayloadJson = bpDoc.RootElement.GetRawText(), ParentRefsJson = "[]",
                EnvelopeJson = JsonSerializer.Serialize(bpEnv, LoopEngineJson.Options), CreatedAt = DateTime.UtcNow
            });
            db.ReadingPaperArtifactHeads.Add(new ReadingPaperArtifactHead
            {
                RunId = expectedRunId,
                ArtifactId = expectedBpId,
                AcceptedVersion = 1,
                AcceptedHash = expectedBpHash,
                UpdatedAt = DateTime.UtcNow
            });

            var passageSources = new[] {
                new ReadingSource("PMC13560651", "Marine Title", null, "https://url/1", "CC-BY-4.0", 800),
                new ReadingSource("PMC13407692", "Quantum Title", null, "https://url/2", "CC-BY-4.0", 800),
                new ReadingSource("PMC13517498", "Smart Grid Title", null, "https://url/3", "CC-BY-4.0", 800)
            };
            var passageTexts = new[] {
                string.Join(" ", Enumerable.Repeat("Academic research discusses marine ecosystem and ocean biodiversity.", 100)),
                string.Join(" ", Enumerable.Repeat("Quantum processor executes syndrome measurements for logical qubits.", 100)),
                string.Join(" ", Enumerable.Repeat("Smart meters deployed in low-voltage distribution networks operate under harsh conditions.", 80))
            };
            var passageHashes = new string[3];

            for (int i = 1; i <= 3; i++)
            {
                var pId = $"art_passage_s{i}";
                var pDoc = JsonDocument.Parse(JsonSerializer.Serialize(new { text = passageTexts[i - 1], passage = passageTexts[i - 1], wordCount = 800, source = passageSources[i - 1] }, ReadingPaperRules.Json));
                var pParents = new List<ArtifactRef> { bpEnv.ToRef() };
                var pHash = ArtifactEnvelope.ComputeContentHash(pDoc.RootElement, pParents);
                passageHashes[i - 1] = pHash;
                var pEnv = new ArtifactEnvelope(pId, ArtifactType.Passage, 1, expectedRunId, i, "2.0.0", pHash, DateTime.UtcNow, "2.0.0", pDoc.RootElement.Clone(), pParents);

                db.ReadingPaperArtifacts.Add(new ReadingPaperArtifact
                {
                    Id = Guid.NewGuid(), RunId = expectedRunId, ArtifactId = pId, ArtifactType = ArtifactType.Passage.ToString(),
                    Version = 1, ContentHash = pHash, PayloadJson = pDoc.RootElement.GetRawText(),
                    ParentRefsJson = JsonSerializer.Serialize(pParents, LoopEngineJson.Options),
                    EnvelopeJson = JsonSerializer.Serialize(pEnv, LoopEngineJson.Options), CreatedAt = DateTime.UtcNow
                });
                db.ReadingPaperArtifactHeads.Add(new ReadingPaperArtifactHead
                {
                    RunId = expectedRunId,
                    ArtifactId = pId,
                    AcceptedVersion = 1,
                    AcceptedHash = pHash,
                    UpdatedAt = DateTime.UtcNow
                });
            }

            s1PassageHash = passageHashes[0];
            s2PassageHash = passageHashes[1];
            s3PassageHash = passageHashes[2];

            await db.SaveChangesAsync();
        }
        var worker = new ReadingPaperWorker(
            provider.GetRequiredService<IServiceScopeFactory>(),
            NullLogger<ReadingPaperWorker>.Instance,
            R03CapsProfileTests.ApprovedFromDeployEnvFile()
        );

        await worker.StartAsync(CancellationToken.None);
        try
        {
            await WaitForStatus(provider, jobId, "Completed");

            // Verify that each of the 3 sections selected its own distinct passage ref!
            Assert.Equal(3, handler.QuestionCallRecords.Count);

            var r1 = handler.QuestionCallRecords.First(r => r.SectionIndex == 1);
            var r2 = handler.QuestionCallRecords.First(r => r.SectionIndex == 2);
            var r3 = handler.QuestionCallRecords.First(r => r.SectionIndex == 3);

            Assert.Equal("art_passage_s1", r1.PassageArtifactId);
            Assert.Equal("art_passage_s2", r2.PassageArtifactId);
            Assert.Equal("art_passage_s3", r3.PassageArtifactId);

            // Assert exact RunId, Epoch, and SectionIndex captured per section
            Assert.Equal(expectedRunId, r1.RunId);
            Assert.Equal(expectedRunId, r2.RunId);
            Assert.Equal(expectedRunId, r3.RunId);
            Assert.Equal(2, r1.Epoch);
            Assert.Equal(2, r2.Epoch);
            Assert.Equal(2, r3.Epoch);

            // Assert exact distinct passage artifact IDs AND exact seeded hashes from PostgreSQL:
            Assert.Equal("art_passage_s1", r1.PassageArtifactId);
            Assert.Equal(s1PassageHash, r1.PassageHash);

            Assert.Equal("art_passage_s2", r2.PassageArtifactId);
            Assert.Equal(s2PassageHash, r2.PassageHash);

            Assert.Equal("art_passage_s3", r3.PassageArtifactId);
            Assert.Equal(s3PassageHash, r3.PassageHash);

            // Assert exact blueprint artifact ID AND exact seeded hash from PostgreSQL across all sections:
            Assert.Equal(expectedBpId, r1.BlueprintArtifactId);
            Assert.Equal(expectedBpHash, r1.BlueprintHash);
            Assert.Equal(expectedBpId, r2.BlueprintArtifactId);
            Assert.Equal(expectedBpHash, r2.BlueprintHash);
            Assert.Equal(expectedBpId, r3.BlueprintArtifactId);
            Assert.Equal(expectedBpHash, r3.BlueprintHash);

            // Assert cryptographic payload hash binding against recorded body bytes:
            foreach (var rec in handler.QuestionCallRecords)
            {
                var computedHash = Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(rec.RawBody)));
                Assert.Equal(computedHash, rec.RequestHash);
            }
            using (var scope = provider.CreateScope())
            {
                var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
                var job = await db.ReadingPaperJobs.AsNoTracking().SingleAsync(x => x.Id == jobId);
                Assert.NotNull(job.ExamId);

                var exam = await db.Exams.Include(e => e.Sections)
                    .ThenInclude(s => s.QuestionGroups)
                    .ThenInclude(g => g.Questions)
                    .ThenInclude(q => q.Options)
                    .SingleAsync(e => e.Id == job.ExamId);

                // Verify complete paper: 3 sections, exactly 40 contiguous questions!
                Assert.Equal(3, exam.Sections.Count);
                Assert.Equal(40, exam.Sections.Sum(s => s.Questions.Count));

                // Section 1: 13 questions (7 TFNG, 6 SentenceCompletion)
                var sec1 = exam.Sections.First(s => s.Idx == 1);
                Assert.Equal(13, sec1.Questions.Count);
                var s1Groups = sec1.QuestionGroups.OrderBy(g => g.Idx).ToList();
                Assert.Equal(2, s1Groups.Count);
                Assert.Equal("TRUE_FALSE_NOT_GIVEN", s1Groups[0].Questions.First().Type);
                Assert.Equal(7, s1Groups[0].Questions.Count);
                Assert.Equal("SENTENCE_COMPLETION", s1Groups[1].Questions.First().Type);
                Assert.Equal(6, s1Groups[1].Questions.Count);

                // Section 2: 13 questions (6 MCQ, 7 SummaryCompletion)
                var sec2 = exam.Sections.First(s => s.Idx == 2);
                Assert.Equal(13, sec2.Questions.Count);
                var s2Groups = sec2.QuestionGroups.OrderBy(g => g.Idx).ToList();
                Assert.Equal(2, s2Groups.Count);
                Assert.Equal("MULTIPLE_CHOICE_SINGLE", s2Groups[0].Questions.First().Type);
                Assert.Equal(6, s2Groups[0].Questions.Count);
                Assert.Equal("SUMMARY_COMPLETION", s2Groups[1].Questions.First().Type);
                Assert.Equal(7, s2Groups[1].Questions.Count);
                var mcqQ = sec2.Questions.First(q => q.Type == "MULTIPLE_CHOICE_SINGLE");
                Assert.Equal(4, mcqQ.Options.Count);

                // Section 3: 14 questions (7 YNNG, 7 ShortAnswer)
                var sec3 = exam.Sections.First(s => s.Idx == 3);
                Assert.Equal(14, sec3.Questions.Count);
                var s3Groups = sec3.QuestionGroups.OrderBy(g => g.Idx).ToList();
                Assert.Equal(2, s3Groups.Count);
                Assert.Equal("YES_NO_NOT_GIVEN", s3Groups[0].Questions.First().Type);
                Assert.Equal(7, s3Groups[0].Questions.Count);
                Assert.Equal("SHORT_ANSWER", s3Groups[1].Questions.First().Type);
                Assert.Equal(7, s3Groups[1].Questions.Count);
                var ynngQ = sec3.Questions.First(q => q.Type == "YES_NO_NOT_GIVEN");
                Assert.Equal(3, ynngQ.Options.Count);
                var shortAnsQ = sec3.Questions.First(q => q.Type == "SHORT_ANSWER");
                Assert.NotNull(shortAnsQ.ShortAnswerAcceptTexts);
            }
        }
        finally
        {
            await worker.StopAsync(CancellationToken.None);
        }
    }

    [Fact]
    public async Task WorkerV2QuestionConsumer_MultiPass_ResumesPartialGroups_AndBindsPersistedPassageHead()
    {
        var connection = Environment.GetEnvironmentVariable("READING_TEST_POSTGRES") ?? DefaultConn;
        var handler = new V2QuestionConsumerHandler(connection)
        {
            SeedPartialGroupOnSection1 = true,
            FailQuestionsOnFirstAttempt = true
        };

        var services = new ServiceCollection();
        services.AddDbContext<ExamDbContext>(options => options.UseNpgsql(connection, npg =>
        {
            npg.ConfigureDataSource(dataSource => dataSource.EnableDynamicJson());
            npg.EnableRetryOnFailure();
        }));
        services.AddHttpClient<ReadingPaperAiClient>(client =>
        {
            client.BaseAddress = new Uri("http://fake-ai/");
            client.Timeout = TimeSpan.FromSeconds(10);
        }).ConfigurePrimaryHttpMessageHandler(() => handler);

        await using var provider = services.BuildServiceProvider();

        Guid jobId;
        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            await db.Database.MigrateAsync();
            var job = new ReadingPaperJob
            {
                Topic = "Partial Group Recovery Across Restart",
                SourcesJson = JsonSerializer.Serialize(new List<ReadingSource> {
                    new("PMC13560651", "Title", null, "https://url", "CC-BY-4.0", 800, Metadata: new Dictionary<string, string> { ["engine"] = "v2" })
                }, ReadingPaperRules.Json)
            };
            db.ReadingPaperJobs.Add(job);
            await db.SaveChangesAsync();
            jobId = job.Id;
        }

        // Attempt 1: Worker 1 starts, generates passage, but encounters network failure on questions
        var worker1 = new ReadingPaperWorker(
            provider.GetRequiredService<IServiceScopeFactory>(),
            NullLogger<ReadingPaperWorker>.Instance,
            R03CapsProfileTests.ApprovedFromDeployEnvFile()
        );

        await worker1.StartAsync(CancellationToken.None);
        try
        {
            await WaitForStatus(provider, jobId, "Failed");
        }
        finally
        {
            await worker1.StopAsync(CancellationToken.None);
        }

        // Verify state after Worker 1 crash:
        // Section 1 passage head is durably committed in PostgreSQL!
        string expectedPassageHash;
        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var failedJob = await db.ReadingPaperJobs.AsNoTracking().SingleAsync(x => x.Id == jobId);
            Assert.Equal("Failed", failedJob.Status);

            var runId = failedJob.ActiveRunId ?? $"run_{failedJob.Id:N}";
            var sectionOp = await db.ReadingPaperOperations.AsNoTracking()
                .FirstOrDefaultAsync(o => o.RunId == runId && o.OperationType == "GENERATE_SECTION");
            Assert.NotNull(sectionOp);

            // Verify Section 1 passage head is durably committed in PostgreSQL from Attempt 1!
            var persistedPassageHead = await db.ReadingPaperArtifactHeads.AsNoTracking()
                .SingleAsync(h => h.RunId == runId && h.ArtifactId == "art_passage_s1");
            Assert.Equal(1, persistedPassageHead.AcceptedVersion);
            expectedPassageHash = persistedPassageHead.AcceptedHash;
            // Reset job to Pending with Epoch 2 for Worker 2 takeover/retry
            await db.ReadingPaperJobs.Where(x => x.Id == jobId)
                .ExecuteUpdateAsync(x => x.SetProperty(j => j.Status, "Pending")
                                          .SetProperty(j => j.Epoch, j => j.Epoch + 1));
        }
        // Attempt 2: Fresh Worker 2 instance with clean memory starts, claims job at Epoch 2 from PostgreSQL,
        // and completes question generation without regenerating passage
        handler.FailQuestionsOnFirstAttempt = false;
        var worker2 = new ReadingPaperWorker(
            provider.GetRequiredService<IServiceScopeFactory>(),
            NullLogger<ReadingPaperWorker>.Instance,
            R03CapsProfileTests.ApprovedFromDeployEnvFile()
        );

        await worker2.StartAsync(CancellationToken.None);
        try
        {
            await WaitForStatus(provider, jobId, "Completed");

            // Verify that worker requested missing slots [6..13] and did NOT skip!
            Assert.Contains(6, handler.RequestedSlotNumbers);
            Assert.Contains(13, handler.RequestedSlotNumbers);
            Assert.DoesNotContain(1, handler.RequestedSlotNumbers); // 1..5 already existed

            // Verify Attempt 2 bound the persisted section 1 passage head from PostgreSQL with Epoch 2!
            var resumeRec = handler.QuestionCallRecords.Last();
            Assert.Equal(4, resumeRec.Epoch);
            Assert.Equal("art_passage_s1", resumeRec.PassageArtifactId);
            Assert.Equal(expectedPassageHash, resumeRec.PassageHash);
            Assert.Equal(Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(resumeRec.RawBody))), resumeRec.RequestHash);
            using (var scope = provider.CreateScope())
            {
                var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
                var job = await db.ReadingPaperJobs.AsNoTracking().SingleAsync(x => x.Id == jobId);
                Assert.NotNull(job.ExamId);

                var exam = await db.Exams.Include(e => e.Sections)
                    .ThenInclude(s => s.QuestionGroups)
                    .ThenInclude(g => g.Questions)
                    .SingleAsync(e => e.Id == job.ExamId);

                Assert.Single(exam.Sections);
                var sec = exam.Sections[0];
                Assert.Equal(13, sec.Questions.Count); // Full 13 questions present!

                var orderedGroups = sec.QuestionGroups.OrderBy(g => g.Idx).ToList();
                Assert.Equal(2, orderedGroups.Count);
                Assert.Equal(7, orderedGroups[0].Questions.Count);
                Assert.Equal(6, orderedGroups[1].Questions.Count);
            }
        }
        finally
        {
            await worker2.StopAsync(CancellationToken.None);
        }
    }

    private static async Task WaitForStatus(ServiceProvider provider, Guid id, string expected)
    {
        using var timeout = new CancellationTokenSource(TimeSpan.FromSeconds(30));
        try
        {
            while (!timeout.IsCancellationRequested)
            {
                using var scope = provider.CreateScope();
                var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
                var status = await db.ReadingPaperJobs.AsNoTracking()
                    .Where(x => x.Id == id).Select(x => x.Status).FirstOrDefaultAsync(timeout.Token);
                if (status == expected) return;
                await Task.Delay(200, timeout.Token);
            }
        }
        catch (OperationCanceledException) { }

        using var errScope = provider.CreateScope();
        var errDb = errScope.ServiceProvider.GetRequiredService<ExamDbContext>();
        var failedJob = await errDb.ReadingPaperJobs.AsNoTracking().FirstOrDefaultAsync(x => x.Id == id);
        throw new TimeoutException($"Job {id} did not reach expected status '{expected}', current status is '{failedJob?.Status}'. Logs:\n{failedJob?.Logs}");
    }
}
