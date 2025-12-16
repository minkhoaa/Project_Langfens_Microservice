namespace LangfensEnglish.Tests.Common.Data;

/// <summary>
/// Generates test data specifically for ExamService test cases.
/// Provides >= 11 scenarios per requirement (EC-xxx, ES-xxx).
/// </summary>
public static class ExamDataGenerator
{
    #region EC-001: Slug Generation Cases

    /// <summary>
    /// EC-001: ToSlug test cases covering edge cases.
    /// Returns: (caseId, input, expectedStartsWith)
    /// </summary>
    public static IEnumerable<object?[]> GetSlugCases()
    {
        // Standard conversions
        yield return new object?[] { "EC-001-01", "Hello World", "hello-world" };
        yield return new object?[] { "EC-001-02", "UPPERCASE", "uppercase" };
        yield return new object?[] { "EC-001-03", "already-a-slug", "already-a-slug" };
        
        // Vietnamese diacritics
        yield return new object?[] { "EC-001-04", "Tiếng Việt Có Dấu", "tieng-viet-co-dau" };
        yield return new object?[] { "EC-001-05", "đáp án đúng", "dap-an-dung" };
        yield return new object?[] { "EC-001-06", "Cộng Hòa Xã Hội", "cong-hoa-xa-hoi" };
        yield return new object?[] { "EC-001-07", "Ngữ pháp tiếng Anh", "ngu-phap-tieng-anh" };
        
        // Special characters (should fallback to exam-{randomId})
        yield return new object?[] { "EC-001-08", "!@#$%^&*()_+", "exam-" };
        yield return new object?[] { "EC-001-09", "---dashes---", "dashes" };
        yield return new object?[] { "EC-001-10", "  many   spaces  ", "many-spaces" };
        
        // Empty/null (should fallback)
        yield return new object?[] { "EC-001-11", "", "exam-" };
        yield return new object?[] { "EC-001-12", null, "exam-" };
        yield return new object?[] { "EC-001-13", "   ", "exam-" };
        
        // Long strings (truncation)
        yield return new object?[] { "EC-001-14", new string('a', 200), new string('a', 120) };
        
        // Mixed content
        yield return new object?[] { "EC-001-15", "Test 123 ABC", "test-123-abc" };
        yield return new object?[] { "EC-001-16", "Question #5: Answers", "question-5-answers" };
    }

    #endregion

    #region EC-002: Unique Slug Generation Cases

    /// <summary>
    /// EC-002: MakeUniqueSlug test cases.
    /// Returns: (caseId, baseSlug, existingSlugs, expectedSlug)
    /// </summary>
    public static IEnumerable<object[]> GetUniqueSlugCases()
    {
        yield return new object[] { "EC-002-01", "my-slug", new List<string>(), "my-slug" };
        yield return new object[] { "EC-002-02", "my-slug", new List<string> { "my-slug" }, "my-slug-2" };
        yield return new object[] { "EC-002-03", "my-slug", new List<string> { "my-slug", "my-slug-2" }, "my-slug-3" };
        yield return new object[] { "EC-002-04", "my-slug", new List<string> { "my-slug", "my-slug-3" }, "my-slug-2" }; // Gap
        yield return new object[] { "EC-002-05", "a", new List<string> { "a" }, "a-2" };
        yield return new object[] { "EC-002-06", "b", new List<string> { "b", "b-2" }, "b-3" };
        yield return new object[] { "EC-002-07", "c", new List<string> { "c", "c-2", "c-3" }, "c-4" };
        yield return new object[] { "EC-002-08", "d", new List<string> { "d", "d-2", "d-3", "d-4" }, "d-5" };
        yield return new object[] { "EC-002-09", "e", new List<string> { "e", "e-2", "e-3", "e-4", "e-5" }, "e-6" };
        yield return new object[] { "EC-002-10", "f", new List<string> { "f" }, "f-2" };
        yield return new object[] { "EC-002-11", "g", new List<string> { "g", "g-2", "g-3", "g-4", "g-5", "g-6", "g-7", "g-8", "g-9", "g-10" }, "g-11" };
    }

    #endregion

    #region ES-001 to ES-012: Section/Question/Option Cases

    /// <summary>
    /// ES-001/002: Section CRUD test cases.
    /// Returns: (caseId, sectionTitle, expectedValid)
    /// </summary>
    public static IEnumerable<object?[]> GetSectionCases()
    {
        yield return new object?[] { "ES-001-01", "Reading Passage 1", true };
        yield return new object?[] { "ES-001-02", "Listening Part A", true };
        yield return new object?[] { "ES-001-03", "", false };
        yield return new object?[] { "ES-001-04", null, false };
        yield return new object?[] { "ES-001-05", "   ", false };
        yield return new object?[] { "ES-001-06", new string('a', 256), true };
        yield return new object?[] { "ES-001-07", "Section with <html> tags", true };
        yield return new object?[] { "ES-001-08", "Section 日本語", true };
        yield return new object?[] { "ES-001-09", "123 Numeric Title", true };
        yield return new object?[] { "ES-001-10", "A", true };
        yield return new object?[] { "ES-001-11", "Very Long Section Title That Goes On And On And On", true };
    }

    /// <summary>
    /// ES-005/006: Question type handling cases.
    /// Returns: (caseId, questionType, points, expectedValid)
    /// </summary>
    public static IEnumerable<object[]> GetQuestionTypeCases()
    {
        yield return new object[] { "ES-005-01", "SINGLE_CHOICE", 1m, true };
        yield return new object[] { "ES-005-02", "MULTIPLE_CHOICE", 2m, true };
        yield return new object[] { "ES-005-03", "FILL_BLANK", 1.5m, true };
        yield return new object[] { "ES-005-04", "SHORT_ANSWER", 3m, true };
        yield return new object[] { "ES-005-05", "MATCHING", 5m, true };
        yield return new object[] { "ES-005-06", "ORDERING", 4m, true };
        yield return new object[] { "ES-005-07", "FlowChart", 10m, true };
        yield return new object[] { "ES-005-08", "LABEL", 2m, true };
        yield return new object[] { "ES-005-09", "TABLE_COMPLETION", 3m, true };
        yield return new object[] { "ES-005-10", "SUMMARY_COMPLETION", 4m, true };
        yield return new object[] { "ES-005-11", "INVALID_TYPE", 1m, false };
    }

    #endregion
}
