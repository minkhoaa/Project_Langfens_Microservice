using System.Text.Json;
using attempt_service.Domain.Entities;
using attempt_service.Features.Helpers;
using FluentAssertions;

namespace attempt_service.Tests.Helpers;

public class SingleChoiceGraderTests
{
    private static AttemptAnswer Answer(IEnumerable<Guid>? ids) =>
        new() { SelectedOptionIds = ids?.ToList(), TextAnswer = "" };

    private static QuestionKey Key(decimal points, params Guid[] correctIds)
    {
        var set = correctIds
            .Select(id => (id, string.Empty))
            .ToHashSet();
        return new QuestionKey(Guid.NewGuid(), "MULTIPLE_CHOICE_SINGLE", points, set);
    }

    [Fact]
    public void CorrectSingleSelection_ReturnsFullPoints()
    {
        var correctId = Guid.NewGuid();
        var grader = new SingleChoiceGrader();
        var result = grader.Grade(Answer(new[] { correctId }), Key(1m, correctId));
        result.AwardedPoints.Should().Be(1m);
        result.IsCorrect.Should().BeTrue();
    }

    [Fact]
    public void WrongSelection_ReturnsZero()
    {
        var correctId = Guid.NewGuid();
        var wrongId = Guid.NewGuid();
        var grader = new SingleChoiceGrader();
        var result = grader.Grade(Answer(new[] { wrongId }), Key(1m, correctId));
        result.AwardedPoints.Should().Be(0m);
        result.IsCorrect.Should().BeFalse();
    }

    [Fact]
    public void EmptySelection_ReturnsZero()
    {
        var correctId = Guid.NewGuid();
        var grader = new SingleChoiceGrader();
        var result = grader.Grade(Answer(Array.Empty<Guid>()), Key(1m, correctId));
        result.AwardedPoints.Should().Be(0m);
        result.IsCorrect.Should().BeFalse();
    }

    [Fact]
    public void TooManySelections_ReturnsZero()
    {
        var correctId = Guid.NewGuid();
        var extraId = Guid.NewGuid();
        var grader = new SingleChoiceGrader();
        // selection.Count == 2, not 1 → false
        var result = grader.Grade(Answer(new[] { correctId, extraId }), Key(1m, correctId));
        result.AwardedPoints.Should().Be(0m);
        result.IsCorrect.Should().BeFalse();
    }
}

public class MultipleChoiceGraderTests
{
    private static AttemptAnswer Answer(IEnumerable<Guid> ids) =>
        new() { SelectedOptionIds = ids.ToList(), TextAnswer = "" };

    private static QuestionKey Key(decimal points, params Guid[] correctIds)
    {
        var set = correctIds.Select(id => (id, string.Empty)).ToHashSet();
        return new QuestionKey(Guid.NewGuid(), "MULTIPLE_CHOICE_MULTIPLE", points, set);
    }

    [Fact]
    public void ExactCorrectSet_ReturnsFullPoints()
    {
        var a = Guid.NewGuid();
        var b = Guid.NewGuid();
        var c = Guid.NewGuid();
        var result = new MultipleChoiceGrader().Grade(Answer(new[] { a, b, c }), Key(2m, a, b, c));
        result.AwardedPoints.Should().Be(2m);
        result.IsCorrect.Should().BeTrue();
    }

    [Fact]
    public void PartialSet_ReturnsZero()
    {
        var a = Guid.NewGuid();
        var b = Guid.NewGuid();
        var c = Guid.NewGuid();
        var result = new MultipleChoiceGrader().Grade(Answer(new[] { a, b }), Key(2m, a, b, c));
        result.AwardedPoints.Should().Be(0m);
        result.IsCorrect.Should().BeFalse();
    }

    [Fact]
    public void SupersetOfCorrect_ReturnsZero()
    {
        var a = Guid.NewGuid();
        var b = Guid.NewGuid();
        var extra = Guid.NewGuid();
        var result = new MultipleChoiceGrader().Grade(Answer(new[] { a, b, extra }), Key(2m, a, b));
        result.AwardedPoints.Should().Be(0m);
        result.IsCorrect.Should().BeFalse();
    }

    [Fact]
    public void EmptySelection_ReturnsZero()
    {
        var a = Guid.NewGuid();
        var b = Guid.NewGuid();
        var result = new MultipleChoiceGrader().Grade(Answer(Array.Empty<Guid>()), Key(2m, a, b));
        result.AwardedPoints.Should().Be(0m);
        result.IsCorrect.Should().BeFalse();
    }
}

public class CompletionGraderTests
{
    private static AttemptAnswer TextAnswer(string text) =>
        new() { TextAnswer = text, SelectedOptionIds = null };

    // Helper: build a QuestionKey with BlankAcceptTexts and optionally BlankAcceptRegex
    private static QuestionKey Key(
        decimal points,
        Dictionary<string, string[]?>? texts = null,
        Dictionary<string, string[]?>? regs = null)
        => new QuestionKey(
            Guid.NewGuid(),
            "SUMMARY_COMPLETION",
            points,
            BlankAcceptTexts: texts,
            BlankAcceptRegex: regs);

