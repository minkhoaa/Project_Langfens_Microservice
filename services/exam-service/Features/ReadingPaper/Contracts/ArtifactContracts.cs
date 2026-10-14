using System.Security.Cryptography;
using System.Text;
using System.Text.Encodings.Web;
using System.Text.Json;
using System.Text.Json.Serialization;
namespace exam_service.Features.ReadingPaper.Contracts;

[JsonConverter(typeof(JsonStringEnumConverter))]
public enum ArtifactType
{
    SourcePack,
    EvidenceGraph,
    ExamBlueprint,
    Passage,
    QuestionGroup,
    Question,
    Section,
    ReadingPaper
}

public sealed record ArtifactRef(
    [property: JsonPropertyName("artifactId")] string ArtifactId,
    [property: JsonPropertyName("artifactType")] ArtifactType ArtifactType,
    [property: JsonPropertyName("version")] int Version,
    [property: JsonPropertyName("contentHash")] string ContentHash
);

public sealed record ArtifactEnvelope(
    [property: JsonPropertyName("artifactId")] string ArtifactId,
    [property: JsonPropertyName("artifactType")] ArtifactType ArtifactType,
    [property: JsonPropertyName("version")] int Version,
    [property: JsonPropertyName("runId")] string RunId,
    [property: JsonPropertyName("sectionId")] int? SectionId,
    [property: JsonPropertyName("schemaVersion")] string SchemaVersion,
    [property: JsonPropertyName("contentHash")] string ContentHash,
    [property: JsonPropertyName("createdAt")] DateTime CreatedAt,
    [property: JsonPropertyName("producerVersion")] string ProducerVersion,
    [property: JsonPropertyName("payload")] JsonElement Payload,
    [property: JsonPropertyName("parentRefs")] IReadOnlyList<ArtifactRef> ParentRefs
)
{
    public ArtifactRef ToRef() => new(ArtifactId, ArtifactType, Version, ContentHash);

    public static string ComputeContentHash(JsonElement payload, IReadOnlyList<ArtifactRef>? parentRefs = null)
    {
        var refsData = (parentRefs ?? Array.Empty<ArtifactRef>())
            .OrderBy(r => r.ArtifactType.ToString(), StringComparer.Ordinal)
            .ThenBy(r => r.ArtifactId, StringComparer.Ordinal)
            .ThenBy(r => r.Version)
            .Select(r => new {
                artifactId = r.ArtifactId,
                artifactType = r.ArtifactType.ToString(),
                contentHash = r.ContentHash,
                version = r.Version
            })
            .ToList();
        using var memoryStream = new MemoryStream();
        using (var writer = new Utf8JsonWriter(memoryStream, new JsonWriterOptions { Indented = false, Encoder = JavaScriptEncoder.UnsafeRelaxedJsonEscaping }))
        {
            writer.WriteStartObject();
            writer.WritePropertyName("parentRefs");
            JsonSerializer.Serialize(writer, refsData, LoopEngineJson.Options);
            writer.WritePropertyName("payload");
            WriteCanonicalElement(writer, payload);
            writer.WriteEndObject();
        }

        var bytes = SHA256.HashData(memoryStream.ToArray());
        return Convert.ToHexStringLower(bytes);
    }

    private static void WriteCanonicalElement(Utf8JsonWriter writer, JsonElement element)
    {
        switch (element.ValueKind)
        {
            case JsonValueKind.Object:
                writer.WriteStartObject();
                foreach (var prop in element.EnumerateObject().OrderBy(p => p.Name, StringComparer.Ordinal))
                {
                    writer.WritePropertyName(prop.Name);
                    WriteCanonicalElement(writer, prop.Value);
                }
                writer.WriteEndObject();
                break;
            case JsonValueKind.Array:
                writer.WriteStartArray();
                foreach (var item in element.EnumerateArray())
                {
                    WriteCanonicalElement(writer, item);
                }
                writer.WriteEndArray();
                break;
            default:
                element.WriteTo(writer);
                break;
        }
    }
}
