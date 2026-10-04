# 04 — API Gateway (YARP) Routing

> Source-of-truth: `gateway/api-gateway/Program.cs`, `gateway/api-gateway/BootstrapExtensions.cs`, `gateway/api-gateway/appsettings.json`.

## Process

```csharp
var builder = WebApplication.CreateBuilder(args);
builder.Services.AddLangfensAuth(builder.Configuration);                 // config-driven variant
builder.Services.AddLangfensCors();
builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("Admin", policy => policy.RequireRole(Roles.Admin));
});
builder.Services.AddLangfensSwagger("API Gateway");

builder.Services
    .AddReverseProxy()
    .LoadFromConfig(builder.Configuration.GetSection("ReverseProxy"))
    .ConfigureHttpClient((context, handler) =>
    {
        // Recreate pooled connection every 30s to re-resolve DNS
        // (compose recreates containers → new IPs).
        handler.PooledConnectionLifetime = TimeSpan.FromSeconds(30);
    });

var app = builder.Build();
app.UseCors("FE");
app.UseAuthentication();
app.UseAuthorization();
app.MapReverseProxy();
app.Run();
```

## Auth wiring (gateway variant)

`GatewayBootstrapExtensions.AddLangfensAuth(IConfiguration configuration)` (in `gateway/api-gateway/BootstrapExtensions.cs`):

- Reads `JwtSettings` section (env var `JwtSettings__SignKey` resolves through `IConfiguration`).
- Throws if `SignKey` missing.
- Adds `JwtBearer` with:
  - `ValidateIssuer = true, ValidateAudience = true, ValidateIssuerSigningKey = true, ValidateLifetime = true`
  - `ClockSkew = TimeSpan.Zero`
  - `NameClaimType = CustomClaims.Sub`, `RoleClaimType = CustomClaims.Roles`
  - `MapInboundClaims = false`; sets `JwtSecurityTokenHandler.DefaultMapInboundClaims = false`
- **Signing: HS256 / `SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwt.SignKey))`** — same as shared lib.

## YARP cluster map (from `appsettings.json`)

| Cluster | Default destination (compose) | HTTP timeout | Aspire override |
|---|---|---|---|
| `auth-cluster` | `http://auth-service:8080` | 20s | `auth.GetEndpoint("http")` |
| `exam-cluster` | `http://exam-service:8080` | 20s | `exam.GetEndpoint("http")` |
| `attempt-cluster` | `http://attempt-service:8080` | 20s | `attempt.GetEndpoint("http")` |
| `vocabulary-cluster` | `http://vocabulary-service:8080` | 20s | `vocabulary.GetEndpoint("http")` |
| `course-cluster` | `http://course-service:8080` | 20s | `course.GetEndpoint("http")` |
| `speaking-cluster` | `http://speaking-service:8080` | 10m | `speaking.GetEndpoint("http")` |
| `writing-cluster` | `http://writing-service:8080` | 10m | `writing.GetEndpoint("http")` |
| `email-cluster` | `http://email-service:3000` | 20s | `email.GetEndpoint("http")` |
| `dictionary-cluster` | `http://dictionary-service:8080` | 20s | `dictionary.GetEndpoint("http")` |
| `gamification-cluster` | `http://gamification-service:8080` | 20s | `gamification.GetEndpoint("http")` |
| `ai-cluster` | `http://ai-service:8080` | 10m | `aiService.GetEndpoint("http")` |
| `generation-cluster` | `http://generation-service:8080` | 45m | `generationService.GetEndpoint("http")` |

## Routes (transforms)

There are **two routing styles** mixed in `appsettings.json`:

### Prefix-removal routes (`/api-<svc>/...` → `/api/...`)

For every service a corresponding rewrite route exists with three transforms:
1. `PathRemovePrefix` (`/api-<svc>`)
2. `PathPrefix` (`/api`)
3. `RequestHeaderOriginalHost: true`

Examples:

