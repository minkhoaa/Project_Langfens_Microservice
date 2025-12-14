using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;

namespace TestSupport;

public static class SqliteInMemoryFactory
{
    public static SqliteContextHandle<TContext> Create<TContext>()
        where TContext : DbContext
    {
        var connection = new SqliteConnection("Filename=:memory:");
        connection.Open();

        var options = new DbContextOptionsBuilder<TContext>()
            .UseSqlite(connection)
            .EnableDetailedErrors()
            .EnableSensitiveDataLogging()
            .Options;

        var context = (TContext?)Activator.CreateInstance(typeof(TContext), options)
                      ?? throw new InvalidOperationException($"Unable to construct {typeof(TContext).Name}");
        context.Database.EnsureCreated();
        return new SqliteContextHandle<TContext>(context, connection);
    }
}

public sealed class SqliteContextHandle<TContext> : IAsyncDisposable, IDisposable
    where TContext : DbContext
{
    public SqliteContextHandle(TContext context, SqliteConnection connection)
    {
        Context = context;
        Connection = connection;
    }

    public TContext Context { get; }
    public SqliteConnection Connection { get; }

    public async ValueTask DisposeAsync()
    {
        await Context.DisposeAsync();
        await Connection.DisposeAsync();
    }

    public void Dispose()
    {
        Context.Dispose();
        Connection.Dispose();
    }
}
