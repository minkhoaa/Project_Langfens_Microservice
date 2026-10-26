using System.Reflection;
using System.Net;
using exam_service.Domains.Entities;
using exam_service.Features.ReadingPaper;
using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging.Abstractions;
using Xunit;

namespace exam_service.Tests;

[Collection("DatabaseTests")]
public class Section1LifecycleTests
{
    internal static string Connection()
    {
        var dsn = Environment.GetEnvironmentVariable("SECTION1_PIPELINE_POSTGRES") ?? throw new InvalidOperationException("Verified disposable DSN required");
        var parsed = new Npgsql.NpgsqlConnectionStringBuilder(dsn);
        if (parsed.Database != "section1_pipeline" || parsed.Port != 5432 || parsed.Host != Environment.GetEnvironmentVariable("SECTION1_PIPELINE_RESOURCE_HOST") ||
            Environment.GetEnvironmentVariable("SECTION1_PIPELINE_RESOURCE_VERIFIED")?.StartsWith("section1-pipeline-postgres-") != true)
            throw new InvalidOperationException("Unverified database");
        return dsn;
    }

    internal static ReadingPaperCapsProfile Caps()
    {
        var root = new DirectoryInfo(AppContext.BaseDirectory);
        while (root != null && !File.Exists(Path.Combine(root.FullName, "deploy/envs/loop-caps.env"))) root = root.Parent;
        var values = File.ReadAllLines(Path.Combine(root!.FullName, "deploy/envs/loop-caps.env"))
            .Where(l => !string.IsNullOrWhiteSpace(l) && !l.TrimStart().StartsWith('#')).Select(l => l.Split('=', 2))
            .ToDictionary(p => p[0], p => (string?)p[1]);
        return ReadingPaperCapsProfile.FromConfiguration(new ConfigurationBuilder().AddInMemoryCollection(values).Build());
    }

    [Theory]
    [InlineData("Failed", "FAILED")]
    [InlineData("Cancelled", "CANCELLED")]
    [InlineData("NeedsSources", "NEEDS_SOURCES")]
    public async Task Historical_Reconciliation_Is_Idempotent_And_Refuses_Unknown_Or_Newer_Epoch(string terminal, string target)
    {
        var options = new DbContextOptionsBuilder<ExamDbContext>().UseNpgsql(Connection()).Options;
        await using var db = new ExamDbContext(options);
        await db.Database.MigrateAsync();
        var job = new ReadingPaperJob { Topic = "Benchmark Historical simulation", Status = terminal, Epoch = 3 };
        var run = new ReadingPaperRun { JobId = job.Id, RunId = Guid.NewGuid().ToString(), Status = "RUNNING", Epoch = 3,
            LeaseOwner = Guid.NewGuid(), LeaseUntil = DateTime.UtcNow.AddSeconds(-5) };
        job.ActiveRunId = run.RunId;
        db.Add(job); db.Add(run);
        var operation = new ReadingPaperOperation { RunId = run.RunId, OperationId = "uncertain", Status = "UNKNOWN_OUTCOME" };
        db.Add(operation); await db.SaveChangesAsync();
        Assert.False(await ReadingPaperLifecycle.ReconcileTerminalAsync(db, job.Id, 3, default));
        await db.Entry(run).ReloadAsync(); Assert.Equal("RUNNING", run.Status);
        operation.Status = "COMPLETED"; operation.AccountingType = "RECONCILED"; await db.SaveChangesAsync();
        Assert.False(await ReadingPaperLifecycle.ReconcileTerminalAsync(db, job.Id, 2, default));
        Assert.True(await ReadingPaperLifecycle.ReconcileTerminalAsync(db, job.Id, 3, default));
        await db.Entry(run).ReloadAsync(); Assert.Equal(target, run.Status); Assert.Null(run.LeaseOwner);
        var updated = run.UpdatedAt;
        Assert.True(await ReadingPaperLifecycle.ReconcileTerminalAsync(db, job.Id, 3, default));
        await db.Entry(run).ReloadAsync(); Assert.Equal(updated, run.UpdatedAt);
    }

