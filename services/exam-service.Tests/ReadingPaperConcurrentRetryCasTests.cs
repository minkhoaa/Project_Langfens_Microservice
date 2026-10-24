using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using exam_service.Domains.Entities;
using exam_service.Features.ReadingPaper;
using exam_service.Features.ReadingPaper.Contracts;
using exam_service.Infrastructure.Persistence;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace exam_service.Tests;

public sealed class ReadingPaperConcurrentRetryCasTests
{
    private const string IsolatedConnection = "Host=localhost;Port=5433;Database=exam-db;Username=exam;Password=exam";

    private DbContextOptions<ExamDbContext> CreateOptions()
    {
        return new DbContextOptionsBuilder<ExamDbContext>()
            .UseNpgsql(IsolatedConnection)
            .Options;
    }

    private async Task<ReadingPaperJob> SeedJobAsync(string status, Guid? examId = null, string topic = "Test Concurrency Topic")
    {
        var options = CreateOptions();
        await using var db = new ExamDbContext(options);

        var job = new ReadingPaperJob
        {
            Id = Guid.NewGuid(),
            Topic = topic,
            Status = status,
            ExamId = examId,
            Epoch = 1,
            CancelVersion = 0,
            Error = status == "Failed" ? "Simulated worker failure" : null,
            CreatedAt = DateTime.UtcNow.AddMinutes(-10),
            UpdatedAt = DateTime.UtcNow.AddMinutes(-5),
            Logs = "Initial seed log",
        };

        db.ReadingPaperJobs.Add(job);
        await db.SaveChangesAsync();
        return job;
    }

    [Fact]
    public async Task B1_To_B6_GenuinelyConcurrentRetry_ExactlyOneSucceeds_AndNonWinnersGetConflict()
    {
        // B1 & B2: Connects exclusively to isolated disposable test database at port 5433
        // B3: Seed a Failed job with ExamId = null
        var job = await SeedJobAsync("Failed", examId: null, topic: "Concurrent Retry Race Test");
        var jobId = job.Id;

        const int concurrencyDegree = 5;
        var startBarrier = new TaskCompletionSource(TaskCreationOptions.RunContinuationsAsynchronously);

        // B4: Dispatch genuinely concurrent retry requests with synchronized race timing
        var retryTasks = Enumerable.Range(0, concurrencyDegree).Select(async _ =>
        {
            var options = CreateOptions();
            await using var db = new ExamDbContext(options);

            // Wait for synchronization signal so all DB updates race simultaneously
            await startBarrier.Task;
            return await ReadingPaperEndpoints.Retry(jobId, db, CancellationToken.None);
        }).ToList();

        // Release all concurrent tasks at the exact same moment
        startBarrier.SetResult();
        var results = await Task.WhenAll(retryTasks);

        // B5 & B6: Capture results and assert exactly ONE conditional CAS update succeeds
        var okCount = results.Count(r => r.GetType().Name.Contains("Ok"));
        var conflictCount = results.Count(r => r.GetType().Name.Contains("Conflict"));

        Assert.Equal(1, okCount);
        Assert.Equal(concurrencyDegree - 1, conflictCount);

        // Verify final database state
        var verifyOptions = CreateOptions();
        await using var verifyDb = new ExamDbContext(verifyOptions);
        var finalJob = await verifyDb.ReadingPaperJobs.AsNoTracking().SingleAsync(j => j.Id == jobId);

        Assert.Equal("Pending", finalJob.Status);
        Assert.Null(finalJob.Error);
        Assert.Null(finalJob.LeaseOwner);
        Assert.Null(finalJob.LeaseUntil);

        // B9: Verify retry log is not duplicated despite multiple concurrent requests
        var logLines = finalJob.Logs.Split('\n', StringSplitOptions.RemoveEmptyEntries);
        var retryLogCount = logLines.Count(l => l.Contains("Retry requested"));
        Assert.Equal(1, retryLogCount);
    }

