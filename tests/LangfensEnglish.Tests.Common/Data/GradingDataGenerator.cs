namespace LangfensEnglish.Tests.Common.Data;

/// <summary>
/// Generates test data specifically for AttemptService grading test cases.
/// Provides >= 11 scenarios per requirement (AR-xxx).
/// </summary>
public static class GradingDataGenerator
{
    #region AR-016: LCS (Longest Common Subsequence) Test Cases

    /// <summary>
    /// AR-016: FlowChart LCS grading test cases.
    /// Returns: (caseId, correctSeq, userSeq, expectedLcsLength)
    /// </summary>
    public static IEnumerable<object[]> GetLcsCases()
    {
        // Case 1: Empty vs Empty
        yield return new object[] { "AR-016-01", new List<string>(), new List<string>(), 0 };
        
        // Case 2: Empty correct (edge)
        yield return new object[] { "AR-016-02", new List<string>(), new List<string> { "A", "B" }, 0 };
        
        // Case 3: Empty user answer
        yield return new object[] { "AR-016-03", new List<string> { "A", "B", "C" }, new List<string>(), 0 };
        
        // Case 4: Full match
        yield return new object[] { "AR-016-04", new List<string> { "A", "B", "C", "D", "E" }, new List<string> { "A", "B", "C", "D", "E" }, 5 };
        
        // Case 5: Completely different
        yield return new object[] { "AR-016-05", new List<string> { "A", "B", "C" }, new List<string> { "X", "Y", "Z" }, 0 };
        
        // Case 6: Partial match (contiguous)
        yield return new object[] { "AR-016-06", new List<string> { "A", "B", "C", "D", "E" }, new List<string> { "B", "C", "D" }, 3 };
        
        // Case 7: Partial match (non-contiguous)
        yield return new object[] { "AR-016-07", new List<string> { "A", "B", "C", "D", "E" }, new List<string> { "A", "C", "E" }, 3 };
        
        // Case 8: User has extra elements
        yield return new object[] { "AR-016-08", new List<string> { "A", "B", "C" }, new List<string> { "X", "A", "Y", "B", "Z", "C" }, 3 };
        
        // Case 9: Reversed order (worst case for LCS)
        yield return new object[] { "AR-016-09", new List<string> { "A", "B", "C", "D", "E" }, new List<string> { "E", "D", "C", "B", "A" }, 1 };
        
        // Case 10: Single element match
        yield return new object[] { "AR-016-10", new List<string> { "A" }, new List<string> { "A" }, 1 };
        
        // Case 11: Single element no match
        yield return new object[] { "AR-016-11", new List<string> { "A" }, new List<string> { "B" }, 0 };
        
        // Case 12: Case sensitivity (should be normalized)
        yield return new object[] { "AR-016-12", new List<string> { "node-one", "node-two" }, new List<string> { "Node One", "Node Two" }, 2 };
        
        // Case 13: Duplicates in correct
        yield return new object[] { "AR-016-13", new List<string> { "A", "B", "A", "C" }, new List<string> { "A", "B", "C" }, 3 };
        
        // Case 14: All same element
        yield return new object[] { "AR-016-14", new List<string> { "A", "A", "A" }, new List<string> { "A", "A" }, 2 };
        
        // Case 15: Long sequence
        yield return new object[] { "AR-016-15", 
            new List<string> { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10" }, 
            new List<string> { "2", "4", "6", "8", "10" }, 5 };
    }

    #endregion

    #region AR-001 to AR-015: Attempt Lifecycle Cases

    /// <summary>
    /// AR-001/002: Start attempt test cases.
    /// Returns: (caseId, examId, userId, expectedStatus)
    /// </summary>
    public static IEnumerable<object?[]> GetStartAttemptCases()
    {
        yield return new object?[] { "AR-001-01", Guid.NewGuid(), Guid.NewGuid().ToString(), "Created" };
        yield return new object?[] { "AR-001-02", Guid.Empty, Guid.NewGuid().ToString(), "BadRequest" };
        yield return new object?[] { "AR-001-03", Guid.NewGuid(), null, "BadRequest" };
        yield return new object?[] { "AR-001-04", Guid.NewGuid(), "", "BadRequest" };
        yield return new object?[] { "AR-001-05", Guid.NewGuid(), "   ", "BadRequest" };
        yield return new object?[] { "AR-001-06", Guid.NewGuid(), Guid.NewGuid().ToString(), "Created" };
        yield return new object?[] { "AR-001-07", Guid.NewGuid(), Guid.NewGuid().ToString(), "Created" };
        yield return new object?[] { "AR-001-08", Guid.NewGuid(), Guid.NewGuid().ToString(), "Created" };
        yield return new object?[] { "AR-001-09", Guid.NewGuid(), Guid.NewGuid().ToString(), "Created" };
        yield return new object?[] { "AR-001-10", Guid.NewGuid(), Guid.NewGuid().ToString(), "Created" };
        yield return new object?[] { "AR-001-11", Guid.NewGuid(), Guid.NewGuid().ToString(), "Created" };
    }

    /// <summary>
    /// AR-005/006: Submit attempt test cases.
    /// Returns: (caseId, attemptId, answers, expectedStatus)
    /// </summary>
    public static IEnumerable<object?[]> GetSubmitAttemptCases()
    {
        yield return new object?[] { "AR-005-01", Guid.NewGuid(), new Dictionary<Guid, string>(), "Submitted" };
        yield return new object?[] { "AR-005-02", Guid.Empty, new Dictionary<Guid, string>(), "BadRequest" };
        yield return new object?[] { "AR-005-03", Guid.NewGuid(), null, "BadRequest" };
        yield return new object?[] { "AR-005-04", Guid.NewGuid(), new Dictionary<Guid, string> { { Guid.NewGuid(), "answer1" } }, "Submitted" };
        yield return new object?[] { "AR-005-05", Guid.NewGuid(), new Dictionary<Guid, string> { { Guid.NewGuid(), "" } }, "Submitted" };
        yield return new object?[] { "AR-005-06", Guid.NewGuid(), new Dictionary<Guid, string> { { Guid.NewGuid(), null! } }, "Submitted" };
        yield return new object?[] { "AR-005-07", Guid.NewGuid(), new Dictionary<Guid, string>(), "Submitted" };
        yield return new object?[] { "AR-005-08", Guid.NewGuid(), new Dictionary<Guid, string>(), "Submitted" };
        yield return new object?[] { "AR-005-09", Guid.NewGuid(), new Dictionary<Guid, string>(), "Submitted" };
        yield return new object?[] { "AR-005-10", Guid.NewGuid(), new Dictionary<Guid, string>(), "Submitted" };
        yield return new object?[] { "AR-005-11", Guid.NewGuid(), new Dictionary<Guid, string>(), "Submitted" };
    }

    #endregion

    #region AR-010 to AR-015: Grader Type Cases

    /// <summary>
    /// AR-010: SingleChoice grading test cases.
    /// Returns: (caseId, correctOptionId, selectedOptionId, points, expectedScore)
    /// </summary>
    public static IEnumerable<object[]> GetSingleChoiceCases()
    {
        var correctId = Guid.NewGuid();
        var wrongId = Guid.NewGuid();
        
        yield return new object[] { "AR-010-01", correctId, correctId, 2m, 2m };       // Correct
        yield return new object[] { "AR-010-02", correctId, wrongId, 2m, 0m };         // Wrong
        yield return new object[] { "AR-010-03", correctId, Guid.Empty, 2m, 0m };      // Empty selection
        yield return new object[] { "AR-010-04", correctId, correctId, 0m, 0m };       // Zero points
        yield return new object[] { "AR-010-05", correctId, correctId, 1.5m, 1.5m };   // Decimal points
        yield return new object[] { "AR-010-06", correctId, wrongId, 5m, 0m };
        yield return new object[] { "AR-010-07", correctId, correctId, 10m, 10m };
        yield return new object[] { "AR-010-08", correctId, wrongId, 3m, 0m };
        yield return new object[] { "AR-010-09", correctId, correctId, 1m, 1m };
        yield return new object[] { "AR-010-10", correctId, wrongId, 1m, 0m };
        yield return new object[] { "AR-010-11", correctId, correctId, 100m, 100m };
    }

    /// <summary>
    /// AR-012: Completion (fill-blank) grading test cases.
    /// Returns: (caseId, acceptedTexts, userAnswer, points, expectedScore)
    /// </summary>
    public static IEnumerable<object?[]> GetCompletionGraderCases()
    {
        yield return new object?[] { "AR-012-01", new[] { "correct" }, "correct", 1m, 1m };
        yield return new object?[] { "AR-012-02", new[] { "correct" }, "CORRECT", 1m, 1m };  // Case insensitive
        yield return new object?[] { "AR-012-03", new[] { "correct" }, "wrong", 1m, 0m };
        yield return new object?[] { "AR-012-04", new[] { "correct" }, "", 1m, 0m };
        yield return new object?[] { "AR-012-05", new[] { "correct" }, null, 1m, 0m };
        yield return new object?[] { "AR-012-06", new[] { "answer1", "answer2" }, "answer2", 1m, 1m };  // Multiple accepted
        yield return new object?[] { "AR-012-07", new[] { "the answer" }, "the  answer", 1m, 1m };      // Normalized spaces
        yield return new object?[] { "AR-012-08", Array.Empty<string>(), "anything", 1m, 0m };          // No accepted texts
        yield return new object?[] { "AR-012-09", new[] { "correct" }, " correct ", 1m, 1m };           // Trimmed
        yield return new object?[] { "AR-012-10", new[] { "correct" }, "correctness", 1m, 0m };         // Partial match fails
        yield return new object?[] { "AR-012-11", new[] { "100" }, "100", 2m, 2m };                     // Numeric
    }

    #endregion
}
