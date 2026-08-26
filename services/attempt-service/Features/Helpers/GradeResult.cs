namespace attempt_service.Features.Helpers;

public sealed record GradeResult(
    decimal AwardedPoints,
    bool IsCorrect,
    bool NeedsManualReview = false,
    string? FailureReason = null);