using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace ExamService.Infrastructure.Persistence;

public class ExamDbContextFactory : IDesignTimeDbContextFactory<ExamDbContext>
{
    public ExamDbContext CreateDbContext(string[] args)
    {
        var options = new DbContextOptionsBuilder<ExamDbContext>()
            .UseNpgsql("Host=localhost;Database=exam-db;Username=exam;Password=exam;Port=5433")
            .Options;
        return new ExamDbContext(options);
    }
}