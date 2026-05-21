using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace exam_service.Infrastructure.Persistence;

public class ExamDbContextFactory : IDesignTimeDbContextFactory<ExamDbContext>
{
    public ExamDbContext CreateDbContext(string[] args)
    {
        var options = new DbContextOptionsBuilder<ExamDbContext>()
            .UseNpgsql("Host=localhost;Database=langfens_exam;Username=postgres;Password=postgres")
            .Options;
        return new ExamDbContext(options);
    }
}