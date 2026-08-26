using System.Text.Json;
using System.Text.Json.Serialization;
using Shared.PublicContracts.Generated;

namespace attempt_service.Features.Helpers;

/// <summary>
/// Grader for <c>MULTIPLE_CHOICE_SINGLE_IMAGE</c>. Same exact-match contract as
/// <see cref="MultipleChoiceSingleGrader"/> but for the image-option payload.
/// </summary>
public sealed class MultipleChoiceSingleImageGrader : IGrader
{
    public string Slug => "MULTIPLE_CHOICE_SINGLE_IMAGE";

    private sealed record LearnerDto(
        [property: JsonPropertyName("selectedOptionId")] string? SelectedOptionId);

    private static readonly JsonSerializerOptions Opts = new(JsonSerializerDefaults.Web);

    public GradeResult Grade(AnswerEnvelope learner, AnswerEnvelope correct, NormalizationConfig _)
    {
        var correctAns = (MultipleChoiceSingleImageAnswer)correct.TypedRecord;
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
