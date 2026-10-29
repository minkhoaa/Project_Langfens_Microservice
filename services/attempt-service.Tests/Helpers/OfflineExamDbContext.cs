using System.Text.Json;
using exam_service.Domains.Entities;
using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace attempt_service.Tests.Helpers;

// InMemory has no native jsonb mapping. Convert only the dictionary columns;
// keep the production relationships, queries, seeder, and delivery mappers.
internal sealed class OfflineExamDbContext(DbContextOptions<ExamDbContext> options) : ExamDbContext(options)
{
    public static DbContextOptions<ExamDbContext> Options(string database) =>
        new DbContextOptionsBuilder<ExamDbContext>().UseInMemoryDatabase(database).Options;

    protected override void OnModelCreating(ModelBuilder model)
    {
        base.OnModelCreating(model);
        foreach (var name in new[] { nameof(ExamQuestion.BlankAcceptTexts), nameof(ExamQuestion.BlankAcceptRegex), nameof(ExamQuestion.MatchPairs) })
            model.Entity<ExamQuestion>().Property<Dictionary<string, string[]?>?>(name).HasConversion(
                value => JsonSerializer.Serialize(value, (JsonSerializerOptions?)null),
                value => JsonSerializer.Deserialize<Dictionary<string, string[]?>>(value, (JsonSerializerOptions?)null));
    }
}
