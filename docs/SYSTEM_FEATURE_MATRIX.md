# System Feature Matrix - Langfens IELTS Platform

## Tổng quan Hệ thống

| Microservice | Mô tả | Số Endpoints |
|:---|:---|:---:|
| auth-service | Xác thực, đăng nhập, quản lý user | 12 |
| attempt-service | Quản lý bài làm, analytics, bookmarks, notes, study plan | 25+ |
| exam-service | Quản lý đề thi (CRUD), question bank | 18 |
| gamification-service | XP, achievements, leaderboard, notifications | 11 |
| writing-service | Đề writing, chấm bài AI | 10 |
| speaking-service | Đề speaking, transcript, chấm bài AI | 12 |
| vocabulary-service | Flashcard decks, AI vocabulary enrichment | 17 |
| dictionary-service | Từ điển tra cứu, Elasticsearch | 5 |
| email-service | Gửi email xác thực | 1+ |
| chatbot-service | AI chatbot hỗ trợ học IELTS | 2 |
| course-service | Quản lý khóa học, bài học | 9 |

---

## Auth Service

| Endpoint | Method | Chức năng | Mô tả chi tiết luồng xử lý | Auth |
|:---|:---:|:---|:---|:---:|
| `POST /api/auth/register` | POST | Đăng ký tài khoản | 1. Validate email/password<br>2. Hash password<br>3. Tạo user trong DB<br>4. Gửi OTP email xác thực | Public |
| `POST /api/auth/login` | POST | Đăng nhập | 1. Validate credentials<br>2. Check password hash<br>3. Generate JWT Access + Refresh token<br>4. Set HttpOnly cookies | Public |
| `POST /api/auth/login-google` | POST | Đăng nhập Google | 1. Verify Google ID token<br>2. Tạo/update user từ Google profile<br>3. Generate JWT tokens | Public |
| `POST /api/auth/refresh` | POST | Refresh token | 1. Validate refresh token từ cookie<br>2. Generate new access token | Public |
| `POST /api/auth/logout` | POST | Đăng xuất | 1. Clear auth cookies<br>2. Invalidate refresh token | User |
| `GET /api/auth/me` | GET | Lấy thông tin user hiện tại | 1. Đọc JWT từ cookie<br>2. Trả về user info | User |
| `POST /api/auth/email-confirm` | POST | Xác thực email OTP | 1. Validate OTP code<br>2. Mark email as verified | Public |
| `POST /api/auth/resend-otp` | POST | Gửi lại OTP email | 1. Generate new OTP<br>2. Gửi email OTP mới | Public |
| `POST /api/auth/forgot-password` | POST | Quên mật khẩu | 1. Generate reset token<br>2. Gửi email reset password | Public |
| `POST /api/auth/resend-forgot-password` | POST | Gửi lại email reset | 1. Resend reset password email | Public |
| `POST /api/auth/confirm-forgot-password` | POST | Xác nhận reset password | 1. Validate reset token<br>2. Update password hash | Public |
| `GET /api/auth/users` | GET | Lấy danh sách users | 1. Query all users (Admin only) | Admin |

---

## Attempt Service

### Attempt Management

| Endpoint | Method | Chức năng | Mô tả chi tiết luồng xử lý | Auth |
|:---|:---:|:---|:---|:---:|
| `POST /api/attempt/attempts:start` | POST | Bắt đầu làm bài | 1. Validate exam exists<br>2. Tạo attempt record<br>3. Trả về paper JSON + attemptId | AttemptStart |
| `POST /api/attempt/attempts:status` | POST | Kiểm tra attempt trước đó | 1. Tìm attempt chưa hoàn thành<br>2. Trả về status | AttemptStart |
| `GET /api/attempt/{attemptId}` | GET | Lấy chi tiết attempt | 1. Validate ownership<br>2. Trả về attempt data + paper JSON | AttemptReadOwn |
| `POST /api/attempt/autosave/{attemptId}` | POST | Tự động lưu đáp án | 1. Validate ownership<br>2. Update answers JSON<br>3. Update timestamp | AttemptReadOwn |
| `POST /api/attempt/submit/{attemptId}` | POST | Nộp bài | 1. Validate ownership<br>2. Chấm điểm từng câu<br>3. Tính điểm tổng<br>4. Publish event `AttemptSubmitted`<br>5. Cộng XP qua RabbitMQ | AttemptSubmit |
| `GET /api/attempt/getresult/{attemptId}` | GET | Lấy kết quả bài làm | 1. Trả về result + detailed answers + explanations | AttemptReadOwn |
| `GET /api/attempt/getlistattempt` | GET | Lấy danh sách attempt của user | 1. Query attempts by userId<br>2. Pagination | AttemptReadOwn |
| `GET /api/attempt/placement` | GET | Lấy placement test gần nhất | 1. Query latest placement result | AttemptReadOwn |
| `GET /api/attempt/placement/status` | GET | Kiểm tra trạng thái placement | 1. Check 4 skills completed status | AttemptReadOwn |
| `GET /api/admin/attempt/` | GET | Admin: Lấy tất cả attempts | 1. Query all attempts with filters | AttemptReadAny |

