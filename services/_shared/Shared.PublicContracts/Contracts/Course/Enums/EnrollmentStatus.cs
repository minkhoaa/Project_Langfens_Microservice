using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Shared.ExamDto.Contracts.Course.Enums
{
    public class EnrollmentStatus
    {

        // ACTIVE|CANCELLED|COMPLETED
        public static string Active { get; set; } = "ACTIVE";
        public static string Cancelled { get; set; } = "CANCELLED";
        public static string Completed { get; set; } = "COMPLETED";
        public static readonly string[] All = new[]
        {
            Active, Cancelled, Completed
        };

        // Fast validation set (O(1))
        private static readonly HashSet<string> _set =
            new HashSet<string>(All, StringComparer.Ordinal);

        public static bool IsValid(string? code) =>
            !string.IsNullOrWhiteSpace(code) && _set.Contains(code);

    }
}