# Langfens Repository Invariants (Sticky Rules)

1. **Source Code Integrity**: Do not modify application source code unless explicitly requested by the user.
2. **Service Discovery & Ports**: Never hardcode host ports, connection strings, or service URLs. Use Aspire dynamic service endpoints (`service.GetEndpoint("http")` / `"grpc"`) and discrete `RABBITMQ__*` environment variables.
3. **Database Schema Isolation**: Each microservice strictly owns its PostgreSQL database. Never cross-query another service's database or bypass EF Core migrations.
4. **C# Architectural Style**:
   - Use Minimal APIs organized under `Features/{Feature}/{Action}Endpoint.cs`.
   - Prefer immutable types (`sealed record`, `init` setters) and explicit nullable annotations (`string?`).
   - Implement `IQuestionGrader` and `IQuestionGraderRegistration` for all question grading in `attempt-service`.
5. **Python Architectural Style**:
   - Use async route handlers (`async def`) for all I/O.
   - Enforce Pydantic v2 models at system boundaries and maintain Groq/Ollama LLM facades.
   - Respect versioned runtime caps (`loop-caps.env`, R03/G06 invariants) in `generation-service`.
6. **Testing & Verification**: Use failing behavioral tests first for code changes and verify affected suites before completing work. Never disable existing suites. Exam integration fixtures can drop schemas: use an explicitly selected disposable test database, never real data. Configuration-only work requires OMP discovery smoke checks, not application startup.
7. **Secrets & Security**: Never commit secrets, credentials, or API keys. Always use environment variables or `deploy/envs/*.env` files.
8. **Configuration Safety**: Reuse global ECC resources; preserve custom project instructions, agents, and skills. Do not activate MCP servers, install packages/hooks, or change global plugin state without approval. Recommendations are not executable setup.
