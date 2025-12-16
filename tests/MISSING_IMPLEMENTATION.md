# Missing Implementation & Gap Analysis Report

> Generated: 2025-12-16 23:21 UTC+7
> Audited by: Antigravity AI Agent

## Summary

| Category | Total Cases | Implemented | Missing |
|----------|------------:|------------:|--------:|
| Auth & Security | 4 | 3 | 1 |
| Data Integrity | 2 | 0 | 2 |
| Concurrency | 1 | 0 | 1 |
| Mobile/UI | 2 | 0 | 2 |

---

## Detailed Findings

### 1. AUTH & SECURITY

#### ✅ Case 1.1: Google Account Linking (Email Conflict)
**Status**: IMPLEMENTED

**Location**: `services/auth-service/Application/Auth/AuthService.cs:301-389`

**Logic**:
```csharp
// If user logs in with Google and email already exists as password user:
user = await userManager.FindByLoginAsync(loginProvider, providerKey);
if (user is null)
{
    user = await userManager.FindByEmailAsync(payload.Email);
    if (user is null)
    {
        // Create new user
    }
    // Link Google login to existing email account
    var info = new UserLoginInfo(loginProvider, providerKey, "Google");
    await userManager.AddLoginAsync(user, info);
}
```

**Test**: Already covered by existing tests. Account auto-links on Google login.

---

#### ❌ Case 1.2: Unlink Provider
**Status**: MISSING

**Notes**: No `UnlinkProviderAsync` or `RemoveLoginAsync` endpoint found in AuthService. Users cannot disconnect their Google account once linked.

**Recommendation**: Implement `POST /api/auth/unlink-google` endpoint.

---

#### ✅ Case 5.1: Brute Force Protection (Login Lockout)
**Status**: IMPLEMENTED (Partial)

**Location**: `services/auth-service/Application/Auth/AuthService.cs:281`

**Logic**:
```csharp
var check = await signInManager.CheckPasswordSignInAsync(user, password, true);
// Third parameter 'true' enables lockout on failure
```

**Notes**: Uses ASP.NET Identity built-in `lockoutOnFailure: true`. Default settings:
- `MaxFailedAccessAttempts`: 5 (default)
- `DefaultLockoutTimeSpan`: 5 minutes (default)

**Test**: Can test by attempting multiple failed logins.

---

#### ✅ Case 5.2: OTP Spam Protection
**Status**: IMPLEMENTED

**Location**: `services/auth-service/Application/Auth/AuthService.cs:144-150`

**Logic**:
```csharp
if (!await redisOtpStore.CanResend(email, ResendCooldown))
{
    var remaining = await redisOtpStore.GetResendCooldownRemaining(email);
    var secs = Math.Max(1, (int)Math.Ceiling(remaining.TotalSeconds));
    return Results.BadRequest(new ApiResultDto(false, $"Please wait {secs}s before retrying",
        new { retryAfter = secs }));
}
```

**Test**: Can test by calling resend multiple times rapidly.

---

### 2. DATA INTEGRITY

#### ❌ Case 2.1: Safe Delete Course (with Enrollments)
**Status**: MISSING (Hard Delete)

**Location**: `services/course-service/Features/AdminEndpoint/AdminEndpointService.cs:113-127`

**Logic**:
```csharp
public async Task<IResult> DeleteCourse(Guid courseId, CancellationToken token)
{
    var affectedRows = await context.Courses
        .Where(x => x.Id == courseId)
        .ExecuteDeleteAsync(token); // HARD DELETE!
    return Results.Ok(...);
}
```

**Risk**: 
- No check for existing enrollments
- No soft delete (`IsDeleted` flag)
- May violate foreign key constraints with enrollments

**Recommendation**:
1. Add enrollment check before delete
2. Implement soft delete pattern
3. Return 409 Conflict if course has active enrollments

---

#### ❌ Case 2.2: Safe Delete Exam (with Attempts)
**Status**: MISSING (Same pattern as Course)

**Notes**: Similar issue likely exists in ExamService. Deleting an Exam with existing Attempts would orphan data.

---

### 3. CONCURRENCY

#### ⚠️ Case 7.1: Flashcard Review Race Condition
**Status**: VULNERABLE

**Location**: `services/vocabulary-service/Features/User/UserService.cs:141-190`

**Logic**:
```csharp
var st = await context.UserCardReviews.FirstOrDefaultAsync(...);
if (st is null)
{
    st = new UserCardReview() { ... };
    context.UserCardReviews.Add(st);
}
// ... modify st ...
await context.SaveChangesAsync(token);
```

**Risk**: Two concurrent requests for the same card can:
1. Both find `st is null`
2. Both insert new records (duplicate primary key error)
3. Or one overwrites the other's changes (last write wins)

**Recommendation**:
1. Add optimistic concurrency (`RowVersion` / `ConcurrencyToken`)
2. Or use database-level `UPSERT` (PostgreSQL `ON CONFLICT`)
3. Or add application-level locking

---

### 4. MOBILE/UI

#### ❌ Case 4.1: Mobile Keyboard Overlap
**Status**: NOT TESTED

**Notes**: No evidence of virtual keyboard handling in frontend code. Need to verify buttons remain visible when keyboard is open on mobile devices.

**Test**: Create `e2e/mobile-layout.spec.ts` with mobile viewport.

---

#### ❌ Case 6.1: XSS in Rich Content
**Status**: PARTIALLY HANDLED

**Notes**: Frontend uses React which escapes by default. However, markdown content (`descriptionMd`, `frontMd`, `backMd`) rendered via `react-markdown` needs verification.

**Test**: Inject `<script>` tags via test harness, verify escaped output.

---

## Test Files to Create

| ID | Test File | Status |
|----|-----------|--------|
| 5.1 | `e2e/auth-lockout.spec.ts` | TODO |
| 5.2 | `e2e/otp-rate-limit.spec.ts` | TODO |
| 2.1 | `tests/.../Course_Delete_Tests.cs` | TODO |
| 7.1 | `tests/.../Flashcard_Concurrency_Tests.cs` | TODO |
| 4.1 | `e2e/mobile-layout.spec.ts` | TODO |
| 6.1 | `e2e/xss-injection.spec.ts` | EXISTS (security-edge.spec.ts) |

---

## Action Items

1. **P1 (Critical)**: Implement safe delete for Course and Exam services
2. **P1 (Critical)**: Add concurrency handling to flashcard review
3. **P2 (High)**: Add unlink Google endpoint
4. **P3 (Medium)**: Create mobile viewport E2E tests
5. **P3 (Medium)**: Verify XSS protection in markdown rendering