    [Theory]
    [InlineData("expired")]
    [InlineData("owner")]
    [InlineData("epoch")]
    [InlineData("cancel")]
    public async Task Failure_Without_Current_Lease_Authority_Cannot_Mutate_Either_State(string fault)
    {
        await using var db = new ExamDbContext(new DbContextOptionsBuilder<ExamDbContext>().UseNpgsql(Connection()).Options);
        await db.Database.MigrateAsync();
        var owner = Guid.NewGuid();
        var job = new ReadingPaperJob { Topic = "Benchmark Fence simulation", Status = "Running", Epoch = 4, LeaseOwner = owner,
            LeaseUntil = DateTime.UtcNow.AddMinutes(2) };
        var run = new ReadingPaperRun { JobId = job.Id, RunId = Guid.NewGuid().ToString(), Status = "RUNNING", Epoch = 4,
            LeaseOwner = owner, LeaseUntil = job.LeaseUntil };
        job.ActiveRunId = run.RunId;
        if (fault == "expired") { job.LeaseUntil = DateTime.UtcNow.AddSeconds(-1); run.LeaseUntil = job.LeaseUntil; }
        db.Add(job); db.Add(run); await db.SaveChangesAsync();
        Assert.False(await ReadingPaperLifecycle.FailAsync(db, job.Id, fault == "owner" ? Guid.NewGuid() : owner,
            fault == "epoch" ? 3 : 4, fault == "cancel" ? 1 : 0, "Failed", "stale", default));
        await db.Entry(job).ReloadAsync(); await db.Entry(run).ReloadAsync();
        Assert.Equal("Running", job.Status); Assert.Equal("RUNNING", run.Status);
    }

    [Fact]
    public async Task Retry_Refuses_Unreconciled_Physical_Submission()
    {
        await using var db = new ExamDbContext(new DbContextOptionsBuilder<ExamDbContext>().UseNpgsql(Connection()).Options);
        await db.Database.MigrateAsync();
        var job = new ReadingPaperJob { Topic = "Benchmark Unknown simulation", Status = "Failed" };
        var run = new ReadingPaperRun { JobId = job.Id, RunId = Guid.NewGuid().ToString(), Status = "FAILED" };
        job.ActiveRunId = run.RunId; db.Add(job); db.Add(run);
        db.Add(new ReadingPaperOperation { RunId = run.RunId, OperationId = "unknown", Status = "UNKNOWN_OUTCOME" });
        await db.SaveChangesAsync();
        var result = await ReadingPaperEndpoints.Retry(job.Id, db, default);
        Assert.Equal(409, ((Microsoft.AspNetCore.Http.IStatusCodeHttpResult)result).StatusCode);
        await db.Entry(job).ReloadAsync(); Assert.Equal("Failed", job.Status);
    }

    [Fact]
    public async Task Explicit_Attempt_Identity_Is_The_Durable_Job_Identity_And_Duplicate_Post_Is_Idempotent()
    {
        var identity = Guid.NewGuid();
        var request = new ReadingJobRequest("Benchmark successor simulation", Sources: [new ReadingSource(
            "PMC1234567", "offline", null, "https://example.invalid", "CC BY 4.0", 800)], Provider: "minimax",
            AcceptancePolicy: "acceptance_5_4_4_v1", SubmissionAttemptId: identity);
        var options = new DbContextOptionsBuilder<ExamDbContext>().UseNpgsql(Connection()).Options;
        await using (var schema = new ExamDbContext(options)) await schema.Database.MigrateAsync();
        async Task<Microsoft.AspNetCore.Http.IResult> Post(ReadingJobRequest input)
        {
            await using var db = new ExamDbContext(options);
            return await (Task<Microsoft.AspNetCore.Http.IResult>)typeof(ReadingPaperEndpoints).GetMethod("Create", BindingFlags.NonPublic | BindingFlags.Static)!
                .Invoke(null, [input, db, new ReadingPaperAiClient(new HttpClient(new OfflineFailure())), CancellationToken.None])!;
        }
        var results = await Task.WhenAll(Post(request), Post(request));
        Assert.All(results, r => Assert.Contains(((Microsoft.AspNetCore.Http.IStatusCodeHttpResult)r).StatusCode, new int?[] {200, 201}));
        await using var check = new ExamDbContext(options);
        Assert.Equal(1, await check.ReadingPaperJobs.CountAsync(j => j.Id == identity));
        var conflict = await Post(request with { Topic = "Different authorized payload" });
        Assert.Equal(409, ((Microsoft.AspNetCore.Http.IStatusCodeHttpResult)conflict).StatusCode);
    }

