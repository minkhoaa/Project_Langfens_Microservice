using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using dictionary_service.Features.Handler;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Mvc;

namespace dictionary_service.Features
{
    public static class DictionaryEndpoint
    {
        public static void MapDictionaryEndpoint(this IEndpointRouteBuilder router)
        {
            var app = router.MapGroup("/api/dictionary");
            app.MapGet("/suggest", DictionaryHandler.GetSuggestsHandler);
            app.MapGet("/details/{id}", DictionaryHandler.GetDetailsHandler);
            app.MapPost("/import", DictionaryHandler.ImportHandler).DisableAntiforgery().DisableRequestSizeLimit()
               .Accepts<IFormFile>("multipart/form-data")
               .WithMetadata(new ConsumesAttribute("multipart/form-data"));
            app.MapPost("/reindex", DictionaryHandler.ReindexHandler);
        }
    }
}
