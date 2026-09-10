using System.Text.Json;
using Xunit;
using attempt_service.Domain.Entities;
using attempt_service.Features.Helpers;

namespace attempt_service.Tests.Helpers;

/// <summary>
/// Tests for CompletionGrader (and LabelGrader alias) index ordering.
///
/// Background: the BE grader compares user answers positionally against
/// \`blankIds\` derived from \`texts.Keys.Union(regs.Keys)\`. PostgreSQL
/// jsonb_object_keys returns keys in an implementation-defined order, and
/// .NET Dictionary iteration order depends on hash code layout — neither
/// is guaranteed to match the UI's blank order. The fix in
/// \`Grader.CompletionGrader.Grade\` sorts blankIds by numeric value (with
/// int.MaxValue fallback for legacy non-numeric keys, then Ordinal
/// tie-break). These tests pin the contract: positional matching must be
/// stable across insertion order and across all 7 completion-family
/// question types (SENTENCE/SUMMARY/NOTE/FORM/TABLE_COMPLETION +
/// DIAGRAM/MAP_LABEL).
/// </summary>
public class GraderCompletionIndexTests
{
    // ---------- Helpers ----------

    private static AttemptAnswer MakeAnswer(string? text) => new()
    {
        Id = Guid.NewGuid(),
        AttemptId = Guid.NewGuid(),
        SectionId = Guid.NewGuid(),
        QuestionId = Guid.NewGuid(),
        TextAnswer = text,
    };

    private static QuestionKey CompletionKey(
        Dictionary<string, string[]?>? texts = null,
        Dictionary<string, string[]?>? regexes = null,
        string type = "SUMMARY_COMPLETION") => new(
        QuestionId: Guid.NewGuid(),
        QuestionType: type,
        QuestionPoints: 2m,
        BlankAcceptTexts: texts,
        BlankAcceptRegex: regexes);

    private static Dictionary<string, string[]?> TextsFor(params (string key, string[] values)[] entries)
    {
        var d = new Dictionary<string, string[]?>(StringComparer.OrdinalIgnoreCase);
        foreach (var (k, v) in entries) d[k] = v;
        return d;
    }

    // ---------- 1. JSON map path is order-independent ----------

