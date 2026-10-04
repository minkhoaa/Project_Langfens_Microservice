# 05 — auth-service

> Source-of-truth: `services/auth-service/*`. Verified end-to-end via direct reads of `Program.cs`, `Application/Auth/AuthService.cs`, `Application/Common/JwtTokenFactory.cs`, `Infrastructure/Redis/RedisOtpStore.cs`, `Infrastructure/Persistence/AuthDbContext.cs`, `Features/Auth/*`.

## Role in the system

Identity & session: register, login (password + Google), refresh, logout, OTP email confirm, forgot/reset password, list users. Issues HS256 JWTs, stores sessions in Redis, publishes `UserRegisteredSendOtp` and `UserCreatedEvent`.

## Stack

- ASP.NET Core 10, EF Core 10 + Npgsql (`IdentityDbContext<User, Role, string>`)
- ASP.NET Core Identity (`AddIdentityCore<User>` + `AddRoles<Role>` + `AddEntityFrameworkStores` + `AddSignInManager` + `AddDefaultTokenProviders`)
- StackExchange.Redis (via `builder.AddRedisClient("auth-redis")` → singleton `IConnectionMultiplexer`)
- MassTransit + RabbitMQ (publishes; **no consumers registered** — `services/auth-service/Features/RabbitMq/TestPingConsumer.cs` exists as a stub `IConsumer<TestPing>` but is **not** wired in `Program.cs`; the MassTransit `AddMassTransit` block in `Program.cs` only configures the host)
- JWT HS256 (`SymmetricSecurityKey(Encoding.UTF8.GetBytes(SignKey))`)

## Persistence

- **PostgreSQL** `auth-db` (Aspire-injected via `AddNpgsqlDbContext<AuthDbContext>("auth-db")`)
- Identity tables: `users`, `roles`, `user_roles`, `user_claims`, `user_logins`, `role_claims`, `user_tokens`; custom table `sessions` keyed `(UserId, DeviceId)`.
- Migrations run on startup via `await context.Database.MigrateAsync()`.
- Health check: `auth-db` + `auth-redis`.

## Sessions

- `IAuthService.PasswordLoginAsync` issues a session id, stores it via `ISessionStore` (Redis) with **30-day TTL** (`SessionLifetime = TimeSpan.FromDays(30)`).
- **Max 5 sessions per user** (`MaxSessionsPerUser = 5`); oldest evicted on overflow.
- **Rotation threshold** `TimeSpan.FromDays(3)` — sessions older than that get rotated on refresh.
- Session cookie: `sid=<sessionId>` HTTP-only (`CookieService.CreateSessionCookie`).
- Refresh uses cookie or header `sid` (`RequestContext.FromHttpContext`).

## OTP store (Redis)

`IOtpStore` implemented by `RedisOtpStore(IConnectionMultiplexer redis, IPasswordHasher<string> hasher)`:

- Keys: `otp:{email}`, `otp:tries:{email}`, `otp:block:{email}`, `otp:cool:{email}` (email normalized trim+lower).
- OTP hashed via `IPasswordHasher<string>` (PBKDF2 — Identity default).
- Verification flow: block check → `PasswordVerificationResult.Success` → clear all keys; on fail increment tries, expire tries at OTP TTL, block for `BlockSeconds=300s` when `MaxAttempts=5`.
- Resend cooldown: 30s (`ResendCooldown`). Resets tries on `PutOtp`.
- Constants (verbatim): `TtlSeconds=180`, `BlockSeconds=300`, `TouchCooldowns=30s`, `MaxAttempts=5`, `OtpTtl=3min`, `ResendCooldown=30s`, `PwResetTtl=10min`, `PwResetCooldown=30s`, `PwResetMaxAttempts=5`, `PwResetBlock=5min`.

## JWT issuance

`JwtTokenFactory.CreateTokenAsync(user, roles, scopes, sid, ct)` (HS256):

- Claims: `sub=user.Id`, `scope=string.Join(' ', scopes)`, `sid=sid`, `roles=<each role>` (and parallel `ClaimTypes.Role`), `iat/nbf/jti`.
- Issuer/audience/lifetime from `auth_service.Application.Common.JwtSettings`.
- The auth-service's local `JwtSettings` POCO adds **`RsaPrivateKeyPem`** and **`KeyId`** fields — loaded but **not used** for signing; signing remains HS256.

