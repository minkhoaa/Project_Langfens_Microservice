# Kiến Trúc Toàn Bộ Flow Generation-Service & Flow Tạo Đề (IELTS Academic)

Tài liệu này mô tả chi tiết kiến trúc của **`generation-service`** và **toàn bộ flow tạo đề thi hiện tại** trong hệ thống microservice **Langfens**, bao gồm quy trình tự động bằng AI (Autonomous Reading Paper Generation) và quy trình quản trị thủ công (Admin Manual Creation).

---

## 1. Tổng Quan Kiến Trúc Hệ Thống Tạo Đề

Hệ sinh thái tạo đề gồm các thành phần phối hợp chặt chẽ:

```
┌────────────────────────────────────────────────────────────────────────┐
│                   Admin Portal (Next.js Frontend)                      │
│      - Quản lý đề thủ công: /admin/exams                               │
│      - Tạo đề tự động:      /admin/exams/reading-paper                 │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ HTTP / REST
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                      YARP API Gateway (:5000)                          │
│             /api-exam/ ──► ReverseProxy sang exam-service               │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                       exam-service (.NET 10)                           │
│  ├── ReadingPaperEndpoints: REST API quản lý Job & Ingest nguồn        │
│  ├── ReadingPaperWorker: BackgroundService (Lease + Heartbeat)         │
│  ├── ReadingPaperAiClient: HTTP Client (NDJSON Streaming)              │
│  ├── ReadingPaperRules: Bộ quy chuẩn IELTS Academic & Validate Graph   │
│  └── AdminExam CRUD & QuestionBank: Tạo / duyệt đề thủ công            │
└──────────────┬──────────────────────────────────────────┬──────────────┘
               │ EF Core / PostgreSQL                     │ HTTP (NDJSON)
               ▼                                          ▼
┌──────────────────────────────┐        ┌────────────────────────────────┐
│   PostgreSQL (exam-db)       │        │  generation-service (FastAPI)  │
│  - Exams, Sections, Groups   │        │  ├── Router & Ingestion Engine │
│  - Questions, Options        │        │  ├── 4-Phase Pipeline          │
│  - ReadingPaperJobs          │        │  └── Streaming LLM Orchestrator│
└──────────────────────────────┘        └───────────────┬────────────────┘
                                                        │ OpenAI SDK
                                                        ▼
                                        ┌────────────────────────────────┐
                                        │         LLM Providers          │
                                        │  - MiniMax-Text-01 (Primary)   │
                                        │  - Groq / Llama 3.3 (Fallback) │
                                        └────────────────────────────────┘
```

---

## 2. Kiến Trúc & Pipeline Nội Tại của `generation-service`

`generation-service` là microservice chuyên biệt viết bằng **Python 3.12 / FastAPI** (cổng nội bộ `8080`, Compose port `8095`), có nhiệm vụ tạo bài thi **IELTS Academic Reading** đạt chuẩn quốc tế dựa trên nguồn khoa học có căn cứ thực tế (source-grounded).

### 2.1. Cấu Trúc Module
- **`router.py`**: Cung cấp API với tiền tố `/v1/autogen/reading-paper/`:
  - `GET /sources?topic=...`: Tìm kiếm bài báo khoa học ứng viên qua OpenAlex & Europe PMC.
  - `POST /source`: Tải full-text XML bài báo từ Europe PMC theo PMCID.
  - `POST /source/ingest`: Nạp nguồn tài liệu bất kỳ (URL, HTML, Markdown, Text).
  - `POST /section`: Tạo một section bài đọc (hỗ trợ stream `application/x-ndjson`).
- **`extractor.py`**:
  - Tải & kiểm tra bản quyền bài báo Europe PMC (bắt buộc CC-BY hoặc CC0, tối thiểu 600 từ gốc).
  - **Universal Ingestion**: Xử lý URL (kèm SSRF Protection chặn dải IP nội bộ/loopback), HTML body cleanup, loại bỏ rác/boilerplate.
  - `source_excerpt`: Trích chọn mẫu phân bổ đều toàn bài (tối đa 12.000–14.000 ký tự) để tránh vượt quá TPM của LLM.
- **`llm.py`**:
  - Tầng trừu tượng hóa LLM kết nối với **MiniMax** (chính) và **Groq** (xoay vòng nhiều API key dự phòng).
  - Bóc tách tag `<think>...</think>` đối với mô hình reasoning.
  - Xử lý defensive JSON parsing (loại bỏ markdown blocks, regex tìm cặp ngoặc JSON hợp lệ).
  - Tự động bắt lỗi 429 và retry sau 65 giây.
