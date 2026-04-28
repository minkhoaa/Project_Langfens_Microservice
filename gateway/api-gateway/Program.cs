using Yarp.ReverseProxy.Configuration;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddLangfensAuth(builder.Configuration);
builder.Services.AddLangfensCors();
builder.Services.AddLangfensSwagger("API Gateway");

builder.Services
    .AddReverseProxy()
    .LoadFromConfig(builder.Configuration.GetSection("ReverseProxy"))
    .ConfigureHttpClient((context, handler) =>
    {
        // Recreate the pooled connection every 30s so DNS is re-resolved.
        // Without this, YARP caches the upstream IP for the lifetime of the
        // process. When a service container is recreated (compose up -d, restart)
        // it gets a new IP and the gateway keeps trying the old one, surfacing
        // as: "Name does not resolve (writing-service:8080)".
        handler.PooledConnectionLifetime = TimeSpan.FromSeconds(30);
    });

var app = builder.Build();

app.UseCors("FE");
app.UseAuthentication();
app.UseAuthorization();
app.MapReverseProxy();
app.Run();

public partial class Program { }