### Analytics

| Endpoint | Method | Chức năng | Mô tả chi tiết luồng xử lý | Auth |
|:---|:---:|:---|:---|:---:|
| `GET /api/analytics/summary` | GET | Tổng quan học tập | 1. Tính tổng attempt, avg score<br>2. Study time, streak | User |
| `GET /api/analytics/score-trend` | GET | Xu hướng điểm số | 1. Query attempts theo ngày<br>2. Group by date, calc avg | User |
| `GET /api/analytics/strengths` | GET | Điểm mạnh/yếu | 1. Analyze answers by question type<br>2. Calc accuracy per type | User |
| `GET /api/analytics/recent-activity` | GET | Hoạt động gần đây | 1. Query recent attempts + submissions | User |
| `GET /api/analytics/errors` | GET | Câu trả lời sai | 1. Query wrong answers<br>2. Filter by skill/type<br>3. Pagination | User |
| `GET /api/analytics/predicted-band` | GET | Dự đoán band IELTS | 1. Analyze placement results<br>2. Calculate predicted band + confidence | User |
| `GET /api/analytics/ai-insights` | GET | AI phân tích học tập | 1. Gather user data<br>2. Call Gemini AI<br>3. Generate personalized insights | User |
| `GET /api/analytics/recommendations` | GET | Đề xuất bài tập | 1. Analyze weaknesses<br>2. Recommend exams matching weak areas | User |

### Bookmarks

| Endpoint | Method | Chức năng | Mô tả chi tiết luồng xử lý | Auth |
|:---|:---:|:---|:---|:---:|
| `POST /api/bookmarks/` | POST | Tạo/Update bookmark | 1. Upsert bookmark record<br>2. Save note if provided | User |
| `GET /api/bookmarks/` | GET | Lấy danh sách bookmark | 1. Query by userId<br>2. Filter by skill/type/hasNote<br>3. Pagination | User |
| `DELETE /api/bookmarks/{questionId}` | DELETE | Xóa bookmark | 1. Validate ownership<br>2. Delete record | User |
| `GET /api/bookmarks/check/{questionId}` | GET | Kiểm tra đã bookmark chưa | 1. Query exists | User |

### Notes

| Endpoint | Method | Chức năng | Mô tả chi tiết luồng xử lý | Auth |
|:---|:---:|:---|:---|:---:|
| `POST /api/notes/` | POST | Tạo ghi chú | 1. Create note record<br>2. Link to attempt if provided | User |
| `GET /api/notes/` | GET | Lấy danh sách ghi chú | 1. Query by userId<br>2. Filter by attemptId<br>3. Pagination | User |
| `GET /api/notes/{noteId}` | GET | Lấy chi tiết ghi chú | 1. Validate ownership<br>2. Return note | User |
| `PUT /api/notes/{noteId}` | PUT | Cập nhật ghi chú | 1. Validate ownership<br>2. Update content | User |
| `DELETE /api/notes/{noteId}` | DELETE | Xóa ghi chú | 1. Validate ownership<br>2. Delete | User |

### Study Plan

| Endpoint | Method | Chức năng | Mô tả chi tiết luồng xử lý | Auth |
|:---|:---:|:---|:---|:---:|
| `POST /api/study-plan/goals` | POST | Tạo mục tiêu học tập | 1. Create/Update goal<br>2. Set target band, date, focus skills | User |
| `GET /api/study-plan/goals/active` | GET | Lấy mục tiêu đang hoạt động | 1. Query active goal | User |
| `GET /api/study-plan/progress` | GET | Lấy tiến độ học tập | 1. Calculate progress %<br>2. Compare current vs target | User |
| `DELETE /api/study-plan/goals/{goalId}` | DELETE | Xóa mục tiêu | 1. Validate ownership<br>2. Delete goal | User |

