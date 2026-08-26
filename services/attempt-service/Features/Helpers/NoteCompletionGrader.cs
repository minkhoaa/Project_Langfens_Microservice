using System.Text.Json;
using Shared.PublicContracts.Generated;

namespace attempt_service.Features.Helpers;

/// <summary>
/// Grader for <c>NOTE_COMPLETION</c>. Per-gap normalised exact match
/// (delegates to <see cref="CompletionScoring"/>).
/// </summary>
public sealed class NoteCompletionGrader(ITextNormalizer normalizer) : IGrader
{
    public string Slug => "NOTE_COMPLETION";

    private static readonly JsonSerializerOptions Opts = new(JsonSerializerDefaults.Web);

    public GradeResult Grade(AnswerEnvelope learner, AnswerEnvelope correct, NormalizationConfig norm)
    {
        var correctAns = (NoteCompletionAnswer)correct.TypedRecord;
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
