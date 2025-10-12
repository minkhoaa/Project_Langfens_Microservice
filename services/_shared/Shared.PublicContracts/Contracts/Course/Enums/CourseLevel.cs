using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Shared.ExamDto.Contracts.Course.Enums
{
    public static class CourseLevel
    {
        public static string A1 = "A1";
        public static string A2 = "A2";
        public static string B1 = "B1";
        public static string B2 = "B2";
        public static string C1 = "C1";
        public static string C2 = "C2";

        public static readonly string[] All = new[]
        {
            A1, A2, B1, B2, C1, C2
        };
        private static readonly HashSet<string> _set =
           new HashSet<string>(All, StringComparer.Ordinal);

        public static bool IsValid(string? code) =>
            !string.IsNullOrWhiteSpace(code) && _set.Contains(code);
    }
}