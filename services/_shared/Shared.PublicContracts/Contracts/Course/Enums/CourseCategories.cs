namespace Shared.ExamDto.Contracts.Course.Enums
{

    public static class CourseCategories
    {
        // Exams
        public const string IELTS_GENERAL = "IELTS_GENERAL";
        public const string IELTS_ACADEMIC = "IELTS_ACADEMIC";
        public const string TOEIC = "TOEIC";
        public const string TOEFL = "TOEFL";
        public const string MOCK_TESTS = "MOCK_TESTS";

        // Skills
        public const string SKILL_LISTENING = "SKILL_LISTENING";
        public const string SKILL_READING = "SKILL_READING";
        public const string SKILL_WRITING = "SKILL_WRITING";
        public const string SKILL_SPEAKING = "SKILL_SPEAKING";

        // Foundations
        public const string GRAMMAR = "GRAMMAR";
        public const string VOCABULARY = "VOCABULARY";
        public const string PRONUNCIATION = "PRONUNCIATION";
        public const string PHONETICS = "PHONETICS";

        // Context / Goals
        public const string BUSINESS_ENGLISH = "BUSINESS_ENGLISH";
        public const string ACADEMIC_ENGLISH = "ACADEMIC_ENGLISH";
        public const string GENERAL_ENGLISH = "GENERAL_ENGLISH";
        public const string STUDY_SKILLS = "STUDY_SKILLS";

        // Audience
        public const string KIDS = "KIDS";
        public const string TEENS = "TEENS";
        public const string ADULTS = "ADULTS";
        public const string TEACHER_TRAINING = "TEACHER_TRAINING";

        // All values for validation/filter UI
        public static readonly string[] All = new[]
        {
        IELTS_GENERAL, IELTS_ACADEMIC, TOEIC, TOEFL, MOCK_TESTS,
        SKILL_LISTENING, SKILL_READING, SKILL_WRITING, SKILL_SPEAKING,
        GRAMMAR, VOCABULARY, PRONUNCIATION, PHONETICS,
        BUSINESS_ENGLISH, ACADEMIC_ENGLISH, GENERAL_ENGLISH, STUDY_SKILLS,
        KIDS, TEENS, ADULTS, TEACHER_TRAINING
        };

        // Fast validation set (O(1))
        private static readonly HashSet<string> _set =
            new HashSet<string>(All, StringComparer.Ordinal);

        public static bool IsValid(string? code) =>
            !string.IsNullOrWhiteSpace(code) && _set.Contains(code);
    }
}