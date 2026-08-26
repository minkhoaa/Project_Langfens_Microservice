using attempt_service.Features.Helpers;
using Xunit;

namespace attempt_service.Tests.Graders;

/// <summary>
/// Mirrors <see cref="MultipleChoiceSingleGraderTests"/> but exercises the
/// image-option record <c>MultipleChoiceSingleImageAnswer</c>.
/// </summary>
public sealed class MultipleChoiceSingleImageGraderTests
{
    private readonly MultipleChoiceSingleImageGrader _grader = new();
    private readonly AnswerEnvelopeReader _reader = new();

    [Fact]
    public void Correct_pick_scores_1()
    {
        var correct = _reader.Read("""{"correctOptionId":"img_2"}""", "MULTIPLE_CHOICE_SINGLE_IMAGE");
        var learner = _reader.Read("""{"selectedOptionId":"img_2"}""", "MULTIPLE_CHOICE_SINGLE_IMAGE");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Wrong_pick_scores_0()
    {
        var correct = _reader.Read("""{"correctOptionId":"img_2"}""", "MULTIPLE_CHOICE_SINGLE_IMAGE");
        var learner = _reader.Read("""{"selectedOptionId":"img_5"}""", "MULTIPLE_CHOICE_SINGLE_IMAGE");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
    }

    [Fact]
    public void Empty_selection_scores_0()
    {
        var correct = _reader.Read("""{"correctOptionId":"img_2"}""", "MULTIPLE_CHOICE_SINGLE_IMAGE");
        var learner = _reader.Read("""{}""", "MULTIPLE_CHOICE_SINGLE_IMAGE");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
        Assert.Equal("no learner selection", result.FailureReason);
    }

    [Fact]
    public void Malformed_learner_scores_0()
    {
        var correct = _reader.Read("""{"correctOptionId":"img_2"}""", "MULTIPLE_CHOICE_SINGLE_IMAGE");
        var learner = _reader.Read("""{"selectedOptionId":null}""", "MULTIPLE_CHOICE_SINGLE_IMAGE");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
        Assert.Equal("no learner selection", result.FailureReason);
    }

    [Fact]
    public void Slug_is_MULTIPLE_CHOICE_SINGLE_IMAGE()
    {
        Assert.Equal("MULTIPLE_CHOICE_SINGLE_IMAGE", _grader.Slug);
    }
}