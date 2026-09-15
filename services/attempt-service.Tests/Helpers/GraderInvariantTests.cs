using Xunit;
using attempt_service.Features.Helpers;

namespace attempt_service.Tests.Helpers;

/// <summary>
/// D1 invariant guard: <c>AwardedPoints ∈ { 0, QuestionPoints }</c> for any
/// all-or-nothing grader. <see cref="GraderScoring.ScoreFor"/> is the single
/// source of truth and must never return a partial-credit value.
/// </summary>
public class GraderInvariantTests
{
    [Theory]
    [InlineData(0.5, 0.5)]
    [InlineData(1, 1)]
    [InlineData(2.5, 2.5)]
    [InlineData(100, 100)]
    public void ScoreFor_when_isCorrect_returns_questionPoints(double questionPoints, double expected)
    {
        var result = GraderScoring.ScoreFor(true, (decimal)questionPoints);
        Assert.Equal((decimal)expected, result);
    }

    [Theory]
    [InlineData(0.5)]
    [InlineData(1)]
    [InlineData(2.5)]
    [InlineData(100)]
    public void ScoreFor_when_not_isCorrect_returns_zero(double questionPoints)
    {
        var result = GraderScoring.ScoreFor(false, (decimal)questionPoints);
        Assert.Equal(0m, result);
    }

    [Theory]
    [InlineData(1)]
    [InlineData(2.5)]
    [InlineData(100)]
    public void ScoreFor_output_is_never_a_partial_value(double questionPoints)
    {
        var qp = (decimal)questionPoints;
        var matched = GraderScoring.ScoreFor(true, qp);
        var unmatched = GraderScoring.ScoreFor(false, qp);

        // Invariant: result is either 0 or qp, never a fraction in between.
        Assert.True(matched == 0m || matched == qp,
            $"GraderScoring.ScoreFor(true, {qp}) returned {matched} which is not 0 or {qp}");
        Assert.True(unmatched == 0m || unmatched == qp,
            $"GraderScoring.ScoreFor(false, {qp}) returned {unmatched} which is not 0 or {qp}");
    }
}
