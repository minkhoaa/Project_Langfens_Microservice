using System.Composition;
using System.IdentityModel.Tokens.Jwt;
using System.Net;
using System.Security.Claims;
using System.Security.Cryptography.Xml;
using System.Text;
using auth_service.Models;
using Microsoft.AspNetCore.Authentication.BearerToken;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);
builder.Services.Configure<JwtSettings>(builder.Configuration.GetSection("JwtSettings"));

var jwt = builder.Configuration.GetSection("JwtSettings").Get<JwtSettings>();
var connectionString = Environment.GetEnvironmentVariable("CONNECTIONSTRING__DEFAULT")
                    ?? builder.Configuration.GetConnectionString("Default");




builder.Services.AddDbContextPool<AppDbContext>(option =>
{
    option.UseNpgsql(connectionString);
});

builder.Services.AddIdentityCore<User>().AddRoles<Role>().AddEntityFrameworkStores<AppDbContext>().AddSignInManager().AddDefaultTokenProviders();

builder.Services.AddAuthentication(option =>
{
    option.DefaultAuthenticateScheme = BearerTokenDefaults.AuthenticationScheme;
    option.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(option =>
{
    option.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateIssuerSigningKey = true,
        ValidAudience = jwt.Audience,
        ValidIssuer = jwt.Issuer,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwt.SignKey)),
        ClockSkew = TimeSpan.Zero


    };
}
)

;
builder.Services.AddAuthorization();
builder.Services.AddEndpointsApiExplorer();

builder.Services.AddSwaggerGen(option =>
{
    option.SwaggerDoc("v1", new OpenApiInfo { Title = "Auth Service", Version = "1.0" });
    option.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.Http,
        Scheme = "Bearer",
        BearerFormat = "JWT",
        Description = "Enter token: "
    });
    option.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        { new OpenApiSecurityScheme {
            Reference =new OpenApiReference{Type = ReferenceType.SecurityScheme, Id = "Bearer"} }, Array.Empty<string>()
        }
    });
});


var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    await db.Database.MigrateAsync();
}
app.UseSwagger();
app.UseSwaggerUI();


app.UseAuthentication();
app.UseAuthorization();




static string CreateJwtToken(User user, IEnumerable<string> roles, JwtSettings jwt)
{
    var claims = new List<Claim>()
    {
        new Claim(JwtRegisteredClaimNames.Sub, user.Id),
        new Claim(JwtRegisteredClaimNames.Email, user.Email!),
        new Claim(JwtRegisteredClaimNames.Name, user.UserName ?? user.Email ?? "")
    };
    claims.AddRange(roles.Select(x => new Claim(ClaimTypes.Role, x)));
    var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwt.SignKey));
    var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
    var token = new JwtSecurityToken(
        issuer: jwt.Issuer,
        audience: jwt.Audience,
        claims: claims,
        expires: DateTime.UtcNow.AddMinutes(5),
        signingCredentials: creds

    );
    return new JwtSecurityTokenHandler().WriteToken(token).ToString();
}


// MINIMAL API

app.MapPost("/api/auth/register", async ([FromServices] UserManager<User> userManagers, [FromBody] RegisterDto dto) =>
{
    if (string.IsNullOrEmpty(dto.email) || string.IsNullOrEmpty(dto.password))
    {
        return Results.BadRequest(new { isSuccess = false, message = "Email and password is missing" });
    }
    var existed = await userManagers.FindByEmailAsync(dto.email);
    if (existed != null)
    {
        return Results.BadRequest(new ResultDto(false, "Email is used", null!));
    }
    var user = new User()
    {
        Email = dto.email,
        UserName = dto.email
    };
    var result = await userManagers.CreateAsync(user, dto.password);
    if (!result.Succeeded) return Results.BadRequest(new ResultDto(false, result.Errors.Select(x => x.Description).FirstOrDefault()!.ToString(), null!));
    return Results.Ok(new ResultDto(true, "User is created successfully", new { id = user.Id, email = user.Email }));
}).AllowAnonymous()
.Produces(StatusCodes.Status201Created)
.Produces(StatusCodes.Status400BadRequest)
.Produces(StatusCodes.Status409Conflict);

app.MapPost("/api/auth/login", async (
    [FromServices] UserManager<User> userManager,
    [FromServices] SignInManager<User> signInManger,
    IOptions<JwtSettings> jwt,
    [FromBody] LoginDto dto
) =>
{
    if (string.IsNullOrEmpty(dto.email) || string.IsNullOrEmpty(dto.password))
    {
        return Results.BadRequest(new ResultDto(false, "Email or password is missing", null!));
    }
    var user = await userManager.FindByEmailAsync(dto.email);
    if (user == null) return Results.BadRequest(new ResultDto(false, "User is not existed", null!));
    var check = await signInManger.CheckPasswordSignInAsync(user, dto.password, true);
    if (!check.Succeeded) return Results.BadRequest(new ResultDto(false, "Password is incorrect", null!));

    var roles = await userManager.GetRolesAsync(user);
    var token = CreateJwtToken(user, roles, jwt.Value);
    return Results.Ok(new ResultDto(true, "Login successfully", token));
}).AllowAnonymous().Produces(statusCode: StatusCodes.Status200OK).Produces(StatusCodes.Status400BadRequest);



app.MapGet("/api/me", async (ClaimsPrincipal info) =>
{
    var email = info.FindFirstValue(JwtRegisteredClaimNames.Email ?? JwtRegisteredClaimNames.Name);
    if (email == null || string.IsNullOrEmpty(email)) return Results.NotFound(new ResultDto(false, "Email is exist", null!));
    var id = info.FindFirstValue(JwtRegisteredClaimNames.Sub) ?? "";
    return Results.Ok(new ResultDto(true, "Get information successfully", new { id, email }));
}).AllowAnonymous().Produces(StatusCodes.Status200OK).Produces(StatusCodes.Status401Unauthorized);


// MINIMAL API



app.Run();







public record RegisterDto(string email, string password);
public record LoginDto(string email, string password);

public record ResultDto(bool isSuccess, string message, object data);

public class JwtSettings
{
    public string Issuer { get; set; } = "";
    public string Audience { get; set; } = "";
    public string SignKey { get; set; } = "";
}