    [Theory]
    [InlineData("Pending")]
    [InlineData("Running")]
    [InlineData("Completed")]
    [InlineData("NeedsSources")]
    public async Task B7_Retry_AgainstNonFailedStatus_ReturnsConflict(string initialStatus)
    {
        var job = await SeedJobAsync(initialStatus, examId: null, topic: $"Status Matrix {initialStatus}");
        var options = CreateOptions();
        await using var db = new ExamDbContext(options);

        var result = await ReadingPaperEndpoints.Retry(job.Id, db, CancellationToken.None);

        Assert.True(result.GetType().Name.Contains("Conflict") || result is Microsoft.AspNetCore.Http.HttpResults.Conflict<object>);

        // Verify status in DB was NOT modified
        await using var verifyDb = new ExamDbContext(options);
        var refreshed = await verifyDb.ReadingPaperJobs.AsNoTracking().SingleAsync(j => j.Id == job.Id);
        Assert.Equal(initialStatus, refreshed.Status);
    }

    [Fact]
    public async Task B7_Retry_AgainstFailedWithExistingExamId_ReturnsConflict()
    {
        var existingExamId = Guid.NewGuid();
        var job = await SeedJobAsync("Failed", examId: existingExamId, topic: "Failed but already published");
        var options = CreateOptions();
        await using var db = new ExamDbContext(options);

        var result = await ReadingPaperEndpoints.Retry(job.Id, db, CancellationToken.None);

        Assert.True(result.GetType().Name.Contains("Conflict") || result is Microsoft.AspNetCore.Http.HttpResults.Conflict<object>);

        await using var verifyDb = new ExamDbContext(options);
        var refreshed = await verifyDb.ReadingPaperJobs.AsNoTracking().SingleAsync(j => j.Id == job.Id);
        Assert.Equal("Failed", refreshed.Status);
        Assert.Equal(existingExamId, refreshed.ExamId);
    }

    [Fact]
    public async Task B7_Retry_AgainstUnknownJobId_ReturnsNotFound()
    {
        var unknownId = Guid.NewGuid();
        var options = CreateOptions();
        await using var db = new ExamDbContext(options);

        var result = await ReadingPaperEndpoints.Retry(unknownId, db, CancellationToken.None);

        Assert.True(result.GetType().Name.Contains("NotFound") || result is Microsoft.AspNetCore.Http.HttpResults.NotFound);
    }

    [Fact]
    public async Task B8_WorkerFencingInvariants_PreservedAcrossRetryCycle()
    {
        // 1. Seed failed job
        var job = await SeedJobAsync("Failed", examId: null, topic: "Worker Fencing Preservation");
        var options = CreateOptions();
        await using var db = new ExamDbContext(options);

        // 2. Successful Retry sets job to Pending
        var retryResult = await ReadingPaperEndpoints.Retry(job.Id, db, CancellationToken.None);
        Assert.True(retryResult.GetType().Name.Contains("Ok"));

        // 3. Worker CAS lease acquisition on Pending job succeeds
        var workerOwner = Guid.NewGuid();
        var leaseUntil = DateTime.UtcNow.AddMinutes(5);
        var rowsAcquired = await db.ReadingPaperJobs
            .Where(j => j.Id == job.Id && j.Status == "Pending" && (j.LeaseUntil == null || j.LeaseUntil < DateTime.UtcNow))
            .ExecuteUpdateAsync(s => s
                .SetProperty(j => j.Status, "Running")
                .SetProperty(j => j.LeaseOwner, workerOwner)
                .SetProperty(j => j.LeaseUntil, leaseUntil));

        Assert.Equal(1, rowsAcquired);

        // 4. Concurrent worker attempting to acquire already-leased job fails with 0 rows
        var competingOwner = Guid.NewGuid();
        var competingAcquired = await db.ReadingPaperJobs
            .Where(j => j.Id == job.Id && j.Status == "Pending" && (j.LeaseUntil == null || j.LeaseUntil < DateTime.UtcNow))
            .ExecuteUpdateAsync(s => s
                .SetProperty(j => j.Status, "Running")
                .SetProperty(j => j.LeaseOwner, competingOwner)
                .SetProperty(j => j.LeaseUntil, leaseUntil));

        Assert.Equal(0, competingAcquired);
    }
}
