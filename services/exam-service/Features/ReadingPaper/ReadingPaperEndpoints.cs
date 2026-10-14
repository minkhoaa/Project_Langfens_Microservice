using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Text.RegularExpressions;
using exam_service.Domains.Entities;
using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Shared.Security.Roles;
namespace exam_service.Features.ReadingPaper;

public static class ReadingPaperEndpoints
{
    private static readonly Regex SourceIdPattern = new(
        @"^(?:PMC[0-9]+|(?:CUSTOM|URL):.+|(?:TXT|HTML|MD|URL)_.+)$",
        RegexOptions.IgnoreCase | RegexOptions.Compiled);
    private static readonly Regex PmcOnlyPattern = new(
        @"^PMC[0-9]+$",
        RegexOptions.IgnoreCase | RegexOptions.Compiled);
    public static void MapReadingPaperEndpoints(this IEndpointRouteBuilder app)
    {
        var routes = app.MapGroup("/api/admin/reading-paper").RequireAuthorization(Roles.Admin);
        routes.MapGet("/sources", Search);
        routes.MapPost("/sources/ingest", IngestSource);
        routes.MapPost("/jobs", Create);
        routes.MapGet("/jobs", List);
        routes.MapGet("/jobs/{id:guid}", Get);
        routes.MapPut("/jobs/{id:guid}/sources", ReplaceSources);
        routes.MapPost("/jobs/{id:guid}/retry", Retry);
        routes.MapPost("/jobs/{id:guid}/cancel", Cancel);

        // Canary & Rollout Controls
        var canaryRoutes = routes.MapGroup("/canary");
        canaryRoutes.MapGet("", GetCanaryStatus);
        canaryRoutes.MapPost("/percentage", SetCanaryPercentage);
        canaryRoutes.MapPost("/pause", PauseCanary);
        canaryRoutes.MapPost("/resume", ResumeCanary);
        canaryRoutes.MapPost("/abort", AbortCanaryRun);
    }

    public record SetCanaryPercentageRequest(int Percentage);
    public record CanaryPauseRequest(string? Reason);
    public record CanaryAbortRequest(string RunId, string Reason, string? Details = null);

    private static IResult GetCanaryStatus(CanaryRoutingService canary)
        => Results.Ok(canary.GetStatus());

    private static IResult SetCanaryPercentage(SetCanaryPercentageRequest request, CanaryRoutingService canary)
    {
        if (request.Percentage is < 0 or > 100)
            return Results.BadRequest(new { error = "Percentage must be between 0 and 100" });
        canary.SetCanaryPercentage(request.Percentage);
        return Results.Ok(canary.GetStatus());
    }

    private static IResult PauseCanary(CanaryPauseRequest request, CanaryRoutingService canary)
    {
        canary.Pause(request.Reason ?? "Admin pause requested");
        return Results.Ok(canary.GetStatus());
    }

    private static IResult ResumeCanary(CanaryRoutingService canary)
    {
        canary.Resume();
        return Results.Ok(canary.GetStatus());
    }

    private static async Task<IResult> AbortCanaryRun(CanaryAbortRequest request, CanaryRoutingService canary, ExamDbContext db, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(request.RunId))
            return Results.BadRequest(new { error = "RunId is required" });

        canary.TriggerAbort(request.RunId, CanaryAbortReason.ManualAbort, request.Details ?? request.Reason);

        var run = await db.ReadingPaperRuns.FirstOrDefaultAsync(r => r.RunId == request.RunId, ct);
        if (run != null)
        {
            run.Status = "ABORTED";
            run.UpdatedAt = DateTime.UtcNow;
            var job = await db.ReadingPaperJobs.FirstOrDefaultAsync(j => j.Id == run.JobId, ct);
            if (job != null)
            {
                job.Status = "Aborted";
                job.Error = $"Manually aborted: {request.Reason}";
                job.UpdatedAt = DateTime.UtcNow;
            }
            await db.SaveChangesAsync(ct);
        }

