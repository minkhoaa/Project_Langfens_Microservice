using System.Net;
using System.Text;
using System.Text.Json;
using exam_service.Domains.Entities;
using exam_service.Features.ReadingPaper;
using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging.Abstractions;
using Npgsql;
using Shared.ExamDto.Contracts.Exam.Enums;
using Xunit;

namespace exam_service.Tests;
[Collection("DatabaseTests")]
public class ReadingPaperWorkerCrashSection2Tests
{
    private const string DefaultConn = "Host=localhost;Port=5433;Database=exam_test_crash_t004;Username=exam;Password=exam";

    private sealed class SectionCrashHandler(List<ReadingGeneratedSection> sections) : HttpMessageHandler
    {
        public Dictionary<int, int> Calls { get; } = new() { [1] = 0, [2] = 0, [3] = 0 };
        public bool FailOnSection3 { get; set; } = true;

        protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken ct)
        {
            var body = request.Content?.ReadAsStringAsync(ct).GetAwaiter().GetResult() ?? "";
            using var doc = JsonDocument.Parse(body);
            var index = doc.RootElement.GetProperty("index").GetInt32();
            Calls[index]++;

            if (index == 3 && FailOnSection3)
            {
                return Task.FromResult(new HttpResponseMessage(HttpStatusCode.BadGateway)
                {
                    Content = new StringContent("{\"error\":\"Simulated crash after section 2 during section 3\"}", Encoding.UTF8, "application/json")
                });
            }

            var section = sections[index - 1];
            return Task.FromResult(new HttpResponseMessage(HttpStatusCode.OK)
            {
                Content = new StringContent(JsonSerializer.Serialize(section, ReadingPaperRules.Json), Encoding.UTF8, "application/json")
            });
        }
    }

    [Fact]
    public async Task WorkerCrashAfterSection2_PreservesCheckpoints1And2_AndRetryOnlyExecutesSection3()
    {
        var connection = Environment.GetEnvironmentVariable("READING_TEST_POSTGRES") ?? DefaultConn;

        // Reset isolated schema
        await using (var conn = new NpgsqlConnection(connection))
        {
            await conn.OpenAsync();
            await using var cmd = new NpgsqlCommand("DROP SCHEMA IF EXISTS public CASCADE; CREATE SCHEMA public;", conn);
            await cmd.ExecuteNonQueryAsync();
        }

        var fixture = ReadingPaperTests.Paper();
        var handler = new SectionCrashHandler(fixture);

        var services = new ServiceCollection();
        services.AddDbContext<ExamDbContext>(options => options.UseNpgsql(connection, npg =>
        {
            npg.ConfigureDataSource(dataSource => dataSource.EnableDynamicJson());
            npg.EnableRetryOnFailure();
        }));
        services.AddHttpClient<ReadingPaperAiClient>(client =>
        {
            client.BaseAddress = new Uri("http://fake-ai/");
            client.Timeout = TimeSpan.FromSeconds(10);
        }).ConfigurePrimaryHttpMessageHandler(() => handler);

        await using var provider = services.BuildServiceProvider();

        // Apply migrations
        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            await db.Database.MigrateAsync();
        }

        // Create 3-passage job
        Guid jobId;
        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var job = new ReadingPaperJob
            {
                Topic = "Marine Ecosystem Dynamics",
                SourcesJson = JsonSerializer.Serialize(fixture.Select(x => x.Source).ToList(), ReadingPaperRules.Json)
            };
            db.ReadingPaperJobs.Add(job);
            await db.SaveChangesAsync();
            jobId = job.Id;
        }

        var worker = new ReadingPaperWorker(
            provider.GetRequiredService<IServiceScopeFactory>(),
            NullLogger<ReadingPaperWorker>.Instance
        );

        await worker.StartAsync(CancellationToken.None);
        try
        {
            // 1. Wait for worker to encounter crash on section 3
            await WaitForStatus(provider, jobId, "Failed");

            // 2. Verify Checkpoints: Section 1 & 2 MUST be preserved!
            using (var scope = provider.CreateScope())
            {
                var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
                var job = await db.ReadingPaperJobs.FirstAsync(x => x.Id == jobId);

                Assert.Equal(2, job.CompletedSections);
                Assert.Equal("Failed", job.Status);
                Assert.NotNull(job.Error);

                var savedSections = JsonSerializer.Deserialize<List<ReadingGeneratedSection>>(job.SectionsJson, ReadingPaperRules.Json);
                Assert.NotNull(savedSections);
                Assert.Equal(2, savedSections.Count);
                Assert.Equal("Passage 1", savedSections[0].Title);
                Assert.Equal("Passage 2", savedSections[1].Title);

                Assert.Equal(0, await db.Exams.CountAsync());

                // Assert calls so far: Section 1 (1 call), Section 2 (1 call), Section 3 (1 call which failed)
                Assert.Equal(1, handler.Calls[1]);
                Assert.Equal(1, handler.Calls[2]);
                Assert.Equal(1, handler.Calls[3]);

                // 3. Admin requests Retry
                handler.FailOnSection3 = false;
                job.Status = "Pending";
                job.Error = null;
                job.LeaseUntil = null;
                job.LeaseOwner = null;
                await db.SaveChangesAsync();
            }

            // 4. Wait for worker to resume and complete
            await WaitForStatus(provider, jobId, "Completed");

            // 5. Verify that ONLY Section 3 was executed during retry!
            using (var scope = provider.CreateScope())
            {
                var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
                var job = await db.ReadingPaperJobs.FirstAsync(x => x.Id == jobId);

                Assert.Equal(3, job.CompletedSections);
                Assert.Equal("Completed", job.Status);
                Assert.Null(job.Error);
                Assert.NotNull(job.ExamId);

                // Invariant: Calls for section 1 and 2 must STILL be exactly 1!
                Assert.Equal(1, handler.Calls[1]);
                Assert.Equal(1, handler.Calls[2]);
                // Calls for section 3 is now 2 (1 failed + 1 successful)
                Assert.Equal(2, handler.Calls[3]);

                // Verify Exam in DB
                var exam = await db.Exams.Include(e => e.Sections)
                    .ThenInclude(s => s.Questions)
                    .SingleAsync(e => e.Id == job.ExamId);

                Assert.Equal(ExamStatus.Draft, exam.Status);
                Assert.Equal(3, exam.Sections.Count);
                Assert.Equal(40, exam.Sections.Sum(s => s.Questions.Count));
            }
        }
        finally
        {
            await worker.StopAsync(CancellationToken.None);
        }
    }

    private static async Task WaitForStatus(ServiceProvider provider, Guid id, string expected)
    {
        using var timeout = new CancellationTokenSource(TimeSpan.FromSeconds(30));
        while (!timeout.IsCancellationRequested)
        {
            using var scope = provider.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var status = await db.ReadingPaperJobs.AsNoTracking()
                .Where(x => x.Id == id).Select(x => x.Status).FirstOrDefaultAsync(timeout.Token);
            if (status == expected) return;
            await Task.Delay(200, timeout.Token);
        }
        throw new TimeoutException($"Job {id} did not reach expected status '{expected}'");
    }
}
