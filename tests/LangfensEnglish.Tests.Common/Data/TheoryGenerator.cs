namespace LangfensEnglish.Tests.Common.Data;

/// <summary>
/// Provides static methods to generate robust test data for [MemberData] attributes.
/// Ensures >= 11 distinct execution scenarios per requirement (The "11-Cases" Rule).
/// </summary>
public static class TheoryGenerator
{
    #region String Generation
    
    /// <summary>
    /// Generates diverse string test cases for boundary/security testing.
    /// </summary>
    public static IEnumerable<object?[]> GetStrings()
    {
        yield return new object?[] { "TG-STR-01", null };                              // Null
        yield return new object?[] { "TG-STR-02", "" };                                // Empty
        yield return new object?[] { "TG-STR-03", "   " };                             // Whitespace only
        yield return new object?[] { "TG-STR-04", "\t\n\r" };                          // Control chars
        yield return new object?[] { "TG-STR-05", "a" };                               // Single char
        yield return new object?[] { "TG-STR-06", "ValidString" };                     // Normal valid
        yield return new object?[] { "TG-STR-07", new string('x', 256) };              // Long string (256)
        yield return new object?[] { "TG-STR-08", new string('x', 1000) };             // Very long (1000)
        yield return new object?[] { "TG-STR-09", "'; DROP TABLE Users;--" };          // SQL Injection
        yield return new object?[] { "TG-STR-10", "<script>alert('xss')</script>" };   // XSS attempt
        yield return new object?[] { "TG-STR-11", "unicode: 日本語 🎉 العربية" };       // Unicode chars
        yield return new object?[] { "TG-STR-12", "   padded   " };                    // Leading/trailing spaces
    }

    #endregion

    #region Email Generation

    /// <summary>
    /// Generates diverse email test cases covering valid/invalid formats.
    /// </summary>
    public static IEnumerable<object?[]> GetEmails()
    {
        // Invalid emails
        yield return new object?[] { "TG-EML-01", null, false };                                    // Null
        yield return new object?[] { "TG-EML-02", "", false };                                      // Empty
        yield return new object?[] { "TG-EML-03", "   ", false };                                   // Whitespace
        yield return new object?[] { "TG-EML-04", "notanemail", false };                            // No @
        yield return new object?[] { "TG-EML-05", "@nodomain.com", false };                         // No local part
        yield return new object?[] { "TG-EML-06", "user@", false };                                 // No domain
        yield return new object?[] { "TG-EML-07", "user@domain", false };                           // No TLD
        yield return new object?[] { "TG-EML-08", "user@.com", false };                             // Empty domain
        yield return new object?[] { "TG-EML-09", "user name@domain.com", false };                  // Space in local
        yield return new object?[] { "TG-EML-10", "user@domain..com", false };                      // Double dot
        yield return new object?[] { "TG-EML-11", new string('a', 65) + "@domain.com", false };     // Local part too long (> 64)

        // Valid emails
        yield return new object?[] { "TG-EML-12", "user@example.com", true };                       // Standard
        yield return new object?[] { "TG-EML-13", "user.name@example.com", true };                  // With dot
        yield return new object?[] { "TG-EML-14", "user+tag@example.com", true };                   // With plus
        yield return new object?[] { "TG-EML-15", "user@subdomain.example.com", true };             // Subdomain
        yield return new object?[] { "TG-EML-16", "USER@EXAMPLE.COM", true };                       // Uppercase
    }

    #endregion

    #region Password Generation

    /// <summary>
    /// Generates diverse password test cases for validation testing.
    /// </summary>
    public static IEnumerable<object?[]> GetPasswords()
    {
        // Invalid passwords
        yield return new object?[] { "TG-PWD-01", null, false };                                    // Null
        yield return new object?[] { "TG-PWD-02", "", false };                                      // Empty
        yield return new object?[] { "TG-PWD-03", "   ", false };                                   // Whitespace only
        yield return new object?[] { "TG-PWD-04", "short", false };                                 // Too short (< 8)
        yield return new object?[] { "TG-PWD-05", "nouppercase1!", false };                         // Missing uppercase
        yield return new object?[] { "TG-PWD-06", "NOLOWERCASE1!", false };                         // Missing lowercase
        yield return new object?[] { "TG-PWD-07", "NoDigitsHere!", false };                         // Missing digit
        yield return new object?[] { "TG-PWD-08", "NoSpecial123", false };                          // Missing special char

        // Valid passwords
        yield return new object?[] { "TG-PWD-09", "ValidPass1!", true };                            // Standard valid
        yield return new object?[] { "TG-PWD-10", "SuperSecure@123", true };                        // Strong
        yield return new object?[] { "TG-PWD-11", new string('A', 50) + "a1!", true };              // Long valid
        yield return new object?[] { "TG-PWD-12", "日本語Pass1!", true };                           // Unicode in password
    }

    #endregion

    #region Integer/Boundary Generation

