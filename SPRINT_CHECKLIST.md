# 🎯 IELTS Platform - Sprint Checklist

> Đồ án 1 - Hoàn thiện các features còn thiếu

---

## ✅ NHÓM 1: CẦN THIẾT (DONE)

- [x] **Gamification & Achievement** - Points, Streaks, Badges, Level up
- [x] **User Analytics Dashboard** - Skill breakdown, Progress charts, Study time
- [x] **Full Mock Test (4 skills)** - Reading, Listening, Writing, Speaking với timer
- [x] **Question Bank by Type** - Filter bài tập theo dạng câu hỏi
- [x] **Study Plan / Goal Setting** - Đặt mục tiêu band, theo dõi progress
- [x] **Notification & Reminder** - Push notification, streak warning
- [x] **Leaderboard** - Xếp hạng thi đua

---

## 🔴 NHÓM 2: CẦN BỔ SUNG

### Priority 1: Error Review System ⏱️ ~1-2 days
- [ ] **Backend**: API lấy câu sai từ attempts group by question type
- [ ] **Backend**: API lấy chi tiết explanation cho câu sai
- [ ] **Frontend**: Trang `/error-review` hiển thị câu sai
- [ ] **Frontend**: Filter theo dạng câu, skill, khoảng thời gian

### Priority 2: Bookmark & Note ⏱️ ~1 day
- [ ] **Backend**: Entity `Bookmark` trong attempt-service
- [ ] **Backend**: Entity `Note` cho ghi chú câu hỏi
- [ ] **Backend**: CRUD APIs cho bookmark/note
- [ ] **Frontend**: Icon bookmark trên mỗi câu hỏi
- [ ] **Frontend**: Panel quản lý bookmarks

### Priority 3: Listening Transcript Timestamp ⏱️ ~1-2 days
- [ ] **Backend**: Thêm field `timestampedSegments` cho transcript
- [ ] **Frontend**: Highlight text sync với audio position
- [ ] **Frontend**: Click vào câu để jump đến vị trí audio

### Priority 4: Band Score Predictor ⏱️ ~2-3 days
- [ ] **Backend**: Tính toán predicted band từ lịch sử attempts
- [ ] **Backend**: Weighted average theo recency và question type
- [ ] **Frontend**: Widget hiển thị predicted band score
- [ ] **Frontend**: Trend chart với confidence interval

### Priority 5: Grammar Lessons & Exercises ⏱️ ~3-5 days
- [ ] **Backend**: Tạo grammar-service mới hoặc tích hợp vào exam-service
- [ ] **Backend**: Entity cho lessons, exercises, progress
- [ ] **Frontend**: Trang `/course` với danh sách bài học
- [ ] **Frontend**: UI làm bài tập grammar
- [ ] **Content**: Chuẩn bị nội dung bài học

---

## 📝 Ghi chú Sprint

| Ngày | Focus | Target |
|------|-------|--------|
| 27/12 | Error Review System | Backend + Frontend MVP |
| 28/12 | Bookmark & Note | Full feature |
| 29/12 | Transcript Timestamp | Hoàn thiện Listening |
| 30/12 | Band Predictor | Algorithm + UI |
| 31/12 | Testing & Polish | Bug fixes |

---

## 🏁 Definition of Done

- [ ] Backend API hoạt động, có error handling
- [ ] Frontend responsive, UI đẹp
- [ ] Integration test qua Postman/browser
- [ ] Không có console errors
- [ ] Code được commit và push

---

*Last updated: 26/12/2024*
