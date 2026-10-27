# API gateway
YARP routes/clusters live in `appsettings.json`; JWT/CORS and proxy clients in `Program.cs`.

- Preserve `/api-<service>/` and direct `/api/...` routes with their distinct prefix transforms.
- Check downstream paths, not just route matches; cluster/destination IDs must match AppHost overrides.
- Authentication middleware does not protect every route: inspect route policies and downstream authorization.
- Internal does not imply authenticated; do not expose answer-bearing exam delivery through new proxy routes.
- Preserve pooled connection lifetime/DNS refresh; verify changed paths and unauthorized responses with isolated downstreams.
