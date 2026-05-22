# Add a new .NET service to the mono-repo

Creates a new service following Langfens conventions. Run from the project root.

## Steps

1. **Create the project** in `services/<name>-service/`:
   ```bash
   dotnet new webapi -n <name>-service -o services/<name>-service --no-https
   ```

2. **Add to solution**:
   ```bash
   dotnet sln Project_Langfens_Microservice.sln add services/<name>-service/<name>-service.csproj
   ```

3. **Add shared lib references**:
   ```bash
   dotnet add services/<name>-service/<name>-service.csproj reference services/_shared/Shared.ServiceDefaults/Shared.ServiceDefaults.csproj
   dotnet add services/<name>-service/<name>-service.csproj reference services/_shared/Shared.Bootstrap/Shared.Bootstrap.csproj
   dotnet add services/<name>-service/<name>-service.csproj reference services/_shared/Shared.Security/Shared.Security.csproj
   ```

4. **Add to AppHost** (`AppHost/Program.cs`):
   ```csharp
   var myService = builder.AddProject("<name>-service", "../services/<name>-service/<name>-service.csproj")
       .WithReference(myDb)
       .WithReference(rabbitmq)
       .WithComposeEnvFile("<name>")
       .WaitFor(myDb)
       .WaitFor(rabbitmq);
   ```

5. **Add gateway route** (`gateway/api-gateway/appsettings.json`) under `Routes` and `Clusters`:
   ```json
   "<name>-api": {
     "ClusterId": "<name>-cluster",
     "Match": { "Path": "/api-<name>/{**catch-all}" },
     "Transforms": [{ "PathRemovePrefix": "/api-<name>" }, { "PathPrefix": "/api" }]
   }
   ```
   ```json
   "<name>-cluster": {
     "Destinations": { "d1": { "Address": "http://<name>-service:8080" } }
   }
   ```

6. **Add to Docker Compose** (`deploy/compose.yaml`):
   - Add service entry with image, ports, depends_on
   - Add env_file reference: `path: ./envs/<name>.env`
   - Add database container if needed

7. **Create env file**:
   ```bash
   touch deploy/envs/<name>.env
   ```

8. **Create CLAUDE.md**:
   ```bash
   touch services/<name>-service/CLAUDE.md
   ```

9. **Create Program.cs pattern**:
   ```csharp
   var builder = WebApplication.CreateBuilder(args);
   builder.AddServiceDefaults();
   builder.Services.AddLangfensAuth(key => Environment.GetEnvironmentVariable(key));
   builder.Services.AddLangfensCors();
   builder.Services.AddLangfensSwagger("<name> Service");
   // ... your service setup
   var app = builder.Build();
   app.UseCors("FE");
   app.UseAuthentication();
   app.UseAuthorization();
   app.Run();
   ```

10. **Build to verify**:
    ```bash
    dotnet build services/<name>-service/<name>-service.csproj
    ```