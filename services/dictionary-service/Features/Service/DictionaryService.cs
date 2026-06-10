using System.IO.Compression;
using System.Text.Json;
using dictionary_service.Contracts;
using dictionary_service.Domains.Entities;
using dictionary_service.Features.Helper;
using dictionary_service.Infrastructure.Persistence;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;

namespace dictionary_service.Features.Service
{
    public interface IDictionaryService
    {
        Task<IResult> GetSuggests(string word, string? pos, CancellationToken token);
        Task<IResult> GetDetails(int id, CancellationToken token);
        Task<IResult> LookupWord(string word, CancellationToken token);
        Task<IResult> Import(IFormFile file, int? maxLines, CancellationToken ct);
    }

    public class DictionaryService : IDictionaryService
    {
        private readonly DictionaryDbContext _context;
        private readonly IDictionaryDtoMapper _mapper;

        public DictionaryService(DictionaryDbContext context, IDictionaryDtoMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public async Task<IResult> GetDetails(int id, CancellationToken token)
        {
            var entry = await _context.Dictionary.AsNoTracking()
                .FirstOrDefaultAsync(x => x.Id == id, token);

            if (entry is null)
                return Results.NotFound(new { id });

            var doc = DictionaryDoc.FromEntity(entry);
            var dto = await _mapper.ToDetailsDtoAsync(doc, maxSenses: 10, maxExamplesPerSense: 2, token);
            return Results.Ok(dto);
        }

        public async Task<IResult> GetSuggests(string word, string? pos, CancellationToken token)
        {
            if (string.IsNullOrWhiteSpace(word))
                return Results.BadRequest("q is required");

            var norm = word.Trim().ToLowerInvariant();
            var prefix = norm + "%";

            // Cheap prefix + contains search on WordNorm. For huge tables add pg_trgm GIN later.
            IQueryable<DictionaryEntry> q = _context.Dictionary.AsNoTracking()
                .Where(x => x.WordNorm.StartsWith(norm) || x.WordNorm.Contains(norm));

            if (!string.IsNullOrWhiteSpace(pos))
                q = q.Where(x => x.Pos == pos);

            var rows = await q
                .OrderBy(x => x.WordNorm == norm ? 0 : 1)
                .ThenBy(x => x.WordNorm.Length)
                .ThenBy(x => x.WordNorm)
                .Take(string.IsNullOrWhiteSpace(pos) ? 10 : 20)
                .Select(x => new { x.Id, x.Word, x.Pos, score = 1.0 })
                .ToListAsync(token);

            return Results.Ok(rows);
        }

        public async Task<IResult> LookupWord(string word, CancellationToken token)
        {
            if (string.IsNullOrWhiteSpace(word))
                return Results.BadRequest("word is required");

            var norm = word.Trim().ToLowerInvariant();

            // Exact match first
            var entry = await _context.Dictionary.AsNoTracking()
                .FirstOrDefaultAsync(x => x.WordNorm == norm, token);

            // Fallback to a single best match (prefix preferred, else contains)
            if (entry is null)
            {
                entry = await _context.Dictionary.AsNoTracking()
                    .Where(x => x.WordNorm.StartsWith(norm))
                    .OrderBy(x => x.WordNorm.Length)
                    .FirstOrDefaultAsync(token);
            }

            if (entry is null)
                return Results.NotFound(new { word, message = "Word not found" });

            var doc = DictionaryDoc.FromEntity(entry);
            var dto = await _mapper.ToDetailsDtoAsync(doc, maxSenses: 5, maxExamplesPerSense: 2, token);
            return Results.Ok(dto);
        }

        public async Task<IResult> Import(IFormFile file, int? maxLines, CancellationToken ct)
        {
            if (file is null || file.Length == 0)
                return Results.BadRequest("file is empty");

            var isGz =
                file.FileName.EndsWith(".gz", StringComparison.OrdinalIgnoreCase) ||
                string.Equals(file.ContentType, "application/gzip", StringComparison.OrdinalIgnoreCase) ||
                string.Equals(file.ContentType, "application/x-gzip", StringComparison.OrdinalIgnoreCase);

            const int batchSize = 100;
            long read = 0, imported = 0, skipped = 0;

            _context.ChangeTracker.AutoDetectChangesEnabled = false;

            await using var uploadStream = file.OpenReadStream();
            Stream baseStream = uploadStream;
            if (isGz) baseStream = new GZipStream(uploadStream, CompressionMode.Decompress);

            using var sr = new StreamReader(baseStream);

            var batch = new List<DictionaryEntry>(batchSize);

            while (!sr.EndOfStream && !ct.IsCancellationRequested)
            {
                if (maxLines is not null && read >= maxLines.Value) break;

                var line = await sr.ReadLineAsync();
                read++;

                if (string.IsNullOrWhiteSpace(line)) { skipped++; continue; }

                try
                {
                    using var doc = JsonDocument.Parse(line);
                    var root = doc.RootElement;

                    if (!root.TryGetProperty("word", out var wProp)) { skipped++; continue; }
                    var word = wProp.GetString();
                    if (string.IsNullOrWhiteSpace(word)) { skipped++; continue; }

                    var pos = root.TryGetProperty("pos", out var pProp)
                        ? (pProp.GetString() ?? "unknown")
                        : "unknown";

                    batch.Add(new DictionaryEntry
                    {
                        Word = word!,
                        WordNorm = word!.Trim().ToLowerInvariant(),
                        Pos = pos,
                        Data = root.Clone(),
                        ImportedAt = DateTimeOffset.UtcNow
                    });

                    if (batch.Count >= batchSize)
                    {
                        _context.AddRange(batch);
                        await _context.SaveChangesAsync(ct);
                        imported += batch.Count;

                        batch.Clear();
                        _context.ChangeTracker.Clear();
                    }
                }
                catch
                {
                    skipped++;
                }
            }

            if (batch.Count > 0)
            {
                _context.AddRange(batch);
                await _context.SaveChangesAsync(ct);
                imported += batch.Count;

                batch.Clear();
                _context.ChangeTracker.Clear();
            }

            return Results.Ok(new { read, imported, skipped, batchSize, file = file.FileName, gzip = isGz });
        }
    }
}
