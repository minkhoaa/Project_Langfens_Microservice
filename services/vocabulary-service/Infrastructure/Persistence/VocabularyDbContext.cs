using Microsoft.EntityFrameworkCore;
using vocabulary_service.Domains.Entities;

namespace vocabulary_service.Infrastructure.Persistence;

public class VocabularyDbContext(DbContextOptions<VocabularyDbContext> options) : DbContext(options)
{
    protected override void OnModelCreating(ModelBuilder app)
    { 
        base.OnModelCreating(app);
        app.Entity<Deck>(e =>
        {
            e.ToTable("deck");
            e.HasKey(x => x.Id);
            e.HasIndex(x => x.Slug);
            e.HasIndex(x => new { x.Status, x.Category });
            e.HasIndex(x => x.UserId);
            e.HasIndex(x => new { x.UserId, x.Status });
        });
        app.Entity<Card>(e =>
        {
            e.ToTable("card");
            e.HasOne(a => a.Deck).WithMany(a => a.Cards).HasForeignKey(x => x.DeckId).OnDelete(DeleteBehavior.Cascade);
            e.HasIndex(a => new { a.DeckId, a.Idx }).IsUnique();
        });
        app.Entity<UserDeck>(e =>
        {
            e.ToTable("user_deck");
            e.HasOne(x => x.Deck).WithMany(x=>x.UserDecks)
                .HasForeignKey(x => x.DeckId)
                .OnDelete(DeleteBehavior.Cascade);
            e.HasIndex(x => new { x.UserId, x.DeckId }).IsUnique();
            e.HasIndex(x => new { x.DeckId, x.Status });
        });
        app.Entity<UserCardReview>(e =>
        {
            e.ToTable("user_card_review_state");
            e.HasOne(x => x.Card)
                .WithMany(x=>x.UserCardReviews)
                .HasForeignKey(x => x.CardId)
                .OnDelete(DeleteBehavior.Cascade);
            e.HasIndex(x => new { x.UserId, x.CardId }).IsUnique();
            e.HasIndex(x => x.DueAt); 
        });
        app.Entity<ReviewLog>(e =>
        {
            e.ToTable("review_log");
            e.HasOne(x => x.Card).WithMany(x => x.ReviewLogs)
                .OnDelete(DeleteBehavior.Cascade)
                .HasForeignKey(x=>x.CardId);
            e.HasIndex(x => new { x.UserId, x.CardId, x.ReviewedAt });
        });
    }

    public DbSet<Card> Cards { get; set; }
    public DbSet<Deck> Decks { get; set; }
    public DbSet<ReviewLog> ReviewLogs { get; set; }
    public DbSet<UserCardReview> UserCardReviews { get; set; }
    public DbSet<UserDeck> UserDecks { get; set; }
}
