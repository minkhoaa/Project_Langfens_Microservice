using System.Text.Json;
using System.Text.Json.Serialization;
using dictionary_service.Domains.Entities;

namespace dictionary_service.Features;

/// <summary>
/// In-memory projection of a dictionary row used by the DTO mapper.
/// Same shape previously sent to Elasticsearch, now built directly from EF.
/// </summary>
public record DictionaryDoc(
    [property: JsonPropertyName("id")] long Id,
    [property: JsonPropertyName("word")] string Word,
    [property: JsonPropertyName("wordNorm")] string WordNorm,
    [property: JsonPropertyName("pos")] string Pos,
    [property: JsonPropertyName("data")] JsonElement Data,
    [property: JsonPropertyName("importedAt")] DateTimeOffset ImportedAt)
{
    public static DictionaryDoc FromEntity(DictionaryEntry e) =>
        new(e.Id, e.Word, e.WordNorm, e.Pos, e.Data, e.ImportedAt);
}
