# Kiến Trúc và Luồng Hoạt Động Của Các Module AI (Langfens Platform)

Tài liệu tổng hợp toàn diện trạng thái kỹ thuật hiện tại, vai trò và chi tiết các luồng dữ liệu (end-to-end flows) của toàn bộ các module AI trong hệ sinh thái microservice Langfens.

---

## 1. Tổng Quan Kiến Trúc AI Phân Tầng

Hệ thống AI của Langfens được thiết kế theo mô hình phân tầng, kết hợp giữa **gọi trực tiếp (Synchronous HTTP with Circuit Breaker)** và **xử lý sự kiện (Event-driven via RabbitMQ / MassTransit)**:

```
                      ┌────────────────────────────────────────┐
                      │          API Gateway (YARP)            │
                      └──────────────────┬─────────────────────┘
                                         │
                 ┌───────────────────────┼───────────────────────┐
                 │                       │                       │
                 ▼                       ▼                       ▼
      ┌────────────────────┐   ┌───────────────────┐   ┌───────────────────┐
      │   writing-service  │   │  speaking-service │   │  attempt-service  │
      │   (.NET 10 / 8091) │   │  (.NET 10 / 8090) │   │  (.NET 10 / 8081) │
      └─────────┬──────────┘   └─────────┬─────────┘   └─────────┬─────────┘
                │                        │                       │
         HTTP   │                        │ HTTP                  │ HTTP (RAG Explainer)
    (Grader/    │                        │ (Speaking Grader)     │ & Azure OpenAI
    Compare)    │                        │                       │ (Study Insights)
                ▼                        ▼                       ▼
      ┌────────────────────────────────────────────────────────────────────┐
      │                           ai-service                               │
      │                    (Python FastAPI / 8092)                         │
      │   ┌────────────────────────────────────────────────────────────┐   │
      │   │ • LLM Engine: Groq (Multi-key rotation, gpt-oss-20b/120b)  │   │
      │   │ • Local Fine-tuned: Qwen2.5-LoRA (Speaking grade & roleplay)│   │
      │   │ • Embeddings: Ollama (BGE-M3, 1024 dims, CPU mode)        │   │
      │   │ • ASR & Pronunciation: faster-whisper (WER & Word Errors)  │   │
      │   │ • Vector DB & Memory: Qdrant (Writing, Grammar, Speaking)  │   │
      │   │ • Semantic Cache: Redis (SHA256 vector hash, TTL 3600s)    │   │
      │   └────────────────────────────────────────────────────────────┘   │
      └────────────────────────────────────────────────────────────────────┘
                 ▲                                               ▲
                 │              RabbitMQ (MassTransit)           │
                 └───────────────────────────────────────────────┘
                     • WritingGradeRequestMessage / WritingGradeResponseMessage
                     • SpeakingGradingRequestMessage / SpeakingGradingResponseMessage
```

---

## 2. Chi Tiết Trạng Thái Hiện Tại Của Từng Module

### 2.1. `ai-service` (Python FastAPI — Trái tim xử lý AI)

- **Vị trí**: `services/ai-service/` (Port nội bộ container `8080`, host `8092`).
- **LLM Provider chính**:
  - **Groq API**: Nhà cung cấp LLM chính cho toàn bộ pipeline: chấm bài viết (writing), phân tích so sánh (compare), giải thích ngữ pháp (grammar), giải thích bài đọc/nghe (reading/listening RAG) và sinh câu hỏi (autogen).
  - **KeyManager & Failover**: Hỗ trợ xoay vòng nhiều key thông qua biến môi trường `GROQ_API_KEYS` (phân tách bởi dấu phẩy). Khi gặp HTTP 429 (Rate Limit), key gặp lỗi sẽ tự động rơi vào trạng thái cooldown 60 giây (chu kỳ reset TPM của Groq) và chuyển sang key kế tiếp.
  - **Model**: Mặc định `openai/gpt-oss-20b`; riêng module ước lượng band điểm sơ bộ (`_estimate_band_with_llm`) sử dụng model lớn `openai/gpt-oss-120b` với temperature 0.1 để neo band điểm, tránh over-scoring và hallucination từ RAG.
