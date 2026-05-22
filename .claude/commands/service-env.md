# List environment variables for a service

Prints the required and optional env vars for a given service based on its Program.cs.

## Usage
```
/service-env <service-name>
```

## Examples

```bash
# Show env vars for auth-service
/service-env auth

# Show env vars for attempt-service
/service-env attempt
```

## Notes
- Always read the service's own CLAUDE.md for the complete env var list
- Secrets live in `deploy/envs/<name>.env` — never commit real values
- Aspire/AppHost auto-injects `ConnectionStrings__*` and `RABBITMQ__*` vars