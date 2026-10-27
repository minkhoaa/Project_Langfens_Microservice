# Dictionary service
PostgreSQL word lookup/bulk import, not Elasticsearch; no RabbitMQ integration.

- `Features/Service/DictionaryService.cs` queries `WordNorm`; `Features/Helper/DictionaryDtoMapper.cs` shapes responses.
- Startup migrates and creates `pg_trgm`/GIN index; the database role needs those permissions.
- Preserve word normalization, import idempotency and response shape, including legacy `DictionaryDoc` fields.
- `Program.cs` permits large request/form bodies; assess streaming/memory before changing limits.
- Lookup/import integration checks require disposable service-owned PostgreSQL, including repeat-import cases.
