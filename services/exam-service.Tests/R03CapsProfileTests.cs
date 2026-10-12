using System.Globalization;
using exam_service.Features.ReadingPaper;
using Microsoft.Extensions.Configuration;
using Xunit;

namespace exam_service.Tests;

/// <summary>
/// R03 — declared production runtime caps must reach DI and the pinned run snapshot.
/// These tests pin the config admission contract (omission / invalid / explicit override),
/// canonical profile shape + hash determinism, and snapshot rehydration on restart.
/// Canonical values mirror deploy/envs/loop-caps.env (approved: 15 calls / 60000 tokens / 300s).
/// </summary>
public class R03CapsProfileTests
{
    private const string ProfileVersion = "phase06-production-v1";
    private const string ProfileSource = "deploy/envs/loop-caps.env";

    /// <summary>Approved deploy/envs/loop-caps.env values, verbatim.</summary>
    private static Dictionary<string, string> ApprovedCaps() => new(StringComparer.Ordinal)
    {
        ["LOOP_CAPS_PROFILE_VERSION"] = ProfileVersion,
        ["LOOP_CAPS_PROFILE_SOURCE"] = ProfileSource,
        ["LOOP_MAX_VERSIONS"] = "3",
        ["LOOP_MAX_GENERATED_VERSIONS"] = "3",
        ["LOOP_MAX_REPAIR_ATTEMPTS_PER_VERSION"] = "2",
        ["LOOP_MAX_TOTAL_REPAIRS"] = "5",
        ["LOOP_MAX_CONSECUTIVE_NO_PROGRESS"] = "2",
        ["LOOP_MAX_OSCILLATION_CYCLES"] = "2",
        ["LOOP_MAX_TOTAL_CALLS"] = "15",
        ["LOOP_MAX_TOTAL_TOKENS"] = "60000",
        ["LOOP_MAX_WALL_TIME_SECONDS"] = "300",
        ["LOOP_GENERATE_TOKEN_RESERVATION"] = "15000",
        ["LOOP_EVALUATE_TOKEN_RESERVATION"] = "10000",
        ["LOOP_REPAIR_TOKEN_RESERVATION"] = "15000",
        ["LOOP_OPERATION_WALL_RESERVATION_SECONDS"] = "60",
        ["LOOP_MAX_RESPONSE_BYTES"] = "500000",
        ["PASSAGE_GENERATE_TOKEN_RESERVATION"] = "9000",
        ["PASSAGE_GENERATE_MAX_TOKENS"] = "2500",
        ["READING_PAPER_RUN_BUDGET_MAX_CALLS"] = "25",
        ["READING_PAPER_RUN_BUDGET_MAX_TOKENS"] = "150000",
        ["READING_PAPER_RUN_BUDGET_MAX_WALL_TIME_SECONDS"] = "900",
        ["BENCHMARK_CHILD_RUN_MAX_CALLS"] = "15",
        ["BENCHMARK_CHILD_RUN_MAX_TOKENS"] = "60000",
        ["BENCHMARK_CHILD_RUN_MAX_WALL_TIME_SECONDS"] = "300",
        ["READING_PAPER_LEGACY_SECTION_TOKEN_CAP"] = "45000",
        ["READING_PAPER_LEGACY_SECTION_CALL_CAP"] = "8",
        ["READING_PAPER_LEGACY_SECTION_WALL_TIME_CAP_SECONDS"] = "280",
        ["READING_PAPER_LEGACY_PASSAGE_TOKEN_CAP"] = "15000",
        ["READING_PAPER_LEGACY_PASSAGE_CALL_CAP"] = "2",
        ["READING_PAPER_LEGACY_PASSAGE_WALL_TIME_CAP_SECONDS"] = "90",
        ["READING_PAPER_LEGACY_QUESTIONS_TOKEN_CAP"] = "18000",
        ["READING_PAPER_LEGACY_QUESTIONS_CALL_CAP"] = "3",
        ["READING_PAPER_LEGACY_QUESTIONS_WALL_TIME_CAP_SECONDS"] = "100",
        ["READING_PAPER_LEGACY_SOLVER_TOKEN_CAP"] = "6000",
        ["READING_PAPER_LEGACY_SOLVER_CALL_CAP"] = "2",
        ["READING_PAPER_LEGACY_SOLVER_WALL_TIME_CAP_SECONDS"] = "50",
        ["READING_PAPER_LEGACY_REVIEW_TOKEN_CAP"] = "6000",
        ["READING_PAPER_LEGACY_REVIEW_CALL_CAP"] = "1",
        ["READING_PAPER_LEGACY_REVIEW_WALL_TIME_CAP_SECONDS"] = "40",
        ["READING_PAPER_BENCHMARK_SECTION_TOKEN_CAP"] = "20000",
        ["READING_PAPER_BENCHMARK_SECTION_CALL_CAP"] = "5",
        ["READING_PAPER_BENCHMARK_SECTION_WALL_TIME_CAP_SECONDS"] = "100",
        ["READING_PAPER_BENCHMARK_PASSAGE_TOKEN_CAP"] = "8000",
        ["READING_PAPER_BENCHMARK_PASSAGE_CALL_CAP"] = "1",
        ["READING_PAPER_BENCHMARK_PASSAGE_WALL_TIME_CAP_SECONDS"] = "35",
        ["READING_PAPER_BENCHMARK_QUESTIONS_TOKEN_CAP"] = "7000",
        ["READING_PAPER_BENCHMARK_QUESTIONS_CALL_CAP"] = "2",
        ["READING_PAPER_BENCHMARK_QUESTIONS_WALL_TIME_CAP_SECONDS"] = "35",
        ["READING_PAPER_BENCHMARK_SOLVER_TOKEN_CAP"] = "3000",
        ["READING_PAPER_BENCHMARK_SOLVER_CALL_CAP"] = "1",
        ["READING_PAPER_BENCHMARK_SOLVER_WALL_TIME_CAP_SECONDS"] = "15",
        ["READING_PAPER_BENCHMARK_REVIEW_TOKEN_CAP"] = "2000",
        ["READING_PAPER_BENCHMARK_REVIEW_CALL_CAP"] = "1",
        ["READING_PAPER_BENCHMARK_REVIEW_WALL_TIME_CAP_SECONDS"] = "15",
        ["EVALUATOR_DETERMINISTIC_TIMEOUT_SECONDS"] = "5",
        ["EVALUATOR_SEMANTIC_TIMEOUT_SECONDS"] = "30",
        ["EVALUATOR_STAGE_TIMEOUT_SECONDS"] = "60",
        ["EVALUATOR_MAX_TOKENS_PER_EVALUATION"] = "4000",
        ["REPAIR_TIMEOUT_SECONDS"] = "30",
        ["REPAIR_MAX_TOKENS_PER_ATTEMPT"] = "3000",
        ["EVALUATION_CACHE_MAX_ENTRIES"] = "1000",
        ["CANDIDATE_POOL_LIMIT_COMPLETION"] = "2",
        ["CANDIDATE_POOL_LIMIT_TFNG"] = "3",
        ["CANDIDATE_POOL_LIMIT_MCQ"] = "3",
        ["CANDIDATE_POOL_LIMIT_SUMMARY"] = "2",
        ["CANDIDATE_POOL_LIMIT_SHORT_ANSWER"] = "2",
        ["CANDIDATE_MAX_SEARCH_DEPTH"] = "50",
        ["CANDIDATE_MAX_BACKTRACKING_STEPS"] = "100"
    };

