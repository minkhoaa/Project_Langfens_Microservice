---
name: langfens-service-setup
description: Integrate an explicitly requested Langfens microservice through shared bootstrap/contracts, database ownership, Aspire, YARP, Compose, and behavioral verification.
---

# Add a Langfens microservice

Use only when the user requests a new service. Reuse global `api-design`,
`contract-first`, `dotnet-patterns`, and `database-migrations`; this workflow
supplies the repository integration checklist, not a second scaffold framework.

1. **Define the boundary.** Establish service ownership, public/internal APIs,
   events/RPC, authorization, persistence, and consumer-visible acceptance
   behavior. Reuse an existing service if the requested responsibility belongs
   there. Write an appropriate failing behavioral test before implementation.
2. **Follow the nearest project.** Transactional services target `net10.0` with
   nullable annotations and implicit usings. Read an existing service's csproj
   and startup; do not copy unverified bootstrap method signatures. Shared
   references from `services/<name>-service` resolve through `../_shared/`.
   Reuse `Shared.Bootstrap`, `Shared.ServiceDefaults`, `Shared.Security`, and
   public/protobuf contracts where actually needed.
3. **Implement the service contract.** Use Minimal API feature endpoints under
   `Features/{Feature}/{Action}Endpoint.cs`. Keep auth, validation, cancellation,
   telemetry, error responses, and external-client lifetimes consistent with
   the closest service. A stateful service owns its database and EF migrations;
   never query a neighbor's database directly.
4. **Wire orchestration.** Update `AppHost/AppHost.csproj` project references and
   `AppHost/Program.cs` resources/dependencies. Use database references,
   `WithComposeEnvFile`, discrete RabbitMQ settings, and dynamic endpoints.
   Declare secret parameters without embedding credentials or choosing a new
   fixed host port. Read `/skill:langfens-aspire` for topology details.
5. **Migrate consumers/deployment.** Align YARP routes and cluster destination
   overrides, shared contracts/events/RPC clients, and applicable Compose
   build/runtime configuration. Endpoint values belong in deployment/service
   discovery, not hardcoded application URLs. Update only the owning service's
   env configuration with explicit authorization; never commit secrets.
6. **Include the project.** Add it to the existing solution and document its
   purpose, prerequisites, ownership, and verification in the repository's
   established documentation. Do not add another agent instruction file merely
   because a generic scaffold recommends one.
7. **Prove behavior.** Build the affected projects/solution, run relevant suites,
   then exercise the actual health/auth/gateway path and a meaningful consumer
   operation. Use disposable infrastructure for integration tests. Update docs
   after proof and remove obsolete paths; do not deliver a compiling placeholder.

From repository root, after the requested service implementation:

```bash
dotnet build Project_Langfens_Microservice.sln
```

That build alone is not end-to-end verification. Use `/skill:langfens-verify` to
select behavioral tests and smoke scenarios; no service creation or application
startup is part of an ECC-configuration-only task.
