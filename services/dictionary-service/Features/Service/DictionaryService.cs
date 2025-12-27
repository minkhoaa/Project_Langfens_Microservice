using System.IO.Compression;
using System.Text.Json;
using dictionary_service.Contracts;
using dictionary_service.Domains.Entities;
using dictionary_service.Features.Helper;
using dictionary_service.Infrastructure.Persistence;
using Elastic.Clients.Elasticsearch;
using Microsoft.AspNetCore.Http;

namespace dictionary_service.Features.Service
{
    public interface IDictionaryService
    {
        Task<IResult> GetSuggests(string word, string? pos, CancellationToken token);
        Task<IResult> GetDetails(int id, CancellationToken token);
        Task<IResult> LookupWord(string word, CancellationToken token);
        Task<IResult> Reindex(int? batchSize, ElasticIndexer indexer, CancellationToken ct);
        Task<IResult> Import(IFormFile file, int? maxLines, CancellationToken ct);

    }
    public class DictionaryService : IDictionaryService
    {
        private readonly ElasticsearchClient _elasticSearch;
        private readonly IConfiguration _configuration;
        private readonly DictionaryDbContext _context;
        private readonly IDictionaryDtoMapper _mapper;
        private readonly string _index;
        public DictionaryService(ElasticsearchClient elasticsearch,
        IDictionaryDtoMapper mapper,
        DictionaryDbContext context,
        IConfiguration configuration)
        {
            _mapper = mapper;
            _context = context;
            _configuration = configuration;
            _elasticSearch = elasticsearch;
            _index = Environment.GetEnvironmentVariable("ELASTICSEARCH__INDEXALIAS") ?? configuration["Elasticsearch:IndexAlias"]!;
        }

        public async Task<IResult> GetDetails(int id, CancellationToken token)
        {
            var resp = await _elasticSearch.GetAsync<DictionaryDoc>(id, g => g.Index(_index), token);

            if (!resp.IsValidResponse || resp.Source is null)
                return Results.NotFound(new { id });

            var dto = await _mapper.ToDetailsDtoAsync(resp.Source, maxSenses: 10, maxExamplesPerSense: 2, token);
            return Results.Ok(dto);

        }

        public async Task<IResult> GetSuggests(string word, string? pos, CancellationToken token)
        {
            if (string.IsNullOrWhiteSpace(word))
                return Results.BadRequest("q is required");


            var resp = string.IsNullOrWhiteSpace(pos)
                ? await _elasticSearch.SearchAsync<DictionaryDoc>(s => s
                    .Indices(_index)
                    .Size(10)
                    .TrackTotalHits(false)
                    .Query(qry => qry.MultiMatch(mm => mm
                        .Query(word)
                        .Type(Elastic.Clients.Elasticsearch.QueryDsl.TextQueryType.BoolPrefix)
                        .Fields(new[] { "wordNorm", "wordNorm._2gram", "wordNorm._3gram" })
                    )), token)
                : await _elasticSearch.SearchAsync<DictionaryDoc>(s => s
                    .Indices(_index)
                    .Size(20)
                    .Query(qry => qry.Bool(b => b
                        .Filter(f => f.Term(t => t.Field("pos").Value(pos!)))
                        .Must(m => m.MultiMatch(mm => mm
                            .Query(word)
                            .Type(Elastic.Clients.Elasticsearch.QueryDsl.TextQueryType.BoolPrefix)
                            .Fields(new[] { "wordNorm", "wordNorm._2gram", "wordNorm._3gram" })
                        ))
                    )), token);
            if (!resp.IsValidResponse)
                return Results.Problem(resp.ElasticsearchServerError?.Error?.Reason ?? "Elasticsearch error");

            var result = resp.Hits
                .Where(h => h.Source is not null)
                .Select(h => new
                {
                    id = h.Source!.Id,
                    word = h.Source.Word,
                    pos = h.Source.Pos,
                    score = h.Score
                });
            return Results.Ok(result);
        }

        public async Task<IResult> LookupWord(string word, CancellationToken token)
        {
            if (string.IsNullOrWhiteSpace(word))
                return Results.BadRequest("word is required");

            var normalizedWord = word.Trim().ToLowerInvariant();

            // Search for exact match first
            var resp = await _elasticSearch.SearchAsync<DictionaryDoc>(s => s
                .Indices(_index)
                .Size(1)
                .TrackTotalHits(false)
                .Query(qry => qry.Bool(b => b
                    .Should(
                        sh => sh.Term(t => t.Field("wordNorm").Value(normalizedWord)),
                        sh => sh.Match(m => m.Field("wordNorm").Query(normalizedWord))
                    )
                    .MinimumShouldMatch(1)
                )), token);

            if (!resp.IsValidResponse)
                return Results.Problem(resp.ElasticsearchServerError?.Error?.Reason ?? "Elasticsearch error");

            var hit = resp.Hits.FirstOrDefault();
            if (hit?.Source is null)
                return Results.NotFound(new { word, message = "Word not found" });

            var dto = await _mapper.ToDetailsDtoAsync(hit.Source, maxSenses: 5, maxExamplesPerSense: 2, token);
            return Results.Ok(dto);
        }



        public async Task<IResult> Reindex(int? batchSize, ElasticIndexer indexer, CancellationToken ct)
        {
            await indexer.BulkReindexAsync(batchSize ?? 1000, ct);
            return Results.Ok(new { ok = true });
        }

        public async Task<IResult> Import(IFormFile file, int? maxLines, CancellationToken ct)
        {
            if (file is null || file.Length == 0)
                return Results.BadRequest("file is empty");

            // Giới hạn kích thước (tuỳ bạn)
            // if (file.Length > 5L * 1024 * 1024 * 1024) return Results.BadRequest("file too large");

            var isGz =
                file.FileName.EndsWith(".gz", StringComparison.OrdinalIgnoreCase) ||
                string.Equals(file.ContentType, "application/gzip", StringComparison.OrdinalIgnoreCase) ||
                string.Equals(file.ContentType, "application/x-gzip", StringComparison.OrdinalIgnoreCase);

            const int batchSize = 100; // << chunk 100 từ
            long read = 0, imported = 0, skipped = 0;

            _context.ChangeTracker.AutoDetectChangesEnabled = false;

            await using var uploadStream = file.OpenReadStream(); // streaming, không load RAM
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
                        Data = root.Clone(),                 // JsonElement clone OK
                        ImportedAt = DateTimeOffset.UtcNow
                    });

                    if (batch.Count >= batchSize)
                    {
                        _context.AddRange(batch);
                        await _context.SaveChangesAsync(ct);
                        imported += batch.Count;

                        batch.Clear();
                        _context.ChangeTracker.Clear();      // cực quan trọng
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
