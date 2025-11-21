using System.IdentityModel.Tokens.Jwt;
using System.Net.Http.Headers;
using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Shared.Security.Claims;
using Shared.Security.Helper;
using Shared.Security.Roles;
using Shared.Security.Scopes;
using writing_service.Contracts;
using writing_service.Features;
using writing_service.Features.Service.Admin;
using writing_service.Features.Service.User;
using writing_service.Infrastructure.Persistence;

var builder = WebApplication.CreateBuilder(args);
JwtSecurityTokenHandler.DefaultMapInboundClaims = false;

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
var connectionString = Environment.GetEnvironmentVariable("CONNECTIONSTRING__WRITING") ??
                       builder.Configuration.GetConnectionString("Writing_DB");

builder.Services.AddDbContext<WritingDbContext>(option => option.UseNpgsql(connectionString));
builder.Services.AddSwaggerGen(option =>
{
    option.SwaggerDoc("v1", new OpenApiInfo()
    {
        Title = "Attempt-service"
    });
    option.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme()
    {
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.Http,
        Scheme = "Bearer",
        BearerFormat = "JWT",
        Description = "Enter token"
    });
    option.AddSecurityRequirement(new OpenApiSecurityRequirement
    { 
        {
            new OpenApiSecurityScheme()
            {
                Reference = new OpenApiReference()
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                },
            },
            Array.Empty<string>()
        }
    }); 
});
builder.Services.AddCors(options =>
{
    options.AddPolicy("FE", policy => policy
        .WithOrigins("http://localhost:3000", "http://127.0.0.1:3000")
        .AllowAnyHeader()
        .AllowAnyMethod()
        .AllowCredentials());
});
builder.Services.AddScoped<IWritingService, WritingService>();
builder.Services.AddScoped<IAdminService, AdminService>();


builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<IUserContext, UserContext>();
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(option =>
    {
        option.MapInboundClaims = false;
        option.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidIssuer = builder.Configuration["JwtSettings:Issuer"]
                          ?? throw new Exception("valid issuer is missing"),
            ValidAudience = builder.Configuration["JwtSettings:Audience"]
                            ?? throw new Exception("valid issuer is missing"),
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(builder.Configuration["JwtSettings:SignKey"]
                                                                               ?? throw new Exception("Signing key is missing"))),
            ClockSkew = TimeSpan.Zero,
            NameClaimType = CustomClaims.Sub,
            RoleClaimType = CustomClaims.Roles
        };
    });

builder.Services.AddAuthorization(option =>
{
    option.AddPolicy(Roles.User, o => o.RequireRole(Roles.User));
    option.AddPolicy(Roles.Admin, o => o.RequireRole(Roles.Admin));
    
    option.AddPolicy(WritingScope.WritingCreate, p => p.RequireAssertion(
        o => o.User.HasAnyScope(WritingScope.WritingCreate) 
             || o.User.IsInRole(Roles.Admin)));
    option.AddPolicy(WritingScope.WritingStart, p => p.RequireAssertion(
        o => o.User.HasAnyScope(WritingScope.WritingStart) 
             || o.User.IsInRole(Roles.User)));
    option.AddPolicy(WritingScope.WritingViewOwn, p => p.RequireAssertion(
        o => o.User.HasAnyScope(WritingScope.WritingViewOwn) 
             || o.User.IsInRole(Roles.User)));
    option.AddPolicy(WritingScope.WritingViewAny, p => p.RequireAssertion(
        o => o.User.HasAnyScope(WritingScope.WritingViewAny) 
             || o.User.IsInRole(Roles.Admin)));
    
    option.AddPolicy("UserScope", p => p.RequireAssertion(
        o => o.User.HasAnyScope(WritingScope.WritingStart) 
             || o.User.HasAnyScope(WritingScope.WritingViewOwn) || o.User.IsInRole(Roles.User)));
    option.AddPolicy("AdminScope", p => p.RequireAssertion(
        o => o.User.HasAnyScope(WritingScope.WritingCreate) 
             || o.User.HasAnyScope(WritingScope.WritingViewAny) || o.User.IsInRole(Roles.Admin)));
});
builder.Services.Configure<OpenRouterOptions>(builder.Configuration.GetSection("OpenRouter"));
var openRouterSettings = builder.Configuration.GetSection("OpenRouter").Get<OpenRouterOptions>();
var apiKey = Environment.GetEnvironmentVariable("LLM__APIKEY") ?? openRouterSettings!.ApiKey ?? throw new Exception("LLM api key is missing");
builder.Services.AddHttpClient("openrouter", client =>
{
    client.BaseAddress = new Uri(openRouterSettings!.BaseUrl);
    client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", apiKey);
    if (!string.IsNullOrWhiteSpace(openRouterSettings.Referer))
        client.DefaultRequestHeaders.Add("HTTP-Referer", openRouterSettings.Referer);

    if (!string.IsNullOrWhiteSpace(openRouterSettings.Title))
        client.DefaultRequestHeaders.Add("X-Title", openRouterSettings.Title);
});


var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<WritingDbContext>();
    await db.Database.MigrateAsync();
}


// Configure the HTTP request pipeline.

app.UseSwagger();
app.UseSwaggerUI();
app.UseAuthentication();
app.UseAuthorization();

app.MapWritingEndpoint();
app.MapWritingAdminEndpoint();

app.Run();