---

## Exam Service

### Public Endpoints

| Endpoint | Method | Chức năng | Mô tả chi tiết luồng xử lý | Auth |
|:---|:---:|:---|:---|:---:|
| `GET /api/public/exam/getall` | GET | Lấy danh sách đề thi | 1. Query published exams<br>2. Filter by skill | Public |
| `GET /api/public/exam/getby/{slug}` | GET | Lấy đề theo slug | 1. Query by slug<br>2. Return exam info | Public |

### Admin Endpoints - Exam

| Endpoint | Method | Chức năng | Mô tả chi tiết luồng xử lý | Auth |
|:---|:---:|:---|:---|:---:|
| `POST /api/admin/exam/addexam` | POST | Thêm đề thi mới | 1. Validate input<br>2. Create exam record | Admin |
| `GET /api/admin/exam/all` | GET | Lấy tất cả đề thi | 1. Query all exams | Admin |
| `PUT /api/admin/exam/update/{id}` | PUT | Cập nhật đề thi | 1. Validate id<br>2. Update exam | Admin |
| `DELETE /api/admin/exam/delete/{id}` | DELETE | Xóa đề thi | 1. Delete exam + related data | Admin |

### Admin Endpoints - Section

| Endpoint | Method | Chức năng | Mô tả chi tiết luồng xử lý | Auth |
|:---|:---:|:---|:---|:---:|
| `POST /api/admin/section/add` | POST | Thêm section | 1. Create section for exam | ExamManage |
| `PUT /api/admin/section/update/{id}` | PUT | Cập nhật section | 1. Update section data | ExamManage |
| `DELETE /api/admin/section/delete/{id}` | DELETE | Xóa section | 1. Delete section + questions | ExamManage |
| `GET /api/admin/section/by-exam/{examId}` | GET | Lấy sections theo exam | 1. Query sections by examId | ExamManage |

### Admin Endpoints - Question

| Endpoint | Method | Chức năng | Mô tả chi tiết luồng xử lý | Auth |
|:---|:---:|:---|:---|:---:|
| `POST /api/admin/question/add` | POST | Thêm câu hỏi | 1. Create question for section | Admin |
| `PUT /api/admin/question/update/{id}` | PUT | Cập nhật câu hỏi | 1. Update question data | Admin |
| `DELETE /api/admin/question/delete/{id}` | DELETE | Xóa câu hỏi | 1. Delete question + options | Admin |
| `GET /api/admin/question/by-section/{sectionId}` | GET | Lấy questions theo section | 1. Query questions by sectionId | Admin |

### Admin Endpoints - Option

| Endpoint | Method | Chức năng | Mô tả chi tiết luồng xử lý | Auth |
|:---|:---:|:---|:---|:---:|
| `POST /api/admin/option/add` | POST | Thêm đáp án | 1. Create option for question | Admin |
| `PUT /api/admin/option/update/{id}` | PUT | Cập nhật đáp án | 1. Update option data | Admin |
| `DELETE /api/admin/option/delete/{id}` | DELETE | Xóa đáp án | 1. Delete option | Admin |
| `GET /api/admin/option/by-question/{questionId}` | GET | Lấy options theo question | 1. Query options by questionId | Admin |

### Question Bank

| Endpoint | Method | Chức năng | Mô tả chi tiết luồng xử lý | Auth |
|:---|:---:|:---|:---|:---:|
| `GET /api/question-bank/types` | GET | Lấy danh sách loại câu hỏi | 1. Query distinct question types<br>2. Count per type | Public |
| `GET /api/question-bank/questions` | GET | Lấy câu hỏi theo loại | 1. Filter by type/skill<br>2. Pagination | Public |
| `GET /api/question-bank/exams` | GET | Lấy đề thi theo loại câu hỏi | 1. Filter exams by question type | Public |

### Internal Endpoint

| Endpoint | Method | Chức năng | Mô tả chi tiết luồng xử lý | Auth |
|:---|:---:|:---|:---|:---:|
| `GET /api/internal/exams/{id}/delivery` | GET | Lấy exam để chấm (internal) | 1. Return full exam data for grading | Internal |

---

## Gamification Service

### XP & Achievements

