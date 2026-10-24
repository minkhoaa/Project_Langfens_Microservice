# API gateway
YARP edge proxy; `appsettings.json` defines `ReverseProxy` routes/clusters, with auth/CORS wired in `Program.cs`.

- Preserve both `/api-<service>/` and direct `/api/...` routes and their distinct prefix transforms.
- Check actual downstream paths, not just route matches; cluster/destination IDs must match `AppHost/Program.cs` overrides.
- Authentication middleware alone does not protect routes: inspect route authorization policies and downstream checks.
- Internal generation endpoints still require their service key; proxying must not bypass it.
- Keep pooled connection lifetime/DNS refresh so recreated Compose containers remain reachable.
- No dedicated test project: verify changed downstream paths and unauthorized responses with isolated dependencies.