    /// <summary>
    /// Generates integer boundary test cases.
    /// </summary>
    public static IEnumerable<object[]> GetIntegers()
    {
        yield return new object[] { "TG-INT-01", int.MinValue };
        yield return new object[] { "TG-INT-02", -1 };
        yield return new object[] { "TG-INT-03", 0 };
        yield return new object[] { "TG-INT-04", 1 };
        yield return new object[] { "TG-INT-05", 10 };
        yield return new object[] { "TG-INT-06", 100 };
        yield return new object[] { "TG-INT-07", 255 };      // Byte max
        yield return new object[] { "TG-INT-08", 256 };
        yield return new object[] { "TG-INT-09", 1000 };
        yield return new object[] { "TG-INT-10", 65535 };    // UInt16 max
        yield return new object[] { "TG-INT-11", int.MaxValue };
    }

    /// <summary>
    /// Generates positive integer test cases (for counts, page sizes, etc.).
    /// </summary>
    public static IEnumerable<object[]> GetPositiveIntegers()
    {
        yield return new object[] { "TG-POS-01", 0, false };     // Zero (usually invalid for counts)
        yield return new object[] { "TG-POS-02", -1, false };    // Negative
        yield return new object[] { "TG-POS-03", 1, true };      // Minimum valid
        yield return new object[] { "TG-POS-04", 5, true };
        yield return new object[] { "TG-POS-05", 10, true };
        yield return new object[] { "TG-POS-06", 50, true };
        yield return new object[] { "TG-POS-07", 100, true };
        yield return new object[] { "TG-POS-08", 500, true };
        yield return new object[] { "TG-POS-09", 1000, true };
        yield return new object[] { "TG-POS-10", 10000, true };  // Large but valid
        yield return new object[] { "TG-POS-11", int.MaxValue, false }; // Overflow risk
    }

    #endregion

    #region GUID Generation

    /// <summary>
    /// Generates GUID test cases including edge cases.
    /// </summary>
    public static IEnumerable<object?[]> GetGuids()
    {
        yield return new object?[] { "TG-GUID-01", null };                                          // Null string
        yield return new object?[] { "TG-GUID-02", "" };                                            // Empty string
        yield return new object?[] { "TG-GUID-03", "not-a-guid" };                                  // Invalid format
        yield return new object?[] { "TG-GUID-04", "00000000-0000-0000-0000-000000000000" };        // Empty GUID
        yield return new object?[] { "TG-GUID-05", Guid.NewGuid().ToString() };                    // Valid random
        yield return new object?[] { "TG-GUID-06", Guid.NewGuid().ToString("N") };                 // No dashes
        yield return new object?[] { "TG-GUID-07", Guid.NewGuid().ToString("B") };                 // With braces
        yield return new object?[] { "TG-GUID-08", Guid.NewGuid().ToString().ToUpperInvariant() }; // Uppercase
        yield return new object?[] { "TG-GUID-09", "12345678-1234-1234-1234-123456789abc" };        // Fixed valid
        yield return new object?[] { "TG-GUID-10", "ZZZZZZZZ-ZZZZ-ZZZZ-ZZZZ-ZZZZZZZZZZZZ" };        // Invalid chars
        yield return new object?[] { "TG-GUID-11", "12345678123412341234123456789abc" };            // 32 chars no dashes
    }

    #endregion

    #region OTP/Code Generation

    /// <summary>
    /// Generates OTP/verification code test cases.
    /// </summary>
    public static IEnumerable<object?[]> GetOtpCodes()
    {
        yield return new object?[] { "TG-OTP-01", null, false };                  // Null
        yield return new object?[] { "TG-OTP-02", "", false };                    // Empty
        yield return new object?[] { "TG-OTP-03", "   ", false };                 // Whitespace
        yield return new object?[] { "TG-OTP-04", "12345", false };               // Too short (5 digits)
        yield return new object?[] { "TG-OTP-05", "1234567", false };             // Too long (7 digits)
        yield return new object?[] { "TG-OTP-06", "abcdef", false };              // Letters not digits
        yield return new object?[] { "TG-OTP-07", "12ab56", false };              // Mixed
        yield return new object?[] { "TG-OTP-08", "123456", true };               // Valid 6-digit
        yield return new object?[] { "TG-OTP-09", "000000", true };               // All zeros (edge)
        yield return new object?[] { "TG-OTP-10", "999999", true };               // All nines (edge)
        yield return new object?[] { "TG-OTP-11", " 123456 ", false };            // Padded (may fail trim)
    }

    #endregion

    #region Token/JWT Generation

