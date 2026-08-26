using attempt_service.Domain.Entities;

namespace attempt_service.Features.Attempt;

/// <summary>
/// Stub calculator: sums awarded points into <c>RawScore</c> and echoes the
/// rounded total into <c>ScaledScore</c>. IELTS band conversion is layered
/// on top once a real calculator lands (Task 18 placeholder).
/// </summary>
public sealed class GradeCalculator : IGradeCalculator
{
    public Task ComputeAsync(attempt_service.Domain.Entities.Attempt attempt, IReadOnlyList<AttemptAnswer> rows, CancellationToken ct)
    {
        attempt.RawScore = Math.Round(rows.Sum(r => r.AwardedPoints ?? 0m), 2);
        attempt.ScaledScore = attempt.RawScore;
        return Task.CompletedTask;
    }
}