| Endpoint | Method | Chức năng | Mô tả chi tiết luồng xử lý | Auth |
|:---|:---:|:---|:---|:---:|
| `GET /api/gamification/me` | GET | Lấy stats cá nhân | 1. Return XP, level, streak, rank | User |
| `GET /api/gamification/achievements` | GET | Lấy danh sách achievements | 1. Return all achievements<br>2. Mark earned ones | User |
| `GET /api/gamification/leaderboard` | GET | Bảng xếp hạng | 1. Query top users by XP | Public |
| `GET /api/gamification/history` | GET | Lịch sử XP | 1. Query XP transactions | User |
| `POST /api/gamification/daily-checkin` | POST | Điểm danh hàng ngày | 1. Check already checked in<br>2. Award XP<br>3. Update streak | User |

### Notifications

| Endpoint | Method | Chức năng | Mô tả chi tiết luồng xử lý | Auth |
|:---|:---:|:---|:---|:---:|
| `GET /api/notifications` | GET | Lấy danh sách thông báo | 1. Query by userId<br>2. Pagination | User |
| `GET /api/notifications/unread-count` | GET | Đếm thông báo chưa đọc | 1. Count unread | User |
| `PATCH /api/notifications/{id}/read` | PATCH | Đánh dấu đã đọc | 1. Update isRead = true | User |
| `PATCH /api/notifications/read-all` | PATCH | Đánh dấu tất cả đã đọc | 1. Update all unread | User |
| `GET /api/notifications/settings` | GET | Lấy cài đặt thông báo | 1. Return notification preferences | User |
| `PUT /api/notifications/settings` | PUT | Cập nhật cài đặt thông báo | 1. Update preferences | User |

---

## Writing Service

### User Endpoints

| Endpoint | Method | Chức năng | Mô tả chi tiết luồng xử lý | Auth |
|:---|:---:|:---|:---|:---:|
| `POST /api/writing/grade` | POST | Nộp bài viết | 1. Validate input<br>2. Call Gemini AI grading<br>3. Return band scores + feedback | User |
| `GET /api/writing/exams` | GET | Lấy danh sách đề writing | 1. Query published writing exams | Public |
| `POST /api/writing/start/{examId}` | POST | Bắt đầu làm bài writing | 1. Create submission record | User |
| `GET /api/writing/exams/{examId}` | GET | Lấy chi tiết đề writing | 1. Return exam data | Public |
| `GET /api/writing/history` | GET | Lịch sử bài viết | 1. Query user's submissions | User |
| `GET /api/writing/history/{submissionId}` | GET | Chi tiết bài viết | 1. Return submission + grades | User |

### Admin Endpoints

| Endpoint | Method | Chức năng | Mô tả chi tiết luồng xử lý | Auth |
|:---|:---:|:---|:---|:---:|
| `GET /api/admin/writing/exams` | GET | Lấy tất cả đề writing | 1. Query all exams | Admin |
| `POST /api/admin/writing/create` | POST | Tạo đề writing | 1. Create writing exam | Admin |
| `PUT /api/admin/writing/exams/{examId}` | PUT | Cập nhật đề writing | 1. Update exam | Admin |
| `DELETE /api/admin/writing/exams/{examId}` | DELETE | Xóa đề writing | 1. Delete exam | Admin |

---

## Speaking Service

### User Endpoints

| Endpoint | Method | Chức năng | Mô tả chi tiết luồng xử lý | Auth |
|:---|:---:|:---|:---|:---:|
| `POST /api/speaking/transcript` | POST | Chuyển audio thành text | 1. Upload audio file<br>2. Call Whisper API<br>3. Return transcript | Public |
| `POST /api/speaking/grade` | POST | Nộp bài speaking | 1. Upload audio<br>2. Transcript với Whisper<br>3. Grade với Gemini AI<br>4. Return scores + feedback | User |
| `GET /api/speaking/exams` | GET | Lấy danh sách đề speaking | 1. Query published exams | Public |
| `GET /api/speaking/exams/{examId}` | GET | Lấy chi tiết đề speaking | 1. Return exam data | Public |
| `POST /api/speaking/start/{examId}` | POST | Bắt đầu làm bài speaking | 1. Create submission record | User |
| `GET /api/speaking/history` | GET | Lịch sử bài nói | 1. Query user's submissions | User |
| `GET /api/speaking/history/{submissionId}` | GET | Chi tiết bài nói | 1. Return submission + grades | User |

### WebSocket

| Endpoint | Method | Chức năng | Mô tả chi tiết luồng xử lý | Auth |
|:---|:---:|:---|:---|:---:|
| `WS /ws/speaking/transcript` | WS | Real-time transcript | 1. Stream audio chunks<br>2. Real-time Whisper processing | Public |

