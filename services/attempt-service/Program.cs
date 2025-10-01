using System.Text;
using System.Text.Json;
using attempt_service.Features.Attempt;
using attempt_service.Features.Attempt.AttemptEndpoint;
using attempt_service.Features.Helpers;
using attempt_service.Infrastructure.Persistence;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Shared.Grpc.ExamInternal;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddGrpcClient<ExamInternal.ExamInternalClient>(option =>
{
    option.Address = new Uri("http://exam-service:8080");
});

builder.Services.Configure<JwtSettings>
    (builder.Configuration.GetSection("JwtSettings"));
var jwtSettings = builder.Configuration.GetSection("JwtSettings").Get<JwtSettings>();
builder.Services.AddDbContext<AttemptDbContext>(option => option.UseNpgsql(
    Environment.GetEnvironmentVariable("CONNECTIONSTRING__ATTEMPT")
    ?? builder.Configuration.GetConnectionString("Attempt_DB")
));
builder.Services.AddHttpClient("ExamServiceInternal", (sp, http) =>
{
    var cfg = sp.GetRequiredService<IConfiguration>();
    var baseExamAddress = Environment.GetEnvironmentVariable("EXAMSERVICE__EXAM__ADDRESS")
                          ?? cfg["ExamService:Exam_BaseAddress"]
                          ?? "http://examservice:8080";
    var internalApiKey = Environment.GetEnvironmentVariable("EXAMSERVICE__INTERNAL__API__KEY")
                         ?? cfg["ExamService:Exam_Internal_Api_Key"];
    Console.Write(baseExamAddress + "  " + internalApiKey);
    http.BaseAddress = new Uri(baseExamAddress);
    http.DefaultRequestHeaders.Add("X-Internal-Key", internalApiKey);
});




// DI
builder.Services.AddScoped<IAttemptService, AttemptService>();
builder.Services.AddScoped<IExamGateway, ExamGateway>();



builder.Services.ConfigureHttpJsonOptions(option =>
{
    option.SerializerOptions.PropertyNameCaseInsensitive = true;
    option.SerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
});

builder.Services.AddAuthentication(option =>
{
    option.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    option.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
}).AddJwtBearer(options =>
{
    options.SaveToken = true;
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateIssuerSigningKey = true,
        ValidateLifetime = true,
        ValidAudience = jwtSettings!.Audience,
        ValidIssuer = jwtSettings.Issuer,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSettings.SignKey)),
        ClockSkew = TimeSpan.Zero
    };
    options.MapInboundClaims = false;
});




builder.Services.AddAuthorization();



var app = builder.Build();





using (var scope = app.Services.CreateScope())
{
    var db      = scope.ServiceProvider.GetRequiredService<AttemptDbContext>();
    var all     = (db.Database.GetMigrations()).ToList();
    var applied = (await db.Database.GetAppliedMigrationsAsync()).ToList();
    var pending = (await db.Database.GetPendingMigrationsAsync()).ToList();
    Console.WriteLine($"[EF] All:     {string.Join(", ", all)}");
    Console.WriteLine($"[EF] Applied: {string.Join(", ", applied)}");
    Console.WriteLine($"[EF] Pending: {string.Join(", ", pending)}");
    await db.Database.MigrateAsync();
}



app.UseSwagger();
app.UseSwaggerUI();
app.MapAttemptEndpoint();

app.UseHttpsRedirection();

app.Run();



