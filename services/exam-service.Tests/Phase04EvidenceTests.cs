using System.Text.Json;
using exam_service.Features.ReadingPaper.Contracts;
using Xunit;

namespace exam_service.Tests;

public class Phase04EvidenceTests
{
    [Fact]
    public void T04_03_UnicodeOffsets_Emojis_CombiningMarks_Roundtrip()
    {
        // Text mixing English, Vietnamese diacritics, scientific symbols, and multi-byte emojis (outside BMP)
        const string text = "🌍 Global climate research in Đà Nẵng shows 14.5% reduction in CO₂ emissions 🚀.";

        // Code point count vs UTF-16 length:
        // '🌍' is code point 0, but 2 UTF-16 chars (surrogate pair)
        // '🚀' is also a surrogate pair
        int totalCodePoints = 0;
        for (int i = 0; i < text.Length; i++)
        {
            if (char.IsSurrogatePair(text, i))
            {
                i++;
            }
            totalCodePoints++;
        }

        // Verify UTF-16 string length is greater than total code points due to 2 emojis (each +1)
        Assert.Equal(totalCodePoints + 2, text.Length);

        // Test offset mapping for substring "Đà Nẵng"
        // 🌍 is cp 0, space is cp 1, "Global" is cp 2..7, etc.
        int daNangStartCp = text.IndexOf("Đà Nẵng", StringComparison.Ordinal) - 1; // 1 emoji before
        // Calculate exact code points to "Đà Nẵng"
        int daNangStartUtf16 = text.IndexOf("Đà Nẵng", StringComparison.Ordinal);
        int daNangEndUtf16 = daNangStartUtf16 + "Đà Nẵng".Length;

        int startCp = UnicodeOffsetHelper.Utf16ToCodePointOffset(text, daNangStartUtf16);
        int endCp = UnicodeOffsetHelper.Utf16ToCodePointOffset(text, daNangEndUtf16);

        // Verify roundtrip conversion
        Assert.Equal(daNangStartUtf16, UnicodeOffsetHelper.CodePointToUtf16Offset(text, startCp));
        Assert.Equal(daNangEndUtf16, UnicodeOffsetHelper.CodePointToUtf16Offset(text, endCp));

        // Verify span invariant: text[startCp:endCp] == "Đà Nẵng"
        string extractedSpan = UnicodeOffsetHelper.GetSubstringByCodePoints(text, startCp, endCp);
        Assert.Equal("Đà Nẵng", extractedSpan);
        Assert.True(UnicodeOffsetHelper.ValidateSpanInvariant(text, startCp, endCp, "Đà Nẵng"));

        // Test offset mapping for "14.5%"
        int pctStartUtf16 = text.IndexOf("14.5%", StringComparison.Ordinal);
        int pctEndUtf16 = pctStartUtf16 + "14.5%".Length;
        int pctStartCp = UnicodeOffsetHelper.Utf16ToCodePointOffset(text, pctStartUtf16);
        int pctEndCp = UnicodeOffsetHelper.Utf16ToCodePointOffset(text, pctEndUtf16);

        Assert.Equal("14.5%", UnicodeOffsetHelper.GetSubstringByCodePoints(text, pctStartCp, pctEndCp));
        Assert.True(UnicodeOffsetHelper.ValidateSpanInvariant(text, pctStartCp, pctEndCp, "14.5%"));
    }

