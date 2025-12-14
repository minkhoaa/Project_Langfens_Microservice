using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;

namespace AttemptService.UnitTests;

internal sealed class AttemptDbContextTest : AttemptDbContext
{
    public AttemptDbContextTest(DbContextOptions<AttemptDbContext> options) : base(options)
    {
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        var converter = new ValueConverter<JsonDocument?, string?>(
            v => v == null ? null : v.RootElement.GetRawText(),
            v => string.IsNullOrWhiteSpace(v) ? null : JsonDocument.Parse(v!, new JsonDocumentOptions())
        );

        modelBuilder.Entity<attempt_service.Domain.Entities.Attempt>().Property(a => a.PaperJson)
            .HasConversion(converter)
            .HasColumnType("TEXT");
    }
}
