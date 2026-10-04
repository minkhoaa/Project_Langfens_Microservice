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
using Xunit;

namespace exam_service.Tests;
[Collection("DatabaseTests")]
public class ReadingPaperWorkerCrashSection2Tests
{
    private const string DefaultConn = "Host=localhost;Port=5433;Database=exam_test_crash_t004;Username=exam;Password=exam";

    private sealed class SectionCrashHandler(List<ReadingGeneratedSection> sections) : HttpMessageHandler
    {
        public Dictionary<int, int> Calls { get; } = new() { [1] = 0, [2] = 0, [3] = 0 };
        public bool FailOnSection3 { get; set; } = true;

        protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken ct)
        {
            var body = request.Content?.ReadAsStringAsync(ct).GetAwaiter().GetResult() ?? "";
            using var doc = JsonDocument.Parse(body);
            var index = doc.RootElement.GetProperty("index").GetInt32();
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
        var handler = new SectionCrashHandler(fixture);

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
            NullLogger<ReadingPaperWorker>.Instance
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

    private sealed class V2QuestionConsumerHandler : HttpMessageHandler
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
            using var sDoc = JsonDocument.Parse(body);
            var index = sDoc.RootElement.TryGetProperty("index", out var idxP) ? idxP.GetInt32() : 1;
            var passageText = index switch
            {
                1 => string.Join(" ", Enumerable.Repeat("Academic research discusses marine ecosystem and ocean biodiversity.", 100)),
                2 => string.Join(" ", Enumerable.Repeat("Quantum processor executes syndrome measurements for logical qubits.", 100)),
                3 => string.Join(" ", Enumerable.Repeat("Smart meters deployed in low-voltage distribution networks operate under harsh conditions.", 80)),
                _ => string.Join(" ", Enumerable.Repeat("Academic research discusses marine ecosystem and ocean biodiversity.", 100))
            };
            var pmc = index switch
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
                passageText,
                new ReadingSource(pmc, $"Title {index}", null, "https://url", "CC-BY-4.0", 800),
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
        var handler = new V2QuestionConsumerHandler();

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
        var expectedBpHash = "b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1";
        var s1PassageHash = "a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1";
        var s2PassageHash = "a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2";
        var s3PassageHash = "a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3";

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

            // Seed exact PostgreSQL heads for blueprint and all 3 section passages!
            db.ReadingPaperArtifactHeads.Add(new ReadingPaperArtifactHead
            {
                RunId = expectedRunId,
                ArtifactId = expectedBpId,
                AcceptedVersion = 1,
                AcceptedHash = expectedBpHash,
                UpdatedAt = DateTime.UtcNow
            });
            db.ReadingPaperArtifactHeads.Add(new ReadingPaperArtifactHead
            {
                RunId = expectedRunId,
                ArtifactId = "art_passage_s1",
                AcceptedVersion = 1,
                AcceptedHash = s1PassageHash,
                UpdatedAt = DateTime.UtcNow
            });
            db.ReadingPaperArtifactHeads.Add(new ReadingPaperArtifactHead
            {
                RunId = expectedRunId,
                ArtifactId = "art_passage_s2",
                AcceptedVersion = 1,
                AcceptedHash = s2PassageHash,
                UpdatedAt = DateTime.UtcNow
            });
            db.ReadingPaperArtifactHeads.Add(new ReadingPaperArtifactHead
            {
                RunId = expectedRunId,
                ArtifactId = "art_passage_s3",
                AcceptedVersion = 1,
                AcceptedHash = s3PassageHash,
                UpdatedAt = DateTime.UtcNow
            });

            await db.SaveChangesAsync();
        }
        var worker = new ReadingPaperWorker(
            provider.GetRequiredService<IServiceScopeFactory>(),
            NullLogger<ReadingPaperWorker>.Instance
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
        var handler = new V2QuestionConsumerHandler
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
            NullLogger<ReadingPaperWorker>.Instance
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
        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var failedJob = await db.ReadingPaperJobs.AsNoTracking().SingleAsync(x => x.Id == jobId);
            Assert.Equal("Failed", failedJob.Status);

            var runId = failedJob.ActiveRunId ?? $"run_{failedJob.Id:N}";
            var sectionOp = await db.ReadingPaperOperations.AsNoTracking()
                .FirstOrDefaultAsync(o => o.RunId == runId && o.OperationType == "GENERATE_SECTION");
            Assert.NotNull(sectionOp);

            // Seed durable passage head into PostgreSQL to verify Worker 2 picks it up on resume
            db.ReadingPaperArtifactHeads.Add(new ReadingPaperArtifactHead
            {
                RunId = runId,
                ArtifactId = "art_passage_s1",
                AcceptedVersion = 1,
                AcceptedHash = "a1b2c3d4e5f60000a1b2c3d4e5f60000a1b2c3d4e5f60000a1b2c3d4e5f60000",
                UpdatedAt = DateTime.UtcNow
            });
            await db.SaveChangesAsync();

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
            NullLogger<ReadingPaperWorker>.Instance
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
            Assert.Equal("a1b2c3d4e5f60000a1b2c3d4e5f60000a1b2c3d4e5f60000a1b2c3d4e5f60000", resumeRec.PassageHash);
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
