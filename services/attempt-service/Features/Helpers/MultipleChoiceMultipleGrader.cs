using System.Text.Json;
using System.Text.Json.Serialization;
using Shared.PublicContracts.Generated;

namespace attempt_service.Features.Helpers;

/// <summary>
/// Grader for <c>MULTIPLE_CHOICE_MULTIPLE</c>. Three scoring modes per SSOT:
/// <list type="bullet">
/// <item><c>all-or-nothing</c> — full credit iff sets match exactly.</item>
/// <item><c>proportional</c> — credit = max(0, (correct − wrong) / total).</item>
/// <item><c>afi</c> (any-fully-correct-item) — credit = correct / total; wrong picks do not penalise.</item>
/// </list>
/// <c>rubric</c> is human/AI-graded and is not handled here.
/// </summary>
public sealed class MultipleChoiceMultipleGrader : IGrader
{
    public string Slug => "MULTIPLE_CHOICE_MULTIPLE";

    private sealed record LearnerDto(
        [property: JsonPropertyName("selectedOptionIds")] string[]? SelectedOptionIds);

    private static readonly JsonSerializerOptions Opts = new(JsonSerializerDefaults.Web);

    public GradeResult Grade(AnswerEnvelope learner, AnswerEnvelope correct, NormalizationConfig _)
    {
        var correctAns = (MultipleChoiceMultipleAnswer)correct.TypedRecord;

        LearnerDto? learnerAns;
        try
        {
            learnerAns = JsonSerializer.Deserialize<LearnerDto>(learner.RawJson, Opts);
        }
        catch
        {
            return new GradeResult(0m, false, FailureReason: "learner answer malformed");
        }
        var learnerIds = learnerAns?.SelectedOptionIds ?? Array.Empty<string>();

        var correctSet = new HashSet<string>(correctAns.CorrectOptionIds, StringComparer.Ordinal);
        var learnerSet = new HashSet<string>(learnerIds, StringComparer.Ordinal);

        var intersection = 0;
        foreach (var id in learnerSet)
            if (correctSet.Contains(id)) intersection++;
        var wrong = learnerSet.Count - intersection;
        var totalCorrect = correctSet.Count;

        return correctAns.Scoring switch
        {
            MultipleChoiceMultipleAnswerScoring.Afi => ScoreAfi(intersection, totalCorrect),
            MultipleChoiceMultipleAnswerScoring.Proportional => ScoreProportional(intersection, wrong, totalCorrect),
            MultipleChoiceMultipleAnswerScoring.Rubric =>
                new GradeResult(0m, false, NeedsManualReview: true, FailureReason: "rubric scoring requires manual review"),
            _ => ScoreAllOrNothing(learnerSet, correctSet),
        };
    }

    private static GradeResult ScoreAllOrNothing(HashSet<string> a, HashSet<string> b)
    {
        var ok = a.SetEquals(b);
        return new GradeResult(ok ? 1m : 0m, ok);
    }

    private static GradeResult ScoreProportional(int intersection, int wrong, int total)
    {
        if (total == 0) return new GradeResult(0m, false);
        var awarded = Math.Max(0m, (decimal)(intersection - wrong) / total);
        return new GradeResult(awarded, awarded >= 1m);
    }

    private static GradeResult ScoreAfi(int intersection, int total)
    {
        if (total == 0) return new GradeResult(0m, false);
        var awarded = (decimal)intersection / total;
        return new GradeResult(awarded, intersection == total);
    }
}
