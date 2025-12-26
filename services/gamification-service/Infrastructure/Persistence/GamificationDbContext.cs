using gamification_service.Domains.Entities;
using Microsoft.EntityFrameworkCore;

namespace gamification_service.Infrastructure.Persistence;

public class GamificationDbContext : DbContext
{
    public GamificationDbContext(DbContextOptions<GamificationDbContext> options) : base(options) { }

    public DbSet<UserStats> UserStats => Set<UserStats>();
    public DbSet<Achievement> Achievements => Set<Achievement>();
    public DbSet<UserAchievement> UserAchievements => Set<UserAchievement>();
    public DbSet<XpTransaction> XpTransactions => Set<XpTransaction>();
    public DbSet<Notification> Notifications => Set<Notification>();
    public DbSet<UserNotificationSettings> UserNotificationSettings => Set<UserNotificationSettings>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<UserStats>(e =>
        {
            e.HasKey(x => x.Id);
            e.HasIndex(x => x.UserId).IsUnique();
        });

        modelBuilder.Entity<Achievement>(e =>
        {
            e.HasKey(x => x.Id);
            e.HasIndex(x => x.Slug).IsUnique();
        });

        modelBuilder.Entity<UserAchievement>(e =>
        {
            e.HasKey(x => x.Id);
            e.HasIndex(x => new { x.UserId, x.AchievementId }).IsUnique();
            e.HasOne(x => x.Achievement)
                .WithMany(a => a.UserAchievements)
                .HasForeignKey(x => x.AchievementId);
        });

        modelBuilder.Entity<XpTransaction>(e =>
        {
            e.HasKey(x => x.Id);
            e.HasIndex(x => x.UserId);
            e.HasIndex(x => x.CreatedAt);
        });

        modelBuilder.Entity<Notification>(e =>
        {
            e.HasKey(x => x.Id);
            e.HasIndex(x => x.UserId);
            e.HasIndex(x => new { x.UserId, x.IsRead });
            e.HasIndex(x => x.CreatedAt);
        });

        modelBuilder.Entity<UserNotificationSettings>(e =>
        {
            e.HasKey(x => x.UserId);
        });
    }
}

