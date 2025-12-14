using System.IO.Compression;
using System.Text.Json;
using dictionary_service.Domains.Entities;
using dictionary_service.Infrastructure.Persistence;
using Elastic.Clients.Elasticsearch;

namespace dictionary_service.Features.Service
{
    public interface IDictionaryService
    {
        Task<IResult> GetSuggests(string word, string? pos, CancellationToken token);
        Task<IResult> GetDetails(int id, CancellationToken token);
        Task<IResult> Reindex(int? batchSize, ElasticIndexer indexer, CancellationToken ct);
        Task<IResult> Import(ImportRequest req, CancellationToken ct);

    }
    public class DictionaryService : IDictionaryService
    {
        private readonly ElasticsearchClient _elasticSearch;
        private readonly IConfiguration _configuration;
        private readonly DictionaryDbContext _context;
        private readonly string _index;
        public DictionaryService(ElasticsearchClient elasticsearch,
        DictionaryDbContext context,
        IConfiguration configuration)
        {
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

            return Results.Ok(new
            {
                id = resp.Source.Id,
                word = resp.Source.Word,
                pos = resp.Source.Pos,
                wordNorm = resp.Source.WordNorm,
                importedAt = resp.Source.ImportedAt,
                entry = resp.Source.Data    // full JSON: forms/senses/sounds/translations/...
            });
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



        public async Task<IResult> Reindex(int? batchSize, ElasticIndexer indexer, CancellationToken ct)
        {
            await indexer.BulkReindexAsync(batchSize ?? 1000, ct);
            return Results.Ok(new { ok = true });
        }

        public async Task<IResult> Import(ImportRequest req, CancellationToken ct)
        {
            if (string.IsNullOrWhiteSpace(req.Path) || !File.Exists(req.Path))
                return Results.BadRequest("path not found");

            var isGz = req.Path.EndsWith(".gz", StringComparison.OrdinalIgnoreCase);
            var maxLines = req.MaxLines;
            var batchSize = 500;

            long read = 0, imported = 0, skipped = 0;

            _context.ChangeTracker.AutoDetectChangesEnabled = false;

            Stream baseStream = File.OpenRead(req.Path);
            if (isGz) baseStream = new GZipStream(baseStream, CompressionMode.Decompress);
            using var sr = new StreamReader(baseStream);

            var batch = new List<DictionaryEntry>(batchSize);

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
                        WordNorm = word.Trim().ToLowerInvariant(),
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
                        _context.ChangeTracker.Clear(); // cực quan trọng để không ngốn RAM
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

            return Results.Ok(new { read, imported, skipped, batchSize });
        }
    }
}
public record ImportRequest(string Path, int? MaxLines);
