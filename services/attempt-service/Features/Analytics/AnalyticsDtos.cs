namespace attempt_service.Features.Analytics;

// Summary response
public record AnalyticsSummaryDto(
    int TotalAttempts,
    int TotalStudyTimeMin,
    decimal AvgScore,
    int CurrentStreak,
    Dictionary<string, int> TestsBySkill
);

// Score trend response
public record ScoreTrendPointDto(
    DateOnly Date,
    decimal AvgScore,
    int TestCount
);

public record ScoreTrendDto(List<ScoreTrendPointDto> Data);

// Strengths/weaknesses
public record QuestionTypeAccuracyDto(
    string Type,
    double Accuracy,
    int TotalQuestions,
    int CorrectAnswers
);

public record StrengthsWeaknessesDto(
    List<QuestionTypeAccuracyDto> Strengths,
    List<QuestionTypeAccuracyDto> Weaknesses
);

// Recent activity
public record RecentActivityDto(
    string Type,
    Guid ExamId,
    string? ExamTitle,
    decimal? Score,
    DateTime Date,
    int DurationMin
);

public record RecentActivitiesDto(List<RecentActivityDto> Activities);
