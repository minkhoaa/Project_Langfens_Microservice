using System.ComponentModel.DataAnnotations;
using course_service.Domains.Enums;

namespace course_service.Domains.Entities
{
    public class Enrollment
    {
        [Key] public int Id { get; set; }
        public int UserId { get; set; }
        public int CourseId { get; set; }
        [MaxLength(20)]
        public string Status { get; set; } = EnrollmentStatus.Active;
        public DateTime EnrolledAt { get; set; }
        public Course Course { get; set; } = default!;
    }
}