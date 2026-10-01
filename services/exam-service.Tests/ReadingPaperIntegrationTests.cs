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
using Xunit;

namespace exam_service.Tests;
[Collection("DatabaseTests")]
public class ReadingPaperIntegrationTests
{
    [Fact]
    public async Task FailedSecondSectionResumesWithoutPartialOrDuplicateExam()
    {
        var connection = Environment.GetEnvironmentVariable("READING_TEST_POSTGRES");
        if (string.IsNullOrWhiteSpace(connection))
            return; // optional isolated PostgreSQL integration gate

        await using (var safety = new NpgsqlConnection(connection))
        {
            await safety.OpenAsync();
            await using var command = new NpgsqlCommand(
                "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public'", safety);
            if (Convert.ToInt32(await command.ExecuteScalarAsync()) != 0)
                throw new InvalidOperationException("Integration test requires an empty isolated PostgreSQL database");
        }

        var fixture = ReadingPaperTests.Paper();
        var handler = new SectionHandler(fixture);
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
        Guid jobId;
        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            Assert.True(db.Database.CreateExecutionStrategy().RetriesOnFailure);
            await db.Database.MigrateAsync();
            var job = new ReadingPaperJob
            {
                Topic = "forest", SourcesJson = JsonSerializer.Serialize(fixture.Select(x => x.Source).ToList(), ReadingPaperRules.Json)
            };
            db.ReadingPaperJobs.Add(job);
            await db.SaveChangesAsync();
            jobId = job.Id;
        }

        var worker = new ReadingPaperWorker(provider.GetRequiredService<IServiceScopeFactory>(),
            NullLogger<ReadingPaperWorker>.Instance);
        await worker.StartAsync(CancellationToken.None);
        try
        {
            await WaitForStatus(provider, jobId, "Failed");
            using (var scope = provider.CreateScope())
            {
                var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
                var job = await db.ReadingPaperJobs.FirstAsync(x => x.Id == jobId);
                Assert.Equal(1, job.CompletedSections);
                Assert.Equal(0, await db.Exams.CountAsync());
                job.Status = "Pending";
                job.Error = null;
                await db.SaveChangesAsync();
            }
            await WaitForStatus(provider, jobId, "Completed");
            using (var scope = provider.CreateScope())
            {
                var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
                Assert.Equal(1, await db.Exams.CountAsync());
                Assert.Equal(3, await db.ExamSections.CountAsync());
                Assert.Equal(6, await db.ExamQuestionGroups.CountAsync());
                Assert.Equal(40, await db.ExamQuestions.CountAsync());
                Assert.Equal("DRAFT", (await db.Exams.SingleAsync()).Status);
                Assert.Equal(1, handler.Calls[1]);
                Assert.Equal(2, handler.Calls[2]);
                Assert.Equal(1, handler.Calls[3]);
            }

            Guid practiceJobId;
            using (var scope = provider.CreateScope())
            {
                var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
                var practice = new ReadingPaperJob
                {
                    Topic = "forest", SourcesJson = JsonSerializer.Serialize(new[] { fixture[0].Source }, ReadingPaperRules.Json)
                };
                db.ReadingPaperJobs.Add(practice);
                await db.SaveChangesAsync();
                practiceJobId = practice.Id;
            }
            await WaitForStatus(provider, practiceJobId, "Completed");
            using (var scope = provider.CreateScope())
            {
                var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
                var job = await db.ReadingPaperJobs.AsNoTracking().SingleAsync(x => x.Id == practiceJobId);
                var practice = await db.Exams.Include(x => x.Sections)
                    .ThenInclude(x => x.Questions).SingleAsync(x => x.Id == job.ExamId);
                Assert.Single(practice.Sections);
                Assert.Equal(13, practice.Sections.Single().Questions.Count);
                Assert.Equal(20, practice.DurationMin);
                Assert.Equal("DRAFT", practice.Status);
            }
        }
        finally { await worker.StopAsync(CancellationToken.None); }
    }

    private static async Task WaitForStatus(ServiceProvider provider, Guid id, string expected)
    {
        using var timeout = new CancellationTokenSource(TimeSpan.FromSeconds(45));
        while (!timeout.IsCancellationRequested)
        {
            using var scope = provider.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var status = await db.ReadingPaperJobs.AsNoTracking().Where(x => x.Id == id)
                .Select(x => x.Status).SingleAsync(timeout.Token);
            if (status == expected) return;
            await Task.Delay(250, timeout.Token);
        }
        throw new TimeoutException($"Job did not reach {expected}");
    }

    private sealed class SectionHandler(List<ReadingGeneratedSection> sections) : HttpMessageHandler
    {
        public Dictionary<int, int> Calls { get; } = new() { [1] = 0, [2] = 0, [3] = 0 };

        protected override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken ct)
        {
            using var document = JsonDocument.Parse(await request.Content!.ReadAsStringAsync(ct));
            var index = document.RootElement.GetProperty("index").GetInt32();
            Calls[index]++;
            if (index == 2 && Calls[index] == 1)
                return new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                { Content = new StringContent("{\"detail\":\"temporary source outage\"}", Encoding.UTF8, "application/json") };
            return new HttpResponseMessage(HttpStatusCode.OK)
            { Content = new StringContent(JsonSerializer.Serialize(sections[index - 1], ReadingPaperRules.Json),
                Encoding.UTF8, "application/json") };
        }
    }
}
