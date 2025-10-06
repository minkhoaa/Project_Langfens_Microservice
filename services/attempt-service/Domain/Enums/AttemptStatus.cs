namespace attempt_service.Domain.Enums;

public static class AttemptStatus
{
    public const string Started = "STARTED";
    public const string InProgress = "IN_PROGRESS";
    public const string Submitted = "SUBMITTED";
    public const string Graded = "GRADED";
    public const string Expired = "EXPIRED";
    public const string Cancelled = "CANCELLED";
}