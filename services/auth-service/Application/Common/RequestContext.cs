using Microsoft.AspNetCore.Http;

namespace auth_service.Application.Common;

public record RequestContext(string? DeviceId, string? UserAgent, string? IpAddress, string? SessionId)
{
    public static RequestContext FromHttpContext(HttpContext httpContext)
    {
        var deviceId = httpContext.Request.Headers["X-Device-Id"].ToString();
        var userAgent = httpContext.Request.Headers.UserAgent.ToString();
        var ipAddress = httpContext.Connection.RemoteIpAddress?.ToString();
        var sessionId = httpContext.Request.Cookies["sid"];
        return new RequestContext(deviceId, userAgent, ipAddress, sessionId);
    }
}
