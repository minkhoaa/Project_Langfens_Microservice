using System.Text.Json;

namespace attempt_service.Features.Helpers;

public interface ISectionContextLookup
{
    string GetPassageMd(JsonDocument paper, Guid sectionId);
    string GetTranscriptMd(JsonDocument paper, Guid sectionId);
}

public sealed class SectionContextLookup : ISectionContextLookup
{
    public string GetPassageMd(JsonDocument paper, Guid sectionId)
        => GetSectionField(paper, sectionId, "passageMd");

    public string GetTranscriptMd(JsonDocument paper, Guid sectionId)
        => GetSectionField(paper, sectionId, "transcriptMd");

    private static string GetSectionField(JsonDocument paper, Guid sectionId, string field)
    {
        if (!paper.RootElement.TryGetProperty("sections", out var sections)) return string.Empty;
        foreach (var s in sections.EnumerateArray())
        {
            if (!s.TryGetProperty("id", out var idProp) || idProp.ValueKind != JsonValueKind.String) continue;
            if (!Guid.TryParse(idProp.GetString(), out var id) || id != sectionId) continue;
            if (!s.TryGetProperty(field, out var val) || val.ValueKind != JsonValueKind.String) return string.Empty;
            return val.GetString() ?? string.Empty;
        }
        return string.Empty;
    }
}