### Upload

| Endpoint | Method | Chức năng | Mô tả chi tiết luồng xử lý | Auth |
|:---|:---:|:---|:---|:---:|
| `POST /api/upload/audio` | POST | Upload audio file | 1. Upload to Cloudinary<br>2. Return URL | Public |

### Admin Endpoints

| Endpoint | Method | Chức năng | Mô tả chi tiết luồng xử lý | Auth |
|:---|:---:|:---|:---|:---:|
| `GET /api/admin/speaking/exams` | GET | Lấy tất cả đề speaking | 1. Query all exams | Admin |
| `POST /api/admin/speaking/create` | POST | Tạo đề speaking | 1. Create exam | Admin |
| `PUT /api/admin/speaking/exams/{examId}` | PUT | Cập nhật đề speaking | 1. Update exam | Admin |
| `DELETE /api/admin/speaking/exams/{examId}` | DELETE | Xóa đề speaking | 1. Delete exam | Admin |

---

## Vocabulary Service

### Public Endpoints

| Endpoint | Method | Chức năng | Mô tả chi tiết luồng xử lý | Auth |
|:---|:---:|:---|:---|:---:|
| `GET /api/decks/` | GET | Lấy danh sách decks | 1. Query published decks | Public |
| `GET /api/decks/{slug}` | GET | Lấy deck theo slug | 1. Query by slug | Public |
| `GET /api/decks/slug:{slug}/cards` | GET | Lấy cards theo slug | 1. Query cards by deck slug | Public |
| `GET /api/decks/deck:{deckId}/cards` | GET | Lấy cards theo deckId | 1. Query cards by deckId | Public |

### AI Endpoints

| Endpoint | Method | Chức năng | Mô tả chi tiết luồng xử lý | Auth |
|:---|:---:|:---|:---|:---:|
| `GET /api/vocabulary/enrich` | GET | AI làm giàu từ vựng | 1. Call Gemini AI<br>2. Return definition, IPA, example, synonyms, CEFR level | Public |
| `POST /api/vocabulary/extract` | POST | AI trích xuất từ vựng | 1. Analyze passage text<br>2. Extract important IELTS vocabulary<br>3. Return word list with details | Public |

### User Endpoints

| Endpoint | Method | Chức năng | Mô tả chi tiết luồng xử lý | Auth |
|:---|:---:|:---|:---|:---:|
| `POST /api/users/{userId}/subscribe/{deckId}` | POST | Đăng ký deck | 1. Create subscription | User |
| `GET /api/users/{userId}/subscribe` | GET | Lấy decks đã đăng ký | 1. Query subscriptions | User |
| `GET /api/users/{userId}/own` | GET | Lấy decks của user | 1. Query user's decks | User |
| `GET /api/users/{userId}/flashcard/due` | GET | Lấy cards cần học | 1. Query due cards (SRS) | User |
| `POST /api/users/{userId}/flashcard/{cardId}/review` | POST | Review flashcard | 1. Update SRS interval<br>2. Schedule next review | User |
| `GET /api/users/{userId}/flashcard/progress` | GET | Tiến độ flashcard | 1. Return learning stats | User |
| `POST /api/users/deck` | POST | Tạo deck mới | 1. Create user deck | User |
| `PUT /api/users/deck/{deckId}` | PUT | Cập nhật deck | 1. Update deck | User |
| `DELETE /api/users/deck/{deckId}` | DELETE | Xóa deck | 1. Delete deck + cards | User |
| `POST /api/users/deck/{deckId}/card` | POST | Thêm card vào deck | 1. Create card | User |
| `PUT /api/users/deck/card/{cardId}` | PUT | Cập nhật card | 1. Update card | User |
| `DELETE /api/users/deck/card/{cardId}` | DELETE | Xóa card | 1. Delete card | User |
| `DELETE /api/users/deck/{deckId}/publish` | DELETE | Publish deck | 1. Set deck as published | User |

---

## Dictionary Service

| Endpoint | Method | Chức năng | Mô tả chi tiết luồng xử lý | Auth |
|:---|:---:|:---|:---|:---:|
| `GET /api/dictionary/suggest` | GET | Gợi ý từ | 1. Elasticsearch autocomplete<br>2. Return word suggestions | Public |
| `GET /api/dictionary/lookup` | GET | Tra từ nhanh | 1. Search exact word<br>2. Return full definition | Public |
| `GET /api/dictionary/details/{id}` | GET | Chi tiết từ theo ID | 1. Get word by Elasticsearch ID | Public |
| `POST /api/dictionary/import` | POST | Import từ điển | 1. Parse JSONL file<br>2. Bulk insert to PostgreSQL | Admin |
| `POST /api/dictionary/reindex` | POST | Reindex Elasticsearch | 1. Bulk reindex from DB | Admin |

