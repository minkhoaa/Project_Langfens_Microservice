using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using dictionary_service.Domains.Entities;
using Microsoft.EntityFrameworkCore;

namespace dictionary_service.Infrastructure.Persistence
{
    public class DictionaryDbContext : DbContext
    {
        public DictionaryDbContext(DbContextOptions<DictionaryDbContext> options) : base(options) { }

        public DbSet<DictionaryEntry> Dictionary => Set<DictionaryEntry>();

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<DictionaryEntry>(e =>
            {
                e.ToTable("dictionary");
                e.HasKey(x => x.Id);

                e.Property(x => x.Data).HasColumnType("jsonb");
                e.HasIndex(x => x.WordNorm);
                e.HasIndex(x => x.Pos);
            });
        }
    }
}