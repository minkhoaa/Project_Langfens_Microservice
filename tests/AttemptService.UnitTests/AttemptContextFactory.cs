using attempt_service.Domain.Entities;
using attempt_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;
using System.Text.Json;
using attempt_service.Domain.Enums;
using Microsoft.EntityFrameworkCore.Diagnostics;

namespace AttemptService.UnitTests
{
    public static class AttemptContextFactory
    {
        public static AttemptDbContext CreateInMemory()
        {
            var options = new DbContextOptionsBuilder<AttemptDbContext>()
                .UseInMemoryDatabase(Guid.NewGuid().ToString())
                .ConfigureWarnings(x => x.Ignore(InMemoryEventId.TransactionIgnoredWarning))
                .Options;

            var context = new TestAttemptDbContext(options);
            context.Database.EnsureCreated();
            return context;
        }

        // Subclass to override OnModelCreating for InMemory-incompatible features (like JSONB)
        private class TestAttemptDbContext : AttemptDbContext
        {
            public TestAttemptDbContext(DbContextOptions<AttemptDbContext> options) : base(options) { }

            protected override void OnModelCreating(ModelBuilder modelBuilder)
            {
                base.OnModelCreating(modelBuilder);

                // Configure ValueConverters for types not supported natively by InMemory (e.g., JsonDocument, arrays)
                
                // Keep it simple if possible, or adapt from ExamService if complex types exist.
                // Attempt.PaperJson is JsonDocument
                var jsonDocumentConverter = new ValueConverter<JsonDocument?, string>(
                    v => v != null ? v.RootElement.GetRawText() : "{}",
                    v => !string.IsNullOrEmpty(v) ? JsonDocument.Parse(v, default) : JsonDocument.Parse("{}", default)
                );

                modelBuilder.Entity<Attempt>(e =>
                {
                    e.Property(p => p.PaperJson).HasConversion(jsonDocumentConverter);
                    // e.Property(x => x.Status).HasConversion<string>(); // Enum usually works, but explicit conversion helps. 
                    // AttemptDbContext already sets MaxLength(16), implying string storage?
                    // Let's check AttemptDbContext.cs again. It sets MaxLength(16) but doesn't explicitly HasConversion<string> in the snippet I saw?
                    // "a.Property(x => x.Status).HasColumnName("status").HasMaxLength(16).IsRequired();"
                    // If it's an enum, EF defaults to int unless configured. The MaxLength suggests it might be treated as string in Postgres.
                    // For InMemory, we might not strictly need conversion if it matches property type, but let's be safe if it fails.
                });

                // AttemptAnswer.SelectedOptionIds is uuid[] (Guid[])
                // InMemory doesn't support arrays well? 
                // Actually EF Core InMemory might handle simple arrays, but Postgres arrays usually need 'HasColumnType("uuid[]")' which we saw.
                // We might need to override the column type or let it be.
                // Let's assume standard behavior for now.
            }
        }
    }
}
