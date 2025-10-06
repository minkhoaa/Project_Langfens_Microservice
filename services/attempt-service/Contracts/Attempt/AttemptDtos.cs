using System.Text.Json;

namespace attempt_service.Contracts.Attempt;

public record AttemptStartRequest(int ExamId);

public record AttemptStartResponse(int AttemptId, JsonElement Paper, DateTime StartedAt, int DurationSec);

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