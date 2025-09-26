using System.Text.Json.Serialization;

namespace auth_service.Application.Auth;

public record RegisterDto(
    [property: JsonPropertyName("email")] string Email,
    [property: JsonPropertyName("password")]
    string Password);

public record LoginDto(
    [property: JsonPropertyName("email")] string Email,
    [property: JsonPropertyName("password")]
    string Password);

public record GoogleLoginRequest(
    [property: JsonPropertyName("idToken")]
    string? IdToken);