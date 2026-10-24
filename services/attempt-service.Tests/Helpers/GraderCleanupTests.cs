using System.Text.Json;
using Xunit;
using attempt_service.Domain.Entities;
using attempt_service.Features.Helpers;

namespace attempt_service.Tests.Helpers;

/// <summary>
/// Sprint 3 G10 grader cleanup tests:
///  - MatchingHeadingGrader feedback strings on each branch
///  - FlowChartGrader exact-match (sequence-equal) per spec §11.11
/// </summary>
public class GraderCleanupTests
{
    // ---------- MatchingHeadingGrader ----------

    private static AttemptAnswer MakeAnswer(string? text) => new()
    {
        Id = Guid.NewGuid(),
        AttemptId = Guid.NewGuid(),
        SectionId = Guid.NewGuid(),
        QuestionId = Guid.NewGuid(),
        TextAnswer = text,
    };

    private static QuestionKey MatchingKey(Dictionary<string, string[]?> pairs) => new(
        QuestionId: Guid.NewGuid(),
        QuestionType: "MATCHING_HEADING",
        QuestionPoints: 2m,
        MatchPairs: pairs);

    [Fact]
    public void MatchingHeading_happy_path_all_pairs_match_returns_full_points_and_null_feedback()
    {
        var pairs = new Dictionary<string, string[]?>(StringComparer.OrdinalIgnoreCase)
        {
            ["i"] = new[] { "iv" },
            ["ii"] = new[] { "i" },
            ["iii"] = new[] { "vi" },
        };
        var key = MatchingKey(pairs);
        // Sorted by value so order in JSON does not matter.
        var raw = JsonSerializer.Serialize(new Dictionary<string, string>
        {
            ["i"] = "iv",
            ["ii"] = "i",
            ["iii"] = "vi",
        });

        var result = new MatchingHeadingGrader().Grade(MakeAnswer(raw), key);

        Assert.Equal(2m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
        Assert.Null(result.Feedback);
    }

    [Fact]
    public void MatchingHeading_json_with_partial_matches_awards_partial_points()
    {
        var pairs = new Dictionary<string, string[]?>(StringComparer.OrdinalIgnoreCase)
        {
            ["i"] = new[] { "iv" },
            ["ii"] = new[] { "i" },
            ["iii"] = new[] { "vi" },
        };
        var key = MatchingKey(pairs);
        var raw = JsonSerializer.Serialize(new Dictionary<string, string>
        {
            ["i"] = "iv",
            ["ii"] = "WRONG",
            ["iii"] = "vi",
        });

        var result = new MatchingHeadingGrader().Grade(MakeAnswer(raw), key);

        // 2 out of 3 matched with 2.0 total points -> 1.33m
        Assert.Equal(1.33m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
        Assert.Equal("2/3 pairs matched", result.Feedback);
    }

    [Fact]
    public void MatchingHeading_display_label_is_rejected_as_answer_key()
    {
        var pairs = new Dictionary<string, string[]?>(StringComparer.OrdinalIgnoreCase)
        {
            ["1"] = new[] { "iv", "The economic impact of tourism" },
        };
        var key = MatchingKey(pairs);

        // Submitting the display label rather than the canonical key "iv" must be rejected
        var result = new MatchingHeadingGrader().Grade(MakeAnswer("The economic impact of tourism"), key);

        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
        Assert.Equal("One or more pairs do not match", result.Feedback);
    }

    [Fact]
    public void MatchingHeading_single_pair_with_mismatched_target_key_resolves_and_scores()
    {
        var pairs = new Dictionary<string, string[]?>(StringComparer.OrdinalIgnoreCase)
        {
            ["2"] = new[] { "ii", "Government's safeguard in the West" },
        };
        var key = MatchingKey(pairs);
        // Client sent JSON with key "1" for a single-item question whose pair key is "2"
        var raw = JsonSerializer.Serialize(new Dictionary<string, string> { ["1"] = "ii" });

        var result = new MatchingHeadingGrader().Grade(MakeAnswer(raw), key);

        Assert.Equal(2m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
        Assert.Null(result.Feedback);
    }

    [Fact]
    public void MatchingHeading_malformed_json_for_multi_pair_returns_zero_with_feedback()
    {
        var pairs = new Dictionary<string, string[]?>(StringComparer.OrdinalIgnoreCase)
        {
            ["i"] = new[] { "iv" },
            ["ii"] = new[] { "i" },
        };
        var key = MatchingKey(pairs);
        // Not valid JSON, more than one pair in key.
        var result = new MatchingHeadingGrader().Grade(MakeAnswer("not-json-payload"), key);

        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
        Assert.Equal("One or more pairs do not match", result.Feedback);
    }

    [Fact]
    public void MatchingHeading_single_pair_plaintext_match_returns_full_points_null_feedback()
    {
        var pairs = new Dictionary<string, string[]?>(StringComparer.OrdinalIgnoreCase)
        {
            ["i"] = new[] { "iv" },
        };
        var key = MatchingKey(pairs);

        var result = new MatchingHeadingGrader().Grade(MakeAnswer("iv"), key);

        Assert.Equal(2m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
        Assert.Null(result.Feedback);
    }

    [Fact]
    public void MatchingHeading_single_pair_plaintext_no_match_returns_zero_with_feedback()
    {
        var pairs = new Dictionary<string, string[]?>(StringComparer.OrdinalIgnoreCase)
        {
            ["i"] = new[] { "iv" },
        };
        var key = MatchingKey(pairs);

        var result = new MatchingHeadingGrader().Grade(MakeAnswer("not-the-answer"), key);

        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
        Assert.Equal("One or more pairs do not match", result.Feedback);
    }

    // ---------- FlowChartGrader ----------

    private static QuestionKey FlowKey(List<string> order) => new(
        QuestionId: Guid.NewGuid(),
        QuestionType: "FLOW_CHART",
        QuestionPoints: 1m,
        OrderCorrects: order);

    [Fact]
    public void FlowChart_full_match_returns_full_points_null_feedback()
    {
        var key = FlowKey(new List<string> { "a", "b", "c" });

        var raw = JsonSerializer.Serialize(new List<string> { "a", "b", "c" });
        var result = new FlowChartGrader().Grade(MakeAnswer(raw), key);

        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
        Assert.Null(result.Feedback);
    }

    [Fact]
    public void FlowChart_swapped_order_returns_zero_with_sequence_feedback()
    {
        var key = FlowKey(new List<string> { "a", "b", "c" });

        var raw = JsonSerializer.Serialize(new List<string> { "a", "c", "b" });
        var result = new FlowChartGrader().Grade(MakeAnswer(raw), key);

        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
        Assert.Equal("Sequence order or labels do not match answer key", result.Feedback);
    }

    [Fact]
    public void FlowChart_partial_wrong_returns_zero_no_partial_credit()
    {
        var key = FlowKey(new List<string> { "a", "b", "c" });

        // User has 3 nodes; one is wrong. No partial credit per spec §11.11.
        var raw = JsonSerializer.Serialize(new List<string> { "a", "b", "x" });
        var result = new FlowChartGrader().Grade(MakeAnswer(raw), key);

        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
        Assert.Equal("Sequence order or labels do not match answer key", result.Feedback);
    }

    [Fact]
    public void FlowChart_length_mismatch_returns_zero_with_sequence_feedback()
    {
        var key = FlowKey(new List<string> { "a", "b", "c" });

        var raw = JsonSerializer.Serialize(new List<string> { "a", "b" });
        var result = new FlowChartGrader().Grade(MakeAnswer(raw), key);

        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
        Assert.Equal("Sequence order or labels do not match answer key", result.Feedback);
    }
}