## Endpoints (`/api/auth`)

`AuthEndpoints.MapAuthEndpoints`:

| Endpoint | Auth | Notes |
|---|---|---|
| `POST /login` | Anonymous | sets `sid` cookie on success |
| `POST /register` | Anonymous | publishes `UserRegisteredSendOtp`, returns generic success |
| `POST /login/google` (GoogleLoginEndpoint) | Anonymous | verifies Google ID token via `GoogleTokenVerifier` (`Google.Apis.Auth.GoogleJsonWebSignature.ValidateAsync`); audience is `PUBLIC_GOOGLE_CLIENT_ID` env |
| `POST /refresh` | (cookie/header `sid`) | rotates session if past `RotationThreshold` |
| `POST /logout` | (cookie/header `sid`) | removes session |
| `GET /me` | (JWT) | current user |
| `GET /verify?email&otp` | Anonymous | email confirmation |
| `POST /resend-otp` | Anonymous | resends verification OTP (cooldown 30s) |
| `POST /forgot-password` | Anonymous | publishes `UserRegisteredSendOtp` with PwReset TTL (10min) |
| `POST /resend-otp-reset-password` | Anonymous | resends forgot-password OTP |
| `POST /confirm-otp-reset-password` | Anonymous | confirms + resets password |
| `GET /users` (admin) | **`Roles.Admin` only** | list users (verified at `GetAllUsersEndpoint.MapGetAllUsersEndpoint` → `MapGet("/users", …).RequireAuthorization(Roles.Admin)`) |

## Authorization policies (added in `Program.cs`)

- `Roles.User` → `RequireRole(Roles.User)`
- `Roles.Admin` → `RequireRole(Roles.Admin)`
- `UserScope.UserReadAny` → `RequireAssertion(ctx => ctx.User.HasAnyScope(UserScope.UserReadAny) || ctx.User.IsInRole(Roles.Admin))` (registered but **not currently attached to any endpoint** — the only `/users` endpoint uses `RequireAuthorization(Roles.Admin)` directly)

## RabbitMQ

- Configured via MassTransit. Host: `RABBITMQ__HOST/PORT/USERNAME/PASSWORD/VHOST/USESSL`.
- `KebabCaseEndpointNameFormatter("user-registered", includeNamespace: false)` for `user-registered` endpoints.
- Publishes:
  - `UserRegisteredSendOtp(Email, Otp, TtlSeconds)` → consumed by `email-service/UserRegisteredSendOtpConsumer`.
  - `UserCreatedEvent(UserId, Email, CreatedAt)` (declared in `Shared.PublicContracts/Events/UserEvents.cs`; intended consumer is `gamification-service/UserCreatedConsumer` — verify publish call site in `AuthService`).
- Does **not** register any consumers in `Program.cs` (the `TestPingConsumer` file is a stub only).

## Environment variables (verified)

| Key | Required | Purpose |
|---|---|---|
| `JwtSettings__Issuer` | yes | token issuer |
| `JwtSettings__Audience` | yes | token audience |
| `JwtSettings__SignKey` | yes | HS256 signing key |
| `JwtSettings__RsaPrivateKeyPem` | yes (load-only) | reserved; unused for current HS256 signing |
| `JwtSettings__KeyId` | yes (load-only) | reserved |
| `JwtSettings__AccessTokenLifetimeSeconds` | optional | default 3600 (auth-service local copy) |
| `PUBLIC_GOOGLE_CLIENT_ID` | optional | Google OAuth audience |
| `RABBITMQ__HOST/PORT/USERNAME/PASSWORD/VHOST/USESSL` | yes | broker |
| `ConnectionStrings__auth-db` | yes | Aspire-injected |
| `ConnectionStrings__auth-redis` | yes | Aspire-injected (mapped from shared Redis) |

## What auth-service does NOT do

- Does not handle course / exam / attempt business logic.
- Does not register any MassTransit consumers (only `TestPingConsumer.cs` exists as an unregistered stub).
- Does not own the email send itself — that's `email-service`.
