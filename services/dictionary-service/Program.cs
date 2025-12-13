using System.IO.Compression;
using System.Text.Json;
using dictionary_service.Domains.Entities;
using dictionary_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);


builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
var connectionString = Environment.GetEnvironmentVariable("CONNECTIONSTRING__DICTIONARY")
                        ?? builder.Configuration.GetConnectionString("Dictionary_DB")
                        ?? "Host=localhost;Port=5443;Database=dictionary-db;Username=dictionary;Password=dictionary";
builder.Services.AddDbContext<DictionaryDbContext>(option => option.UseNpgsql(connectionString));

var app = builder.Build();




using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<DictionaryDbContext>();
    await context.Database.MigrateAsync();
}




app.UseSwagger();
app.UseSwaggerUI();



static string Norm(string s) => s.Trim().ToLowerInvariant();

app.MapGet("/health", () => Results.Ok(new { ok = true }));

// POST /import
// body: { "path": "/path/to/file.jsonl(.gz)", "gzip": true/false, "maxLines": 10000, "batchSize": 500 }
app.MapPost("/import", async (
    ImportRequest req,
    DictionaryDbContext db,
    CancellationToken ct) =>
{
    if (string.IsNullOrWhiteSpace(req.Path) || !File.Exists(req.Path))
        return Results.BadRequest("path not found");

    var isGz = req.Gzip ?? req.Path.EndsWith(".gz", StringComparison.OrdinalIgnoreCase);
    var maxLines = req.MaxLines;
    var batchSize = 500; // bạn có thể expose thêm field BatchSize nếu muốn

    long read = 0, imported = 0, skipped = 0;

    db.ChangeTracker.AutoDetectChangesEnabled = false;

    Stream baseStream = File.OpenRead(req.Path);
    if (isGz) baseStream = new GZipStream(baseStream, CompressionMode.Decompress);
    using var sr = new StreamReader(baseStream);

    var batch = new List<DictionaryEntry>(batchSize); // <-- đổi DictionaryEntry theo entity thật của bạn

    while (!sr.EndOfStream && !ct.IsCancellationRequested)
    {
        if (maxLines is not null && read >= maxLines.Value) break;

        var line = await sr.ReadLineAsync();
        read++;

        if (string.IsNullOrWhiteSpace(line))
        {
            skipped++;
            continue;
        }

        try
        {
            using var doc = JsonDocument.Parse(line);
            var root = doc.RootElement;

            if (!root.TryGetProperty("word", out var wProp))
            {
                skipped++;
                continue;
            }

            var word = wProp.GetString();
            if (string.IsNullOrWhiteSpace(word))
            {
                skipped++;
                continue;
            }

            var pos = root.TryGetProperty("pos", out var pProp)
                ? (pProp.GetString() ?? "unknown")
                : "unknown";

            batch.Add(new DictionaryEntry
            {
                Word = word,
                WordNorm = Norm(word),
                Pos = pos,
                Data = line, // lưu nguyên 1 dòng JSONL vào jsonb/string
                ImportedAt = DateTimeOffset.UtcNow
            });

            if (batch.Count >= batchSize)
            {
                db.AddRange(batch);
                await db.SaveChangesAsync(ct);
                imported += batch.Count;

                batch.Clear();
                db.ChangeTracker.Clear(); // cực quan trọng để không ngốn RAM
            }
        }
        catch
        {
            skipped++;
        }
    }

    if (batch.Count > 0)
    {
        db.AddRange(batch);
        await db.SaveChangesAsync(ct);
        imported += batch.Count;

        batch.Clear();
        db.ChangeTracker.Clear();
    }

    return Results.Ok(new { read, imported, skipped, batchSize });
});


app.Run();

public sealed record ImportRequest(string Path, bool? Gzip, int? MaxLines);
