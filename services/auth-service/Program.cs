using System.Composition;
using System.IdentityModel.Tokens.Jwt;
using System.Net;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Security.Cryptography.Xml;
using System.Text;
using System.Text.Json;
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


static CookieOptions RtDel(string path) => new()
{
    HttpOnly = true,
    SameSite = SameSiteMode.Lax,
    Secure = false,
    Path = path,
    Expires = DateTimeOffset.UnixEpoch
};

static CookieOptions RtSet() => new()
{
    HttpOnly = true,
    SameSite = SameSiteMode.Lax,
    Secure = false,
    Path = "/api/auth/refresh",
    Expires = DateTime.UtcNow.AddDays(30),
    IsEssential = true
};
static void ClearRtCookies(HttpResponse res)
{
    res.Cookies.Append("refresh_token", "", RtDel("/"));
    res.Cookies.Append("refresh_token", "", RtDel("/api/auth/refresh"));
}

static string? GetLatestRefreshToken(HttpRequest req)
{
    var raw = req.Headers.Cookie.ToString();
    if (string.IsNullOrEmpty(raw)) return null;
    return raw.Split(';')
        .Select(s => s.Trim())
        .Where(s => s.StartsWith("refresh_token="))
        .Select(s => s["refresh_token=".Length..])
        .LastOrDefault();
}



static string Base64Url(byte[] b) =>
    Convert.ToBase64String(b).TrimEnd('=').Replace('+', '-').Replace('/', '_');

static byte[] Base64UrlDecode(string s)
{
    s = s.Replace('-', '+').Replace('_', '/');
    switch (s.Length % 4) { case 2: s += "=="; break; case 3: s += "="; break; }
    return Convert.FromBase64String(s);
}

static string NewRaw() => Base64Url(RandomNumberGenerator.GetBytes(64));

static string Hash(string raw)
{
    using var sha = SHA256.Create();
    return Convert.ToBase64String(sha.ComputeHash(Encoding.UTF8.GetBytes(raw)));
}

static (string token, string jti, string raw) BuildRefreshPayload(string userId)
{
    var raw = NewRaw();
    var jti = Guid.NewGuid().ToString("N");
    return ($"{userId}.{jti}.{raw}", jti, raw);
}

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

builder.Services.AddCors(c => c.AddPolicy("FE", p => p
    .WithOrigins("http://localhost:3000", "http://127.0.0.1:3000")
    .AllowAnyHeader()
    .AllowAnyMethod()
    .AllowCredentials()
));



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
        expires: DateTime.UtcNow.AddMinutes(15),
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
    var accessToken = CreateJwtToken(user, roles, jwt.Value);


    var (payload, jti, raw) = BuildRefreshPayload(user.Id);
    var rec = new RefreshRecord(
        hash: Hash(raw),
        exp: DateTime.UtcNow.AddDays(30),
        revokedAt: null,
        replacedByJti: null,

        deviceId: http.Request.Headers["X-Device-Id"].ToString(),
        ip: http.Connection.RemoteIpAddress?.ToString(),
        ua: http.Request.Headers.UserAgent.ToString()
    );

    await userManager.SetAuthenticationTokenAsync(user, "refresh_token", jti, JsonSerializer.Serialize(rec));
    ClearRtCookies(http.Response);

    http.Response.Cookies.Append("refresh_token", payload, RtSet());



    return Results.Ok(new ResultDto(true, "Login successfully", accessToken));
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

        const string loginProvider = "Google";
        var providerKey = payLoad.Subject;

        var existedUser = await userManager.FindByLoginAsync(loginProvider, providerKey);
        if (existedUser == null)
        {
            existedUser = await userManager.FindByEmailAsync(payLoad.Email);
            if (existedUser == null)
            {
                existedUser = new User()
                {
                    Email = payLoad.Email,
                    UserName = payLoad.Email,
                    EmailConfirmed = true
                };
                var createUser = await userManager.CreateAsync(existedUser);
                if (!createUser.Succeeded) return Results.BadRequest(new ResultDto(false, createUser.Errors.FirstOrDefault()!.Description, null!));

            }
            var info = new UserLoginInfo(loginProvider, providerKey, "Google");
            var addLogin = await userManager.AddLoginAsync(existedUser, info);
            if (!addLogin.Succeeded)
            {
                var already = addLogin.Errors.Any(e =>
                    e.Code.Contains("LoginAlreadyAssociated", StringComparison.OrdinalIgnoreCase));
                if (!already)
                    return Results.BadRequest(new ResultDto(false, string.Join("; ", addLogin.Errors.Select(e => e.Description)), null!));
            }
        }

        var roles = await userManager.GetRolesAsync(user: existedUser);

        var accessToken = CreateJwtToken(existedUser, roles, jwtSettings.Value);

        var (refreshtoken, jti, raw) = BuildRefreshPayload(userId: existedUser.Id);

        var rec = new RefreshRecord(
            hash: Hash(raw),
            exp: DateTime.UtcNow.AddDays(30),
            revokedAt: null,
            replacedByJti: null,
            deviceId: req.Request.Headers["X-Device-Id"].ToString(),
            ip: req.Connection.RemoteIpAddress?.ToString(),
            ua: req.Request.Headers.UserAgent.ToString()
        );



        var saveToken = await userManager.SetAuthenticationTokenAsync(existedUser, "refresh_token", jti, JsonSerializer.Serialize(rec));
        if (!saveToken.Succeeded) return Results.BadRequest(new ResultDto(false, string.Join("; ", saveToken.Errors.Select(e => e.Description)), null!));
        ClearRtCookies(req.Response);
        req.Response.Cookies.Append("refresh_token", refreshtoken, RtSet());


        return Results.Ok(new ResultDto(true, "Login successfully", accessToken));
    }
    catch (Exception e)
    {
        return Results.BadRequest(new ResultDto(false, $"{e.Message}", null!));
    }

}).AllowAnonymous()
.Produces(StatusCodes.Status200OK).Produces(StatusCodes.Status400BadRequest); ;



