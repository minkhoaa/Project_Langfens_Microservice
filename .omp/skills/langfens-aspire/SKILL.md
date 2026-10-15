---
name: langfens-aspire
description: Operate, diagnose, and extend Langfens Aspire 13.3 orchestration, dynamic endpoints, RabbitMQ environment wiring, and YARP routes.
---

# Langfens Aspire workflow

Use for `AppHost/`, gateway routing, and local infrastructure. Reuse global
`dotnet-patterns` and `docker-patterns`; this skill adds only repository context.
Delegate to `aspire-architect` when the topology change warrants a specialist.

## Inspect before acting

- `AppHost/AppHost.csproj` targets .NET 10; primary Aspire packages are 13.3.2.
- `AppHost/Program.cs` owns resource dependencies, `WithComposeEnvFile`,
  `WithRabbitMqEnv`, and gateway destination overrides.
- Gateway routes/clusters live in `gateway/api-gateway/appsettings.json`.
- `deploy/compose.local.yaml` and `deploy/compose.yaml` are separate runtime
  surfaces. Read current mappings rather than copying ports from old instructions.
- Frontend code is in a sibling checkout; it is not a local npm application.

## Local operation

Requires .NET 10 SDK, Docker, and the appropriate local environment configuration:

```bash
dotnet run --project AppHost/AppHost.csproj
```

Starting the full graph launches databases/services; do not do it for a
configuration-only task. Read the actual Dashboard and gateway addresses from
startup output. Never print environment values containing credentials.

## Resource and routing contract

- Stateful services own separate PostgreSQL databases and EF migrations.
- Redis, RabbitMQ, Elasticsearch, Qdrant, and Ollama are infrastructure resources;
  Python AI/generation services are containerized in the AppHost graph.
- Inject database references with `WithReference`; respect existing `WaitFor`
  dependencies and health checks.
- Resolve service addresses using `GetEndpoint("http")` / `GetEndpoint("grpc")`.
  Preserve existing Compose DNS configuration without inventing new fixed URLs.
- Supply RabbitMQ through discrete `RABBITMQ__HOST`, `PORT`, `USERNAME`,
  `PASSWORD`, `VHOST`, and `USESSL` settings, not a new connection-string parser.
- When a route changes, align its YARP route/cluster configuration with the
  AppHost `ReverseProxy__Clusters__...__Destinations__d1__Address` override and
  Compose configuration. Do not treat a reachable downstream health endpoint
  as proof that gateway transforms and authentication work.

## Diagnose and verify

Inspect the failed resource, its dependency health, endpoint bindings, and
redacted logs before changing anything. Do not reset volumes or overwrite secrets
to address connection failures. Build the affected projects, then exercise the
actual gateway route and auth/health path when application behavior changes.
Use `/skill:langfens-verify` for the applicable checks; do not infer fixed ports.
