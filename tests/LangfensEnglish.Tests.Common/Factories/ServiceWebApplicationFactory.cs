using LangfensEnglish.Tests.Common.Fixtures;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.TestHost;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

namespace LangfensEnglish.Tests.Common.Factories;

public abstract class ServiceWebApplicationFactory<TProgram> : WebApplicationFactory<TProgram>
    where TProgram : class
{
    private readonly string _databaseName;
    private readonly PostgresContainerFixture _postgres;
    private string? _connectionString;

    protected ServiceWebApplicationFactory(PostgresContainerFixture postgres, string databaseName)
    {
        _postgres = postgres;
        _databaseName = databaseName;
    }

    protected string ConnectionString => _connectionString ?? throw new InvalidOperationException("Connection string not initialized");
    protected PostgresContainerFixture Postgres => _postgres;

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        EnsureDatabaseAsync().GetAwaiter().GetResult();
        builder.UseEnvironment("Testing");
        builder.ConfigureAppConfiguration((_, configurationBuilder) =>
        {
            var overrides = BuildConfigurationOverrides();
            configurationBuilder.AddInMemoryCollection(overrides);
        });

        builder.ConfigureTestServices(ConfigureTestServices);
    }

    protected override IHost CreateHost(IHostBuilder builder)
    {
        EnsureDatabaseAsync().GetAwaiter().GetResult();
        var host = base.CreateHost(builder);
        RunMigrationsAsync(host.Services).GetAwaiter().GetResult();
        return host;
    }

    protected virtual void ConfigureTestServices(IServiceCollection services)
    {
    }

    protected abstract Task RunMigrationsAsync(IServiceProvider services);

    protected abstract Dictionary<string, string?> BuildConfigurationOverrides();

    protected async Task EnsureDatabaseAsync()
    {
        if (_connectionString is not null)
        {
            return;
        }

        _connectionString = await _postgres.GetConnectionStringAsync(_databaseName);
    }
}
