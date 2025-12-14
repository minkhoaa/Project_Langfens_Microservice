using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using dictionary_service.Infrastructure.Persistence;
using Elastic.Clients.Elasticsearch;
using Elastic.Clients.Elasticsearch.Core.Bulk;
using Elastic.Clients.Elasticsearch.IndexManagement;
using Microsoft.AspNetCore.Mvc.ModelBinding.Binders;
using Microsoft.EntityFrameworkCore;

namespace dictionary_service.Features
{
    public class ElasticIndexer
    {
        private readonly DictionaryDbContext _context;
        private readonly ElasticsearchClient _elastic;
        private readonly string _index;
        public ElasticIndexer(DictionaryDbContext context, ElasticsearchClient elasticsearch, IConfiguration configuration)
        {
            _context = context;
            _elastic = elasticsearch;
            _index = configuration["Elasticsearch:IndexAlias"]!;
        }
        public async Task BulkReindexAsync(int batchSize = 1000, CancellationToken ct = default)
        {
            long lastId = 0;

            while (true)
            {
                var rows = await _context.Dictionary.AsNoTracking()
                    .Where(x => x.Id > lastId)
                    .OrderBy(x => x.Id)
                    .Take(batchSize)
                    .ToListAsync(ct);

                if (rows.Count == 0) break;

                var ops = new List<IBulkOperation>(rows.Count);

                foreach (var r in rows)
                {
                    var doc = new DictionaryDoc(r.Id, r.Word, r.WordNorm, r.Pos, r.Data, r.ImportedAt);

                    ops.Add(new BulkIndexOperation<DictionaryDoc>(doc)
                    {
                        Index = _index,
                        Id = r.Id
                    });

                    lastId = r.Id;
                }

                var resp = await _elastic.BulkAsync(new BulkRequest(_index) { Operations = ops }, ct);

                if (!resp.IsValidResponse || resp.Errors)
                {
                    var firstError = resp.ItemsWithErrors?.FirstOrDefault();
                    var reason = firstError?.Error?.Reason ?? "Unknown bulk error";
                    throw new Exception($"Bulk failed. First error: {reason}");
                }
            }

            await _elastic.Indices.RefreshAsync(new RefreshRequest(_index), ct);
        }
    }
}
public record DictionaryDoc(
    [property: JsonPropertyName("id")] long Id,
    [property: JsonPropertyName("word")] string Word,
    [property: JsonPropertyName("wordNorm")] string WordNorm,
    [property: JsonPropertyName("pos")] string Pos,
    [property: JsonPropertyName("data")] JsonElement Data,
    [property: JsonPropertyName("importedAt")] DateTimeOffset ImportedAt
);