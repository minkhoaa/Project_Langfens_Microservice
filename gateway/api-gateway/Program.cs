using Yarp.ReverseProxy.Configuration;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddLangfensAuth(builder.Configuration);
builder.Services.AddLangfensCors();
builder.Services.AddLangfensSwagger("API Gateway");

builder.Services.AddReverseProxy().LoadFromConfig(builder.Configuration.GetSection("ReverseProxy"));

var app = builder.Build();

app.UseCors("FE");
app.UseAuthentication();
app.UseAuthorization();
app.MapReverseProxy();
app.Run();

public partial class Program { }
