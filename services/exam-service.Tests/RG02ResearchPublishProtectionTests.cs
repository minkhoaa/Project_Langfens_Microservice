using System.Net;
using System.Net.Http.Json;
using exam_service.Contracts.Exams;
using exam_service.Domains.Entities;
using exam_service.Features.ReadingPaper;
using exam_service.Features.ReadingPaper.Contracts;
using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Shared.ExamDto.Contracts.Exam.Enums;
using Xunit;

namespace exam_service.Tests;

[Collection("DatabaseTests")]
public class RG02ResearchPublishProtectionTests
{
    private const string DefaultConn = "Host=localhost;Port=5433;Database=exam_test_phase02;Username=exam;Password=exam";

    private async Task<(Phase14ExamApiFactory Factory, HttpClient Client)> SetupAsync()
    {
        var factory = new Phase14ExamApiFactory(DefaultConn);
        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            await db.Database.MigrateAsync();

            await db.ReadingPaperHumanFeedbacks.ExecuteDeleteAsync();
            await db.ReadingPaperRuns.ExecuteDeleteAsync();
            await db.ReadingPaperJobs.ExecuteDeleteAsync();
            await db.Exams.ExecuteDeleteAsync();
        }

        var client = factory.CreateAdminClient();
        return (factory, client);
    }

    [Fact]
    public async Task POS_RG02_S04_PrimaryPublishEndpoint_RejectsBenchmarkRun_With403()
    {
        var (factory, client) = await SetupAsync();
        await using var _ = factory;

        var examId = Guid.NewGuid();
        var jobId = Guid.NewGuid();
        var runId = $"run-bench-{Guid.NewGuid():N}"[..24];

        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();

            var exam = new Exam
            {
                Id = examId,
                Title = "Benchmark Research Exam",
                Slug = $"ielts-mock-exam-{examId:N}"[..24],
                Category = "IELTS",
                Level = "B2",
                Status = ExamStatus.Draft,
                DurationMin = 60
            };
            db.Exams.Add(exam);

            var job = new ReadingPaperJob
            {
                Id = jobId,
                Topic = "Benchmark reading topic",
                Status = "Completed",
                ExamId = examId,
                ActiveRunId = runId
            };
            db.ReadingPaperJobs.Add(job);

            var run = new ReadingPaperRun
            {
                Id = Guid.NewGuid(),
                JobId = jobId,
                RunId = runId,
                Status = "COMPLETED",
                BenchmarkCampaignId = "campaign-rq2-pilot",
                BenchmarkCaseId = "case-01"
            };
            db.ReadingPaperRuns.Add(run);

            await db.SaveChangesAsync();
        }

        var res = await client.PostAsJsonAsync($"/api/v2/reading/papers/{examId}/publish", new FeedbackEndpoints.PublishPaperPayload());
        Assert.Equal(HttpStatusCode.Forbidden, res.StatusCode);

        var body = await res.Content.ReadAsStringAsync();
        Assert.Contains("RESEARCH_PUBLICATION_FORBIDDEN", body);
    }

    [Fact]
    public async Task NEG_RG02_S04_AlternateAdminUpdateApi_RejectsBenchmarkExamPublish_With403()
    {
        var (factory, client) = await SetupAsync();
        await using var _ = factory;

        var examId = Guid.NewGuid();
        var jobId = Guid.NewGuid();
        var runId = $"run-bench-{Guid.NewGuid():N}"[..24];

        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();

            var exam = new Exam
            {
                Id = examId,
                Title = "Benchmark Research Exam Alternate Route",
                Slug = $"ielts-mock-alt-{examId:N}"[..24],
                Level = "C1",
                Status = ExamStatus.Draft,
                DurationMin = 60
            };
            db.Exams.Add(exam);

            var job = new ReadingPaperJob
            {
                Id = jobId,
                Topic = "Benchmark reading topic",
                Status = "Completed",
                ExamId = examId,
                ActiveRunId = runId
            };
            db.ReadingPaperJobs.Add(job);

            var run = new ReadingPaperRun
            {
                Id = Guid.NewGuid(),
                JobId = jobId,
                RunId = runId,
                Status = "COMPLETED",
                BenchmarkCampaignId = "campaign-rq2-pilot",
                BenchmarkCaseId = "case-02"
            };
            db.ReadingPaperRuns.Add(run);

            await db.SaveChangesAsync();
        }

        var updateDto = new DtoAdmin.AdminExamUpdate(
            Title: "Attempted Research Publish via Admin Update",
            DescriptionMd: "Description",
            Category: "IELTS",
            Level: "C1",
            DurationMin: 60,
            ImageUrl: null,
            Status: ExamStatus.Published
        );

        var res = await client.PutAsJsonAsync($"/api/admin/exam/update/{examId}", updateDto);
        Assert.Equal(HttpStatusCode.Forbidden, res.StatusCode);

        var body = await res.Content.ReadAsStringAsync();
        Assert.Contains("RESEARCH_PUBLICATION_FORBIDDEN", body);

        // Verify exam status in database was NOT changed to Published
        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var examInDb = await db.Exams.AsNoTracking().SingleAsync(e => e.Id == examId);
            Assert.Equal(ExamStatus.Draft, examInDb.Status);
        }
    }

    [Fact]
    public async Task EDGE_RG02_S04_NormalProductionExam_PublishesSuccessfully()
    {
        var (factory, client) = await SetupAsync();
        await using var _ = factory;

        var examId = Guid.NewGuid();
        var jobId = Guid.NewGuid();
        var runId = $"run-prod-{Guid.NewGuid():N}"[..24];

        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();

            var exam = new Exam
            {
                Id = examId,
                Title = "Legitimate Production Practice Exam",
                Slug = $"prod-exam-{examId:N}"[..24],
                Category = "IELTS",
                Level = "B2",
                Status = ExamStatus.Draft,
                DurationMin = 60
            };
            db.Exams.Add(exam);

            var job = new ReadingPaperJob
            {
                Id = jobId,
                Topic = "Standard Academic Reading",
                Status = "Completed",
                ExamId = examId,
                ActiveRunId = runId
            };
            db.ReadingPaperJobs.Add(job);

            var run = new ReadingPaperRun
            {
                Id = Guid.NewGuid(),
                JobId = jobId,
                RunId = runId,
                Status = "COMPLETED",
                BenchmarkCampaignId = null
            };
            db.ReadingPaperRuns.Add(run);

            await db.SaveChangesAsync();
        }

        var res = await client.PostAsJsonAsync($"/api/v2/reading/papers/{examId}/publish", new FeedbackEndpoints.PublishPaperPayload());
        Assert.Equal(HttpStatusCode.OK, res.StatusCode);

        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var examInDb = await db.Exams.AsNoTracking().SingleAsync(e => e.Id == examId);
            Assert.Equal(ExamStatus.Published, examInDb.Status);
        }
    }
}