- **Embeddings & Vector Search (RAG)**:
  - **Ollama BGE-M3**: Chạy mô hình embedding `bge-m3` (1024 chiều). Cố định chạy ở chế độ CPU (`num_gpu=0`) nhằm triệt tiêu lỗi sinh giá trị `NaN` trên CUDA của Ollama.
  - **Qdrant Vector DB**: Quản lý 3 collection:
    1. `writing_samples`: Chứa các bài mẫu chuẩn band cao để RAG tham chiếu và đối chiếu bài viết.
    2. `grammar_knowledge`: Tập luật ngữ pháp phục vụ giải thích lỗi.
    3. `speaking_memory`: Lưu trữ lịch sử các lỗi phát âm của từng học viên nhằm cá nhân hóa phản hồi bot trong hội thoại Roleplay.
  - **Semantic Cache (Redis)**: Lưu trữ kết quả vector search theo SHA256 của 32 chiều vector đầu + filters, thời gian sống (TTL) mặc định 3600 giây. Tự động phục hồi (graceful degradation) nếu Redis ngắt kết nối.
  - **Startup Ingestion**: Tự động kiểm tra và nạp dữ liệu mẫu vào Qdrant nếu collection rỗng (`ingestion_service.py`).
- **Local Model (Fine-tuned LoRA)**:
  - `app/services/qwen_service.py`: Tải mô hình cục bộ **Qwen2.5-LoRA** phục vụ chấm điểm Speaking (`/v1/speaking/grade`) và hội thoại Roleplay (`/v1/speaking/roleplay/turn-local`, `/turn-audio`), độc lập với cloud LLM. Tự động fallback về Ollama (`qwen2.5`) nếu LoRA gặp sự cố.
- **Speech-to-Text & Chấm phát âm (ASR)**:
  - `app/services/speech_eval_service.py`: Tích hợp `faster-whisper` (model `base`, CPU int8).
  - Thuật toán căn chỉnh WER (Word Error Rate) tính điểm phát âm (thang 0.0 – 1.0) và trích xuất lỗi phát âm từng từ (`missing` hoặc `incorrect`).
- **RAG Explainer Endpoints**:
  - `POST /api/v1/reading/explain-item`: Giải thích câu hỏi Reading dựa trên trích đoạn bài đọc (`passage_quote`), phân tích bẫy (`distractor_analysis`), xuất ra theo chuẩn `RagFeedbackEnvelope`.
  - `POST /api/v1/listening/explain-item`: Tương tự cho câu hỏi Listening dựa trên transcript audio.
- **Question Autogen**:
  - `POST /api/v1/autogen/questions`: Nhận cấu hình kỹ năng/dạng bài, gọi Groq sinh JSON câu hỏi IELTS chuẩn format backend, chống malformed JSON từ phía client.

---

### 2.2. `writing-service` (.NET 10 — Chấm & Phân Tích Bài Viết)

- **Vị trí**: `services/writing-service/` (Port `8091`).
- **Tích hợp AI**:
  - `AiWritingGrader`: Gọi HTTP `POST /api/v1/writing/grade` tới `ai-service`.
  - `AiCompareClient`: Gọi HTTP `POST /api/v1/writing/compare` tới `ai-service`.
- **Cơ chế phòng vệ Circuit Breaker**:
  - Triển khai riêng biệt 2 instance `CircuitBreaker` (keyed singleton: `"grader"` và `"compare"`). Khi `ai-service` lỗi liên tiếp vượt ngưỡng, Circuit Breaker tự ngắt mạch để bảo vệ hệ thống khỏi cascading failure.
- **Lưu trữ dữ liệu**:
  - Entity `WritingSubmission`: Lưu thông tin bài làm, số từ, thời gian làm bài, snapshot đề bài.
  - Entity `WritingEvaluation`: Lưu band 4 tiêu chí (TR, CC, LR, GR), gợi ý cải thiện (`SuggestionsJson`), bài viết viết lại (`ImprovedParagraph`), luật ngữ pháp (`GrammarRulesJson`), lỗi ngữ pháp (`GrammarErrorsJson`), và phân tích đối chiếu bài mẫu (`ComparativeAnalysisJson`).

---

### 2.3. `speaking-service` (.NET 10 — Thu Âm, Nhận Diện Giọng Nói & Chấm Speaking)

