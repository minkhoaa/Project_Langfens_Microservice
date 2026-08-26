using System.Text.Json;
using Google.Protobuf;
using Google.Protobuf.WellKnownTypes;

namespace ExamService.Application.Common;

/// <summary>
/// Tiny helpers for converting between JsonDocument/JsonElement and google.protobuf.Struct
/// for the SSOT envelope carrier in exam_internal.proto. Replaces the legacy 13-line ProtoHelper
/// that mixed envelope projection with legacy-column projection (gone after Task 2 wipe).
/// </summary>
public static class ProtoHelper
{
    private static readonly JsonParser Parser = new(JsonParser.Settings.Default.WithIgnoreUnknownFields(true));

    /// <summary>
    /// Parse a JSON string into a google.protobuf.Struct. Empty / null returns an empty Struct (not null).
    /// </summary>
    public static Struct JsonToStruct(string json)
    {
        if (string.IsNullOrWhiteSpace(json)) return new Struct();
        return Parser.Parse<Struct>(json);
    }

    /// <summary>
    /// Removes the top-level "provenance" property from the payload JSON object.
    /// Per spec §8 Q5, provenance is `writeOnly` and must never leak to learners via the
    /// gRPC payload Struct. Returns the input unchanged if it isn't a JSON object.
    /// </summary>
    public static JsonElement ScrubProvenance(JsonElement payload)
    {
        if (payload.ValueKind != JsonValueKind.Object) return payload;

        var dict = new Dictionary<string, JsonElement>();
        foreach (var prop in payload.EnumerateObject())
        {
            if (prop.NameEquals("provenance")) continue;
            dict[prop.Name] = prop.Value.Clone();
        }

        var json = JsonSerializer.Serialize(dict);
        var bytes = System.Text.Encoding.UTF8.GetBytes(json);
        return JsonDocument.Parse(bytes).RootElement.Clone();
    }
}
