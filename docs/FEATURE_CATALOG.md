# 📚 Langfens IELTS Platform - Feature Catalog

> **Comprehensive list of all system features organized by functional domain**

---

## 1. 🔐 Authentication & User Management

### 1.1 Account Registration
- **Email Registration**: Đăng ký bằng email + password
- **Password Hashing**: Mã hóa password an toàn
- **Email Verification**: Xác thực email qua OTP 6 số
- **Resend OTP**: Gửi lại mã OTP nếu hết hạn

### 1.2 Login & Session
- **Email/Password Login**: Đăng nhập truyền thống
- **Google OAuth**: Đăng nhập 1-click với Google
- **JWT Authentication**: Access token + Refresh token
- **HttpOnly Cookies**: Bảo mật session trong cookie
- **Token Refresh**: Tự động refresh khi access token hết hạn
- **Logout**: Xóa session, invalidate tokens

### 1.3 Password Recovery
- **Forgot Password**: Gửi email reset password
- **Reset Link**: Link reset có thời hạn
- **Password Confirm**: Đặt mật khẩu mới

### 1.4 User Profile
- **View Profile**: Xem thông tin cá nhân
- **Get Current User**: Lấy user từ JWT token

---

## 2. 📖 Reading & Listening Practice

### 2.1 Exam Discovery
- **Browse Exams**: Danh sách đề thi Reading/Listening
- **Filter by Skill**: Lọc theo Reading, Listening
- **Exam Details**: Thông tin đề (số câu, thời gian, độ khó)
- **Exam by Slug**: Truy cập đề theo URL slug

### 2.2 Question Bank
- **Browse by Type**: Lọc câu hỏi theo loại
  - Multiple Choice (Single/Multiple)
  - True/False/Not Given
  - Yes/No/Not Given
  - Matching Heading
  - Matching Information
  - Matching Features
  - Summary Completion
  - Sentence Completion
  - Table/Flow Chart Completion
  - Diagram Label
- **Type Statistics**: Số lượng câu hỏi mỗi loại
- **Exams by Type**: Tìm đề theo loại câu hỏi

### 2.3 Taking the Test
- **Start Attempt**: Bắt đầu làm bài, tạo attempt record
- **Resume Attempt**: Tiếp tục bài làm dở
- **Check Status**: Kiểm tra attempt chưa hoàn thành
- **Split-View Layout**: Passage bên trái, Questions bên phải
- **Resizable Panels**: Kéo thay đổi tỷ lệ panel
- **Timer**: Đồng hồ đếm ngược
- **Autosave**: Tự động lưu đáp án định kỳ
- **Passage Navigation**: Chuyển giữa các passages
- **Question Navigation**: Jump đến câu hỏi cụ thể
- **Highlighting**: Bôi vàng text trong passage
- **Zoom Controls**: Phóng to/thu nhỏ font passage
- **Paragraph Labels**: Nhãn [A], [B], [C] cho paragraphs

### 2.4 Submission & Grading
- **Submit Attempt**: Nộp bài làm
- **Auto-Grading**: Chấm điểm tự động Reading/Listening
- **Band Score Calculation**: Tính band từ raw score
- **XP Award**: Cộng XP sau khi nộp bài

### 2.5 Result Review
- **View Result**: Xem kết quả tổng quan
- **Answer Review**: Xem chi tiết từng câu đúng/sai
- **Correct Answers**: Hiển thị đáp án đúng
- **Explanations**: Giải thích chi tiết (AI generated)
- **Review Mode**: Xem lại bài làm ở chế độ readonly

---

## 3. ✍️ Writing Practice

### 3.1 Writing Exams
- **Browse Writing Exams**: Danh sách đề Writing
- **Task 1**: Academic (Describe chart/graph/process)
- **Task 2**: Essay questions
- **Exam Details**: Prompt, requirements, word limit

### 3.2 Taking Writing Test
- **Start Writing Exam**: Bắt đầu làm bài writing
- **Text Editor**: Vùng soạn thảo bài viết
- **Word Counter**: Đếm số từ real-time
- **Timer**: Đồng hồ cho mỗi task

### 3.3 AI Grading
- **Submit Writing**: Nộp bài viết
- **Gemini AI Grading**: Chấm bài bằng AI
- **4 Criteria Scores**:
  - Task Response / Task Achievement
  - Coherence & Cohesion
  - Lexical Resource
  - Grammatical Range & Accuracy
- **Overall Band**: Điểm tổng kết
- **Detailed Feedback**: Nhận xét chi tiết từng phần
- **Improvement Suggestions**: Gợi ý cải thiện

