using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;
using course_service.Domains.Enums;

namespace course_service.Domains.Entities
{
    public class Enrollment
    {
        [Key] public Guid Id { get; set; }
        public Guid UserId { get; set; }
        public Guid CourseId { get; set; }
        [MaxLength(20)]
        public string Status { get; set; } = EnrollmentStatus.Active;
        public DateTime EnrolledAt { get; set; }
        public Course Course { get; set; } = default!;
    }
}