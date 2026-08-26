using System.Text.Json;
using Shared.PublicContracts.Generated;

namespace attempt_service.Features.Helpers;

/// <summary>
/// Grader for <c>MATCHING_FEATURES</c>. Learner supplies
/// <c>Dictionary&lt;string, string&gt;</c> (itemId → featureId); correct answer is
/// <c>ICollection&lt;Pairs3&gt;</c> of <c>(itemId, featureId)</c>. Scoring honours the
/// per-answer <c>Scoring</c> enum via <see cref="MatchingScoring"/>.
/// </summary>
public sealed class MatchingFeaturesGrader : IGrader
{
    public string Slug => "MATCHING_FEATURES";

    private static readonly JsonSerializerOptions Opts = new(JsonSerializerDefaults.Web);

    public GradeResult Grade(AnswerEnvelope learner, AnswerEnvelope correct, NormalizationConfig _)
    {
        var correctAns = (MatchingFeaturesAnswer)correct.TypedRecord;

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
            leftId: p => p.ItemId,
            rightId: p => p.FeatureId,
            learnerAnswers: learnerMap,
            correctPairs: correctAns.Pairs,
            mode: ToMode(correctAns.Scoring));
    }

    private static MatchingScoringMode ToMode(MatchingFeaturesAnswerScoring s) => s switch
    {
        MatchingFeaturesAnswerScoring.AllOrNothing => MatchingScoringMode.AllOrNothing,
        MatchingFeaturesAnswerScoring.Afi => MatchingScoringMode.Afi,
        MatchingFeaturesAnswerScoring.Rubric => MatchingScoringMode.Rubric,
        _ => MatchingScoringMode.Proportional,
    };
}
