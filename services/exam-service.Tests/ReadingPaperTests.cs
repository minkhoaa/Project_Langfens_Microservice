using System.Text.Json;
using exam_service.Domains.Entities;
using attempt_service.Domain.Entities;
using attempt_service.Features.Helpers;
using exam_service.Features.ReadingPaper;
using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts.Exam.Enums;
using Xunit;

namespace exam_service.Tests;

public class ReadingPaperTests
{
    private const string Sentence = "Scientists found species in the forest and measured changes over time. ";
    private static readonly string[] Filler = [
        "Researchers observed seasonal migration patterns through coastal woodlands and nearby wetlands. ",
        "Oceanographers documented coral recovery after storms across several tropical reef sites. ",
        "Engineers compared energy storage methods used by remote mountain communities worldwide. "
    ];

    internal static List<ReadingGeneratedSection> Paper()
    {
        var sections = new List<ReadingGeneratedSection>();
        var number = 1;
        for (var i = 0; i < 3; i++)
        {
            var groups = new List<ReadingGeneratedGroup>();
            for (var g = 0; g < 2; g++)
            {
                var kind = ReadingPaperRules.Types[i][g];
                var questions = new List<ReadingGeneratedQuestion>();
                for (var k = 0; k < ReadingPaperRules.Counts[i][g]; k++)
                {
                    var options = kind switch
                    {
                        "TRUE_FALSE_NOT_GIVEN" => new List<string> { "TRUE", "FALSE", "NOT GIVEN" },
                        "YES_NO_NOT_GIVEN" => ["YES", "NO", "NOT GIVEN"],
                        "MULTIPLE_CHOICE_SINGLE" => ["A. species", "B. ocean", "C. desert", "D. river"],
                        _ => []
                    };
                    var prompt = kind is "SENTENCE_COMPLETION" or "SUMMARY_COMPLETION"
                        ? $"Scientists observed [{number}] in study {number}."
                        : $"What did scientists observe in study {number}?";
                    questions.Add(new ReadingGeneratedQuestion(number, prompt,
                        options.Count > 0 ? options[0] : "species", options,
                        "Scientists found species in the forest",
                        "The passage states that scientists found species in the forest."));
                    number++;
                }
                groups.Add(new ReadingGeneratedGroup(kind, "Answer each question", questions));
            }
            sections.Add(new ReadingGeneratedSection($"Passage {i + 1}", Sentence + string.Concat(Enumerable.Repeat(Filler[i], 70)),
                new ReadingSource($"PMC{i + 1}", $"Source {i + 1}", $"10.1/{i + 1}",
                    $"https://europepmc.org/articles/PMC{i + 1}", "https://creativecommons.org/licenses/by/4.0", 2000), groups));
        }
        return sections;
    }

    [Fact]
    public void BuildExamStores40IndividuallyScoredQuestionsAndSources()
    {
        var job = new ReadingPaperJob { Id = Guid.NewGuid(), Topic = "forest ecology" };
        var exam = ReadingPaperWorker.BuildExam(job, Paper());
        Assert.Equal(ExamStatus.Draft, exam.Status);
        Assert.Equal(60, exam.DurationMin);
        Assert.Equal(3, exam.Sections.Count);
        Assert.Equal(40, exam.Sections.Sum(s => s.Questions.Count));
        Assert.Equal(Enumerable.Range(1, 40), exam.Sections.SelectMany(s => s.Questions).Select(q => q.Idx));
        Assert.All(exam.Sections, s => Assert.Equal(2, s.QuestionGroups.Count));
        Assert.All(exam.Sections, s => Assert.NotNull(s.SourceLicense));
        Assert.All(exam.Sections.SelectMany(s => s.Questions).Where(q => q.Options.Count > 0),
            q => Assert.Single(q.Options, o => o.IsCorrect));
        Assert.All(exam.Sections.SelectMany(s => s.Questions).Where(q => q.Type is "SENTENCE_COMPLETION" or "SUMMARY_COMPLETION"),
            q => Assert.Single(q.BlankAcceptTexts!));
        Assert.All(exam.Sections.SelectMany(s => s.Questions).Where(q => q.Type == "SHORT_ANSWER"),
            q => Assert.Single(q.ShortAnswerAcceptTexts!));
    }

