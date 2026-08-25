using email_service.Features.Handler;

namespace email_service.Features;

public static class EmailEndpoint
{
    public static void MapEmailEndpoint(this IEndpointRouteBuilder app)
    {
        app.MapGroup("/api").MapGet("/verify-email", EmailSenderHandler.VerifyEmailHandler);
    }
}