- **Vị trí**: `services/speaking-service/` (Port `8090`).
- **Xử lý Audio & Nhận diện kép (Hybrid STT)**:
  - **Whisper.net Cục bộ**: Nhúng trực tiếp thư viện Whisper.net trong runtime .NET (ưu tiên CUDA -> CPU -> CPU-no-AVX) để xử lý file ghi âm nộp bài và WebSocket streaming practice real-time.
  - **Cloudinary**: Lưu trữ CDN cho toàn bộ audio bài thi của người dùng.
- **Tích hợp Chấm Điểm AI**:
  - `AiSpeakingGrader`: Gửi transcript sang `ai-service` tại `POST /api/v1/speaking/grade` để nhận band 4 tiêu chí Speaking (Fluency & Coherence, Lexical Resource, Grammatical Range & Accuracy, Pronunciation).

---

### 2.4. `attempt-service` (.NET 10 — Điều Phối Bài Thi & Khuyến Nghị Học Tập)

- **Vị trí**: `services/attempt-service/` (Port `8081`).
- **RAG Explainer Cho Reading & Listening**:
  - `SkillRagExplainer`: Khi học viên nộp bài trắc nghiệm Reading/Listening, service tự động chấm theo answer key (lấy qua gRPC từ `exam-service`), đồng thời kích hoạt cuộc gọi tới `ai-service` với **timeout giới hạn 3 giây** (`CancellationTokenSource.CancelAfter(3s)`).
  - Kết quả giải thích được lưu vào cột JSONB `AttemptAnswer.RagFeedbackJson`, sẵn sàng hiển thị tại component `RagFeedbackCard` trên Frontend.
- **Điều Phối Chấm Thi (Placement / Full Exam Workflow)**:
  - Khi bài thi có câu hỏi Writing/Speaking, `PlacementWorkflow` gửi message qua RabbitMQ cho `writing-service` và `speaking-service`.
  - Consumers `WritingGradedConsumer` và `SpeakingGradedConsumer` lắng nghe kết quả trả về, tự động tính Overall Band, cập nhật trạng thái Attempt thành `Graded`.
- **AI Study Insights & Dự Đoán Band (Azure OpenAI)**:
  - `AiInsightsService`: Tích hợp Azure OpenAI (`gpt-4o-mini`).
  - Đọc 20 lần thi gần nhất, phân tích tỷ lệ chính xác từng nhóm dạng câu hỏi (strengths/weaknesses), sinh báo cáo xu hướng và gợi ý 2–4 mục tiêu ưu tiên học tập bằng tiếng Việt.

---

### 2.5. `Shared.PublicContracts` (Hợp Đồng Dữ Liệu Dùng Chung)

- Cung cấp `RagFeedbackContracts.cs` với envelope chuẩn hóa:
  - `overall_band`: Điểm band đánh giá.
  - `criteria`: Mảng điểm theo từng tiêu chí kèm comment nhận xét.
  - `evidence`: Mảng trích dẫn dẫn chứng bài đọc/bài nghe (`passage_quote` / `audio_quote`).
  - `suggestions`: Mảng gợi ý cải thiện.
  - `raw_llm_json`: Bản sao lưu JSON gốc từ LLM.

---

## 3. Chi Tiết Các Luồng Hoạt Động (End-to-End Execution Flows)

### 3.1. Flow 1: Luyện Viết Tự Do (Standalone Writing Practice — Flow A)

Dành cho người dùng luyện viết trực tiếp theo từng đề bài:

```
[User / FE]
   │
   │ 1. POST /writing/submit (Answer, ExamId)
   ▼
[writing-service : WritingService]
   │
   │ 2. Gọi HTTP POST /api/v1/writing/grade (bảo vệ bởi CircuitBreaker "grader")
   ▼
[ai-service : grade_service]
   │ 3. Ước lượng band sơ bộ bằng LLM (gpt-oss-120b) hoặc regex density
   │ 4. Per-criterion RAG từ Qdrant (lọc bài mẫu và luật ngữ pháp theo band)
   │ 5. Gọi Groq sinh điểm 4 tiêu chí (TR, CC, LR, GR), grammar errors, suggestions
   ▼
[writing-service : WritingService]
   │ 6. Thêm bản ghi WritingSubmission vào DB
   │ 7. Ánh xạ kết quả thành WritingEvaluation (lưu vào DB)
   │ 8. Trả ngay HTTP 200 OK kèm điểm số cho Frontend (Fast UX)
   │ 9. Bắn message RabbitMQ: WritingGradeRequestMessage (CÓ SubmissionId)
   ▼
[RabbitMQ Exchange & Queue]
   ▼
[writing-service : WritingSubmittedConsumer]
   │ 10. Phát hiện request.SubmissionId.HasValue == true
   │ 11. Đọc lại WritingEvaluation từ DB (có cơ chế Retry Backoff) -> KHÔNG chấm lại
   │ 12. Gọi HTTP POST /api/v1/writing/compare sang ai-service
   │ 13. Cập nhật trường ComparativeAnalysisJson vào WritingEvaluation trong DB
   │ 14. BỎ QUA PUBLISH (Skip): Không bắn message lên bus vì không có Attempt cha
```

