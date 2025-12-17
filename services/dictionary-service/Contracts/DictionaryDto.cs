using System;
using System.Collections.Generic;

namespace dictionary_service.Contracts
{
    public sealed record DictionaryDetailsDto(
        long Id,
        string Word,
        string Pos,
        string WordNorm,
        DateTimeOffset ImportedAt,
        IReadOnlyList<PronunciationDto> Pronunciations,
        IReadOnlyList<FormDto> Forms,
        IReadOnlyList<SenseDto> Senses,
        IReadOnlyList<string> VietnameseTerms // fallback (VI terms ở level entry)
    );

    public sealed record PronunciationDto(string? Region, string? Ipa, string? Mp3Url);
    public sealed record FormDto(string Form, IReadOnlyList<string> Tags);

    public sealed record SenseDto(
        string Id,
        string DefinitionEn,
        string? DefinitionVi,                  // GIẢI THÍCH VI (dịch từ DefinitionEn)
        IReadOnlyList<string> Labels,          // tags/qualifier
        IReadOnlyList<string> VietnameseTerms, // NGHĨA VI kiểu “từ/cụm từ” (từ điển, tự điển...)
        IReadOnlyList<string> Examples
    );
}
