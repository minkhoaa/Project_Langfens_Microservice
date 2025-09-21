using System.Composition;
using System.Globalization;
using System.IdentityModel.Tokens.Jwt;
using System.Net;
using System.Net.Mail;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Security.Cryptography.Xml;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using auth_service.Data;
using auth_service.Models;
using Google.Apis.Auth;
using MassTransit;
using Microsoft.AspNetCore.Authentication.BearerToken;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.CodeAnalysis.CSharp.Syntax;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Microsoft.OpenApi.Writers;
using Shared.Contracts.Contracts;
using StackExchange.Redis;



// HELPER

// sid: 1 phiên = 1 sid.
static string KeySession(string sid) => $"session:{sid}";

// devKey: giữ sid hiện hành của 1 thiết bị → phục vụ “mỗi device chỉ 1 phiên” và đá phiên cũ cùng device.
static string KeyUserDevSid(string userId, string deviceId) => $"user:{userId}:device:{deviceId}:sid";

// zKey: giữ tất cả sid của user → phục vụ giới hạn tổng số phiên/user & theo dõi hoạt động.
static string KeyUserSessions(string userId) => $"user:{userId}:sessions";

static bool IsValidEmail(string? email)
{
    if (string.IsNullOrWhiteSpace(email)) return false;
    var trimmed = email.Trim();
    var at = trimmed.LastIndexOf('@');
    if (at <= 0 || at == trimmed.Length - 1) return false;
    var local = trimmed[..at];
    var domain = trimmed[(at + 1)..];
    try
    {
        domain = new IdnMapping().GetAscii(domain);

    }
    catch
    {
        return false; 
    }
    var candidate = $"{local}@{domain}";
    return MailAddress.TryCreate(candidate, out var address) && address.Address == candidate;

}



static string Base64Url(byte[] b) =>
    Convert.ToBase64String(b).TrimEnd('=').Replace('+', '-').Replace('/', '_');
static string NewRaw() => Base64Url(RandomNumberGenerator.GetBytes(64));
static (string token, string jti, string raw) BuildRefreshPayload(string userId)
{
    var raw = NewRaw();
    var jti = Guid.NewGuid().ToString("N");
    return ($"{userId}.{jti}.{raw}", jti, raw);
}

// gắn index khi có session mới, phiên của user kèm device cụ thể
static async Task AddSessionIndicesAsync(IDatabase redis, SessionRec ss, TimeSpan time)
{
    var devKey = KeyUserDevSid(ss.UserId, ss.DeviceId!);
    var zKey = KeyUserSessions(ss.UserId);
    var oldSid = await redis.StringGetAsync(devKey);
    if (!oldSid.IsNullOrEmpty)
    {
        await redis.KeyDeleteAsync(KeySession(oldSid!));
        await redis.SortedSetRemoveAsync(zKey, oldSid);
    }

    await redis.StringSetAsync(devKey, ss.Sid, time);
    await redis.SortedSetAddAsync(zKey, ss.Sid, DateTimeOffset.UtcNow.ToUnixTimeSeconds());
}

// giới hạn số lương phiên của 1 user, 
static async Task CapUserSessionsAsync(IDatabase redis, string userId, int maxSession)
{
    if (maxSession <= 0) return;
    var zKey = KeyUserSessions(userId);
    var count = await redis.SortedSetLengthAsync(zKey);
    if (count > maxSession)
    {
        var toRemove = await redis.SortedSetRangeByRankAsync(zKey, 0, (long)(count - maxSession - 1));
        foreach (var c in toRemove)
        {
            await redis.KeyDeleteAsync(KeySession(c!));
        }
        await redis.SortedSetRemoveRangeByRankAsync(zKey, 0, (long)(count - maxSession - 1));
    }
}
static async Task RemoveSessionAsync(IDatabase redis, SessionRec ss)
{
    await redis.KeyDeleteAsync(KeySession(ss.Sid));
    await redis.SortedSetRemoveAsync(KeyUserSessions(ss.UserId), ss.Sid);
    if (!string.IsNullOrEmpty(ss.DeviceId))
    {
        await redis.KeyDeleteAsync(KeyUserDevSid(ss.UserId, ss.DeviceId));
    }
}

static CookieOptions SidSet(IConfiguration cfg) => new()
{
    HttpOnly = true,
    SameSite = SameSiteMode.Lax,
    Secure = false, // prod => true
    Path = "/",
    // Prod: set domain gốc để FE (subdomain khác) thấy cookie
    // Domain = cfg["Cookies:Domain"], // ví dụ ".example.com"
    Expires = DateTimeOffset.UtcNow.AddDays(30),
    IsEssential = true
};

