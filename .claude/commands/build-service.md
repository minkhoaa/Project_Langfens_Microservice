# Build a single service and its shared dependencies

Builds the specified service along with the shared libraries it depends on.
Run from the project root or a service directory.

```bash
cd services/<service-name> && dotnet build
```

For full solution build:
```bash
dotnet build Project_Langfens_Microservice.sln
```

To build only the shared libs first (recommended before building a service):
```bash
dotnet build services/_shared/Shared.Bootstrap/Shared.Bootstrap.csproj
dotnet build services/_shared/Shared.Grpc/Shared.Grpc.csproj
dotnet build services/_shared/Shared.PublicContracts/Shared.PublicContracts.csproj
dotnet build services/_shared/Shared.Security/Shared.Security.csproj
dotnet build services/_shared/Shared.ServiceDefaults/Shared.ServiceDefaults.csproj
```

To rebuild all services (useful after shared lib changes):
```bash
dotnet build Project_Langfens_Microservice.sln
```