namespace LangfensEnglish.Tests.Common.Data;

/// <summary>
/// Generates test data specifically for CourseService test cases.
/// Provides >= 11 scenarios per requirement (CL-xxx, EP-xxx).
/// </summary>
public static class CourseDataGenerator
{
    #region CL-001 to CL-007: Course CRUD Cases

    /// <summary>
    /// CL-001/002: Course listing and filtering test cases.
    /// Returns: (caseId, category, level, status, expectedFilterApplied)
    /// </summary>
    public static IEnumerable<object?[]> GetCourseFilterCases()
    {
        yield return new object?[] { "CL-001-01", null, null, null, false };
        yield return new object?[] { "CL-001-02", "GENERAL_ENGLISH", null, null, true };
        yield return new object?[] { "CL-001-03", null, "B1", null, true };
        yield return new object?[] { "CL-001-04", null, null, "Published", true };
        yield return new object?[] { "CL-001-05", "BUSINESS_ENGLISH", "C1", null, true };
        yield return new object?[] { "CL-001-06", "GENERAL_ENGLISH", "B1", "Published", true };
        yield return new object?[] { "CL-001-07", "INVALID", null, null, false };
        yield return new object?[] { "CL-001-08", null, "INVALID", null, false };
        yield return new object?[] { "CL-001-09", null, null, "Draft", true };
        yield return new object?[] { "CL-001-10", "EXAM_PREP", "C2", "Published", true };
        yield return new object?[] { "CL-001-11", "", "", "", false };
    }

    /// <summary>
    /// CL-003/004: Course creation test cases.
    /// Returns: (caseId, title, description, category, level, expectedValid)
    /// </summary>
    public static IEnumerable<object?[]> GetCourseCreateCases()
    {
        yield return new object?[] { "CL-003-01", "Introduction to English", "Basic course", "GENERAL_ENGLISH", "A1", true };
        yield return new object?[] { "CL-003-02", "", "Description", "GENERAL_ENGLISH", "A1", false };
        yield return new object?[] { "CL-003-03", null, "Description", "GENERAL_ENGLISH", "A1", false };
        yield return new object?[] { "CL-003-04", "Title", "", "GENERAL_ENGLISH", "A1", true };
        yield return new object?[] { "CL-003-05", "Title", null, "GENERAL_ENGLISH", "A1", true };
        yield return new object?[] { "CL-003-06", "Title", "Desc", "INVALID_CATEGORY", "A1", false };
        yield return new object?[] { "CL-003-07", "Title", "Desc", "GENERAL_ENGLISH", "INVALID", false };
        yield return new object?[] { "CL-003-08", new string('a', 256), "Desc", "GENERAL_ENGLISH", "B1", true };
        yield return new object?[] { "CL-003-09", "Business English", "Advanced", "BUSINESS_ENGLISH", "C1", true };
        yield return new object?[] { "CL-003-10", "IELTS Prep", "Exam preparation", "EXAM_PREP", "B2", true };
        yield return new object?[] { "CL-003-11", "   ", "Desc", "GENERAL_ENGLISH", "A1", false };
    }

    #endregion

    #region EP-001 to EP-007: User Progress Cases

    /// <summary>
    /// EP-001/002: Enrollment test cases.
    /// Returns: (caseId, userId, courseId, alreadyEnrolled, expectedStatus)
    /// </summary>
    public static IEnumerable<object?[]> GetEnrollmentCases()
    {
        var userId = Guid.NewGuid().ToString();
        var courseId = Guid.NewGuid();
        
        yield return new object?[] { "EP-001-01", userId, courseId, false, "Enrolled" };
        yield return new object?[] { "EP-001-02", userId, courseId, true, "AlreadyEnrolled" };
        yield return new object?[] { "EP-001-03", "", courseId, false, "BadRequest" };
        yield return new object?[] { "EP-001-04", null, courseId, false, "BadRequest" };
        yield return new object?[] { "EP-001-05", userId, Guid.Empty, false, "BadRequest" };
        yield return new object?[] { "EP-001-06", "   ", courseId, false, "BadRequest" };
        yield return new object?[] { "EP-001-07", Guid.NewGuid().ToString(), courseId, false, "Enrolled" };
        yield return new object?[] { "EP-001-08", Guid.NewGuid().ToString(), Guid.NewGuid(), false, "Enrolled" };
        yield return new object?[] { "EP-001-09", Guid.NewGuid().ToString(), Guid.NewGuid(), true, "AlreadyEnrolled" };
        yield return new object?[] { "EP-001-10", Guid.NewGuid().ToString(), Guid.NewGuid(), false, "Enrolled" };
        yield return new object?[] { "EP-001-11", Guid.NewGuid().ToString(), Guid.NewGuid(), false, "Enrolled" };
    }

    /// <summary>
    /// EP-003/004: Progress tracking test cases.
    /// Returns: (caseId, completedLessons, totalLessons, expectedProgressPercent)
    /// </summary>
    public static IEnumerable<object[]> GetProgressTrackingCases()
    {
        yield return new object[] { "EP-003-01", 0, 10, 0.0 };          // 0%
        yield return new object[] { "EP-003-02", 1, 10, 10.0 };         // 10%
        yield return new object[] { "EP-003-03", 5, 10, 50.0 };         // 50%
        yield return new object[] { "EP-003-04", 10, 10, 100.0 };       // 100%
        yield return new object[] { "EP-003-05", 3, 10, 30.0 };         // 30%
        yield return new object[] { "EP-003-06", 7, 10, 70.0 };         // 70%
        yield return new object[] { "EP-003-07", 1, 3, 33.33 };         // Precision test
        yield return new object[] { "EP-003-08", 2, 3, 66.67 };         // Precision test
        yield return new object[] { "EP-003-09", 0, 0, 0.0 };           // Edge: no lessons
        yield return new object[] { "EP-003-10", 1, 1, 100.0 };         // Single lesson
        yield return new object[] { "EP-003-11", 99, 100, 99.0 };       // Almost complete
    }

    #endregion
}