    private static List<KeyValuePair<string, string?>> ToEntries(Dictionary<string, string> values) =>
        values.Select(pair => new KeyValuePair<string, string?>(pair.Key, pair.Value)).ToList();

    private static IConfiguration BuildConfiguration(
        IDictionary<string, string?>? overrides = null)
    {
        var values = ApprovedCaps();
        if (overrides is not null)
            foreach (var (key, value) in overrides)
            {
                if (value is null) values.Remove(key);
                else values[key] = value;
            }
        return new ConfigurationBuilder()
            .AddInMemoryCollection(ToEntries(values))
            .Build();
    }

    private static ReadingPaperCapsProfile Approved() => ReadingPaperCapsProfile.FromConfiguration(BuildConfiguration());

    /// <summary>
    /// Builds a real <see cref="ReadingPaperCapsProfile"/> from the approved, non-secret
    /// deploy/envs/loop-caps.env file, exactly as production DI does. Shared by the
    /// ReadingPaperWorker tests, which must stamp real run-budget caps onto new runs.
    /// </summary>
    public static ReadingPaperCapsProfile ApprovedFromDeployEnvFile()
    {
        var envPath = LocateDeployEnvFile();
        var values = new Dictionary<string, string?>(StringComparer.Ordinal);
        foreach (var rawLine in File.ReadAllLines(envPath))
        {
            var line = rawLine.Trim();
            if (line.Length == 0 || line.StartsWith('#')) continue;
            var separator = line.IndexOf('=');
            if (separator <= 0) continue;
            values[line[..separator].Trim()] = line[(separator + 1)..].Trim();
        }

        return ReadingPaperCapsProfile.FromConfiguration(
            new ConfigurationBuilder().AddInMemoryCollection(values).Build());
    }