---

## Email Service

| Endpoint | Method | Chức năng | Mô tả chi tiết luồng xử lý | Auth |
|:---|:---:|:---|:---|:---:|
| `GET /api/mail/verify-email` | GET | Xác thực email link | 1. Validate token<br>2. Mark email verified | Public |

### Background: RabbitMQ Consumer

| Event | Chức năng | Mô tả chi tiết luồng xử lý |
|:---|:---|:---|
| `UserRegistered` | Gửi email xác thực | 1. Consume event<br>2. Generate OTP<br>3. Send verification email |
| `ForgotPassword` | Gửi email reset password | 1. Consume event<br>2. Send reset link email |

---

## Chatbot Service

| Endpoint | Method | Chức năng | Mô tả chi tiết luồng xử lý | Auth |
|:---|:---:|:---|:---|:---:|
| `POST /api/ielts/chat` | POST | Chat với AI tutor | 1. Send message to Gemini<br>2. Return AI response | Public |
| `POST /api/ielts/chat-stream` | POST | Chat stream | 1. Stream response from Gemini | Public |

---

## Course Service

| Endpoint | Method | Chức năng | Mô tả chi tiết luồng xử lý | Auth |
|:---|:---:|:---|:---|:---:|
| `GET /api/getpublishedcourse/` | GET | Lấy danh sách khóa học | 1. Query published courses | Public |
| `GET /api/getbyslug/{slug}` | GET | Lấy khóa học theo slug | 1. Query by slug | Public |
| `GET /api/getlessonbyslug/{slug}` | GET | Lấy bài học theo slug | 1. Query lesson by slug | Public |
| `GET /api/lesson/{lessonId}` | GET | Lấy bài học theo ID | 1. Query by lessonId | Public |
| `GET /api/{courseId}/{userId}:enroll` | GET | Đăng ký khóa học | 1. Create enrollment | CourseEnroll |
| `POST /api/{userId}/{lessonId}:complete` | POST | Hoàn thành bài học | 1. Mark lesson completed<br>2. Award XP | CourseComplete |
| `POST /api/{userId}/progress` | POST | Lấy tiến độ học | 1. Return course progress | CourseRead |
| `POST /api/admin/create` | POST | Tạo khóa học | 1. Create course | CourseManage |
| `PUT /api/admin/update/{courseId}` | PUT | Cập nhật khóa học | 1. Update course | CourseManage |
| `DELETE /api/admin/delete/{courseId}` | DELETE | Xóa khóa học | 1. Delete course | CourseManage |
| `POST /api/admin/{courseId}/lesson/create` | POST | Thêm bài học | 1. Create lesson | CourseManage |

---

## Background Services & Integrations

### RabbitMQ Event Consumers

| Service | Event | Chức năng | Mô tả |
|:---|:---|:---|:---|
| gamification-service | `AttemptSubmitted` | Cộng XP khi nộp bài | Award XP based on score |
| gamification-service | `LessonCompleted` | Cộng XP khi học xong bài | Award lesson XP |
| email-service | `UserRegistered` | Gửi email xác thực | Send OTP email |
| email-service | `ForgotPassword` | Gửi email reset | Send reset password email |

### AI Integrations (Gemini)

| Service | Feature | Mô tả |
|:---|:---|:---|
| writing-service | Writing Grading | Chấm bài viết với band score + feedback |
| speaking-service | Speaking Grading | Chấm bài nói với band score + feedback |
| attempt-service | AI Insights | Phân tích học tập cá nhân hóa |
| vocabulary-service | Word Enrichment | Làm giàu thông tin từ vựng |
| vocabulary-service | Passage Extraction | Trích xuất từ vựng từ bài đọc |
| chatbot-service | IELTS Tutor | Chat hỗ trợ học IELTS |

### External Services

| Service | Integration | Mô tả |
|:---|:---|:---|
| speaking-service | OpenAI Whisper | Speech-to-text transcription |
| speaking-service | Cloudinary | Audio file storage |
| dictionary-service | Elasticsearch | Full-text search |
