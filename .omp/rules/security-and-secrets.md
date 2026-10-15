---
description: Security rules for JWT RS256 authentication, internal API authorization, secret handling, SSRF defense, and database connection security.
globs:
  - "**/*.cs"
  - "**/*.py"
  - "deploy/envs/*.env"
  - "deploy/compose.yaml"
  - "deploy/compose*.yaml"
  - ".omp/mcp*.json"
  - ".omp/agents/*.md"
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
- Preserve endpoint-specific internal authentication and policies. Generation routes use `X-Internal-Service-Key`; do not assume an `X-Internal-Key` header authenticates every service.
- Verify token expiration, audience, issuer, and claim validity on protected routes.

## 3. Data Protection & SQL Injection
- EF Core parameterized queries prevent SQL injection by default. Never concatenate raw SQL strings with user input.
- Validate and sanitize external input strings, especially in file upload or audio processing endpoints.
- Enforce SSRF protection in ingestion services (`generation-service/app/extractor.py`) by checking private IP ranges before fetching remote URLs.
- Never log authorization headers, plain passwords, or sensitive customer details.

## 4. Agent & MCP Configuration
- `.omp/mcp.recommended.json` is documentation-only; do not merge it into `.omp/mcp.json` or start servers without explicit approval.
- Before activation, approve the server/version, data scope, endpoint, credentials, and any external disclosure. Keep credentials out of tracked files.
- Database MCP access must use separate read-only roles for a single service-owned disposable/local database, never an application owner/superuser.
- A PostgreSQL server's restricted mode supplements database permissions; it does not replace them. Do not run migrations through MCP.
- Qdrant REST is not an MCP endpoint. An approved bridge must match the collection's embedding model, dimensions, and payload schema and disable writes.
- Use existing OMP/CLI capabilities before proposing redundant filesystem, shell, Git, or browser MCPs. Never auto-download an unpinned server on session startup.
