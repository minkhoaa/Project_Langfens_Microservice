using System.Text;
using System.Text.Json;

namespace attempt_service.Contracts.Attempt;

public record AttemptStartRequest(Guid ExamId);

public record AttemptStartResponse(Guid AttemptId, JsonElement Paper, DateTime StartedAt, int DurationSec, int timeLeft);

public record AttemptGetRequest(Guid AttemptId, Guid UserId);

public record AttemptGetResponse(
    Guid AttemptId,
    string Status,
    JsonElement Paper,
    List<AnswerItem> Answers,
    DateTime StartedAt,
    int TimeLeftSec);

public record AnswerItem(Guid QuestionId, Guid? SectionId, List<Guid>? SelectedOptionIds, string? TextAnswer);

public record AutosaveRequest(List<AnswerItem> Answers, long? ClientRevision);

public record SubmitResponse(Guid AttemptId, string Status, decimal ScoreRaw, decimal ScorePct, int Correct, int Total);

public record AttemptResultResponse(
    Guid AttemptId,
    string Status,
    DateTime? SubmittedAt,
    DateTime? GradedAt,
    decimal ScoreRaw,
    decimal ScorePct,
    int Correct,
    int Total,
    JsonElement PaperWithAnswers,
    List<AnswerItem> Answers
);
public record AttemptListItem(
    Guid AttemptId,
    Guid ExamId,
    string Status,
    DateTime StartedAt,
    DateTime? SubmittedAt,
    decimal? ScorePct
);

public record AttemptListResponse(
    int Total,
    int Page,
    int PageSize,
    List<AttemptListItem> Items
);
