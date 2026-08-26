using System.Text.Json;
using System.Text.Json.Serialization;
using Shared.PublicContracts.Generated;

namespace attempt_service.Features.Helpers;

/// <summary>
/// Grader for <c>YES_NO_NOT_GIVEN</c>. Exact enum match on the
/// <c>YesNoNotGivenAnswerChoice</c> enum (<c>YES</c> / <c>NO</c> / <c>NOT_GIVEN</c>).
/// Mirrors <see cref="TrueFalseNotGivenGrader"/>.
/// </summary>
public sealed class YesNoNotGivenGrader : IGrader
{
    public string Slug => "YES_NO_NOT_GIVEN";

    private sealed record LearnerDto(
        [property: JsonPropertyName("choice")] YesNoNotGivenAnswerChoice? Choice);

    private static readonly JsonSerializerOptions Opts = new(JsonSerializerDefaults.Web);

    public GradeResult Grade(AnswerEnvelope learner, AnswerEnvelope correct, NormalizationConfig _)
    {
        var correctAns = (YesNoNotGivenAnswer)correct.TypedRecord;

        LearnerDto? learnerAns;
        try
        {
            learnerAns = JsonSerializer.Deserialize<LearnerDto>(learner.RawJson, Opts);
        }
        catch
        {
            return new GradeResult(0m, false, FailureReason: "learner answer malformed");
        }
        if (learnerAns?.Choice is null)
            return new GradeResult(0m, false, FailureReason: "no learner choice");

        var matched = learnerAns.Choice.Value == correctAns.Choice;
        return new GradeResult(matched ? 1m : 0m, matched);
    }
}
