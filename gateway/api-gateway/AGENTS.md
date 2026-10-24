# API gateway
YARP edge proxy with shared JWT/CORS bootstrap; no domain persistence.

- `Program.cs` loads `ReverseProxy` from configuration; routes/clusters live in `appsettings.json`.
- Build from root: `dotnet build gateway/api-gateway/api-gateway.csproj`.
- Prefixed `/api-<service>/` routes and direct `/api/...` routes coexist; preserve both and their transforms.
- Some routes add `/api`, others remove a prefix; verify the resulting downstream path, not just route matching.
- A configured authentication middleware is not proof that a route requires auth: inspect route policy and downstream endpoint authorization.
- Internal generation routes still require their service-specific key; proxy routing must not bypass it.
- Cluster IDs/destination names must match overrides in `../../AppHost/Program.cs`; production destinations remain in deployment configuration.
- Preserve pooled connection lifetime/DNS refresh when changing HTTP handlers; recreated Compose containers get new addresses.
- For route changes, verify affected downstream paths and unauthorized behavior; no dedicated gateway test project exists.
