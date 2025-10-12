using System.ComponentModel.DataAnnotations;

namespace course_service.Domains.Entities
{
    public class Lesson
    {
        [Key] public Guid Id { get; set; }
        public Guid CourseId { get; set; }
        public int Idx { get; set; }
        [Required] public string Title { get; set; } = default!;
        public string? ContentMd { get; set; }
        public int? DurationMin { get; set; }
        public Course Course { get; set; } = default!;
        public ICollection<LessonCompletion> LessonCompletions { get; set; } = [];
    }
}
