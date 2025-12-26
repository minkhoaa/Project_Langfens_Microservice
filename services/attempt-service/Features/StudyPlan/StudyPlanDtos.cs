namespace attempt_service.Features.StudyPlan;

// Request DTOs
public record CreateGoalRequest(
    decimal TargetBandScore,
    DateTime TargetDate,
    List<string> FocusSkills,
    decimal StudyHoursPerDay
);

// Response DTOs
public record StudyGoalDto(
    Guid Id,
    decimal TargetBandScore,
    DateTime TargetDate,
    List<string> FocusSkills,
    decimal StudyHoursPerDay,
    bool IsActive,
    DateTime CreatedAt
);

public record WeeklyTargetsDto(
    int TestsPerWeek,
    decimal HoursPerDay,
    Dictionary<string, int> FocusDistribution
);

public record CreateGoalResponseDto(
    Guid Id,
    int DaysRemaining,
    WeeklyTargetsDto WeeklyTargets
);

public record CurrentProgressDto(
    decimal AvgScore,
    int TestsCompleted,
    int StudyTimeHours
);

public record ProgressMetricsDto(
    int ScoreProgress,
    int TimeProgress,
    string Status // ON_TRACK, BEHIND, AHEAD
);

public record GoalProgressDto(
    StudyGoalDto Goal,
    CurrentProgressDto Current,
    ProgressMetricsDto Progress
);
