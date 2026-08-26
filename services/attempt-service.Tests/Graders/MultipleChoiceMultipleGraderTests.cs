using attempt_service.Features.Helpers;
using Xunit;

namespace attempt_service.Tests.Graders;

/// <summary>
/// Locks the contract of <see cref="MultipleChoiceMultipleGrader"/>: three
/// scoring modes (<c>all-or-nothing</c> / <c>proportional</c> / <c>afi</c>).
/// <c>rubric</c> is human/AI-graded and is not handled here.
/// </summary>
public sealed class MultipleChoiceMultipleGraderTests
{
    private readonly MultipleChoiceMultipleGrader _grader = new();
    private readonly AnswerEnvelopeReader _reader = new();

    [Fact]
    public void AllOrNothing_full_match_scores_1()
    {
        var correct = _reader.Read(
            """{"correctOptionIds":["a","b","c"],"scoring":"all-or-nothing"}""",
            "MULTIPLE_CHOICE_MULTIPLE");
        var learner = _reader.Read(
            """{"selectedOptionIds":["a","b","c"]}""",
            "MULTIPLE_CHOICE_MULTIPLE");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void AllOrNothing_partial_scores_0()
    {
        var correct = _reader.Read(
            """{"correctOptionIds":["a","b","c"],"scoring":"all-or-nothing"}""",
            "MULTIPLE_CHOICE_MULTIPLE");
        var learner = _reader.Read(
            """{"selectedOptionIds":["a","b"]}""",
            "MULTIPLE_CHOICE_MULTIPLE");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
    }

    [Fact]
    public void AllOrNothing_over_selection_scores_0()
    {
        var correct = _reader.Read(
            """{"correctOptionIds":["a","b"],"scoring":"all-or-nothing"}""",
            "MULTIPLE_CHOICE_MULTIPLE");
        var learner = _reader.Read(
            """{"selectedOptionIds":["a","b","c"]}""",
            "MULTIPLE_CHOICE_MULTIPLE");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
    }

    [Fact]
    public void Proportional_partial_match_with_neg_marking()
    {
        // 2 correct out of 3 minus 1 wrong = (2-1)/3 = 0.333
        var correct = _reader.Read(
            """{"correctOptionIds":["a","b","c"],"scoring":"proportional"}""",
            "MULTIPLE_CHOICE_MULTIPLE");
        var learner = _reader.Read(
            """{"selectedOptionIds":["a","b","d"]}""",
            "MULTIPLE_CHOICE_MULTIPLE");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m / 3m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
    }

    [Fact]
    public void Proportional_over_does_not_go_negative()
    {
        // 0 correct, 3 wrong, 1 total → max(0, 0-3)/1 = 0
        var correct = _reader.Read(
            """{"correctOptionIds":["a"],"scoring":"proportional"}""",
            "MULTIPLE_CHOICE_MULTIPLE");
        var learner = _reader.Read(
            """{"selectedOptionIds":["d","e","f"]}""",
            "MULTIPLE_CHOICE_MULTIPLE");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
    }

    [Fact]
    public void Proportional_full_match_scores_1()
    {
        var correct = _reader.Read(
            """{"correctOptionIds":["a","b","c"],"scoring":"proportional"}""",
            "MULTIPLE_CHOICE_MULTIPLE");
        var learner = _reader.Read(
            """{"selectedOptionIds":["a","b","c"]}""",
            "MULTIPLE_CHOICE_MULTIPLE");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Afi_over_selection_is_not_penalized()
    {
        // 2 correct / 3 total = 0.666 (extra pick doesn't count against)
        var correct = _reader.Read(
            """{"correctOptionIds":["a","b","c"],"scoring":"afi"}""",
            "MULTIPLE_CHOICE_MULTIPLE");
        var learner = _reader.Read(
            """{"selectedOptionIds":["a","b","d","e"]}""",
            "MULTIPLE_CHOICE_MULTIPLE");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(2m / 3m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
    }

    [Fact]
    public void Afi_full_match_scores_1()
    {
        var correct = _reader.Read(
            """{"correctOptionIds":["a","b","c"],"scoring":"afi"}""",
            "MULTIPLE_CHOICE_MULTIPLE");
        var learner = _reader.Read(
            """{"selectedOptionIds":["a","b","c"]}""",
            "MULTIPLE_CHOICE_MULTIPLE");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Rubric_flags_for_manual_review()
    {
        var correct = _reader.Read(
            """{"correctOptionIds":["a"],"scoring":"rubric"}""",
            "MULTIPLE_CHOICE_MULTIPLE");
        var learner = _reader.Read(
            """{"selectedOptionIds":["a"]}""",
            "MULTIPLE_CHOICE_MULTIPLE");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.True(result.NeedsManualReview);
        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
        Assert.Contains("rubric", result.FailureReason);
    }

    [Fact]
    public void Empty_learner_selection_scores_0()
    {
        var correct = _reader.Read(
            """{"correctOptionIds":["a","b"],"scoring":"proportional"}""",
            "MULTIPLE_CHOICE_MULTIPLE");
        var learner = _reader.Read("""{}""", "MULTIPLE_CHOICE_MULTIPLE");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
    }
}