static CookieOptions SidDel(IConfiguration cfg) => new()
{
    HttpOnly = true,
    SameSite = SameSiteMode.Lax,
    Secure = false,
    Path = "/",
    // Domain = cfg["Cookies:Domain"],
    Expires = DateTimeOffset.UnixEpoch,
    IsEssential = true
};





var builder = WebApplication.CreateBuilder(args);
builder.Services.Configure<JwtSettings>(builder.Configuration.GetSection("JwtSettings"));

var jwt = builder.Configuration.GetSection("JwtSettings").Get<JwtSettings>();
var connectionString = Environment.GetEnvironmentVariable("CONNECTIONSTRING__AUTH");

var redis = Environment.GetEnvironmentVariable("CONNECTIONSTRING__REDIS")
                    ?? builder.Configuration.GetConnectionString("Redis");

builder.Services.AddSingleton<IConnectionMultiplexer>(p => ConnectionMultiplexer.Connect(redis!));
builder.Services.AddSingleton(c => c.GetRequiredService<IConnectionMultiplexer>().GetDatabase());
var googleClientId = Environment.GetEnvironmentVariable("PUBLIC_GOOGLE_CLIENT_ID") ??
                     builder.Configuration["OAuth:PUBLIC_GOOGLE_CLIENT_ID"];
builder.Services.AddMassTransit(busConfigurator =>
{
    busConfigurator.SetKebabCaseEndpointNameFormatter();
    busConfigurator.UsingInMemory((context, config) =>
    {
        config.ConfigureEndpoints(context);
    });
});


builder.Services.AddDbContextPool<AuthDbContext>(option =>
{
    option.UseNpgsql(connectionString);
});

builder.Services.AddIdentityCore<User>().AddRoles<auth_service.Models.Role>().AddEntityFrameworkStores<AuthDbContext>().AddSignInManager().AddDefaultTokenProviders();

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
        ValidateLifetime = true,
        ValidAudience = jwt!.Audience,
        ValidIssuer = jwt.Issuer,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwt.SignKey)),
        ClockSkew = TimeSpan.Zero


    };


}
);
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
    var db = scope.ServiceProvider.GetRequiredService<AuthDbContext>();
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
        expires: DateTime.UtcNow.AddSeconds(15),
signingCredentials: creds
    );
    return new JwtSecurityTokenHandler().WriteToken(token).ToString();
}




// MINIMAL API

app.MapPost("/api/auth/register", async ([FromServices] UserManager<User> userManagers, [FromBody] RegisterDto dto) =>
    {

        if (IsValidEmail(dto.email))
            return Results.BadRequest(new ApiResultDto(false, "Email format is not valid", null!));

        if (string.IsNullOrEmpty(dto.email) || string.IsNullOrEmpty(dto.password))
            return Results.BadRequest(new ApiResultDto(false, "Email or password is missed", null!));
    var existed = await userManagers.FindByEmailAsync(dto.email);
    if (existed != null)
    {
        return Results.BadRequest(new ApiResultDto(false, "Email is used", null!));
    }
    var user = new User()
    {
        Email = dto.email,
        UserName = dto.email
    };
    var result = await userManagers.CreateAsync(user, dto.password);
    if (!result.Succeeded) return Results.BadRequest(new ApiResultDto(false, result.Errors.Select(x => x.Description).FirstOrDefault()!.ToString(), null!));
    return Results.Ok(new ApiResultDto(true, "User is created successfully", new { id = user.Id, email = user.Email }));
}).AllowAnonymous()
.Produces(StatusCodes.Status201Created)
.Produces(StatusCodes.Status400BadRequest)
.Produces(StatusCodes.Status409Conflict);







/// <summary>
/// LOGIN SERVICE
/// </summary>
/// <param name="userManager"></param>
/// <param name="signInManger"></param>
/// <param name="jwt"></param>
/// <param name="dto"></param>
/// <param name="redis"></param>
/// <param name="http"></param>
/// <param name="configuration"></param>
/// <returns></returns>


