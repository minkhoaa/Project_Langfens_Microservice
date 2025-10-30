using System.Globalization;
using System.Text;
using Microsoft.EntityFrameworkCore;
using vocabulary_service.Infrastructure.Persistence;

namespace vocabulary_service.Application.Helper;

public static class SlugHelper
{
    public static string ToSlug(string? input, int maxLen = 120)
    {
        // Treat null/whitespace as empty and let fallback handle it
        var s = (input ?? string.Empty).Trim().ToLowerInvariant()
            .Replace('đ', 'd').Replace('ð', 'd');
        var norm = s.Normalize(NormalizationForm.FormD);
        var sb = new StringBuilder(capacity: norm.Length);

        foreach (var ch in norm)
        {
            var uc = CharUnicodeInfo.GetUnicodeCategory(ch);
            if (uc == UnicodeCategory.NonSpacingMark) continue;
            sb.Append(ch);
        }

        var noMarks = sb.ToString();
        var outSb = new StringBuilder(noMarks.Length);
        var prevDash = false;
        foreach (var c in noMarks)
            if ((c >= 'a' && c <= 'z') || (c >= '0' && c <= '9'))
            {
                outSb.Append(c);
                prevDash = false;
            }
            else
            {
                if (!prevDash)
                {
                    outSb.Append('-');
                    prevDash = true;
                }
            }

        var slug = outSb.ToString().Trim('-');
        if (slug.Length > maxLen)
            slug = slug[..maxLen].Trim('-');
        if (string.IsNullOrEmpty(slug))
            slug = "exam-" + Guid.NewGuid().ToString("N")[..6];
        return slug;
    }

    public static async Task<string> MakeUniqueSlugAsync(VocabularyDbContext db, string baseSlug, CancellationToken ct)
    {
        var slug = baseSlug;
        var i = 1;
        while (await db.Decks.AsNoTracking().AnyAsync(e => e.Slug == slug, ct))
        {
            i++;
            var suffix = "-" + i;
            var maxBase = Math.Max(1, 120 - suffix.Length);
            var trimmed = baseSlug.Length > maxBase ? baseSlug[..maxBase].Trim('-') : baseSlug;
            slug = $"{trimmed}{suffix}";
            if (i > 1000) throw new InvalidOperationException("Cannot generate unique slug");
        }

        return slug;
    }
}
