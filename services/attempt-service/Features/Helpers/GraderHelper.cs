using System.Globalization;
using System.Text;
using System.Text.RegularExpressions;
using attempt_service.Contracts.Attempt;
using Shared.ExamDto.Contracts.Exam.Enums;

namespace attempt_service.Features.Helpers;

public sealed record QuestionKey(
    Guid QuestionId,
    string QuestionType,
    decimal QuestionPoints = 1,
    HashSet<(Guid id, string content)>? CorrectOptionIds = null, // MC/TF/YN
    Dictionary<string, string[]?>? BlankAcceptTexts = null,
    Dictionary<string, string[]?>? BlankAcceptRegex = null,
    // Matching: leftKey -> accepted right values
    Dictionary<string, string[]?>? MatchPairs = null,
    // Flow chart / ordering:
    List<string>? OrderCorrects = null,
    IReadOnlyList<string>? ShortAnswerAcceptTexts = null,
    IReadOnlyList<string>? ShortAnswerAcceptRegex = null
);


internal static class TextNorm
{
    public static string Normalize(string? s)
    {
        if (string.IsNullOrWhiteSpace(s)) return "";
        var x = s.Trim().ToLowerInvariant();
        x = x.Normalize(NormalizationForm.FormD);
        var sb = new StringBuilder(x.Length);
        foreach (var ch in x)
        {
            var cat = CharUnicodeInfo.GetUnicodeCategory(ch);
            if (cat != UnicodeCategory.NonSpacingMark) sb.Append(ch);
        }

        var noDia = sb.ToString().Normalize(NormalizationForm.FormC);
        return Regex.Replace(noDia, "\\s+", " ").Trim();
    }
}
public static class AnswerValidator {
    public static string? Validate(AnswerItem answerItem, Dictionary<Guid, IndexBuilder.QMeta> idx)
    {
        if (!idx.TryGetValue(answerItem.QuestionId, out var meta))
            return $"Unknown question {answerItem.QuestionId}";
        if (answerItem.SelectedOptionIds is { Count: > 0 })
        {
            var normalized = answerItem.SelectedOptionIds.Distinct().OrderBy(x => x).ToList() 
                             ?? new List<Guid>();
            var allowedIds = meta.OptionIds.Select(t => t.id).ToHashSet();
            if (normalized.Any(x => !allowedIds.Contains(x)))
                return $"Invalid option for Q{answerItem.QuestionId}";
            if (IsSingleChoice(meta.Type) && normalized.Count() > 1)
                return $"Too many options for single-choice Q{answerItem.QuestionId}";
        }

        return null!;
    }
    // validate answer type
    public static bool IsSingleChoice(string? type)
    {
        var t = (type ?? "").ToUpperInvariant();
        return t is QuestionType.MultipleChoiceSingle
            or QuestionType.TrueFalseNotGiven
            or QuestionType.YesNoNotGiven
            or QuestionType.MultipleChoiceSingleImage;
    }
}