app.MapPost("/api/auth/login", async (
    [FromServices] UserManager<User> userManager,
    [FromServices] SignInManager<User> signInManger,
    IOptions<JwtSettings> jwt,
    [FromBody] LoginDto dto,
    [FromServices] IDatabase redis,
    HttpContext http,
    IConfiguration configuration,
    AuthDbContext context
) =>
{

    if (string.IsNullOrEmpty(dto.email) || string.IsNullOrEmpty(dto.password))
    {
        return Results.BadRequest(new ApiResultDto(false, "Email or password is missing", null!));
    }
    var user = await userManager.FindByEmailAsync(dto.email);
    if (user == null) return Results.BadRequest(new ApiResultDto(false, "User is not existed", null!));
    var check = await signInManger.CheckPasswordSignInAsync(user, dto.password, true);
    if (!check.Succeeded) return Results.BadRequest(new ApiResultDto(false, "Password is incorrect", null!));

    var roles = await userManager.GetRolesAsync(user);
    var accessToken = CreateJwtToken(user, roles, jwt.Value);


    var (payload, jti, raw) = BuildRefreshPayload(user.Id);

    var deviceId = http.Request.Headers["X-Device-Id"].ToString();
    var ip = http.Connection.RemoteIpAddress?.ToString();
    var ua = http.Request.Headers.UserAgent.ToString();

    
    var sid = Guid.NewGuid().ToString("N");
    var newSession = new SessionEntity()
    {
        UserId = user.Id,
        DeviceId = deviceId,
        Jti = jti,
        Exp = DateTime.UtcNow.AddDays(30),
        Ua = ua,
        Ip = ip,
        LastSeen = DateTime.UtcNow,
        PrevJti = null,
        RevokedAt = null,
    };



    // lưu databsase

    var existedSession = await context.Sessions.FindAsync(newSession.UserId, newSession.DeviceId);
    if (existedSession == null)
    {
        await context.Sessions.AddAsync(newSession);

    }
    else
    {
        existedSession.PrevJti = existedSession.Jti;
        existedSession.Jti = newSession.Jti;
        existedSession.Exp = newSession.Exp;
        existedSession.LastSeen = DateTime.UtcNow;
        existedSession.Ua = newSession.Ua;
        existedSession.Ip = newSession.Ip;
        existedSession.RevokedAt = null;
        context.Sessions.Update(existedSession);
    }
    await context.SaveChangesAsync();



    // lưu sid redis
    var ss = new SessionRec(
        sid, user.Id, jti, DateTime.UtcNow.AddDays(30), deviceId, ua, ip
    );
    await redis.StringSetAsync(KeySession(sid), JsonSerializer.Serialize(ss), TimeSpan.FromDays(30));

    // add Cookie
    http.Response.Cookies.Append("sid", sid, SidSet(cfg: configuration));


    // lưu device trỏ đến sid ( 1 device - 1 sid(lần user đăng nhập))
    var ttl = ss.Exp > DateTime.UtcNow ? ss.Exp - DateTime.UtcNow : TimeSpan.FromSeconds(1);
    await AddSessionIndicesAsync(redis, ss, ttl);     // đá phiên cũ cùng device nếu có
    const int K = 5;                                  // tuỳ bạn, 0 = không giới hạn
    // lưu list số lượng sid của một userId đã đăng nhập (giới hannj là 5 sid cho một userId )
    await CapUserSessionsAsync(redis, ss.UserId, K);

    return Results.Ok(new ApiResultDto(true, "Login successfully", accessToken));
}).AllowAnonymous().Produces(statusCode: StatusCodes.Status200OK).Produces(StatusCodes.Status400BadRequest);





/// <summary>
/// LOGIN GOOGLE
/// </summary>
/// <param name="req"></param>
/// <param name="userManager"></param>
/// <param name="jwtSettings"></param>
/// <param name="roleManager"></param>
/// <param name="redis"></param>
/// <param name="cfg"></param>
/// <returns></returns>


