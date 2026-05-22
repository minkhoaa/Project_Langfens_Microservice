# auth-service

JWT/identity service with Redis session management and OTP verification.

## Service Overview
- **Port**: 5434 (HTTP + health)
- **Stack**: ASP.NET Core 10, EF Core + Npgsql, Redis, MassTransit/RabbitMQ, JWT (RS256 + HS256 hybrid)
- **Database**: PostgreSQL via AuthDbContext (EF Core)
- **Cache**: Redis (session storage, OTP store)

## Key Files
```
Program.cs                           Entry point, wiring
Program.Partial.cs                   Partial for additional setup
BootstrapExtensions.cs               Service-local bootstrap extensions
Application/
  Auth/AuthService.cs                Core auth logic (login, register, refresh, google OAuth)
  Common/JwtTokenFactory.cs          RS256 token issuance
  Common/JwtSettings.cs              JWT config model (Issuer, Audience, SignKey, RsaPrivateKeyPem, KeyId)
  Common/RedisOtpStore.cs            OTP storage in Redis (IOtpStore impl)
  Common/OtpGenerator.cs             OTP generation (IOtpGenerator)
  Common/CookieService.cs            HTTP-only cookie helpers
  Common/GoogleTokenVerifier.cs      Google ID token verification
  Common/RequestContext.cs           Current user context from JWT
  Common/EmailValidator.cs           Validates email format
Data/SessionEntity.cs                Redis session entity
Infrastructure/Persistence/
  AuthDbContext.cs                   EF Core DbContext (Users, Roles)
  SessionRepository.cs               ISessionRepository (session CRUD)
Infrastructure/Redis/
  SessionStore.cs                    ISessionStore (Redis-backed)
  RedisOtpStore.cs                   OTP store using IDatabase
Features/
  Auth/*.cs                          Minimal API endpoints (Login, Register, Refresh, Me, etc.)
  RabbitMq/*.cs                     MassTransit consumers (e.g. TestPing)
Migrations/                          EF Core migrations
```

## Common Operations

### Adding a new auth endpoint
1. Create a new file under `Features/Auth/` named `{Action}Endpoint.cs`
2. Implement a `Results`-based minimal API method (e.g. `app.MapPost(...)`)
3. Inject scoped services (`IAuthService`, `UserManager<User>`, etc.)
4. Add to `Program.cs` via `app.MapAuthEndpoints()` — endpoints are mapped from the static `AuthEndpoints` class.

### Modifying JWT behavior
- Token settings live in `Application/Common/JwtSettings.cs`
- `Program.cs` reads env vars `JwtSettings__*` directly.
- Token issuance logic in `JwtTokenFactory.cs` (RS256 with private key).

### Updating an entity / running migrations
```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/auth-service
dotnet ef migrations add <MigrationName> --project auth-service.csproj
dotnet ef database update
# Or via dotnet run (migrations run automatically on startup)
```

### Adding a new role or policy
- Roles defined in `Shared.Security.Roles/Roles.cs` (`User`, `Admin`)
- Authorization policies set in `Program.cs` via `builder.Services.AddAuthorization()`
- Example: `opts.AddPolicy(Roles.Admin, p => p.RequireRole(Roles.Admin))`

## MassTransit / RabbitMQ Patterns
- **Publisher**: `auth-service` publishes events to RabbitMQ (e.g., `UserRegistered`)
- Endpoint name formatter: `KebabCaseEndpointNameFormatter("user-registered")`
- Consumer pattern (e.g. `TestPingConsumer`):
  ```csharp
  // Features/RabbitMq/TestPingConsumer.cs
  public class TestPingConsumer : IConsumer<TestPing> { ... }
  ```
- Register consumer in `Program.cs` inside `AddMassTransit(config => ...)`

## DB Migration Commands
```bash
# Create migration
dotnet ef migrations add AddNewTable --project auth-service.csproj --output-dir Migrations

# Apply migrations (runs on startup, or explicitly)
dotnet ef database update --project auth-service.csproj

# Remove last migration (if not applied)
dotnet ef migrations remove --project auth-service.csproj
```

## How This Service Communicates with Others
- **Publishes**: `UserRegistered` event → RabbitMQ → other services (email-service for OTP)
- **gRPC**: None (REST only)
- **HTTP internal**: Calls to external Google OAuth endpoints for token verification

## Testing Patterns
- No dedicated test project currently; write unit tests for `AuthService.cs`, `JwtTokenFactory.cs`, `OtpGenerator.cs`
- Use `UserManager<User>` + in-memory/mock DbContext for service tests
- Mock `IConnectionMultiplexer` / `IDatabase` for Redis operations
- MassTransit consumer tests: publish test message → assert side effects

## Environment Variables (required)
```
JwtSettings__Issuer, JwtSettings__Audience, JwtSettings__SignKey,
JwtSettings__RsaPrivateKeyPem, JwtSettings__KeyId, JwtSettings__AccessTokenLifetimeSeconds,
RABBITMQ__HOST, RABBITMQ__USERNAME, RABBITMQ__PASSWORD, RABBITMQ__VHOST, RABBITMQ__PORT, RABBITMQ__USESSL,
Aspire: auth-db connection string, auth-redis connection string
```