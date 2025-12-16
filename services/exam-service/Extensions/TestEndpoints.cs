using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.EntityFrameworkCore;
using exam_service.Domains.Entities;
using exam_service.Infrastructure.Persistence;

namespace exam_service.Extensions;

/// <summary>
/// Test harness endpoints for E2E testing.
/// These endpoints are ONLY active in Testing environment.
/// Protected by X-Test-Secret header.
/// </summary>
public static class TestEndpoints
{
    private const string TestSecretHeader = "X-Test-Secret";

    public static void MapTestEndpoints(this IEndpointRouteBuilder app, IWebHostEnvironment env)
    {
        if (!env.IsEnvironment("Testing"))
            return;

        var testSecret = Environment.GetEnvironmentVariable("TEST_SECRET") ?? "test-key";

        var group = app.MapGroup("/__test")
            .AllowAnonymous()
            .AddEndpointFilter(async (context, next) =>
            {
                var request = context.HttpContext.Request;
                if (!request.Headers.TryGetValue(TestSecretHeader, out var secret) ||
                    !secret.Equals(testSecret))
                {
                    return Results.StatusCode(403);
                }
                return await next(context);
            });

        // POST /__test/seed - Seed sample exam data
        group.MapPost("/seed", async (ExamDbContext dbContext) =>
        {
            try
            {
                // Check if already seeded
                var existingExam = await dbContext.Exams.FirstOrDefaultAsync(e => e.Slug == "test-ielts-reading");
                if (existingExam != null)
                {
                    return Results.Ok(new { message = "Already seeded", examId = existingExam.Id });
                }

                // Create minimal test exam
                var examId = Guid.NewGuid();
                var sectionId = Guid.NewGuid();
                var questionId = Guid.NewGuid();
                
                var exam = new Exam
                {
                    Id = examId,
                    Title = "Test IELTS Reading",
                    Slug = "test-ielts-reading",
                    DescriptionMd = "Sample IELTS reading test for E2E testing",
                    DurationMin = 60,
                    Status = "Published",
                    Category = "IELTS",
                    Level = "B1"
                };

                dbContext.Exams.Add(exam);
                await dbContext.SaveChangesAsync();

                return Results.Created($"/__test/exam/{exam.Id}", new { examId = exam.Id, slug = exam.Slug });
            }
            catch (Exception ex)
            {
                return Results.Problem(ex.Message);
            }
        });

        // DELETE /__test/cleanup - Remove test data
        group.MapDelete("/cleanup", async (ExamDbContext dbContext) =>
        {
            try
            {
                var testExams = await dbContext.Exams
                    .Where(e => e.Slug != null && e.Slug.StartsWith("test-"))
                    .ToListAsync();
                
                dbContext.Exams.RemoveRange(testExams);
                await dbContext.SaveChangesAsync();
                
                return Results.Ok(new { deleted = testExams.Count });
            }
            catch (Exception ex)
            {
                return Results.Problem(ex.Message);
            }
        });

        // GET /__test/health
        group.MapGet("/health", () => Results.Ok(new { status = "ok", environment = "Testing" }));
    }
}