    [Fact]
    public async Task Admin_Cancellation_Fences_Both_States_And_A_Late_Failure()
    {
        await using var db = new ExamDbContext(new DbContextOptionsBuilder<ExamDbContext>().UseNpgsql(Connection()).Options);
        await db.Database.MigrateAsync();
        var owner = Guid.NewGuid();
        var job = new ReadingPaperJob { Topic = "Benchmark cancellation simulation", Status = "Running", LeaseOwner = owner,
            LeaseUntil = DateTime.UtcNow.AddMinutes(3), Epoch = 2 };
        var run = new ReadingPaperRun { JobId = job.Id, RunId = Guid.NewGuid().ToString(), Status = "RUNNING", Epoch = 2,
            LeaseOwner = owner, LeaseUntil = job.LeaseUntil };
        job.ActiveRunId = run.RunId; db.Add(job); db.Add(run); await db.SaveChangesAsync();
        var result = await (Task<Microsoft.AspNetCore.Http.IResult>)typeof(ReadingPaperEndpoints).GetMethod("Cancel", BindingFlags.NonPublic | BindingFlags.Static)!
            .Invoke(null, [job.Id, db, CancellationToken.None])!;
        Assert.Equal(200, ((Microsoft.AspNetCore.Http.IStatusCodeHttpResult)result).StatusCode);
        Assert.False(await ReadingPaperLifecycle.FailAsync(db, job.Id, owner, 2, 0, "Failed", "late", default));
        await db.Entry(job).ReloadAsync(); await db.Entry(run).ReloadAsync();
        Assert.Equal("Cancelled", job.Status); Assert.Equal("CANCELLED", run.Status);
        Assert.Equal(3, job.Epoch); Assert.Equal(3, run.Epoch); Assert.Equal(1, run.CancelVersion);
        Assert.Null(job.LeaseOwner); Assert.Null(run.LeaseOwner);
    }

    [Fact]
    public async Task Shutdown_Preserves_Run_Until_Lease_Expiry_Then_Restart_Reuses_Pinned_Policy()
    {
        using var shutdown = new CancellationTokenSource();
        var handler = new ShutdownOnce(shutdown);
        var services = new ServiceCollection();
        services.AddDbContext<ExamDbContext>(o => o.UseNpgsql(Connection()));
        services.AddSingleton(new ReadingPaperAiClient(new HttpClient(handler) { BaseAddress = new Uri("http://offline.invalid") }));
        await using var provider = services.BuildServiceProvider();
        var id = Guid.NewGuid();
        using (var seed = provider.CreateScope())
        {
            var db = seed.ServiceProvider.GetRequiredService<ExamDbContext>();
            await db.Database.MigrateAsync();
            db.Add(new ReadingPaperJob { Id = id, Topic = "Shutdown simulation", Status = "Pending", SourcesJson = "[{\"pmcid\":\"PMC1234567\",\"title\":\"offline\",\"url\":\"https://example.invalid\",\"license\":\"CC BY\",\"wordCount\":800,\"metadata\":{\"acceptancePolicy\":\"acceptance_5_4_4_v1\"}}]" });
            await db.SaveChangesAsync();
        }
        var worker = new ReadingPaperWorker(provider.GetRequiredService<IServiceScopeFactory>(), NullLogger<ReadingPaperWorker>.Instance, Caps());
        await Assert.ThrowsAnyAsync<OperationCanceledException>(() => Once(worker, shutdown.Token));
        string hash;
        using (var seed = provider.CreateScope())
        {
            var db = seed.ServiceProvider.GetRequiredService<ExamDbContext>();
            var job = await db.ReadingPaperJobs.AsNoTracking().SingleAsync(j => j.Id == id);
            var run = await db.ReadingPaperRuns.AsNoTracking().SingleAsync(r => r.JobId == id);
            Assert.Equal("Running", job.Status); Assert.Equal("RUNNING", run.Status);
            hash = run.BudgetProfileSha256;
            await db.ReadingPaperJobs.Where(j => j.Id == id).ExecuteUpdateAsync(s => s.SetProperty(j => j.LeaseUntil, DateTime.UtcNow.AddSeconds(-1)));
            await db.ReadingPaperRuns.Where(r => r.JobId == id).ExecuteUpdateAsync(s => s.SetProperty(r => r.LeaseUntil, DateTime.UtcNow.AddSeconds(-1)));
        }
        Assert.True(await Once(worker));
        using var check = provider.CreateScope();
        var saved = check.ServiceProvider.GetRequiredService<ExamDbContext>();
        var resumed = await saved.ReadingPaperRuns.AsNoTracking().SingleAsync(r => r.JobId == id);
        Assert.Equal("FAILED", resumed.Status); Assert.Equal(3, resumed.Epoch); Assert.Equal(hash, resumed.BudgetProfileSha256);
        Assert.Equal(2, handler.Calls);
        Assert.Equal("Failed", (await saved.ReadingPaperJobs.AsNoTracking().SingleAsync(j => j.Id == id)).Status);
    }

