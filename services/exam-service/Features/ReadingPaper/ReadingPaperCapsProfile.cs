using System.Collections.ObjectModel;
using System.Globalization;
using System.Security.Cryptography;
using System.Text;
using System.Text.Encodings.Web;
using System.Text.Json;

namespace exam_service.Features.ReadingPaper;

public sealed class ReadingPaperCapsProfile
{
    public const int UnlimitedCap = -1;

    private ReadingPaperCapsProfile(
        string version,
        string source,
        string benchmarkMode,
        string benchmarkMonetaryCapMode,
        SortedDictionary<string, int> caps)
    {
        Version = version;
        Source = source;
        BenchmarkMode = benchmarkMode;
        BenchmarkMonetaryCapMode = benchmarkMonetaryCapMode;
        // Read-only view wraps the exact map serialized into SnapshotJson, so a caller can
        // never mutate the published caps away from the sealed Sha256/scalar caps.
        Caps = new ReadOnlyDictionary<string, int>(caps);
        SnapshotJson = JsonSerializer.Serialize(
            new SortedDictionary<string, object>(StringComparer.Ordinal)
            {
                ["benchmarkMode"] = benchmarkMode,
                ["benchmarkMonetaryCapMode"] = benchmarkMonetaryCapMode,
                ["caps"] = caps,
                ["profileSource"] = source,
                ["profileVersion"] = version
            },
            new JsonSerializerOptions { Encoder = JavaScriptEncoder.UnsafeRelaxedJsonEscaping });
        Sha256 = Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(SnapshotJson))).ToLowerInvariant();

        RunBudgetCapCalls = caps["standaloneRunBudgetCapCalls"];
        RunBudgetCapTokens = caps["standaloneRunBudgetCapTokens"];
        RunBudgetCapWallTimeSeconds = caps["standaloneRunBudgetCapWallTimeSeconds"];
        BenchmarkChildRunCallCap = caps["benchmarkChildRunCallCap"];
        BenchmarkChildRunTokenCap = caps["benchmarkChildRunTokenCap"];
        BenchmarkChildRunWallTimeCapSeconds = caps["benchmarkChildRunWallTimeCapSeconds"];
    }

    public string Version { get; }
    public string Source { get; }
    public string BenchmarkMode { get; }
    public string BenchmarkMonetaryCapMode { get; }
    public bool IsBenchmarkUnlimited =>
        string.Equals(BenchmarkMode, "UNLIMITED", StringComparison.OrdinalIgnoreCase) &&
        string.Equals(BenchmarkMonetaryCapMode, "UNLIMITED", StringComparison.OrdinalIgnoreCase);
    public string Sha256 { get; }
    public string SnapshotJson { get; }

    /// <summary>
    /// Read-only view over the authoritative caps, which stay pinned to the sealed
    /// <see cref="SnapshotJson"/> digest. Wrapped once at construction; no per-access copy.
    /// </summary>
    public IReadOnlyDictionary<string, int> Caps { get; }

    public int RunBudgetCapCalls { get; }
    public int RunBudgetCapTokens { get; }
    public int RunBudgetCapWallTimeSeconds { get; }
    public int BenchmarkChildRunCallCap { get; }
    public int BenchmarkChildRunTokenCap { get; }
    public int BenchmarkChildRunWallTimeCapSeconds { get; }

    public static ReadingPaperCapsProfile FromConfiguration(IConfiguration configuration)
    {
        var version = RequiredText(configuration, "LOOP_CAPS_PROFILE_VERSION");
        var source = RequiredText(configuration, "LOOP_CAPS_PROFILE_SOURCE");
        var caps = new SortedDictionary<string, int>(StringComparer.Ordinal)
        {
            ["benchmarkChildRunCallCap"] = RequiredInt(configuration, "BENCHMARK_CHILD_RUN_MAX_CALLS"),
            ["benchmarkChildRunTokenCap"] = RequiredInt(configuration, "BENCHMARK_CHILD_RUN_MAX_TOKENS"),
            ["benchmarkChildRunWallTimeCapSeconds"] = RequiredInt(configuration, "BENCHMARK_CHILD_RUN_MAX_WALL_TIME_SECONDS"),
            ["benchmarkSectionCallCap"] = RequiredInt(configuration, "READING_PAPER_BENCHMARK_SECTION_CALL_CAP"),
            ["benchmarkSectionTokenCap"] = RequiredInt(configuration, "READING_PAPER_BENCHMARK_SECTION_TOKEN_CAP"),
            ["benchmarkSectionWallTimeCapSeconds"] = RequiredInt(configuration, "READING_PAPER_BENCHMARK_SECTION_WALL_TIME_CAP_SECONDS"),
            ["benchmarkArtifactPassageCallCap"] = RequiredInt(configuration, "READING_PAPER_BENCHMARK_PASSAGE_CALL_CAP"),
            ["benchmarkArtifactPassageTokenCap"] = RequiredInt(configuration, "READING_PAPER_BENCHMARK_PASSAGE_TOKEN_CAP"),
            ["benchmarkArtifactPassageWallTimeCapSeconds"] = RequiredInt(configuration, "READING_PAPER_BENCHMARK_PASSAGE_WALL_TIME_CAP_SECONDS"),
            ["benchmarkArtifactQuestionsCallCap"] = RequiredInt(configuration, "READING_PAPER_BENCHMARK_QUESTIONS_CALL_CAP"),
            ["benchmarkArtifactQuestionsTokenCap"] = RequiredInt(configuration, "READING_PAPER_BENCHMARK_QUESTIONS_TOKEN_CAP"),
            ["benchmarkArtifactQuestionsWallTimeCapSeconds"] = RequiredInt(configuration, "READING_PAPER_BENCHMARK_QUESTIONS_WALL_TIME_CAP_SECONDS"),
            ["benchmarkArtifactSolverCallCap"] = RequiredInt(configuration, "READING_PAPER_BENCHMARK_SOLVER_CALL_CAP"),
            ["benchmarkArtifactSolverTokenCap"] = RequiredInt(configuration, "READING_PAPER_BENCHMARK_SOLVER_TOKEN_CAP"),
            ["benchmarkArtifactSolverWallTimeCapSeconds"] = RequiredInt(configuration, "READING_PAPER_BENCHMARK_SOLVER_WALL_TIME_CAP_SECONDS"),
            ["benchmarkArtifactReviewCallCap"] = RequiredInt(configuration, "READING_PAPER_BENCHMARK_REVIEW_CALL_CAP"),
            ["benchmarkArtifactReviewTokenCap"] = RequiredInt(configuration, "READING_PAPER_BENCHMARK_REVIEW_TOKEN_CAP"),
            ["benchmarkArtifactReviewWallTimeCapSeconds"] = RequiredInt(configuration, "READING_PAPER_BENCHMARK_REVIEW_WALL_TIME_CAP_SECONDS"),
            ["candidateMaxBacktrackingSteps"] = RequiredInt(configuration, "CANDIDATE_MAX_BACKTRACKING_STEPS"),
            ["candidateMaxSearchDepth"] = RequiredInt(configuration, "CANDIDATE_MAX_SEARCH_DEPTH"),
            ["candidatePoolLimitCompletion"] = RequiredInt(configuration, "CANDIDATE_POOL_LIMIT_COMPLETION"),
            ["candidatePoolLimitMcq"] = RequiredInt(configuration, "CANDIDATE_POOL_LIMIT_MCQ"),
            ["candidatePoolLimitShortAnswer"] = RequiredInt(configuration, "CANDIDATE_POOL_LIMIT_SHORT_ANSWER"),
            ["candidatePoolLimitSummary"] = RequiredInt(configuration, "CANDIDATE_POOL_LIMIT_SUMMARY"),
            ["candidatePoolLimitTfng"] = RequiredInt(configuration, "CANDIDATE_POOL_LIMIT_TFNG"),
            ["evaluationCacheMaxEntries"] = RequiredInt(configuration, "EVALUATION_CACHE_MAX_ENTRIES"),
            ["evaluatorDeterministicTimeoutSeconds"] = RequiredInt(configuration, "EVALUATOR_DETERMINISTIC_TIMEOUT_SECONDS"),
            ["evaluatorMaxTokensPerEvaluation"] = RequiredInt(configuration, "EVALUATOR_MAX_TOKENS_PER_EVALUATION"),
            ["evaluatorSemanticTimeoutSeconds"] = RequiredInt(configuration, "EVALUATOR_SEMANTIC_TIMEOUT_SECONDS"),
            ["evaluatorStageTimeoutSeconds"] = RequiredInt(configuration, "EVALUATOR_STAGE_TIMEOUT_SECONDS"),
            ["generateTokenReservation"] = RequiredInt(configuration, "LOOP_GENERATE_TOKEN_RESERVATION"),
            ["passageGenerateTokenReservation"] = RequiredInt(configuration, "PASSAGE_GENERATE_TOKEN_RESERVATION"),
            ["passageGenerateMaxTokens"] = RequiredInt(configuration, "PASSAGE_GENERATE_MAX_TOKENS"),
            ["evaluateTokenReservation"] = RequiredInt(configuration, "LOOP_EVALUATE_TOKEN_RESERVATION"),
            ["legacySectionCallCap"] = RequiredInt(configuration, "READING_PAPER_LEGACY_SECTION_CALL_CAP"),
            ["legacySectionTokenCap"] = RequiredInt(configuration, "READING_PAPER_LEGACY_SECTION_TOKEN_CAP"),
            ["legacySectionWallTimeCapSeconds"] = RequiredInt(configuration, "READING_PAPER_LEGACY_SECTION_WALL_TIME_CAP_SECONDS"),
            ["legacyArtifactPassageCallCap"] = RequiredInt(configuration, "READING_PAPER_LEGACY_PASSAGE_CALL_CAP"),
            ["legacyArtifactPassageTokenCap"] = RequiredInt(configuration, "READING_PAPER_LEGACY_PASSAGE_TOKEN_CAP"),
            ["legacyArtifactPassageWallTimeCapSeconds"] = RequiredInt(configuration, "READING_PAPER_LEGACY_PASSAGE_WALL_TIME_CAP_SECONDS"),
            ["legacyArtifactQuestionsCallCap"] = RequiredInt(configuration, "READING_PAPER_LEGACY_QUESTIONS_CALL_CAP"),
            ["legacyArtifactQuestionsTokenCap"] = RequiredInt(configuration, "READING_PAPER_LEGACY_QUESTIONS_TOKEN_CAP"),
            ["legacyArtifactQuestionsWallTimeCapSeconds"] = RequiredInt(configuration, "READING_PAPER_LEGACY_QUESTIONS_WALL_TIME_CAP_SECONDS"),
            ["legacyArtifactSolverCallCap"] = RequiredInt(configuration, "READING_PAPER_LEGACY_SOLVER_CALL_CAP"),
            ["legacyArtifactSolverTokenCap"] = RequiredInt(configuration, "READING_PAPER_LEGACY_SOLVER_TOKEN_CAP"),
            ["legacyArtifactSolverWallTimeCapSeconds"] = RequiredInt(configuration, "READING_PAPER_LEGACY_SOLVER_WALL_TIME_CAP_SECONDS"),
            ["legacyArtifactReviewCallCap"] = RequiredInt(configuration, "READING_PAPER_LEGACY_REVIEW_CALL_CAP"),
            ["legacyArtifactReviewTokenCap"] = RequiredInt(configuration, "READING_PAPER_LEGACY_REVIEW_TOKEN_CAP"),
            ["legacyArtifactReviewWallTimeCapSeconds"] = RequiredInt(configuration, "READING_PAPER_LEGACY_REVIEW_WALL_TIME_CAP_SECONDS"),
            ["loopMaxConsecutiveNoProgress"] = RequiredInt(configuration, "LOOP_MAX_CONSECUTIVE_NO_PROGRESS"),
            ["loopMaxGeneratedVersions"] = RequiredInt(configuration, "LOOP_MAX_GENERATED_VERSIONS"),
            ["loopMaxOscillationCycles"] = RequiredInt(configuration, "LOOP_MAX_OSCILLATION_CYCLES"),
            ["loopMaxRepairAttemptsPerVersion"] = RequiredInt(configuration, "LOOP_MAX_REPAIR_ATTEMPTS_PER_VERSION"),
            ["loopMaxResponseBytes"] = RequiredInt(configuration, "LOOP_MAX_RESPONSE_BYTES"),
            ["loopMaxTotalCalls"] = RequiredInt(configuration, "LOOP_MAX_TOTAL_CALLS"),
            ["loopMaxTotalRepairs"] = RequiredInt(configuration, "LOOP_MAX_TOTAL_REPAIRS"),
            ["loopMaxTotalTokens"] = RequiredInt(configuration, "LOOP_MAX_TOTAL_TOKENS"),
            ["loopMaxVersions"] = RequiredInt(configuration, "LOOP_MAX_VERSIONS"),
            ["loopMaxWallTimeSeconds"] = RequiredInt(configuration, "LOOP_MAX_WALL_TIME_SECONDS"),
            ["loopOperationWallReservationSeconds"] = RequiredInt(configuration, "LOOP_OPERATION_WALL_RESERVATION_SECONDS"),
            ["repairMaxTokensPerAttempt"] = RequiredInt(configuration, "REPAIR_MAX_TOKENS_PER_ATTEMPT"),
            ["repairTimeoutSeconds"] = RequiredInt(configuration, "REPAIR_TIMEOUT_SECONDS"),
            ["repairTokenReservation"] = RequiredInt(configuration, "LOOP_REPAIR_TOKEN_RESERVATION"),
            ["standaloneRunBudgetCapCalls"] = RequiredInt(configuration, "READING_PAPER_RUN_BUDGET_MAX_CALLS"),
            ["standaloneRunBudgetCapTokens"] = RequiredInt(configuration, "READING_PAPER_RUN_BUDGET_MAX_TOKENS"),
            ["standaloneRunBudgetCapWallTimeSeconds"] = RequiredInt(configuration, "READING_PAPER_RUN_BUDGET_MAX_WALL_TIME_SECONDS")
        };

        ValidateHierarchy(caps);
        var benchmarkMode = configuration["BENCHMARK_CAPS_MODE"]?.Trim();
        if (string.IsNullOrWhiteSpace(benchmarkMode)) benchmarkMode = "LIMITED";
        var benchmarkMonetaryCapMode = configuration["BENCHMARK_MONETARY_CAP_MODE"]?.Trim();
        if (string.IsNullOrWhiteSpace(benchmarkMonetaryCapMode)) benchmarkMonetaryCapMode = "LIMITED";
        return new ReadingPaperCapsProfile(version, source, benchmarkMode, benchmarkMonetaryCapMode, caps);
    }

    public static bool IsValidSnapshot(string? snapshotJson, string? expectedSha256)
    {
        if (string.IsNullOrWhiteSpace(snapshotJson) || string.IsNullOrWhiteSpace(expectedSha256)) return false;
        var actual = Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(snapshotJson))).ToLowerInvariant();
        return string.Equals(actual, expectedSha256, StringComparison.OrdinalIgnoreCase);
    }

    public static bool MatchesRunBudget(string? snapshotJson, string? expectedSha256, bool isBenchmark, int calls, int tokens, int wallTimeSeconds)
    {
        if (!IsValidSnapshot(snapshotJson, expectedSha256)) return false;
        try
        {
            using var document = JsonDocument.Parse(snapshotJson!);
            var root = document.RootElement;
            var isUnlimitedRun = calls == -1 && tokens == -1 && wallTimeSeconds == -1;
            var snapshotIsBenchmarkUnlimited =
                root.TryGetProperty("benchmarkMode", out var bm) &&
                string.Equals(bm.GetString(), "UNLIMITED", StringComparison.OrdinalIgnoreCase) &&
                root.TryGetProperty("benchmarkMonetaryCapMode", out var mm) &&
                string.Equals(mm.GetString(), "UNLIMITED", StringComparison.OrdinalIgnoreCase);

            if (isBenchmark && isUnlimitedRun)
            {
                return snapshotIsBenchmarkUnlimited;
            }

            if (isUnlimitedRun || snapshotIsBenchmarkUnlimited)
            {
                return false;
            }

            if (calls <= 0 || tokens <= 0 || wallTimeSeconds <= 0)
            {
                return false;
            }

            if (!root.TryGetProperty("caps", out var caps)) return false;
            var callKey = isBenchmark ? "benchmarkChildRunCallCap" : "standaloneRunBudgetCapCalls";
            var tokenKey = isBenchmark ? "benchmarkChildRunTokenCap" : "standaloneRunBudgetCapTokens";
            var wallKey = isBenchmark ? "benchmarkChildRunWallTimeCapSeconds" : "standaloneRunBudgetCapWallTimeSeconds";
            return caps.TryGetProperty(callKey, out var callValue) && callValue.TryGetInt32(out var snapshotCalls) && snapshotCalls == calls &&
                   caps.TryGetProperty(tokenKey, out var tokenValue) && tokenValue.TryGetInt32(out var snapshotTokens) && snapshotTokens == tokens &&
                   caps.TryGetProperty(wallKey, out var wallValue) && wallValue.TryGetInt32(out var snapshotWall) && snapshotWall == wallTimeSeconds;
        }
        catch (JsonException)
        {
            return false;
        }
    }

    public ReadingPaperCapsProfile ToUnlimitedBenchmarkProfile(string? version = null, string? source = null)
    {
        var capsDict = new SortedDictionary<string, int>(StringComparer.Ordinal);
        foreach (var (k, v) in Caps)
        {
            capsDict[k] = v;
        }
        capsDict["evaluatorSemanticTimeoutSeconds"] = 300;
        capsDict["evaluatorStageTimeoutSeconds"] = 300;
        capsDict["repairTimeoutSeconds"] = 120;
        capsDict["loopOperationWallReservationSeconds"] = 300;
        capsDict["benchmarkArtifactSolverWallTimeCapSeconds"] = 180;
        capsDict["benchmarkArtifactReviewWallTimeCapSeconds"] = 180;
        return new ReadingPaperCapsProfile(
            version ?? Version,
            source ?? Source,
            "UNLIMITED",
            "UNLIMITED",
            capsDict);
    }

    private static void ValidateHierarchy(SortedDictionary<string, int> caps)
    {
        int Cap(string key) => caps[key];
        if (Cap("loopMaxGeneratedVersions") > Cap("loopMaxVersions") ||
            Cap("loopMaxTotalCalls") > Cap("standaloneRunBudgetCapCalls") ||
            Cap("loopMaxTotalTokens") > Cap("standaloneRunBudgetCapTokens") ||
            Cap("loopMaxWallTimeSeconds") > Cap("standaloneRunBudgetCapWallTimeSeconds") ||
            Cap("benchmarkChildRunCallCap") > Cap("loopMaxTotalCalls") ||
            Cap("benchmarkChildRunTokenCap") > Cap("loopMaxTotalTokens") ||
            Cap("benchmarkChildRunWallTimeCapSeconds") > Cap("loopMaxWallTimeSeconds") ||
            Math.Max(Cap("generateTokenReservation"), Math.Max(Cap("passageGenerateTokenReservation"), Math.Max(Cap("passageGenerateMaxTokens"), Math.Max(Cap("evaluateTokenReservation"), Cap("repairTokenReservation"))))) > Cap("loopMaxTotalTokens") ||
            Cap("loopOperationWallReservationSeconds") > Cap("loopMaxWallTimeSeconds"))
            throw new InvalidOperationException("Configured reading-paper cap hierarchy is inconsistent");

        if (3L * Cap("legacySectionTokenCap") > Cap("standaloneRunBudgetCapTokens") ||
            3L * Cap("legacySectionCallCap") > Cap("standaloneRunBudgetCapCalls") ||
            3L * Cap("legacySectionWallTimeCapSeconds") > Cap("standaloneRunBudgetCapWallTimeSeconds") ||
            3L * Cap("benchmarkSectionTokenCap") > Cap("benchmarkChildRunTokenCap") ||
            3L * Cap("benchmarkSectionCallCap") > Cap("benchmarkChildRunCallCap") ||
            3L * Cap("benchmarkSectionWallTimeCapSeconds") > Cap("benchmarkChildRunWallTimeCapSeconds"))
            throw new InvalidOperationException("Section caps exceed their parent run allocation");

        ValidateArtifacts(caps, "legacy", Cap("legacySectionTokenCap"), Cap("legacySectionCallCap"), Cap("legacySectionWallTimeCapSeconds"));
        ValidateArtifacts(caps, "benchmark", Cap("benchmarkSectionTokenCap"), Cap("benchmarkSectionCallCap"), Cap("benchmarkSectionWallTimeCapSeconds"));
    }

    private static void ValidateArtifacts(SortedDictionary<string, int> caps, string profile, int tokenCap, int callCap, int wallCap)
    {
        int ProfileCap(string artifact, string suffix) => caps[$"{profile}Artifact{artifact}{suffix}"];
        var tokenTotal = ProfileCap("Passage", "TokenCap") + ProfileCap("Questions", "TokenCap") +
                         ProfileCap("Solver", "TokenCap") + ProfileCap("Review", "TokenCap");
        var callTotal = ProfileCap("Passage", "CallCap") + ProfileCap("Questions", "CallCap") +
                        ProfileCap("Solver", "CallCap") + ProfileCap("Review", "CallCap");
        var wallTotal = ProfileCap("Passage", "WallTimeCapSeconds") + ProfileCap("Questions", "WallTimeCapSeconds");
        if (tokenTotal > tokenCap || callTotal > callCap || wallTotal > wallCap)
            throw new InvalidOperationException($"{profile} artifact allocations exceed their parent section cap");
    }

    private static string RequiredText(IConfiguration configuration, string key)
    {
        var value = configuration[key];
        if (string.IsNullOrWhiteSpace(value))
            throw new InvalidOperationException($"Required cap-profile setting {key} is missing");
        return value.Trim();
    }

    private static int RequiredInt(IConfiguration configuration, string key)
    {
        var raw = RequiredText(configuration, key);
        if (!int.TryParse(raw, NumberStyles.Integer, CultureInfo.InvariantCulture, out var value) || value <= 0)
            throw new InvalidOperationException($"Required cap-profile setting {key} must be a positive integer");
        return value;
    }
}
