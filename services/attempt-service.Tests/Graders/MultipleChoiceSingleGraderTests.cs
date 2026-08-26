using attempt_service.Features.Helpers;

namespace attempt_service.Tests.Graders;

/// <summary>
/// Locks the contract of <see cref="MultipleChoiceSingleGrader"/>: learner submits
/// <c>selectedOptionId</c>, correct carries <c>correctOptionId</c>. Full credit iff the
/// ids match exactly; otherwise 0 with <see cref="GradeResult.IsCorrect"/> = false.
/// </summary>
public sealed class MultipleChoiceSingleGraderTests
{
    private readonly MultipleChoiceSingleGrader _grader = new();
    private readonly AnswerEnvelopeReader _reader = new();

    [Fact]
    public void Correct_pick_scores_1()
    {
        var correct = _reader.Read("""{"correctOptionId":"opt_2"}""", "MULTIPLE_CHOICE_SINGLE");
        var learner = _reader.Read("""{"selectedOptionId":"opt_2"}""", "MULTIPLE_CHOICE_SINGLE");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Wrong_pick_scores_0()
    {
        var correct = _reader.Read("""{"correctOptionId":"opt_2"}""", "MULTIPLE_CHOICE_SINGLE");
        var learner = _reader.Read("""{"selectedOptionId":"opt_5"}""", "MULTIPLE_CHOICE_SINGLE");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
    }

    [Fact]
    public void Empty_selection_scores_0_with_failure_reason()
    {
        var correct = _reader.Read("""{"correctOptionId":"opt_2"}""", "MULTIPLE_CHOICE_SINGLE");
        var learner = _reader.Read("""{}""", "MULTIPLE_CHOICE_SINGLE");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
        Assert.Equal("no learner selection", result.FailureReason);
    }

    [Fact]
    public void Malformed_learner_json_scores_0_with_failure_reason()
    {
        var correct = _reader.Read("""{"correctOptionId":"opt_2"}""", "MULTIPLE_CHOICE_SINGLE");
        var learner = _reader.Read("""{"selectedOptionId":12345}""", "MULTIPLE_CHOICE_SINGLE");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
        Assert.Equal("learner answer malformed", result.FailureReason);
    }

    [Fact]
    public void Id_match_is_case_sensitive_ordinal()
    {
        var correct = _reader.Read("""{"correctOptionId":"OPT_2"}""", "MULTIPLE_CHOICE_SINGLE");
        var learner = _reader.Read("""{"selectedOptionId":"opt_2"}""", "MULTIPLE_CHOICE_SINGLE");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.False(result.IsCorrect);
        Assert.Equal(0m, result.AwardedPoints);
    }
}