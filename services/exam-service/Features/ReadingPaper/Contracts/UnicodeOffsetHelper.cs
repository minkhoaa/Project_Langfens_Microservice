using System.Globalization;

namespace exam_service.Features.ReadingPaper.Contracts;

/// <summary>
/// Provides cross-language Unicode code-point alignment between Python str indexing and .NET UTF-16 chars.
/// </summary>
public static class UnicodeOffsetHelper
{
    /// <summary>
    /// Converts a Unicode code-point index (Python 0-based code-point offset) to a .NET UTF-16 string index.
    /// Characters outside BMP (surrogate pairs, e.g. emojis) consume 2 UTF-16 chars.
    /// </summary>
    public static int CodePointToUtf16Offset(string text, int codePointOffset)
    {
        if (string.IsNullOrEmpty(text) || codePointOffset <= 0)
            return 0;

        int currentCp = 0;
        int utf16Index = 0;

        while (utf16Index < text.Length && currentCp < codePointOffset)
        {
            if (char.IsSurrogatePair(text, utf16Index))
            {
                utf16Index += 2;
            }
            else
            {
                utf16Index += 1;
            }
            currentCp++;
        }

        return utf16Index;
    }

    /// <summary>
    /// Converts a .NET UTF-16 string index to a Unicode code-point index.
    /// </summary>
    public static int Utf16ToCodePointOffset(string text, int utf16Offset)
    {
        if (string.IsNullOrEmpty(text) || utf16Offset <= 0)
            return 0;

        int currentCp = 0;
        int currentUtf16 = 0;
        int targetUtf16 = Math.Min(utf16Offset, text.Length);

        while (currentUtf16 < targetUtf16)
        {
            if (char.IsSurrogatePair(text, currentUtf16))
            {
                currentUtf16 += 2;
            }
            else
            {
                currentUtf16 += 1;
            }
            currentCp++;
        }

        return currentCp;
    }

    /// <summary>
    /// Slices a string using half-open Unicode code-point interval [startCodePoint, endCodePoint).
    /// </summary>
    public static string GetSubstringByCodePoints(string text, int startCodePoint, int endCodePoint)
    {
        if (string.IsNullOrEmpty(text) || startCodePoint >= endCodePoint)
            return string.Empty;

        int startUtf16 = CodePointToUtf16Offset(text, startCodePoint);
        int endUtf16 = CodePointToUtf16Offset(text, endCodePoint);

        int length = Math.Max(0, endUtf16 - startUtf16);
        return text.Substring(startUtf16, length);
    }

    /// <summary>
    /// Verifies the cross-language invariant that text[start:end] strictly equals expected span text.
    /// </summary>
    public static bool ValidateSpanInvariant(string documentText, int startCodePoint, int endCodePoint, string expectedSpanText)
    {
        var actualSpan = GetSubstringByCodePoints(documentText, startCodePoint, endCodePoint);
        return string.Equals(actualSpan, expectedSpanText, StringComparison.Ordinal);
    }
}
