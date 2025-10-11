using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace course_service.Domains.Enums
{
    public static class CourseStatus
    {
        // DRAFT|PUBLISHED
        public static string Draft { get; set; } = "DRAFT";
        public static string Published { get; set; } = "PUBLISHED";
    }
}