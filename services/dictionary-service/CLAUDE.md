# dictionary-service

Word lookup service backed by Elasticsearch with PostgreSQL for metadata persistence.

## Service Overview
- **Port**: 8094 (HTTP)
- **Stack**: ASP.NET Core 10, EF Core + Npgsql, Elasticsearch (NEST/Elastic.Clients.Elasticsearch)
- **Database**: PostgreSQL via DictionaryDbContext (word metadata, import history)
- **Search**: Elasticsearch (Elastic.Clients.Elasticsearch) for full-text word search
- **No RabbitMQ**: Synchronous HTTP only

## Key Files
```
Program.cs                           Entry point; large upload config
Infrastructure/
  Persistence/DictionaryDbContext.cs EF Core DbContext
  Migrations/                        EF Core migrations
Features/
  Endpoint/                          REST endpoints (word search, lookup, import)
  Service/
    DictionaryService.cs             IDictionaryService implementation
    ElasticIndexer.cs                Syncs words to Elasticsearch index
  Helper/
    DictionaryDtoMapper.cs           IDictionaryDtoMapper (singleton)
```

## Common Operations

### Adding a new word lookup endpoint
1. Add method to `IDictionaryService` + `DictionaryService.cs`
2. Map in `Features/Endpoint/`
3. Register `app.MapDictionaryEndpoint()` in `Program.cs`

### Indexing words in Elasticsearch
- `ElasticIndexer` class handles document indexing
- `ElasticsearchClient` registered as singleton
- Index name configured via env or `appsettings.json`

### Large file import
- `Program.cs` sets `MaxRequestBodySize = null` and `MultipartBodyLengthLimit = long.MaxValue`
- Accepts large file uploads for bulk word import

### DB Migrations
```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/dictionary-service
dotnet ef migrations add <Name> --project dictionary-service.csproj --output-dir Migrations
dotnet ef database update --project dictionary-service.csproj
```

## How This Service Communicates with Others
- **No RabbitMQ**: Standalone service, consumed by frontend directly
- **Elasticsearch**: Primary search engine for word lookups

## Health Checks
- PostgreSQL (`dictionary-db`)
- Elasticsearch (`elasticsearch`)

## Environment Variables
```
ELASTICSEARCH__URL (default: http://elasticsearch:9200),
Aspire: dictionary-db connection string
```