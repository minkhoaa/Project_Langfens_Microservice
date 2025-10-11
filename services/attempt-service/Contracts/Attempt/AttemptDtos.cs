using System.Text.Json;

namespace attempt_service.Contracts.Attempt;

public record AttemptStartRequest(int ExamId);

public record AttemptStartResponse(int AttemptId, JsonElement Paper, DateTime StartedAt, int DurationSec, int timeLeft);

public record AttemptGetRequest(int AttemptId, int UserId);

public record AttemptGetResponse(
    int AttemptId,
    string Status,
    JsonElement Paper,
    List<AnswerItem> Answers,
    DateTime StartedAt,
    int TimeLeftSec);

public record AnswerItem(int QuestionId, int? SectionId, List<int>? SelectedOptionIds, string? TextAnswer);

public record AutosaveRequest(List<AnswerItem> Answers, long? ClientRevision);

public record SubmitResponse(int AttemptId, string Status, decimal ScoreRaw, decimal ScorePct, int Correct, int Total);

public record AttemptResultResponse(
    int AttemptId,
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
    int AttemptId,
    int ExamId,
    string Status,
    DateTime StartedAt,
    DateTime? SubmittedAt,
    double? ScorePct
);

public record AttemptListResponse(
    int Total,
    int Page,
    int PageSize,
    List<AttemptListItem> Items
);