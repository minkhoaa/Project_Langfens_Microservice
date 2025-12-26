namespace gamification_service.Domains.Entities;

public class XpTransaction
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public int Amount { get; set; }
    public string Source { get; set; } = null!; // TEST_COMPLETED, CARD_REVIEWED, STREAK_BONUS, DAILY_LOGIN
    public string? SourceId { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}

public static class XpSource
{
    public const string TestCompleted = "TEST_COMPLETED";
    public const string CardReviewed = "CARD_REVIEWED";
    public const string LessonCompleted = "LESSON_COMPLETED";
    public const string DailyLogin = "DAILY_LOGIN";
    public const string StreakBonus = "STREAK_BONUS";
    public const string AchievementUnlocked = "ACHIEVEMENT_UNLOCKED";
}

public static class XpRewards
{
    public const int ReadingTest = 50;
    public const int ListeningTest = 50;
    public const int WritingTest = 75;
    public const int SpeakingTest = 75;
    public const int CardReviewedCorrect = 5;
    public const int CardReviewedWrong = 2;
    public const int LessonCompleted = 30;
    public const int DailyLogin = 10;
    public const int Streak7Days = 100;
    public const int Streak30Days = 500;
}
