using attempt_service.Features.Helpers;
using Xunit;

namespace attempt_service.Tests.Graders;

/// <summary>
/// Locks the contract of <see cref="FormCompletionGrader"/> via
/// <see cref="CompletionScoring"/>: per-gap normalised exact match.
/// </summary>
public sealed class FormCompletionGraderTests
{
    private readonly FormCompletionGrader _grader = new(new TextNormalizer());
    private readonly AnswerEnvelopeReader _reader = new();

    [Fact]
    public void All_gaps_match_scores_1()
    {
        var correct = _reader.Read(
            """{"answers":{"f1":["John Smith"],"f2":["01/01/1990"]}}""",
            "FORM_COMPLETION");
        var learner = _reader.Read(
            """{"f1":["John Smith"],"f2":["01/01/1990"]}""",
            "FORM_COMPLETION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Partial_match_scores_proportion()
    {
        var correct = _reader.Read(
            """{"answers":{"f1":["John Smith"],"f2":["01/01/1990"]}}""",
            "FORM_COMPLETION");
        var learner = _reader.Read(
            """{"f1":["Jane Doe"],"f2":["01/01/1990"]}""",
            "FORM_COMPLETION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0.5m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
    }

    [Fact]
    public void All_wrong_scores_0()
    {
        var correct = _reader.Read(
            """{"answers":{"f1":["John Smith"]}}""",
            "FORM_COMPLETION");
        var learner = _reader.Read(
            """{"f1":["WRONG"]}""",
            "FORM_COMPLETION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
    }

    [Fact]
    public void Article_drop_normalizes_match()
    {
        var correct = _reader.Read(
            """{"answers":{"f1":["Mr. Smith"]}}""",
            "FORM_COMPLETION");
        var learner = _reader.Read(
            """{"f1":["Mr Smith"]}""",
            "FORM_COMPLETION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Empty_learner_payload_scores_0()
    {
        var correct = _reader.Read(
            """{"answers":{"f1":["John Smith"]}}""",
            "FORM_COMPLETION");
        var learner = _reader.Read("""{}""", "FORM_COMPLETION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
    }
}