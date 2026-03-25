using System.Collections.Generic;
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

/// <summary>
/// Interface for text normalization strategies
/// </summary>
public interface ITextNormalizer
{
    /// <summary>
    /// Normalizes text using the default basic normalization
    /// </summary>
    string Normalize(string? text);

    /// <summary>
    /// Normalizes text with enhanced rules (contractions, spelling variants, possessives)
    /// </summary>
    string NormalizeEnhanced(string? text);
}

/// <summary>
/// Helper class providing enhanced text normalization capabilities
/// </summary>
public sealed class TextNormHelper : ITextNormalizer
{
    private static readonly Dictionary<string, string> Contractions = new(StringComparer.OrdinalIgnoreCase)
    {
        // Common contractions
        {"can't", "cannot"},
        {"couldn't", "could not"},
        {"won't", "will not"},
        {"wouldn't", "would not"},
        {"don't", "do not"},
        {"doesn't", "does not"},
        {"didn't", "did not"},
        {"hasn't", "has not"},
        {"haven't", "have not"},
        {"hadn't", "had not"},
        {"isn't", "is not"},
        {"aren't", "are not"},
        {"wasn't", "was not"},
        {"weren't", "were not"},
        {"shouldn't", "should not"},
        {"mightn't", "might not"},
        {"mustn't", "must not"},
        {"needn't", "need not"},
        {"oughtn't", "ought not"},
        {"let's", "let us"},
        {"i'm", "i am"},
        {"you're", "you are"},
        {"he's", "he is"},
        {"she's", "she is"},
        {"it's", "it is"},
        {"we're", "we are"},
        {"they're", "they are"},
        {"i've", "i have"},
        {"you've", "you have"},
        {"we've", "we have"},
        {"they've", "they have"},
        {"i'll", "i will"},
        {"you'll", "you will"},
        {"he'll", "he will"},
        {"she'll", "she will"},
        {"it'll", "it will"},
        {"we'll", "we will"},
        {"they'll", "they will"},
        {"i'd", "i would"},
        {"you'd", "you would"},
        {"he'd", "he would"},
        {"she'd", "she would"},
        {"it'd", "it would"},
        {"we'd", "we would"},
        {"they'd", "they would"},
        {"ain't", "am not"},
        {"y'all", "you all"},
        {"ma'am", "madam"},
        {"gonna", "going to"},
        {"wanna", "want to"},
        {"gotta", "got to"},
        {"kinda", "kind of"},
        {"sorta", "sort of"},
        {"outta", "out of"},
        {"gimme", "give me"},
        {"lemme", "let me"},
        {"sup", "what is up"}
    };

    private static readonly Dictionary<string, string> BritishAmericanSpelling = new(StringComparer.OrdinalIgnoreCase)
    {
        // British -> American spelling variants
        {"colour", "color"},
        {"favour", "favor"},
        {"honour", "honor"},
        {"neighbour", "neighbor"},
        {"labour", "labor"},
        {"armour", "armor"},
        {"behaviour", "behavior"},
        {"flavour", "flavor"},
        {"humour", "humor"},
        {"numour", "numor"},
        {"rumour", "rumor"},
        {"savour", "savor"},
        {"terror", "terror"},
        {"harbour", "harbor"},
        {"clamour", "clamor"},
        {"clamour", "clamor"},
        {"fibre", "fiber"},
        {"litre", "liter"},
        {"metre", "meter"},
        {"centre", "center"},
        {"theatre", "theater"},
        {"fibre", "fiber"},
        {"manoeuvre", "maneuver"},
        {"anaemia", "anemia"},
        {"haemoglobin", "hemoglobin"},
        {"haemorrhage", "hemorrhage"},
        {"oedema", "edema"},
        {"oestrogen", "estrogen"},
        {"leukaemia", "leukemia"},
        {"foetus", "fetus"},
        {"programme", "program"},
        {"defence", "defense"},
        {"offence", "offense"},
        {"licence", "license"},
        {"practise", "practice"},
        {"analyse", "analyze"},
        {"catalyse", "catalyze"},
        {"hypnotise", "hypnotize"},
        {"recognise", "recognize"},
        {"specialise", "specialize"},
        {"organisation", "organization"},
        {"isation", "ization"},
        {"isation", "ization"},
        {"isation", "ization"},
        {"realise", "realize"},
        {"size", "size"},
        {"enquire", "inquire"},
        {"enquiry", "inquiry"},
        {"tyre", "tire"},
        {"waggon", "wagon"},
        {"mouldy", "moldy"},
        {"mould", "mold"},
        {"pour", "pour"},
        {"learnt", "learned"},
        {"spelt", "spelled"},
        {"dealt", "dealt"},
        {"built", "built"},
        {"centre", "center"}
    };

    /// <inheritdoc />
    public string Normalize(string? text) => TextNorm.Normalize(text);

    /// <inheritdoc />
    public string NormalizeEnhanced(string? text)
    {
        if (string.IsNullOrWhiteSpace(text)) return "";

        // Step 1: Apply basic normalization first
        var normalized = Normalize(text);

        // Step 2: Handle possessives - remove 's at end of words
        normalized = Regex.Replace(normalized, @"(\w+)['\u2019]s\b", "$1", RegexOptions.IgnoreCase);

        // Step 3: Expand contractions
        normalized = ExpandContractions(normalized);

        // Step 4: Normalize British/American spelling (British -> American)
        normalized = NormalizeSpelling(normalized);

        return normalized;
    }

    private string ExpandContractions(string text)
    {
        foreach (var kvp in Contractions)
        {
            // Use word boundary matching to avoid partial replacements
            var pattern = $@"\b{Regex.Escape(kvp.Key)}\b";
            text = Regex.Replace(text, pattern, kvp.Value, RegexOptions.IgnoreCase);
        }
        return text;
    }

    private string NormalizeSpelling(string text)
    {
        foreach (var kvp in BritishAmericanSpelling)
        {
            // Use case-insensitive matching but preserve original case for first letter
            var pattern = $@"\b{Regex.Escape(kvp.Key)}\b";
            text = Regex.Replace(text, pattern, kvp.Value, RegexOptions.IgnoreCase);
        }
        return text;
    }
}
public interface IAnswerValidator
{
    string? Validate(AnswerItem answerItem, Dictionary<Guid, QMeta> idx);
    bool IsSingleChoice(string? type);

}
public class AnswerValidator : IAnswerValidator
{
    public string? Validate(AnswerItem answerItem, Dictionary<Guid, QMeta> idx)
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
    public bool IsSingleChoice(string? type)
    {
        var t = (type ?? "").ToUpperInvariant();
        return t is QuestionType.MultipleChoiceSingle
            or QuestionType.TrueFalseNotGiven
            or QuestionType.YesNoNotGiven
            or QuestionType.MultipleChoiceSingleImage;
    }
}
