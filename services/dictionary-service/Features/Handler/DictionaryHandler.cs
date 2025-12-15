using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Threading.Tasks;
using dictionary_service.Features.Service;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;

namespace dictionary_service.Features.Handler
{
    public static class DictionaryHandler
    {
        public static Task<IResult> GetSuggestsHandler(string word, string? pos, CancellationToken token, [FromServices] IDictionaryService service) => service.GetSuggests(word, pos, token);
        public static Task<IResult> GetDetailsHandler([FromRoute] int id, CancellationToken token, [FromServices] IDictionaryService service) => service.GetDetails(id, token);
        public static Task<IResult> ReindexHandler(int? batchSize, ElasticIndexer indexer, CancellationToken ct, [FromServices] IDictionaryService service) => service.Reindex(batchSize, indexer, ct);
        public static Task<IResult> ImportHandler(IFormFile file, int? maxLines, CancellationToken ct, [FromServices] IDictionaryService service)
            => service.Import(file, maxLines, ct);
    }
}
