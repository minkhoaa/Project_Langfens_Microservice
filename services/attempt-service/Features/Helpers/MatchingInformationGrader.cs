using System.Text.Json;
using Shared.PublicContracts.Generated;

namespace attempt_service.Features.Helpers;

/// <summary>
/// Grader for <c>MATCHING_INFORMATION</c>. Learner supplies
/// <c>Dictionary&lt;string, string&gt;</c> (questionId → paragraphId); correct answer is
/// <c>ICollection&lt;Pairs2&gt;</c> of <c>(questionId, paragraphId)</c>. Scoring honours
/// the per-answer <c>Scoring</c> enum via <see cref="MatchingScoring"/>.
/// </summary>
public sealed class MatchingInformationGrader : IGrader
{
    public string Slug => "MATCHING_INFORMATION";

    private static readonly JsonSerializerOptions Opts = new(JsonSerializerDefaults.Web);

    public GradeResult Grade(AnswerEnvelope learner, AnswerEnvelope correct, NormalizationConfig _)
    {
        var correctAns = (MatchingInformationAnswer)correct.TypedRecord;

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
            leftId: p => p.QuestionId,
            rightId: p => p.ParagraphId,
            learnerAnswers: learnerMap,
            correctPairs: correctAns.Pairs,
            mode: ToMode(correctAns.Scoring));
    }

    private static MatchingScoringMode ToMode(MatchingInformationAnswerScoring s) => s switch
    {
        MatchingInformationAnswerScoring.AllOrNothing => MatchingScoringMode.AllOrNothing,
        MatchingInformationAnswerScoring.Afi => MatchingScoringMode.Afi,
        MatchingInformationAnswerScoring.Rubric => MatchingScoringMode.Rubric,
        _ => MatchingScoringMode.Proportional,
    };
}
