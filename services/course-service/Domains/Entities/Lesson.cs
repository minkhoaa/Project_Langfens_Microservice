using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace course_service.Domains.Entities
{
    public class Lesson
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public Guid Id { get; set; }
        public Guid CourseId { get; set; }
        public int Idx { get; set; }
        [Required] public string Title { get; set; } = default!;
        public string? ContentMd { get; set; }
        public int? DurationMin { get; set; }
        
        /// <summary>
        /// Optional link to exam-service exam for quiz/exercise
        /// </summary>
        public Guid? QuizExamId { get; set; }
        
        public Course Course { get; set; } = default!;
        public ICollection<LessonCompletion> LessonCompletions { get; set; } = [];
    }
}
