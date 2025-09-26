using Google.Apis.Auth;

namespace auth_service.Application.Common;

public interface IGoogleTokenVerifier
{
    Task<GoogleJsonWebSignature.Payload> VerifyAsync(string idToken, CancellationToken ct);
}

public class GoogleTokenVerifier : IGoogleTokenVerifier
{
    private readonly string? _clientId;

    public GoogleTokenVerifier(IConfiguration configuration)
    {
        _clientId = Environment.GetEnvironmentVariable("PUBLIC_GOOGLE_CLIENT_ID") ??
                    configuration["OAuth:PUBLIC_GOOGLE_CLIENT_ID"];
    }

    public async Task<GoogleJsonWebSignature.Payload> VerifyAsync(string idToken, CancellationToken ct)
    {
        var settings = string.IsNullOrWhiteSpace(_clientId)
            ? new GoogleJsonWebSignature.ValidationSettings()
            : new GoogleJsonWebSignature.ValidationSettings
            {
                Audience = new[] { _clientId }
            };

        return await GoogleJsonWebSignature.ValidateAsync(idToken, settings);
    }
}