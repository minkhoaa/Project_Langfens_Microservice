using System.Globalization;
using System.Text;
using System.Text.RegularExpressions;
using attempt_service.Domain.Entities;
using Microsoft.IdentityModel.Tokens;

namespace attempt_service.Features.Helpers;

public sealed record QuestionKey (
    int QuestionId,
    string QuestionType,
    double QuestionPoints,
    HashSet<int>? CorrectOptionIds = null,      // MC/TF/YN
    Dictionary<string, string[]?> BlankAcceptTexts = null!,
    Dictionary<string, string[]?> BlankAcceptRegex = null!,
    // Matching: leftKey -> accepted right values
    Dictionary<string, string[]?>MatchPairs = null!,
    // Flow chart / ordering:
    List<string> OrderCorrects = null!
    ) ;
public sealed record GradeResult(double AwardedPoints, bool? IsCorrect, bool NeedsManualReview = false, string? Feedback = null);

static class TextNorm {
    public static string Normalize(string? s) {
        if (string.IsNullOrWhiteSpace(s)) return "";
        var x = s.Trim().ToLowerInvariant();
        x = x.Normalize(NormalizationForm.FormD);
        var sb = new StringBuilder(x.Length);
        foreach (var ch in x) {
            var cat = CharUnicodeInfo.GetUnicodeCategory(ch);
            if (cat != UnicodeCategory.NonSpacingMark) sb.Append(ch);
        }
        var noDia = sb.ToString().Normalize(NormalizationForm.FormC);
        return Regex.Replace(noDia, "\\s+", " ").Trim();
    }
}


