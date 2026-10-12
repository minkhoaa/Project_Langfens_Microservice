using System.Text.RegularExpressions;

namespace exam_service.Features.ReadingPaper.Contracts;

/// <summary>
/// Canonical reason taxonomy used to annotate human edits to reading-paper content.
/// These string ids are the source of truth shared with the admin UI; do not rename
/// without coordinating with langfens-fe-app/src/app/admin/_lib/feedbackTaxonomy.ts.
/// </summary>
public static class FeedbackReasons
{
    public const string UnsupportedClaim = "unsupported_claim";
    public const string Ambiguity = "ambiguity";
    public const string TooDirectOrEasy = "too_direct_or_easy"; // editorial label, not calibrated difficulty
    public const string WeakDistractor = "weak_distractor";
    public const string StyleOrGrammar = "style_or_grammar";
    public const string TypoOrFormatting = "typo_or_formatting";
    public const string PolicyViolation = "policy_violation";
    public const string SourceLicenseIssue = "source_license_issue";

    public static readonly IReadOnlyList<string> All = new[]
    {
        UnsupportedClaim,
        Ambiguity,
        TooDirectOrEasy,
        WeakDistractor,
        StyleOrGrammar,
        TypoOrFormatting,
        PolicyViolation,
        SourceLicenseIssue
    };

    public static bool IsKnown(string reason) => All.Contains(reason);
}

/// <summary>Lifecycle of a single human feedback record (admin curation pipeline).</summary>
public static class CurationStatuses
{
    public const string Raw = "RAW";
    public const string Annotated = "ANNOTATED";
    public const string Reviewed = "REVIEWED";
    public const string Curated = "CURATED";
    public const string Rejected = "REJECTED";

    public static readonly IReadOnlyList<string> All = new[] { Raw, Annotated, Reviewed, Curated, Rejected };

    public static bool IsKnown(string status) => All.Contains(status);
}

/// <summary>Action that a feedback record represents.</summary>
public static class FeedbackActions
{
    public const string Create = "CREATE";
    public const string Update = "UPDATE";
    public const string Delete = "DELETE";
    public const string Accept = "ACCEPT";
    public const string Reject = "REJECT";
    public const string Publish = "PUBLISH";
}

public sealed record SmallEditPolicyResult(
    bool IsSmallEdit,
    bool ReasonsRequired,
    bool ReasonsRecommended,
    int CharacterDiff,
    bool FormattingOnly,
    string Explanation);

/// <summary>
/// Decides whether a textual edit counts as "small" (reasons optional) or
/// "substantive" (reasons recommended / required). Mirrors the FE helper so the
/// two sides agree on the threshold.
/// </summary>
public static class SmallEditPolicyHelper
{
    /// <summary>Maximum character-level disagreement allowed for the small-edit route.</summary>
    public const int SmallEditCharacterDiffThreshold = 10;

    private static readonly Regex FormattingChars = new(@"[^\w]+", RegexOptions.Compiled);

    /// <summary>
    /// Returns true when the two strings differ only by formatting (whitespace, punctuation)
    /// once letters/digits are normalized to lowercase. Uses the strip-of-non-word approach
    /// because that matches the typical "fix the markdown rendering" pattern.
    /// </summary>
    public static bool IsFormattingOnly(string before, string after)
    {
        if (before is null || after is null) return false;
        var beforeNorm = FormattingChars.Replace(before.ToLowerInvariant(), string.Empty);
        var afterNorm = FormattingChars.Replace(after.ToLowerInvariant(), string.Empty);
        return string.Equals(beforeNorm, afterNorm, StringComparison.Ordinal);
    }

    /// <summary>
    /// Character-level edit distance using Levenshtein algorithm.
    /// </summary>
    public static int CharacterDiff(string before, string after)
    {
        if (before is null) before = string.Empty;
        if (after is null) after = string.Empty;
        if (string.Equals(before, after, StringComparison.Ordinal)) return 0;
        if (before.Length == 0) return after.Length;
        if (after.Length == 0) return before.Length;

        var m = before.Length;
        var n = after.Length;
        if (Math.Abs(m - n) > 50) return Math.Abs(m - n);

        var prev = new int[n + 1];
        var curr = new int[n + 1];
        for (var j = 0; j <= n; j++) prev[j] = j;

        for (var i = 1; i <= m; i++)
        {
            curr[0] = i;
            for (var j = 1; j <= n; j++)
            {
                var cost = before[i - 1] == after[j - 1] ? 0 : 1;
                curr[j] = Math.Min(
                    Math.Min(prev[j] + 1, curr[j - 1] + 1),
                    prev[j - 1] + cost);
            }
            Array.Copy(curr, prev, n + 1);
        }
        return prev[n];
    }

    public static SmallEditPolicyResult Evaluate(string before, string after)
    {
        var diff = CharacterDiff(before, after);
        var formattingOnly = diff > 0 && IsFormattingOnly(before, after);
        var isSmall = diff == 0 || diff <= SmallEditCharacterDiffThreshold || formattingOnly;
        return new SmallEditPolicyResult(
            IsSmallEdit: isSmall,
            ReasonsRequired: !isSmall,
            ReasonsRecommended: !isSmall && !formattingOnly,
            CharacterDiff: diff,
            FormattingOnly: formattingOnly,
            Explanation: isSmall
                ? formattingOnly
                    ? "Formatting-only change — reasons optional."
                    : "Small edit (≤ 10 character diff) — reasons optional."
                : "Substantive edit — at least one reason recommended; reasoning required before finalization.");
    }
}

/// <summary>DTO returned by GET /api/v2/reading/feedback endpoints.</summary>
public sealed record HumanFeedbackDto(
    Guid Id,
    string FeedbackId,
    string RunId,
    Guid ExamId,
    string? SectionId,
    string? QuestionId,
    string? OptionId,
    string TargetEntityType,
    string TargetEntityId,
    string? ArtifactId,
    int? ArtifactVersion,
    string? BeforeContentHash,
    string? AfterContentHash,
    string? BeforePayloadJson,
    string? AfterPayloadJson,
    string? DiffJson,
    string? EditorId,
    string? EditorRole,
    IReadOnlyList<string> Reasons,
    string? Comment,
    string? DownstreamImpactJson,
    string ActionType,
    string CurationStatus,
    string? IdempotencyKey,
    DateTime CreatedAt);

/// <summary>
/// Body for POST /api/v2/reading/feedback/{id}/review.
/// Editors / admins send this to advance curation status; the server is idempotent
/// on <see cref="IdempotencyKey"/>.
/// </summary>
public sealed record FeedbackReviewRequest
{
    public string CurationStatus { get; init; } = CurationStatuses.Reviewed;
    public string? ReviewerNotes { get; init; }
    public IReadOnlyList<string> Reasons { get; init; } = Array.Empty<string>();
    public string? ReviewerId { get; init; }
    public string? ExpectedCurrentStatus { get; init; }
    public string? IdempotencyKey { get; init; }
}

/// <summary>Filter + paging for GET /api/v2/reading/feedback.</summary>
public sealed record FeedbackFilterRequest
{
    public Guid? ExamId { get; init; }
    public string? RunId { get; init; }
    public string? CurationStatus { get; init; }
    public int Page { get; init; } = 1;
    public int MaxSize { get; init; } = 50;
}