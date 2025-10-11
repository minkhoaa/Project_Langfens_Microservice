using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;

namespace course_service.Domains.Entities
{
    public class LessonCompletion
    {
        [Key] public Guid Id { get; set; }
        public Guid UserId { get; set; }
        public Guid LessonId { get; set; }
        public DateTime CompletedAt { get; set; }
        public Lesson Lesson { get; set; } = default!;
    }
}