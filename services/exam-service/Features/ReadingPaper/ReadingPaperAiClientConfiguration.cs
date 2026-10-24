using Microsoft.Extensions.Configuration;

namespace exam_service.Features.ReadingPaper;

internal static class ReadingPaperAiClientConfiguration
{
    internal static string ResolveInternalApiKey(IConfiguration configuration)
    {
        ArgumentNullException.ThrowIfNull(configuration);

        return configuration["EXAMSERVICE:INTERNAL:API:KEY"]
               ?? configuration["EXAMSERVICE__INTERNAL__API__KEY"]
               ?? configuration["INTERNAL_API_KEY"]
               ?? configuration["InternalApiKey"]
               ?? configuration["Parameters:internal-api-key"]
               ?? string.Empty;
    }
}
