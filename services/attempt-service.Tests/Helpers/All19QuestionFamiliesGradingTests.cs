using System.Text.Json;
using Xunit;
using attempt_service.Domain.Entities;
using attempt_service.Features.Helpers;
using Shared.ExamDto.Contracts.Exam.Enums;

namespace attempt_service.Tests.Helpers;

/// <summary>
/// Comprehensive verification of all 19 IELTS Academic Reading question families
/// through QuestionGraderFactory and their respective concrete graders.
/// </summary>
public class All19QuestionFamiliesGradingTests
{
    private readonly IQuestionGraderFactory _factory;

    public All19QuestionFamiliesGradingTests()
    {
        var singleChoice = new SingleChoiceGrader();
        var multipleChoice = new MultipleChoiceGrader();
        var completion = new CompletionGrader();
        var label = new LabelGrader();
        var matching = new MatchingHeadingGrader();
        var flowChart = new FlowChartGrader();
        var shortAnswer = new ShortAnswerGrader();

        var registrations = new IQuestionGraderRegistration[]
        {
            new SingleChoiceGraderRegistration(singleChoice),
            new MultipleChoiceGraderRegistration(multipleChoice),
            new CompletionGraderRegistration(completion),
            new LabelGraderRegistration(label),
            new MatchingHeadingGraderRegistration(matching),
            new FlowChartGraderRegistration(flowChart),
            new ShortAnswerGraderRegistration(shortAnswer),
        };

        _factory = new QuestionGraderFactory(registrations);
    }

    private static AttemptAnswer MakeTextAnswer(string? text) => new()
    {
        Id = Guid.NewGuid(),
        AttemptId = Guid.NewGuid(),
        SectionId = Guid.NewGuid(),
        QuestionId = Guid.NewGuid(),
        TextAnswer = text,
    };

    private static AttemptAnswer MakeOptionAnswer(List<Guid> optionIds) => new()
    {
        Id = Guid.NewGuid(),
        AttemptId = Guid.NewGuid(),
        SectionId = Guid.NewGuid(),
        QuestionId = Guid.NewGuid(),
        SelectedOptionIds = optionIds,
    };

    // ─────────────────────────────────────────────────────────────────────────
    // 1. Factory Resolution Verification for all 19 Question Families
    // ─────────────────────────────────────────────────────────────────────────

    [Theory]
    [InlineData(QuestionType.MultipleChoiceSingle, typeof(SingleChoiceGrader))]
    [InlineData(QuestionType.MultipleChoiceSingleImage, typeof(SingleChoiceGrader))]
    [InlineData(QuestionType.TrueFalseNotGiven, typeof(SingleChoiceGrader))]
    [InlineData(QuestionType.YesNoNotGiven, typeof(SingleChoiceGrader))]
    [InlineData(QuestionType.ChoosingTitle, typeof(SingleChoiceGrader))]
    [InlineData(QuestionType.MultipleChoiceMultiple, typeof(MultipleChoiceGrader))]
    [InlineData(QuestionType.SentenceCompletion, typeof(CompletionGrader))]
    [InlineData(QuestionType.SummaryCompletion, typeof(CompletionGrader))]
    [InlineData(QuestionType.SummaryCompletionBox, typeof(CompletionGrader))]
    [InlineData(QuestionType.TableCompletion, typeof(CompletionGrader))]
    [InlineData(QuestionType.NoteCompletion, typeof(CompletionGrader))]
    [InlineData(QuestionType.FormCompletion, typeof(CompletionGrader))]
    [InlineData(QuestionType.DiagramLabel, typeof(LabelGrader))]
    [InlineData(QuestionType.MapLabel, typeof(LabelGrader))]
    [InlineData(QuestionType.MatchingHeading, typeof(MatchingHeadingGrader))]
    [InlineData(QuestionType.MatchingInformation, typeof(MatchingHeadingGrader))]
    [InlineData(QuestionType.MatchingFeatures, typeof(MatchingHeadingGrader))]
    [InlineData(QuestionType.MatchingEndings, typeof(MatchingHeadingGrader))]
    [InlineData(QuestionType.Classification, typeof(MatchingHeadingGrader))]
    [InlineData(QuestionType.FlowChart, typeof(FlowChartGrader))]
    [InlineData(QuestionType.ShortAnswer, typeof(ShortAnswerGrader))]
    public void Factory_ResolvesAll19Families_ToCorrectConcreteGraders(string questionType, Type expectedGraderType)
    {
        var grader = _factory.Resolve(questionType);
        Assert.NotNull(grader);
        Assert.IsType(expectedGraderType, grader);
    }