- **`prompts.py`**: Quản lý Section Profiles và cấu trúc 6 dạng câu hỏi IELTS Academic chuẩn.

### 2.2. Pipeline Tạo Một Passage (4-Phase Autonomous Pipeline)

Mỗi Section được thực thi khép kín qua 4 giai đoạn nghiêm ngặt:

```mermaid
flowchart TD
    Source[Nguồn Bài Báo >= 600 từ] --> P1[Phase 1: Passage Synthesis]
    P1 --> CheckWords{Độ dài 720-915 từ?}
    CheckWords -- < 720 từ --> Extend[Bounded Extension: extend_passage tối đa 4 lần]
    Extend --> CheckWords
    CheckWords -- Đủ từ --> Trim[Trim câu cuối theo ranh giới câu]
    
    Trim --> P2[Phase 2: Source-Fidelity Audit]
    P2 --> AuditCheck{Có lỗi bịa đặt / phóng đại?}
    AuditCheck -- Có lỗi --> Revise[Revision Loop tối đa 2 vòng]
    Revise --> P2
    AuditCheck -- Fail sau 2 vòng --> Fail[Reject Section: Fail-Closed]
    AuditCheck -- Sạch lỗi --> P3[Phase 3: Question Group Generation]
    
    P3 --> GenGroup1[Sinh Group 1 theo loại định sẵn]
    GenGroup1 --> GenGroup2[Sinh Group 2 theo loại định sẵn]
    GenGroup2 --> ValQ{Validate Question & Evidence?}
    ValQ -- Lỗi câu đơn lẻ --> ReplaceQ[replace_rejected_question cục bộ]
    ReplaceQ --> ValQ
    ValQ -- Hợp lệ --> P4[Phase 4: Independent Answer Review]
    
    P4 --> Reviewer[LLM Độc lập giải đề từ Passage]
    Reviewer --> Verdict{Tất cả câu hỏi đạt chuẩn?}
    Verdict -- Có câu bị reject --> SurgRep[Surgical Replacement & Re-review]
    SurgRep --> Reviewer
    Verdict -- 100% Valid --> Completed[Hoàn tất Section -> Trả về Client]
```

#### Chi tiết 4 Phase:
1. **Phase 1: Passage Synthesis (720–915 từ)**:
   - Viết bài đọc học thuật theo từng Section Profile:
     - **Section 1**: Văn phong mô tả, sự thật khách quan, trình tự rõ ràng.
     - **Section 2**: Phân tích, tập trung vào quy trình/cơ chế.
     - **Section 3**: Lập luận học thuật chuyên sâu, so sánh các quan điểm/giả thuyết.
   - Nếu LLM sinh thiếu độ dài (< 720 từ), hàm `extend_passage` tiếp tục gọi LLM viết tiếp các đoạn tiếp theo từ source gốc (tối đa 4 lần).
2. **Phase 2: Source-Fidelity Audit & Revision Loop (Fail-closed)**:
   - LLM đóng vai trò thẩm định viên đối chiếu từng câu của bài đọc với source gốc.
   - Bắt các lỗi: `unsupported_claim` (không có trong nguồn), `contradicted_claim` (mâu thuẫn), `causal_overstatement` (biến tương quan thành nhân quả), `overstated_certainty` (phóng đại độ chắc chắn), `unmeasured_outcome`.
   - Nếu có lỗi, kích hoạt revision loop (tối đa 2 lượt) để viết lại những chỗ sai. Nếu sau 2 lượt vẫn còn lỗi, từ chối toàn bộ section (fail-closed).
3. **Phase 3: Question Group Generation**:
   - Mỗi section luôn gồm 2 nhóm câu hỏi với cấu hình cố định:
     - **Section 1**: `TRUE_FALSE_NOT_GIVEN` (7 câu) + `SENTENCE_COMPLETION` (6 câu) = 13 câu.
     - **Section 2**: `MULTIPLE_CHOICE_SINGLE` (6 câu) + `SUMMARY_COMPLETION` (7 câu) = 13 câu.
     - **Section 3**: `YES_NO_NOT_GIVEN` (7 câu) + `SHORT_ANSWER` (7 câu) = 14 câu.
   - Bắt buộc kiểm tra `evidenceQuote` phải tồn tại nguyên văn trong bài đọc.
   - Đối với completion/short-answer: đáp án không quá 3 từ/số và phải xuất hiện nguyên văn trong bài đọc, không làm lộ đáp án trong đề (`answer_leakage`).
