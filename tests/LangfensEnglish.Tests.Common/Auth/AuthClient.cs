using System.Net.Http.Json;
using LangfensEnglish.Tests.Common.Http;

namespace LangfensEnglish.Tests.Common.Auth;

public sealed class AuthClient
{
    private readonly HttpClient _client;

    public AuthClient(HttpClient client)
    {
        _client = client;
    }

    public Task<HttpResponseMessage> RegisterAsync(string email, string password, CancellationToken ct = default) =>
        _client.PostAsJsonAsync("/api/auth/register", new { email, password }, ct);

    public Task<HttpResponseMessage> ResendOtpAsync(string email, CancellationToken ct = default) =>
        _client.PostAsync($"/api/auth/resend-otp?email={Uri.EscapeDataString(email)}", null, ct);

    public Task<HttpResponseMessage> VerifyOtpAsync(string email, string otp, CancellationToken ct = default) =>
        _client.GetAsync($"/api/auth/verify?email={Uri.EscapeDataString(email)}&otp={Uri.EscapeDataString(otp)}", ct);

    public async Task<(HttpResponseMessage Response, string? Token)> PasswordLoginAsync(string email, string password,
        CancellationToken ct = default)
    {
        var response = await _client.PostAsJsonAsync("/api/auth/login", new { email, password }, ct);
        var payload = await response.Content.ReadFromJsonAsync<ApiResponse<string>>(cancellationToken: ct);
        return (response, payload?.Data);
    }

    public async Task<(HttpResponseMessage Response, string? Token)> RefreshAsync(string? sessionId, CancellationToken ct = default)
    {
        if (!string.IsNullOrWhiteSpace(sessionId))
        {
            _client.DefaultRequestHeaders.Add("X-Session-Id", sessionId);
        }

        var response = await _client.PostAsync("/api/auth/refresh", null, ct);
        var payload = await response.Content.ReadFromJsonAsync<ApiResponse<string>>(cancellationToken: ct);
        return (response, payload?.Data);
    }
}