### 3.4 Writing History
- **Submission History**: Danh sách bài viết đã nộp
- **View Past Submission**: Xem lại bài viết + feedback

---

## 4. 🎤 Speaking Practice

### 4.1 Speaking Exams
- **Browse Speaking Exams**: Danh sách đề Speaking
- **Part 1**: Introduction & interview questions
- **Part 2**: Cue card / long turn
- **Part 3**: Discussion questions
- **Exam Details**: Questions, preparation time, speaking time

### 4.2 Taking Speaking Test
- **Start Speaking Exam**: Bắt đầu làm bài speaking
- **Preparation Timer**: Đồng hồ chuẩn bị (Part 2)
- **Audio Recorder**: Ghi âm câu trả lời
- **Speaking Timer**: Đồng hồ nói (1-2 minutes)
- **Recording Playback**: Nghe lại bản ghi

### 4.3 Speech-to-Text
- **Whisper Transcription**: Chuyển audio thành text
- **Real-time Transcript**: WebSocket streaming transcript
- **Audio Upload**: Upload file audio lên Cloudinary

### 4.4 AI Grading
- **Submit Speaking**: Nộp bài nói
- **Gemini AI Grading**: Chấm bài bằng AI
- **4 Criteria Scores**:
  - Fluency & Coherence
  - Lexical Resource
  - Grammatical Range & Accuracy
  - Pronunciation
- **Overall Band**: Điểm tổng kết
- **Detailed Feedback**: Nhận xét chi tiết
- **Transcript Review**: Xem bản transcript

### 4.5 Speaking History
- **Submission History**: Danh sách bài nói đã nộp
- **View Past Submission**: Xem lại transcript + feedback

---

## 5. 📊 Analytics & Progress Tracking

### 5.1 Dashboard Summary
- **Total Attempts**: Tổng số bài đã làm
- **Average Score**: Điểm trung bình
- **Study Time**: Tổng thời gian học
- **Current Streak**: Chuỗi ngày học liên tục
- **Tests This Week**: Số bài tuần này

### 5.2 Score Trends
- **Score Chart**: Biểu đồ điểm theo thời gian
- **Daily/Weekly View**: Xem theo ngày hoặc tuần
- **Skill Breakdown**: Điểm từng skill

### 5.3 Strengths & Weaknesses
- **Question Type Analysis**: Phân tích theo loại câu hỏi
- **Accuracy Rate**: Tỉ lệ đúng mỗi loại
- **Strength Tags**: Nhãn điểm mạnh (xanh)
- **Weakness Tags**: Nhãn điểm yếu (đỏ)

### 5.4 AI-Powered Insights
- **Predicted Band Score**: Dự đoán band từ placement test
- **Confidence Level**: Độ tin cậy của dự đoán
- **AI Insights**: Phân tích cá nhân hóa từ Gemini
- **Personalized Recommendations**: Đề xuất bài tập phù hợp

### 5.5 Error Review
- **Wrong Answers List**: Danh sách câu trả lời sai
- **Filter by Skill/Type**: Lọc theo kỹ năng, loại câu
- **Explanation View**: Xem giải thích chi tiết
- **Quick Review**: Ôn tập câu sai

### 5.6 Recent Activity
- **Activity Feed**: Hoạt động gần đây
- **Attempt History**: Lịch sử bài làm

---

## 6. 🎯 Study Plan & Goals

### 6.1 Goal Setting
- **Create Goal**: Tạo mục tiêu học tập
- **Target Band Score**: Đặt điểm mục tiêu (5.0-9.0)
- **Target Date**: Ngày deadline
- **Focus Skills**: Chọn kỹ năng tập trung
- **Daily Commitment**: Giờ học mỗi ngày

### 6.2 Progress Tracking
- **View Active Goal**: Xem mục tiêu đang hoạt động
- **Progress Percentage**: Tiến độ so với mục tiêu
- **Score Progress Bar**: Thanh tiến độ điểm
- **Time Progress Bar**: Thanh tiến độ thời gian
- **Status Badge**: Ahead / On Track / Behind

### 6.3 Goal Management
- **Delete Goal**: Xóa mục tiêu
- **Create New Goal**: Tạo mục tiêu mới (thay thế cũ)

---

## 7. 📑 Bookmarks & Notes

### 7.1 Question Bookmarks
- **Bookmark Question**: Lưu câu hỏi quan trọng
- **View Bookmarks**: Danh sách câu đã bookmark
- **Filter Bookmarks**: Lọc theo skill, type, hasNote
- **Add Note to Bookmark**: Ghi chú cho bookmark
- **Remove Bookmark**: Xóa bookmark
- **Check Bookmark Status**: Kiểm tra đã bookmark chưa