    private static string LocateDeployEnvFile()
    {
        for (var dir = new DirectoryInfo(AppContext.BaseDirectory); dir is not null; dir = dir.Parent)
        {
            var candidate = Path.Combine(dir.FullName, "deploy", "envs", "loop-caps.env");
            if (File.Exists(candidate)) return candidate;
        }
        throw new FileNotFoundException(
            "Approved cap-profile env file 'deploy/envs/loop-caps.env' was not found above " + AppContext.BaseDirectory);
    }

    // ── T1: config omission is rejected, not silently defaulted ──────────────

    [Theory]
    [InlineData("LOOP_CAPS_PROFILE_VERSION")]
    [InlineData("LOOP_CAPS_PROFILE_SOURCE")]
    [InlineData("READING_PAPER_RUN_BUDGET_MAX_CALLS")]
    [InlineData("READING_PAPER_RUN_BUDGET_MAX_TOKENS")]
    [InlineData("READING_PAPER_RUN_BUDGET_MAX_WALL_TIME_SECONDS")]
    [InlineData("BENCHMARK_CHILD_RUN_MAX_CALLS")]
    [InlineData("BENCHMARK_CHILD_RUN_MAX_TOKENS")]
    [InlineData("BENCHMARK_CHILD_RUN_MAX_WALL_TIME_SECONDS")]
    [InlineData("LOOP_MAX_TOTAL_CALLS")]
    [InlineData("READING_PAPER_BENCHMARK_SECTION_CALL_CAP")]
    [InlineData("READING_PAPER_LEGACY_REVIEW_WALL_TIME_CAP_SECONDS")]
    [InlineData("CANDIDATE_MAX_SEARCH_DEPTH")]
    public void OmittedCapSettingIsRejectedAtStartup(string missingKey)
    {
        var configuration = BuildConfiguration(new Dictionary<string, string?> { [missingKey] = null });

        var exception = Assert.Throws<InvalidOperationException>(
            () => ReadingPaperCapsProfile.FromConfiguration(configuration));

        Assert.Contains(missingKey, exception.Message, StringComparison.Ordinal);
    }

    [Fact]
    public void WhitespaceOnlyCapSettingIsRejectedAtStartup()
    {
        var configuration = BuildConfiguration(new Dictionary<string, string?>
        {
            ["LOOP_CAPS_PROFILE_VERSION"] = "   "
        });

        var exception = Assert.Throws<InvalidOperationException>(
            () => ReadingPaperCapsProfile.FromConfiguration(configuration));

        Assert.Contains("LOOP_CAPS_PROFILE_VERSION", exception.Message, StringComparison.Ordinal);
    }

    // ── T2: invalid values are rejected, never clamped or defaulted ───────────

    [Theory]
    [InlineData("0")]
    [InlineData("-1")]
    [InlineData("1.5")]
    [InlineData("not-a-number")]
    [InlineData("")]
    [InlineData("1,000")]
    public void InvalidCapValueIsRejectedAtStartup(string invalidValue)
    {
        var configuration = BuildConfiguration(new Dictionary<string, string?>
        {
            ["READING_PAPER_RUN_BUDGET_MAX_CALLS"] = invalidValue
        });

        var exception = Assert.Throws<InvalidOperationException>(
            () => ReadingPaperCapsProfile.FromConfiguration(configuration));

        Assert.Contains("READING_PAPER_RUN_BUDGET_MAX_CALLS", exception.Message, StringComparison.Ordinal);
    }

    [Fact]
    public void NonPositiveBenchmarkChildCallCapIsRejectedAtStartup()
    {
        var configuration = BuildConfiguration(new Dictionary<string, string?>
        {
            ["BENCHMARK_CHILD_RUN_MAX_CALLS"] = "0"
        });

        var exception = Assert.Throws<InvalidOperationException>(
            () => ReadingPaperCapsProfile.FromConfiguration(configuration));

        Assert.Contains("must be a positive integer", exception.Message, StringComparison.Ordinal);
    }

    // ── T3: explicit override is admitted and changes the pinned profile ─────

