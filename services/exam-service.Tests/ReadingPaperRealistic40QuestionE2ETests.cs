using System.Net;
using System.Text.Json;
using System.Text.RegularExpressions;
using attempt_service.Domain.Entities;
using attempt_service.Features.Helpers;
using exam_service.Application.Common;
using exam_service.Domains.Entities;
using exam_service.Features.ReadingPaper;
using exam_service.Features.ReadingPaper.Contracts;
using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using QuestionType = Shared.ExamDto.Contracts.Exam.Enums.QuestionType;
using Xunit;

namespace exam_service.Tests;

public sealed class ReadingPaperRealistic40QuestionE2ETests
{
    private const string IsolatedConnection = "Host=localhost;Port=5433;Database=exam-db;Username=exam;Password=exam";

    private static void EnsureDatabaseIsolationSafety(ExamDbContext db)
    {
        var connStr = db.Database.GetConnectionString() ?? "";
        Assert.True(connStr.Contains("5433") || connStr.Contains("exam-db"),
            "Database safety violation: Test must run against isolated test PostgreSQL instance on port 5433.");
    }

    private static string FindCanonicalFixturePath()
    {
        var candidates = new[]
        {
            Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, "../../../../../services/generation-service/tests/fixtures/canonical_40_question_reading_paper.json")),
            Path.GetFullPath("services/generation-service/tests/fixtures/canonical_40_question_reading_paper.json"),
            Path.GetFullPath("../generation-service/tests/fixtures/canonical_40_question_reading_paper.json"),
        };
        foreach (var c in candidates)
        {
            if (File.Exists(c)) return c;
        }
        throw new FileNotFoundException("Could not find canonical_40_question_reading_paper.json in candidates: " + string.Join(", ", candidates));
    }

    private static JsonDocument LoadCanonicalFixtureDocument()
    {
        var path = FindCanonicalFixturePath();
        var json = File.ReadAllText(path);
        return JsonDocument.Parse(json);
    }

    private static string FindCanonicalAcceptanceBundlePath()
    {
        var candidates = new[]
        {
            Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, "../../../../../services/generation-service/tests/fixtures/canonical_40_question_acceptance_bundle.json")),
            Path.GetFullPath("services/generation-service/tests/fixtures/canonical_40_question_acceptance_bundle.json"),
            Path.GetFullPath("../generation-service/tests/fixtures/canonical_40_question_acceptance_bundle.json"),
        };
        foreach (var c in candidates)
        {
            if (File.Exists(c)) return c;
        }
        throw new FileNotFoundException("Could not find canonical_40_question_acceptance_bundle.json in candidates: " + string.Join(", ", candidates));
    }

    private static (List<ArtifactEnvelope> Envelopes, List<EvaluationResult> Evaluations, List<ReadingGeneratedSection> Sections) LoadAcceptanceBundle()
    {
        var path = FindCanonicalAcceptanceBundlePath();
        var json = File.ReadAllText(path);
        using var doc = JsonDocument.Parse(json);
        var root = doc.RootElement;

        var envelopes = JsonSerializer.Deserialize<List<ArtifactEnvelope>>(root.GetProperty("envelopes").GetRawText(), LoopEngineJson.Options)
            ?? throw new InvalidOperationException("Failed to deserialize envelopes from acceptance bundle");

        var evaluations = JsonSerializer.Deserialize<List<EvaluationResult>>(root.GetProperty("evaluations").GetRawText(), LoopEngineJson.Options)
            ?? throw new InvalidOperationException("Failed to deserialize evaluations from acceptance bundle");

        var sections = new List<ReadingGeneratedSection>();
        foreach (var secElem in root.GetProperty("sections").EnumerateArray())
        {
            var sec = CheckpointService.ParseCanonicalV2Section(secElem);
            Assert.NotNull(sec);
            sections.Add(sec);
        }

        return (envelopes, evaluations, sections);
    }

    private static DbContextOptions<ExamDbContext> CreateOptions()
    {
        return new DbContextOptionsBuilder<ExamDbContext>()
            .UseNpgsql(IsolatedConnection, npg =>
            {
                npg.ConfigureDataSource(ds => ds.EnableDynamicJson());
                npg.EnableRetryOnFailure();
            })
            .Options;
    }

    private static async Task<(ArtifactEnvelope PaperEnvelope, List<EvaluationResult> ValidEvaluations)> SeedFullAcceptedPaperGraphAsync(
        ExamDbContext db, ReadingPaperRun run, List<ReadingGeneratedSection> sections)
    {
        var runId = run.RunId;
        var (bundleEnvelopes, realEvaluations, _) = LoadAcceptanceBundle();
        Assert.NotEmpty(bundleEnvelopes);
        Assert.NotEmpty(realEvaluations);

        var sources = sections.Select(s => s.Source).ToList();
        run.SourceRevisionsJson = JsonSerializer.Serialize(sources, ReadingPaperRules.Json);
        await db.SaveChangesAsync();

        ArtifactEnvelope? paperEnv = null;

        foreach (var original in bundleEnvelopes)
        {
            var env = original with { RunId = runId };
            if (env.ArtifactType == ArtifactType.ReadingPaper)
            {
                paperEnv = env;
            }

            db.ReadingPaperArtifacts.Add(new ReadingPaperArtifact
            {
                Id = Guid.NewGuid(),
                RunId = runId,
                ArtifactId = env.ArtifactId,
                ArtifactType = env.ArtifactType.ToString(),
                Version = env.Version,
                ContentHash = env.ContentHash,
                PayloadJson = env.Payload.GetRawText(),
                ParentRefsJson = JsonSerializer.Serialize(env.ParentRefs, LoopEngineJson.Options),
                EnvelopeJson = JsonSerializer.Serialize(env, LoopEngineJson.Options),
                CreatedAt = env.CreatedAt
            });

            db.ReadingPaperArtifactHeads.Add(new ReadingPaperArtifactHead
            {
                Id = Guid.NewGuid(),
                RunId = runId,
                ArtifactId = env.ArtifactId,
                AcceptedVersion = env.Version,
                AcceptedHash = env.ContentHash,
                UpdatedAt = env.CreatedAt
            });
        }

        Assert.NotNull(paperEnv);

        foreach (var ev in realEvaluations)
        {
            db.ReadingPaperEvaluations.Add(new ReadingPaperEvaluation
            {
                Id = Guid.NewGuid(),
                RunId = runId,
                EvaluationId = ev.EvaluationId,
                EvaluatorId = ev.EvaluatorId,
                EvaluatorVersion = ev.EvaluatorVersion,
                TargetArtifactId = ev.TargetRef.ArtifactId,
                TargetVersion = ev.TargetRef.Version,
                TargetContentHash = ev.TargetRef.ContentHash,
                Status = ev.Status.ToString(),
                IsPass = ev.IsPass,
                PayloadJson = JsonSerializer.Serialize(ev, LoopEngineJson.Options),
                CreatedAt = ev.EvaluatedAt
            });
        }

        await db.SaveChangesAsync();

        return (paperEnv, realEvaluations);
    }

    [Fact]
    public void C1_Through_C4_VerifyCanonicalFixtureContract()
    {
        using var doc = LoadCanonicalFixtureDocument();
        var root = doc.RootElement;

        // C1: Three passages and word-count compliance
        var sections = root.GetProperty("sections").EnumerateArray().ToList();
        Assert.Equal(3, sections.Count);

        var wordsRegex = new Regex(@"\b[\w'-]+\b", RegexOptions.Compiled);
        var totalWords = 0;
        var qNumbers = new List<int>();

        for (var i = 0; i < sections.Count; i++)
        {
            var sec = sections[i];
            var passage = sec.GetProperty("passage").GetString()!;
            var wc = wordsRegex.Matches(passage).Count;
            totalWords += wc;

            // Section passage word count in valid range [720, 915]
            Assert.InRange(wc, 720, 915);

            // C3 & C4: Verify groups and questions
            var groups = sec.GetProperty("groups").EnumerateArray().ToList();
            Assert.NotEmpty(groups);

            foreach (var g in groups)
            {
                var qType = g.GetProperty("questionType").GetString()!;
                Assert.True(ReadingPaperRules.KnownQuestionFamilies.Contains(qType), $"Unknown family {qType}");

                var questions = g.GetProperty("questions").EnumerateArray().ToList();
                Assert.NotEmpty(questions);

                foreach (var q in questions)
                {
                    var qNum = q.GetProperty("questionNumber").GetInt32();
                    qNumbers.Add(qNum);

                    var answer = q.GetProperty("answer").GetString();
                    Assert.False(string.IsNullOrWhiteSpace(answer), $"Question {qNum} answer is empty");

                    var evidenceQuote = q.TryGetProperty("evidenceQuote", out var eq) ? eq.GetString() : null;
                    if (!string.IsNullOrWhiteSpace(evidenceQuote) && !answer.Contains("NOT_GIVEN", StringComparison.OrdinalIgnoreCase))
                    {
                        Assert.Contains(evidenceQuote.Trim(), passage, StringComparison.OrdinalIgnoreCase);
                    }
                }
            }
        }

        // C1: Total paper words in [2150, 2750]
        Assert.InRange(totalWords, 2150, 2750);

        // C2: Exactly 40 questions, numbered 1..40 continuously
        Assert.Equal(40, qNumbers.Count);
        Assert.Equal(Enumerable.Range(1, 40), qNumbers);
    }

    [Fact]
    public void D1_Through_D6_VerifyScholarlyProvenanceAndNegativeGates()
    {
        using var doc = LoadCanonicalFixtureDocument();
        var root = doc.RootElement;
        var sections = root.GetProperty("sections").EnumerateArray().ToList();
        Assert.Equal(3, sections.Count);

        // D1: Verify Section 1 Scholarly Source (PMC13654891, Iron Smelting at Didé West 1)
        var s1Source = sections[0].GetProperty("source");
        Assert.Equal("PMC13654891", s1Source.GetProperty("pmcid").GetString());
        Assert.Contains("Didé West 1", s1Source.GetProperty("title").GetString()!);
        Assert.Equal("10.1007/s10437-026-09653-z", s1Source.GetProperty("doi").GetString());
        Assert.Contains("Morel", s1Source.GetProperty("authors").GetString()!);
        Assert.Equal("CC BY 4.0", s1Source.GetProperty("license").GetString());

        // D1: Verify Section 2 Scholarly Source (PMC13667678, Combined Wind-Rain Harvester)
        var s2Source = sections[1].GetProperty("source");
        Assert.Equal("PMC13667678", s2Source.GetProperty("pmcid").GetString());
        Assert.Contains("Piezoelectric Energy Harvester", s2Source.GetProperty("title").GetString()!);
        Assert.Equal("10.3390/s26196271", s2Source.GetProperty("doi").GetString());
        Assert.Contains("Chen", s2Source.GetProperty("authors").GetString()!);
        Assert.Equal("CC BY 4.0", s2Source.GetProperty("license").GetString());

        // D1: Verify Section 3 Scholarly Source (PMC13665993, Bedrock Erodibility and CO2 release)
        var s3Source = sections[2].GetProperty("source");
        Assert.Equal("PMC13665993", s3Source.GetProperty("pmcid").GetString());
        Assert.Contains("Bedrock erodibility", s3Source.GetProperty("title").GetString()!);
        Assert.Contains("release in alpine landscapes", s3Source.GetProperty("title").GetString()!);
        Assert.Equal("10.1126/sciadv.aei9275", s3Source.GetProperty("doi").GetString());
        Assert.Contains("Marder", s3Source.GetProperty("authors").GetString()!);
        Assert.Equal("CC BY-NC 4.0", s3Source.GetProperty("license").GetString());
        Assert.True(s3Source.GetProperty("licenseCleared").GetBoolean());

        // D5: Verify Visual SVG Assets for FLOW_CHART and DIAGRAM_LABEL
        var s1Groups = sections[0].GetProperty("groups").EnumerateArray().ToList();
        var flowChartGroup = s1Groups.Single(g => g.GetProperty("questionType").GetString() == "FLOW_CHART");
        var flowSvg = flowChartGroup.TryGetProperty("svgXml", out var fsvg) ? fsvg.GetString() : null;
        Assert.False(string.IsNullOrWhiteSpace(flowSvg), "FLOW_CHART group must provide svgXml");
        Assert.Contains("<svg", flowSvg);
        Assert.Contains("viewBox", flowSvg);
        Assert.Contains("data-callout-id=\"10\"", flowSvg);
        Assert.Contains("data-callout-id=\"13\"", flowSvg);

        var s2Groups = sections[1].GetProperty("groups").EnumerateArray().ToList();
        var diagramGroup = s2Groups.Single(g => g.GetProperty("questionType").GetString() == "DIAGRAM_LABEL");
        var diagramSvg = diagramGroup.TryGetProperty("svgXml", out var dsvg) ? dsvg.GetString() : null;
        Assert.False(string.IsNullOrWhiteSpace(diagramSvg), "DIAGRAM_LABEL group must provide svgXml");
        Assert.Contains("<svg", diagramSvg);
        Assert.Contains("viewBox", diagramSvg);
        Assert.Contains("data-callout-id=\"14\"", diagramSvg);
        Assert.Contains("data-callout-id=\"17\"", diagramSvg);

        // Verify DIAGRAM_LABEL answers are physical component labels, not adverbs
        var diagramQuestions = diagramGroup.GetProperty("questions").EnumerateArray().ToList();
        foreach (var dq in diagramQuestions)
        {
            var ans = dq.GetProperty("answer").GetString()!;
            Assert.False(string.Equals(ans, "conversely", StringComparison.OrdinalIgnoreCase),
                "DIAGRAM_LABEL answer must not be the placeholder 'conversely'");
            Assert.True(ans.Length >= 5, "DIAGRAM_LABEL answer must be a valid component label");
        }
    }

    [Fact]
    public async Task C5_Through_C15_FullPaperCrossServiceE2E_PersistenceAndGrading()
    {
        // C5 & C6: Canonical Python serialization -> .NET contract deserialization
        var (_, _, generatedSections) = LoadAcceptanceBundle();
        Assert.Equal(3, generatedSections.Count);

        var options = CreateOptions();
        await using var db = new ExamDbContext(options);
        EnsureDatabaseIsolationSafety(db);

        // Setup durable job and run in isolated PostgreSQL
        var jobId = Guid.NewGuid();
        var runId = $"e2e-run-{Guid.NewGuid():N}";
        var leaseOwner = Guid.NewGuid();
        var leaseUntil = DateTime.UtcNow.AddMinutes(15);
        var epoch = 1;

        var job = new ReadingPaperJob
        {
            Id = jobId,
            Topic = "Ancient Metallurgy, Wind-Rain Energy Harvesting, and Bedrock Erodibility",
            Status = "Running",
            ActiveRunId = runId,
            Epoch = epoch,
            CancelVersion = 0,
            LeaseOwner = leaseOwner,
            LeaseUntil = leaseUntil,
            SectionsJson = JsonSerializer.Serialize(generatedSections, ReadingPaperRules.Json),
            CompletedSections = 3,
            CreatedAt = DateTime.UtcNow.AddMinutes(-5),
            UpdatedAt = DateTime.UtcNow,
            Logs = "Initial job seed for full 40q E2E",
        };
        db.ReadingPaperJobs.Add(job);

        var run = new ReadingPaperRun
        {
            RunId = runId,
            JobId = jobId,
            Epoch = epoch,
            Status = "RUNNING",
            LeaseOwner = leaseOwner,
            LeaseUntil = leaseUntil,
            EngineVersion = "2.0.0",
            PolicyVersion = "2.0.0",
            CreatedAt = DateTime.UtcNow.AddMinutes(-5),
            UpdatedAt = DateTime.UtcNow,
        };
        db.ReadingPaperRuns.Add(run);
        await db.SaveChangesAsync();

        // Seed full accepted paper graph and valid evaluations in V2 durable persistence
        var (_, validEvaluations) = await SeedFullAcceptedPaperGraphAsync(db, run, generatedSections);

        // C7: Exam publication through real application logic (BuildExamIdempotentAsync)
        var buildReq = new BuildExamInternalRequest(
            JobId: jobId,
            RunId: runId,
            Epoch: epoch,
            LeaseOwner: leaseOwner,
            FinalEvaluations: validEvaluations
        );

        var buildResult = await CheckpointService.BuildExamIdempotentAsync(db, buildReq, CancellationToken.None);
        Assert.NotNull(buildResult);
        var examId = buildResult.ExamId;
        Assert.NotEqual(Guid.Empty, examId);

        // C8 & C14: Database persistence and reload
        db.ChangeTracker.Clear();
        var reloadedExam = await db.Exams.AsNoTracking()
            .Include(e => e.Sections)
                .ThenInclude(s => s.Questions)
                    .ThenInclude(q => q.Options)
            .Include(e => e.Sections)
                .ThenInclude(s => s.QuestionGroups)
                    .ThenInclude(g => g.Questions)
                        .ThenInclude(q => q.Options)
            .SingleAsync(e => e.Id == examId);

        Assert.Equal(3, reloadedExam.Sections.Count);
        var persistedQuestions = reloadedExam.Sections
            .SelectMany(s => s.QuestionGroups)
            .SelectMany(g => g.Questions)
            .OrderBy(q => q.Idx)
            .ToList();

        Assert.Equal(40, persistedQuestions.Count);
        Assert.Equal(Enumerable.Range(1, 40), persistedQuestions.Select(q => q.Idx));

        // C13: Repeated publication is idempotent
        var replayResult = await CheckpointService.BuildExamIdempotentAsync(db, buildReq, CancellationToken.None);
        Assert.Equal(examId, replayResult.ExamId);
        Assert.Equal(reloadedExam.Slug, replayResult.Slug);

        // C9 & C10 & C11: Project to gRPC proto and grade via attempt-service QuestionGraderFactory
        var protoExam = ProtoHelper.MapToProto(reloadedExam, showAnswers: true);
        var answerKeyBuilder = new AnswerKeyBuilder(new AnswerValidator());
        var compiledKeys = answerKeyBuilder.FromProto(protoExam);

        var graderRegistrations = new IQuestionGraderRegistration[]
        {
            new SingleChoiceGraderRegistration(new SingleChoiceGrader()),
            new MultipleChoiceGraderRegistration(new MultipleChoiceGrader()),
            new CompletionGraderRegistration(new CompletionGrader()),
            new LabelGraderRegistration(new LabelGrader()),
            new MatchingHeadingGraderRegistration(new MatchingHeadingGrader()),
            new FlowChartGraderRegistration(new FlowChartGrader()),
            new ShortAnswerGraderRegistration(new ShortAnswerGrader()),
        };
        var graderFactory = new QuestionGraderFactory(graderRegistrations);

        foreach (var q in persistedQuestions)
        {
            Assert.True(compiledKeys.Keys.TryGetValue(q.Id, out var qKey), $"Missing compiled key for question {q.Idx} ({q.Id})");
            var grader = graderFactory.Resolve(qKey.QuestionType);

            AttemptAnswer correctAnswer;
            AttemptAnswer incorrectAnswer;

            if (qKey.QuestionType == QuestionType.FlowChart)
            {
                var steps = qKey.OrderCorrects ?? [$"step-{q.Idx}"];
                var labels = qKey.BlankAcceptTexts?.ToDictionary(k => k.Key, k => k.Value?.FirstOrDefault() ?? "") ?? new Dictionary<string, string>();
                correctAnswer = new AttemptAnswer
                {
                    TextAnswer = JsonSerializer.Serialize(new { Steps = steps, Labels = labels })
                };
                incorrectAnswer = new AttemptAnswer
                {
                    TextAnswer = JsonSerializer.Serialize(new { Steps = new[] { "wrong-step" }, Labels = new Dictionary<string, string>() })
                };
            }
            else if (qKey.QuestionType == QuestionType.DiagramLabel || qKey.QuestionType == QuestionType.MapLabel)
            {
                var labelAns = qKey.BlankAcceptTexts?.Values.FirstOrDefault()?.FirstOrDefault() ?? "test_label";
                correctAnswer = new AttemptAnswer
                {
                    TextAnswer = labelAns
                };
                incorrectAnswer = new AttemptAnswer
                {
                    TextAnswer = "wrong_diagram_label_xyz"
                };
            }
            else if (qKey.CorrectOptionIds != null && qKey.CorrectOptionIds.Count > 0)
            {
                var correctOpt = qKey.CorrectOptionIds.First();
                correctAnswer = new AttemptAnswer
                {
                    SelectedOptionIds = [correctOpt.id]
                };
                incorrectAnswer = new AttemptAnswer
                {
                    SelectedOptionIds = [Guid.NewGuid()]
                };
            }
            else if (qKey.MatchPairs != null && qKey.MatchPairs.Count > 0)
            {
                var correctMatches = qKey.MatchPairs.ToDictionary(
                    kv => kv.Key,
                    kv => kv.Value?.FirstOrDefault() ?? ""
                );
                var matchPayload = JsonSerializer.Serialize(correctMatches);
                correctAnswer = new AttemptAnswer
                {
                    TextAnswer = matchPayload
                };
                incorrectAnswer = new AttemptAnswer
                {
                    TextAnswer = JsonSerializer.Serialize(qKey.MatchPairs.ToDictionary(kv => kv.Key, _ => "WRONG_HEADING_VALUE_999"))
                };
            }
            else if (qKey.BlankAcceptTexts != null && qKey.BlankAcceptTexts.Count > 0)
            {
                var correctBlanks = qKey.BlankAcceptTexts.ToDictionary(
                    kv => kv.Key,
                    kv => kv.Value?.FirstOrDefault() ?? ""
                );
                var firstText = correctBlanks.Values.FirstOrDefault() ?? "test";
                var blankPayload = correctBlanks.Count == 1 ? firstText : JsonSerializer.Serialize(correctBlanks);
                correctAnswer = new AttemptAnswer
                {
                    TextAnswer = blankPayload
                };
                incorrectAnswer = new AttemptAnswer
                {
                    TextAnswer = correctBlanks.Count == 1 ? "completely_wrong_answer_xyz" : JsonSerializer.Serialize(qKey.BlankAcceptTexts.ToDictionary(kv => kv.Key, _ => "wrong_val_xyz"))
                };
            }
            else
            {
                var shortAns = qKey.ShortAnswerAcceptTexts?.FirstOrDefault() ?? "answer";
                correctAnswer = new AttemptAnswer { TextAnswer = shortAns };
                incorrectAnswer = new AttemptAnswer { TextAnswer = "definitely_wrong_xyz" };
            }

            // C9: Correct answers receive positive points
            var gradePass = grader.Grade(correctAnswer, qKey);
            Assert.True(gradePass.AwardedPoints > 0, $"Question {q.Idx} ({qKey.QuestionType}) correct answer awarded 0 points. Feedback: {gradePass.Feedback}");

            // C10: Incorrect answers receive 0 points
            var gradeFail = grader.Grade(incorrectAnswer, qKey);
            Assert.Equal(0, gradeFail.AwardedPoints);
        }

        // C12 / B14: Malformed answer submission is safely rejected with 0 points
        var firstQKey = compiledKeys.Keys[persistedQuestions[0].Id];
        var malformedResult = graderFactory.Resolve(firstQKey.QuestionType).Grade(new AttemptAnswer(), firstQKey);
        Assert.Equal(0, malformedResult.AwardedPoints);
    }

    private static async Task<(ReadingPaperRun Run, ReadingPaperJob Job, ArtifactEnvelope PaperEnv, List<EvaluationResult> ValidEvaluations)> SetupTestPaperRunAsync(
        ExamDbContext db, string testName)
    {
        var (_, _, generatedSections) = LoadAcceptanceBundle();
        var jobId = Guid.NewGuid();
        var runId = $"e2e-run-{testName.ToLowerInvariant()}-{Guid.NewGuid():N}";
        var leaseOwner = Guid.NewGuid();
        var leaseUntil = DateTime.UtcNow.AddMinutes(15);
        var epoch = 1;

        var job = new ReadingPaperJob
        {
            Id = jobId,
            Topic = $"Test {testName}",
            Status = "Running",
            ActiveRunId = runId,
            Epoch = epoch,
            CancelVersion = 0,
            LeaseOwner = leaseOwner,
            LeaseUntil = leaseUntil,
            SectionsJson = JsonSerializer.Serialize(generatedSections, ReadingPaperRules.Json),
            CompletedSections = 3,
            CreatedAt = DateTime.UtcNow.AddMinutes(-5),
            UpdatedAt = DateTime.UtcNow,
            Logs = $"Seed for {testName}",
        };
        db.ReadingPaperJobs.Add(job);

        var run = new ReadingPaperRun
        {
            RunId = runId,
            JobId = jobId,
            Epoch = epoch,
            Status = "RUNNING",
            LeaseOwner = leaseOwner,
            LeaseUntil = leaseUntil,
            EngineVersion = "2.0.0",
            PolicyVersion = "2.0.0",
            CreatedAt = DateTime.UtcNow.AddMinutes(-5),
            UpdatedAt = DateTime.UtcNow,
        };
        db.ReadingPaperRuns.Add(run);
        await db.SaveChangesAsync();

        var (paperEnv, validEvaluations) = await SeedFullAcceptedPaperGraphAsync(db, run, generatedSections);
        return (run, job, paperEnv, validEvaluations);
    }

    [Fact]
    public async Task B2_MissingRequiredEvaluator_BlocksPublication()
    {
        var options = CreateOptions();
        await using var db = new ExamDbContext(options);
        EnsureDatabaseIsolationSafety(db);

        var (run, job, _, validEvaluations) = await SetupTestPaperRunAsync(db, "b2");

        // Omit required evaluator eval_paper_structure
        var missingEvalList = validEvaluations.Where(e => e.EvaluatorId != "eval_paper_structure").ToList();

        var ex = await Assert.ThrowsAsync<CheckpointValidationException>(() =>
            ReadingPaperFinalSnapshot.LoadAsync(db, run, job, missingEvalList, CancellationToken.None));
        Assert.Contains("Required fresh paper evaluation rejected: eval_paper_structure", ex.Message);
    }

    [Fact]
    public async Task B3_FailEvaluator_BlocksPublication()
    {
        var options = CreateOptions();
        await using var db = new ExamDbContext(options);
        EnsureDatabaseIsolationSafety(db);

        var (run, job, _, validEvaluations) = await SetupTestPaperRunAsync(db, "b3");

        // Mutate one evaluation to FAIL
        var failedList = validEvaluations.Select(e =>
            e.EvaluatorId == "eval_paper_monotony" ? e with { Status = EvaluationStatus.FAIL } : e).ToList();

        var ex = await Assert.ThrowsAsync<CheckpointValidationException>(() =>
            ReadingPaperFinalSnapshot.LoadAsync(db, run, job, failedList, CancellationToken.None));
        Assert.Contains("Required fresh paper evaluation rejected: eval_paper_monotony", ex.Message);
    }

    [Fact]
    public async Task B4_WrongEvaluatorVersion_BlocksPublication()
    {
        var options = CreateOptions();
        await using var db = new ExamDbContext(options);
        EnsureDatabaseIsolationSafety(db);

        var (run, job, _, validEvaluations) = await SetupTestPaperRunAsync(db, "b4");

        // Mutate eval_paper_leakage version from 2.1.0 to 1.0.0
        var wrongVersionList = validEvaluations.Select(e =>
            e.EvaluatorId == "eval_paper_leakage" ? e with { EvaluatorVersion = "1.0.0" } : e).ToList();

        var ex = await Assert.ThrowsAsync<CheckpointValidationException>(() =>
            ReadingPaperFinalSnapshot.LoadAsync(db, run, job, wrongVersionList, CancellationToken.None));
        Assert.Contains("Required fresh paper evaluation rejected: eval_paper_leakage", ex.Message);
    }

    [Fact]
    public async Task B5_WrongTargetRefHash_BlocksPublication()
    {
        var options = CreateOptions();
        await using var db = new ExamDbContext(options);
        EnsureDatabaseIsolationSafety(db);

        var (run, job, _, validEvaluations) = await SetupTestPaperRunAsync(db, "b5");

        // Mutate TargetRef content hash
        var corruptedTargetList = validEvaluations.Select(e =>
            e with { TargetRef = e.TargetRef with { ContentHash = new string('a', 64) } }).ToList();

        var ex = await Assert.ThrowsAsync<CheckpointValidationException>(() =>
            ReadingPaperFinalSnapshot.LoadAsync(db, run, job, corruptedTargetList, CancellationToken.None));
        Assert.Contains("Required fresh paper evaluation rejected", ex.Message);
    }

    [Fact]
    public async Task B6_ChangedParentDependency_BlocksPublication()
    {
        var options = CreateOptions();
        await using var db = new ExamDbContext(options);
        EnsureDatabaseIsolationSafety(db);

        var (run, job, _, validEvaluations) = await SetupTestPaperRunAsync(db, "b6");

        // Mutate InputDependencyRefs to omit dependencies
        var changedDepsList = validEvaluations.Select(e =>
            e with { InputDependencyRefs = e.InputDependencyRefs.Take(10).ToList() }).ToList();

        var ex = await Assert.ThrowsAsync<CheckpointValidationException>(() =>
            ReadingPaperFinalSnapshot.LoadAsync(db, run, job, changedDepsList, CancellationToken.None));
        Assert.Contains("dependency closure mismatch", ex.Message);
    }

    [Fact]
    public async Task B7_StaleEvaluation_BlocksPublication()
    {
        var options = CreateOptions();
        await using var db = new ExamDbContext(options);
        EnsureDatabaseIsolationSafety(db);

        var (run, job, paperEnv, validEvaluations) = await SetupTestPaperRunAsync(db, "b7");

        // Stale timestamp: earlier than paper.CreatedAt - EvaluationBackwardJitter
        var staleList = validEvaluations.Select(e =>
            e with { EvaluatedAt = paperEnv.CreatedAt.AddHours(-1) }).ToList();

        var ex = await Assert.ThrowsAsync<CheckpointValidationException>(() =>
            ReadingPaperFinalSnapshot.LoadAsync(db, run, job, staleList, CancellationToken.None));
        Assert.Contains("Required fresh paper evaluation rejected", ex.Message);
    }

    [Fact]
    public async Task B8_OpenCriticalMajorIssue_BlocksPublication()
    {
        var options = CreateOptions();
        await using var db = new ExamDbContext(options);
        EnsureDatabaseIsolationSafety(db);

        var (run, job, _, validEvaluations) = await SetupTestPaperRunAsync(db, "b8");

        // Inject open CRITICAL issue
        var blockedList = validEvaluations.Select(e =>
            e.EvaluatorId == "eval_paper_structure"
                ? e with
                {
                    Issues = [
                        new Issue(
                            "iss_test_b8",
                            IssueCode.SCHEMA_VIOLATION,
                            IssueSeverity.CRITICAL,
                            IssueScope.PAPER,
                            [],
                            "Unresolved structural defect",
                            null,
                            null,
                            IssueStatus.OPEN,
                            "fp_test_b8",
                            DateTime.UtcNow,
                            null
                        )
                    ]
                }
                : e).ToList();

        var ex = await Assert.ThrowsAsync<CheckpointValidationException>(() =>
            ReadingPaperFinalSnapshot.LoadAsync(db, run, job, blockedList, CancellationToken.None));
        Assert.Contains("Required fresh paper evaluation rejected: eval_paper_structure", ex.Message);
    }

    [Fact]
    public async Task B9_TamperedEnvelopePayload_BlocksPublication()
    {
        var options = CreateOptions();
        await using var db = new ExamDbContext(options);
        EnsureDatabaseIsolationSafety(db);

        var (run, job, paperEnv, validEvaluations) = await SetupTestPaperRunAsync(db, "b9");

        // Tamper with paper envelope payload in database
        var paperArtifact = await db.ReadingPaperArtifacts.SingleAsync(a => a.RunId == run.RunId && a.ArtifactId == paperEnv.ArtifactId);
        var tamperedPayload = JsonDocument.Parse("{\"tampered\": true, \"title\": \"Hacked Paper\"}").RootElement;
        var tamperedEnv = paperEnv with { Payload = tamperedPayload };
        paperArtifact.EnvelopeJson = JsonSerializer.Serialize(tamperedEnv, LoopEngineJson.Options);
        paperArtifact.PayloadJson = tamperedPayload.GetRawText();
        await db.SaveChangesAsync();

        var ex = await Assert.ThrowsAsync<CheckpointValidationException>(() =>
            ReadingPaperFinalSnapshot.LoadAsync(db, run, job, validEvaluations, CancellationToken.None));
        Assert.Contains("Authoritative envelope identity or hash mismatch", ex.Message);
    }
}