app.MapPost("/api/auth/login-google", async (HttpContext req,
    [FromServices] UserManager<User> userManager,
    IOptions<JwtSettings> jwtSettings,
    [FromServices] RoleManager<auth_service.Models.Role> roleManager,
    IDatabase redis,
    IConfiguration cfg,
    AuthDbContext db
) =>
{
    var dto = await req.Request.ReadFromJsonAsync<GoogleLoginRequest>();
    if (dto == null || string.IsNullOrEmpty(dto.idToken))
        return Results.BadRequest(new ApiResultDto(false, "Missing Idtoken", null!));

    try
    {
        var payLoad = await GoogleJsonWebSignature.ValidateAsync(dto.idToken, new GoogleJsonWebSignature.ValidationSettings()
        {
            Audience = new[] { googleClientId }
        });
        if (!payLoad.EmailVerified)
            return Results.BadRequest(new ApiResultDto(false, "Email is not verified by Google", null!));

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
                if (!createUser.Succeeded) return Results.BadRequest(new ApiResultDto(false, createUser.Errors.FirstOrDefault()!.Description, null!));

            }
            var info = new UserLoginInfo(loginProvider, providerKey, "Google");
            var addLogin = await userManager.AddLoginAsync(existedUser, info);
            if (!addLogin.Succeeded)
            {
                var already = addLogin.Errors.Any(e =>
                    e.Code.Contains("LoginAlreadyAssociated", StringComparison.OrdinalIgnoreCase));
                if (!already)
                    return Results.BadRequest(new ApiResultDto(false, string.Join("; ", addLogin.Errors.Select(e => e.Description)), null!));
            }
        }



        var roles = await userManager.GetRolesAsync(user: existedUser);

        var accessToken = CreateJwtToken(existedUser, roles, jwtSettings.Value);

        var (refreshtoken, jti, raw) = BuildRefreshPayload(userId: existedUser.Id);
        var deviceId = req.Request.Headers["X-Device-Id"].ToString();
        var ua = req.Request.Headers.UserAgent.ToString();
        var ip = req.Connection.RemoteIpAddress?.ToString();


        var newSession = new SessionEntity
        {
            UserId = existedUser.Id,
            DeviceId = deviceId,
            Jti = jti,
            Exp = DateTime.UtcNow.AddDays(30),
            Ip = ip,
            LastSeen = DateTime.UtcNow,
            PrevJti = null,
            RevokedAt = null,
            Ua = ua,
        };
        var existedSession = await db.Sessions.FindAsync(newSession.UserId, deviceId);
        if (existedSession == null) await db.Sessions.AddAsync(newSession);
        else
        {
            existedSession.PrevJti = existedSession.Jti;
            existedSession.Jti = newSession.Jti;
            existedSession.Exp = DateTime.UtcNow.AddDays(30);
            existedSession.LastSeen = DateTime.UtcNow;
            existedSession.Ua = ua;
            existedSession.Ip = ip;
            db.Sessions.Update(existedSession);
        }
        await db.SaveChangesAsync();


        var sid = Guid.NewGuid().ToString("N");
        var ss = new SessionRec(
            Sid: sid,
            UserId: existedUser.Id,
            Jti: jti,                             // liên kết tới refresh hiện hành
            Exp: DateTime.UtcNow.AddDays(30),
            DeviceId: deviceId,
            Ua: ua,
            Ip: ip
        );


        await redis.StringSetAsync(KeySession(sid), JsonSerializer.Serialize(ss), TimeSpan.FromDays(30));
        req.Response.Cookies.Append("sid", sid, SidSet(cfg));

        var ttl = ss.Exp > DateTime.UtcNow ? ss.Exp - DateTime.UtcNow : TimeSpan.FromSeconds(1);
        await AddSessionIndicesAsync(redis, ss, ttl);
        const int K = 5;
        await CapUserSessionsAsync(redis, ss.UserId, K);
        return Results.Ok(new ApiResultDto(true, "Login successfully", accessToken));
    }
    catch (Exception e)
    {
        return Results.BadRequest(new ApiResultDto(false, $"{e.Message}", null!));
    }

}).AllowAnonymous()
.Produces(StatusCodes.Status200OK).Produces(StatusCodes.Status400BadRequest); ;

// COOKIE set trong redis có id là KeySession(sid) với body là SessionRecord
// COOKIE set trong Frontend thì có id là sid 
// mỗi refresh_token có khóa ngoại liên kết với jti (mã jwt của session cookie)