    [Fact]
    public void ExplicitOverrideIsAdmittedAndRePinsTheProfile()
    {
        // A valid but stricter parent allocation than the approved 25/150000/900.
        // Still above the legacy section sums (24 calls / 135000 tokens / 840s), so the
        // override lowers the ceiling without invalidating the cap hierarchy.
        var baseline = Approved();
        var overridden = ReadingPaperCapsProfile.FromConfiguration(
            BuildConfiguration(new Dictionary<string, string?>
            {
                ["READING_PAPER_RUN_BUDGET_MAX_CALLS"] = "24",
                ["READING_PAPER_RUN_BUDGET_MAX_TOKENS"] = "140000",
                ["READING_PAPER_RUN_BUDGET_MAX_WALL_TIME_SECONDS"] = "850"
            }));

        Assert.Equal(24, overridden.RunBudgetCapCalls);
        Assert.Equal(140000, overridden.RunBudgetCapTokens);
        Assert.Equal(850, overridden.RunBudgetCapWallTimeSeconds);
        Assert.Equal(baseline.Version, overridden.Version);
        Assert.Equal(baseline.Source, overridden.Source);
        Assert.NotEqual(baseline.Sha256, overridden.Sha256);

        // The re-pinned snapshot must still be self-consistent and rehydratable.
        Assert.True(ReadingPaperCapsProfile.MatchesRunBudget(
            overridden.SnapshotJson, overridden.Sha256, isBenchmark: false,
            overridden.RunBudgetCapCalls, overridden.RunBudgetCapTokens, overridden.RunBudgetCapWallTimeSeconds));

        // The prior profile's caps must no longer be admitted against the re-pinned snapshot.
        Assert.False(ReadingPaperCapsProfile.MatchesRunBudget(
            overridden.SnapshotJson, overridden.Sha256, isBenchmark: false,
            baseline.RunBudgetCapCalls, baseline.RunBudgetCapTokens, baseline.RunBudgetCapWallTimeSeconds));
    }

    // ── T4: cap hierarchy and artifact allocation validation ─────────────────

    [Fact]
    public void LoopTotalExceedingRunBudgetCapIsRejected()
    {
        var configuration = BuildConfiguration(new Dictionary<string, string?>
        {
            ["READING_PAPER_RUN_BUDGET_MAX_CALLS"] = "10"
        });

        var exception = Assert.Throws<InvalidOperationException>(
            () => ReadingPaperCapsProfile.FromConfiguration(configuration));

        Assert.Contains("cap hierarchy is inconsistent", exception.Message, StringComparison.Ordinal);
    }

    [Fact]
    public void BenchmarkChildRunExceedingLoopTotalIsRejected()
    {
        var configuration = BuildConfiguration(new Dictionary<string, string?>
        {
            ["BENCHMARK_CHILD_RUN_MAX_CALLS"] = "16"
        });

        Assert.Throws<InvalidOperationException>(
            () => ReadingPaperCapsProfile.FromConfiguration(configuration));
    }

    [Fact]
    public void SectionCapExceedingTripleOfParentRunAllocationIsRejected()
    {
        // benchmarkSectionCallCap * 3 must stay within benchmarkChildRunCallCap (15).
        var configuration = BuildConfiguration(new Dictionary<string, string?>
        {
            ["READING_PAPER_BENCHMARK_SECTION_CALL_CAP"] = "6"
        });

        var exception = Assert.Throws<InvalidOperationException>(
            () => ReadingPaperCapsProfile.FromConfiguration(configuration));

        Assert.Contains("exceed their parent run allocation", exception.Message, StringComparison.Ordinal);
    }

    [Fact]
    public void ArtifactAllocationExceedingParentSectionCapIsRejected()
    {
        // Keep the 3x section rule satisfied (4*3=12 <= 15) but push artifact
        // token allocations above the benchmark section token cap of 20000.
        var configuration = BuildConfiguration(new Dictionary<string, string?>
        {
            ["READING_PAPER_BENCHMARK_PASSAGE_TOKEN_CAP"] = "8000",
            ["READING_PAPER_BENCHMARK_QUESTIONS_TOKEN_CAP"] = "8000",
            ["READING_PAPER_BENCHMARK_SOLVER_TOKEN_CAP"] = "3000",
            ["READING_PAPER_BENCHMARK_REVIEW_TOKEN_CAP"] = "2000"
        });

        var exception = Assert.Throws<InvalidOperationException>(
            () => ReadingPaperCapsProfile.FromConfiguration(configuration));

        Assert.Contains("benchmark artifact allocations exceed their parent section cap", exception.Message, StringComparison.Ordinal);
    }

