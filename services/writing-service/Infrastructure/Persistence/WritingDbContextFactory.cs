using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;

namespace writing_service.Infrastructure.Persistence;

public class WritingDbContextFactory : IDesignTimeDbContextFactory<WritingDbContext>
{
    public WritingDbContext CreateDbContext(string[] args)
    {
        var configuration = new ConfigurationBuilder()
            .SetBasePath(Directory.GetCurrentDirectory())
            .AddJsonFile("appsettings.json", optional: true)
            .AddEnvironmentVariables()
            .Build();

        var connectionString = Environment.GetEnvironmentVariable("CONNECTIONSTRING__WRITING")
            ?? configuration.GetConnectionString("Writing_DB")
            ?? configuration.GetConnectionString("writing-db")
            ?? "Host=localhost;Port=5440;Database=writing-db;Username=writing;Password=writing";

        var optionsBuilder = new DbContextOptionsBuilder<WritingDbContext>();
        optionsBuilder.UseNpgsql(connectionString);
        return new WritingDbContext(optionsBuilder.Options);
    }
}
