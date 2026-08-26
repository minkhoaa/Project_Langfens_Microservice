using System.Text.Json;
using Shared.PublicContracts.Generated;

namespace attempt_service.Features.Helpers;

/// <summary>
/// Grader for <c>CLASSIFICATION</c>. Learner supplies
/// <c>Dictionary&lt;string, string&gt;</c> (itemId → categoryId); correct answer is
/// <c>ICollection&lt;Pairs5&gt;</c> of <c>(itemId, categoryId)</c>. Scoring honours the
/// per-answer <c>Scoring</c> enum via <see cref="MatchingScoring"/>. This is
/// standalone — it does not delegate to <c>SingleChoiceGrader</c> (spec §4.4).
/// </summary>
public sealed class ClassificationGrader : IGrader
{
    public string Slug => "CLASSIFICATION";

    private static readonly JsonSerializerOptions Opts = new(JsonSerializerDefaults.Web);

    public GradeResult Grade(AnswerEnvelope learner, AnswerEnvelope correct, NormalizationConfig _)
    {
        var correctAns = (ClassificationAnswer)correct.TypedRecord;

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
            rightId: p => p.CategoryId,
            learnerAnswers: learnerMap,
            correctPairs: correctAns.Pairs,
            mode: ToMode(correctAns.Scoring));
    }

    private static MatchingScoringMode ToMode(ClassificationAnswerScoring s) => s switch
    {
        ClassificationAnswerScoring.AllOrNothing => MatchingScoringMode.AllOrNothing,
        ClassificationAnswerScoring.Afi => MatchingScoringMode.Afi,
        ClassificationAnswerScoring.Rubric => MatchingScoringMode.Rubric,
        _ => MatchingScoringMode.Proportional,
    };
}
