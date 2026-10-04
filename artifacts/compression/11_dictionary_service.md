# 11 — dictionary-service

> Source-of-truth: `services/dictionary-service/*`. Verified by direct reads.

## Role in the system

IELTS dictionary: word lookup + suggestions + bulk import. **Note**: the older CLAUDE.md mentions Elasticsearch, but `dictionary-service.csproj` no longer references `Elastic.Clients.Elasticsearch` and the runtime uses **PostgreSQL with pg_trgm** for similarity search — see `Program.cs` migration script:

```csharp
await context.Database.ExecuteSqlRawAsync(
    "CREATE EXTENSION IF NOT EXISTS pg_trgm; CREATE INDEX IF NOT EXISTS ix_dictionary_wordnorm_trgm ON dictionary USING GIN (\"WordNorm\" gin_trgm_ops);");
```

`Features/DictionaryDoc.cs` comment confirms: "Same shape previously sent to Elasticsearch, now built directly from EF." — Elasticsearch is no longer in the actual code path.

## Stack

- ASP.NET Core 10, EF Core + Npgsql (`NonRetryingExecutionStrategy`).
- PostgreSQL `pg_trgm` extension + GIN index on `WordNorm`.
- Kestrel `MaxRequestBodySize = null`; `FormOptions.MultipartBodyLengthLimit = long.MaxValue`.
- **No RabbitMQ, no auth (no `AddLangfensAuth` call)** — anonymous endpoints; `AddLangfensSwagger` only.

## Persistence

`DictionaryDbContext` (table `dictionary` with `WordNorm` column for trigram lookup). Migration script in `Program.cs` ensures `pg_trgm` extension + GIN index exist after `MigrateAsync`.

## Endpoints (`/api/dictionary`)

`Features/DictionaryEndpoint.cs`:

| Method | Path | Notes |
|---|---|---|
| GET | `/api/dictionary/suggest?word=&pos?` | trigram suggestions |
| GET | `/api/dictionary/lookup?word=` | full lookup |
| GET | `/api/dictionary/details/{id}` | entry by id |
| POST | `/api/dictionary/import` | multipart `IFormFile`, optional `maxLines`; Antiforgery disabled; `DisableRequestSizeLimitAttribute` |

## Service surface

- `IDictionaryService.GetSuggests(word, pos?, token)` — trigram similarity via `_context.Dictionary`.
- `IDictionaryService.LookupWord(word, token)` — exact match.
- `IDictionaryService.GetDetails(id, token)` — full record + senses.
- `IDictionaryService.Import(file, maxLines?, ct)` — large-file bulk insert.
- `IDictionaryDtoMapper` (singleton) — projection from `DictionaryEntry` → DTO (max senses 10, max examples per sense 2).
- `IEnViTranslator` registered as `NullEnViTranslator` (no-op stub).

## Health checks

- `dictionary-db` (NpgSql).
- No ES health check (ES is not in use).

## Environment variables (verified)

| Key | Default | Purpose |
|---|---|---|
| `ELASTICSEARCH__URL` | `http://elasticsearch:9200` | retained in env but **unused at runtime** |
| `ELASTICSEARCH__INDEXALIAS` | `dictionary_current` | retained but unused |
| `ConnectionStrings__dictionary-db` | Aspire-injected | required |

The Elasticsearch URL still appears in `deploy/envs/dictionary.env`, but the code path does not read or call it.

## Notable design points

- Direct query (EF) without an external search engine reduces infra footprint at the cost of being limited to what `pg_trgm` can offer.
- Import endpoint supports very large files (multipart limit `long.MaxValue`).
