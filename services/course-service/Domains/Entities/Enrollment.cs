using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Shared.ExamDto.Contracts.Course.Enums;


namespace course_service.Domains.Entities
{
    public class Enrollment
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public Guid Id { get; set; }
        public Guid UserId { get; set; }
        public Guid CourseId { get; set; }
        [MaxLength(20)]
        public string Status { get; set; } = EnrollmentStatus.Active;
        public DateTime EnrolledAt { get; set; }
        public Course Course { get; set; } = null!;
    }
}