---

### 3.2. Flow 2: Luyện Nói Tự Do (Standalone Speaking Practice — Flow A)

Dành cho người dùng luyện nói trực tiếp theo từng đề thi Speaking:

```
[User / FE]
   │
   │ 1. POST /speaking/submit (Multipart Audio file, ExamId)
   ▼
[speaking-service : SpeakingService]
   │ 2. Dùng Whisper.net in-process chuyển Audio -> Transcript
   │ 3. Gọi HTTP POST /api/v1/speaking/grade sang ai-service (Transcript + TaskText)
   ▼
[ai-service : grade_speaking]
   │ 4. Gọi Qwen2.5-LoRA cục bộ (hoặc Ollama fallback)
   │ 5. Trả về điểm 4 tiêu chí (FC, LR, GR, PR), gợi ý sửa và câu trả lời mẫu
   ▼
[speaking-service : SpeakingService]
   │ 6. Lưu SpeakingSubmission & SpeakingEvaluation vào DB
   │ 7. Trả HTTP 200 OK kèm điểm số và nhận xét chi tiết về cho User
```

---

### 3.3. Flow 3: Thi Thử / Kiểm Tra Đầu Vào Đa Kỹ Năng (Exam / Placement Attempt — Flow B)

Luồng tích hợp giữa `attempt-service`, `writing-service`, `speaking-service`, và `ai-service`:

```
                                  [User nộp bài thi Attempt / Placement]
                                                     │
                                                     ▼
                                            [attempt-service]
                                                     │
            ┌────────────────────────────────────────┴────────────────────────────────────────┐
            │ (Nhánh trắc nghiệm: Chấm đồng bộ)                                              │ (Nhánh tự luận: Event-driven RabbitMQ)
            ▼                                                                                ▼
   [Reading & Listening]                                                            [Writing & Speaking]
            │                                                                                │
   • Chấm trắc nghiệm tự động qua Answer Key                                        • Publish 2 events lên RabbitMQ:
     (gRPC tới exam-service)                                                           1. WritingGradeRequestMessage (SubmissionId = NULL)
            │                                                                          2. SpeakingGradingRequestMessage (AudioUrl, Prompt)
   • Gọi đồng thời RAG Explainer sang ai-service                                             │
     (Timeout bảo vệ 3 giây):                                                                ├───────────────────────────────┐
     - POST /api/v1/reading/explain-item                                                     ▼                               ▼
     - POST /api/v1/listening/explain-item                                           [writing-service]               [speaking-service]
            │                                                                                │                               │
   • Lưu RagFeedbackJson vào AttemptAnswer                                          • Tạo mới WritingSubmission     • Tải Audio từ Cloudinary
     (hiển thị trích dẫn bài thi & bẫy trắc nghiệm)                                   (ExamId = null)               • Whisper.net transcribe
            │                                                                       • Gọi ai-service chấm bài       • Gọi ai-service chấm bài
            │                                                                       • Gọi ai-service compare        • Publish response:
            │                                                                       • Lưu WritingEvaluation           SpeakingGradingResponseMessage
            │                                                                       • Publish response:                              │
            │                                                                         WritingGradeResponseMessage                    │
            │                                                                                │                                       │
            └────────────────────────────────────────┬───────────────────────────────────────┴───────────────────────────────────────┘
                                                     ▼
                                      [attempt-service Consumers]
                                      • WritingGradedConsumer
                                      • SpeakingGradedConsumer
                                                     │
                                                     ▼
                                            [PlacementWorkflow]
                                      • Cập nhật WritingBand & SpeakingBand vào PlacementResult
                                      • Tính điểm tổng Overall Band theo công thức chuẩn IELTS
                                      • Ánh xạ trình độ CEFR / Level
                                      • Cập nhật trạng thái bài thi: AttemptStatus = Graded
```

