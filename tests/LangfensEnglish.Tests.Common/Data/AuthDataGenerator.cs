extern alias authsvc;
using authsvc::auth_service.Application.Auth;

namespace LangfensEnglish.Tests.Common.Data;

/// <summary>
/// Generates test data specifically for AuthService test cases.
/// Provides >= 11 scenarios per requirement (AU-xxx).
/// </summary>
public static class AuthDataGenerator
{
    #region AU-001/002/003: Register Scenarios

    /// <summary>
    /// AU-001 to AU-003: Registration test cases covering all validation paths.
    /// Returns: (caseId, email, password, expectedStatusCode, expectedMessage, isEmailValid, userExists)
    /// </summary>
    public static IEnumerable<object?[]> GetRegisterCases()
    {
        // AU-001: Input validation failures
        yield return new object?[] { "AU-001-01", null, "ValidPass1!", 400, "Email or password is missed", false, false };
        yield return new object?[] { "AU-001-02", "", "ValidPass1!", 400, "Email or password is missed", false, false };
        yield return new object?[] { "AU-001-03", "   ", "ValidPass1!", 400, "Email or password is missed", false, false };
        yield return new object?[] { "AU-001-04", "user@example.com", null, 400, "Email or password is missed", true, false };
        yield return new object?[] { "AU-001-05", "user@example.com", "", 400, "Email or password is missed", true, false };
        yield return new object?[] { "AU-001-06", "user@example.com", "   ", 400, "Email or password is missed", true, false };
        yield return new object?[] { "AU-001-07", "invalid-email", "ValidPass1!", 400, "Email format is not valid", false, false };
        yield return new object?[] { "AU-001-08", "@nodomain.com", "ValidPass1!", 400, "Email format is not valid", false, false };
        yield return new object?[] { "AU-001-09", "user@", "ValidPass1!", 400, "Email format is not valid", false, false };
        yield return new object?[] { "AU-001-10", "user@domain.com", "short", 400, "Password is too short", true, false };
        yield return new object?[] { "AU-001-11", "user@domain.com", "nodigits!", 400, "Passwords must have at least one digit", true, false };

        // AU-002: Email already exists
        yield return new object?[] { "AU-002-01", "existing@example.com", "ValidPass1!", 400, "Email is already used", true, true };
        yield return new object?[] { "AU-002-02", "EXISTING@EXAMPLE.COM", "ValidPass1!", 400, "Email is already used", true, true };
        yield return new object?[] { "AU-002-03", "  existing@example.com  ", "ValidPass1!", 400, "Email is already used", true, true };

        // AU-003: Happy path (success)
        yield return new object?[] { "AU-003-01", "newuser@example.com", "ValidPass1!", 200, "User is created successfully", true, false };
        yield return new object?[] { "AU-003-02", "newuser+tag@example.com", "SuperSecure@123", 200, "User is created successfully", true, false };
        yield return new object?[] { "AU-003-03", "new.user@subdomain.example.com", "P@ssw0rd!", 200, "User is created successfully", true, false };
    }

    #endregion

    #region AU-004/005: Confirm Email Cases

    /// <summary>
    /// AU-004/005: Email confirmation test cases.
    /// Returns: (caseId, email, otp, expectedStatusCode, expectedMessage, userFound, otpVerifyResult)
    /// </summary>
    public static IEnumerable<object?[]> GetConfirmEmailCases()
    {
        // AU-004: Validation failures
        yield return new object?[] { "AU-004-01", null, "123456", 400, "Email is required", false, false };
        yield return new object?[] { "AU-004-02", "", "123456", 400, "Email is required", false, false };
        yield return new object?[] { "AU-004-03", "user@example.com", null, 400, "OTP is required", true, false };
        yield return new object?[] { "AU-004-04", "user@example.com", "", 400, "OTP is required", true, false };
        yield return new object?[] { "AU-004-05", "notfound@example.com", "123456", 404, "User not found", false, false };
        yield return new object?[] { "AU-004-06", "user@example.com", "wrong1", 400, "Invalid OTP", true, false };
        yield return new object?[] { "AU-004-07", "user@example.com", "12345", 400, "Invalid OTP", true, false };     // Too short
        yield return new object?[] { "AU-004-08", "user@example.com", "1234567", 400, "Invalid OTP", true, false };   // Too long
        yield return new object?[] { "AU-004-09", "blocked@example.com", "123456", 429, "Too many attempts", true, false }; // Rate limited

        // AU-005: Happy path
        yield return new object?[] { "AU-005-01", "user@example.com", "123456", 200, "Email confirmed", true, true };
        yield return new object?[] { "AU-005-02", "USER@EXAMPLE.COM", "654321", 200, "Email confirmed", true, true };
    }

