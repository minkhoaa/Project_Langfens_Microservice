using attempt_service.Features.Helpers;
using Shared.ExamDto.Contracts.Exam.Enums;
using Xunit;

namespace attempt_service.Tests.Helpers;

/// <summary>
/// Phase 5: locks QuestionKey.IsValidType against the 21 canonical SSOT
/// slugs and rejects null/empty/typo/legacy alias input.
/// </summary>
public class QuestionKeyIsValidTypeTests
{
    [Fact]
    public void IsValidType_accepts_all_21_canonical_slugs()
    {
        var canonical = new[]
        {
            QuestionType.MultipleChoiceSingle,
            QuestionType.MultipleChoiceSingleImage,
            QuestionType.MultipleChoiceMultiple,
            QuestionType.TrueFalseNotGiven,
            QuestionType.YesNoNotGiven,
            QuestionType.SummaryCompletion,
            QuestionType.TableCompletion,
            QuestionType.NoteCompletion,
            QuestionType.FormCompletion,
            QuestionType.SentenceCompletion,
            QuestionType.ShortAnswer,
            QuestionType.AudioResponse,
            QuestionType.DiagramLabel,
            QuestionType.MapLabel,
            QuestionType.MatchingHeading,
            QuestionType.MatchingInformation,
            QuestionType.MatchingFeatures,
            QuestionType.MatchingEndings,
            QuestionType.Classification,
            QuestionType.FlowChart,
            QuestionType.FlowChartCompletion,
        };

        Assert.Equal(21, canonical.Length);

        foreach (var slug in canonical)
        {
            Assert.True(QuestionKey.IsValidType(slug),
                $"Expected '{slug}' to be a valid QuestionType slug");
        }
    }

    [Theory]
    [InlineData("")]
    [InlineData(null)]
    [InlineData("BOGUS")]
    [InlineData("MCQ_SINGLE")]       // removed in Phase 1
    [InlineData("MCQ_SINGLE_IMAGE")] // removed in Phase 1
    [InlineData("classification")]   // case-sensitive — only canonical casing accepted
    public void IsValidType_rejects_empty_null_unknown(string? input)
    {
        Assert.False(QuestionKey.IsValidType(input));
    }
}