using course_service.Domains.Entities;
using Microsoft.EntityFrameworkCore;

namespace course_service.Infrastructure
{
    public class CourseDbContext : DbContext
    {
        public CourseDbContext(DbContextOptions<CourseDbContext> options) : base(options) { }
        protected override void OnModelCreating(ModelBuilder model)
        {
            base.OnModelCreating(model);
            model.Entity<Course>(course =>
            {
                course.ToTable("course");
                course.HasIndex(x => x.Slug).IsUnique();
                course.HasIndex(x => new { x.Status, x.Category, x.Level });

            });
            model.Entity<Lesson>(e =>
            {
                e.ToTable("lesson");
                e.HasOne(x => x.Course)
                .WithMany(c => c.Lessons)
                .HasForeignKey(x => x.CourseId)
                .OnDelete(DeleteBehavior.Cascade);
                e.HasIndex(x => new { x.CourseId, x.Idx }).IsUnique();
            });
            model.Entity<Enrollment>(e =>
            {
                e.ToTable("enrollment");
                e.HasOne(x => x.Course)
                .WithMany(x => x.Enrollments)
                .HasForeignKey(x => x.CourseId)
                .OnDelete(DeleteBehavior.Cascade);
                e.HasIndex(x => new { x.UserId, x.CourseId }).IsUnique();
            });
            model.Entity<LessonCompletion>(e =>
            {
                e.ToTable("lesson_completion");
                e.HasOne(x => x.Lesson)
                .WithMany(x => x.LessonCompletions)
                .HasForeignKey(x => x.LessonId)
                .OnDelete(DeleteBehavior.Cascade);
                e.HasIndex(x => new { x.UserId, x.LessonId }).IsUnique();
            });

        }
        public DbSet<Lesson> Lessons { get; set; }
        public DbSet<Enrollment> Enrollments { get; set; }
        public DbSet<LessonCompletion> LessonCompletions { get; set; }
        public DbSet<Course> Courses { get; set; }



    }
}