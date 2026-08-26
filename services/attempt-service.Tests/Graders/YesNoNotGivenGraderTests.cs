using attempt_service.Features.Helpers;
using Xunit;

namespace attempt_service.Tests.Graders;

/// <summary>
/// Locks the contract of <see cref="YesNoNotGivenGrader"/>: exact enum match
/// on <c>YesNoNotGivenAnswerChoice</c> (<c>YES</c> / <c>NO</c> / <c>NOT_GIVEN</c>).
/// Mirrors the True/False/NotGiven grader.
/// </summary>
public sealed class YesNoNotGivenGraderTests
{
    private readonly YesNoNotGivenGrader _grader = new();
    private readonly AnswerEnvelopeReader _reader = new();

    [Fact]
    public void Matching_choice_scores_1()
    {
        var correct = _reader.Read("""{"choice":"YES"}""", "YES_NO_NOT_GIVEN");
        var learner = _reader.Read("""{"choice":"YES"}""", "YES_NO_NOT_GIVEN");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Different_choice_scores_0()
    {
        var correct = _reader.Read("""{"choice":"NO"}""", "YES_NO_NOT_GIVEN");
        var learner = _reader.Read("""{"choice":"YES"}""", "YES_NO_NOT_GIVEN");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
    }

    [Fact]
    public void Missing_choice_scores_0()
    {
        var correct = _reader.Read("""{"choice":"YES"}""", "YES_NO_NOT_GIVEN");
        var learner = _reader.Read("""{}""", "YES_NO_NOT_GIVEN");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
        Assert.Equal("no learner choice", result.FailureReason);
    }

    [Fact]
    public void All_three_enum_values_resolve()
    {
        foreach (var choice in new[] { "YES", "NO", "NOT_GIVEN" })
        {
            var correct = _reader.Read($$"""{"choice":"{{choice}}"}""", "YES_NO_NOT_GIVEN");
            var learner = _reader.Read($$"""{"choice":"{{choice}}"}""", "YES_NO_NOT_GIVEN");
            var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
            Assert.True(result.IsCorrect, $"expected IsCorrect for {choice}");
        }
    }
}