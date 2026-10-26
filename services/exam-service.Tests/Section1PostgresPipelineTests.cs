using System.Diagnostics;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using exam_service.Domains.Entities;
using exam_service.Features.ReadingPaper;
using exam_service.Infrastructure.Persistence;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Hosting.Server;
using Microsoft.AspNetCore.Hosting.Server.Features;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Xunit;

namespace exam_service.Tests;

// Opt-in host: no production Program, seeder, worker, broker or provider services.
// Only this fixture's fresh, labelled server/database is allowed; never drops schema.
[Collection("DatabaseTests")]
public class Section1PostgresPipelineTests
{
    public sealed record Provision(PipelineRequest Request, string CapProfileJson, string CapProfileSha256);

    [Fact]
    public async Task Scripted_13Q_Pipeline_Recovers_After_Lost_Ack_And_Fences_Unsafe_Work()
    {
        var dsn = Environment.GetEnvironmentVariable("SECTION1_PIPELINE_POSTGRES")
            ?? throw new InvalidOperationException("Explicit session-owned disposable PostgreSQL required");
        var parsed = new Npgsql.NpgsqlConnectionStringBuilder(dsn);
        var resource = Environment.GetEnvironmentVariable("SECTION1_PIPELINE_RESOURCE_VERIFIED");
        if (string.IsNullOrWhiteSpace(resource) || !resource.StartsWith("section1-pipeline-postgres-", StringComparison.Ordinal) ||
            parsed.Host != Environment.GetEnvironmentVariable("SECTION1_PIPELINE_RESOURCE_HOST") ||
            parsed.Port != 5432 || parsed.Database != "section1_pipeline")
            throw new InvalidOperationException("Only the verified session-owned Section1 server is allowed");
        var python = Environment.GetEnvironmentVariable("SECTION1_PIPELINE_PYTHON")
            ?? throw new InvalidOperationException("Explicit offline venv Python required");
        var generation = Environment.GetEnvironmentVariable("SECTION1_PIPELINE_GENERATION_DIR")
            ?? throw new InvalidOperationException("Explicit generation worktree required");
        var evidence = Environment.GetEnvironmentVariable("SECTION1_PIPELINE_EVIDENCE_DIR")
            ?? throw new InvalidOperationException("Explicit evidence directory required");
        var key = Guid.NewGuid().ToString("N");
        var builder = WebApplication.CreateBuilder();
        builder.WebHost.UseUrls("http://127.0.0.1:0");
        builder.Logging.ClearProviders();
        builder.Configuration.AddInMemoryCollection(new Dictionary<string, string?> { ["InternalApiKey"] = key });
        builder.Services.AddDbContext<ExamDbContext>(options => options.UseNpgsql(dsn, n =>
            n.ConfigureDataSource(source => source.EnableDynamicJson())));
        // Provisioning below uses the complete supplied test profile, not current DI defaults.
        builder.Services.AddSingleton<ReadingPaperCapsProfile>(_ => throw new InvalidOperationException("No live campaign provisioning in fixture"));
        await using var app = builder.Build();
        using (var scope = app.Services.CreateScope())
            await scope.ServiceProvider.GetRequiredService<ExamDbContext>().Database.MigrateAsync();
        app.Use(async (context, next) => {
            if (context.Request.Headers[CheckpointService.InternalApiKeyHeader] != key) { context.Response.StatusCode = 403; return; }
            await next(context);
        });
        app.MapCheckpointEndpoints();
        // Same scoped selector used by the real worker, not a Python policy override.
        var acceptancePolicy = PinnedExecutionPolicy.CreateForSources("minimax", [new ReadingSource(
            "PMC1234567", "offline", null, "https://example.invalid", "CC BY", 800,
            Metadata: new() { ["acceptancePolicy"] = PinnedExecutionPolicy.Acceptance544 })]);
        app.MapGet("/fixture/acceptance-policy", () => Results.Ok(acceptancePolicy));
        app.MapPost("/fixture/provision", async (Provision input, ExamDbContext db) => {
            var request = input.Request;
            if (request.Policy.ComputeHash() != acceptancePolicy.ComputeHash() ||
                !request.RunId.StartsWith("section1_fixture_", StringComparison.Ordinal) || request.Finalize)
                return Results.BadRequest();
            using var profile = JsonDocument.Parse(input.CapProfileJson);
            var root = profile.RootElement;
            var caps = root.GetProperty("caps");
            var run = new ReadingPaperRun {
                RunId = request.RunId, JobId = request.JobId, Status = "RUNNING", Epoch = request.Epoch,
                LeaseOwner = request.LeaseOwner, LeaseUntil = DateTime.UtcNow.AddMinutes(15),
                BudgetCapCalls = caps.GetProperty("standaloneRunBudgetCapCalls").GetInt32(),
                BudgetCapTokens = caps.GetProperty("standaloneRunBudgetCapTokens").GetInt32(),
                BudgetCapWallTimeSeconds = caps.GetProperty("standaloneRunBudgetCapWallTimeSeconds").GetInt32(),
                BudgetProfileVersion = root.GetProperty("profileVersion").GetString()!,
                BudgetProfileSource = root.GetProperty("profileSource").GetString()!,
                BudgetProfileJson = input.CapProfileJson, BudgetProfileSha256 = input.CapProfileSha256,
                SourceRevisionsJson = JsonSerializer.Serialize(request, ReadingPaperRules.Json)
            };
            if (!ReadingPaperCapsProfile.MatchesRunBudget(run.BudgetProfileJson, run.BudgetProfileSha256, false,
                run.BudgetCapCalls, run.BudgetCapTokens, run.BudgetCapWallTimeSeconds)) return Results.BadRequest();
            ReadingPaperExecutionSnapshot.Pin(run, request.Policy);
            db.ReadingPaperJobs.Add(new ReadingPaperJob {
                Id = request.JobId, ActiveRunId = request.RunId, Topic = request.Topic, Status = "Running",
                Epoch = request.Epoch, LeaseOwner = request.LeaseOwner, LeaseUntil = run.LeaseUntil,
                SourcesJson = JsonSerializer.Serialize(request.Sources, ReadingPaperRules.Json), SectionsJson = "[]", Logs = "Isolated scripted integration"
            });
            db.ReadingPaperRuns.Add(run);
            await db.SaveChangesAsync();
            return Results.Ok();
        });
        app.MapGet("/fixture/request/{runId}", async (string runId, ExamDbContext db) => {
            var run = await db.ReadingPaperRuns.SingleAsync(r => r.RunId == runId);
            return Results.Content(run.SourceRevisionsJson, "application/json");
        });
        app.MapGet("/fixture/snapshot/{runId}", async (string runId, ExamDbContext db) => Results.Ok(new {
            run = await db.ReadingPaperRuns.Where(r => r.RunId == runId).Select(r => new {
                r.Epoch, r.LeaseOwner, r.BudgetUsedCalls, r.BudgetUsedTokens, r.BudgetUsedWallTimeSeconds,
                r.BudgetProfileSha256, r.BudgetProfileJson }).SingleAsync(),
            heads = await db.ReadingPaperArtifactHeads.Where(r => r.RunId == runId).OrderBy(r => r.ArtifactId).ToListAsync(),
            operations = await db.ReadingPaperOperations.Where(r => r.RunId == runId).OrderBy(r => r.OperationId).ToListAsync(),
            cursors = await db.ReadingPaperLoopCursors.Where(r => r.RunId == runId).OrderBy(r => r.ArtifactId).ToListAsync(),
            evaluations = await db.ReadingPaperEvaluations.Where(r => r.RunId == runId).OrderBy(r => r.EvaluationId).ToListAsync(),
            dependencies = await db.ReadingPaperArtifactDependencies.Where(r => r.RunId == runId).OrderBy(r => r.Id).ToListAsync(),
            allocations = await db.ReadingPaperBudgetAllocations.Where(r => r.RunId == runId).OrderBy(r => r.ScopeType).ThenBy(r => r.ScopeId).ToListAsync()
        }));
        app.MapPost("/fixture/takeover/{runId}", async (string runId, ExamDbContext db) => {
            await using var tx = await db.Database.BeginTransactionAsync();
            var run = await db.ReadingPaperRuns.Include(r => r.Job).SingleAsync(r => r.RunId == runId);
            var oldEpoch = run.Epoch;
            // Expire the original lease, then acquire with a CAS exactly as a new worker would.
            await db.ReadingPaperJobs.Where(j => j.Id == run.JobId).ExecuteUpdateAsync(s => s.SetProperty(j => j.LeaseUntil, DateTime.UtcNow.AddSeconds(-1)));
            var owner = Guid.NewGuid();
            var claimed = await db.ReadingPaperJobs.Where(j => j.Id == run.JobId && j.Epoch == oldEpoch && j.LeaseUntil < DateTime.UtcNow)
                .ExecuteUpdateAsync(s => s.SetProperty(j => j.Epoch, j => j.Epoch + 1).SetProperty(j => j.LeaseOwner, owner)
                    .SetProperty(j => j.LeaseUntil, DateTime.UtcNow.AddMinutes(15)));
            Assert.Equal(1, claimed);
            run.Epoch++; run.LeaseOwner = owner; run.LeaseUntil = DateTime.UtcNow.AddMinutes(15);
            await db.SaveChangesAsync(); await tx.CommitAsync();
            return Results.Ok(new { epoch = run.Epoch, leaseOwner = owner });
        });
        app.MapGet("/fixture/projected-draft/{runId}", async (string runId, ExamDbContext db) => {
            var head = await db.ReadingPaperArtifactHeads.AsNoTracking().SingleAsync(h => h.RunId == runId && h.ArtifactId == $"section:{runId}:1");
            var artifact = await db.ReadingPaperArtifacts.AsNoTracking().SingleAsync(a => a.RunId == runId && a.ArtifactId == head.ArtifactId &&
                a.Version == head.AcceptedVersion && a.ContentHash == head.AcceptedHash);
            using var payload = JsonDocument.Parse(artifact.PayloadJson);
            var section = CheckpointService.ParseCanonicalV2Section(payload.RootElement)!;
            var job = await db.ReadingPaperJobs.AsNoTracking().SingleAsync(j => j.ActiveRunId == runId);
            var draft = ReadingPaperWorker.BuildExam(job, [section]); // in memory only; no publication or database write
            return Results.Ok(new { source = section.Source, questions = draft.Sections.Single().Questions.OrderBy(q => q.Idx).Select(q => new {
                number = q.Idx, type = q.Type, prompt = q.PromptMd }) });
        });
        app.MapPost("/fixture/historical-failure", async (ExamDbContext db) => {
            var id = Guid.NewGuid();
            var run = new ReadingPaperRun { JobId = id, RunId = $"successor_history_{id:N}", Status = "RUNNING", Epoch = 3,
                LeaseOwner = Guid.NewGuid(), LeaseUntil = DateTime.UtcNow.AddSeconds(-5) };
            db.ReadingPaperJobs.Add(new ReadingPaperJob { Id = id, Topic = "Benchmark historical failure simulation", Status = "Failed",
                Epoch = 3, ActiveRunId = run.RunId });
            db.ReadingPaperRuns.Add(run); await db.SaveChangesAsync();
            return Results.Ok(new { job_id = id });
        });
        app.MapPost("/fixture/reconcile-terminal/{id:guid}", async (Guid id, ExamDbContext db) =>
            Results.Ok(new { reconciled = await ReadingPaperLifecycle.ReconcileTerminalAsync(db, id, 3, default) }));
        app.MapGet("/fixture/terminal-proof/{id:guid}", async (Guid id, ExamDbContext db) => {
            var job = await db.ReadingPaperJobs.AsNoTracking().SingleAsync(j => j.Id == id);
            var run = await db.ReadingPaperRuns.AsNoTracking().SingleAsync(r => r.JobId == id && r.RunId == job.ActiveRunId);
            return Results.Ok(new { job_id = id, job_status = job.Status, run_status = run.Status,
                job_epoch = job.Epoch, run_epoch = run.Epoch, job_cancel_version = job.CancelVersion, run_cancel_version = run.CancelVersion,
                job_lease_owner = job.LeaseOwner, run_lease_owner = run.LeaseOwner,
                job_lease_until = job.LeaseUntil is {} jl ? (long?)new DateTimeOffset(jl).ToUnixTimeSeconds() : null,
                run_lease_until = run.LeaseUntil is {} rl ? (long?)new DateTimeOffset(rl).ToUnixTimeSeconds() : null,
                unresolved_operations = await db.ReadingPaperOperations.CountAsync(o => o.RunId == run.RunId && o.OperationType == "PROVIDER_CALL" &&
                    (o.Status == "RESERVED" || o.Status == "UNKNOWN_OUTCOME" || o.AccountingType == "UNKNOWN")) });
        });
        app.MapPost("/fixture/create-successor", (ReadingJobRequest request, ExamDbContext db) =>
            request.Sources is { Count: 1 } && request.Topic.StartsWith("Benchmark ", StringComparison.Ordinal) && request.SubmissionAttemptId != null
                ? ReadingPaperEndpoints.Create(request, db, new ReadingPaperAiClient(new HttpClient()), default)
                : Task.FromResult<IResult>(Results.BadRequest()));
        app.MapGet("/fixture/successor-count/{id:guid}", async (Guid id, ExamDbContext db) => Results.Ok(new {
            jobs = await db.ReadingPaperJobs.CountAsync(j => j.Id == id), runs = await db.ReadingPaperRuns.CountAsync(r => r.JobId == id) }));
        await app.StartAsync();
        var url = app.Services.GetRequiredService<IServer>().Features.Get<IServerAddressesFeature>()!.Addresses.Single();
        var start = new ProcessStartInfo(python) { WorkingDirectory = generation, RedirectStandardOutput = true, RedirectStandardError = true };
        start.ArgumentList.Add("tests/section1_postgres_driver.py");
        // Do not inherit live provider credentials, endpoint aliases or .env overrides.
        start.Environment.Clear();
        foreach (var name in new[] { "PATH", "HOME", "LANG" })
            if (Environment.GetEnvironmentVariable(name) is { } value) start.Environment[name] = value;
        start.Environment["PYTHONPATH"] = generation;
        start.Environment["GENERATION_SERVICE_ENV_FILE"] = "/dev/null";
        start.Environment["SECTION1_FIXTURE_URL"] = url;
        start.Environment["SECTION1_FIXTURE_KEY"] = key;
        start.Environment["SECTION1_FIXTURE_EVIDENCE"] = evidence;
        if (Environment.GetEnvironmentVariable("SECTION1_PIPELINE_RESTART_VERIFY") == "1")
            start.Environment["SECTION1_FIXTURE_RESTART_VERIFY"] = "1";
        if (Environment.GetEnvironmentVariable("SECTION1_PIPELINE_CRASH_BOUNDARY") is { } boundary)
            start.Environment["SECTION1_FIXTURE_CRASH_BOUNDARY"] = boundary;
        using var process = Process.Start(start)!;
        var stdout = process.StandardOutput.ReadToEndAsync();
        var stderr = process.StandardError.ReadToEndAsync();
        try { await process.WaitForExitAsync(new CancellationTokenSource(TimeSpan.FromMinutes(12)).Token); }
        finally { if (!process.HasExited) process.Kill(entireProcessTree: true); }
        var output = await stdout + await stderr;
        await File.WriteAllTextAsync(Path.Combine(evidence, "pipeline-driver.log"), output);
        Assert.True(process.ExitCode == 0, output);
        await app.StopAsync();
    }
}
