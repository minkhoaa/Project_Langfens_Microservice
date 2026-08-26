using attempt_service.Domain.Entities;

namespace attempt_service.Features.Attempt;

public interface IGradeCalculator
{
    Task ComputeAsync(attempt_service.Domain.Entities.Attempt attempt, IReadOnlyList<AttemptAnswer> rows, CancellationToken ct);
}
