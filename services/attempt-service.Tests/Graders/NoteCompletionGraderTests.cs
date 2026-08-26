using attempt_service.Features.Helpers;
using Xunit;

namespace attempt_service.Tests.Graders;

/// <summary>
/// Locks the contract of <see cref="NoteCompletionGrader"/> via
/// <see cref="CompletionScoring"/>: per-gap normalised exact match.
/// </summary>
public sealed class NoteCompletionGraderTests
{
    private readonly NoteCompletionGrader _grader = new(new TextNormalizer());
    private readonly AnswerEnvelopeReader _reader = new();

    [Fact]
    public void All_gaps_match_scores_1()
    {
        var correct = _reader.Read(
            """{"answers":{"n1":["bacteria"],"n2":["oxygen"]}}""",
            "NOTE_COMPLETION");
        var learner = _reader.Read(
            """{"n1":["bacteria"],"n2":["oxygen"]}""",
            "NOTE_COMPLETION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Partial_match_scores_proportion()
    {
        var correct = _reader.Read(
            """{"answers":{"n1":["bacteria"],"n2":["oxygen"],"n3":["nitrogen"]}}""",
            "NOTE_COMPLETION");
        var learner = _reader.Read(
            """{"n1":["bacteria"],"n2":["CO2"],"n3":["nitrogen"]}""",
            "NOTE_COMPLETION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(2m / 3m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
    }

    [Fact]
    public void All_wrong_scores_0()
    {
        var correct = _reader.Read(
            """{"answers":{"n1":["bacteria"]}}""",
            "NOTE_COMPLETION");
        var learner = _reader.Read(
            """{"n1":["virus"]}""",
            "NOTE_COMPLETION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
    }

    [Fact]
    public void Empty_learner_payload_scores_0()
    {
        var correct = _reader.Read(
            """{"answers":{"n1":["bacteria"]}}""",
            "NOTE_COMPLETION");
        var learner = _reader.Read("""{}""", "NOTE_COMPLETION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
    }

    [Fact]
    public void Accented_chars_match_via_NFKC_lowercase()
    {
        var correct = _reader.Read(
            """{"answers":{"n1":["café"]}}""",
            "NOTE_COMPLETION");
        var learner = _reader.Read(
            """{"n1":["CAFE"]}""",
            "NOTE_COMPLETION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }
}