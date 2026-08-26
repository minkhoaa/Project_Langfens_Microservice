using System.Text.Json;
using Shared.PublicContracts.Generated;

namespace attempt_service.Features.Helpers;

/// <summary>
/// Grader for <c>MATCHING_ENDINGS</c>. Learner supplies
/// <c>Dictionary&lt;string, string&gt;</c> (beginId → endId); correct answer is
/// <c>ICollection&lt;Pairs4&gt;</c> of <c>(beginId, endId)</c>. Scoring honours the
/// per-answer <c>Scoring</c> enum via <see cref="MatchingScoring"/>.
/// </summary>
public sealed class MatchingEndingsGrader : IGrader
{
    public string Slug => "MATCHING_ENDINGS";

    private static readonly JsonSerializerOptions Opts = new(JsonSerializerDefaults.Web);

    public GradeResult Grade(AnswerEnvelope learner, AnswerEnvelope correct, NormalizationConfig _)
    {
        var correctAns = (MatchingEndingsAnswer)correct.TypedRecord;

        Dictionary<string, string>? learnerMap = null;
        try
        {
            learnerMap = JsonSerializer.Deserialize<Dictionary<string, string>>(learner.RawJson, Opts);
        }
        catch
        {
            // fall through with null → 0 matches
        }

        return MatchingScoring.Score(
            leftId: p => p.BeginId,
            rightId: p => p.EndId,
            learnerAnswers: learnerMap,
            correctPairs: correctAns.Pairs,
            mode: ToMode(correctAns.Scoring));
    }

    private static MatchingScoringMode ToMode(MatchingEndingsAnswerScoring s) => s switch
    {
        MatchingEndingsAnswerScoring.AllOrNothing => MatchingScoringMode.AllOrNothing,
        MatchingEndingsAnswerScoring.Afi => MatchingScoringMode.Afi,
        MatchingEndingsAnswerScoring.Rubric => MatchingScoringMode.Rubric,
        _ => MatchingScoringMode.Proportional,
    };
}