### 7.2 Personal Notes
- **Create Note**: Tạo ghi chú mới
- **Link to Attempt**: Liên kết note với bài làm
- **View Notes**: Danh sách ghi chú
- **Edit Note**: Chỉnh sửa ghi chú
- **Delete Note**: Xóa ghi chú

---

## 8. 🃏 Vocabulary & Flashcards

### 8.1 Deck Discovery
- **Browse Public Decks**: Danh sách bộ từ vựng công khai
- **Deck by Slug**: Truy cập deck theo URL
- **View Cards**: Xem danh sách cards trong deck
- **Deck Info**: Số cards, author, level

### 8.2 Learning with Flashcards
- **Subscribe to Deck**: Đăng ký học deck
- **View Subscribed Decks**: Danh sách deck đã đăng ký
- **Due Cards**: Cards cần học hôm nay (SRS)
- **Study Session**: Phiên học flashcard
- **Review Card**: Đánh giá (Again, Hard, Good, Easy)
- **Spaced Repetition**: Tự động schedule lần review tiếp

### 8.3 Progress Tracking
- **Learning Progress**: Tiến độ học từng deck
- **Cards Learned**: Số cards đã học
- **Cards Due**: Số cards cần ôn
- **Retention Rate**: Tỷ lệ nhớ

### 8.4 User Deck Management
- **Create Deck**: Tạo bộ flashcard riêng
- **Edit Deck**: Chỉnh sửa deck info
- **Delete Deck**: Xóa deck
- **Add Card**: Thêm card vào deck
- **Edit Card**: Chỉnh sửa card (front, back, example)
- **Delete Card**: Xóa card
- **Publish Deck**: Công khai deck cho người khác

### 8.5 AI Vocabulary Features
- **Word Enrichment**: Làm giàu thông tin từ vựng
  - Definition (English + Vietnamese)
  - IPA Phonetic
  - Part of Speech
  - Example Sentences
  - Synonyms / Antonyms
  - CEFR Level (A1-C2)
  - IELTS Word Frequency
- **Passage Extraction**: Trích xuất từ vựng từ bài đọc
  - Identify important words
  - Rank by difficulty
  - Group by topic
  - One-click add to deck

---

## 9. 🔍 Dictionary

### 9.1 Word Lookup
- **Quick Lookup**: Tra từ nhanh
- **Full Definition**: Nghĩa đầy đủ (Anh-Việt)
- **Phonetics**: Phiên âm IPA + audio
- **Examples**: Câu ví dụ

### 9.2 Search Features
- **Autocomplete**: Gợi ý từ khi gõ
- **Fuzzy Search**: Tìm kiếm gần đúng
- **Suggestion List**: Danh sách từ gợi ý

### 9.3 Word Details
- **Word by ID**: Xem chi tiết từ theo ID
- **Multiple Meanings**: Nhiều nghĩa của từ
- **Usage Notes**: Ghi chú cách dùng

---

## 10. 🏆 Gamification

### 10.1 XP System
- **Earn XP**: Cộng XP khi hoàn thành bài
- **XP from Tests**: XP tỷ lệ với điểm số
- **XP from Lessons**: XP khi học xong bài
- **XP History**: Lịch sử giao dịch XP
- **Total XP**: Tổng XP đã tích lũy

### 10.2 Leveling System
- **Current Level**: Level hiện tại
- **Level Progress**: Tiến độ đến level tiếp
- **Level Thresholds**: XP cần cho mỗi level
- **Level Up Animation**: Hiệu ứng lên level

### 10.3 Streak System
- **Daily Streak**: Chuỗi ngày học liên tục
- **Streak Counter**: Số ngày streak hiện tại
- **Streak Protection**: Bảo vệ streak (future)
- **Best Streak**: Streak cao nhất từng đạt

### 10.4 Achievements
- **Achievement List**: Danh sách huy chương
- **Earned Achievements**: Huy chương đã đạt
- **Locked Achievements**: Huy chương chưa mở
- **Achievement Progress**: Tiến độ đến achievement
- **Achievement Types**:
  - First Test Completed
  - Score Milestones (Band 6, 7, 8, 9)
  - Streak Milestones (7 days, 30 days, 100 days)
  - Test Count Milestones (10, 50, 100 tests)
  - Perfect Score
  - Vocabulary Milestones