    [Fact]
    public void JsonPayload_CorrectBlank_ReturnsFullPoints()
    {
        var payload = JsonSerializer.Serialize(new Dictionary<string, string>
        {
            ["blank-q1"] = "correct"
        });
        var key = Key(1m, texts: new Dictionary<string, string[]?>
        {
            ["blank-q1"] = new[] { "correct" }
        });
        var result = new CompletionGrader().Grade(TextAnswer(payload), key);
        result.AwardedPoints.Should().Be(1m);
        result.IsCorrect.Should().BeTrue();
    }

    [Fact]
    public void JsonPayload_WrongAnswer_ReturnsZero()
    {
        var payload = JsonSerializer.Serialize(new Dictionary<string, string>
        {
            ["blank-q1"] = "wrong"
        });
        var key = Key(1m, texts: new Dictionary<string, string[]?>
        {
            ["blank-q1"] = new[] { "correct" }
        });
        var result = new CompletionGrader().Grade(TextAnswer(payload), key);
        result.AwardedPoints.Should().Be(0m);
        result.IsCorrect.Should().BeFalse();
    }

    [Fact]
    public void MultiBlank_PartialCredit_HalfPoints()
    {
        // 2 blanks, user gets 1 correct → 0.5 * points = 0.5
        var payload = JsonSerializer.Serialize(new Dictionary<string, string>
        {
            ["b1"] = "right",
            ["b2"] = "wrong"
        });
        var key = Key(1m, texts: new Dictionary<string, string[]?>
        {
            ["b1"] = new[] { "right" },
            ["b2"] = new[] { "correct" }
        });
        var result = new CompletionGrader().Grade(TextAnswer(payload), key);
        result.AwardedPoints.Should().Be(0.5m);
        result.IsCorrect.Should().BeFalse();
    }

    [Fact]
    public void JsonPayload_RegexMatch_CaseInsensitive_ReturnsFullPoints()
    {
        var payload = JsonSerializer.Serialize(new Dictionary<string, string>
        {
            ["b1"] = "Hello"
        });
        // regex pattern: hello (case-insensitive flag applied)
        var key = Key(1m,
            texts: null,
            regs: new Dictionary<string, string[]?>
            {
                ["b1"] = new[] { "hello" }
            });
        var result = new CompletionGrader().Grade(TextAnswer(payload), key);
        result.AwardedPoints.Should().Be(1m);
        result.IsCorrect.Should().BeTrue();
    }

    [Fact]
    public void PlainText_SingleBlankLegacy_CorrectAnswer_ReturnsFullPoints()
    {
        // Not JSON, single blank: fallback to plaintext path
        var key = Key(1m, texts: new Dictionary<string, string[]?>
        {
            ["only"] = new[] { "London" }
        });
        var result = new CompletionGrader().Grade(TextAnswer("London"), key);
        result.AwardedPoints.Should().Be(1m);
        result.IsCorrect.Should().BeTrue();
    }

    [Fact]
    public void EmptyAnswer_ReturnsZero()
    {
        var key = Key(1m, texts: new Dictionary<string, string[]?>
        {
            ["b1"] = new[] { "answer" }
        });
        var result = new CompletionGrader().Grade(TextAnswer(""), key);
        result.AwardedPoints.Should().Be(0m);
        result.IsCorrect.Should().BeFalse();
    }
}

public class MatchingHeadingGraderTests
{
    private static AttemptAnswer TextAnswer(string text) =>
        new() { TextAnswer = text, SelectedOptionIds = null };

    private static QuestionKey Key(
        decimal points,
        Dictionary<string, string[]?> pairs)
        => new QuestionKey(
            Guid.NewGuid(),
            "MATCHING_HEADINGS",
            points,
            MatchPairs: pairs);

    [Fact]
    public void Json_CorrectSinglePair_ReturnsFullPoints()
    {
        var payload = JsonSerializer.Serialize(new Dictionary<string, string>
        {
            ["section-A"] = "iii"
        });
        var key = Key(1m, new Dictionary<string, string[]?>
        {
            ["section-A"] = new[] { "iii" }
        });
        var result = new MatchingHeadingGrader().Grade(TextAnswer(payload), key);
        result.AwardedPoints.Should().Be(1m);
        result.IsCorrect.Should().BeTrue();
    }

    [Fact]
    public void Json_WrongValue_ReturnsZero()
    {
        var payload = JsonSerializer.Serialize(new Dictionary<string, string>
        {
            ["section-A"] = "iv"
        });
        var key = Key(1m, new Dictionary<string, string[]?>
        {
            ["section-A"] = new[] { "iii" }
        });
        var result = new MatchingHeadingGrader().Grade(TextAnswer(payload), key);
        result.AwardedPoints.Should().Be(0m);
        result.IsCorrect.Should().BeFalse();
    }

