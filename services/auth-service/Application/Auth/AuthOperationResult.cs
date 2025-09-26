using Shared.Contracts.Contracts;

namespace auth_service.Application.Auth;

public record SessionTicket(string SessionId, DateTimeOffset ExpiresAt);

public record AuthOperationResult(
    ApiResultDto Response,
    int StatusCode,
    SessionTicket? SessionTicket = null,
    bool ShouldClearSessionCookie = false)
{
    public static AuthOperationResult Success(ApiResultDto response, SessionTicket? sessionTicket = null) =>
        new(response, StatusCodes.Status200OK, sessionTicket);

    public static AuthOperationResult Created(ApiResultDto response, SessionTicket? sessionTicket = null) =>
        new(response, StatusCodes.Status201Created, sessionTicket);

    public static AuthOperationResult Failure(ApiResultDto response, int statusCode) =>
        new(response, statusCode);

    public static AuthOperationResult Unauthorized() =>
        new(new ApiResultDto(false, "Unauthorized", null!), StatusCodes.Status401Unauthorized);

    public AuthOperationResult WithCookie(SessionTicket? ticket) => this with { SessionTicket = ticket };

    public AuthOperationResult WithClearCookie() => this with { ShouldClearSessionCookie = true };
}