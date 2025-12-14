using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

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
       IReadOnlyList<string> Vietnamese // fallback nếu không map được theo sense
   );

    public sealed record PronunciationDto(string? Region, string? Ipa, string? Mp3Url);
    public sealed record FormDto(string Form, IReadOnlyList<string> Tags);

    public sealed record SenseDto(
        string Id,
        string DefinitionEn,
        IReadOnlyList<string> Labels,          // tags/qualifier
        IReadOnlyList<string> Vietnamese,
        IReadOnlyList<string> Examples
    );


}