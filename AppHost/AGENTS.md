# AppHost
Aspire's primary local-dev resource graph; frontend runs separately in the sibling checkout.

- `Program.cs` defines services, infra, credentials, startup dependencies and `AppHostExtensions`.
- Build from root: `dotnet build AppHost/AppHost.csproj`; run with the root guide's stack command.
- `WithComposeEnvFile(name)` loads `deploy/envs/<name>.env`, skipping graph-owned values; preserve its exclusion list when adding configuration.
- Use `WithReference` for databases; map legacy connection-string keys explicitly with `ConnectionStringExpression`.
- Use `WithRabbitMqEnv` as well as broker references: consumers require discrete host/port/credential variables.
- Declare reusable credentials as parameters; passwords use `secret: true`.
- Wire dependencies with `WaitFor`; use named `http`/`grpc` endpoints and matching YARP destination overrides.
- Exam's gRPC endpoint uses `KESTREL_GRPC_PORT`; attempt needs both `ExamService__GrpcAddress` and internal HTTP configuration.
- Exam and generation share the internal service key and `WithComposeEnvFile("loop-caps")`; see `../docs/standards/reading-runtime-caps.md` before changing caps.
- Persistent infra volumes survive restarts; restarting AppHost is not database isolation for tests.
- Obtain live endpoints from Aspire; point frontend `NEXT_PUBLIC_GATEWAY_URL` at the gateway endpoint.