    [Theory]
    [InlineData(1, 13, 20)]
    [InlineData(2, 26, 40)]
    public void BuildExamSupportsPracticePapersWithSelectedPassageCount(int passages, int questions, int minutes)
    {
        var exam = ReadingPaperWorker.BuildExam(
            new ReadingPaperJob { Id = Guid.NewGuid(), Topic = "forest ecology" },
            Paper().Take(passages).ToList());
        Assert.Equal(ExamStatus.Draft, exam.Status);
        Assert.Equal(passages, exam.Sections.Count);
        Assert.Equal(questions, exam.Sections.Sum(section => section.Questions.Count));
        Assert.Equal(minutes, exam.DurationMin);
        Assert.Contains("Practice", exam.Title);
        Assert.Equal(Enumerable.Range(1, questions), exam.Sections.SelectMany(section => section.Questions).Select(question => question.Idx));
    }

    [Fact]
    public void InvalidAnswerPreventsAnyExamGraph()
    {
        var sections = Paper();
        var first = sections[0].Groups[0].Questions[0];
        sections[0].Groups[0].Questions[0] = first with { Answer = "UNSUPPORTED" };
        Assert.Throws<InvalidOperationException>(() => ReadingPaperWorker.BuildExam(
            new ReadingPaperJob { Topic = "forest" }, sections));
    }

    [Fact]
    public void MissingQuestionOrDuplicateSourceIsRejected()
    {
        var sections = Paper();
        sections[1].Groups[0].Questions.RemoveAt(0);
        Assert.Throws<InvalidOperationException>(() => ReadingPaperRules.Validate(sections));
        sections = Paper();
        sections[1] = sections[1] with { Source = sections[0].Source };
        Assert.Throws<InvalidOperationException>(() => ReadingPaperRules.Validate(sections));
        sections = Paper();
        sections[1] = sections[1] with { Passage = sections[0].Passage };
        Assert.Throws<InvalidOperationException>(() => ReadingPaperRules.Validate(sections));
    }

    [Fact]
    public void EfTracksWholePaperAndDiscoversJobMigration()
    {
        var options = new DbContextOptionsBuilder<ExamDbContext>()
            .UseNpgsql("Host=localhost;Database=unused;Username=unused;Password=unused").Options;
        using var db = new ExamDbContext(options);
        Assert.Contains("20260924120000_AddReadingPaperJobs", db.Database.GetMigrations());
        db.Exams.Add(ReadingPaperWorker.BuildExam(new ReadingPaperJob { Topic = "forest" }, Paper()));
        Assert.Equal(40, db.ChangeTracker.Entries<ExamQuestion>().Count());
        Assert.Equal(6, db.ChangeTracker.Entries<ExamQuestionGroup>().Count());
        Assert.Equal(3, db.ChangeTracker.Entries<ExamSection>().Count());
    }

    [Fact]
    public void GeneratedAnswersAreAcceptedByCurrentAttemptGraders()
    {
        var exam = ReadingPaperWorker.BuildExam(new ReadingPaperJob { Topic = "forest" }, Paper());
        foreach (var question in exam.Sections.SelectMany(s => s.Questions))
        {
            var key = new QuestionKey(question.Id, question.Type, 1,
                question.Options.Where(o => o.IsCorrect).Select(o => (o.Id, o.ContentMd)).ToHashSet(),
                question.BlankAcceptTexts, ShortAnswerAcceptTexts: question.ShortAnswerAcceptTexts);
            var correct = question.Options.FirstOrDefault(o => o.IsCorrect);
            var answer = new AttemptAnswer
            {
                SelectedOptionIds = correct is null ? [] : [correct.Id],
                TextAnswer = question.ShortAnswerAcceptTexts?.FirstOrDefault()
                    ?? question.BlankAcceptTexts?.Values.FirstOrDefault()?.FirstOrDefault()
            };
            IQuestionGrader grader = question.Type switch
            {
                "SENTENCE_COMPLETION" or "SUMMARY_COMPLETION" => new CompletionGrader(),
                "SHORT_ANSWER" => new ShortAnswerGrader(),
                _ => new SingleChoiceGrader()
            };
            Assert.Equal(1, grader.Grade(answer, key).AwardedPoints);
            Assert.Equal(0, grader.Grade(new AttemptAnswer { TextAnswer = "wrong" }, key).AwardedPoints);
        }
    }