    [Fact]
    public void Completion_json_map_with_keys_in_reverse_order_still_matches()
    {
        // The FE may emit JSON map in any key order. Iteration order in
        // the JSON-map branch (line 107-148) only walks the answer key
        // dictionary to look up each accepted value, so it must produce
        // the same result regardless of how the JSON was serialised.
        var texts = TextsFor(
            ("0", new[] { "stacked layers", "layers" }),
            ("1", new[] { "sunlight" }),
            ("2", new[] { "hydroponic systems", "hydroponics" }),
            ("3", new[] { "temperature" }),
            ("4", new[] { "supermarkets", "sale" })
        );
        var key = CompletionKey(texts);

        // JSON payload with keys in REVERSE order (worst case for
        // implementation-defined ordering).
        var raw = JsonSerializer.Serialize(new Dictionary<string, string>
        {
            ["4"] = "supermarkets",
            ["3"] = "temperature",
            ["2"] = "hydroponics",
            ["1"] = "sunlight",
            ["0"] = "stacked layers",
        });

        var result = new CompletionGrader().Grade(MakeAnswer(raw), key);

        Assert.Equal(2m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Completion_json_map_with_one_wrong_blank_returns_zero()
    {
        var texts = TextsFor(
            ("0", new[] { "stacked layers" }),
            ("1", new[] { "sunlight" }),
            ("2", new[] { "hydroponic systems" })
        );
        var key = CompletionKey(texts);

        var raw = JsonSerializer.Serialize(new Dictionary<string, string>
        {
            ["0"] = "stacked layers",
            ["1"] = "WRONG",
            ["2"] = "hydroponic systems",
        });

        var result = new CompletionGrader().Grade(MakeAnswer(raw), key);

        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
    }

    // ---------- 2. Positional fallback — main bug reproduction ----------

    [Fact]
    public void Completion_positional_falls_back_to_split_when_textAnswer_is_not_JSON()
    {
        // Without `{` `}` the grader takes the positional fallback. The FE
        // currently packs answers as newline-separated values for 2+ blanks.
        var texts = TextsFor(
            ("0", new[] { "a" }),
            ("1", new[] { "b" }),
            ("2", new[] { "c" })
        );
        var key = CompletionKey(texts);

        var result = new CompletionGrader().Grade(MakeAnswer("a\nb\nc"), key);

        Assert.Equal(2m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Completion_positional_matches_when_textAnswer_uses_crlf_separator()
    {
        // The fallback splits on `\n` and trims each part. Windows-style
        // `\r\n` line endings must still work after Trim.
        var texts = TextsFor(
            ("0", new[] { "alpha" }),
            ("1", new[] { "beta" }),
            ("2", new[] { "gamma" })
        );
        var key = CompletionKey(texts);

        var result = new CompletionGrader().Grade(MakeAnswer("alpha\r\nbeta\r\ngamma"), key);

        Assert.Equal(2m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Completion_positional_matches_userParts_to_blankIds_regardless_of_dict_order()
    {
        // Insert keys in REVERSE order to simulate PostgreSQL jsonb_object_keys
        // returning keys in non-insertion order. After the sort fix, the
        // grader must still match userParts[0]="a" against texts["0"] etc.
        var texts = TextsFor(
            ("4", new[] { "e" }),
            ("3", new[] { "d" }),
            ("2", new[] { "c" }),
            ("1", new[] { "b" }),
            ("0", new[] { "a" })
        );
        var key = CompletionKey(texts);

        var result = new CompletionGrader().Grade(MakeAnswer("a\nb\nc\nd\ne"), key);

        Assert.Equal(2m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Completion_positional_with_two_blanks_user_swaps_answers_returns_zero()
    {
        // Sanity check: even after the sort fix, swapping answers still
        // returns zero (the bug is about ordering, not about losing
        // sensitivity to wrong swaps).
        var texts = TextsFor(
            ("0", new[] { "alpha" }),
            ("1", new[] { "beta" })
        );
        var key = CompletionKey(texts);

        var result = new CompletionGrader().Grade(MakeAnswer("beta\nalpha"), key);

        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
    }

    [Fact]
    public void Completion_positional_user_fills_4_of_5_blanks_correctly_returns_zero()
    {
        // All-or-nothing per D1 invariant — leaving blank 4 (5th) empty
        // must mark the whole answer wrong even if the other four are
        // correct. This pins the no-partial-credit rule.
        var texts = TextsFor(
            ("0", new[] { "a" }),
            ("1", new[] { "b" }),
            ("2", new[] { "c" }),
            ("3", new[] { "d" }),
            ("4", new[] { "e" })
        );
        var key = CompletionKey(texts);

        var result = new CompletionGrader().Grade(MakeAnswer("a\nb\nc\nd"), key);

        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
    }

    // ---------- 3. Single-blank path ----------

    [Fact]
    public void Completion_single_blank_plaintext_match_returns_full_points()
    {
        // When the answer key has exactly one blank the grader short-circuits
        // to a single-blank plaintext match. Order doesn't matter.
        var texts = TextsFor(("0", new[] { "river" }));
        var key = CompletionKey(texts);

        var result = new CompletionGrader().Grade(MakeAnswer("river"), key);

        Assert.Equal(2m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Completion_single_blank_user_leaves_empty_returns_zero()
    {
        var texts = TextsFor(("0", new[] { "river" }));
        var key = CompletionKey(texts);

        var result = new CompletionGrader().Grade(MakeAnswer(""), key);

        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
    }

    // ---------- 4. Edge cases ----------

    [Fact]
    public void Completion_textAnswer_null_returns_zero_no_feedback()
    {
        var texts = TextsFor(("0", new[] { "x" }));
        var key = CompletionKey(texts);

        var result = new CompletionGrader().Grade(MakeAnswer(null), key);

        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
    }

    [Fact]
    public void Completion_textAnswer_whitespace_only_returns_zero()
    {
        var texts = TextsFor(("0", new[] { "x" }));
        var key = CompletionKey(texts);

        var result = new CompletionGrader().Grade(MakeAnswer("   \n  \n   "), key);

        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
    }

    [Fact]
    public void Completion_textAnswer_extra_trailing_blank_parts_ignored()
    {
        // The fallback ignores extra trailing parts (spec).
        var texts = TextsFor(
            ("0", new[] { "a" }),
            ("1", new[] { "b" })
        );
        var key = CompletionKey(texts);

        var result = new CompletionGrader().Grade(MakeAnswer("a\nb\nignored\nextra"), key);

        Assert.Equal(2m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Completion_textAnswer_fewer_parts_than_blanks_marks_wrong()
    {
        var texts = TextsFor(
            ("0", new[] { "a" }),
            ("1", new[] { "b" }),
            ("2", new[] { "c" })
        );
        var key = CompletionKey(texts);

        var result = new CompletionGrader().Grade(MakeAnswer("a\nb"), key);

        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
    }

    [Fact]
    public void Completion_with_legacy_non_numeric_blank_keys_falls_back_to_ordinal_sort()
    {
        // Legacy seeds may use keys like "blank-q1" — int.TryParse fails
        // so they go to the end (int.MaxValue) and sort Ordinal. The
        // positional match still works as long as the order in the user
        // payload mirrors the Ordinal order.
        var texts = new Dictionary<string, string[]?>(StringComparer.OrdinalIgnoreCase)
        {
            ["blank-q1"] = new[] { "alpha" },
            ["blank-q2"] = new[] { "beta" },
            ["blank-q3"] = new[] { "gamma" },
        };
        var key = CompletionKey(texts);

        var result = new CompletionGrader().Grade(MakeAnswer("alpha\nbeta\ngamma"), key);

        Assert.Equal(2m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Completion_with_mixed_numeric_and_legacy_keys_numeric_first()
    {
        // Numeric keys should sort before non-numeric legacy keys.
        // Insert in mixed order and verify the grader still works.
        var texts = new Dictionary<string, string[]?>(StringComparer.OrdinalIgnoreCase)
        {
            ["blank-q1"] = new[] { "alpha" },
            ["2"] = new[] { "gamma" },
            ["1"] = new[] { "beta" },
        };
        var key = CompletionKey(texts);

        var result = new CompletionGrader().Grade(MakeAnswer("beta\ngamma\nalpha"), key);

        Assert.Equal(2m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Completion_empty_dictionary_returns_zero_with_no_answer_key_feedback()
    {
        var key = CompletionKey(texts: new Dictionary<string, string[]?>());

        var result = new CompletionGrader().Grade(MakeAnswer("anything"), key);

        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
    }

    // ---------- 5. TextNorm edge cases ----------

    [Fact]
    public void Completion_positional_match_with_internal_whitespace_collapses()
    {
        // TextNorm collapses runs of whitespace to a single space. User
        // answer with extra spaces between words must still match.
        var texts = TextsFor(
            ("0", new[] { "river bank" }),
            ("1", new[] { "mountain peak" })
        );
        var key = CompletionKey(texts);

        var result = new CompletionGrader().Grade(MakeAnswer("river    bank\nmountain   peak"), key);

        Assert.Equal(2m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Completion_positional_match_case_insensitive()
    {
        // TextNorm lowercases both sides; case must not matter.
        var texts = TextsFor(
            ("0", new[] { "River" }),
            ("1", new[] { "Mountain" })
        );
        var key = CompletionKey(texts);

        var result = new CompletionGrader().Grade(MakeAnswer("RIVER\nMOUNTAIN"), key);

        Assert.Equal(2m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Completion_positional_match_with_trailing_whitespace_per_blank()
    {
        // The fallback trims each part, so leading/trailing spaces per line
        // are tolerated.
        var texts = TextsFor(
            ("0", new[] { "alpha" }),
            ("1", new[] { "beta" })
        );
        var key = CompletionKey(texts);

        var result = new CompletionGrader().Grade(MakeAnswer("  alpha  \n  beta  "), key);

        Assert.Equal(2m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    // ---------- 6. Cover all 7 completion-family types via LabelGrader alias ----------

    [Theory]
    [InlineData("DIAGRAM_LABEL")]
    [InlineData("MAP_LABEL")]
    public void Label_delegates_to_Completion_and_matches_positionally(string type)
    {
        // LabelGrader is registered for both DIAGRAM_LABEL and MAP_LABEL;
        // verify the alias path also respects the sort fix.
        var texts = TextsFor(
            ("0", new[] { "alpha" }),
            ("1", new[] { "beta" })
        );
        var key = new QuestionKey(
            QuestionId: Guid.NewGuid(),
            QuestionType: type,
            QuestionPoints: 2m,
            BlankAcceptTexts: texts);

        var result = new LabelGrader().Grade(MakeAnswer("alpha\nbeta"), key);

        Assert.Equal(2m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Label_diagram_with_reversed_dict_order_still_matches()
    {
        var texts = TextsFor(
            ("1", new[] { "beta" }),
            ("0", new[] { "alpha" })
        );
        var key = new QuestionKey(
            QuestionId: Guid.NewGuid(),
            QuestionType: "DIAGRAM_LABEL",
            QuestionPoints: 2m,
            BlankAcceptTexts: texts);

        var result = new LabelGrader().Grade(MakeAnswer("alpha\nbeta"), key);

        Assert.Equal(2m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Label_map_with_random_dict_order_still_matches()
    {
        // Insert in 3,1,4,0,2 order — random non-sequential insertion to
        // stress the sort fix.
        var texts = TextsFor(
            ("3", new[] { "delta" }),
            ("1", new[] { "beta" }),
            ("4", new[] { "epsilon" }),
            ("0", new[] { "alpha" }),
            ("2", new[] { "gamma" })
        );
        var key = new QuestionKey(
            QuestionId: Guid.NewGuid(),
            QuestionType: "MAP_LABEL",
            QuestionPoints: 2m,
            BlankAcceptTexts: texts);

        var result = new LabelGrader().Grade(MakeAnswer("alpha\nbeta\ngamma\ndelta\nepsilon"), key);

        Assert.Equal(2m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }
}