using System.Collections.Concurrent;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using exam_service.Domains.Entities;

namespace exam_service.Features.ReadingPaper;

public enum CanaryAbortReason
{
    StaleCommit,
    DuplicateExam,
    GroundingBlocker,
    UnauthorizedWrite,
    ContractBreak,
    ExcessiveErrors,
    AdminRequested,
    ManualAbort
}

public sealed record CanaryAbortRecord(
    string RunId,
    CanaryAbortReason Reason,
    string Details,
    DateTime AbortedAt,
    string EngineVersion
);

public sealed record CanaryStatusDto(
    int CanaryPercentage,
    bool IsPaused,
    string? PausedReason,
    DateTime? PausedAt,
    int TotalRoutedRuns,
    int V1RoutedRuns,
    int V2RoutedRuns,
    int AbortCount,
    IReadOnlyList<CanaryAbortRecord> RecentAborts
);

public sealed record CanaryRoutingDecision(
    string RunId,
    string EngineVersion,
    bool IsPinned,
    int RolloutPercentage,
    int HashBucket,
    string DecisionReason
);

public class CanaryRoutingService
{
    private readonly object _lock = new();
    private int _canaryPercentage = 10; // Default fail-safe initial stage (10% -> 50% -> 100%)
    private bool _isPaused;
    private string? _pausedReason;
    private DateTime? _pausedAt;

    private int _v1Count;
    private int _v2Count;
    private readonly ConcurrentQueue<CanaryAbortRecord> _recentAborts = new();
    private const int MaxRecentAborts = 50;

    public const string V1Engine = "1.0.0";
    public const string V2Engine = "2.0.0";

    public CanaryRoutingService(IConfiguration? configuration = null)
    {
        var envCanary = Environment.GetEnvironmentVariable("CANARY_PERCENTAGE");
        if (!string.IsNullOrWhiteSpace(envCanary) && int.TryParse(envCanary, out var cp))
        {
            _canaryPercentage = Math.Clamp(cp, 0, 100);
        }
        else if (configuration != null)
        {
            var confVal = configuration.GetValue<int?>("Canary:Percentage");
            if (confVal.HasValue)
            {
                _canaryPercentage = Math.Clamp(confVal.Value, 0, 100);
            }
        }
    }

    public int CanaryPercentage
    {
        get { lock (_lock) return _canaryPercentage; }
    }

    public bool IsPaused
    {
        get { lock (_lock) return _isPaused; }
    }

    public string? PausedReason
    {
        get { lock (_lock) return _pausedReason; }
    }

    public DateTime? PausedAt
    {
        get { lock (_lock) return _pausedAt; }
    }

    /// <summary>
    /// Updates the canary percentage weight (e.g. 0, 10, 50, 100).
    /// </summary>
    public void SetCanaryPercentage(int percentage)
    {
        lock (_lock)
        {
            _canaryPercentage = Math.Clamp(percentage, 0, 100);
        }
    }

    /// <summary>
    /// Pauses all new V2 generation runs, routing traffic to fallback V1.
    /// </summary>
    public void Pause(string reason)
    {
        lock (_lock)
        {
            _isPaused = true;
            _pausedReason = string.IsNullOrWhiteSpace(reason) ? "Admin paused" : reason;
            _pausedAt = DateTime.UtcNow;
        }
    }

    /// <summary>
    /// Resumes normal canary routing.
    /// </summary>
    public void Resume()
    {
        lock (_lock)
        {
            _isPaused = false;
            _pausedReason = null;
            _pausedAt = null;
        }
    }

    /// <summary>
    /// Computes a deterministic integer bucket (0..99) from the run ID.
    /// </summary>
    public static int ComputeHashBucket(string runId)
    {
        if (string.IsNullOrWhiteSpace(runId)) return 0;
        var bytes = Encoding.UTF8.GetBytes(runId);
        var hash = SHA256.HashData(bytes);
        var value = BitConverter.ToUInt32(hash, 0);
        return (int)(value % 100);
    }

