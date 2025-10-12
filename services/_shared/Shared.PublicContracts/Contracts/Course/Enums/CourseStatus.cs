using Microsoft.EntityFrameworkCore.Diagnostics;

namespace Shared.ExamDto.Contracts.Course.Enums
{
    public class CourseStatus
    {
        public static string Draft { get; set; } = "DRAFT";
        public static string Published { get; set; } = "PUBLISHED";


        public static readonly string[] All = new[]
        {
        Draft, Published
        };

        // Fast validation set (O(1))
        private static readonly HashSet<string> _set =
            new HashSet<string>(All, StringComparer.Ordinal);

        public static bool IsValid(string? code) =>
            !string.IsNullOrWhiteSpace(code) && _set.Contains(code);
    }
}