    [Fact]
    public void BuildExamSupportsUniversalNonPmcSources()
    {
        var sections = Paper();
        sections[0] = sections[0] with
        {
            Source = new ReadingSource("CUSTOM:abc123", "Custom Text Source", null,
                "local://manual-source", "User Provided", 1200, "Jane Doe",
                SourceType: "text", Metadata: new Dictionary<string, string> { ["format"] = "text" })
        };
        sections[1] = sections[1] with
        {
            Source = new ReadingSource("URL:nature-com", "Nature Ecology Article", null,
                "https://www.nature.com/articles/sample", "Web Public", 1500, "Nature Editorial",
                SourceType: "url", Metadata: new Dictionary<string, string> { ["domain"] = "nature.com" })
        };

        ReadingPaperRules.Validate(sections);

        var job = new ReadingPaperJob { Id = Guid.NewGuid(), Topic = "universal sources" };
        var exam = ReadingPaperWorker.BuildExam(job, sections);

        Assert.Equal(3, exam.Sections.Count);
        Assert.Equal("CUSTOM:abc123", exam.Sections[0].SourcePmcid);
        Assert.Null(exam.Sections[0].SourceDoi);
        Assert.Equal("User Provided", exam.Sections[0].SourceLicense);
        Assert.Equal("URL:nature-com", exam.Sections[1].SourcePmcid);
        Assert.Null(exam.Sections[1].SourceDoi);
        Assert.Equal("Web Public", exam.Sections[1].SourceLicense);
    }

    [Fact]
    public void ReadingJobRequestSupportsDirectSourcesWithoutPmcids()
    {
        var sources = new List<ReadingSource>
        {
            new("CUSTOM:test1", "Title 1", null, "https://example.org/1", "User Provided", 1000,
                Content: "Extracted article content...", ContentPreview: "Extracted article..."),
            new("URL:test2", "Title 2", null, "https://example.org/2", "Web Public", 1200)
        };

        var request = new ReadingJobRequest("Cognitive Linguistics", Sources: sources);
        Assert.Equal("Cognitive Linguistics", request.Topic);
        Assert.Null(request.Pmcids);
        Assert.NotNull(request.Sources);
        Assert.Equal(2, request.Sources.Count);
        Assert.Equal("CUSTOM:test1", request.Sources[0].Pmcid);

        var json = JsonSerializer.Serialize(request, ReadingPaperRules.Json);
        var deserialized = JsonSerializer.Deserialize<ReadingJobRequest>(json, ReadingPaperRules.Json);

        Assert.NotNull(deserialized);
        Assert.Equal("Cognitive Linguistics", deserialized.Topic);
        Assert.Null(deserialized.Pmcids);
        Assert.NotNull(deserialized.Sources);
        Assert.Equal(2, deserialized.Sources.Count);
        Assert.Equal("CUSTOM:test1", deserialized.Sources[0].Pmcid);
        Assert.Equal("User Provided", deserialized.Sources[0].License);
        Assert.Equal("Extracted article content...", deserialized.Sources[0].Content);
        Assert.Equal("Extracted article...", deserialized.Sources[0].ContentPreview);
    }

    [Fact]
    public void ReadingJobRequestBackwardCompatibleWithPmcidsOnly()
    {
        var json = """{"topic":"Artificial Intelligence","pmcids":["PMC1234567","PMC7654321"]}""";
        var request = JsonSerializer.Deserialize<ReadingJobRequest>(json, ReadingPaperRules.Json);

        Assert.NotNull(request);
        Assert.Equal("Artificial Intelligence", request.Topic);
        Assert.NotNull(request.Pmcids);
        Assert.Equal(2, request.Pmcids.Count);
        Assert.Equal("PMC1234567", request.Pmcids[0]);
        Assert.Null(request.Sources);
    }

    [Fact]
    public void NormalizeSections_ValidQuestions_RemainAccepted()
    {
        var sections = Paper();
        var normalized = ReadingPaperWorker.NormalizeSectionsForValidation(sections);

        Assert.Equal(3, normalized.Count);
        Assert.Equal(40, normalized.Sum(s => s.Groups.Sum(g => g.Questions.Count)));
        Assert.Equal("The passage states that scientists found species in the forest.", normalized[0].Groups[0].Questions[0].Explanation);
        Assert.Equal("Scientists found species in the forest", normalized[0].Groups[0].Questions[0].EvidenceQuote);
    }

