namespace email_service.Features;

public static class EmailEndpoint
{
    public static void MapEmailEndpoint(this IEndpointRouteBuilder app)
    {
        app.MapGroup("/api/mail");
    }
}