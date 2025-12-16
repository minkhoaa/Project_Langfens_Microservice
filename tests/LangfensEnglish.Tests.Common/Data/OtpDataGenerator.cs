namespace LangfensEnglish.Tests.Common.Data;

/// <summary>
/// Generates test data specifically for OTP/Email service test cases.
/// Provides >= 11 scenarios per requirement (OE-xxx).
/// </summary>
public static class OtpDataGenerator
{
    #region OE-001: OTP Verification Cases

    /// <summary>
    /// OE-001: OTP verification test cases.
    /// Returns: (caseId, email, otp, isBlocked, storedHash, verificationResult, tries, expectedSuccess, shouldBlock, shouldClear)
    /// </summary>
    public static IEnumerable<object?[]> GetVerifyOtpCases()
    {
        var hashedOtp = "hashed_otp_string";
        var maxAttempts = 3;

        // Blocked scenarios
        yield return new object?[] { "OE-001-01", "blocked@example.com", "123456", true, null, "Failed", 0, false, false, false };
        yield return new object?[] { "OE-001-02", "blocked2@example.com", "123456", true, hashedOtp, "Failed", 0, false, false, false };

        // Hash not found
        yield return new object?[] { "OE-001-03", "nocode@example.com", "123456", false, null, "Failed", 0, false, false, false };

        // Verification success
        yield return new object?[] { "OE-001-04", "user@example.com", "123456", false, hashedOtp, "Success", 0, true, false, true };
        yield return new object?[] { "OE-001-05", "user2@example.com", "654321", false, hashedOtp, "Success", 0, true, false, true };

        // Verification failures (incrementing tries)
        yield return new object?[] { "OE-001-06", "user@example.com", "wrong1", false, hashedOtp, "Failed", 1, false, false, false };
        yield return new object?[] { "OE-001-07", "user@example.com", "wrong2", false, hashedOtp, "Failed", 2, false, false, false };
        yield return new object?[] { "OE-001-08", "user@example.com", "wrong3", false, hashedOtp, "Failed", maxAttempts, false, true, false }; // Block triggered

        // Edge cases
        yield return new object?[] { "OE-001-09", "user@example.com", "wrong4", false, hashedOtp, "Failed", maxAttempts + 1, false, true, false }; // Already over
        yield return new object?[] { "OE-001-10", null, "123456", false, null, "Failed", 0, false, false, false };
        yield return new object?[] { "OE-001-11", "", "123456", false, null, "Failed", 0, false, false, false };
    }

    #endregion

    #region OE-002: Resend Cooldown Cases

    /// <summary>
    /// OE-002: Can resend (cooldown) test cases.
    /// Returns: (caseId, email, keyExists, expectedCanResend)
    /// </summary>
    public static IEnumerable<object[]> GetCanResendCases()
    {
        yield return new object[] { "OE-002-01", "user@example.com", false, true };    // No cooldown
        yield return new object[] { "OE-002-02", "user@example.com", true, false };    // In cooldown
        yield return new object[] { "OE-002-03", "USER@EXAMPLE.COM", false, true };    // Case insensitive
        yield return new object[] { "OE-002-04", "  user@example.com  ", false, true }; // Trimmed
        yield return new object[] { "OE-002-05", "test1@example.com", false, true };
        yield return new object[] { "OE-002-06", "test2@example.com", true, false };
        yield return new object[] { "OE-002-07", "test3@example.com", false, true };
        yield return new object[] { "OE-002-08", "test4@example.com", true, false };
        yield return new object[] { "OE-002-09", "test5@example.com", false, true };
        yield return new object[] { "OE-002-10", "test6@example.com", true, false };
        yield return new object[] { "OE-002-11", "test7@example.com", false, true };
    }

    #endregion

    #region OE-003: Put OTP Cases

    /// <summary>
    /// OE-003: Store OTP test cases.
    /// Returns: (caseId, email, otp, ttlMinutes)
    /// </summary>
    public static IEnumerable<object[]> GetPutOtpCases()
    {
        yield return new object[] { "OE-003-01", "user@example.com", "123456", 5 };
        yield return new object[] { "OE-003-02", "USER@EXAMPLE.COM", "654321", 10 };
        yield return new object[] { "OE-003-03", "  user@example.com  ", "111111", 15 };
        yield return new object[] { "OE-003-04", "test1@example.com", "222222", 1 };
        yield return new object[] { "OE-003-05", "test2@example.com", "333333", 30 };
        yield return new object[] { "OE-003-06", "test3@example.com", "444444", 60 };
        yield return new object[] { "OE-003-07", "test4@example.com", "555555", 5 };
        yield return new object[] { "OE-003-08", "test5@example.com", "666666", 5 };
        yield return new object[] { "OE-003-09", "test6@example.com", "777777", 5 };
        yield return new object[] { "OE-003-10", "test7@example.com", "888888", 5 };
        yield return new object[] { "OE-003-11", "test8@example.com", "999999", 5 };
    }

    #endregion

    #region OE-004: Is Blocked Cases