    [Fact]
    public void NormalizeSections_EmptyOrShortExplanation_IsRejected()
    {
        var sections = Paper();
        var q = sections[0].Groups[0].Questions[0];
        sections[0].Groups[0].Questions[0] = q with { Explanation = "Too short" };

        var ex = Assert.Throws<InvalidOperationException>(() => ReadingPaperWorker.NormalizeSectionsForValidation(sections));
        Assert.Contains("explanation", ex.Message, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public void NormalizeSections_GenericPlaceholderExplanation_IsRejected()
    {
        var sections = Paper();
        var q = sections[0].Groups[0].Questions[0];
        sections[0].Groups[0].Questions[0] = q with { Explanation = "Verified against the reading passage text." };

        var ex = Assert.Throws<InvalidOperationException>(() => ReadingPaperWorker.NormalizeSectionsForValidation(sections));
        Assert.Contains("explanation", ex.Message, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public void NormalizeSections_InvalidEvidenceQuote_IsRejected()
    {
        var sections = Paper();
        var q = sections[0].Groups[0].Questions[0];
        sections[0].Groups[0].Questions[0] = q with { EvidenceQuote = "Invented evidence quote not in passage text" };

        var ex = Assert.Throws<InvalidOperationException>(() => ReadingPaperWorker.NormalizeSectionsForValidation(sections));
        Assert.Contains("evidence quote", ex.Message, StringComparison.OrdinalIgnoreCase);
        Assert.Contains("not found in passage text", ex.Message, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public void NormalizeSections_FabricatedCompletionAnswer_IsRejected()
    {
        var sections = Paper();
        var compGroup = sections[0].Groups[1];
        var q = compGroup.Questions[0];
        compGroup.Questions[0] = q with { Answer = "unmentioned_word" };

        var ex = Assert.Throws<InvalidOperationException>(() => ReadingPaperWorker.NormalizeSectionsForValidation(sections));
        Assert.Contains("completion answer", ex.Message, StringComparison.OrdinalIgnoreCase);
        Assert.Contains("not a verbatim 1–3 word match", ex.Message, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public void NormalizeSections_CompletionAnswerExceedingWordLimit_IsRejected()
    {
        var sections = Paper();
        var compGroup = sections[0].Groups[1];
        var q = compGroup.Questions[0];
        compGroup.Questions[0] = q with { Answer = "four words in answer" };

        var ex = Assert.Throws<InvalidOperationException>(() => ReadingPaperWorker.NormalizeSectionsForValidation(sections));
        Assert.Contains("completion answer", ex.Message, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public void NormalizeSections_GenericExplanationQ1FromRealDemoJson_IsRejected()
    {
        var sections = Paper();
        var q = sections[0].Groups[0].Questions[0];
        sections[0].Groups[0].Questions[0] = q with { Explanation = "Explanation for question 1 based on passage text." };

        var ex = Assert.Throws<InvalidOperationException>(() => ReadingPaperWorker.NormalizeSectionsForValidation(sections));
        Assert.Contains("explanation", ex.Message, StringComparison.OrdinalIgnoreCase);
        Assert.Contains("generic placeholder", ex.Message, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public void NormalizeSections_GenericExplanationQ13FromRealDemoJson_IsRejected()
    {
        var sections = Paper();
        var q = sections[0].Groups[1].Questions[5];
        sections[0].Groups[1].Questions[5] = q with { Explanation = "Explanation for question 13 based on passage text." };

        var ex = Assert.Throws<InvalidOperationException>(() => ReadingPaperWorker.NormalizeSectionsForValidation(sections));
        Assert.Contains("explanation", ex.Message, StringComparison.OrdinalIgnoreCase);
        Assert.Contains("generic placeholder", ex.Message, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public void NormalizeSections_RealExplanatoryText_PassesValidation()
    {
        var sections = Paper();
        var q1 = sections[0].Groups[0].Questions[0];
        sections[0].Groups[0].Questions[0] = q1 with { Explanation = "According to paragraph 2, the Persian Gulf has exceptionally high coastal ALAN density." };
        var q13 = sections[0].Groups[1].Questions[5];
        sections[0].Groups[1].Questions[5] = q13 with { Explanation = "The passage explicitly notes that 1.9 million square kilometers are affected at 1 meter depth." };

        var normalized = ReadingPaperWorker.NormalizeSectionsForValidation(sections);
        Assert.NotNull(normalized);
        Assert.Equal("According to paragraph 2, the Persian Gulf has exceptionally high coastal ALAN density.", normalized[0].Groups[0].Questions[0].Explanation);
        Assert.Equal("The passage explicitly notes that 1.9 million square kilometers are affected at 1 meter depth.", normalized[0].Groups[1].Questions[5].Explanation);
    }

    [Fact]
    public void SectionBlueprint_QuestionNumberingAndTypes_Section2And3()
    {
        // Section 2: Index 2 (0-indexed 1)
        Assert.Equal("MULTIPLE_CHOICE_SINGLE", ReadingPaperRules.Types[1][0]);
        Assert.Equal(6, ReadingPaperRules.Counts[1][0]);
        Assert.Equal("SUMMARY_COMPLETION", ReadingPaperRules.Types[1][1]);
        Assert.Equal(7, ReadingPaperRules.Counts[1][1]);
        Assert.Equal(13, ReadingPaperRules.Counts[1].Sum());

        // Section 3: Index 3 (0-indexed 2)
        Assert.Equal("YES_NO_NOT_GIVEN", ReadingPaperRules.Types[2][0]);
        Assert.Equal(7, ReadingPaperRules.Counts[2][0]);
        Assert.Equal("SHORT_ANSWER", ReadingPaperRules.Types[2][1]);
        Assert.Equal(7, ReadingPaperRules.Counts[2][1]);
        Assert.Equal(14, ReadingPaperRules.Counts[2].Sum());

        // Question numbering continuous across 40 questions
        var paper = Paper();
        Assert.Equal(40, paper.Sum(s => s.Groups.Sum(g => g.Questions.Count)));

        // Section 2 questions: Q14 - Q26
        var sec2Questions = paper[1].Groups.SelectMany(g => g.Questions).ToList();
        Assert.Equal(13, sec2Questions.Count);
        Assert.Equal(14, sec2Questions.First().Number);
        Assert.Equal(26, sec2Questions.Last().Number);

        // Section 3 questions: Q27 - Q40
        var sec3Questions = paper[2].Groups.SelectMany(g => g.Questions).ToList();
        Assert.Equal(14, sec3Questions.Count);
        Assert.Equal(27, sec3Questions.First().Number);
        Assert.Equal(40, sec3Questions.Last().Number);
    }

    [Fact]
    public async Task InitDemoRun_CreatesAuthorizedDurableRunsWithFencedLease()
    {
        var conn = "Host=localhost;Database=exam;Username=exam;Password=exam;Port=32771";
        var options = new DbContextOptionsBuilder<ExamDbContext>()
            .UseNpgsql(conn)
            .Options;
        await using var db = new ExamDbContext(options);

        var caps = R03CapsProfileTests.ApprovedFromDeployEnvFile();

        var src = new ReadingSource("PMC9640808", "Marine Climate", null, "https://europepmc.org/articles/PMC9640808", "CC BY 4.0", 5000);
        var req = new ReadingPaperEndpoints.DemoRunRequest("Marine Climate", 2, null, src, "minimax");
        try
        {
            var result = await ReadingPaperEndpoints.InitDemoRun(req, db, null!, caps, CancellationToken.None);
            Assert.NotNull(result);

            // Verify authorized durable run was created in DB and passes fencing check
            var createdJob = await db.ReadingPaperJobs.OrderByDescending(j => j.CreatedAt).FirstAsync(j => j.Topic == "Marine Climate");
            Assert.Equal("Running", createdJob.Status);
            Assert.NotNull(createdJob.ActiveRunId);

            var (run, job) = await CheckpointService.ValidateRunAuthorityAndFencingAsync(
                db, createdJob.ActiveRunId, 1, createdJob.LeaseOwner!.Value, CancellationToken.None
            );
            Assert.Equal("RUNNING", run.Status);
            Assert.Equal(1, run.Epoch);
            Assert.True(run.LeaseUntil > DateTime.UtcNow);
            Assert.True(await db.ReadingPaperOperations.AnyAsync(o => o.RunId == createdJob.ActiveRunId && o.OperationType == "GENERATE_SECTION"));
        }
        finally
        {
            var testJobs = await db.ReadingPaperJobs.Where(j => j.Topic == "Marine Climate").ToListAsync();
            foreach (var j in testJobs)
            {
                if (j.ActiveRunId != null)
                {
                    await db.ReadingPaperOperations.Where(o => o.RunId == j.ActiveRunId).ExecuteDeleteAsync();
                }
                await db.ReadingPaperRuns.Where(r => r.JobId == j.Id).ExecuteDeleteAsync();
                await db.ReadingPaperJobs.Where(x => x.Id == j.Id).ExecuteDeleteAsync();
            }
        }
    }
}