app.MapPost("/api/auth/refresh", async (
    UserManager<User> userManager,
    IOptions<JwtSettings> jwtSettings,
    HttpContext http
) =>
{
    var payload = GetLatestRefreshToken(http.Request) ?? http.Request.Cookies["refresh_token"];
    if (string.IsNullOrEmpty(payload))
        return Results.BadRequest(new ResultDto(false, "refresh token is missing", null!));

    var parts = payload.Split('.', 3);
    if (parts.Length != 3) return Results.Unauthorized();
    var userId = parts[0];
    var jti = parts[1];
    var raw = parts[2];


    var user = await userManager.FindByIdAsync(userId);
    if (user == null) return Results.Unauthorized();
    var json = await userManager.GetAuthenticationTokenAsync(user, "refresh_token", jti);

    if (string.IsNullOrEmpty(json)) return Results.Unauthorized();
    var rec = JsonSerializer.Deserialize<RefreshRecord>(json);
    if (rec.revokedAt != null || rec.exp <= DateTime.UtcNow) return Results.Unauthorized();

    if (!string.IsNullOrEmpty(rec.replacedByJti)) return Results.Unauthorized();

    if (rec.hash != Hash(raw)) return Results.Unauthorized();


    var roles = await userManager.GetRolesAsync(user);
    var newAccessToken = CreateJwtToken(user, roles, jwtSettings.Value);


    var (newPayload, newJti, newRaw) = BuildRefreshPayload(user.Id);
    var newRec = new RefreshRecord(
        hash: Hash(newRaw),
        exp: DateTime.UtcNow.AddDays(30),
        revokedAt: null,
        replacedByJti: null,
        deviceId: http.Request.Headers["X-Device-Id"].ToString(),
        ua: http.Request.Headers.UserAgent.ToString(),
        ip: http.Connection.RemoteIpAddress?.ToString()
    );
    await userManager.SetAuthenticationTokenAsync(user, "refresh_token", newJti, JsonSerializer.Serialize(newRec));
    var oldRec = rec with { revokedAt = DateTime.UtcNow, replacedByJti = newJti };
    await userManager.SetAuthenticationTokenAsync(user, "refresh_token", jti, JsonSerializer.Serialize(oldRec));

    ClearRtCookies(http.Response);
    http.Response.Cookies.Append("refresh_token", newPayload, RtSet());

    return Results.Ok(new ResultDto(true, "Success", newAccessToken));

}).Produces(StatusCodes.Status200OK).Produces(StatusCodes.Status401Unauthorized);



app.MapPost("/api/auth/logout", async (HttpContext http, UserManager<User> userManager) =>
{
    var payLoad = http.Request.Cookies["refresh_token"];
    if (!string.IsNullOrEmpty(payLoad))
    {
        var parts = payLoad.Split('.', 3);
        if (parts.Length == 3)
        {
            var user = await userManager.FindByIdAsync(parts[0]);
            if (user != null)
            {
                var jti = parts[1];
                var json = await userManager.GetAuthenticationTokenAsync(user, "refresh_token", jti);
                if (!string.IsNullOrEmpty(json))
                {
                    var rec = JsonSerializer.Deserialize<RefreshRecord>(json)! with { revokedAt = DateTime.UtcNow };
                    await userManager.SetAuthenticationTokenAsync(user, "refresh_token", jti, JsonSerializer.Serialize(rec));
                }
            }
        }
    }
    ClearRtCookies(http.Response);
    return Results.Ok(new ResultDto(true, "Logout successfully", null!));

});











app.MapGet("/api/auth/me", async (ClaimsPrincipal info) =>
{
    var email = info.FindFirstValue(ClaimTypes.Email ?? JwtRegisteredClaimNames.Name);
    if (email == null || string.IsNullOrEmpty(email)) return Results.NotFound(new ResultDto(false, "Email is not exist", null!));
    var id = info.FindFirstValue(ClaimTypes.NameIdentifier) ?? "";
    return Results.Ok(new ResultDto(true, "Get information successfully", new { id, email }));
}).RequireAuthorization().Produces(StatusCodes.Status200OK).Produces(StatusCodes.Status401Unauthorized);











// MINIMAL API



app.Run();







public record RegisterDto(string email, string password);
public record LoginDto(string email, string password);

public record ResultDto(bool isSuccess, string message, object data);

public record RefreshTokenDto(string refreshToken);

public record RevokeRefreshToken(string refreshToken);
record RefreshRecord(
    string hash,
    DateTime exp,
    DateTime? revokedAt,
    string? replacedByJti,
    string? deviceId,
    string? ip,
    string? ua
);


public class JwtSettings
{
    public string Issuer { get; set; } = "";
    public string Audience { get; set; } = "";
    public string SignKey { get; set; } = "";
}

public record GoogleLoginRequest([property: JsonPropertyName("idToken")] string? idToken);

public record FacebookLoginRequest([property: JsonPropertyName("idToken")] string? idToken);

