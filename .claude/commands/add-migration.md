# Add EF Core migration to a service

Creates a new migration for the specified service. Run from the service directory.

```bash
cd services/<service-name>
dotnet ef migrations add <MigrationName> --project <service>.csproj --output-dir Migrations
```

## Apply migrations (auto-runs on startup, but can be done manually)
```bash
cd services/<service-name>
dotnet ef database update --project <service>.csproj
```

## Remove last migration (if not applied)
```bash
cd services/<service-name>
dotnet ef migrations remove --project <service>.csproj
```

## List pending migrations
```bash
cd services/<service-name>
dotnet ef migrations list --project <service>.csproj
```

**Important**: Always add `--output-dir Migrations` to keep migrations in a dedicated folder.

Services using EF Core with Npgsql:
- auth-service
- exam-service
- attempt-service
- vocabulary-service
- speaking-service
- writing-service
- course-service
- gamification-service
- dictionary-service