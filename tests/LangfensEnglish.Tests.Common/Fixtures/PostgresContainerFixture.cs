using System.Collections.Concurrent;
using Npgsql;
using Respawn;
using Respawn.Graph;
using Testcontainers.PostgreSql;
using Xunit;

namespace LangfensEnglish.Tests.Common.Fixtures;

public class PostgresContainerFixture : IAsyncLifetime
{
    private readonly PostgreSqlContainer _container;
    private readonly ConcurrentDictionary<string, bool> _createdDatabases = new(StringComparer.OrdinalIgnoreCase);

    public PostgresContainerFixture()
    {
        _container = new PostgreSqlBuilder()
            .WithImage("postgres:16-alpine")
            .WithDatabase("langfens")
            .WithUsername("postgres")
            .WithPassword("postgres")
            .WithCleanUp(true)
            .Build();
    }

    public string AdminConnectionString => _container.GetConnectionString();

    public async Task InitializeAsync()
    {
        await _container.StartAsync();
    }

    public Task DisposeAsync() => _container.DisposeAsync().AsTask();

    public async Task<string> GetConnectionStringAsync(string databaseName)
    {
        if (string.IsNullOrWhiteSpace(databaseName))
        {
            return AdminConnectionString;
        }

        await EnsureDatabaseExistsAsync(databaseName);
        var builder = new NpgsqlConnectionStringBuilder(AdminConnectionString)
        {
            Database = databaseName
        };
        return builder.ToString();
    }

    private async Task EnsureDatabaseExistsAsync(string databaseName)
    {
        if (_createdDatabases.ContainsKey(databaseName))
        {
            return;
        }

        await using var connection = new NpgsqlConnection(AdminConnectionString);
        await connection.OpenAsync();

        await using (var check = connection.CreateCommand())
        {
            check.CommandText = "select 1 from pg_database where datname = @name;";
            check.Parameters.AddWithValue("name", databaseName);
            var exists = await check.ExecuteScalarAsync();
            if (exists is not null && exists is int or long)
            {
                _createdDatabases.TryAdd(databaseName, true);
                return;
            }
        }

        await using (var create = connection.CreateCommand())
        {
            create.CommandText = $"create database \"{databaseName}\";";
            await create.ExecuteNonQueryAsync();
        }

        _createdDatabases.TryAdd(databaseName, true);
    }

    public async Task<Respawner> CreateRespawnerAsync(string connectionString)
    {
        await using var connection = new NpgsqlConnection(connectionString);
        await connection.OpenAsync();

        var options = new RespawnerOptions
        {
            DbAdapter = DbAdapter.Postgres,
            SchemasToInclude = ["public"],
            TablesToIgnore = new[] { new Table("__EFMigrationsHistory") }
        };

        return await Respawner.CreateAsync(connection, options);
    }
}
