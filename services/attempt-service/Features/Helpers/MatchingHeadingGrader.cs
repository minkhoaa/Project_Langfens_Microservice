using System.Text.Json;
using Shared.PublicContracts.Generated;

namespace attempt_service.Features.Helpers;

/// <summary>
/// Grader for <c>MATCHING_HEADING</c>. Learner supplies
/// <c>Dictionary&lt;string, string&gt;</c> (paragraphId → headingId); correct answer is
/// <c>ICollection&lt;Pairs&gt;</c> of <c>(paragraphId, headingId)</c>. Scoring honours the
/// per-answer <c>Scoring</c> enum (<c>all-or-nothing</c> / <c>proportional</c> /
/// <c>afi</c> / <c>rubric</c>) via <see cref="MatchingScoring"/>.
/// </summary>
public sealed class MatchingHeadingGrader : IGrader
{
    public string Slug => "MATCHING_HEADING";

    private static readonly JsonSerializerOptions Opts = new(JsonSerializerDefaults.Web);

    public GradeResult Grade(AnswerEnvelope learner, AnswerEnvelope correct, NormalizationConfig _)
    {
        var correctAns = (MatchingHeadingAnswer)correct.TypedRecord;

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
            leftId: p => p.ParagraphId,
            rightId: p => p.HeadingId,
            learnerAnswers: learnerMap,
            correctPairs: correctAns.Pairs,
            mode: ToMode(correctAns.Scoring));
    }

    private static MatchingScoringMode ToMode(MatchingHeadingAnswerScoring s) => s switch
    {
        MatchingHeadingAnswerScoring.AllOrNothing => MatchingScoringMode.AllOrNothing,
        MatchingHeadingAnswerScoring.Afi => MatchingScoringMode.Afi,
        MatchingHeadingAnswerScoring.Rubric => MatchingScoringMode.Rubric,
        _ => MatchingScoringMode.Proportional,
    };
}
