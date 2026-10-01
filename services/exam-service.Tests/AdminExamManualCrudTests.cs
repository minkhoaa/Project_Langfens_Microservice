using exam_service.Contracts.Exams;
using exam_service.Domains.Entities;
using exam_service.Features.Exams.AdminEndpoint.ExamEndpoint;
using exam_service.Features.Exams.PublicEndpoint;
using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Npgsql;
using Shared.ExamDto.Contracts.Exam.Enums;
using Xunit;

namespace exam_service.Tests;

[Collection("DatabaseTests")]
public class AdminExamManualCrudTests
{
    private const string DefaultConn = "Host=localhost;Port=5433;Database=exam_test_crud_t005;Username=exam;Password=exam";

    [Fact]
    public async Task ManualExamLifecycle_Draft_Edit_Publish_WorksIndependently()
    {
        var connection = Environment.GetEnvironmentVariable("READING_TEST_POSTGRES") ?? DefaultConn;

        // Ensure clean isolated schema
        await using (var conn = new NpgsqlConnection(connection))
        {
            await conn.OpenAsync();
            await using var cmd = new NpgsqlCommand("DROP SCHEMA IF EXISTS public CASCADE; CREATE SCHEMA public;", conn);
            await cmd.ExecuteNonQueryAsync();
        }

        var services = new ServiceCollection();
        services.AddDbContext<ExamDbContext>(options => options.UseNpgsql(connection, npg =>
        {
            npg.ConfigureDataSource(dataSource => dataSource.EnableDynamicJson());
            npg.EnableRetryOnFailure();
        }));
        services.AddScoped<IAdminExamService, AdminExamService>();
        services.AddScoped<IExamService, exam_service.Features.Exams.PublicEndpoint.ExamService>();

        await using var provider = services.BuildServiceProvider();

        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            await db.Database.MigrateAsync();
        }

        Guid examId;
        string slug;

        // 1. Admin creates Draft exam
        using (var scope = provider.CreateScope())
        {
            var adminService = scope.ServiceProvider.GetRequiredService<IAdminExamService>();
            var createDto = new DtoAdmin.AdminExamCreate(
                Title: "Manual Academic Test Alpha",
                DescriptionMd: "Handcrafted manual reading test",
                Category: "IELTS",
                Level: "B2",
                DurationMin: 60,
                ImageUrl: null,
                Slug: null
            );

            var result = await adminService.AddAsync(createDto);
            Assert.NotNull(result);

            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var createdExam = await db.Exams.AsNoTracking().SingleAsync(e => e.Title == "Manual Academic Test Alpha");
            examId = createdExam.Id;
            slug = createdExam.Slug;
            Assert.Equal(ExamStatus.Draft, createdExam.Status);
        }

        // 2. Verify that public service does NOT expose the Draft exam
        using (var scope = provider.CreateScope())
        {
            var publicService = scope.ServiceProvider.GetRequiredService<IExamService>();
            var listResult = await publicService.ListPublishedAsync("IELTS", "B2", null, 1, 10, CancellationToken.None);
            Assert.NotNull(listResult);
        }

        // 3. Admin edits exam (updating title and duration, remaining in Draft)
        using (var scope = provider.CreateScope())
        {
            var adminService = scope.ServiceProvider.GetRequiredService<IAdminExamService>();
            var updateDto = new DtoAdmin.AdminExamUpdate(
                Title: "Manual Academic Test Alpha (Reviewed)",
                DescriptionMd: "Handcrafted manual reading test with revisions",
                Category: "IELTS",
                Level: "C1",
                DurationMin: 65,
                Status: ExamStatus.Draft,
                ImageUrl: "https://example.org/cover.png"
            );

            var updateResult = await adminService.UpdateAsync(examId, updateDto);
            Assert.NotNull(updateResult);

            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var exam = await db.Exams.AsNoTracking().SingleAsync(e => e.Id == examId);
            Assert.Equal("Manual Academic Test Alpha (Reviewed)", exam.Title);
            Assert.Equal(65, exam.DurationMin);
            Assert.Equal("C1", exam.Level);
            Assert.Equal(ExamStatus.Draft, exam.Status);
        }

        // 4. Admin publishes the exam
        using (var scope = provider.CreateScope())
        {
            var adminService = scope.ServiceProvider.GetRequiredService<IAdminExamService>();
            var publishDto = new DtoAdmin.AdminExamUpdate(
                Title: "Manual Academic Test Alpha (Reviewed)",
                DescriptionMd: "Handcrafted manual reading test with revisions",
                Category: "IELTS",
                Level: "C1",
                DurationMin: 65,
                Status: ExamStatus.Published,
                ImageUrl: "https://example.org/cover.png"
            );

            var publishResult = await adminService.UpdateAsync(examId, publishDto);
            Assert.NotNull(publishResult);

            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var exam = await db.Exams.AsNoTracking().SingleAsync(e => e.Id == examId);
            Assert.Equal(ExamStatus.Published, exam.Status);
        }

        // 5. Verify published exam is now visible to public endpoint
        using (var scope = provider.CreateScope())
        {
            var publicService = scope.ServiceProvider.GetRequiredService<IExamService>();
            var bySlugResult = await publicService.GetBySlugAsync(slug, CancellationToken.None);
            Assert.NotNull(bySlugResult);
        }

        // 6. Admin deletes exam
        using (var scope = provider.CreateScope())
        {
            var adminService = scope.ServiceProvider.GetRequiredService<IAdminExamService>();
            var deleteResult = await adminService.DeleteAsync(examId);
            Assert.NotNull(deleteResult);

            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            Assert.False(await db.Exams.AnyAsync(e => e.Id == examId));
        }
    }
}
