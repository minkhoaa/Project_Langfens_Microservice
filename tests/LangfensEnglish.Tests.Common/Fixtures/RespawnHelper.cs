using Npgsql;
using Respawn;
using Respawn.Graph;

namespace LangfensEnglish.Tests.Common.Fixtures;

public static class RespawnHelper
{
    public static async Task ResetDatabaseAsync(string connectionString, Respawner? respawner = null)
    {
        if (string.IsNullOrWhiteSpace(connectionString))
        {
            return;
        }

        await using var connection = new NpgsqlConnection(connectionString);
        await connection.OpenAsync();

        var options = new RespawnerOptions
        {
            DbAdapter = DbAdapter.Postgres,
            SchemasToInclude = ["public"],
            TablesToIgnore = new[] { new Table("__EFMigrationsHistory") }
        };

        if (respawner is not null)
        {
            await respawner.ResetAsync(connection);
            return;
        }

        var instance = await Respawner.CreateAsync(connection, options);
        await instance.ResetAsync(connection);
    }
}