    [Fact]
    public void Json_MultiPair_PartialCredit_HalfPoints()
    {
        var payload = JsonSerializer.Serialize(new Dictionary<string, string>
        {
            ["section-A"] = "iii",
            ["section-B"] = "wrong"
        });
        var key = Key(1m, new Dictionary<string, string[]?>
        {
            ["section-A"] = new[] { "iii" },
            ["section-B"] = new[] { "v" }
        });
        var result = new MatchingHeadingGrader().Grade(TextAnswer(payload), key);
        result.AwardedPoints.Should().Be(0.5m);
        result.IsCorrect.Should().BeFalse();
    }

    [Fact]
    public void Json_CaseInsensitiveMatch_ReturnsFullPoints()
    {
        // user sends "III" vs accepted "iii"
        var payload = JsonSerializer.Serialize(new Dictionary<string, string>
        {
            ["section-A"] = "III"
        });
        var key = Key(1m, new Dictionary<string, string[]?>
        {
            ["section-A"] = new[] { "iii" }
        });
        var result = new MatchingHeadingGrader().Grade(TextAnswer(payload), key);
        result.AwardedPoints.Should().Be(1m);
        result.IsCorrect.Should().BeTrue();
    }
}

public class FlowChartGraderTests
{
    private static AttemptAnswer SeqAnswer(IEnumerable<string> items) =>
        new() { TextAnswer = JsonSerializer.Serialize(items), SelectedOptionIds = null };

    private static QuestionKey Key(decimal points, IEnumerable<string> correct)
        => new QuestionKey(
            Guid.NewGuid(),
            "FLOW_CHART",
            points,
            OrderCorrects: correct.ToList());

    [Fact]
    public void PerfectSequence_ReturnsFullPoints()
    {
        var seq = new[] { "alpha", "beta", "gamma" };
        var result = new FlowChartGrader().Grade(SeqAnswer(seq), Key(3m, seq));
        result.AwardedPoints.Should().Be(3m);
        result.IsCorrect.Should().BeTrue();
    }

    [Fact]
    public void CompletelyWrongSequence_ReturnsZero()
    {
        var correct = new[] { "alpha", "beta", "gamma" };
        var wrong = new[] { "delta", "epsilon", "zeta" };
        var result = new FlowChartGrader().Grade(SeqAnswer(wrong), Key(3m, correct));
        // LCS = 0 → score = 0
        result.AwardedPoints.Should().Be(0m);
        result.IsCorrect.Should().BeFalse();
    }

    [Fact]
    public void PartialSequenceViaLCS_ReturnsProportionalScore()
    {
        // correct = [a, b, c], user = [a, b, x] → LCS = 2 → score = 2/3 * 3 ≈ 2
        var correct = new[] { "a", "b", "c" };
        var user = new[] { "a", "b", "x" };
        var result = new FlowChartGrader().Grade(SeqAnswer(user), Key(3m, correct));
        // decimal arithmetic: (decimal)2/3*3 may have a tiny rounding error
        result.AwardedPoints.Should().BeApproximately(2m, 0.0000001m);
        result.IsCorrect.Should().BeFalse();
    }
}

public class ShortAnswerGraderTests
{
    private static AttemptAnswer TextAnswer(string text) =>
        new() { TextAnswer = text, SelectedOptionIds = null };

    private static QuestionKey Key(
        decimal points,
        string[]? accepts = null,
        string[]? regexes = null)
        => new QuestionKey(
            Guid.NewGuid(),
            "SHORT_ANSWER",
            points,
            ShortAnswerAcceptTexts: accepts,
            ShortAnswerAcceptRegex: regexes);

    [Fact]
    public void ExactMatch_ReturnsFullPoints()
    {
        var result = new ShortAnswerGrader().Grade(
            TextAnswer("London"),
            Key(1m, accepts: new[] { "London" }));
        result.AwardedPoints.Should().Be(1m);
        result.IsCorrect.Should().BeTrue();
    }

    [Fact]
    public void CaseInsensitiveMatch_ReturnsFullPoints()
    {
        // TextNorm lowercases both sides
        var result = new ShortAnswerGrader().Grade(
            TextAnswer("LONDON"),
            Key(1m, accepts: new[] { "london" }));
        result.AwardedPoints.Should().Be(1m);
        result.IsCorrect.Should().BeTrue();
    }

    [Fact]
    public void AccentNormalizedMatch_ReturnsFullPoints()
    {
        // "café" normalized → "cafe"
        var result = new ShortAnswerGrader().Grade(
            TextAnswer("café"),
            Key(1m, accepts: new[] { "cafe" }));
        result.AwardedPoints.Should().Be(1m);
        result.IsCorrect.Should().BeTrue();
    }

    [Fact]
    public void RegexMatch_ReturnsFullPoints()
    {
        var result = new ShortAnswerGrader().Grade(
            TextAnswer("2024"),
            Key(1m, regexes: new[] { @"\d{4}" }));
        result.AwardedPoints.Should().Be(1m);
        result.IsCorrect.Should().BeTrue();
    }

    [Fact]
    public void WrongAnswer_ReturnsZero()
    {
        var result = new ShortAnswerGrader().Grade(
            TextAnswer("Paris"),
            Key(1m, accepts: new[] { "London" }));
        result.AwardedPoints.Should().Be(0m);
        result.IsCorrect.Should().BeFalse();
    }
}
