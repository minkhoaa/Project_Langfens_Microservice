using exam_service.Infrastructure.Persistence;
using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;

namespace ExamService.UnitTest;

public static class SqlTestHelper
{
    public static (ExamDbContext ctx, SqliteConnection conn) CreateInMemory()
    {
        var conn = new SqliteConnection("Filename=:memory:");
        conn.Open();

        var options = new DbContextOptionsBuilder<ExamDbContext>()
            .UseSqlite(conn)
            .EnableDetailedErrors()
            .EnableSensitiveDataLogging()
            .Options;

        var ctx = new ExamDbContext(options);
        ctx.Database.EnsureCreated();

        return (ctx, conn);
    }
}