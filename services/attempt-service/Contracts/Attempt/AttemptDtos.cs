using System.Security.Claims;
using System.Text;
using System.Text.Json;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion.Internal;

namespace attempt_service.Contracts.Attempt;

public record AttemptStartRequest(Guid ExamId);

public record AttemptStartResponse(Guid AttemptId, JsonElement Paper, DateTime StartedAt, int DurationSec, int timeLeft);


public record AttemptGetResponse(
    Guid AttemptId,
    string Status,
    JsonElement Paper,
    List<AnswerItem> Answers,
    DateTime StartedAt,
    int TimeLeftSec);

public record AnswerItem(Guid QuestionId, Guid? SectionId, List<Guid>? SelectedOptionIds, string? TextAnswer);
public record ResultAnswerItem(
    Guid QuestionId,
    Guid? SectionId,
    List<Guid>? SelectedOptionIds,
    string? TextAnswer,
    bool? IsCorrect,
    string? SelectedAnswerText,
    string? CorrectAnswerText
);

public record AutosaveRequest(List<AnswerItem> Answers, long? ClientRevision);

public record SubmitResponse(Guid AttemptId, string Status, decimal ScoreRaw, decimal ScorePct, int Correct, int Total);

public record AttemptResultResponse(
    Guid AttemptId,
    string Status,
    DateTime? SubmittedAt,
    TimeSpan? TotalTime,
    DateTime? GradedAt,
    decimal ScoreRaw,
    decimal ScorePct,
    int Correct,
    int Total,
    JsonElement PaperWithAnswers,
    List<ResultAnswerItem> Answers,
    decimal? IeltsBand,
    string? PlacementLevel = null,
    decimal? PlacementBand = null,
    int? ReadingCorrect = null,
    int? ListeningCorrect = null,
    decimal? WritingBand = null
);
public record AttemptListItem(
    Guid AttemptId,
    Guid ExamId,
    string Status,
    DateTime StartedAt,
    DateTime? SubmittedAt,
    decimal? ScorePct,
    string? Title
);

public record AttemptListResponse(
    int Total,
    int Page,
    int PageSize,
    List<AttemptListItem> Items
);
public record PlacementResultResponse(
    Guid Id,
    Guid UserId,
    Guid ExamId,
    Guid AttemptId,
    int ReadingCorrect,
    int ListeningCorrect,
    decimal? WritingBand,
    int TotalCorrect,
    string Level,
    decimal Band,
    DateTime CreatedAt,
    DateTime UpdatedAt);
