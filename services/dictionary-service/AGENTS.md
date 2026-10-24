# Dictionary service
Word lookup and bulk import using PostgreSQL; legacy Elasticsearch instructions are obsolete.

- `Features/DictionaryEndpoint.cs` maps APIs; `Features/Service/DictionaryService.cs` performs lookup/import.
- `Infrastructure/Persistence/DictionaryDbContext.cs` owns data; `Features/Helper/DictionaryDtoMapper.cs` maps responses.
- Search uses PostgreSQL `pg_trgm`/`WordNorm`; there is no active Elasticsearch client/indexer or RabbitMQ integration.
- Startup migrates, creates `pg_trgm` and the GIN index; deployment DB permissions must support these operations.
- Preserve normalization, response shape and import idempotency; `DictionaryDoc` retains a historical search-document shape.
- Bulk imports intentionally allow large request/form bodies in `Program.cs`; inspect streaming/memory impact before changing limits.
- Build from root: `dotnet build services/dictionary-service/dictionary-service.csproj`.
- No dedicated test project exists; lookup/import integration checks need a disposable service-owned PostgreSQL database.