    // ── T6: snapshot validation and restart rehydration ─────────────────────

    [Fact]
    public void IsValidSnapshotAcceptsSealedSnapshotAndRejectsTampering()
    {
        var profile = Approved();

        Assert.True(ReadingPaperCapsProfile.IsValidSnapshot(profile.SnapshotJson, profile.Sha256));
        Assert.True(ReadingPaperCapsProfile.IsValidSnapshot(profile.SnapshotJson, profile.Sha256.ToUpperInvariant()));

        Assert.False(ReadingPaperCapsProfile.IsValidSnapshot(
            profile.SnapshotJson.Replace("\"standaloneRunBudgetCapCalls\":25", "\"standaloneRunBudgetCapCalls\":26", StringComparison.Ordinal),
            profile.Sha256));
        Assert.False(ReadingPaperCapsProfile.IsValidSnapshot(null, profile.Sha256));
        Assert.False(ReadingPaperCapsProfile.IsValidSnapshot(profile.SnapshotJson, null));
        Assert.False(ReadingPaperCapsProfile.IsValidSnapshot("   ", profile.Sha256));
    }

    [Fact]
    public void PersistedStandaloneRunSnapshotRehydratesAfterRestart()
    {
        var profile = Approved();

        // What BenchmarkCampaignService / run creation persists for a standalone run.
        Assert.True(ReadingPaperCapsProfile.MatchesRunBudget(
            profile.SnapshotJson, profile.Sha256, isBenchmark: false,
            profile.RunBudgetCapCalls, profile.RunBudgetCapTokens, profile.RunBudgetCapWallTimeSeconds));
    }

    [Fact]
    public void PersistedBenchmarkChildRunSnapshotRehydratesAfterRestart()
    {
        var profile = Approved();

        // What BenchmarkCampaignService.ProvisionCaseAsync persists for a child run.
        Assert.True(ReadingPaperCapsProfile.MatchesRunBudget(
            profile.SnapshotJson, profile.Sha256, isBenchmark: true,
            profile.BenchmarkChildRunCallCap, profile.BenchmarkChildRunTokenCap,
            profile.BenchmarkChildRunWallTimeCapSeconds));
    }

    [Fact]
    public void SnapshotWithMismatchedCapsIsNotAdmittedAfterRestart()
    {
        var profile = Approved();

        // Run row drifted from its pinned snapshot (e.g. caps edited out of band).
        Assert.False(ReadingPaperCapsProfile.MatchesRunBudget(
            profile.SnapshotJson, profile.Sha256, isBenchmark: false,
            24, profile.RunBudgetCapTokens, profile.RunBudgetCapWallTimeSeconds));
        Assert.False(ReadingPaperCapsProfile.MatchesRunBudget(
            profile.SnapshotJson, profile.Sha256, isBenchmark: true,
            profile.BenchmarkChildRunCallCap, 59999, profile.BenchmarkChildRunWallTimeCapSeconds));
    }

    [Fact]
    public void SnapshotForOtherRunKindIsNotAdmittedAsBenchmark()
    {
        var profile = Approved();

        // A standalone run's persisted caps must not satisfy benchmark admission.
        Assert.False(ReadingPaperCapsProfile.MatchesRunBudget(
            profile.SnapshotJson, profile.Sha256, isBenchmark: true,
            profile.RunBudgetCapCalls, profile.RunBudgetCapTokens, profile.RunBudgetCapWallTimeSeconds));
    }

    [Fact]
    public void MalformedSnapshotJsonFailsClosed()
    {
        const string malformed = "{\"caps\":{";
        var sha = System.Security.Cryptography.SHA256.HashData(
            System.Text.Encoding.UTF8.GetBytes(malformed));
        var shaHex = Convert.ToHexString(sha).ToLowerInvariant();

        Assert.False(ReadingPaperCapsProfile.MatchesRunBudget(
            malformed, shaHex, isBenchmark: false, 25, 150000, 900));
    }

    [Fact]
    public void LegacyUnpinnedProfileShaIsNotAdmitted()
    {
        var profile = Approved();

        Assert.False(ReadingPaperCapsProfile.IsValidSnapshot(profile.SnapshotJson, "legacy-unpinned"));
    }

    // ── T7: config precedence — last provider wins ──────────────────────────

