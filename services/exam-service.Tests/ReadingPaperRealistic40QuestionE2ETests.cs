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

    private static List<ReadingGeneratedSection> DeserializeSectionsFromFixture()
    {
        using var doc = LoadCanonicalFixtureDocument();
        var root = doc.RootElement;
        var sectionsArray = root.GetProperty("sections");

        var result = new List<ReadingGeneratedSection>();
        foreach (var secElem in sectionsArray.EnumerateArray())
        {
            var sec = CheckpointService.ParseCanonicalV2Section(secElem);
            Assert.NotNull(sec);
            result.Add(sec);
        }
        return result;
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
    public async Task C5_Through_C15_FullPaperCrossServiceE2E_PersistenceAndGrading()
    {
        // C5 & C6: Canonical Python serialization -> .NET contract deserialization
        var generatedSections = DeserializeSectionsFromFixture();
        Assert.Equal(3, generatedSections.Count);

        var options = CreateOptions();
        await using var db = new ExamDbContext(options);

        // Setup durable job and run in isolated PostgreSQL
        var jobId = Guid.NewGuid();
        var runId = $"e2e-run-{Guid.NewGuid():N}";
        var leaseOwner = Guid.NewGuid();
        var leaseUntil = DateTime.UtcNow.AddMinutes(15);
        var epoch = 1;

        var job = new ReadingPaperJob
        {
            Id = jobId,
            Topic = "Wetland Agriculture, Marine Stoichiometry, and Exoplanet Spectroscopy",
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

        // C12: Malformed answer submission is safely rejected with 0 points
        var firstQKey = compiledKeys.Keys[persistedQuestions[0].Id];
        var malformedResult = graderFactory.Resolve(firstQKey.QuestionType).Grade(new AttemptAnswer(), firstQKey);
        Assert.Equal(0, malformedResult.AwardedPoints);
    }
}