### 10.5 Leaderboard
- **Global Ranking**: Bảng xếp hạng toàn cầu
- **Top Users**: Danh sách top users by XP
- **User Rank**: Vị trí của user hiện tại
- **Weekly Leaderboard**: Xếp hạng tuần

### 10.6 Daily Check-in
- **Daily Check-in**: Điểm danh hàng ngày
- **Check-in Bonus**: XP bonus khi check-in
- **Check-in Streak**: Streak check-in liên tục

---

## 11. 🔔 Notifications

### 11.1 Notification Center
- **Notification List**: Danh sách thông báo
- **Unread Count**: Đếm thông báo chưa đọc
- **Notification Bell**: Icon bell với badge

### 11.2 Notification Types
- **XP Earned**: "Bạn vừa nhận được +50 XP"
- **Achievement Unlocked**: "Chúc mừng! Streak 7 Days"
- **Level Up**: "Lên Level 5!"
- **Study Reminder**: "Đừng quên học hôm nay"
- **Goal Progress**: "Bạn đã đạt 50% mục tiêu"

### 11.3 Notification Management
- **Mark as Read**: Đánh dấu đã đọc
- **Mark All Read**: Đánh dấu tất cả đã đọc
- **Notification Settings**: Bật/tắt loại thông báo
- **Email Notifications**: Nhận thông báo qua email

---

## 12. 📖 Courses & Lessons

### 12.1 Course Discovery
- **Browse Courses**: Danh sách khóa học
- **Course by Slug**: Truy cập khóa theo URL
- **Course Details**: Mô tả, số bài học, thời lượng

### 12.2 Course Enrollment
- **Enroll Course**: Đăng ký khóa học
- **My Courses**: Danh sách khóa đã đăng ký

### 12.3 Learning Lessons
- **Lesson List**: Danh sách bài trong khóa
- **View Lesson**: Xem nội dung bài học
- **Lesson Content**: Text, video, interactive
- **Complete Lesson**: Đánh dấu hoàn thành bài
- **XP Award**: Nhận XP khi hoàn thành bài

### 12.4 Course Progress
- **Course Progress**: Tiến độ từng khóa
- **Lessons Completed**: Số bài đã hoàn thành
- **Completion Percentage**: % hoàn thành khóa

---

## 13. 🤖 AI Chatbot

### 13.1 IELTS Tutor Chat
- **Chat Interface**: Giao diện chat với AI
- **Ask Questions**: Hỏi về IELTS, grammar, vocabulary
- **Get Explanations**: Nhận giải thích chi tiết
- **Practice Tips**: Mẹo luyện thi

### 13.2 Chat Features
- **Message History**: Lịch sử tin nhắn
- **Streaming Response**: Response real-time từ AI
- **Markdown Support**: Format text, code blocks

---

## 14. ⚙️ Admin Features

### 14.1 Exam Management
- **Create Exam**: Tạo đề thi mới
- **Edit Exam**: Chỉnh sửa đề thi
- **Delete Exam**: Xóa đề thi
- **Manage Sections**: Quản lý passages/sections
- **Manage Questions**: Quản lý câu hỏi
- **Manage Options**: Quản lý đáp án

### 14.2 Writing/Speaking Exam Management
- **Create Writing Exam**: Tạo đề writing
- **Create Speaking Exam**: Tạo đề speaking
- **Edit/Delete**: Chỉnh sửa, xóa đề

### 14.3 Course Management
- **Create Course**: Tạo khóa học
- **Edit Course**: Chỉnh sửa khóa học
- **Add Lessons**: Thêm bài học
- **Publish/Unpublish**: Công bố/ẩn khóa học

### 14.4 User Management
- **View All Users**: Danh sách users
- **View All Attempts**: Danh sách bài làm

### 14.5 Dictionary Management
- **Import Dictionary**: Import từ điển từ file
- **Reindex Elasticsearch**: Đánh index lại

---

## 15. 🔄 Background Services

### 15.1 RabbitMQ Events
- **AttemptSubmitted**: Trigger XP calculation
- **LessonCompleted**: Award lesson XP
- **UserRegistered**: Send verification email
- **ForgotPassword**: Send reset email

### 15.2 AI Integrations
- **Gemini AI**: Writing/Speaking grading, insights, vocabulary
- **OpenAI Whisper**: Speech-to-text
- **Cloudinary**: Media storage

### 15.3 Search Infrastructure
- **Elasticsearch**: Dictionary full-text search
- **Autocomplete**: Fast word suggestions

---

> **Total: 150+ individual features across 15 functional domains**