4. **Phase 4: Independent Answer Review & Surgical Replacement**:
   - Một LLM độc lập giải đề mà **chỉ đọc bài đọc và câu hỏi** (không xem prompt gốc).
   - Kiểm tra tính duy nhất của đáp án, độ phân hóa học thuật (loại bỏ các câu quá hiển nhiên `too_direct`), tính tương thích giữa câu trả lời và trích dẫn bằng chứng.
   - Nếu có câu bị từ chối, hệ thống thực hiện **Surgical Replacement** (chỉ sinh lại đúng câu hỏi bị lỗi kèm prompt cấm lặp lại nội dung cũ) và tái thẩm định.

---

## 3. Toàn Bộ Flow Tạo Đề Hiện Tại

Hệ thống hỗ trợ 2 flow tạo đề chính:

### FLOW 1: Tạo Đề Tự Động (Autonomous AI Reading Paper Flow)

Toàn bộ quy trình diễn ra bất đồng bộ thông qua Job & Worker:

```mermaid
sequenceDiagram
    autonumber
    actor Admin as Admin (Frontend)
    participant ExamSvc as exam-service (API)
    participant DB as PostgreSQL (exam-db)
    participant Worker as ReadingPaperWorker
    participant GenSvc as generation-service

    Admin->>ExamSvc: GET /api/admin/reading-paper/sources?topic={topic}
    ExamSvc->>GenSvc: Tìm kiếm bài báo khoa học (OpenAlex + Europe PMC)
    GenSvc-->>ExamSvc: Danh sách ứng viên (Title, PMCID, License, WordCount)
    ExamSvc-->>Admin: Hiển thị gợi ý nguồn

    Admin->>ExamSvc: POST /api/admin/reading-paper/jobs (Chọn 1-3 nguồn, Topic, Provider)
    ExamSvc->>DB: Lưu ReadingPaperJob (Status: Pending)
    ExamSvc-->>Admin: Trả về Job ID

    loop Background Worker Loop (mỗi 10s)
        Worker->>DB: Claim Job (Status=Running, LeaseUntil=Now+3m, LeaseOwner=GUID)
        activate Worker
        Worker->>Worker: Khởi động Heartbeat Task (Gia hạn lease mỗi 30s)
        
        loop Cho từng Passage (1 -> 2 -> 3)
            Worker->>GenSvc: POST /v1/autogen/reading-paper/section (Accept: ndjson)
            activate GenSvc
            loop Streaming NDJSON Events
                GenSvc-->>Worker: Token/Log stream event
                Worker->>DB: Ghi log thời gian thực vào Job.Logs
            end
            GenSvc-->>Worker: Trả về Section hoàn chỉnh (Passage + 2 Groups + Questions)
            deactivate GenSvc
            
            Worker->>DB: Lưu Checkpoint: Cập nhật SectionsJson & CompletedSections
        end

        Worker->>Worker: Validate toàn bài (ReadingPaperRules.Validate)
        Note over Worker: Kiểm tra: 2150-2750 từ, 40 câu liên tục, Shingle chống trùng lặp

        Worker->>DB: Transaction: BuildExam -> Tạo Exam, Section, Question, Option -> Status=Completed
        deactivate Worker
    end

    Admin->>ExamSvc: Polling GET /api/admin/reading-paper/jobs/{id}
    ExamSvc->>DB: Đọc trạng thái & logs
    ExamSvc-->>Admin: Cập nhật tiến độ / Hoàn tất với ExamId (Trạng thái Draft)
```

#### Các đặc tính nổi bật của Flow:
- **Distributed Lease & Heartbeat**: Chống tranh chấp nhiều instance worker; tự động khôi phục nếu worker bị crash (lease tự hết hạn sau 3 phút).
- **Checkpoint & Resume**: Nếu tạo 3 passage mà passage 3 gặp sự cố, hệ thống giữ nguyên checkpoint 2 passage đầu; khi bấm **Retry**, worker chạy tiếp từ passage 3 mà không sinh lại từ đầu.
- **Replace Sources**: Nếu nguồn không đủ điều kiện (trạng thái `NeedsSources`), admin có thể thay thế nguồn mới mà không cần tạo lại job.
- **Final Exam Graph**: Đề được khởi tạo với trạng thái **`ExamStatus.Draft`** để Admin biên tập, rà soát lại trước khi phát hành (Publish).

---

### FLOW 2: Tạo Đề Thủ Công (Admin Manual Exam Creation Flow)

Dành cho ban biên tập tạo đề truyền thống hoặc đề Listening / Writing / Speaking:

