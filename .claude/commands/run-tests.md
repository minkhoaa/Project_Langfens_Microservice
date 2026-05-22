# Run tests for the project

## Single service tests
```bash
cd services/<service-name>
dotnet test
```

## All tests
```bash
dotnet test Project_Langfens_Microservice.sln
```

## Single test project
```bash
dotnet test services/<service-name>/<service-name>.csproj
```

## With coverage
```bash
dotnet test --collect:"XPlat Code Coverage"
```

## Verbose output
```bash
dotnet test --verbosity normal
```