---

### 3.4. Chi Tiết Cơ Chế Phân Nhánh Tại `WritingSubmittedConsumer`

Để tránh xung đột dữ liệu giữa hai luồng làm bài, `WritingSubmittedConsumer` sử dụng thuộc tính `request.SubmissionId.HasValue` làm điểm phân nhánh:

| Tiêu chí | Flow A: Luyện viết tự do | Flow B: Bài thi Attempt / Placement |
| :--- | :--- | :--- |
| **Nguồn phát sinh** | `writing-service` (`WritingService.WritingSubmit`) | `attempt-service` (`PlacementWorkflow`) |
| **`SubmissionId` trong message** | **Có giá trị (HasValue = true)** | **Không có giá trị (null / HasValue = false)** |
| **Hành vi chấm điểm LLM** | **Bỏ qua chấm lại** (tái sử dụng kết quả đã lưu trong DB) | **Tạo mới `WritingSubmission` và gọi `_grader.GradeAsync`** |
| **Hành vi chạy so sánh** | Gọi `_compareClient.CompareAsync` và lưu DB | Gọi `_compareClient.CompareAsync` và lưu DB |
| **Hành vi publish RabbitMQ** | **Bỏ qua (Skip publish)** để không ghi nhầm vào `PlacementResult` | **Publish `WritingGradeResponseMessage`** để `attempt-service` cập nhật điểm tổng |

---

### 3.5. Flow 4: Luyện Hội Thoại & Sửa Phát Âm AI (Speaking Roleplay Pipeline)

Chạy hoàn toàn trong `ai-service`:

```
[User / FE]
   │ 1. GET /api/v1/speaking/roleplay/scenarios (chọn ngữ cảnh: nhà hàng, phỏng vấn...)
   │ 2. POST /api/v1/speaking/roleplay/start (khởi tạo session_id)
   │ 3. POST /api/v1/speaking/roleplay/turn-audio (upload audio giọng nói học viên)
   ▼
[ai-service : routers/speaking.py]
   │ 4. faster-whisper transcribe audio -> transcript
   │ 5. So sánh với target text (nếu có) để tính điểm phát âm (WER) và danh sách lỗi từng từ
   │ 6. Truy vấn Qdrant (`speaking_memory`): Lấy các lỗi phát âm học viên hay mắc trong quá khứ
   │ 7. Đưa toàn bộ ngữ cảnh vào mô hình Qwen2.5-LoRA:
   │    -> Sinh câu thoại đáp lại tự nhiên, khéo léo lồng ghép việc chỉnh sửa lỗi phát âm vừa mắc
   │ 8. Background Task: Lưu vết lỗi phát âm của lượt này vào Qdrant memory của user
   ▼
[Frontend nhận về]
   • Văn bản nhận diện (Transcript)
   • Điểm phát âm & danh sách từ phát âm sai
   • Câu thoại phản hồi của AI Bot kèm nhận xét sư phạm
```

---

### 3.6. Flow 5: Phân Tích Dữ Liệu Học Tập Bằng AI (AI Study Insights)

```
[User / FE]
   │ 1. GET /api/analytics/ai-insights
   ▼
[attempt-service : AiInsightsService]
   │ 2. Truy vấn tối đa 20 bản ghi PlacementResults gần nhất từ PostgreSQL
   │ 3. Tính toán độ chính xác (Accuracy %) theo từng kỹ năng và từng dạng câu hỏi
   │ 4. Tổng hợp danh sách Điểm mạnh (Strengths) và Điểm yếu (Weaknesses)
   │ 5. Xây dựng prompt chuẩn hóa theo `AiInsightsPrompt` gửi sang Azure OpenAI (gpt-4o-mini)
   ▼
[Azure OpenAI]
   │ 6. Phân tích xu hướng và sinh đề xuất theo schema JSON chặt chẽ
   ▼
[Frontend nhận về]
   • summary: Tóm tắt 2-3 câu về trình độ và tiến độ học tập bằng tiếng Việt
   • trendAnalysis: Đánh giá xu hướng tăng/giảm band điểm
   • recommendations: Danh sách các lời khuyên hành động cụ thể
   • focusAreas: 2–4 dạng câu hỏi/kỹ năng cần tập trung ôn luyện nhất kèm độ ưu tiên
```

