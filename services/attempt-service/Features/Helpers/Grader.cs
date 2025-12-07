using System.Data.Common;
using System.Formats.Asn1;
using System.Text.Json;
using System.Text.RegularExpressions;
using attempt_service.Domain.Entities;
using MassTransit.Middleware.Outbox;
using Microsoft.AspNetCore.OutputCaching;

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
// - user.TextAnswer: JSON {"blankId1":"value1","blankI d2":"value2", ...}
public sealed class CompletionGrader : IQuestionGrader
{
    public GradeResult Grade(AttemptAnswer answer, QuestionKey key)
    {
        if (string.IsNullOrWhiteSpace(answer.TextAnswer))
            return new GradeResult(0, false);
        Dictionary<string, string>? map = null;


        var texts = key.BlankAcceptTexts ?? new Dictionary<string, string[]?>();
        var regs = key.BlankAcceptRegex ?? new Dictionary<string, string[]?>();
        var raw = answer.TextAnswer.Trim();

        var looksLikeJson = raw.StartsWith("{") && raw.EndsWith("}");
        if (looksLikeJson)
        {
            try
            {
                map = JsonSerializer.Deserialize<Dictionary<string, string>>(raw) ??
                      new Dictionary<string, string>();
            }
            catch
            {
                // map vẫn null → sẽ fallback phía dưới
            }
        }
        if (map is not null)
        {
            decimal get = 0, total = 0;
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
        // đoạn này payload không phải JSON chấm theo Plaintext
        var blankCount = texts.Count + regs.Count;
        if (blankCount == 0)
        {
            return new GradeResult(0, false, Feedback: "No answer key");
        }
        if (blankCount == 1)
        {
            var userRaw = answer.TextAnswer ?? string.Empty;
            var userNorm = TextNorm.Normalize(userRaw);
            var allAcceptTexts = texts.Values.SelectMany(k => k ?? Array.Empty<string>())
                        .Where(k => !string.IsNullOrWhiteSpace(k))
                        .Select(TextNorm.Normalize)
                        .ToHashSet();
            var matched = allAcceptTexts.Contains(userNorm);
            if (!matched)
            {
                var allPatterns = regs.Values.SelectMany(k => k ?? Array.Empty<string>());
                foreach (var reg in allPatterns)
                {
                    if (string.IsNullOrWhiteSpace(reg))
                        continue;
                    try
                    {
                        var pat = reg.StartsWith('^') || reg.EndsWith('$') ? reg : $"^{reg}$";
                        if (Regex.IsMatch(userRaw,
                                pat,
                                RegexOptions.IgnoreCase | RegexOptions.CultureInvariant))
                        {
                            matched = true;
                            break;
                        }
                    }
                    catch
                    {
                    }
                }
            }
            var score = matched ? key.QuestionPoints : 0m;
            return new GradeResult(score, matched);
        }
        return new GradeResult(0, false, Feedback: "Malformed completion payload (expected JSON or one-blank legacy)");
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

        var pairs = key.MatchPairs ??
                    new Dictionary<string, string[]?>(StringComparer.OrdinalIgnoreCase);
        if (pairs.Count == 0)
            return new GradeResult(0, false, Feedback: "No answer key");

        var raw = answer.TextAnswer.Trim();


        Dictionary<string, string>? map = null;
        var looksLikeJson = raw.StartsWith("{") && raw.EndsWith("}");
        if (looksLikeJson)
        {
            try
            {
                map = JsonSerializer.Deserialize<Dictionary<string, string>>(raw)
                      ?? new Dictionary<string, string>();
            }
            catch
            {
                // bỏ qua, fallback phía dưới
            }
        }
        if (map is not null)
        {
            decimal got = 0m, total = pairs.Count;
            foreach (var (left, right) in pairs)
            {
                map.TryGetValue(left, out var userRight);
                if (right is { Length: > 0 } &&
                    right.Any(r => string.Equals(r, userRight, StringComparison.OrdinalIgnoreCase)))
                {
                    got++;
                }
            }
            var score = total > 0 ? got / total * key.QuestionPoints : 0m;
            return new GradeResult(score, score >= key.QuestionPoints);
        }
        if (pairs.Count == 1)
        {
            var (_, accepted) = pairs.First();
            var user = raw;
            var matched = accepted is { Length: > 0 } && accepted.Any(k => string.Equals(k, user, StringComparison.OrdinalIgnoreCase));
            var score = matched ? key.QuestionPoints : 0m;
            return new GradeResult(score, matched);
        }
        return new GradeResult(0, false, Feedback: "Malformed matching payload (expected JSON for multiple pairs)");

    }
}

public sealed class FlowChartGrader : IQuestionGrader
{
    public GradeResult Grade(AttemptAnswer answer, QuestionKey key)
    {
        var correctRaw = key.OrderCorrects ?? new List<string>();
        if (correctRaw.Count == 0)
            return new GradeResult(0m, null, true, "No answer key");
        var correct = correctRaw.Select(NormNode)
            .Where(k => !string.IsNullOrEmpty(k))
            .ToList();
        if (correct.Count == 0)
            return new GradeResult(0m, null, true, "No answer key");
        var userRawList = ParseUserSequence(answer.TextAnswer);
        if (userRawList.Count == 0)
            return new GradeResult(0m, false, false, "Malformed or empty sequence payload");

        var user = userRawList
            .Where(k => !string.IsNullOrEmpty(k))
            .Select(NormNode)
            .ToList();
        if (user.Count == 0)
            return new GradeResult(0m, false, false, "Malformed or empty sequence payload");
        var lcs = LCS(user, correct);
        var score = (decimal)lcs / correct.Count * key.QuestionPoints;
        var full = score >= key.QuestionPoints;
        return new GradeResult(score, full, false);

    }
    private static string NormNode(string? s)
    {
        if (string.IsNullOrWhiteSpace(s)) return string.Empty;
        s = s.ToLowerInvariant();
        s = s.Replace('-', ' ');
        s = Regex.Replace(s, @"[^a-z0-9\s]", " ");
        s = Regex.Replace(s, @"\s+", " ").Trim();
        return s;
    }
    private static List<string> ParseUserSequence(string? raw)
    {
        if (string.IsNullOrWhiteSpace(raw))
            return new List<string>();
        try
        {
            return JsonSerializer.Deserialize<List<string>>(raw) ?? new List<string>();
        }
        catch
        {
            return new List<string>();
        }
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