        return Results.Ok(new { status = "ABORTED", runId = request.RunId, reason = request.Reason });
    }

    private static async Task<IResult> IngestSource(IngestSourceRequest request,
        ReadingPaperAiClient ai, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(request.Payload))
            return Results.BadRequest(new { error = "Payload cannot be empty" });
        try
        {
            var source = await ai.IngestSourceAsync(request, ct);
            return Results.Ok(source);
        }
        catch (ReadingSourceUnavailableException ex)
        {
            return Results.UnprocessableEntity(new { error = ex.Message });
        }
        catch (Exception ex) when (ex is HttpRequestException or TaskCanceledException)
        {
            return Results.Problem(ex.Message, statusCode: 503);
        }
    }

    private static async Task<IResult> Search(string topic, ReadingPaperAiClient ai, CancellationToken ct)
    {
        if (topic.Trim().Length is < 3 or > 120) return Results.BadRequest(new { error = "Topic must contain 3–120 characters" });
        try { return Results.Ok(await ai.SearchAsync(topic.Trim(), ct)); }
        catch (Exception ex) when (ex is HttpRequestException or TaskCanceledException)
        { return Results.Problem(ex.Message, statusCode: 503); }
    }

    private static async Task<IResult> Create(ReadingJobRequest request, ExamDbContext db,
        ReadingPaperAiClient ai, CancellationToken ct)
    {
        if (request.Topic?.Trim().Length is not (>= 3 and <= 120))
            return Results.BadRequest(new { error = "Topic must contain 3–120 characters" });
        var (sources, error) = request.Sources is { Count: > 0 }
            ? ValidateSources(request.Sources)
            : await VerifySources(request.Pmcids, ai, ct);
        var provider = !string.IsNullOrWhiteSpace(request.Provider) ? request.Provider.Trim().ToLowerInvariant() : null;
        if (provider is not null)
        {
            sources = sources.Select(s => s with
            {
                Metadata = new Dictionary<string, string>(s.Metadata ?? new Dictionary<string, string>()) { ["provider"] = provider }
            }).ToList();
        }
        var job = new ReadingPaperJob
        {
            Topic = request.Topic.Trim(), SourcesJson = JsonSerializer.Serialize(sources, ReadingPaperRules.Json),
            Status = error is null ? "Pending" : "NeedsSources", Error = error,
            Logs = SerializeLog("Information", error is null
                ? $"Job created with {sources.Count} verified source(s); waiting for the generation worker."
                : $"Job created but source verification needs attention: {error}")
        };
        db.ReadingPaperJobs.Add(job);
        await db.SaveChangesAsync(ct);
        return Results.Created($"/api/admin/reading-paper/jobs/{job.Id}", View(job));
    }

    private static async Task<IResult> Get(Guid id, ExamDbContext db, CancellationToken ct)
    {
        var job = await db.ReadingPaperJobs.AsNoTracking().FirstOrDefaultAsync(x => x.Id == id, ct);
        return job is null ? Results.NotFound() : Results.Ok(View(job));
    }

    private static async Task<IResult> List(ExamDbContext db, CancellationToken ct)
    {
        var jobs = await db.ReadingPaperJobs.AsNoTracking().OrderByDescending(x => x.CreatedAt)
            .Take(20).ToListAsync(ct);
        return Results.Ok(jobs.Select(x => new
        {
            x.Id, x.Topic, x.Status, x.CompletedSections, x.Error, x.ExamId, x.CreatedAt
        }));
    }

    private static async Task<IResult> ReplaceSources(Guid id, ReadingJobRequest request, ExamDbContext db,
        ReadingPaperAiClient ai, CancellationToken ct)
    {
        var job = await db.ReadingPaperJobs.FirstOrDefaultAsync(x => x.Id == id, ct);
        if (job is null) return Results.NotFound();
        if (job.Status is not ("NeedsSources" or "Failed") || job.ExamId is not null)
            return Results.Conflict(new { error = "Sources can only be replaced before a paper is saved" });
        if (request.Topic?.Trim().Length is not (>= 3 and <= 120))
            return Results.BadRequest(new { error = "Topic must contain 3–120 characters" });
        var (sources, error) = request.Sources is { Count: > 0 }
            ? ValidateSources(request.Sources)
            : await VerifySources(request.Pmcids, ai, ct);
        var provider = !string.IsNullOrWhiteSpace(request.Provider) ? request.Provider.Trim().ToLowerInvariant() : null;
        if (provider is not null)
        {
            sources = sources.Select(s => s with
            {
                Metadata = new Dictionary<string, string>(s.Metadata ?? new Dictionary<string, string>()) { ["provider"] = provider }
            }).ToList();
        }
        job.Topic = request.Topic.Trim();
        await InvalidateChangedSourcesAsync(db, job, sources, ct);
        job.Status = error is null ? "Pending" : "NeedsSources";
        job.Error = error;
        job.LeaseUntil = null;
        job.LeaseOwner = null;
        job.UpdatedAt = DateTime.UtcNow;
        job.Logs += SerializeLog("Information", $"Sources replaced with {sources.Count} verified source(s); generation is ready to resume with preserved valid sections ({job.CompletedSections}/{sources.Count}).");
        await db.SaveChangesAsync(ct);
        return Results.Ok(View(job));
    }

    public static async Task InvalidateChangedSourcesAsync(ExamDbContext db, ReadingPaperJob job, List<ReadingSource> newSources, CancellationToken ct)
    {
        var existingSources = JsonSerializer.Deserialize<List<ReadingSource>>(job.SourcesJson, ReadingPaperRules.Json) ?? [];
        var existingSections = JsonSerializer.Deserialize<List<ReadingGeneratedSection>>(job.SectionsJson, ReadingPaperRules.Json) ?? [];

        var runId = job.ActiveRunId ?? $"run_{job.Id:N}";
        var preservedSections = new List<ReadingGeneratedSection>();

        for (var i = 0; i < existingSources.Count; i++)
        {
            var oldSrc = existingSources[i];
            var newSrc = i < newSources.Count ? newSources[i] : null;

            var isSameSource = newSrc != null &&
                string.Equals(ComputeSourceHash(oldSrc), ComputeSourceHash(newSrc), StringComparison.OrdinalIgnoreCase);

            if (isSameSource && i < existingSections.Count)
            {
                preservedSections.Add(existingSections[i]);
            }
            else
            {
                var sectionNum = i + 1;
                var sourceArtifactId = $"art_source_{sectionNum}";

                var allDeps = await db.ReadingPaperArtifactDependencies
                    .Where(d => d.RunId == runId)
                    .ToListAsync(ct);

                var childrenMap = new Dictionary<string, HashSet<string>>(StringComparer.OrdinalIgnoreCase);
                foreach (var dep in allDeps)
                {
                    if (!childrenMap.ContainsKey(dep.ParentArtifactId))
                        childrenMap[dep.ParentArtifactId] = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
                    childrenMap[dep.ParentArtifactId].Add(dep.ArtifactId);
                }

                var invalidated = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
                {
                    sourceArtifactId,
                    $"art_passage_{sectionNum}",
                    $"art_section_{sectionNum}"
                };
                var queue = new Queue<string>(invalidated);

                while (queue.Count > 0)
                {
                    var curr = queue.Dequeue();
                    if (childrenMap.TryGetValue(curr, out var children))
                    {
                        foreach (var child in children)
                        {
                            if (invalidated.Add(child))
                                queue.Enqueue(child);
                        }
                    }
                }

                // Invalidate aggregated paper as well
                invalidated.Add("art_paper");

                var headsToRemove = await db.ReadingPaperArtifactHeads
                    .Where(h => h.RunId == runId && invalidated.Contains(h.ArtifactId))
                    .ToListAsync(ct);

                db.ReadingPaperArtifactHeads.RemoveRange(headsToRemove);
            }
        }

        job.SourcesJson = JsonSerializer.Serialize(newSources, ReadingPaperRules.Json);
        job.SectionsJson = JsonSerializer.Serialize(preservedSections, ReadingPaperRules.Json);
        job.CompletedSections = preservedSections.Count;
    }

    public static string ComputeSourceHash(ReadingSource s)
    {
        var metaStr = s.Metadata is null
            ? ""
            : string.Join(";", s.Metadata.OrderBy(k => k.Key, StringComparer.Ordinal).Select(kv => $"{kv.Key}={kv.Value}"));

        var raw = $"{s.Pmcid}|{s.Title}|{s.Doi}|{s.License}|{s.Authors}|{s.WordCount}|{s.Url}|{s.OpenAlexId}|{s.TopicId}|{s.SourceType}|{metaStr}|{s.Content}|{s.ContentPreview}";
        return Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(raw)));
    }
    private static async Task<IResult> Retry(Guid id, ExamDbContext db, CancellationToken ct)
    {
        var job = await db.ReadingPaperJobs.FirstOrDefaultAsync(x => x.Id == id, ct);
        if (job is null) return Results.NotFound();
        if (job.Status != "Failed" || job.ExamId is not null)
            return Results.Conflict(new { error = "Only a failed, unsaved job can be retried" });
        job.Status = "Pending";
        job.Error = null;
        job.LeaseUntil = null;
        job.LeaseOwner = null;
        job.UpdatedAt = DateTime.UtcNow;
        job.Logs += SerializeLog("Information", "Retry requested; the worker will resume from the last saved passage.");
        await db.SaveChangesAsync(ct);
        return Results.Ok(View(job));
    }

    private static async Task<IResult> Cancel(Guid id, ExamDbContext db, CancellationToken ct)
    {
        var initialJob = await db.ReadingPaperJobs.AsNoTracking().FirstOrDefaultAsync(x => x.Id == id, ct);
        if (initialJob is null) return Results.NotFound();
        if (initialJob.Status is "Completed" or "Cancelled" or "Aborted")
            return Results.Conflict(new { error = $"Job in terminal status '{initialJob.Status}' cannot be cancelled" });

        var expectedEpoch = initialJob.Epoch;
        var expectedCancelVersion = initialJob.CancelVersion;
        var strategy = db.Database.CreateExecutionStrategy();
        return await strategy.ExecuteAsync(async () =>
        {
            await using var transaction = await db.Database.BeginTransactionAsync(ct);
            var job = await db.ReadingPaperJobs.AsNoTracking().FirstOrDefaultAsync(x => x.Id == id, ct);
            if (job is null) return Results.NotFound();
            if (job.Status == "Cancelled" && job.Error == "Cancelled by user" &&
                job.Epoch == expectedEpoch + 1 && job.CancelVersion == expectedCancelVersion + 1)
                return Results.Ok(View(job));
            if (job.Status is "Completed" or "Cancelled" or "Aborted")
                return Results.Conflict(new { error = $"Job in terminal status '{job.Status}' cannot be cancelled" });

            var now = DateTime.UtcNow;
            var cancellationLog = SerializeLog("Information", "Cancellation requested by admin. In-flight worker operations fenced.");
            var rows = await db.ReadingPaperJobs
                .Where(x => x.Id == id &&
                            (x.Status == "Pending" || x.Status == "Running" || x.Status == "NeedsSources") &&
                            x.CancelVersion == expectedCancelVersion && x.Epoch == expectedEpoch)
                .ExecuteUpdateAsync(x => x
                    .SetProperty(j => j.Status, "Cancelled")
                    .SetProperty(j => j.Epoch, j => j.Epoch + 1)
                    .SetProperty(j => j.CancelVersion, j => j.CancelVersion + 1)
                    .SetProperty(j => j.Error, "Cancelled by user")
                    .SetProperty(j => j.LeaseUntil, (DateTime?)null)
                    .SetProperty(j => j.LeaseOwner, (Guid?)null)
                    .SetProperty(j => j.UpdatedAt, now)
                    .SetProperty(j => j.Logs, j => j.Logs + "\n" + cancellationLog),
                    ct);

            if (rows == 0)
            {
                var refreshed = await db.ReadingPaperJobs.AsNoTracking().FirstOrDefaultAsync(x => x.Id == id, ct);
                return Results.Conflict(new { error = $"Job status changed concurrently to '{refreshed?.Status}' and could not be cancelled" });
            }

            await db.ReadingPaperRuns
                .Where(r => r.JobId == id && r.Status == "RUNNING")
                .ExecuteUpdateAsync(r => r
                    .SetProperty(x => x.Status, "CANCELLED")
                    .SetProperty(x => x.Epoch, expectedEpoch + 1)
                    .SetProperty(x => x.CancelVersion, expectedCancelVersion + 1)
                    .SetProperty(x => x.LeaseOwner, (Guid?)null)
                    .SetProperty(x => x.LeaseUntil, (DateTime?)null)
                    .SetProperty(x => x.UpdatedAt, now),
                    ct);

            var updatedJob = await db.ReadingPaperJobs.AsNoTracking().FirstAsync(x => x.Id == id, ct);
            var response = Results.Ok(View(updatedJob));
            await transaction.CommitAsync(ct);
            return response;
        });
    }

    private static IReadOnlyList<ReadingPaperLog> ReadLogs(string logs)
    {
        var entries = new List<ReadingPaperLog>();
        foreach (var line in logs.Split('\n', StringSplitOptions.RemoveEmptyEntries))
        {
            try
            {
                var entry = JsonSerializer.Deserialize<ReadingPaperLog>(line, ReadingPaperRules.Json);
                if (entry is not null) entries.Add(entry);
            }
            catch (JsonException)
            {
                entries.Add(new ReadingPaperLog(DateTime.UtcNow, "Warning", $"Legacy log entry: {line}"));
            }
        }

        return entries;
    }

    internal static (List<ReadingSource>, string?) ValidateSources(List<ReadingSource>? sources)
    {
        if (sources is null || sources.Count is < 1 or > 3
            || sources.Select(s => s.Pmcid).Distinct(StringComparer.OrdinalIgnoreCase).Count() != sources.Count
            || sources.Any(s => string.IsNullOrWhiteSpace(s.Pmcid) || !SourceIdPattern.IsMatch(s.Pmcid)))
            return (sources ?? [], "Select one to three distinct valid sources");
        if (sources.Where(s => !string.IsNullOrWhiteSpace(s.Doi)).Select(s => s.Doi!)
                .Distinct(StringComparer.OrdinalIgnoreCase).Count()
            != sources.Count(s => !string.IsNullOrWhiteSpace(s.Doi)))
            return (sources, "Selected sources include the same DOI twice");
        return (sources, null);
    }

    private static async Task<(List<ReadingSource>, string?)> VerifySources(List<string>? ids,
        ReadingPaperAiClient ai, CancellationToken ct)
    {
        if (ids is null || ids.Count is < 1 or > 3
            || ids.Distinct(StringComparer.OrdinalIgnoreCase).Count() != ids.Count
            || ids.Any(x => string.IsNullOrWhiteSpace(x) || !PmcOnlyPattern.IsMatch(x)))
            return ([], "Select one to three distinct Europe PMC source IDs (non-PMC sources must be ingested via /sources/ingest and submitted via Sources)");
        var sources = new List<ReadingSource>();
        foreach (var id in ids)
        {
            try { sources.Add(await ai.FetchSourceAsync(id, ct)); }
            catch (Exception ex) when (ex is ReadingSourceUnavailableException or HttpRequestException or TaskCanceledException)
            { return (sources, $"{id}: {ex.Message}"); }
        }
        if (sources.Where(s => s.Doi is not null).Select(s => s.Doi).Distinct(StringComparer.OrdinalIgnoreCase).Count()
            != sources.Count(s => s.Doi is not null))
            return (sources, "Selected sources include the same DOI twice");
        return (sources, null);
    }

    private static object View(ReadingPaperJob job) => new
    {
        job.Id, job.Topic, job.Status, job.CompletedSections, job.Error, job.ExamId,
        job.CreatedAt, job.UpdatedAt,
        Sources = JsonSerializer.Deserialize<List<ReadingSource>>(job.SourcesJson, ReadingPaperRules.Json) ?? [],
        Sections = JsonSerializer.Deserialize<List<ReadingGeneratedSection>>(job.SectionsJson, ReadingPaperRules.Json) ?? [],
        Logs = ReadLogs(job.Logs)
    };

    private static string SerializeLog(string level, string message)
        => JsonSerializer.Serialize(new ReadingPaperLog(DateTime.UtcNow, level, message), ReadingPaperRules.Json) + "\n";

}
