# AppHost
`Program.cs` owns Aspire's local resource graph; the frontend runs in a separate checkout.

- `WithComposeEnvFile(name)` loads `deploy/envs/<name>.env`; preserve exclusions for graph-owned values.
- Database references need explicit legacy connection-key mappings via `ConnectionStringExpression`; auth Redis is named `auth-redis`.
- Use `WithRabbitMqEnv` alongside broker references, secret credential parameters and `WaitFor` dependencies.
- Named `http`/`grpc` endpoints and YARP cluster/destination overrides must agree; exam uses `KESTREL_GRPC_PORT`, attempt needs gRPC and internal HTTP.
- Exam/generation share the internal key and `WithComposeEnvFile("loop-caps")`; cap changes require both service guides and regression suites.
- Persistent volumes survive restarts: restarting Aspire does not isolate tests. Discover live URLs from Aspire, including frontend `NEXT_PUBLIC_GATEWAY_URL`.
