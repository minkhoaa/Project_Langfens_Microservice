using Shared.ExamDto.Contracts.Exam.Enums;
using Xunit;

namespace attempt_service.Tests.Helpers;

/// <summary>
/// Locks parity between the BE <see cref="QuestionType"/> constants and the
/// SSOT canonical slugs defined in
/// <c>schemas/question-schema/src/discriminator.ts</c> (the
/// <c>QUESTION_TYPES</c> array, lines 2-24).
///
/// Both arrays below MUST be kept in the canonical SSOT order. The C#
/// constants in <c>QuestionType.cs</c> are grouped by category and therefore
/// are not in this order — that grouping is fine for the source file; this
/// test pairs each canonical slug with the correct C# constant by name.
/// </summary>
public class QuestionTypeParityTests
{
    private static readonly string[] SsotCanonical = new[]
    {
        "MULTIPLE_CHOICE_SINGLE",
        "MULTIPLE_CHOICE_SINGLE_IMAGE",
        "MULTIPLE_CHOICE_MULTIPLE",
        "TRUE_FALSE_NOT_GIVEN",
        "YES_NO_NOT_GIVEN",
        "SUMMARY_COMPLETION",
        "TABLE_COMPLETION",
        "NOTE_COMPLETION",
        "FORM_COMPLETION",
        "SENTENCE_COMPLETION",
        "SHORT_ANSWER",
        "AUDIO_RESPONSE",
        "DIAGRAM_LABEL",
        "MAP_LABEL",
        "MATCHING_HEADING",
        "MATCHING_INFORMATION",
        "MATCHING_FEATURES",
        "MATCHING_ENDINGS",
        "CLASSIFICATION",
        "FLOW_CHART",
        "FLOW_CHART_COMPLETION",
    };

    private static readonly string[] LocalConsts = new[]
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

    [Fact]
    public void QuestionType_HasExactly21Constants()
    {
        Assert.Equal(21, LocalConsts.Length);
    }

    [Fact]
    public void QuestionType_MatchesSsotCanonicalOrder()
    {
        Assert.Equal(SsotCanonical, LocalConsts);
    }
}
