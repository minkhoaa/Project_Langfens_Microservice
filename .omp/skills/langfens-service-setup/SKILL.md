---
name: langfens-service-setup
description: End-to-end workflow to scaffold and integrate a new microservice into Langfens with shared libraries, Aspire AppHost, YARP gateway, and PostgreSQL.
---

# Adding a New Microservice to Langfens

Follow this systematic 7-step workflow whenever introducing a new microservice to the Langfens platform.

## Step 1: Scaffold Project Directory
Create `services/<name>-service/<name>-service.csproj`:
```xml
<Project Sdk="Microsoft.NET.Sdk.Web">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>

  <ItemGroup>
    <ProjectReference Include="..\..\services\_shared\Shared.Bootstrap\Shared.Bootstrap.csproj" />
    <ProjectReference Include="..\..\services\_shared\Shared.ServiceDefaults\Shared.ServiceDefaults.csproj" />
    <ProjectReference Include="..\..\services\_shared\Shared.Security\Shared.Security.csproj" />
    <ProjectReference Include="..\..\services\_shared\Shared.PublicContracts\Shared.PublicContracts.csproj" />
  </ItemGroup>
</Project>
```

## Step 2: Configure `Program.cs`
Implement standard Langfens startup:
```csharp
var builder = WebApplication.CreateBuilder(args);

// Aspire service defaults (OTel, health checks, discovery)
builder.AddServiceDefaults();

// Langfens standard bootstrap
builder.Services.AddLangfensAuth(builder.Configuration);
builder.Services.AddLangfensCors(builder.Configuration);
builder.Services.AddLangfensSwagger("<Service Name> API");

// Add EF Core DbContext with Npgsql
builder.Services.AddDbContext<MyDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("mysvc-db")));

var app = builder.Build();

app.UseLangfensCors();
app.UseLangfensAuth();
app.UseLangfensSwagger();

// Map Minimal API endpoint groups
app.MapMyEndpoints();

await app.RunAsync();
```

## Step 3: Wire into Aspire `AppHost/Program.cs`
1. Allocate database credentials and persistent server on an unassigned port (e.g. 545X).
2. Attach project with `.WithReference(db)` and `.WithRabbitMqEnv(...)`.
3. Inject dynamic endpoint into YARP gateway overrides.

## Step 4: Add YARP Route to `gateway/api-gateway/appsettings.json`
Add cluster and route mappings:
```json
"ReverseProxy": {
  "Routes": {
    "mysvc-route": {
      "ClusterId": "mysvc-cluster",
      "Match": { "Path": "/api-mysvc/{**catch-all}" },
      "Transforms": [{ "PathRemovePrefix": "/api-mysvc" }]
    }
  },
  "Clusters": {
    "mysvc-cluster": {
      "Destinations": {
        "d1": { "Address": "http://mysvc-service:8080" }
      }
    }
  }
}
```

## Step 5: Add to Solution
```bash
dotnet sln Project_Langfens_Microservice.sln add services/<name>-service/<name>-service.csproj
```

## Step 6: Create Service Documentation
Create `services/<name>-service/CLAUDE.md` detailing:
- Service purpose and port
- Architecture and folder structure
- Database migrations and dependencies
- Communicating services and message queues

## Step 7: Verify
```bash
dotnet build Project_Langfens_Microservice.sln
```
