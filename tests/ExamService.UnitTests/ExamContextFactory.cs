using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using System.Text.Json;
using exam_service.Domains.Entities;

using Microsoft.EntityFrameworkCore.Diagnostics;

namespace ExamService.UnitTests;

public static class ExamContextFactory
{
    public static ExamDbContext CreateInMemory()
    {
        var options = new DbContextOptionsBuilder<ExamDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .ConfigureWarnings(x => x.Ignore(InMemoryEventId.TransactionIgnoredWarning))
            .EnableSensitiveDataLogging()
            .Options;
        return new TestExamDbContext(options);
    }

    private class TestExamDbContext : ExamDbContext
    {
        public TestExamDbContext(DbContextOptions<ExamDbContext> options) : base(options)
        {
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            var jsonOptions = new JsonSerializerOptions();

            modelBuilder.Entity<ExamQuestion>(e =>
            {
                e.Property(x => x.BlankAcceptTexts).HasConversion(
                    v => JsonSerializer.Serialize(v, jsonOptions),
                    v => JsonSerializer.Deserialize<Dictionary<string, string[]?>>(v, jsonOptions)
                );

                e.Property(x => x.BlankAcceptRegex).HasConversion(
                    v => JsonSerializer.Serialize(v, jsonOptions),
                    v => JsonSerializer.Deserialize<Dictionary<string, string[]?>>(v, jsonOptions)
                );

                e.Property(x => x.MatchPairs).HasConversion(
                    v => JsonSerializer.Serialize(v, jsonOptions),
                    v => JsonSerializer.Deserialize<Dictionary<string, string[]?>>(v, jsonOptions)
                );

                e.Property(x => x.OrderCorrects).HasConversion(
                    v => JsonSerializer.Serialize(v, jsonOptions),
                    v => JsonSerializer.Deserialize<List<string>>(v, jsonOptions)
                );

                e.Property(x => x.ShortAnswerAcceptTexts).HasConversion(
                    v => JsonSerializer.Serialize(v, jsonOptions),
                    v => JsonSerializer.Deserialize<List<string>>(v, jsonOptions)
                );

                e.Property(x => x.ShortAnswerAcceptRegex).HasConversion(
                    v => JsonSerializer.Serialize(v, jsonOptions),
                    v => JsonSerializer.Deserialize<List<string>>(v, jsonOptions)
                );
            });
        }
    }
}
