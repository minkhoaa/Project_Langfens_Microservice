using System.Text.Json;
using attempt_service.Features.Helpers;
using Xunit;

namespace attempt_service.Tests.Helpers;

public class SectionContextLookupTests
{
    private static JsonDocument Snapshot() => JsonDocument.Parse("""
    {
      "sections": [
        {
          "id": "11111111-1111-1111-1111-111111111111",
          "passageMd": "The library opens at nine.",
          "transcriptMd": "",
          "questionGroups": []
        },
        {
          "id": "22222222-2222-2222-2222-222222222222",
          "passageMd": "",
          "transcriptMd": "Librarian: Good morning.",
          "questionGroups": []
        }
      ]
    }
    """);

    [Fact]
    public void GetPassageMd_returns_text_for_reading_section()
    {
        var lookup = new SectionContextLookup();
        var passage = lookup.GetPassageMd(Snapshot(), Guid.Parse("11111111-1111-1111-1111-111111111111"));
        Assert.Equal("The library opens at nine.", passage);
    }

    [Fact]
    public void GetTranscriptMd_returns_text_for_listening_section()
    {
        var lookup = new SectionContextLookup();
        var transcript = lookup.GetTranscriptMd(Snapshot(), Guid.Parse("22222222-2222-2222-2222-222222222222"));
        Assert.Equal("Librarian: Good morning.", transcript);
    }

    [Fact]
    public void GetPassageMd_returns_empty_when_section_missing()
    {
        var lookup = new SectionContextLookup();
        var passage = lookup.GetPassageMd(Snapshot(), Guid.NewGuid());
        Assert.Equal(string.Empty, passage);
    }

    [Fact]
    public void GetTranscriptMd_returns_empty_when_section_missing()
    {
        var lookup = new SectionContextLookup();
        var t = lookup.GetTranscriptMd(Snapshot(), Guid.NewGuid());
        Assert.Equal(string.Empty, t);
    }
}
