using attempt_service.Features.Helpers;
using Xunit;

namespace attempt_service.Tests.Graders;

/// <summary>
/// Locks the contract of <see cref="DiagramLabelGrader"/> via
/// <see cref="CompletionScoring"/>: per-gap normalised exact match.
/// </summary>
public sealed class DiagramLabelGraderTests
{
    private readonly DiagramLabelGrader _grader = new(new TextNormalizer());
    private readonly AnswerEnvelopeReader _reader = new();

    [Fact]
    public void All_gaps_match_scores_1()
    {
        var correct = _reader.Read(
            """{"answers":{"A":["library"],"B":["gym"]}}""",
            "DIAGRAM_LABEL");
        var learner = _reader.Read(
            """{"A":["library"],"B":["gym"]}""",
            "DIAGRAM_LABEL");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Partial_match_scores_proportion()
    {
        var correct = _reader.Read(
            """{"answers":{"A":["library"],"B":["gym"],"C":["pool"]}}""",
            "DIAGRAM_LABEL");
        var learner = _reader.Read(
            """{"A":["library"],"B":["WRONG"],"C":["pool"]}""",
            "DIAGRAM_LABEL");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(2m / 3m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
    }

    [Fact]
    public void All_wrong_scores_0()
    {
        var correct = _reader.Read(
            """{"answers":{"A":["library"]}}""",
            "DIAGRAM_LABEL");
        var learner = _reader.Read("""{"A":["WRONG"]}""", "DIAGRAM_LABEL");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
    }

    [Fact]
    public void Empty_learner_payload_scores_0()
    {
        var correct = _reader.Read(
            """{"answers":{"A":["library"]}}""",
            "DIAGRAM_LABEL");
        var learner = _reader.Read("""{}""", "DIAGRAM_LABEL");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
    }

    [Fact]
    public void Normalized_match()
    {
        var correct = _reader.Read(
            """{"answers":{"A":["library"]}}""",
            "DIAGRAM_LABEL");
        var learner = _reader.Read(
            """{"A":["The Library!"]}""",
            "DIAGRAM_LABEL");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }
}