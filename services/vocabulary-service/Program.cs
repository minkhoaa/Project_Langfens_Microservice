using System.IdentityModel.Tokens.Jwt;
using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Shared.Security.Claims;
using Shared.Security.Helper;
using Shared.Security.Roles;
using Shared.Security.Scopes;
using vocabulary_service.Features;
using vocabulary_service.Features.Admin;
using vocabulary_service.Features.Public;
using vocabulary_service.Features.User;
using vocabulary_service.Infrastructure.Persistence;

var builder = WebApplication.CreateBuilder(args);


builder.Services.AddCors(option =>
{
    option.AddPolicy("FE", policy => policy
        .WithOrigins("http://localhost:3000", "http://127.0.0.1:3000")
        .AllowAnyHeader()
        .AllowAnyMethod()
        .AllowCredentials());
});
JwtSecurityTokenHandler.DefaultMapInboundClaims = false;
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(option =>
    {
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
builder.Services.AddAuthorization(options =>
{
    options.FallbackPolicy = new AuthorizationPolicyBuilder()
        .RequireAuthenticatedUser().Build();
    options.AddPolicy(Roles.User, p => p.RequireRole(Roles.User));
    options.AddPolicy(Roles.Admin, p => p.RequireRole(Roles.Admin));

    options.AddPolicy(VocabScope.VocabRead, p => p.RequireAssertion(c =>
        c.User.HasAnyScope(VocabScope.VocabRead) || c.User.IsInRole(Roles.User)));
    options.AddPolicy(VocabScope.VocabManage, p => p.RequireAssertion(c =>
        c.User.HasAnyScope(VocabScope.VocabManage) || c.User.IsInRole(Roles.Admin)));

});
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(option =>
{
    option.SwaggerDoc("v1", new OpenApiInfo { Title = "Vocabulary Service", Version = "1.0" });
    option.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
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
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});
builder.Services.AddDbContext<VocabularyDbContext>(option => option.UseNpgsql(
    Environment.GetEnvironmentVariable("CONNECTIONSTRING__VOCABULARY") ??
    builder.Configuration.GetConnectionString("Vocabulary_DB") ??
    "Host=localhost;Port=5437;Database=vocabulary-db;Username=vocabulary;Password=vocabulary"
));
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IPublicService, PublicService>();
builder.Services.AddScoped<IAdminService, AdminService>();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();
app.UseCors("FE");
app.UseAuthentication();
app.UseAuthorization();
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<VocabularyDbContext>();
    await db.Database.MigrateAsync();
}

app.MapPublicVocabularyEndpoints();
app.MapUserVocabularyEndpoints();
app.MapAdminVocabularyEndpoints();
app.Run();
