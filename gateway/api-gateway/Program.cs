using System.IdentityModel.Tokens.Jwt;
using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Shared.Security.Claims;

var builder = WebApplication.CreateBuilder(args);

builder.Services.Configure<JwtSettings>(builder.Configuration.GetSection("JwtSettings"));

var jwt = builder.Configuration.GetSection("JwtSettings").Get<JwtSettings>();

if (string.IsNullOrWhiteSpace(jwt!.SignKey))
    throw new InvalidOperationException("Required config 'JwtSettings:SignKey' is not set");
if (string.IsNullOrWhiteSpace(jwt.Issuer))
    throw new InvalidOperationException("Required config 'JwtSettings:Issuer' is not set");
if (string.IsNullOrWhiteSpace(jwt.Audience))
    throw new InvalidOperationException("Required config 'JwtSettings:Audience' is not set");

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddReverseProxy().LoadFromConfig(builder.Configuration.GetSection("ReverseProxy"));
builder.Services.AddAuthentication(option =>
{
    option.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    option.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
    option.DefaultSignInScheme = JwtBearerDefaults.AuthenticationScheme;
}).AddJwtBearer(option =>
{
    option.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = jwt!.Issuer,
        ValidAudience = jwt.Audience,
        NameClaimType = CustomClaims.Sub,
        RoleClaimType = CustomClaims.Roles,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwt.SignKey))
    };
    JwtSecurityTokenHandler.DefaultMapInboundClaims = false;
});
builder.Services.AddCors(c => c.AddPolicy("FE", p => p
    .WithOrigins("http://localhost:3000", "http://127.0.0.1:3000")
    .AllowAnyHeader()
    .AllowAnyMethod()
    .AllowCredentials()
));

var app = builder.Build();

app.MapReverseProxy();

app.UseCors("FE");
app.UseAuthentication();
app.UseAuthorization();
app.Run();

public class JwtSettings
{
    public string Issuer { get; set; } = "";
    public string Audience { get; set; } = "";
    public string SignKey { get; set; } = "";
}

public partial class Program { }
