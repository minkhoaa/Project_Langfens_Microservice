using attempt_service.Features.Helpers;
using Xunit;

namespace attempt_service.Tests.Graders;

/// <summary>
/// Locks the contract of <see cref="TrueFalseNotGivenGrader"/>: exact enum match
/// on <c>TrueFalseNotGivenAnswerChoice</c> (<c>TRUE</c> / <c>FALSE</c> / <c>NOT_GIVEN</c>).
/// </summary>
public sealed class TrueFalseNotGivenGraderTests
{
    private readonly TrueFalseNotGivenGrader _grader = new();
    private readonly AnswerEnvelopeReader _reader = new();

    [Fact]
    public void Matching_choice_scores_1()
    {
        var correct = _reader.Read("""{"choice":"TRUE"}""", "TRUE_FALSE_NOT_GIVEN");
        var learner = _reader.Read("""{"choice":"TRUE"}""", "TRUE_FALSE_NOT_GIVEN");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Different_choice_scores_0()
    {
        var correct = _reader.Read("""{"choice":"FALSE"}""", "TRUE_FALSE_NOT_GIVEN");
        var learner = _reader.Read("""{"choice":"NOT_GIVEN"}""", "TRUE_FALSE_NOT_GIVEN");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
    }

    [Fact]
    public void Missing_choice_scores_0_with_failure_reason()
    {
        var correct = _reader.Read("""{"choice":"TRUE"}""", "TRUE_FALSE_NOT_GIVEN");
        var learner = _reader.Read("""{}""", "TRUE_FALSE_NOT_GIVEN");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
        Assert.Equal("no learner choice", result.FailureReason);
    }

    [Fact]
    public void All_three_enum_values_resolve()
    {
        foreach (var choice in new[] { "TRUE", "FALSE", "NOT_GIVEN" })
        {
            var correct = _reader.Read($$"""{"choice":"{{choice}}"}""", "TRUE_FALSE_NOT_GIVEN");
            var learner = _reader.Read($$"""{"choice":"{{choice}}"}""", "TRUE_FALSE_NOT_GIVEN");
            var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
            Assert.True(result.IsCorrect, $"expected IsCorrect for {choice}");
        }
    }

    [Fact]
    public void Malformed_learner_scores_0()
    {
        var correct = _reader.Read("""{"choice":"TRUE"}""", "TRUE_FALSE_NOT_GIVEN");
        var learner = _reader.Read("""{"choice":"WRONG_VALUE"}""", "TRUE_FALSE_NOT_GIVEN");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
        Assert.Equal("learner answer malformed", result.FailureReason);
    }
}