    /// <summary>
    /// Evaluates engine version routing for a run.
    /// In-flight runs stay strictly pinned to their original engine version.
    /// </summary>
    public CanaryRoutingDecision RouteRun(string runId, string? requestedEngine = null, ReadingPaperRun? existingRun = null)
    {
        // 1. In-flight runs stay pinned to their initial engine version
        if (existingRun != null && !string.IsNullOrWhiteSpace(existingRun.EngineVersion))
        {
            var pinnedEngine = existingRun.EngineVersion;
            return new CanaryRoutingDecision(
                runId,
                pinnedEngine,
                IsPinned: true,
                RolloutPercentage: CanaryPercentage,
                HashBucket: ComputeHashBucket(runId),
                DecisionReason: $"Pinned to existing run engine version: {pinnedEngine}"
            );
        }

        int currentPercentage;
        bool paused;
        string? pauseReason;
        lock (_lock)
        {
            currentPercentage = _canaryPercentage;
            paused = _isPaused;
            pauseReason = _pausedReason;
        }

        // 2. System paused -> fallback to V1
        if (paused)
        {
            Interlocked.Increment(ref _v1Count);
            return new CanaryRoutingDecision(
                runId,
                V1Engine,
                IsPinned: false,
                RolloutPercentage: 0,
                HashBucket: ComputeHashBucket(runId),
                DecisionReason: $"System paused: {pauseReason}"
            );
        }

        // 3. Explicit requested engine version override
        if (!string.IsNullOrWhiteSpace(requestedEngine))
        {
            var normalized = requestedEngine.Trim().ToLowerInvariant() switch
            {
                "v2" or "2" or "2.0.0" => V2Engine,
                "v1" or "1" or "1.0.0" or "legacy" => V1Engine,
                _ => requestedEngine
            };
            if (normalized == V2Engine) Interlocked.Increment(ref _v2Count);
            else Interlocked.Increment(ref _v1Count);

            return new CanaryRoutingDecision(
                runId,
                normalized,
                IsPinned: false,
                RolloutPercentage: currentPercentage,
                HashBucket: ComputeHashBucket(runId),
                DecisionReason: $"Explicit engine version requested: {requestedEngine}"
            );
        }

        // 4. Deterministic hash bucket evaluation against rollout weight
        var bucket = ComputeHashBucket(runId);
        if (bucket < currentPercentage)
        {
            Interlocked.Increment(ref _v2Count);
            return new CanaryRoutingDecision(
                runId,
                V2Engine,
                IsPinned: false,
                RolloutPercentage: currentPercentage,
                HashBucket: bucket,
                DecisionReason: $"Canary bucket {bucket} < {currentPercentage}% rollout -> V2"
            );
        }
        else
        {
            Interlocked.Increment(ref _v1Count);
            return new CanaryRoutingDecision(
                runId,
                V1Engine,
                IsPinned: false,
                RolloutPercentage: currentPercentage,
                HashBucket: bucket,
                DecisionReason: $"Canary bucket {bucket} >= {currentPercentage}% rollout -> V1"
            );
        }
    }

    /// <summary>
    /// Records an abort trigger event and automatically applies safety fallback.
    /// </summary>
    public bool TriggerAbort(string runId, CanaryAbortReason reason, string details, string? engineVersion = null)
    {
        var record = new CanaryAbortRecord(
            runId,
            reason,
            details,
            DateTime.UtcNow,
            engineVersion ?? V2Engine
        );

        _recentAborts.Enqueue(record);
        while (_recentAborts.Count > MaxRecentAborts && _recentAborts.TryDequeue(out _)) { }

        // Critical triggers automatically drop canary to 0% and pause to prevent cascading failures
        if (reason is CanaryAbortReason.StaleCommit
            or CanaryAbortReason.DuplicateExam
            or CanaryAbortReason.GroundingBlocker
            or CanaryAbortReason.UnauthorizedWrite
            or CanaryAbortReason.ContractBreak)
        {
            lock (_lock)
            {
                _canaryPercentage = 0;
                _isPaused = true;
                _pausedReason = $"Auto-aborted on critical condition: {reason} ({details})";
                _pausedAt = DateTime.UtcNow;
            }
            return true;
        }

        return false;
    }

    /// <summary>
    /// Returns the current canary status snapshot.
    /// </summary>
    public CanaryStatusDto GetStatus()
    {
        lock (_lock)
        {
            return new CanaryStatusDto(
                CanaryPercentage: _canaryPercentage,
                IsPaused: _isPaused,
                PausedReason: _pausedReason,
                PausedAt: _pausedAt,
                TotalRoutedRuns: _v1Count + _v2Count,
                V1RoutedRuns: _v1Count,
                V2RoutedRuns: _v2Count,
                AbortCount: _recentAborts.Count,
                RecentAborts: _recentAborts.ToArray()
            );
        }
    }
}
