using System.Runtime.CompilerServices;

internal static class IntegrationTestEnv
{
    [ModuleInitializer]
    public static void Init()
    {
        Environment.SetEnvironmentVariable("JwtSettings__Issuer", "test-issuer");
        Environment.SetEnvironmentVariable("JwtSettings__Audience", "test-audience");
        Environment.SetEnvironmentVariable("JwtSettings__SignKey", "0123456789abcdef0123456789abcdef");
    }
}