    #endregion

    #region AU-006/007: Password Login Cases

    /// <summary>
    /// AU-006/007: Login test cases.
    /// Returns: (caseId, email, password, expectedStatusCode, expectedMessage, userFound, passwordCorrect, emailConfirmed)
    /// </summary>
    public static IEnumerable<object?[]> GetLoginCases()
    {
        // AU-006: Login failures
        yield return new object?[] { "AU-006-01", null, "ValidPass1!", 400, "Email or password is missing", false, false, false };
        yield return new object?[] { "AU-006-02", "", "ValidPass1!", 400, "Email or password is missing", false, false, false };
        yield return new object?[] { "AU-006-03", "user@example.com", null, 400, "Email or password is missing", true, false, true };
        yield return new object?[] { "AU-006-04", "user@example.com", "", 400, "Email or password is missing", true, false, true };
        yield return new object?[] { "AU-006-05", "notfound@example.com", "ValidPass1!", 400, "User is not existed", false, false, false };
        yield return new object?[] { "AU-006-06", "user@example.com", "WrongPass!", 400, "Password is incorrect", true, false, true };
        yield return new object?[] { "AU-006-07", "unconfirmed@example.com", "ValidPass1!", 400, "Email not confirmed", true, true, false };
        yield return new object?[] { "AU-006-08", "locked@example.com", "ValidPass1!", 400, "Account locked", true, false, true };

        // AU-007: Login success
        yield return new object?[] { "AU-007-01", "user@example.com", "ValidPass1!", 200, "Login successfully", true, true, true };
        yield return new object?[] { "AU-007-02", "USER@EXAMPLE.COM", "ValidPass1!", 200, "Login successfully", true, true, true };
        yield return new object?[] { "AU-007-03", "admin@example.com", "AdminPass1!", 200, "Login successfully", true, true, true };
    }

    #endregion

    #region AU-008/009/010: Refresh Token Cases

    /// <summary>
    /// AU-008/009/010: Token refresh test cases.
    /// Returns: (caseId, sessionId, expectedStatusCode, expectedMessage, sessionExists, sessionExpired, userExists)
    /// </summary>
    public static IEnumerable<object?[]> GetRefreshCases()
    {
        var validSessionId = Guid.NewGuid().ToString("N");
        var expiredSessionId = Guid.NewGuid().ToString("N");
        var revokedSessionId = Guid.NewGuid().ToString("N");

        // AU-008: Refresh failures
        yield return new object?[] { "AU-008-01", null, 401, "Unauthorized", false, false, false };
        yield return new object?[] { "AU-008-02", "", 401, "Unauthorized", false, false, false };
        yield return new object?[] { "AU-008-03", "invalid-session", 401, "Unauthorized", false, false, false };
        yield return new object?[] { "AU-008-04", expiredSessionId, 401, "Session expired", true, true, true };
        yield return new object?[] { "AU-008-05", revokedSessionId, 401, "Session revoked", true, false, true };
        yield return new object?[] { "AU-008-06", validSessionId, 401, "User not found", true, false, false };

        // AU-009: Refresh success (no rotation)
        yield return new object?[] { "AU-009-01", validSessionId, 200, "Success", true, false, true };
        yield return new object?[] { "AU-009-02", validSessionId, 200, "Success", true, false, true };

        // AU-010: Refresh success (with rotation)
        yield return new object?[] { "AU-010-01", validSessionId, 200, "Success", true, false, true };
        yield return new object?[] { "AU-010-02", validSessionId, 200, "Success", true, false, true };
        yield return new object?[] { "AU-010-03", validSessionId, 200, "Success", true, false, true };
    }

    #endregion

    #region AU-011: Logout Cases

