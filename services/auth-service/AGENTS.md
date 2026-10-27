# Auth service
PostgreSQL Identity users/roles and Redis sessions/OTP; these stores are not interchangeable.

- Auth flows: `Application/Auth/AuthService.cs`; token issuance: `Application/Common/JwtTokenFactory.cs` (HS256, not RSA).
- Preserve `JwtSettings__*` issuer/audience/signing settings, claims and cookie semantics with gateway/shared bootstrap.
- Redis registration requires `auth-redis`; role/scope constants belong in `Shared.Security`.
- Registration/OTP messages must match email's `UserRegisteredSendOtp` consumer and queue.
- Startup migrates and seeds roles; verification must isolate Identity, Redis, Google token verification and message dispatch.
