# Per-Service ServiceDefaults Migration Recipe

For each service after exam-service:

1. Add ProjectReference in `<service>.csproj`:
   ```xml
   <ProjectReference Include="..\_shared\Shared.ServiceDefaults\Shared.ServiceDefaults.csproj" />
   ```
2. In `Program.cs`, immediately after `var builder = WebApplication.CreateBuilder(args);`:
   ```csharp
   builder.AddServiceDefaults();
   ```
3. Replace the hand-rolled `app.MapHealthChecks("/health", new HealthCheckOptions { ResponseWriter = ... });` block with:
   ```csharp
   app.MapDefaultEndpoints();
   ```
4. Remove unused `using System.Text.Json;` if no other JsonSerializer call remains.
5. Build the service, then the solution.
6. Boot AppHost; curl `/health` and `/alive`; check the dashboard's Traces tab.
7. Commit with message `refactor(<service>): adopt Shared.ServiceDefaults for OTel + health`.

## Service-specific notes

- **auth-service / attempt-service / writing-service / email-service / gamification-service / course-service / vocabulary-service / speaking-service:** also keep their existing `AddNpgSql` / `AddRedis` / `AddRabbitMQ` health checks. ServiceDefaults registers a `self` check; the others stack alongside.
- **dictionary-service:** has Elasticsearch via `WithEnvironment`, no Aspire client wrapper. Keep the existing manual config; nothing changes for ServiceDefaults.
- **api-gateway:** YARP cluster discovery may need adjustment if `AddServiceDiscovery` interferes with the explicit `ReverseProxy__...` endpoint env vars from AppHost. Test this one carefully.
- **frontend (NextJS):** not a .NET project, no migration.

## Anti-patterns to avoid

- Don't move `AddServiceDefaults()` after other `AddX` calls — OTel needs to wrap them.
- Don't add OTel / ServiceDiscovery packages directly to a service csproj — they come transitively through the shared project.
- Don't remove existing service-specific `AddHealthChecks().AddX(...)` calls. ServiceDefaults adds a `self` check; service-specific dependency checks stay where they are.