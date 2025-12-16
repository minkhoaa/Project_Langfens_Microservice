namespace LangfensEnglish.Tests.Common.Data;

/// <summary>
/// Generates test data specifically for VocabularyService test cases.
/// Provides >= 11 scenarios per requirement (VF-xxx).
/// </summary>
public static class VocabularyDataGenerator
{
    #region VF-001: SM2 Scheduler Test Cases

    /// <summary>
    /// VF-001: SM2 Scheduler comprehensive test cases.
    /// Returns: (caseId, repetition, ef, intervalDays, grade, expectedReps, expectedEf, expectedInterval)
    /// </summary>
    public static IEnumerable<object[]> GetSm2Cases()
    {
        // Quality < 3 (Fail) -> Interval resets to 1
        yield return new object[] { "VF-001-01_q0_new", 0, 2.5, 0, 0, 0, 1.7, 1 };
        yield return new object[] { "VF-001-02_q1_new", 0, 2.5, 0, 1, 0, 1.96, 1 };
        yield return new object[] { "VF-001-03_q2_new", 0, 2.5, 0, 2, 0, 2.18, 1 };
        yield return new object[] { "VF-001-04_q2_reviewed", 3, 1.8, 10, 2, 0, 1.48, 1 };
        
        // Quality >= 3 (Pass) -> Interval increases
        yield return new object[] { "VF-001-05_q3_first", 0, 2.5, 0, 3, 1, 2.36, 1 };
        yield return new object[] { "VF-001-06_q4_first", 0, 2.5, 0, 4, 1, 2.5, 1 };
        yield return new object[] { "VF-001-07_q5_first", 0, 2.5, 0, 5, 1, 2.6, 1 };
        yield return new object[] { "VF-001-08_q3_second", 1, 2.5, 1, 3, 2, 2.36, 6 };
        yield return new object[] { "VF-001-09_q4_second", 1, 2.6, 1, 4, 2, 2.6, 6 };
        yield return new object[] { "VF-001-10_q5_third", 2, 2.7, 6, 5, 3, 2.8, 17 };
        
        // EF Floor (min 1.3)
        yield return new object[] { "VF-001-11_ef_floor", 5, 1.3, 20, 3, 6, 1.3, 26 };
    }

    #endregion

    #region VF-005 to VF-011: Deck and Flashcard Cases

    /// <summary>
    /// VF-005: Create deck test cases.
    /// Returns: (caseId, title, slug, category, description, expectedValid)
    /// </summary>
    public static IEnumerable<object?[]> GetDeckCreateCases()
    {
        yield return new object?[] { "VF-005-01", "Animals", "animals", "Nature", "Animal vocabulary", true };
        yield return new object?[] { "VF-005-02", "Business Terms", "business-terms", "Business", "Business vocab", true };
        yield return new object?[] { "VF-005-03", "", "empty-title", "Cat", "Desc", false };
        yield return new object?[] { "VF-005-04", null, "null-title", "Cat", "Desc", false };
        yield return new object?[] { "VF-005-05", "Title", "", "Cat", "Desc", false };
        yield return new object?[] { "VF-005-06", "Title", null, "Cat", "Desc", false };
        yield return new object?[] { "VF-005-07", "Title", "valid-slug", "", "Desc", true };
        yield return new object?[] { "VF-005-08", "Title", "valid-slug-2", null, "Desc", true };
        yield return new object?[] { "VF-005-09", "日本語", "japanese", "Language", "Japanese vocab", true };
        yield return new object?[] { "VF-005-10", "Tiếng Việt", "tieng-viet", "Language", "Vietnamese vocab", true };
        yield return new object?[] { "VF-005-11", new string('a', 100), "long-title", "Cat", "Desc", true };
    }

    /// <summary>
    /// VF-008: Flashcard review test cases.
    /// Returns: (caseId, currentInterval, quality, expectedNextInterval)
    /// </summary>
    public static IEnumerable<object[]> GetFlashcardReviewCases()
    {
        yield return new object[] { "VF-008-01", 1, 5, 3 };    // Good review, increase
        yield return new object[] { "VF-008-02", 1, 0, 1 };    // Fail, reset
        yield return new object[] { "VF-008-03", 6, 5, 16 };   // After second review
        yield return new object[] { "VF-008-04", 6, 0, 1 };    // Fail after second
        yield return new object[] { "VF-008-05", 17, 5, 45 };  // Long interval
        yield return new object[] { "VF-008-06", 17, 0, 1 };   // Fail long interval
        yield return new object[] { "VF-008-07", 1, 3, 3 };    // Barely pass
        yield return new object[] { "VF-008-08", 1, 4, 3 };    // Pass
        yield return new object[] { "VF-008-09", 100, 5, 260 }; // Very long interval
        yield return new object[] { "VF-008-10", 1, 1, 1 };    // Fail q=1
        yield return new object[] { "VF-008-11", 1, 2, 1 };    // Fail q=2
    }

    /// <summary>
    /// VF-009: Due cards calculation test cases.
    /// Returns: (caseId, totalCards, dueCards, reviewedToday, expectedDueCount)
    /// </summary>
    public static IEnumerable<object[]> GetDueCardsCases()
    {
        yield return new object[] { "VF-009-01", 100, 10, 0, 10 };
        yield return new object[] { "VF-009-02", 100, 0, 0, 0 };
        yield return new object[] { "VF-009-03", 100, 100, 0, 100 };
        yield return new object[] { "VF-009-04", 0, 0, 0, 0 };
        yield return new object[] { "VF-009-05", 50, 25, 10, 15 };
        yield return new object[] { "VF-009-06", 50, 50, 50, 0 };
        yield return new object[] { "VF-009-07", 1000, 500, 100, 400 };
        yield return new object[] { "VF-009-08", 10, 5, 3, 2 };
        yield return new object[] { "VF-009-09", 10, 10, 5, 5 };
        yield return new object[] { "VF-009-10", 10, 1, 0, 1 };
        yield return new object[] { "VF-009-11", 1, 1, 0, 1 };
    }

    #endregion
}