---

## 4. Bảng Tổng Hợp Công Nghệ & Trạng Thái Kỹ Thuật

| Tính năng / Tác vụ | Module đảm nhiệm | Công nghệ / Model chính | Giao thức | Trạng thái |
| :--- | :--- | :--- | :--- | :--- |
| **Writing Grading** | `writing-service` $\rightarrow$ `ai-service` | Groq (`gpt-oss-20b` & `120b`) + Qdrant RAG | HTTP POST (CircuitBreaker) + RabbitMQ | Hoàn chỉnh; có clamp band chống hallucination |
| **Writing Compare** | `writing-service` $\rightarrow$ `ai-service` | Qdrant (`writing_samples`) + Groq | HTTP POST + Async Consumer | Hoàn chỉnh; chạy ngầm không block UX |
| **Speaking Grading** | `speaking-service` $\rightarrow$ `ai-service` | Local Fine-tuned Qwen2.5-LoRA (Ollama fallback) | HTTP POST + RabbitMQ | Hoàn chỉnh; format compact tối ưu JSON |
| **Speech-to-Text (STT)**| `speaking-service` & `ai-service` | Whisper.net (.NET) & faster-whisper (Python) | In-process native / HTTP | Hoàn chỉnh; hỗ trợ cả CPU và CUDA |
| **Speaking Roleplay** | `ai-service` | Qwen2.5-LoRA + Qdrant `speaking_memory` | REST API trực tiếp | Hoàn chỉnh; có bộ nhớ nhớ lỗi phát âm quá khứ |
| **RAG Reading/Listening** | `attempt-service` $\rightarrow$ `ai-service` | Groq LLM + Trích xuất trích đoạn | HTTP POST (Timeout 3s) | Hoàn chỉnh; chuẩn hóa `RagFeedbackEnvelope` |
| **Grammar Explain/Detect**| `ai-service` | Groq + Qdrant `grammar_knowledge` | REST API | Hoàn chỉnh; hỗ trợ batch-explain với semaphore |
| **Question Autogen** | `ai-service` | Groq LLM server-side template | REST API | Hoàn chỉnh; kiểm soát chặt định dạng JSON |
| **AI Study Insights** | `attempt-service` | Azure OpenAI (`gpt-4o-mini`) | Azure OpenAI SDK | Hoàn chỉnh; kết quả xuất ra bằng tiếng Việt |

---

## 5. Các Đặc Điểm Thiết Kế Đáng Chú Ý

1. **Khả năng chịu lỗi & Không gây nghẽn (Fail-Open / Non-blocking)**:
   - Cuộc gọi RAG Explainer trong lúc nộp bài trắc nghiệm có timeout nghiêm ngặt (3s). Nếu AI chậm hoặc gián đoạn, bài thi vẫn được lưu và tính điểm bình thường mà không làm đứng giao diện người dùng.
   - Các tác vụ so sánh bài viết (`compare`) chạy bất đồng bộ qua message queue, đảm bảo học viên nhận điểm ngay trong vòng 2–4 giây.
2. **Kiểm soát chi phí & Tốc độ suy luận**:
   - Sử dụng Groq cho hầu hết các tác vụ LLM giúp thời gian phản hồi ở mức dưới 1.5 giây.
   - Bắt buộc chạy Ollama BGE-M3 trên CPU để khắc phục hoàn toàn lỗi crash NaN trên CUDA.
   - Hệ thống xoay vòng key tự động xử lý mượt mà giới hạn TPM/RPM của Groq.
3. **Phòng chống ảo giác điểm số (Anti-Hallucination Band Clamping)**:
   - Trước khi đưa bài văn vào RAG và chấm chi tiết, module ước lượng band chạy model xlarge độc lập không tham chiếu ngữ cảnh để thiết lập trần điểm (ceiling). Nhờ đó, một bài văn Band 3 không thể bị phóng đại lên Band 6 do ảnh hưởng của bài mẫu band cao trong RAG.
