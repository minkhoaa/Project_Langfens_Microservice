using System.Collections.Generic;

namespace Shared.PublicContracts.Contracts.Ai;

/// <summary>
/// Shared RAG feedback envelope returned by ai-service for writing,
/// reading, listening, speaking, and grammar items. Consumed by the FE
/// as a single shape and rendered by RagFeedbackCard.
/// </summary>
public sealed record RagFeedbackEnvelope(
    string ItemId,
    string Domain,                                    // "writing" | "reading" | "listening" | "speaking" | "grammar"
    double? OverallBand,
    IReadOnlyList<CriterionScore> Criteria,
    IReadOnlyList<Evidence> Evidence,
    IReadOnlyList<Suggestion> Suggestions,
    string? RawLlmJson = null);

public sealed record CriterionScore(
    string Name,
    double Band,
    string Comment,
    IReadOnlyList<string>? EvidenceIds = null);

public sealed record Evidence(
    string Id,
    string Text,
    string Source,
    double Relevance);

public sealed record Suggestion(
    string Text,
    string Target);
