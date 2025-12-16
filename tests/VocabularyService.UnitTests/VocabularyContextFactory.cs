using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Diagnostics;
using vocabulary_service.Infrastructure.Persistence;

namespace VocabularyService.UnitTests
{
    public static class VocabularyContextFactory
    {
        public static VocabularyDbContext CreateInMemory()
        {
            var options = new DbContextOptionsBuilder<VocabularyDbContext>()
                .UseInMemoryDatabase(Guid.NewGuid().ToString())
                .ConfigureWarnings(x => x.Ignore(InMemoryEventId.TransactionIgnoredWarning))
                .Options;

            var context = new TestVocabularyDbContext(options);
            context.Database.EnsureCreated();
            return context;
        }

        private class TestVocabularyDbContext : VocabularyDbContext
        {
            public TestVocabularyDbContext(DbContextOptions<VocabularyDbContext> options) : base(options) { }
            
            // Add ValueConverters in OnModelCreating if needed for complex types. 
            // Looking at VocabularyDbContext.cs, no obvious JSON types or arrays requiring special handling for basic Deck/Card tests.
            // Deck has Indexes using strings/enums, Card has relationships. 
            // Should be fine with default InMemory support.
        }
    }
}