    [Fact]
    public void Factory_UnsupportedType_ThrowsNotSupportedException()
    {
        Assert.Throws<NotSupportedException>(() => _factory.Resolve("UNSUPPORTED_RANDOM_TYPE"));
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 2. Single-Choice Families (MCQ Single, TFNG, YNNG, Choosing Title)
    // ─────────────────────────────────────────────────────────────────────────

    [Theory]
    [InlineData(QuestionType.MultipleChoiceSingle)]
    [InlineData(QuestionType.TrueFalseNotGiven)]
    [InlineData(QuestionType.YesNoNotGiven)]
    [InlineData(QuestionType.ChoosingTitle)]
    public void SingleChoice_CorrectOption_AwardsFullPoints(string qType)
    {
        var grader = _factory.Resolve(qType);
        var correctId = Guid.NewGuid();
        var key = new QuestionKey(
            QuestionId: Guid.NewGuid(),
            QuestionType: qType,
            QuestionPoints: 1m,
            CorrectOptionIds: new HashSet<(Guid id, string content)> { (correctId, "Correct Answer") }
        );

        var correctResult = grader.Grade(MakeOptionAnswer([correctId]), key);
        Assert.True(correctResult.IsCorrect);
        Assert.Equal(1m, correctResult.AwardedPoints);

        var wrongResult = grader.Grade(MakeOptionAnswer([Guid.NewGuid()]), key);
        Assert.False(wrongResult.IsCorrect);
        Assert.Equal(0m, wrongResult.AwardedPoints);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 3. Multiple-Choice Multiple (Order-independent set scoring)
    // ─────────────────────────────────────────────────────────────────────────

    [Fact]
    public void MultipleChoiceMultiple_ExactSet_AwardsFullPoints()
    {
        var grader = _factory.Resolve(QuestionType.MultipleChoiceMultiple);
        var optA = Guid.NewGuid();
        var optB = Guid.NewGuid();
        var key = new QuestionKey(
            QuestionId: Guid.NewGuid(),
            QuestionType: QuestionType.MultipleChoiceMultiple,
            QuestionPoints: 2m,
            CorrectOptionIds: new HashSet<(Guid id, string content)>
            {
                (optA, "Option A"),
                (optB, "Option B"),
            }
        );

        // Student selected both in reverse order -> Full points
        var res = grader.Grade(MakeOptionAnswer([optB, optA]), key);
        Assert.True(res.IsCorrect);
        Assert.Equal(2m, res.AwardedPoints);

        // Student selected one correct and one incorrect -> Incorrect
        var wrongRes = grader.Grade(MakeOptionAnswer([optA, Guid.NewGuid()]), key);
        Assert.False(wrongRes.IsCorrect);
        Assert.Equal(0m, wrongRes.AwardedPoints);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 4. Completion Families (Sentence, Summary, Box, Table, Note, Form)
    // ─────────────────────────────────────────────────────────────────────────

    [Theory]
    [InlineData(QuestionType.SentenceCompletion)]
    [InlineData(QuestionType.SummaryCompletion)]
    [InlineData(QuestionType.SummaryCompletionBox)]
    [InlineData(QuestionType.TableCompletion)]
    [InlineData(QuestionType.NoteCompletion)]
    [InlineData(QuestionType.FormCompletion)]
    public void Completion_VerbatimAndEquivalentAnswers_AwardFullPoints(string qType)
    {
        var grader = _factory.Resolve(qType);
        var blankMap = new Dictionary<string, string[]?>(StringComparer.OrdinalIgnoreCase)
        {
            ["1"] = new[] { "cellular energy", "cell energy" },
        };
        var key = new QuestionKey(
            QuestionId: Guid.NewGuid(),
            QuestionType: qType,
            QuestionPoints: 1m,
            BlankAcceptTexts: blankMap
        );

        // 1. Verbatim exact answer
        var r1 = grader.Grade(MakeTextAnswer(JsonSerializer.Serialize(new Dictionary<string, string> { ["1"] = "cellular energy" })), key);
        Assert.True(r1.IsCorrect);
        Assert.Equal(1m, r1.AwardedPoints);

        // 2. Equivalent alternative answer with casing & extra whitespace
        var r2 = grader.Grade(MakeTextAnswer(JsonSerializer.Serialize(new Dictionary<string, string> { ["1"] = "  CELL ENERGY  " })), key);
        Assert.True(r2.IsCorrect);
        Assert.Equal(1m, r2.AwardedPoints);

        // 3. Incorrect answer -> 0 points
        var r3 = grader.Grade(MakeTextAnswer(JsonSerializer.Serialize(new Dictionary<string, string> { ["1"] = "wrong answer" })), key);
        Assert.False(r3.IsCorrect);
        Assert.Equal(0m, r3.AwardedPoints);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 5. Visual Families (Diagram Label, Map Label)
    // ─────────────────────────────────────────────────────────────────────────

    [Theory]
    [InlineData(QuestionType.DiagramLabel)]
    [InlineData(QuestionType.MapLabel)]
    public void Label_CalloutAnswer_AwardsFullPoints(string qType)
    {
        var grader = _factory.Resolve(qType);
        var blankMap = new Dictionary<string, string[]?>(StringComparer.OrdinalIgnoreCase)
        {
            ["14"] = new[] { "central conduit" },
        };
        var key = new QuestionKey(
            QuestionId: Guid.NewGuid(),
            QuestionType: qType,
            QuestionPoints: 1m,
            BlankAcceptTexts: blankMap
        );

        // Exact match on callout 14
        var res = grader.Grade(MakeTextAnswer(JsonSerializer.Serialize(new Dictionary<string, string> { ["14"] = "central conduit" })), key);
        Assert.True(res.IsCorrect);
        Assert.Equal(1m, res.AwardedPoints);

        // Incorrect callout text
        var wrongRes = grader.Grade(MakeTextAnswer(JsonSerializer.Serialize(new Dictionary<string, string> { ["14"] = "outer crust" })), key);
        Assert.False(wrongRes.IsCorrect);
        Assert.Equal(0m, wrongRes.AwardedPoints);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 6. Matching Families (Headings, Information, Features, Endings, Classification)
    // ─────────────────────────────────────────────────────────────────────────

    [Theory]
    [InlineData(QuestionType.MatchingHeading)]
    [InlineData(QuestionType.MatchingInformation)]
    [InlineData(QuestionType.MatchingFeatures)]
    [InlineData(QuestionType.MatchingEndings)]
    [InlineData(QuestionType.Classification)]
    public void Matching_FullAndPartialPairs_EvaluatedAccurately(string qType)
    {
        var grader = _factory.Resolve(qType);
        var matchPairs = new Dictionary<string, string[]?>(StringComparer.OrdinalIgnoreCase)
        {
            ["1"] = new[] { "ii" },
            ["2"] = new[] { "iv" },
        };
        var key = new QuestionKey(
            QuestionId: Guid.NewGuid(),
            QuestionType: qType,
            QuestionPoints: 2m,
            MatchPairs: matchPairs
        );

        // Both pairs match -> Full points
        var fullRes = grader.Grade(MakeTextAnswer(JsonSerializer.Serialize(new Dictionary<string, string>
        {
            ["1"] = "ii",
            ["2"] = "iv",
        })), key);
        Assert.True(fullRes.IsCorrect);
        Assert.Equal(2m, fullRes.AwardedPoints);

        // Single pair matches in multi-pair question -> partial points
        var partialRes = grader.Grade(MakeTextAnswer(JsonSerializer.Serialize(new Dictionary<string, string>
        {
            ["1"] = "ii",
            ["2"] = "wrong",
        })), key);
        Assert.False(partialRes.IsCorrect);
        Assert.Equal(1m, partialRes.AwardedPoints);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 7. Flow Chart Family (Sequential Order Matching)
    // ─────────────────────────────────────────────────────────────────────────

    [Fact]
    public void FlowChart_ExactSequence_AwardsFullPoints()
    {
        var grader = _factory.Resolve(QuestionType.FlowChart);
        var key = new QuestionKey(
            QuestionId: Guid.NewGuid(),
            QuestionType: QuestionType.FlowChart,
            QuestionPoints: 1m,
            OrderCorrects: new List<string> { "cold water", "magmatic heating", "mineral plumes" }
        );

        // Exact order match
        var rawGood = JsonSerializer.Serialize(new List<string> { "cold water", "magmatic heating", "mineral plumes" });
        var res = grader.Grade(MakeTextAnswer(rawGood), key);
        Assert.True(res.IsCorrect);
        Assert.Equal(1m, res.AwardedPoints);

        // Scrambled order -> 0 points (no partial credit per §11.11)
        var rawBad = JsonSerializer.Serialize(new List<string> { "magmatic heating", "cold water", "mineral plumes" });
        var wrongRes = grader.Grade(MakeTextAnswer(rawBad), key);
        Assert.False(wrongRes.IsCorrect);
        Assert.Equal(0m, wrongRes.AwardedPoints);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 8. Short Answer Family
    // ─────────────────────────────────────────────────────────────────────────

    [Fact]
    public void ShortAnswer_MatchesVerbatimOrAcceptTexts()
    {
        var grader = _factory.Resolve(QuestionType.ShortAnswer);
        var key = new QuestionKey(
            QuestionId: Guid.NewGuid(),
            QuestionType: QuestionType.ShortAnswer,
            QuestionPoints: 1m,
            ShortAnswerAcceptTexts: new List<string> { "metallothioneins", "metallothionein" }
        );

        // Exact match
        var res1 = grader.Grade(MakeTextAnswer("metallothioneins"), key);
        Assert.True(res1.IsCorrect);
        Assert.Equal(1m, res1.AwardedPoints);

        // Case & whitespace tolerance
        var res2 = grader.Grade(MakeTextAnswer("  METALLOTHIONEIN  "), key);
        Assert.True(res2.IsCorrect);
        Assert.Equal(1m, res2.AwardedPoints);

        // Incorrect text
        var res3 = grader.Grade(MakeTextAnswer("heat shock protein"), key);
        Assert.False(res3.IsCorrect);
        Assert.Equal(0m, res3.AwardedPoints);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 9. Malformed Payloads Fail Closed (0 points, no crash)
    // ─────────────────────────────────────────────────────────────────────────

    [Theory]
    [InlineData(QuestionType.MatchingHeading)]
    [InlineData(QuestionType.FlowChart)]
    [InlineData(QuestionType.SentenceCompletion)]
    public void MalformedJsonPayloads_FailClosedGracefully(string qType)
    {
        var grader = _factory.Resolve(qType);
        var key = new QuestionKey(
            QuestionId: Guid.NewGuid(),
            QuestionType: qType,
            QuestionPoints: 1m,
            MatchPairs: new Dictionary<string, string[]?> { ["1"] = new[] { "val" } },
            OrderCorrects: new List<string> { "a", "b" },
            BlankAcceptTexts: new Dictionary<string, string[]?> { ["1"] = new[] { "text" } }
        );

        var result = grader.Grade(MakeTextAnswer("{{{not-valid-json"), key);
        Assert.False(result.IsCorrect);
        Assert.Equal(0m, result.AwardedPoints);
    }
}
