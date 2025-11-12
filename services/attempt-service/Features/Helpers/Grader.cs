using System.Text.Json;
using System.Text.RegularExpressions;
using attempt_service.Domain.Entities;

namespace attempt_service.Features.Helpers;

public sealed record GradeResult(
    decimal AwardedPoints,
    bool? IsCorrect,
    bool NeedsManualReview = false,
    string? Feedback = null);
public interface IQuestionGrader
{
    GradeResult Grade(AttemptAnswer answer, QuestionKey key);
}

// single choice grader
public sealed class SingleChoiceGrader : IQuestionGrader
{
    public GradeResult Grade(AttemptAnswer answer, QuestionKey key)
    {
        var selection = (answer.SelectedOptionIds ?? new List<Guid>()).ToHashSet();
        var correctIds = (key.CorrectOptionIds ?? new HashSet<(Guid id, string content)>())
            .Select(t => t.id)
            .ToHashSet();
        var ok = selection.Count == 1 && correctIds.Contains(selection.First());
        return new GradeResult(ok ? key.QuestionPoints : 0m, ok);
    }
}

// SUMMARY_COMPLETION / TABLE_COMPLETION / NOTE_COMPLETION
// - user.TextAnswer: JSON {"blankId1":"value1","blankId2":"value2", ...}
public sealed class CompletionGrader : IQuestionGrader
{
    public GradeResult Grade(AttemptAnswer answer, QuestionKey key)
    {
        if (string.IsNullOrWhiteSpace(answer.TextAnswer))
            return new GradeResult(0, false);
        Dictionary<string, string>? map;
        try
        {
            map = JsonSerializer.Deserialize<Dictionary<string, string>>(answer.TextAnswer) ??
                  new Dictionary<string, string>();
        }
        catch
        {
            return new GradeResult(0, false, Feedback: "Malformed completion payload");
        }

        decimal get = 0, total = 0;
        var texts = key.BlankAcceptTexts ?? new Dictionary<string, string[]?>();
        var regs = key.BlankAcceptRegex ?? new Dictionary<string, string[]?>();
        foreach (var blankId in texts.Keys.Union(regs.Keys))
        {
            texts.TryGetValue(blankId, out var accepted);
            regs.TryGetValue(blankId, out var patterns);
            var hasText = accepted is { Length: > 0 };
            var hasRegex = patterns is { Length: > 0 };
            if (!hasRegex && !hasText) continue;
            total += 1;

            map.TryGetValue(blankId, out var userRaw);
            var userNorm = TextNorm.Normalize(userRaw);
            var matched = hasText && accepted!.Any(x => TextNorm.Normalize(x) == userNorm);
            if (!matched && hasRegex)
                foreach (var rx in patterns!)
                {
                    if (string.IsNullOrWhiteSpace(rx)) continue;
                    try
                    {
                        var pat = rx.StartsWith('^') || rx.EndsWith('$') ? rx : $"^{rx}$";
                        if (Regex.IsMatch(userRaw ?? "",
                                pat, RegexOptions.IgnoreCase
                                     | RegexOptions.CultureInvariant))
                        {
                            matched = true;
                            break;
                        }
                    }
                    catch
                    {
                    }
                }

            if (matched) get++;
        }

        var score = (total > 0 ? get / total : 0) * key.QuestionPoints;
        return new GradeResult(score, score >= key.QuestionPoints);
    }
}

// answer.TextAnswer = {"labelNodeId":"user text", ...}.
public sealed class LabelGrader : IQuestionGrader
{
    private readonly CompletionGrader _inner = new();

    public GradeResult Grade(AttemptAnswer answer, QuestionKey key)
        => _inner.Grade(answer, key);
}

public sealed class MatchingHeadingGrader : IQuestionGrader
{
    public GradeResult Grade(AttemptAnswer answer, QuestionKey key)
    {
        if (string.IsNullOrWhiteSpace(answer.TextAnswer))
            return new GradeResult(0, false);
        Dictionary<string, string> map;
        try
        {
            map = JsonSerializer.Deserialize<Dictionary<string, string>>(answer.TextAnswer) ??
                  new Dictionary<string, string>();
        }
        catch
        {
            return new GradeResult(0, false, Feedback: "malformed matching payload");
        }

        var pairs = key.MatchPairs ??
                    new Dictionary<string, string[]?>(StringComparer.OrdinalIgnoreCase);
        if (pairs.Count == 0) return new GradeResult(0, false, Feedback: "No answer key");
        decimal got = 0, total = pairs.Count;
        foreach (var (left, right) in pairs)
        {
            map.TryGetValue(left, out var userRight);
            if (right is { Length: > 0 } &&
                right.Any(r => string.Equals(r, userRight, StringComparison.OrdinalIgnoreCase))
               ) got++;
        }

        var score = got / total * key.QuestionPoints;
        return new GradeResult(score, score >= key.QuestionPoints);
    }
}

public sealed class FlowChartGrader : IQuestionGrader
{
    public GradeResult Grade(AttemptAnswer answer, QuestionKey key)
    {
        List<string> userSeq;

        if (answer.SelectedOptionIds is { Count: > 0 })
        {
            userSeq = answer.SelectedOptionIds.ConvertAll(i => i.ToString());
        }
        else
        {
            try
            {
                userSeq = JsonSerializer.Deserialize<List<string>>(answer.TextAnswer ?? "[]") ?? new List<string>();
            }
            catch
            {
                return new GradeResult(0m, false, false, "Malformed sequence payload");
            }
        }

        var correct = key.OrderCorrects ?? new List<string>();
        if (correct.Count == 0)
            return new GradeResult(0m, null, true, "No answer key");

        var lcs = LCS(userSeq, correct);
        var score = correct.Count > 0 ? (decimal)lcs / correct.Count * key.QuestionPoints : 0m;
        var full  = score >= key.QuestionPoints;

        return new GradeResult(score, full, false);
    }

    private static int LCS(IList<string> a, IList<string> b)
    {
        var dp = new int[a.Count + 1, b.Count + 1];
        for (var i = 1; i <= a.Count; i++)
        for (var j = 1; j <= b.Count; j++)
            dp[i, j] = a[i - 1] == b[j - 1]
                ? dp[i - 1, j - 1] + 1
                : Math.Max(dp[i - 1, j], dp[i, j - 1]);
        return dp[a.Count, b.Count];
    }
}

public sealed class ShortAnswerGrader : IQuestionGrader
{
    public GradeResult Grade(AttemptAnswer answer, QuestionKey key)
    {
        var input = answer.TextAnswer ?? string.Empty;
        var normalized = TextNorm.Normalize(input);
        var accepts = key.ShortAnswerAcceptTexts ?? Array.Empty<string>();
        var regexes = key.ShortAnswerAcceptRegex ?? Array.Empty<string>();

        var matched = accepts.Any(x => TextNorm.Normalize(x) == normalized);

        if (!matched)
        {
            foreach (var rx in regexes)
            {
                if (string.IsNullOrWhiteSpace(rx)) continue;
                try
                {
                    var pat = rx.StartsWith('^') || rx.EndsWith('$') ? rx : $"^{rx}$";
                    if (Regex.IsMatch(input, pat, RegexOptions.IgnoreCase | RegexOptions.CultureInvariant))
                    {
                        matched = true;
                        break;
                    }
                }
                catch
                {
                    // ignore malformed regex
                }
            }
        }

        return new GradeResult(matched ? key.QuestionPoints : 0m, matched);
    }
}
