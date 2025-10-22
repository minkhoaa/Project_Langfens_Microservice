namespace auth_service.Features.Auth;

public static class AuthEndpoints
{
    public static void MapAuthEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/auth");
        group.WithTags("Auth");
        group.MapRegisterEndpoint();
        group.MapLoginEndpoint();
        group.MapGoogleLoginEndpoint();
        group.MapRefreshEndpoint();
        group.MapLogoutEndpoint();
        group.MapMeEndpoint();
        group.MapEmailConfirmEndpoint();
        group.MapResendOtpEndpoint();
        group.MapForgotPasswordEndpoint();
        group.MapResendForgotPasswordEndpoint();
        group.MapConfirmForgotPasswordEndpoint();
    }
}