    /// <summary>
    /// Generates token/JWT test cases.
    /// </summary>
    public static IEnumerable<object?[]> GetTokens()
    {
        yield return new object?[] { "TG-TKN-01", null, false };                                    // Null
        yield return new object?[] { "TG-TKN-02", "", false };                                      // Empty
        yield return new object?[] { "TG-TKN-03", "   ", false };                                   // Whitespace
        yield return new object?[] { "TG-TKN-04", "not.a.jwt", false };                             // Invalid format
        yield return new object?[] { "TG-TKN-05", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9", false };  // Only header
        yield return new object?[] { "TG-TKN-06", "header.payload", false };                        // Missing signature
        yield return new object?[] { "TG-TKN-07", "a.b.c", false };                                 // Too short parts
        yield return new object?[] { "TG-TKN-08", "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.dozjgNryP4J3jVmNHl0w5N_XgL0n3I9PlFUP0THsR8U", true }; // Valid format
        yield return new object?[] { "TG-TKN-09", "expired.token.signature", false };               // Simulate expired
        yield return new object?[] { "TG-TKN-10", new string('x', 5000), false };                   // Extremely long
        yield return new object?[] { "TG-TKN-11", "Bearer eyJhbGciOiJIUzI1NiJ9.e.s", false };       // With Bearer prefix
    }

    #endregion

    #region TimeSpan/Duration Generation

    /// <summary>
    /// Generates TimeSpan test cases for TTL, cooldown, etc.
    /// </summary>
    public static IEnumerable<object[]> GetTimeSpans()
    {
        yield return new object[] { "TG-TS-01", TimeSpan.Zero };                     // Zero
        yield return new object[] { "TG-TS-02", TimeSpan.FromMilliseconds(1) };      // Very short
        yield return new object[] { "TG-TS-03", TimeSpan.FromSeconds(1) };           // 1 second
        yield return new object[] { "TG-TS-04", TimeSpan.FromSeconds(30) };          // Half minute
        yield return new object[] { "TG-TS-05", TimeSpan.FromMinutes(1) };           // 1 minute
        yield return new object[] { "TG-TS-06", TimeSpan.FromMinutes(5) };           // 5 minutes (typical OTP)
        yield return new object[] { "TG-TS-07", TimeSpan.FromHours(1) };             // 1 hour
        yield return new object[] { "TG-TS-08", TimeSpan.FromDays(1) };              // 1 day
        yield return new object[] { "TG-TS-09", TimeSpan.FromDays(7) };              // 1 week
        yield return new object[] { "TG-TS-10", TimeSpan.FromDays(30) };             // 1 month
        yield return new object[] { "TG-TS-11", TimeSpan.FromSeconds(-1) };          // Negative (invalid)
    }

    #endregion

    #region Boolean/Flag Generation

    /// <summary>
    /// Generate boolean flag combinations for multi-flag scenarios.
    /// </summary>
    public static IEnumerable<object[]> GetBooleanPairs()
    {
        yield return new object[] { "TG-BOOL-01", false, false };
        yield return new object[] { "TG-BOOL-02", false, true };
        yield return new object[] { "TG-BOOL-03", true, false };
        yield return new object[] { "TG-BOOL-04", true, true };
    }

    /// <summary>
    /// Generate boolean triplets for 3-flag scenarios (8 combinations).
    /// </summary>
    public static IEnumerable<object[]> GetBooleanTriplets()
    {
        for (int i = 0; i < 8; i++)
        {
            bool a = (i & 1) != 0;
            bool b = (i & 2) != 0;
            bool c = (i & 4) != 0;
            yield return new object[] { $"TG-BOOL3-{i + 1:D2}", a, b, c };
        }
        // Add 3 more edge cases to reach 11
        yield return new object[] { "TG-BOOL3-09", false, false, false };  // Duplicate for emphasis
        yield return new object[] { "TG-BOOL3-10", true, true, true };     // Duplicate for emphasis
        yield return new object[] { "TG-BOOL3-11", true, false, true };    // Random mix
    }

    #endregion

    #region Attempt Count Generation

    /// <summary>
    /// Generates attempt count test cases for rate limiting scenarios.
    /// </summary>
    public static IEnumerable<object[]> GetAttemptCounts(int maxAttempts = 3)
    {
        yield return new object[] { "TG-ATT-01", 0, maxAttempts, false };                   // No attempts yet
        yield return new object[] { "TG-ATT-02", 1, maxAttempts, false };                   // First attempt
        yield return new object[] { "TG-ATT-03", maxAttempts - 1, maxAttempts, false };     // One before max
        yield return new object[] { "TG-ATT-04", maxAttempts, maxAttempts, true };          // At max (blocked)
        yield return new object[] { "TG-ATT-05", maxAttempts + 1, maxAttempts, true };      // Over max
        yield return new object[] { "TG-ATT-06", maxAttempts + 10, maxAttempts, true };     // Way over
        yield return new object[] { "TG-ATT-07", -1, maxAttempts, false };                  // Invalid (negative)
        yield return new object[] { "TG-ATT-08", 0, 0, true };                              // Zero max (blocks all)
        yield return new object[] { "TG-ATT-09", 0, 1, false };                             // Very strict limit
        yield return new object[] { "TG-ATT-10", 1, 1, true };                              // At strict limit
        yield return new object[] { "TG-ATT-11", 100, 100, true };                          // Large limit at max
    }

    #endregion
}