    [Fact]
    public void LaterConfigurationSourceOverridesEarlierOne()
    {
        // Mirrors production layering: appsettings-derived base then environment
        // overrides. Environment variables are appended last by
        // WebApplication.CreateBuilder, so the override must win.
        var configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(ToEntries(ApprovedCaps()))
            .AddInMemoryCollection(new Dictionary<string, string?>
            {
                ["READING_PAPER_RUN_BUDGET_MAX_CALLS"] = "24"
            })
            .Build();

        var profile = ReadingPaperCapsProfile.FromConfiguration(configuration);

        Assert.Equal(24, profile.RunBudgetCapCalls);
        Assert.Contains("\"standaloneRunBudgetCapCalls\":24", profile.SnapshotJson, StringComparison.Ordinal);
    }

    [Fact]
    public void InjectedEnvironmentOverrideIsAdmittedForRealEnvironmentKeys()
    {
        // The production wiring relies on WebApplication.CreateBuilder appending an
        // environment-variable provider after appsettings. This pins that a genuine
        // process environment override of a cap key is admitted and re-pins the hash.
        const string capKey = "READING_PAPER_RUN_BUDGET_MAX_WALL_TIME_SECONDS";
        var previous = Environment.GetEnvironmentVariable(capKey);
        var baseline = Approved();

        try
        {
            Environment.SetEnvironmentVariable(capKey, "850");

            var configuration = new ConfigurationBuilder()
                .AddInMemoryCollection(ToEntries(ApprovedCaps()))
                .AddEnvironmentVariables()
                .Build();

            var profile = ReadingPaperCapsProfile.FromConfiguration(configuration);

            Assert.Equal(850, profile.RunBudgetCapWallTimeSeconds);
            Assert.NotEqual(baseline.Sha256, profile.Sha256);
            Assert.True(ReadingPaperCapsProfile.MatchesRunBudget(
                profile.SnapshotJson, profile.Sha256, isBenchmark: false,
                profile.RunBudgetCapCalls, profile.RunBudgetCapTokens, profile.RunBudgetCapWallTimeSeconds));
        }
        finally
        {
            Environment.SetEnvironmentVariable(capKey, previous);
        }
    }

    [Fact]
    public void NonInvariantCultureDoesNotChangeCapParsing()
    {
        var original = System.Globalization.CultureInfo.CurrentCulture;
        try
        {
            // de-DE uses ',' as the group separator; a naive parse would accept "1,000".
            System.Globalization.CultureInfo.CurrentCulture = new System.Globalization.CultureInfo("de-DE");
            var configuration = BuildConfiguration(new Dictionary<string, string?>
            {
                ["LOOP_MAX_TOTAL_CALLS"] = "15"
            });

            var profile = ReadingPaperCapsProfile.FromConfiguration(configuration);

            Assert.Equal(15, profile.Caps["loopMaxTotalCalls"]);
        }
        finally
        {
            System.Globalization.CultureInfo.CurrentCulture = original;
        }
    }

    [Fact]
    public void WriteAttemptThroughCapsThrowsAndCannotDriftSnapshotOrScalars()
    {
        var profile = Approved();
        var snapshotJson = profile.SnapshotJson;
        var sha = profile.Sha256;
        var runBudgetCalls = profile.RunBudgetCapCalls;

        // The published Caps view is a read-only wrapper, so any write attempt must fail
        // loudly rather than silently desync the profile from its sealed sha256 snapshot.
        var published = (IDictionary<string, int>)profile.Caps;

        Assert.Throws<NotSupportedException>(() => published["standaloneRunBudgetCapCalls"] = 999999);
        Assert.Throws<NotSupportedException>(() => published["loopMaxTotalCalls"] = 1);
        Assert.Throws<NotSupportedException>(() => published.Remove("benchmarkChildRunCallCap"));
        Assert.Throws<NotSupportedException>(published.Clear);

        // Snapshot, hash, and scalar caps must all remain pinned to the approved profile.
        Assert.Equal(snapshotJson, profile.SnapshotJson);
        Assert.Equal(sha, profile.Sha256);
        Assert.Equal(runBudgetCalls, profile.RunBudgetCapCalls);
        Assert.Equal(25, profile.Caps["standaloneRunBudgetCapCalls"]);
        Assert.Equal(15, profile.Caps["benchmarkChildRunCallCap"]);
        Assert.True(ReadingPaperCapsProfile.IsValidSnapshot(profile.SnapshotJson, profile.Sha256));
        Assert.True(ReadingPaperCapsProfile.MatchesRunBudget(
            profile.SnapshotJson, profile.Sha256, isBenchmark: false,
            profile.RunBudgetCapCalls, profile.RunBudgetCapTokens, profile.RunBudgetCapWallTimeSeconds));
    }

