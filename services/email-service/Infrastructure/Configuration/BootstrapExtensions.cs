using Microsoft.Extensions.Options;

namespace Microsoft.Extensions.DependencyInjection;

// u2500u2500u2500 Config models u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500

public class SmtpOptions
{
    public string Host { get; set; } = "smtp.gmail.com";
    public int Port { get; set; } = 587;
    public string User { get; set; } = string.Empty;
    public string Pass { get; set; } = string.Empty;
    public string From { get; set; } = "No-Reply <no-reply@example.com>";
    public string Brand { get; set; } = "Langfens English";
    public string Support { get; set; } = "support@langfens-english.com";
    public string VerifyUrlTemplate { get; set; } = "http://auth-service:8080/api/auth/verify";
    public string RedirectUrl { get; set; } = "http://localhost:8080/api/auth/verify";
}

// u2500u2500u2500 Bootstrap extensions (email-service specific) u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500

public static class EmailBootstrapExtensions
{
    // u2500u2500 SMTP config u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500

    public static IServiceCollection AddSmtpConfig(
        this IServiceCollection services,
        Func<string, string?> getEnv)
    {
        services.Configure<SmtpOptions>(o =>
        {
            o.Host            = getEnv("SMTP__HOST") ?? "smtp.gmail.com";
            o.Port            = int.TryParse(getEnv("SMTP__PORT"), out var p) ? p : 587;
            o.User            = getEnv("SMTP__USER") ?? string.Empty;
            o.Pass            = getEnv("SMTP__PASS") ?? string.Empty;
            o.From            = getEnv("SMTP__FROM") ?? "No-Reply <no-reply@example.com>";
            o.Brand           = getEnv("SMTP__BRAND") ?? "Langfens English";
            o.Support         = getEnv("SMTP__SUPPORT") ?? "support@langfens-english.com";
            o.VerifyUrlTemplate = getEnv("SMTP__VERIFYURLTEMPLATE")
                ?? "http://auth-service:8080/api/auth/verify";
            o.RedirectUrl     = getEnv("SMTP__REDIRECTURL")
                ?? "http://localhost:8080/api/auth/verify";
        });
        return services;
    }
}
