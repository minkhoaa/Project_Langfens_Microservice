# Auth service
Identity/JWT issuance with PostgreSQL users/roles and Redis sessions/OTP; these stores are not interchangeable.

- `Application/Auth/AuthService.cs` owns auth flows; `Application/Common/JwtTokenFactory.cs` currently signs HS256 tokens, not RSA.
- Preserve `JwtSettings__*` issuer/audience/signing settings, claims and cookie semantics across gateway/shared bootstrap changes.
- Aspire must map Redis as `auth-redis`; role/scope constants live in `Shared.Security`.
- Registration/OTP messages must match email consumers and existing MassTransit endpoint names.
- Startup migrates and seeds roles. No dedicated tests; isolate Identity, Redis, Google verification and message dispatch.