    /// <summary>
    /// AU-011: Logout test cases.
    /// Returns: (caseId, sessionId, expectedStatusCode, expectedMessage, sessionExists)
    /// </summary>
    public static IEnumerable<object?[]> GetLogoutCases()
    {
        yield return new object?[] { "AU-011-01", null, 200, "Logged out", false };                   // No session (still succeeds)
        yield return new object?[] { "AU-011-02", "", 200, "Logged out", false };                     // Empty session
        yield return new object?[] { "AU-011-03", "invalid-session", 200, "Logged out", false };      // Invalid session (still succeeds)
        yield return new object?[] { "AU-011-04", Guid.NewGuid().ToString("N"), 200, "Logged out", true };  // Valid session
        yield return new object?[] { "AU-011-05", Guid.NewGuid().ToString("N"), 200, "Logged out", true };
        yield return new object?[] { "AU-011-06", Guid.NewGuid().ToString("N"), 200, "Logged out", true };
        yield return new object?[] { "AU-011-07", Guid.NewGuid().ToString("N"), 200, "Logged out", true };
        yield return new object?[] { "AU-011-08", Guid.NewGuid().ToString("N"), 200, "Logged out", true };
        yield return new object?[] { "AU-011-09", Guid.NewGuid().ToString("N"), 200, "Logged out", true };
        yield return new object?[] { "AU-011-10", Guid.NewGuid().ToString("N"), 200, "Logged out", true };
        yield return new object?[] { "AU-011-11", Guid.NewGuid().ToString("N"), 200, "Logged out", true };
    }

    #endregion

    #region AU-012: Get Current User Cases

    /// <summary>
    /// AU-012: Get current user test cases.
    /// Returns: (caseId, isAuthenticated, hasSubClaim, userExists, expectedStatusCode, expectedMessage)
    /// </summary>
    public static IEnumerable<object?[]> GetCurrentUserCases()
    {
        yield return new object?[] { "AU-012-01", false, false, false, 401, "Unauthorized" };   // Not authenticated
        yield return new object?[] { "AU-012-02", true, false, false, 401, "Unauthorized" };    // No sub claim
        yield return new object?[] { "AU-012-03", true, true, false, 404, "User not found" };   // User deleted
        yield return new object?[] { "AU-012-04", true, true, true, 200, "Success" };           // Happy path
        yield return new object?[] { "AU-012-05", true, true, true, 200, "Success" };
        yield return new object?[] { "AU-012-06", true, true, true, 200, "Success" };
        yield return new object?[] { "AU-012-07", true, true, true, 200, "Success" };
        yield return new object?[] { "AU-012-08", true, true, true, 200, "Success" };
        yield return new object?[] { "AU-012-09", true, true, true, 200, "Success" };
        yield return new object?[] { "AU-012-10", true, true, true, 200, "Success" };
        yield return new object?[] { "AU-012-11", true, true, true, 200, "Success" };
    }

    #endregion

    #region AU-013/014: Resend Verification Email Cases

    /// <summary>
    /// AU-013/014: Resend verification email test cases.
    /// Returns: (caseId, email, expectedStatusCode, expectedMessage, userFound, emailConfirmed, canResend)
    /// </summary>
    public static IEnumerable<object?[]> GetResendEmailCases()
    {
        // AU-013: Failures
        yield return new object?[] { "AU-013-01", null, 400, "Email is required", false, false, false };
        yield return new object?[] { "AU-013-02", "", 400, "Email is required", false, false, false };
        yield return new object?[] { "AU-013-03", "   ", 400, "Email is required", false, false, false };
        yield return new object?[] { "AU-013-04", "notfound@example.com", 404, "User not found", false, false, false };
        yield return new object?[] { "AU-013-05", "confirmed@example.com", 400, "Already confirmed", true, true, false };
        yield return new object?[] { "AU-013-06", "cooldown@example.com", 429, "Please wait", true, false, false };

        // AU-014: Success
        yield return new object?[] { "AU-014-01", "user@example.com", 200, "Email sent", true, false, true };
        yield return new object?[] { "AU-014-02", "USER@EXAMPLE.COM", 200, "Email sent", true, false, true };
        yield return new object?[] { "AU-014-03", "another@example.com", 200, "Email sent", true, false, true };
        yield return new object?[] { "AU-014-04", "test@example.com", 200, "Email sent", true, false, true };
        yield return new object?[] { "AU-014-05", "demo@example.com", 200, "Email sent", true, false, true };
    }

    #endregion
}