    [Fact]
    public void CapParsingUsesInvariantIntegerFormat()
    {
        // A large but hierarchy-valid cap must round-trip exactly regardless of culture,
        // proving RequiredInt parses with InvariantCulture rather than the ambient culture.
        var original = System.Globalization.CultureInfo.CurrentCulture;
        try
        {
            System.Globalization.CultureInfo.CurrentCulture = new System.Globalization.CultureInfo("de-DE");
            var configuration = BuildConfiguration(new Dictionary<string, string?>
            {
                ["READING_PAPER_RUN_BUDGET_MAX_TOKENS"] = "150000",
                ["READING_PAPER_LEGACY_SECTION_TOKEN_CAP"] = "45000"
            });

            var profile = ReadingPaperCapsProfile.FromConfiguration(configuration);

            Assert.Equal(150000, profile.RunBudgetCapTokens);
            Assert.Equal(45000, profile.Caps["legacySectionTokenCap"]);
        }
        finally
        {
            System.Globalization.CultureInfo.CurrentCulture = original;
        }
    }

    [Fact]
    public void BoundedProfileCannotEnterUnlimitedBenchmarkMode()
    {
        var profile = Approved();
        Assert.False(profile.IsBenchmarkUnlimited);
        Assert.Equal("LIMITED", profile.BenchmarkMode);
        Assert.Equal("LIMITED", profile.BenchmarkMonetaryCapMode);

        // Bounded profile must fail closed against unlimited requests (-1)
        Assert.False(ReadingPaperCapsProfile.MatchesRunBudget(
            profile.SnapshotJson, profile.Sha256, isBenchmark: true,
            calls: -1, tokens: -1, wallTimeSeconds: -1));

        // Bounded profile must fail closed against standalone unlimited requests
        Assert.False(ReadingPaperCapsProfile.MatchesRunBudget(
            profile.SnapshotJson, profile.Sha256, isBenchmark: false,
            calls: -1, tokens: -1, wallTimeSeconds: -1));
    }

    [Fact]
    public void PartialOrSingleFieldHighCapsCannotPromoteOrBypassLimits()
    {
        var profile = Approved();

        // Single high or -1 cap cannot promote other bounded caps
        Assert.False(ReadingPaperCapsProfile.MatchesRunBudget(
            profile.SnapshotJson, profile.Sha256, isBenchmark: true,
            calls: -1, tokens: profile.BenchmarkChildRunTokenCap, wallTimeSeconds: profile.BenchmarkChildRunWallTimeCapSeconds));
        Assert.False(ReadingPaperCapsProfile.MatchesRunBudget(
            profile.SnapshotJson, profile.Sha256, isBenchmark: true,
            calls: profile.BenchmarkChildRunCallCap, tokens: -1, wallTimeSeconds: profile.BenchmarkChildRunWallTimeCapSeconds));
        Assert.False(ReadingPaperCapsProfile.MatchesRunBudget(
            profile.SnapshotJson, profile.Sha256, isBenchmark: true,
            calls: profile.BenchmarkChildRunCallCap, tokens: profile.BenchmarkChildRunTokenCap, wallTimeSeconds: -1));
        Assert.False(ReadingPaperCapsProfile.MatchesRunBudget(
            profile.SnapshotJson, profile.Sha256, isBenchmark: true,
            calls: 2_000_000_000, tokens: profile.BenchmarkChildRunTokenCap, wallTimeSeconds: profile.BenchmarkChildRunWallTimeCapSeconds));
    }

