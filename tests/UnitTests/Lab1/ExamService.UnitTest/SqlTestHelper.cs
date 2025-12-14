using exam_service.Domains.Entities;
using exam_service.Infrastructure.Persistence;
using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.ChangeTracking;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;
using System.Text.Json;

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

        var ctx = new ExamDbContextTest(options);
        ctx.Database.EnsureCreated();

        return (ctx, conn);
    }

    private sealed class ExamDbContextTest : ExamDbContext
    {
        public ExamDbContextTest(DbContextOptions<ExamDbContext> options) : base(options)
        {
        }

        private static string? SerializeDict(Dictionary<string, string[]?>? value) =>
            value == null ? null : JsonSerializer.Serialize(value, (JsonSerializerOptions?)null);

        private static Dictionary<string, string[]?>? DeserializeDict(string? value) =>
            string.IsNullOrWhiteSpace(value)
                ? null
                : JsonSerializer.Deserialize<Dictionary<string, string[]?>>(value!)!;

        private static string? SerializeList(List<string>? value) =>
            value == null ? null : JsonSerializer.Serialize(value, (JsonSerializerOptions?)null);

        private static List<string> DeserializeList(string? value) =>
            string.IsNullOrWhiteSpace(value)
                ? new List<string>()
                : JsonSerializer.Deserialize<List<string>>(value!) ?? new List<string>();

        private static bool DictEquals(Dictionary<string, string[]?>? left, Dictionary<string, string[]?>? right) =>
            SerializeDict(left) == SerializeDict(right);

        private static int DictHash(Dictionary<string, string[]?>? value)
        {
            var serialized = SerializeDict(value);
            return serialized == null ? 0 : serialized.GetHashCode();
        }

        private static Dictionary<string, string[]?>? DictSnapshot(Dictionary<string, string[]?>? value) =>
            DeserializeDict(SerializeDict(value));

        private static bool ListEquals(List<string>? left, List<string>? right) =>
            SerializeList(left) == SerializeList(right);

        private static int ListHash(List<string>? value)
        {
            var serialized = SerializeList(value);
            return serialized == null ? 0 : serialized.GetHashCode();
        }

        private static List<string> ListSnapshot(List<string>? value) =>
            DeserializeList(SerializeList(value));

        protected override void OnModelCreating(ModelBuilder mb)
        {
            base.OnModelCreating(mb);

            var dictConverter = new ValueConverter<Dictionary<string, string[]?>?, string?>(
                v => SerializeDict(v),
                v => DeserializeDict(v));
            var dictComparer = new ValueComparer<Dictionary<string, string[]?>?>(
                (l, r) => DictEquals(l, r),
                v => DictHash(v),
                v => DictSnapshot(v));

            var listConverter = new ValueConverter<List<string>?, string?>(
                v => SerializeList(v),
                v => DeserializeList(v));
            var listComparer = new ValueComparer<List<string>?>(
                (l, r) => ListEquals(l, r),
                v => ListHash(v),
                v => ListSnapshot(v));

            mb.Entity<ExamQuestion>(e =>
            {
                e.Property(x => x.BlankAcceptRegex).HasConversion(dictConverter).Metadata.SetValueComparer(dictComparer);
                e.Property(x => x.BlankAcceptTexts).HasConversion(dictConverter).Metadata.SetValueComparer(dictComparer);
                e.Property(x => x.MatchPairs).HasConversion(dictConverter).Metadata.SetValueComparer(dictComparer);
                e.Property(x => x.OrderCorrects).HasConversion(listConverter).Metadata.SetValueComparer(listComparer);
                e.Property(x => x.ShortAnswerAcceptTexts).HasConversion(listConverter).Metadata.SetValueComparer(listComparer);
                e.Property(x => x.ShortAnswerAcceptRegex).HasConversion(listConverter).Metadata.SetValueComparer(listComparer);
            });
        }
    }
}
