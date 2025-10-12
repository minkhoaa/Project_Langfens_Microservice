using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Shared.ExamDto.Contracts.Course.Enums;

namespace course_service.Domains.Entities
{
    public class Course
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public Guid Id { get; set; }
        [Required, MaxLength(255)] public string Slug { get; set; } = default!;
        [Required] public string Title { get; set; } = default!;
        public string? DescriptionMd { get; set; }
        [MaxLength(100)]
        public string? Category { get; set; } = CourseCategories.GENERAL_ENGLISH;
        [MaxLength(50)] public string? Level { get; set; }
        [MaxLength(20)] public string Status { get; set; } = CourseStatus.Draft;


        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }

        public ICollection<Lesson> Lessons { get; set; } = [];
        public ICollection<Enrollment> Enrollments { get; set; } = [];
    }
}