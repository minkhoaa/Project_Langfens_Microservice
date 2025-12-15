# Test Coverage Traceability

FunctionName | Service | Endpoint | #Cases>=10 | Status | Notes
--- | --- | --- | --- | --- | ---
Register account (valid email) | auth-service | POST /api/auth/register | 0 | Pending | Not automated yet
Register account (duplicate email) | auth-service | POST /api/auth/register | 0 | Pending | Not automated yet
Register account (invalid email format) | auth-service | POST /api/auth/register | 0 | Pending | Not automated yet
Verify OTP (correct) | auth-service | GET /api/auth/verify | 0 | Pending | Not automated yet
Verify OTP (incorrect) | auth-service | GET /api/auth/verify | 0 | Pending | Not automated yet
Verify OTP (expired) | auth-service | GET /api/auth/verify | 0 | Pending | Not automated yet
Resend OTP (if supported) | auth-service | POST /api/auth/resend-otp | 0 | Pending | Not automated yet
Password login (success) | auth-service | POST /api/auth/login | 0 | Pending | Not automated yet
Password login (wrong password) | auth-service | POST /api/auth/login | 0 | Pending | Not automated yet
Password login (non-existing email) | auth-service | POST /api/auth/login | 0 | Pending | Not automated yet
Google login (success) | auth-service | POST /api/auth/login-google | 0 | Pending | Not automated yet
Google login (failed/canceled) | auth-service | POST /api/auth/login-google | 0 | Pending | Not automated yet
Logout | auth-service | POST /api/auth/logout | 0 | Pending | Not automated yet
Forgot password (request OTP) | auth-service | POST /api/auth/forgot-password | 0 | Pending | Not automated yet
Forgot password (non-existing email) | auth-service | POST /api/auth/forgot-password | 0 | Pending | Not automated yet
Reset password (valid OTP) | auth-service | POST /api/auth/confirm-otp-reset-password | 0 | Pending | Not automated yet
Reset password (invalid/expired OTP) | auth-service | POST /api/auth/confirm-otp-reset-password | 0 | Pending | Not automated yet
Browse exams list | exam-service | GET /api/public/exam/getall | 0 | Pending | Not automated yet
View exam detail (by slug/id) | exam-service | GET /api/public/exam/getby/{slug} | 0 | Pending | Not automated yet
Search/filter exams (if available) | exam-service | GET /api/public/exam/getall | 0 | Pending | Not automated yet
Browse courses list | course-service | GET /api/course/getpublishedcourse | 0 | Pending | Not automated yet
View course detail (by slug/id) | course-service | GET /api/course/getbyslug/{slug} | 0 | Pending | Not automated yet
Browse vocabulary decks list | vocabulary-service | GET /api/decks/ | 0 | Pending | Not automated yet
View deck detail (full content) | vocabulary-service | GET /api/decks/{slug} | 0 | Pending | Not automated yet
Subscribe to a deck (success) | vocabulary-service | POST /api/users/{userId}/subscribe/{deckId} | 0 | Pending | Not automated yet
Subscribe to a deck (unauthenticated) | vocabulary-service | POST /api/users/{userId}/subscribe/{deckId} | 0 | Pending | Not automated yet
View my subscribed decks | vocabulary-service | GET /api/users/{userId}/subscribe | 0 | Pending | Not automated yet
Review flashcards (record outcome) | vocabulary-service | POST /api/users/{userId}/flashcard/{cardId}/review | 0 | Pending | Not automated yet
Enroll in a course (success) | course-service | GET /api/course/{courseId}/{userId}:enroll | 0 | Pending | Not automated yet
Enroll in a course (unauthenticated) | course-service | GET /api/course/{courseId}/{userId}:enroll | 0 | Pending | Not automated yet
View my enrollments | course-service | POST /api/lesson/{userId}/progress | 0 | Pending | Not automated yet
Start exam attempt (success) | attempt-service | POST /api/attempt/attempts:start | 0 | Pending | Not automated yet
Save answers during attempt (as implemented) | attempt-service | POST /api/attempt/autosave/{attemptId} | 0 | Pending | Not automated yet
Submit attempt (manual submit) | attempt-service | POST /api/attempt/submit/{attemptId} | 0 | Pending | Not automated yet
Submit when time expired (returns “Expired”) | attempt-service | POST /api/attempt/submit/{attemptId} | 0 | Pending | Not automated yet
View attempt history (list) | attempt-service | GET /api/attempt/getlistattempt | 0 | Pending | Not automated yet
View attempt result detail (if available) | attempt-service | GET /api/attempt/getresult/{attemptId} | 0 | Pending | Not automated yet
Admin manage exam catalog (create/update) | exam-service | POST /api/admin/exam/addexam | 0 | Pending | Not automated yet
Admin edit exam structure | exam-service | /api/admin/section | 0 | Pending | Not automated yet
Admin manage courses & lessons | course-service | /api/admin/course | 0 | Pending | Not automated yet
Admin manage decks & cards | vocabulary-service | /api/users deck/card routes | 0 | Pending | Not automated yet
Admin manage speaking exams | speaking-service | /api/admin/speaking | 0 | Pending | Not automated yet
Admin manage writing exams | writing-service | /api/admin/writing | 0 | Pending | Not automated yet
Admin monitor attempts (list only) | attempt-service | GET /api/admin/attempt | 0 | Pending | Not automated yet
Internal fetch delivery snapshot (success) | exam-service | GET /api/internal/exams/{id}/delivery | 0 | Pending | Not automated yet
Internal fetch delivery snapshot (general error) | exam-service | GET /api/internal/exams/{id}/delivery | 0 | Pending | Not automated yet
