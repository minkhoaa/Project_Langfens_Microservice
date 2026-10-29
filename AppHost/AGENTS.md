# AppHost
`Program.cs` owns Aspire's resource graph and dynamic endpoint injection.

- `WithComposeEnvFile(name)` loads `deploy/envs/<name>.env`; preserve graph-owned exclusions.
- Use `WithRabbitMqEnv` with broker references, secret parameters and `WaitFor` dependencies.
- Preserve legacy connection mappings: auth needs `ConnectionStrings__auth-redis`; writing needs `CONNECTIONSTRING__WRITING`.
- Set the secret Aspire parameter `Parameters:exam-internal-api-key` (environment: `Parameters__exam-internal-api-key`); AppHost injects the same `EXAMSERVICE__INTERNAL__API__KEY` into exam and attempt. No placeholder key is supplied.
- Named `http`/`grpc` endpoints must match gateway destination overrides and attempt's exam HTTP/gRPC addresses; exam uses `Kestrel__HttpPort` / `Kestrel__GrpcPort` outside Aspire.
- AI waits for Ollama's BGE-M3 initialization; chat and embeddings use different providers.
- Discover live URLs from Aspire; point the external frontend's `NEXT_PUBLIC_GATEWAY_URL` at the gateway.