```mermaid
sequenceDiagram
    autonumber
    actor Admin as Admin (Frontend)
    participant Gateway as YARP API Gateway
    participant ExamSvc as exam-service
    participant DB as PostgreSQL (exam-db)

    Admin->>Gateway: POST /api/admin/exams (Title, Category, Level, DurationMin, DescriptionMd)
    Gateway->>ExamSvc: AdminExamEndpoint.AddExamHandler
    ExamSvc->>ExamSvc: Tạo Slug duy nhất (SlugHelper.MakeUniqueSlugAsync)
    ExamSvc->>DB: INSERT INTO Exams (Status = Draft)
    ExamSvc-->>Admin: Trả về Exam vừa tạo (Id, Slug)

    Admin->>Gateway: POST /api/admin/sections (ExamId, Title, PassageMd, InstructionsMd, Idx)
    Gateway->>ExamSvc: AdminSectionHandler.AddSectionHandler
    ExamSvc->>DB: INSERT INTO ExamSections
    ExamSvc-->>Admin: SectionId

    opt Upload Media nếu có
        Admin->>Gateway: POST /api/admin/upload/image (Multipart form-data)
        Gateway->>ExamSvc: AdminUploadEndpoint (Kiểm tra dung lượng <= 5MB, format ảnh)
        ExamSvc->>ExamSvc: Lưu file vào wwwroot/uploads/images/yyyy/mm/{guid}.{ext}
        ExamSvc-->>Admin: Trả về Relative Image URL
    end

    Admin->>Gateway: POST /api/admin/questions (SectionId, Type, Skill, Difficulty, PromptMd, Options, Answers)
    Gateway->>ExamSvc: AdminQuestionHandler.AddQuestionHandler
    ExamSvc->>DB: INSERT INTO ExamQuestions & ExamOptions
    ExamSvc-->>Admin: QuestionId

    Admin->>Gateway: PUT /api/admin/exams/{id} (Cập nhật Status = Published)
    Gateway->>ExamSvc: AdminExamHandler.UpdateExamHandler
    ExamSvc->>DB: UPDATE Exams SET Status = Published
    ExamSvc-->>Admin: Đề thi sẵn sàng cho học viên làm bài
```

---

## 4. Bảng So Sánh Hai Flow Tạo Đề

| Tiêu chí | Flow Tạo Đề AI (`generation-service`) | Flow Tạo Đề Thủ Công (`exam-service`) |
| :--- | :--- | :--- |
| **Kỹ năng áp dụng** | IELTS Academic Reading (1–3 Passages) | Đa kỹ năng (Reading, Listening, Writing, Speaking) |
| **Đầu vào** | Topic / PMCID bài báo khoa học / Văn bản raw | Giáo viên nhập liệu từng đoạn văn, câu hỏi |
| **Thời gian tạo** | Tự động hoàn toàn (khoảng 3–5 phút cho bài full 40 câu) | Thủ công (30–60 phút tùy dung lượng đề) |
| **Quy chuẩn đề** | Tự động clamp 720–915 từ/bài, 40 câu, 6 dạng bài IELTS chuẩn | Phụ thuộc vào người biên soạn |
| **Thẩm định chất lượng**| Tự động 2 tầng: Source-Fidelity Audit & Independent Reviewer | Người dùng tự kiểm duyệt |
| **Cơ chế chịu lỗi** | Checkpointing từng Section, Distributed Lease, Retry tự động | Lưu trực tiếp từng thao tác qua REST API |
| **Trạng thái khởi tạo**| Luôn là `Draft` để Admin duyệt cuối trước khi Publish | `Draft` -> Admin chủ động chuyển `Published` |

---

## 5. Tổng Kết

Kiến trúc tạo đề của Langfens kết hợp giữa **mô hình Async Background Job bền bỉ trên .NET 10** và **hệ thống Multi-stage AI Pipeline thông minh trên Python FastAPI**. Thiết kế này đảm bảo:
1. **Tính học thuật & độ tin cậy**: Bài đọc 100% bám sát tài liệu khoa học mở, không bị ảo giác (hallucination).
2. **Khả năng mở rộng & khả năng phục hồi**: Không block HTTP request, lưu checkpoint từng bước, chịu lỗi mạng và rate limit LLM.
3. **Quyền kiểm soát của con người (Human-in-the-loop)**: AI hỗ trợ sinh đề chuẩn, nhưng quyết định xuất bản cuối cùng thuộc về Admin qua hệ thống quản trị Draft/Publish.
