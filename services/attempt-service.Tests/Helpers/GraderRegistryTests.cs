using attempt_service.Features.Helpers;
using Xunit;

namespace attempt_service.Tests.Helpers;

/// <summary>
/// Locks <see cref="GraderRegistry"/>: resolves every one of the 21 canonical
/// slugs to its concrete grader, throws <see cref="UnknownQuestionTypeException"/>
/// for unknown slugs, and round-trips slug strings case-sensitively.
/// </summary>
public sealed class GraderRegistryTests
{
    private readonly GraderRegistry _registry = new(new IGrader[]
    {
        new MultipleChoiceSingleGrader(),
        new MultipleChoiceSingleImageGrader(),
        new MultipleChoiceMultipleGrader(),
        new TrueFalseNotGivenGrader(),
        new YesNoNotGivenGrader(),
        new SummaryCompletionGrader(new TextNormalizer()),
        new TableCompletionGrader(new TextNormalizer()),
        new NoteCompletionGrader(new TextNormalizer()),
        new FormCompletionGrader(new TextNormalizer()),
        new SentenceCompletionGrader(new TextNormalizer()),
        new MatchingHeadingGrader(),
        new MatchingInformationGrader(),
        new MatchingFeaturesGrader(),
        new MatchingEndingsGrader(),
        new ClassificationGrader(),
        new DiagramLabelGrader(new TextNormalizer()),
        new MapLabelGrader(new TextNormalizer()),
        new FlowChartGrader(),
        new FlowChartCompletionGrader(new TextNormalizer()),
        new ShortAnswerGrader(new TextNormalizer()),
        new AudioResponseGrader(),
    });

    public static IEnumerable<object[]> AllSlugs => new[]
    {
        new object[] { "MULTIPLE_CHOICE_SINGLE" },
        new object[] { "MULTIPLE_CHOICE_SINGLE_IMAGE" },
        new object[] { "MULTIPLE_CHOICE_MULTIPLE" },
        new object[] { "TRUE_FALSE_NOT_GIVEN" },
        new object[] { "YES_NO_NOT_GIVEN" },
        new object[] { "SUMMARY_COMPLETION" },
        new object[] { "TABLE_COMPLETION" },
        new object[] { "NOTE_COMPLETION" },
        new object[] { "FORM_COMPLETION" },
        new object[] { "SENTENCE_COMPLETION" },
        new object[] { "MATCHING_HEADING" },
        new object[] { "MATCHING_INFORMATION" },
        new object[] { "MATCHING_FEATURES" },
        new object[] { "MATCHING_ENDINGS" },
        new object[] { "CLASSIFICATION" },
        new object[] { "DIAGRAM_LABEL" },
        new object[] { "MAP_LABEL" },
        new object[] { "FLOW_CHART" },
        new object[] { "FLOW_CHART_COMPLETION" },
        new object[] { "SHORT_ANSWER" },
        new object[] { "AUDIO_RESPONSE" },
    };

    [Theory]
    [MemberData(nameof(AllSlugs))]
    public void Resolves_all_21_slugs(string slug)
    {
        var grader = _registry.Resolve(slug);
        Assert.NotNull(grader);
        Assert.Equal(slug, grader.Slug);
    }

    [Theory]
    [MemberData(nameof(AllSlugs))]
    public void TryResolve_returns_true_for_all_21_slugs(string slug)
    {
        Assert.True(_registry.TryResolve(slug, out var grader));
        Assert.NotNull(grader);
    }

    [Fact]
    public void Unknown_slug_throws_UnknownQuestionTypeException()
    {
        var ex = Assert.Throws<UnknownQuestionTypeException>(
            () => _registry.Resolve("UNKNOWN_SLUG"));
        Assert.Contains("UNKNOWN_SLUG", ex.Message);
    }

    [Fact]
    public void TryResolve_returns_false_for_unknown_slug()
    {
        Assert.False(_registry.TryResolve("UNKNOWN_SLUG", out var grader));
        Assert.Null(grader);
    }

    [Fact]
    public void Registry_count_matches_21()
    {
        Assert.Equal(21, AllSlugs.Count());
    }

    [Fact]
    public void Registry_is_case_sensitive()
    {
        // Lowercase version of a valid slug should not resolve.
        Assert.False(_registry.TryResolve("multiple_choice_single", out var _));
    }
}