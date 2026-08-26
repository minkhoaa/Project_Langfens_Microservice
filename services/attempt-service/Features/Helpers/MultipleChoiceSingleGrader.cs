using System.Text.Json;
using System.Text.Json.Serialization;
using Shared.PublicContracts.Generated;

namespace attempt_service.Features.Helpers;

/// <summary>
/// Grader for <c>MULTIPLE_CHOICE_SINGLE</c>. Learner wire carries
/// <c>selectedOptionId</c>; correct-answer wire carries <c>correctOptionId</c>.
/// Full credit (1.0) iff the selected id matches exactly; otherwise 0.
/// </summary>
public sealed class MultipleChoiceSingleGrader : IGrader
{
    public string Slug => "MULTIPLE_CHOICE_SINGLE";

    private sealed record LearnerDto(
        [property: JsonPropertyName("selectedOptionId")] string? SelectedOptionId);

    private static readonly JsonSerializerOptions Opts = new(JsonSerializerDefaults.Web);

    public GradeResult Grade(AnswerEnvelope learner, AnswerEnvelope correct, NormalizationConfig _)
    {
        var correctAns = (MultipleChoiceSingleAnswer)correct.TypedRecord;
        LearnerDto? learnerAns;
        try
        {
            learnerAns = JsonSerializer.Deserialize<LearnerDto>(learner.RawJson, Opts);
        }
        catch
        {
            return new GradeResult(0m, false, FailureReason: "learner answer malformed");
        }
        if (learnerAns is null || string.IsNullOrEmpty(learnerAns.SelectedOptionId))
            return new GradeResult(0m, false, FailureReason: "no learner selection");

        var matched = string.Equals(learnerAns.SelectedOptionId, correctAns.CorrectOptionId, StringComparison.Ordinal);
        return new GradeResult(matched ? 1m : 0m, matched);
    }
}
