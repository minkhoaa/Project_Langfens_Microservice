using System.Net.Http.Json;

namespace LangfensEnglish.Tests.Common.Http;

public record ApiResponse<T>(bool Success, string Message, T? Data);

public static class HttpJsonExtensions
{
    public static async Task<ApiResponse<T>?> ReadApiResponseAsync<T>(this HttpResponseMessage response,
        CancellationToken ct = default)
    {
        return await response.Content.ReadFromJsonAsync<ApiResponse<T>>(cancellationToken: ct);
    }

    public static async Task<HttpResponseMessage> PostAsJsonWithRetryAsync<T>(
        this HttpClient client,
        string uri,
        T payload,
        int maxRetries = 1,
        CancellationToken ct = default)
    {
        HttpResponseMessage? response = null;
        var attempt = 0;

        while (attempt <= maxRetries)
        {
            attempt++;
            try
            {
                response = await client.PostAsJsonAsync(uri, payload, ct);
                return response;
            }
            catch when (attempt <= maxRetries)
            {
                await Task.Delay(TimeSpan.FromMilliseconds(200), ct);
            }
        }

        return response!;
    }
}