| Route id | Match | Cluster |
|---|---|---|
| `auth-api` | `/api-auth/{**catch-all}` | `auth-cluster` |
| `exams-api` | `/api-exams/{**catch-all}` | `exam-cluster` |
| `attempts-api` | `/api-attempts/{**catch-all}` | `attempt-cluster` |
| `vocabulary-api` | `/api-vocabulary/{**catch-all}` | `vocabulary-cluster` |
| `course-api` | `/api-course/{**catch-all}` | `course-cluster` |
| `speaking-api` | `/api-speaking/{**catch-all}` | `speaking-cluster` |
| `writing-api` | `/api-writing/{**catch-all}` | `writing-cluster` |
| `email-api` | `/api-email/{**catch-all}` | `email-cluster` |
| `dictionary-api` | `/api-dictionary/{**catch-all}` | `dictionary-cluster` |
| `analytics-api` | `/api-analytics/{**catch-all}` | `attempt-cluster` |
| `gamification-api` | `/api-gamification/{**catch-all}` | `gamification-cluster` |
| `notification-api` | `/api-notification/{**catch-all}` | `gamification-cluster` |
| `study-plan-api` | `/api-study-plan/{**catch-all}` | `attempt-cluster` |
| `ai-api` | `/api-ai/{**catch-all}` | `ai-cluster` |
| `ai-autogen-admin` | `/api-ai/v1/autogen/{**catch-all}` + `AuthorizationPolicy=Admin` | `ai-cluster` |
| `generation-api` | `/api-generation/{**catch-all}` + `AuthorizationPolicy=Admin` | `generation-cluster` |

### Direct routes (`/api/...` → cluster without rewrite)

The frontend calls these without the `/api-<svc>` prefix; gateway forwards verbatim:

| Route id | Match | Cluster |
|---|---|---|
| `auth-api-direct` | `/api/auth/{**catch-all}` | `auth-cluster` |
| `exam-public-direct` | `/api/public/exam/{**catch-all}` | `exam-cluster` |
| `exam-admin-direct` | `/api/admin/exam/{**catch-all}` | `exam-cluster` |
| `exam-section-direct` | `/api/admin/section/{**catch-all}` | `exam-cluster` |
| `exam-question-direct` | `/api/admin/question/{**catch-all}` | `exam-cluster` |
| `exam-option-direct` | `/api/admin/option/{**catch-all}` | `exam-cluster` |
| `exam-internal-direct` | `/api/internal/{**catch-all}` | `exam-cluster` |
| `exam-upload-direct` | `/api/admin/upload/{**catch-all}` | `exam-cluster` |
| `exam-uploads-static` | `/uploads/{**catch-all}` | `exam-cluster` |
| `exam-direct` | `/api/exam/{**catch-all}` | `exam-cluster` |
| `attempts-api-direct` | `/api/attempt/{**catch-all}` (PathRemovePrefix) | `attempt-cluster` |
| `analytics-api-direct` | `/api/analytics/{**catch-all}` | `attempt-cluster` |
| `study-plan-api-direct` | `/api/study-plan/{**catch-all}` | `attempt-cluster` |
| `notes-api-direct` | `/api/notes/{**catch-all}` | `attempt-cluster` |
| `bookmarks-api-direct` | `/api/bookmarks/{**catch-all}` | `attempt-cluster` |
| `question-bank-api-direct` | `/api/question-bank/{**catch-all}` | `exam-cluster` |
| `courses-api-direct` | `/api/course/{**catch-all}` | `course-cluster` |
| `lessons-api-direct` | `/api/lesson/{**catch-all}` | `course-cluster` |
| `courses-admin-direct` | `/api/admin/course/{**catch-all}` | `course-cluster` |
| `vocabulary-api-direct` | `/api/vocabulary/{**catch-all}` | `vocabulary-cluster` |
| `speaking-api-direct` | `/api/speaking/{**catch-all}` | `speaking-cluster` |
| `speaking-api-grade` | `/api-speaking/grade` (PathRemovePrefix `/api-speaking`, PathPrefix `/api`) | `speaking-cluster` |
| `writing-api-direct` | `/api/writing/{**catch-all}` | `writing-cluster` |
| `writing-api-grade` | `/api-writing/grade` (PathRemovePrefix `/api-writing`, PathPrefix `/api/writing`) | `writing-cluster` |
| `email-api-direct` | `/api/mail/{**catch-all}` | `email-cluster` |
| `dictionary-api-direct` | `/api/dictionary/{**catch-all}` | `dictionary-cluster` |
| `gamification-api-direct` | `/api/gamification/{**catch-all}` | `gamification-cluster` |
| `notifications-api-direct` | `/api/notifications/{**catch-all}` | `gamification-cluster` |

Two routes enforce Admin role at the gateway level: `ai-autogen-admin` and `generation-api`.

## Why so many route flavors?

Each service was originally only exposed via `/api-<svc>/...`. Over time, individual endpoints (public/auth/admin) were carved out as direct routes so the FE could keep a stable path namespace while admins maintain isolated sub-paths. This is the on-disk reality in `appsettings.json`.

## Subtle YARP config

- `RequestHeaderOriginalHost: true` preserves the original `Host` header through YARP.
- All clusters share the `HttpClient` configured with `PooledConnectionLifetime=30s` (DnsRefresh workaround for compose).
- The gateway itself uses port **5000** in both compose and AppHost.
