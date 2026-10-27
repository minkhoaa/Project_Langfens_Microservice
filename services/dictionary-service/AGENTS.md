# Dictionary service
PostgreSQL word lookup/bulk import, not Elasticsearch; no RabbitMQ integration.

- `Features/Service/DictionaryService.cs` queries `WordNorm`; `Features/Helper/DictionaryDtoMapper.cs` shapes responses.
- Startup migrates and creates `pg_trgm`/GIN index; the database role needs those permissions.
- Preserve normalization, import idempotency and response shape, including legacy `DictionaryDoc` fields.
- `Program.cs` deliberately permits large request/form bodies; assess streaming/memory before changing limits.
- No dedicated tests; lookup/import integration checks require disposable service-owned PostgreSQL.
