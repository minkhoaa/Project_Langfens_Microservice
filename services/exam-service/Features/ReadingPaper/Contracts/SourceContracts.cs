using System.Text.Json.Serialization;

namespace exam_service.Features.ReadingPaper.Contracts;

public sealed record SourceMetadata(
    [property: JsonPropertyName("pmid")] string? Pmid,
    [property: JsonPropertyName("pmcid")] string? Pmcid,
    [property: JsonPropertyName("doi")] string? Doi,
    [property: JsonPropertyName("title")] string Title,
    [property: JsonPropertyName("authors")] IReadOnlyList<string> Authors,
    [property: JsonPropertyName("journal")] string? Journal,
    [property: JsonPropertyName("pubDate")] string? PubDate,
    [property: JsonPropertyName("sourceUrl")] string SourceUrl,
    [property: JsonPropertyName("licenseType")] string LicenseType = "Open Access",
    [property: JsonPropertyName("licenseCleared")] bool LicenseCleared = true,
    [property: JsonPropertyName("contentHash")] string? ContentHash = null,
    [property: JsonPropertyName("normalizedTextHash")] string? NormalizedTextHash = null,
    [property: JsonPropertyName("normalizerVersion")] string? NormalizerVersion = null,
    [property: JsonPropertyName("originalUrl")] string? OriginalUrl = null,
    [property: JsonPropertyName("effectiveUrl")] string? EffectiveUrl = null,
    [property: JsonPropertyName("fetchedAt")] DateTime? FetchedAt = null,
    [property: JsonPropertyName("provenance")] string? Provenance = null,
    [property: JsonPropertyName("rightsStatement")] string? RightsStatement = null
);

public sealed record SourceDocument(
    [property: JsonPropertyName("text")] string Text,
    [property: JsonPropertyName("wordCount")] int WordCount,
    [property: JsonPropertyName("paragraphs")] IReadOnlyList<string> Paragraphs,
    [property: JsonPropertyName("headings")] IReadOnlyList<string> Headings,
    [property: JsonPropertyName("extractedAt")] DateTime ExtractedAt
);

public sealed record SourceItem(
    [property: JsonPropertyName("sourceId")] string SourceId,
    [property: JsonPropertyName("metadata")] SourceMetadata Metadata,
    [property: JsonPropertyName("document")] SourceDocument Document
);

public sealed record SourcePack(
    [property: JsonPropertyName("packId")] string PackId,
    [property: JsonPropertyName("runId")] string RunId,
    [property: JsonPropertyName("sectionId")] int? SectionId,
    [property: JsonPropertyName("revision")] int Revision,
    [property: JsonPropertyName("sources")] IReadOnlyList<SourceItem> Sources,
    [property: JsonPropertyName("combinedWordCount")] int CombinedWordCount,
    [property: JsonPropertyName("suitabilityScore")] double SuitabilityScore,
    [property: JsonPropertyName("licenseCleared")] bool LicenseCleared,
    [property: JsonPropertyName("createdAt")] DateTime CreatedAt
);
