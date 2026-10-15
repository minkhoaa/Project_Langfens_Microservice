---
description: Security rules for JWT RS256 authentication, internal API authorization, secret handling, SSRF defense, and database connection security.
globs:
  - "**/*.cs"
  - "**/*.py"
  - "deploy/envs/*.env"
  - "deploy/compose.yaml"
---

# Security & Secrets Management Rules

## 1. Secrets Management
- **NEVER** commit API keys, private certificates, JWT signing keys, database passwords, or SMTP tokens to source code or git.
- Read secrets exclusively from environment variables or `deploy/envs/*.env` files.
- In `AppHost`, declare passwords with `builder.AddParameter(..., secret: true)`.
- Use `.gitignore` to prevent any local credentials or `.env` files from leaking.

## 2. Authentication & Authorization
- External client requests terminate at `gateway/api-gateway/`, which validates JWT RS256 tokens using public keys.
- Services configure auth using `AddLangfensAuth(...)` from `Shared.Bootstrap`.
- Internal service-to-service REST calls require internal API key verification (`X-Internal-Key` header) and internal policy enforcement (`[Authorize(Policy = InternalPolicy)]`).
- Verify token expiration, audience, issuer, and claim validity on protected routes.

## 3. Data Protection & SQL Injection
- EF Core parameterized queries prevent SQL injection by default. Never concatenate raw SQL strings with user input.
- Validate and sanitize external input strings, especially in file upload or audio processing endpoints.
- Enforce SSRF protection in ingestion services (`generation-service/app/extractor.py`) by checking private IP ranges before fetching remote URLs.
- Never log authorization headers, plain passwords, or sensitive customer details.
