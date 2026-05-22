# Run the full mono-repo locally via AppHost (Aspire)

Starts all services using Aspire orchestration with live rebuild support.

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
dotnet run --project AppHost/AppHost.csproj
```

## Endpoints after startup
- **Gateway**: http://localhost:5000 (YARP reverse proxy)
- **Aspire Dashboard**: http://localhost:18888 (resource status, logs)

## Run a specific service directly (for debugging)
```bash
cd services/<service-name>
dotnet run
```

## Run ai-service (Python)
```bash
cd services/ai-service
pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8092 --reload
```

## Docker Compose (full infra, no dev)
```bash
cd deploy
cp envs/*.env .env  # fill in secrets first
docker compose up -d
docker compose logs -f <service-name>
```

## Stop AppHost
Press `Ctrl+C` in the terminal running AppHost.

## Restart a specific service
Restart the AppHost session, or run the service directly:
```bash
cd services/<service-name>
dotnet run
```