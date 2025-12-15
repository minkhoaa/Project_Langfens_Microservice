# Test Coverage Traceability

FunctionName | Service | Endpoint | #Cases>=10 | Status | Notes
--- | --- | --- | --- | --- | ---
Register account (valid email) | auth-service | POST /api/auth/register | 0 | Skip | Pending automation harness
Register account (duplicate email) | auth-service | POST /api/auth/register | 0 | Skip | Pending automation harness
Register account (invalid email format) | auth-service | POST /api/auth/register | 0 | Skip | Pending automation harness
Verify OTP (correct) | auth-service | GET /api/auth/verify | 0 | Skip | Pending automation harness
Verify OTP (incorrect) | auth-service | GET /api/auth/verify | 0 | Skip | Pending automation harness
Verify OTP (expired) | auth-service | GET /api/auth/verify | 0 | Skip | Pending automation harness
Resend OTP (if supported) | auth-service | POST /api/auth/resend-otp | 0 | Skip | Pending automation harness
Password login (success) | auth-service | POST /api/auth/login | 0 | Skip | Pending automation harness
Password login (wrong password) | auth-service | POST /api/auth/login | 0 | Skip | Pending automation harness
Password login (non-existing email) | auth-service | POST /api/auth/login | 0 | Skip | Pending automation harness
Google login (success) | auth-service | POST /api/auth/login-google | 0 | Skip | Pending automation harness
Google login (failed/canceled) | auth-service | POST /api/auth/login-google | 0 | Skip | Pending automation harness
Logout | auth-service | POST /api/auth/logout | 0 | Skip | Pending automation harness
Forgot password (request OTP) | auth-service | POST /api/auth/forgot-password | 0 | Skip | Pending automation harness
Forgot password (non-existing email) | auth-service | POST /api/auth/forgot-password | 0 | Skip | Pending automation harness
Reset password (valid OTP) | auth-service | POST /api/auth/confirm-otp-reset-password | 0 | Skip | Pending automation harness
Reset password (invalid/expired OTP) | auth-service | POST /api/auth/confirm-otp-reset-password | 0 | Skip | Pending automation harness
Browse exams list | exam-service | GET /api/public/exam/getall | 10 | Automated | Unit tests: ExamService.UnitTests/BrowseExamsListTests
View exam detail (by slug/id) | exam-service | GET /api/public/exam/getby/{slug} | 10 | Automated | Unit tests: ExamService.UnitTests/ExamDetailTests
Search/filter exams (if available) | exam-service | GET /api/public/exam/getall | 10 | Automated | Unit tests: ExamService.UnitTests/SearchExamsTests
Browse courses list | course-service | GET /api/course/getpublishedcourse | 10 | Automated | Unit tests: CourseService.UnitTests/BrowseCoursesListTests
View course detail (by slug/id) | course-service | GET /api/course/getbyslug/{slug} | 10 | Automated | Unit tests: CourseService.UnitTests/CourseDetailTests
Browse vocabulary decks list | vocabulary-service | GET /api/decks/ | 0 | Skip | Pending automation harness
View deck detail (full content) | vocabulary-service | GET /api/decks/{slug} | 0 | Skip | Pending automation harness
Subscribe to a deck (success) | vocabulary-service | POST /api/users/{userId}/subscribe/{deckId} | 0 | Skip | Pending automation harness
Subscribe to a deck (unauthenticated) | vocabulary-service | POST /api/users/{userId}/subscribe/{deckId} | 0 | Skip | Pending automation harness
View my subscribed decks | vocabulary-service | GET /api/users/{userId}/subscribe | 0 | Skip | Pending automation harness
Review flashcards (record outcome) | vocabulary-service | POST /api/users/{userId}/flashcard/{cardId}/review | 0 | Skip | Pending automation harness
Enroll in a course (success) | course-service | GET /api/course/{courseId}/{userId}:enroll | 0 | Skip | Pending automation harness
Enroll in a course (unauthenticated) | course-service | GET /api/course/{courseId}/{userId}:enroll | 0 | Skip | Pending automation harness
View my enrollments | course-service | POST /api/lesson/{userId}/progress | 0 | Skip | Pending automation harness
Start exam attempt (success) | attempt-service | POST /api/attempt/attempts:start | 0 | Skip | Pending automation harness
Save answers during attempt (as implemented) | attempt-service | POST /api/attempt/autosave/{attemptId} | 0 | Skip | Pending automation harness
Submit attempt (manual submit) | attempt-service | POST /api/attempt/submit/{attemptId} | 0 | Skip | Pending automation harness
Submit when time expired (returns “Expired”) | attempt-service | POST /api/attempt/submit/{attemptId} | 0 | Skip | Pending automation harness
View attempt history (list) | attempt-service | GET /api/attempt/getlistattempt | 0 | Skip | Pending automation harness
View attempt result detail (if available) | attempt-service | GET /api/attempt/getresult/{attemptId} | 0 | Skip | Pending automation harness
Admin manage exam catalog (create/update) | exam-service | POST /api/admin/exam/addexam | 0 | Skip | Pending automation harness
Admin edit exam structure | exam-service | /api/admin/section | 0 | Skip | Pending automation harness
Admin manage courses & lessons | course-service | /api/admin/course | 0 | Skip | Pending automation harness
Admin manage decks & cards | vocabulary-service | /api/users deck/card routes | 0 | Skip | Pending automation harness
Admin manage speaking exams | speaking-service | /api/admin/speaking | 0 | Skip | Pending automation harness
Admin manage writing exams | writing-service | /api/admin/writing | 0 | Skip | Pending automation harness
Admin monitor attempts (list only) | attempt-service | GET /api/admin/attempt | 0 | Skip | Pending automation harness
Internal fetch delivery snapshot (success) | exam-service | GET /api/internal/exams/{id}/delivery | 0 | Skip | Pending automation harness
Internal fetch delivery snapshot (general error) | exam-service | GET /api/internal/exams/{id}/delivery | 0 | Skip | Pending automation harness