    /// <summary>
    /// OE-004: Is user blocked test cases.
    /// Returns: (caseId, email, blockKeyExists, expectedBlocked)
    /// </summary>
    public static IEnumerable<object[]> GetIsBlockedCases()
    {
        yield return new object[] { "OE-004-01", "user@example.com", false, false };
        yield return new object[] { "OE-004-02", "blocked@example.com", true, true };
        yield return new object[] { "OE-004-03", "USER@EXAMPLE.COM", false, false };
        yield return new object[] { "OE-004-04", "BLOCKED@EXAMPLE.COM", true, true };
        yield return new object[] { "OE-004-05", "  user@example.com  ", false, false };
        yield return new object[] { "OE-004-06", "test1@example.com", false, false };
        yield return new object[] { "OE-004-07", "test2@example.com", true, true };
        yield return new object[] { "OE-004-08", "test3@example.com", false, false };
        yield return new object[] { "OE-004-09", "test4@example.com", true, true };
        yield return new object[] { "OE-004-10", "test5@example.com", false, false };
        yield return new object[] { "OE-004-11", "test6@example.com", true, true };
    }

    #endregion

    #region OE-005: Clear OTP Cases

    /// <summary>
    /// OE-005: Clear OTP (all keys) test cases.
    /// Returns: (caseId, email)
    /// </summary>
    public static IEnumerable<object[]> GetClearOtpCases()
    {
        yield return new object[] { "OE-005-01", "user@example.com" };
        yield return new object[] { "OE-005-02", "USER@EXAMPLE.COM" };
        yield return new object[] { "OE-005-03", "  user@example.com  " };
        yield return new object[] { "OE-005-04", "test1@example.com" };
        yield return new object[] { "OE-005-05", "test2@example.com" };
        yield return new object[] { "OE-005-06", "test3@example.com" };
        yield return new object[] { "OE-005-07", "test4@example.com" };
        yield return new object[] { "OE-005-08", "test5@example.com" };
        yield return new object[] { "OE-005-09", "test6@example.com" };
        yield return new object[] { "OE-005-10", "test7@example.com" };
        yield return new object[] { "OE-005-11", "test8@example.com" };
    }

    #endregion

    #region OE-006: Touch Resend Cooldown Cases

    /// <summary>
    /// OE-006: Touch resend cooldown test cases.
    /// Returns: (caseId, email, cooldownSeconds)
    /// </summary>
    public static IEnumerable<object[]> GetTouchCooldownCases()
    {
        yield return new object[] { "OE-006-01", "user@example.com", 30 };
        yield return new object[] { "OE-006-02", "USER@EXAMPLE.COM", 60 };
        yield return new object[] { "OE-006-03", "  user@example.com  ", 90 };
        yield return new object[] { "OE-006-04", "test1@example.com", 10 };
        yield return new object[] { "OE-006-05", "test2@example.com", 120 };
        yield return new object[] { "OE-006-06", "test3@example.com", 30 };
        yield return new object[] { "OE-006-07", "test4@example.com", 30 };
        yield return new object[] { "OE-006-08", "test5@example.com", 30 };
        yield return new object[] { "OE-006-09", "test6@example.com", 30 };
        yield return new object[] { "OE-006-10", "test7@example.com", 30 };
        yield return new object[] { "OE-006-11", "test8@example.com", 30 };
    }

    #endregion

    #region OE-007: Get Cooldown Remaining Cases

    /// <summary>
    /// OE-007: Get remaining cooldown time test cases.
    /// Returns: (caseId, email, ttlSeconds, expectedSeconds)
    /// </summary>
    public static IEnumerable<object?[]> GetCooldownRemainingCases()
    {
        yield return new object?[] { "OE-007-01", "user@example.com", null, 0 };       // No key
        yield return new object?[] { "OE-007-02", "user@example.com", 30, 30 };        // 30 seconds left
        yield return new object?[] { "OE-007-03", "user@example.com", 0, 0 };          // Expired
        yield return new object?[] { "OE-007-04", "user@example.com", -5, 0 };         // Negative (expired)
        yield return new object?[] { "OE-007-05", "user@example.com", 60, 60 };
        yield return new object?[] { "OE-007-06", "user@example.com", 1, 1 };
        yield return new object?[] { "OE-007-07", "user@example.com", 120, 120 };
        yield return new object?[] { "OE-007-08", "user@example.com", 5, 5 };
        yield return new object?[] { "OE-007-09", "user@example.com", 10, 10 };
        yield return new object?[] { "OE-007-10", "user@example.com", 15, 15 };
        yield return new object?[] { "OE-007-11", "user@example.com", 25, 25 };
    }

    #endregion

    #region OE-008/009: Send Email Cases

    /// <summary>
    /// OE-008/009: Email sending test cases.
    /// Returns: (caseId, toEmail, subject, body, expectedSuccess, throwsException)
    /// </summary>
    public static IEnumerable<object?[]> GetSendEmailCases()
    {
        // OE-008: Failures
        yield return new object?[] { "OE-008-01", null, "Subject", "Body", false, true };
        yield return new object?[] { "OE-008-02", "", "Subject", "Body", false, true };
        yield return new object?[] { "OE-008-03", "invalid-email", "Subject", "Body", false, true };
        yield return new object?[] { "OE-008-04", "user@example.com", null, "Body", false, true };
        yield return new object?[] { "OE-008-05", "user@example.com", "", "Body", false, true };

        // OE-009: Success
        yield return new object?[] { "OE-009-01", "user@example.com", "Welcome", "Hello!", true, false };
        yield return new object?[] { "OE-009-02", "user@example.com", "OTP", "Your code is 123456", true, false };
        yield return new object?[] { "OE-009-03", "user@example.com", "Reset", "Click here to reset", true, false };
        yield return new object?[] { "OE-009-04", "user@example.com", "Verify", "Please verify your email", true, false };
        yield return new object?[] { "OE-009-05", "user@example.com", "Newsletter", "Check out our updates", true, false };
        yield return new object?[] { "OE-009-06", "user@example.com", "Alert", "Security alert", true, false };
    }

    #endregion
}
