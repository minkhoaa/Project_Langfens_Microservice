using System.Text;
using System.Text.RegularExpressions;

namespace attempt_service.Features.Helpers;

public sealed class TextNormalizer : ITextNormalizer
{
    public string Normalize(string s, NormalizationConfig cfg)
    {
        if (string.IsNullOrEmpty(s)) return "";
        var t = s;
        if (cfg.NFKC) t = t.Normalize(NormalizationForm.FormKC);
        if (cfg.Trim) t = t.Trim();
        if (cfg.Lowercase) t = t.ToLowerInvariant();
        if (cfg.DropArticles)
            t = Regex.Replace(t, @"\b(a|an|the)\b", "");
        if (cfg.DropTrailingPunct)
            t = Regex.Replace(t, @"[.,;:!?]+$", "");
        t = Regex.Replace(t, @"\s+", " ").Trim();
        return t;
    }
}