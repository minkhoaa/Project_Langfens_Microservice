using System.Text.Json;
using Shared.PublicContracts.Generated;

namespace attempt_service.Features.Helpers;

/// <summary>
/// Grader for <c>MAP_LABEL</c>. Wire shape is identical to the completion types:
/// learner answer is <c>Dictionary&lt;string, ICollection&lt;string&gt;&gt;</c>
/// (gapId → list of user strings); correct answer is the same dictionary keyed by gap id
/// with the list of accepted strings. Per-gap rule: a learner pick matches if any
/// normalised accepted string equals any normalised user pick. Delegates to
/// <see cref="CompletionScoring"/>.
/// </summary>
public sealed class MapLabelGrader(ITextNormalizer normalizer) : IGrader
{
    public string Slug => "MAP_LABEL";

    private static readonly JsonSerializerOptions Opts = new(JsonSerializerDefaults.Web);

    public GradeResult Grade(AnswerEnvelope learner, AnswerEnvelope correct, NormalizationConfig norm)
    {
        var correctAns = (MapLabelAnswer)correct.TypedRecord;

        Dictionary<string, ICollection<string>>? learnerDict = null;
        try
        {
            learnerDict = JsonSerializer.Deserialize<Dictionary<string, ICollection<string>>>(learner.RawJson, Opts);
        }
        catch
        {
            // fall through with null → all gaps score 0
        }

        return CompletionScoring.Score(
            normalizer,
            learnerDict,
            new Dictionary<string, ICollection<string>>(correctAns.Answers, StringComparer.Ordinal),
            norm);
    }
}
