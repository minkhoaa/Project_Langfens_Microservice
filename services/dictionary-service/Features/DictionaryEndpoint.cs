using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using dictionary_service.Features.Handler;

namespace dictionary_service.Features
{
    public static class DictionaryEndpoint
    {
        public static void MapDictionaryEndpoint(this IEndpointRouteBuilder router)
        {
            var app = router.MapGroup("/api/dictionary");
            app.MapGet("/suggest", DictionaryHandler.GetSuggestsHandler);
            app.MapGet("/details/{id}", DictionaryHandler.GetDetailsHandler);
            app.MapPost("/import", DictionaryHandler.ImportHandler);
            app.MapPost("/reindex", DictionaryHandler.ReindexHandler);
        }
    }
}