    private sealed class ShutdownOnce(CancellationTokenSource shutdown) : HttpMessageHandler
    {
        public int Calls;
        protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken ct)
        {
            if (Interlocked.Increment(ref Calls) == 1) { shutdown.Cancel(); throw new OperationCanceledException(ct); }
            return Task.FromResult(new HttpResponseMessage(HttpStatusCode.InternalServerError) { Content = new StringContent("restart failure") });
        }
    }

    private sealed class OfflineFailure : HttpMessageHandler
    {
        public int Calls;
        public PipelineRequest? Request;
        protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken ct)
        {
            Interlocked.Increment(ref Calls);
            Request = System.Text.Json.JsonSerializer.Deserialize<PipelineRequest>(request.Content!.ReadAsStringAsync(ct).GetAwaiter().GetResult(), ReadingPaperRules.Json);
            return Task.FromResult(new HttpResponseMessage(HttpStatusCode.InternalServerError) { Content = new StringContent("isolated failure") });
        }
    }

    internal static Task<bool> Once(ReadingPaperWorker worker, CancellationToken ct = default) =>
        (Task<bool>)typeof(ReadingPaperWorker).GetMethod("RunOne", BindingFlags.Instance | BindingFlags.NonPublic)!.Invoke(worker, [ct])!;

    [Fact]
    public async Task Worker_Exception_Terminates_Job_And_Run_Atomically_And_Competing_Workers_Claim_Once()
    {
        var services = new ServiceCollection();
        services.AddDbContext<ExamDbContext>(o => o.UseNpgsql(Connection()));
        var handler = new OfflineFailure();
        services.AddSingleton(new ReadingPaperAiClient(new HttpClient(handler) { BaseAddress = new Uri("http://offline.invalid/") }));
        await using var provider = services.BuildServiceProvider();
        var id = Guid.NewGuid();
        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            await db.Database.MigrateAsync();
            // Other tests retain running fixture jobs; exclude them from this worker's queue.
            // This is a fresh lifecycle-only server, never a historical database.
            db.ReadingPaperJobs.Add(new ReadingPaperJob { Id = id, Topic = "Isolated lifecycle", Status = "Pending", SourcesJson = "[{\"pmcid\":\"PMC1234567\",\"title\":\"offline\",\"url\":\"https://example.invalid\",\"license\":\"CC BY\",\"wordCount\":800,\"metadata\":{\"acceptancePolicy\":\"acceptance_5_4_4_v1\"}}]", SectionsJson = "[]" });
            await db.SaveChangesAsync();
        }
        var worker = new ReadingPaperWorker(provider.GetRequiredService<IServiceScopeFactory>(), NullLogger<ReadingPaperWorker>.Instance, Caps());
        await Task.WhenAll(Once(worker), Once(worker));
        using var check = provider.CreateScope();
        var saved = check.ServiceProvider.GetRequiredService<ExamDbContext>();
        var job = await saved.ReadingPaperJobs.AsNoTracking().SingleAsync(j => j.Id == id);
        var run = await saved.ReadingPaperRuns.AsNoTracking().SingleAsync(r => r.JobId == id);
        Assert.Equal("Failed", job.Status);
        Assert.Equal("FAILED", run.Status);
        Assert.Null(job.LeaseOwner); Assert.Null(run.LeaseOwner);
        Assert.Equal(job.Epoch, run.Epoch);
        Assert.Equal(1, handler.Calls);
        Assert.Equal("acceptance_5_4_4_v1", handler.Request!.Policy.BlueprintMode);
        Assert.Equal(new[] { 5, 4, 4 }, handler.Request.Policy.Sections.Single().Groups.Select(g => g.Count));
        Assert.Equal(60, handler.Request.Policy.ProviderCallSeconds);
        Assert.True(run.BudgetCapTokens > 0);
    }
}