app.MapPost("/api/auth/refresh", async (
    UserManager<User> userManager,
    IOptions<JwtSettings> jwtSettings,
    HttpContext http,
    IDatabase redis,
    AuthDbContext db
) =>
{

    var sid = http.Request.Cookies["sid"];
    if (string.IsNullOrEmpty(sid)) return Results.Unauthorized();

    var raw = await redis.StringGetAsync(KeySession(sid));
    if (raw.IsNullOrEmpty) return Results.Unauthorized();

    var session = JsonSerializer.Deserialize<SessionRec>(raw!)!;
    if (session.Exp <= DateTime.UtcNow) return Results.Unauthorized();

    var user = await userManager.FindByIdAsync(session.UserId);
    if (user == null) return Results.Unauthorized();

    var deviceId = session.DeviceId ?? http.Request.Headers["X-Device-Id"].ToString();
    var ua = session.Ua ?? http.Request.Headers.UserAgent.ToString();
    var ip = session.Ip ?? http.Connection.RemoteIpAddress?.ToString();

    var dbSession = await db.Sessions.FindAsync(user.Id, deviceId);
    if (dbSession == null || dbSession.RevokedAt != null || dbSession.Jti != session.Jti ||
        dbSession.Exp <= DateTime.UtcNow) return Results.Unauthorized();

    var roles = await userManager.GetRolesAsync(user);
    var newAccessToken = CreateJwtToken(user, roles, jwtSettings.Value);
    var now = DateTime.UtcNow;
    var rotate = (dbSession.Exp - now) < TimeSpan.FromDays(3);
    if (rotate)
    {
        var (newPayload, newJti, newRaw) = BuildRefreshPayload(user.Id);

        dbSession.PrevJti = dbSession.Jti;
        dbSession.Jti = newJti;
        dbSession.Exp = DateTime.UtcNow.AddDays(30);
        dbSession.LastSeen = DateTime.UtcNow;
        dbSession.RevokedAt = null;

        db.Sessions.Update(dbSession);

        var updated = session with { Jti = newJti, Exp = now.AddDays(30) };
        await redis.StringSetAsync(KeySession(sid), JsonSerializer.Serialize(updated), TimeSpan.FromDays(30));
    }

    else
    {
        await redis.KeyExpireAsync(KeySession(sid), TimeSpan.FromDays(30));
        dbSession.LastSeen = now;
        db.Sessions.Update(dbSession);
    }
    await db.SaveChangesAsync();



    return Results.Ok(new ApiResultDto(true, "Success", newAccessToken));

}).Produces(StatusCodes.Status200OK).Produces(StatusCodes.Status401Unauthorized);



app.MapPost("/api/auth/logout", async (HttpContext http, UserManager<User> userManager,
    IDatabase redis, IConfiguration configuration, AuthDbContext db
) =>
{
    var sid = http.Request.Cookies["sid"];
    if (!string.IsNullOrEmpty(sid))
    {
        var raw = await redis.StringGetAsync(KeySession(sid));
        if (!raw.IsNullOrEmpty)
        {
            var session = JsonSerializer.Deserialize<SessionRec>(raw!)!;
            var deviceId = session.DeviceId ?? http.Request.Headers["X-Device-Id"].ToString();
            var dbSession = await db.Sessions.FindAsync(session.UserId, deviceId);
            if (dbSession != null)
            {
                dbSession.RevokedAt = DateTime.UtcNow;
                await db.SaveChangesAsync();
            }
            await redis.SortedSetRemoveAsync($"user:{session.UserId}:sessions", sid);
            if (!string.IsNullOrEmpty(deviceId))
                await redis.KeyDeleteAsync($"user:{session.UserId}:device:{deviceId}:sid");
            await redis.KeyDeleteAsync(KeySession(sid));

        }


    }
    http.Response.Cookies.Append("sid", "", SidDel(configuration));


    return Results.Ok(new ApiResultDto(true, "Logout successfully", null!));

});








app.MapGet("/api/auth/me", async (ClaimsPrincipal info) =>
{
    var email = info.FindFirstValue(ClaimTypes.Email ?? JwtRegisteredClaimNames.Name);
    if (email == null || string.IsNullOrEmpty(email)) return Results.NotFound(new ApiResultDto(false, "Email is not exist", null!));
    var id = info.FindFirstValue(ClaimTypes.NameIdentifier) ?? "";
    return Results.Ok(new ApiResultDto(true, "Get information successfully", new { id, email }));
}).RequireAuthorization().Produces(StatusCodes.Status200OK).Produces(StatusCodes.Status401Unauthorized);







// MINIMAL API



app.Run();







public record RegisterDto(string email, string password);
public record LoginDto(string email, string password);

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

record SessionRec(
    string Sid,
    string UserId,
    string Jti,            // JTI hiện tại của refresh family
    DateTime Exp,          // hết hạn phiên (30 ngày)
    string? DeviceId,
    string? Ua,
    string? Ip
);


public class JwtSettings
{
    public string Issuer { get; set; } = "";
    public string Audience { get; set; } = "";
    public string SignKey { get; set; } = "";
}

public record GoogleLoginRequest([property: JsonPropertyName("idToken")] string? idToken);

public record FacebookLoginRequest([property: JsonPropertyName("idToken")] string? idToken);

