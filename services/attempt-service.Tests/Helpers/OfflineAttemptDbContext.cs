using System.Text.Json;
using attempt_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;

namespace attempt_service.Tests.Helpers;

internal sealed class OfflineAttemptDbContext() : AttemptDbContext(
    new DbContextOptionsBuilder<AttemptDbContext>().UseInMemoryDatabase(Guid.NewGuid().ToString()).Options)
{
    protected override void OnModelCreating(ModelBuilder model)
    {
        base.OnModelCreating(model);
        foreach (var property in model.Model.GetEntityTypes().SelectMany(e => e.GetProperties())
                     .Where(p => p.ClrType == typeof(JsonDocument)))
            property.SetValueConverter(new ValueConverter<JsonDocument, string>(
                value => value.RootElement.GetRawText(), value => JsonDocument.Parse(value, default(JsonDocumentOptions))));
    }
}