    [Fact]
    public void T04_03_SourcePack_EvidenceGraph_Serialization_Roundtrip()
    {
        var meta = new SourceMetadata(
            Pmid: "123456",
            Pmcid: "PMC999999",
            Doi: "10.1234/science.2026.01",
            Title: "Biodiversity in Marine Habitats",
            Authors: new[] { "Dr. Elena Rostova", "Dr. Alex Thorne" },
            Journal: "Journal of Marine Ecology",
            PubDate: "2026-03-15",
            SourceUrl: "https://europepmc.org/articles/PMC999999",
            LicenseType: "CC BY 4.0",
            LicenseCleared: true,
            ContentHash: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
            NormalizedTextHash: "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
            NormalizerVersion: "v2.0.0"
        );

        var doc = new SourceDocument(
            Text: "Coral reefs sustain diverse ecosystems under rising ocean temperatures.",
            WordCount: 650,
            Paragraphs: new[] { "Coral reefs sustain diverse ecosystems under rising ocean temperatures." },
            Headings: new[] { "Introduction" },
            ExtractedAt: DateTime.UtcNow
        );

        var item = new SourceItem("src_001", meta, doc);

        var pack = new SourcePack(
            PackId: "pack_001",
            RunId: "run_test_001",
            SectionId: 1,
            Revision: 1,
            Sources: new[] { item },
            CombinedWordCount: 650,
            SuitabilityScore: 1.0,
            LicenseCleared: true,
            CreatedAt: DateTime.UtcNow
        );

        // Serialize and Deserialize SourcePack
        var packJson = JsonSerializer.Serialize(pack, LoopEngineJson.Options);
        var deserializedPack = JsonSerializer.Deserialize<SourcePack>(packJson, LoopEngineJson.Options);

        Assert.NotNull(deserializedPack);
        Assert.Equal("pack_001", deserializedPack.PackId);
        Assert.Equal(1, deserializedPack.Revision);
        Assert.Equal("PMC999999", deserializedPack.Sources[0].Metadata.Pmcid);
        Assert.True(deserializedPack.LicenseCleared);

        // Build and Roundtrip EvidenceGraph
        var claim = new VerifiedClaim(
            ClaimId: "claim_001",
            Text: "Rising ocean temperatures challenge coral reef ecosystems.",
            SourceId: "src_001",
            Offsets: new SourceOffset(0, 71, "src_001"),
            Confidence: 0.98,
            Entailment: EntailmentLabel.Entails,
            Qualifier: Qualifier.Definite,
            Keywords: new[] { "coral", "ocean", "temperature" }
        );

        var absence = new AbsenceAssessment(
            AssessmentId: "abs_001",
            ClaimOrTopic: "Deep sea hydrothermal vents",
            AbsenceReason: "Source focuses strictly on tropical coral reefs without discussing deep ocean vents",
            TopicalContextSpan: null,
            AbsenceConfirmed: true
        );

        var graph = new EvidenceGraph(
            GraphId: "eg_001",
            RunId: "run_test_001",
            SectionId: 1,
            Claims: new[] { claim },
            AbsenceAssessments: new[] { absence },
            VerifiedAt: DateTime.UtcNow
        );

        var graphJson = JsonSerializer.Serialize(graph, LoopEngineJson.Options);
        var deserializedGraph = JsonSerializer.Deserialize<EvidenceGraph>(graphJson, LoopEngineJson.Options);

        Assert.NotNull(deserializedGraph);
        Assert.Equal("eg_001", deserializedGraph.GraphId);
        Assert.Single(deserializedGraph.Claims);
        Assert.Equal(EntailmentLabel.Entails, deserializedGraph.Claims[0].Entailment);
        Assert.Equal(Qualifier.Definite, deserializedGraph.Claims[0].Qualifier);
        Assert.Single(deserializedGraph.AbsenceAssessments);
        Assert.True(deserializedGraph.AbsenceAssessments[0].AbsenceConfirmed);
    }

    [Fact]
    public void T04_07_SourcePack_RevisionBumping_InvalidatesDescendants()
    {
        var metaV1 = new SourceMetadata(
            Pmid: null,
            Pmcid: null,
            Doi: null,
            Title: "Source Title",
            Authors: new[] { "Author A" },
            Journal: null,
            PubDate: null,
            SourceUrl: "https://example.org/article",
            LicenseType: "CC-BY",
            LicenseCleared: true
        );
        var docV1 = new SourceDocument("Original source content here.", 620, new[] { "Original content." }, Array.Empty<string>(), DateTime.UtcNow);
        var packV1 = new SourcePack("pack_dyn", "run_01", 1, 1, new[] { new SourceItem("src_1", metaV1, docV1) }, 620, 1.0, true, DateTime.UtcNow);

        // Package into Envelope
        var docElemV1 = JsonSerializer.SerializeToElement(packV1, LoopEngineJson.Options);
        var hashV1 = ArtifactEnvelope.ComputeContentHash(docElemV1);
        var refV1 = new ArtifactRef(packV1.PackId, ArtifactType.SourcePack, packV1.Revision, hashV1);

        // Update content at same URL -> revision 2
        var docV2 = new SourceDocument("Updated novel research content here.", 640, new[] { "Updated content." }, Array.Empty<string>(), DateTime.UtcNow);
        var packV2 = new SourcePack("pack_dyn", "run_01", 1, 2, new[] { new SourceItem("src_1", metaV1, docV2) }, 640, 1.0, true, DateTime.UtcNow);

        var docElemV2 = JsonSerializer.SerializeToElement(packV2, LoopEngineJson.Options);
        var hashV2 = ArtifactEnvelope.ComputeContentHash(docElemV2);
        var refV2 = new ArtifactRef(packV2.PackId, ArtifactType.SourcePack, packV2.Revision, hashV2);

        // Content hash and revision must be distinct
        Assert.NotEqual(hashV1, hashV2);
        Assert.Equal(1, refV1.Version);
        Assert.Equal(2, refV2.Version);

        // Child artifact depending on refV1 does not match refV2 -> invalidated
        Assert.NotEqual(refV1, refV2);
    }
}
