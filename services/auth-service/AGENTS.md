# Auth service
Identity/JWT issuer, Redis sessions and OTP verification; publishes registration/OTP messages.

- `Application/Auth/AuthService.cs` owns login/register/refresh/Google flows; endpoints are in `Features/Auth/`.
- `Application/Common/JwtTokenFactory.cs` issues RS256 tokens; settings are read from `JwtSettings__*` in `Program.cs`.
- Preserve issuer/audience, signing-key/key-ID and cookie semantics across issuer, shared bootstrap and gateway changes.
- PostgreSQL `AuthDbContext` stores users/roles; `Infrastructure/Redis/` stores sessions/OTP. Do not substitute one store for the other.
- `auth-redis` is the required Aspire Redis connection name, explicitly mapped by AppHost.
- Role/scope constants are in `Shared.Security`; policies are configured in `Program.cs`.
- Keep registration/OTP message contracts compatible with email consumers; preserve the existing MassTransit endpoint naming.
- Startup applies migrations and seeds roles; starting the app is not a side-effect-free smoke test.
- Build from root: `dotnet build services/auth-service/auth-service.csproj`.
- No dedicated test project exists; auth tests should isolate Identity, Redis, Google verification and message dispatch.
