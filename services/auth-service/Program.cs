using System.Composition;
using System.IdentityModel.Tokens.Jwt;
using System.Net;
using System.Security.Claims;
using System.Security.Cryptography.Xml;
using System.Text;
using System.Text.Json.Serialization;
using auth_service.Models;
using Google.Apis.Auth;
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


var googleClientId = Environment.GetEnvironmentVariable("PUBLIC_GOOGLE_CLIENT_ID") ?? builder.Configuration["OAuth:PUBLIC_GOOGLE_CLIENT_ID"];



builder.Services.AddDbContextPool<AppDbContext>(option =>
{
    option.UseNpgsql(connectionString);
});

builder.Services.AddIdentityCore<User>().AddRoles<Role>().AddEntityFrameworkStores<AppDbContext>().AddSignInManager().AddDefaultTokenProviders();

builder.Services.AddCors(c => c.AddPolicy("FE", p => p.WithOrigins("http://localhost:3000").AllowAnyHeader().AllowAnyMethod().AllowCredentials()));



builder.Services.AddAuthentication(option =>
{
    option.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    option.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
    option.DefaultScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(option =>
{
    option.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateIssuerSigningKey = true,
        ValidAudience = jwt!.Audience,
        ValidIssuer = jwt.Issuer,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwt.SignKey)),
        ClockSkew = TimeSpan.Zero


    };

    option.Events = new JwtBearerEvents
    {
        OnMessageReceived = (ctx) =>
        {
            if (string.IsNullOrEmpty(ctx.Token) && ctx.Request.Cookies.TryGetValue("auth", out var tokenFromCookie))
            {
                ctx.Token = tokenFromCookie.ToString();
            }
            return Task.CompletedTask;
        }
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

app.UseCors("FE");
app.UseAuthentication();
app.UseAuthorization();




static string CreateJwtToken(User user, IEnumerable<string> roles, JwtSettings jwt)
{
    var claims = new List<Claim>()
    {
       new(ClaimTypes.NameIdentifier, user.Id),
        new(ClaimTypes.Email, user.Email ?? string.Empty),
        new(ClaimTypes.Name, user.UserName ?? user.Email ?? string.Empty),
    };
    claims.AddRange(roles.Select(x => new Claim(ClaimTypes.Role, x)));
    var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwt.SignKey));
    var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
    var token = new JwtSecurityToken(
        issuer: jwt.Issuer,
        audience: jwt.Audience,
        claims: claims,
        expires: DateTime.UtcNow.AddHours(2),
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
    [FromBody] LoginDto dto,
    HttpContext http
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

    http.Response.Cookies.Append("auth", token, new CookieOptions
    {
        HttpOnly = true,
        SameSite = SameSiteMode.Lax,
        Secure = true,
        Path = "/",
        Expires = DateTime.UtcNow.AddHours(2)
    });



    return Results.Ok(new ResultDto(true, "Login successfully", null!));
}).AllowAnonymous().Produces(statusCode: StatusCodes.Status200OK).Produces(StatusCodes.Status400BadRequest);

app.MapPost("/api/auth/login-google", async (HttpContext req,
    [FromServices] UserManager<User> userManager,
    IOptions<JwtSettings> jwtSettings,
    [FromServices] RoleManager<Role> roleManager
) =>
{
    var dto = await req.Request.ReadFromJsonAsync<GoogleLoginRequest>();
    if (string.IsNullOrEmpty(dto.idToken)) return Results.BadRequest(new ResultDto(false, "Missing Idtoken", null!));
    try
    {
        var payLoad = await GoogleJsonWebSignature.ValidateAsync(dto.idToken, new GoogleJsonWebSignature.ValidationSettings()
        {
            Audience = new[] { googleClientId }
        });
        if (!payLoad.EmailVerified)
            return Results.BadRequest(new ResultDto(false, "Email is not verified by Google", null!));

        var existedUser = await userManager.FindByEmailAsync(payLoad.Email);
        if (existedUser == null)
        {
            User newUser = new User()
            {
                Email = payLoad.Email,
                UserName = payLoad.Email,
                EmailConfirmed = true
            };
            var createUser = await userManager.CreateAsync(newUser);
            if (!createUser.Succeeded) return Results.BadRequest(new ResultDto(false, "Error while creating new user ", null!));
            existedUser = newUser;
        }
        var roles = await userManager.GetRolesAsync(user: existedUser);

        var token = CreateJwtToken(existedUser, roles, jwtSettings.Value);

        req.Response.Cookies.Append("auth", token, new CookieOptions()
        {
            HttpOnly = true,
            SameSite = SameSiteMode.Lax,
            Secure = true,
            Path = "/",
            Expires = DateTime.UtcNow.AddDays(2),

        });

        return Results.Ok(new ResultDto(true, "Login successfully", token));
    }
    catch (Exception e)
    {
        return Results.BadRequest(new ResultDto(false, $"{e.Message}", null!));
    }

}).AllowAnonymous()
.Produces(StatusCodes.Status200OK).Produces(StatusCodes.Status400BadRequest);
;



app.MapGet("/api/me", async (ClaimsPrincipal info) =>
{
    var email = info.FindFirstValue(ClaimTypes.Email ?? JwtRegisteredClaimNames.Name);
    if (email == null || string.IsNullOrEmpty(email)) return Results.NotFound(new ResultDto(false, "Email is exist", null!));
    var id = info.FindFirstValue(ClaimTypes.NameIdentifier) ?? "";
    return Results.Ok(new ResultDto(true, "Get information successfully", new { id, email }));
}).RequireAuthorization().Produces(StatusCodes.Status200OK).Produces(StatusCodes.Status401Unauthorized);


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

public record GoogleLoginRequest([property: JsonPropertyName("idToken")] string? idToken);