    [Fact]
    public void UnlimitedBenchmarkProfileMatchesOnlyUnlimitedBenchmarkRuns()
    {
        var config = BuildConfiguration(new Dictionary<string, string?>
        {
            ["BENCHMARK_CAPS_MODE"] = "UNLIMITED",
            ["BENCHMARK_MONETARY_CAP_MODE"] = "UNLIMITED",
            ["LOOP_CAPS_PROFILE_VERSION"] = "minimax-benchmark-unlimited-v1",
            ["LOOP_CAPS_PROFILE_SOURCE"] = "automated-minimax-benchmark"
        });
        var unlimitedProfile = ReadingPaperCapsProfile.FromConfiguration(config);
        Assert.True(unlimitedProfile.IsBenchmarkUnlimited);
        Assert.Equal("UNLIMITED", unlimitedProfile.BenchmarkMode);
        Assert.Equal("UNLIMITED", unlimitedProfile.BenchmarkMonetaryCapMode);

        // Matches when isBenchmark=true and all three caps are explicit unlimited (-1)
        Assert.True(ReadingPaperCapsProfile.MatchesRunBudget(
            unlimitedProfile.SnapshotJson, unlimitedProfile.Sha256, isBenchmark: true,
            calls: -1, tokens: -1, wallTimeSeconds: -1));

        // Standalone runs CANNOT enter unlimited benchmark mode
        Assert.False(ReadingPaperCapsProfile.MatchesRunBudget(
            unlimitedProfile.SnapshotJson, unlimitedProfile.Sha256, isBenchmark: false,
            calls: -1, tokens: -1, wallTimeSeconds: -1));

        // Bounded caps cannot enter unlimited benchmark mode
        Assert.False(ReadingPaperCapsProfile.MatchesRunBudget(
            unlimitedProfile.SnapshotJson, unlimitedProfile.Sha256, isBenchmark: true,
            calls: 15, tokens: 60000, wallTimeSeconds: 300));
    }

    [Fact]
    public void MonetaryCapStateMismatchFailsClosed()
    {
        // Profile with UNLIMITED benchmark mode but LIMITED monetary cap
        var config = BuildConfiguration(new Dictionary<string, string?>
        {
            ["BENCHMARK_CAPS_MODE"] = "UNLIMITED",
            ["BENCHMARK_MONETARY_CAP_MODE"] = "LIMITED",
            ["LOOP_CAPS_PROFILE_VERSION"] = "minimax-partial-unlimited",
            ["LOOP_CAPS_PROFILE_SOURCE"] = "partial-unlimited-test"
        });
        var partialProfile = ReadingPaperCapsProfile.FromConfiguration(config);
        Assert.False(partialProfile.IsBenchmarkUnlimited);

        // Cannot enter unlimited benchmark mode because monetary cap is not unlimited
        Assert.False(ReadingPaperCapsProfile.MatchesRunBudget(
            partialProfile.SnapshotJson, partialProfile.Sha256, isBenchmark: true,
            calls: -1, tokens: -1, wallTimeSeconds: -1));
    }

    [Fact]
    public void ToUnlimitedBenchmarkProfileIsolatesExtendedBenchmarkTimeouts()
    {
        var prodProfile = Approved();
        Assert.False(prodProfile.IsBenchmarkUnlimited);
        Assert.Equal(30, prodProfile.Caps["evaluatorSemanticTimeoutSeconds"]);
        Assert.Equal(60, prodProfile.Caps["evaluatorStageTimeoutSeconds"]);
        Assert.Equal(30, prodProfile.Caps["repairTimeoutSeconds"]);
        Assert.Equal(60, prodProfile.Caps["loopOperationWallReservationSeconds"]);
        Assert.Equal(15, prodProfile.Caps["benchmarkArtifactSolverWallTimeCapSeconds"]);
        Assert.Equal(15, prodProfile.Caps["benchmarkArtifactReviewWallTimeCapSeconds"]);

        var benchProfile = prodProfile.ToUnlimitedBenchmarkProfile(
            "minimax-benchmark-unlimited-v1",
            "automated-minimax-benchmark");

        Assert.True(benchProfile.IsBenchmarkUnlimited);
        Assert.Equal("UNLIMITED", benchProfile.BenchmarkMode);
        Assert.Equal("UNLIMITED", benchProfile.BenchmarkMonetaryCapMode);
        Assert.Equal(300, benchProfile.Caps["evaluatorSemanticTimeoutSeconds"]);
        Assert.Equal(300, benchProfile.Caps["evaluatorStageTimeoutSeconds"]);
        Assert.Equal(120, benchProfile.Caps["repairTimeoutSeconds"]);
        Assert.Equal(300, benchProfile.Caps["loopOperationWallReservationSeconds"]);
        Assert.Equal(180, benchProfile.Caps["benchmarkArtifactSolverWallTimeCapSeconds"]);
        Assert.Equal(180, benchProfile.Caps["benchmarkArtifactReviewWallTimeCapSeconds"]);

        // Production profile remains pinned and unmodified
        Assert.Equal(30, prodProfile.Caps["evaluatorSemanticTimeoutSeconds"]);
        Assert.Equal(60, prodProfile.Caps["evaluatorStageTimeoutSeconds"]);
        Assert.Equal(30, prodProfile.Caps["repairTimeoutSeconds"]);
    }
}
