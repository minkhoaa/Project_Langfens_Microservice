using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace course_service.Domains.Enums
{
    public static class EnrollmentStatus
    {
        // ACTIVE|CANCELLED|COMPLETED

        public static string Active { get; set; } = "ACTIVE";
        public static string Cancelled { get; set; } = "CANCELLED";
        public static string Completed { get; set; } = "COMPLETED";
    }
}