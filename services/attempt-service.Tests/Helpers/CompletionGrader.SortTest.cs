using Xunit;
using attempt_service.Features.Helpers;

namespace attempt_service.Tests.Helpers;

/// <summary>
/// Sprint 3: pins the numeric-sort contract of <c>GraderScoring.SortedUnionKeys</c>.
/// Without sorting, <c>Dictionary&lt;string,_&gt;.Keys</c> iteration order is hash-driven
/// and <c>jsonb_object_keys</c> order is implementation-defined — so positional matching
/// between FE rendering and BE grading could go off-by-one whenever an admin typed blanks
/// in non-numeric order (or seeders loaded them out of order). These cases assert the
/// helper normalises both numeric and non-numeric keys.
/// </summary>
public class CompletionGraderSortTest
{
    private static Dictionary<string, string[]?> TextsFor(params string[] keys)
    {
        var d = new Dictionary<string, string[]?>(StringComparer.OrdinalIgnoreCase);
        foreach (var k in keys) d[k] = null;
        return d;
    }

    [Fact]
    public void Numeric_keys_in_descending_order_sort_to_ascending()
    {
        var texts = TextsFor("5", "3", "1");
        var regs  = new Dictionary<string, string[]?>(StringComparer.OrdinalIgnoreCase);
        var result = GraderScoring.SortedUnionKeys(texts, regs).ToList();
        Assert.Equal(new[] { "1", "3", "5" }, result);
    }

    [Fact]
    public void Union_of_texts_and_regexes_is_sorted_numerically()
    {
        var texts = TextsFor("3", "1", "2");
        var regs  = TextsFor("7");
        var result = GraderScoring.SortedUnionKeys(texts, regs).ToList();
        Assert.Equal(new[] { "1", "2", "3", "7" }, result);
    }

    [Fact]
    public void Non_numeric_keys_fall_back_to_ordinal_order()
    {
        var texts = TextsFor("z", "a", "m");
        var regs  = new Dictionary<string, string[]?>(StringComparer.OrdinalIgnoreCase);
        var result = GraderScoring.SortedUnionKeys(texts, regs).ToList();
        Assert.Equal(new[] { "a", "m", "z" }, result);
    }

    [Fact]
    public void Numeric_sort_beats_lexical_sort_for_two_digit_keys()
    {
        // The bug repro. Lexical sort would give ["10","2"]; numeric sort gives ["2","10"].
        var texts = TextsFor("10", "2");
        var regs  = new Dictionary<string, string[]?>(StringComparer.OrdinalIgnoreCase);
        var result = GraderScoring.SortedUnionKeys(texts, regs).ToList();
        Assert.Equal(new[] { "2", "10" }, result);
    }
}