using System.Net.Http.Headers;

namespace LangfensEnglish.Tests.Common.Auth;

public static class AuthHeaderExtensions
{
    public static HttpClient WithBearer(this HttpClient client, string? token)
    {
        if (!string.IsNullOrWhiteSpace(token))
        {
            client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);
        }

        return client;
    }
}
