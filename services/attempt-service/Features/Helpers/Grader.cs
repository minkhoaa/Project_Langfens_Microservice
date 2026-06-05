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
        var correct = key.CorrectOptionIds ?? new HashSet<(Guid id, string content)>();
        var correctIds = correct.Select(t => t.id).ToHashSet();
        // Accept match if EITHER:
        //   1. The user's SelectedOptionIds UUID is in the correct set
        //   2. TextAnswer holds a GUID that's in the correct set (older FE
        //      builds routed the option UUID into TextAnswer instead)
        //   3. TextAnswer equals a correct option's text content
        var ok = (selection.Count == 1 && correctIds.Contains(selection.First()))
            || (!string.IsNullOrWhiteSpace(answer.TextAnswer) && (
                (Guid.TryParse(answer.TextAnswer, out var tGuid) && correctIds.Contains(tGuid))
                || correct.Any(c => !string.IsNullOrEmpty(c.content)
                    && string.Equals(c.content.Trim(), answer.TextAnswer.Trim(), StringComparison.OrdinalIgnoreCase))
            ));
        return new GradeResult(ok ? key.QuestionPoints : 0m, ok);
    }
}

// Multiple choice with multiple correct answers (e.g., "Choose THREE letters A-F")
// Order doesn't matter - checks if selected set equals correct set
public sealed class MultipleChoiceGrader : IQuestionGrader
{
    public GradeResult Grade(AttemptAnswer answer, QuestionKey key)
    {
        var selection = (answer.SelectedOptionIds ?? new List<Guid>()).ToHashSet();
        var correctIds = (key.CorrectOptionIds ?? new HashSet<(Guid id, string content)>())
            .Select(t => t.id)
            .ToHashSet();
        
        // Set equality - order doesn't matter, just need to match all correct options
        var isCorrect = selection.SetEquals(correctIds);
        return new GradeResult(isCorrect ? key.QuestionPoints : 0m, isCorrect);
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
                            // ignored
                        }
                    }

                if (matched) get++;

            }

            var score = (total > 0 ? (decimal)get / total : 0) * key.QuestionPoints;
            return new GradeResult(score, score > 0);
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
                        // ignored
                    }
                }
            }
            var score = matched ? key.QuestionPoints : 0m;
            return new GradeResult(score, matched);
        }
        // Multi-blank positional fallback: the FE packs user answers as
        // newline-separated values (e.g. "answer1\nanswer2"). Match each part
        // to the corresponding blank ID in dictionary iteration order, which
        // mirrors the order of `question.CompletionAccepts` and therefore the
        // UI's blank order. Extra trailing parts are ignored; missing parts
        // count as unmatched for that blank.
        var userParts = raw.Split('\n')
            .Select(p => p.Trim())
            .ToArray();
        var blankIds = texts.Keys
            .Union(regs.Keys, StringComparer.OrdinalIgnoreCase)
            .ToList();
        decimal positionalGet = 0m, positionalTotal = 0m;
        for (var i = 0; i < blankIds.Count; i++)
        {
            var blankId = blankIds[i];
            texts.TryGetValue(blankId, out var accepted);
            regs.TryGetValue(blankId, out var patterns);
            var hasText = accepted is { Length: > 0 };
            var hasRegex = patterns is { Length: > 0 };
            if (!hasRegex && !hasText) continue;
            positionalTotal += 1;

            var userRaw = i < userParts.Length ? userParts[i] : string.Empty;
            var userNorm = TextNorm.Normalize(userRaw);
            var matched = hasText && accepted!.Any(x => TextNorm.Normalize(x) == userNorm);
            if (!matched && hasRegex)
            {
                foreach (var rx in patterns!)
                {
                    if (string.IsNullOrWhiteSpace(rx)) continue;
                    try
                    {
                        var pat = rx.StartsWith('^') || rx.EndsWith('$') ? rx : $"^{rx}$";
                        if (Regex.IsMatch(userRaw, pat,
                                RegexOptions.IgnoreCase | RegexOptions.CultureInvariant))
                        {
                            matched = true;
                            break;
                        }
                    }
                    catch
                    {
                        // ignored
                    }
                }
            }

            if (matched) positionalGet++;
        }
        var positionalScore = positionalTotal > 0
            ? (positionalGet / positionalTotal) * key.QuestionPoints
            : 0m;
        return new GradeResult(positionalScore, positionalScore > 0);
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
            return new GradeResult(score, score > 0);
        }
        if (pairs.Count == 1)
        {
            var (_, accepted) = pairs.First();
            var matched = accepted is { Length: > 0 } &&
                          accepted.Any(k => string.Equals(k, raw, StringComparison.OrdinalIgnoreCase));
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
        return new GradeResult(score, score > 0);

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

    public static int LCS(IList<string> a, IList<string> b)
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


