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

// Wrong answers / Error review
public record WrongAnswerDto(
    Guid AnswerId,
    Guid QuestionId,
    string QuestionContent,
    string QuestionType,
    string Skill,
    string SectionTitle,
    string UserAnswer,
    string CorrectAnswer,
    string? Explanation,
    DateTime AttemptDate,
    Guid ExamId,
    Guid AttemptId
);

public record WrongAnswersResultDto(
    List<WrongAnswerDto> Items,
    int Total,
    int Page,
    int PageSize,
    Dictionary<string, int> StatsByType
);

// Band prediction
public record PredictedBandDto(
    decimal OverallBand,
    string Confidence,
    decimal? ReadingBand,
    decimal? ListeningBand,
    decimal? WritingBand,
    decimal? SpeakingBand,
    int SampleSize,
    DateTime? LatestAttemptDate
);

