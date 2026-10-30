using System.Security.Claims;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
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

public record AnswerItem
{
    private string? _textAnswer;

    public Guid QuestionId { get; init; }
    public Guid? SectionId { get; init; }
    public List<Guid>? SelectedOptionIds { get; init; }

    public string? TextAnswer
    {
        get => _textAnswer;
        init
        {
            _textAnswer = value;
            IsTextAnswerSpecified = true;
        }
    }

    [JsonIgnore]
    public bool IsTextAnswerSpecified { get; private set; }

    [JsonConstructor]
    public AnswerItem() { }

    public AnswerItem(Guid QuestionId, Guid? SectionId, List<Guid>? SelectedOptionIds, string? TextAnswer)
    {
        this.QuestionId = QuestionId;
        this.SectionId = SectionId;
        this.SelectedOptionIds = SelectedOptionIds;
        _textAnswer = TextAnswer;
        // Preserve the historical constructor convention: null means no patch.
        IsTextAnswerSpecified = TextAnswer is not null;
    }

    public void Deconstruct(
        out Guid questionId,
        out Guid? sectionId,
        out List<Guid>? selectedOptionIds,
        out string? textAnswer)
    {
        questionId = QuestionId;
        sectionId = SectionId;
        selectedOptionIds = SelectedOptionIds;
        textAnswer = TextAnswer;
    }
}
public record ResultAnswerItem(
    Guid QuestionId,
    Guid? SectionId,
    int Idx,  // Question index for ordering
    List<Guid>? SelectedOptionIds,
    string? TextAnswer,
    bool? IsCorrect,
    string? SelectedAnswerText,
    string? CorrectAnswerText,
    JsonElement? RagFeedback = null
);

public record AutosaveRequest(List<AnswerItem> Answers, long? ClientRevision);

public record SubmitRequest(List<AnswerItem>? Answers);

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
    decimal? WritingBand = null,
    decimal? SpeakingBand = null,
    WritingGradeDto? WritingGrade = null,
    SpeakingGradeDto? SpeakingGrade = null
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
public record PlacementCompletionResponse(
    bool Completed,
    Guid? AttemptId,
    Guid? ExamId,
    string? Status,
    DateTime? StartedAt,
    DateTime? SubmittedAt,
    DateTime? GradedAt,
    string? Level,
    decimal? Band,
    DateTime? CreatedAt,
    DateTime? UpdatedAt);
public record PlacementResultResponse(
    Guid Id,
    Guid UserId,
    Guid ExamId,
    Guid AttemptId,
    int ReadingCorrect,
    int ReadingTotal,
    int ListeningCorrect,
    int ListeningTotal,
    decimal? WritingBand,
    decimal? SpeakingBand,
    int TotalCorrect,
    string Level,
    decimal Band,
    DateTime CreatedAt,
    DateTime UpdatedAt,
    WritingGradeDto? WritingGrade = null,
    SpeakingGradeDto? SpeakingGrade = null);

public record CriterionScoreDto(double Band, string Comment);

public record WritingGradeDto(
    double OverallBand,
    int WordCount,
    CriterionScoreDto? TaskResponse,
    CriterionScoreDto? CoherenceAndCohesion,
    CriterionScoreDto? LexicalResource,
    CriterionScoreDto? GrammaticalRangeAndAccuracy,
    List<string>? Suggestions,
    string? ImprovedParagraph);

public record SpeakingGradeDto(
    double OverallBand,
    string? Transcription,
    CriterionScoreDto? FluencyAndCoherence,
    CriterionScoreDto? LexicalResource,
    CriterionScoreDto? GrammaticalRangeAndAccuracy,
    CriterionScoreDto? Pronunciation,
    List<string>? Suggestions,
    string? ImprovedAnswer);

