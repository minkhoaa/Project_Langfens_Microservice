# PLAN — Tách autonomous exam generation khỏi ai-service

## Mục tiêu và phạm vi

Tạo một `generation-service` độc lập để sở hữu **toàn bộ** luồng tạo đề: tiếp nhận yêu cầu Admin, tìm/nhập nguồn, sinh nội dung, kiểm định, review/repair, lưu job và checkpoint, rồi yêu cầu exam-service nhập nội dung đã duyệt (Reading Paper thành Draft; question batch vào Exam/Section đích theo quy tắc hiện hành). Không chỉ chạy thêm một replica của `ai-service`: cách đó không chuyển được job/worker đang ở exam-service và không giải quyết đường tạo câu hỏi từ trình duyệt.

Phạm vi cutover là hai luồng **đang có**: `question_batch` (AI authoring trong Admin) và `reading_paper` (1–3 sections). Tài liệu dự kiến bốn kỹ năng không đồng nghĩa Listening/Writing/Speaking đã có pipeline hoàn chỉnh. Các kỹ năng đó chỉ mở rộng sau khi có blueprint, validator, media/rubric và bộ đánh giá riêng; không dùng một prompt tổng quát làm điều kiện phát hành.

## 1. Hiện trạng và bản đồ cutover

### Các endpoint AI phải xử lý dứt điểm

| Endpoint hiện tại ở ai-service | Caller hiện tại | Thay thế và điều kiện gỡ route cũ |
| --- | --- | --- |
| `POST /api/v1/autogen/questions` | FE `admin/_lib/aiConfig.ts` → `questionGeneration.ts` qua gateway `/api-ai/v1/autogen/questions`; ngoài ra có lựa chọn gọi provider trực tiếp từ browser | `POST /api-generation/v1/jobs` với `kind=question_batch`; gỡ sau khi `AiAuthorModal`/`QuestionEditor` đọc job mới, modal nhập batch nguyên tử và xóa browser-provider path (bước 4–5). |
| `GET /api/v1/autogen/reading-paper/sources` | `exam-service/Features/ReadingPaper/ReadingPaperAiClient.cs` | Generation API `GET /sources`; gỡ sau khi FE search qua generation gateway và exam Admin source proxy không còn caller (bước 4–5). |
| `POST /api/v1/autogen/reading-paper/source` | `ReadingPaperAiClient.cs`, fetch PMCID khi tạo/thay nguồn | Generation API `POST /sources/resolve` và snapshot trong job; gỡ sau khi Create/Replace không còn nhờ exam-service fetch và worker cũ đã drain (bước 4–5). |
| `POST /api/v1/autogen/reading-paper/source/ingest` | `ReadingPaperAiClient.cs`, nhập custom URL/text/HTML/Markdown | Generation API `POST /sources/ingest`; gỡ sau khi FE/worker dùng nguồn generation và exam proxy bị xóa (bước 4–5). |
| `POST /api/v1/autogen/reading-paper/section` (JSON hoặc NDJSON progress) | `ReadingPaperAiClient.cs` từ `ReadingPaperWorker` | Hàm nội bộ generation-worker với progress/checkpoint trong generation DB; gỡ HTTP route sau khi worker exam cũ drain và FE đọc tiến độ từ job API (bước 3–5). |

`ai-service/app/main.py` hiện vẫn include các router này. `autogen.py` import `app.services.autogen_loop` không tồn tại trong checkout, trong khi test đang kỳ vọng `app.generation_main` cũng chưa tồn tại; smoke import router trước đó đã lỗi `ModuleNotFoundError`. Đây là trạng thái code đang dở cần đối chiếu trước khi coi baseline là chạy được, không phải lý do để giữ hai runtime generation song song.

### Các endpoint và caller ở exam/FE phải chuyển

`ReadingPaperEndpoints.cs` hiện phục vụ Admin `GET /admin/reading-paper/sources`, `POST /admin/reading-paper/sources/ingest`, `POST /admin/reading-paper/jobs`, `GET /admin/reading-paper/jobs`, `GET /admin/reading-paper/jobs/{id}`, `PUT /admin/reading-paper/jobs/{id}/sources`, `POST /admin/reading-paper/jobs/{id}/retry`. `readingPaperApi.ts` và trang Admin Reading Paper dùng các thao tác này. Search/ingest và toàn bộ job API chuyển sang generation-service; exam-service không còn proxy source hoặc sở hữu `ReadingPaperJob` mới. List/get phải tiếp tục hiển thị trạng thái, log, nguồn và `examId` của job cũ theo ID/đường dẫn Admin hiện có qua mapping sang lịch sử generation; không cắt giao diện trạng thái khi đổi owner.

`AiAuthorModal.tsx` hiện gọi generate rồi `persistGeneratedQuestions` tạo question/option **tuần tự** qua exam Admin API: đổi sang preview job và nhập batch nguyên tử sau khi Admin duyệt. `QuestionEditor.tsx` hiện dùng kết quả AI để điền form: vẫn giữ thao tác sửa/lưu thủ công của editor, nhưng lấy kết quả qua job mới. Xóa lựa chọn gọi Anthropic/OpenAI trực tiếp từ browser và `NEXT_PUBLIC_AI_API_KEY`; provider credentials chỉ ở worker. Gateway route Admin `ai-autogen-admin` `/api-ai/v1/autogen` phải được loại bỏ sau cutover; route `/api-ai` cho chức năng AI khác giữ nguyên.

## 2. Ranh giới hệ thống

```text
Admin UI ──JWT──> Gateway /api-generation/v1 ──> generation-api ──> generation-db
                                                    │                      ↑
                                                    └── enqueue job ───────┤ lease/checkpoint
                                                                           generation-worker
                                                                             │ sources/providers
                                                                             └── authenticated import
                                                                                     ↓
                                                                                 exam-service ──> exam-db (Reading Paper Draft / question batch)
```

- **Generation API/worker:** cùng một image Python nhưng hai process/deployment độc lập để scale và giới hạn concurrency riêng. PostgreSQL riêng giữ job, source snapshot, artifact có phiên bản, event/log, lease, mức dùng provider và `examId` trả về. Với tải Admin ban đầu, claim job bằng transaction/lease PostgreSQL (`SKIP LOCKED`) và heartbeat là đủ; chỉ thêm broker khi có bằng chứng throughput cần thiết. Worker không ghi exam DB, không gọi lại router generation qua HTTP, không phụ thuộc runtime `ai-service` để tạo đề.
- **Exam-service:** nguồn dữ liệu chuẩn cho exam/question/option, các validator và trạng thái Draft/publish. Thêm internal import cho Reading Paper và question batch; kiểm định lại toàn bộ payload, ghi graph trong một transaction. Import yêu cầu xác thực service-to-service, không expose qua public gateway. Giữ nguyên quyền Admin publish; generation không được tự publish.
- **Gateway/FE:** chỉ gateway Admin expose generation API và cả generation-service cũng xác thực quyền Admin. Job list/status/preview không lộ prompt nội bộ, API key hoặc dữ liệu nguồn không được phép công bố.

## 3. Hợp đồng đề xuất

Định nghĩa OpenAPI và schema có `contractVersion` trước khi chuyển caller; các path sau là **đích đề xuất**, không phải endpoint đã tồn tại:

- `GET /api-generation/v1/sources` (search), `POST /api-generation/v1/sources/resolve` (PMCID), `POST /api-generation/v1/sources/ingest` (custom). Một source record có identifier/URL, license, thời điểm truy xuất, hash và snapshot để retry không âm thầm đổi đầu vào. Xác minh quyền sử dụng và chặn truy xuất URL nội bộ/redirect không an toàn trước khi fetch.
- `POST /api-generation/v1/jobs` (`kind`, blueprint/input, target Exam/Section nếu là question batch), `GET /jobs`, `GET /jobs/{id}`, `PUT /jobs/{id}/sources`, `POST /jobs/{id}/retry`. Thay nguồn phải **persist nguồn mới rồi mới reset checkpoint**; endpoint `ReplaceSources` hiện tại reset trạng thái nhưng không gán nguồn mới vào `SourcesJson`, không được sao chép lỗi này. Sau khi Draft đã được nhập, thay nguồn phải tạo job mới, không ghi đè lịch sử đã import.
- `POST /jobs/{id}/approve` cho question batch, kèm revision dự kiến và nội dung đã được Admin chỉnh sửa (nếu có); generation lưu revision được duyệt, kiểm định lại và chỉ import revision đó. QuestionEditor có thể đọc artifact để điền form mà không gọi approve. Reading Paper đạt đủ điều kiện có thể tự import **Draft**, sau đó Admin review/publish theo quy trình hiện tại.
- `POST /internal/generated/reading-papers` và `POST /internal/generated/question-batches` ở exam-service. Request gồm `originJobId`, `artifactVersion`, payload/hash và provenance cần lưu; exam trả `examId` hoặc batch result. Unique constraint trên `originJobId` (theo loại import): retry cùng payload trả cùng kết quả, khác hash trả conflict. Nếu worker chết sau commit nhưng trước khi lưu response, retry không sinh bản sao. Question batch nhập questions/options trong một transaction, giữ các điều kiện exam hiện có (ví dụ Listening cần `AudioUrl`).

Job state tối thiểu: `queued → running → importing → completed` cho Reading Paper (kèm `draftExamId`), hoặc `queued → running → needs_review → importing → completed` cho question batch; lỗi chuyển `failed` có diagnostics và khả năng retry theo policy. Lưu checkpoint từng section/nhóm câu, artifact hash/version, attempt, prompt/model/validator version, token/cost/call count, trace ID, creator, timestamps và kết quả import. Worker dùng lease/heartbeat có recovery; thao tác resume không chạy lại phần đã chốt trừ khi input/blueprint đổi.

Mỗi lần claim job tăng `leaseEpoch` đơn điệu. Mọi checkpoint, finalization artifact và yêu cầu import mang `jobId + leaseEpoch + owner + artifactHash`; cập nhật generation DB dùng CAS `WHERE leaseEpoch = expected AND owner = expected AND leaseUntil > now()`. Chỉ artifact final đã commit dưới CAS được import; exam-service đối chiếu epoch/hash với final artifact hiện hành qua kênh nội bộ trước khi commit và từ chối token cũ. Idempotency theo `originJobId`/hash vẫn cần nhưng **không thay thế fencing**: worker hồi sinh sau khi hết lease không được ghi đè artifact hoặc nhập bản cũ của owner mới.

## 4. Loop engineering và chất lượng

Cho từng loại đề, định nghĩa blueprint/validator riêng thay vì chỉ mở rộng prompt:

1. **Acquire & plan:** chuẩn hóa yêu cầu, chọn nguồn, kiểm tra license/provenance, cố định source snapshot, sinh cấu trúc theo blueprint.
2. **Generate:** tạo từng section/nhóm câu thành artifact riêng; không sinh lại cả đề khi chỉ một nhóm sai.
3. **Deterministic validate:** JSON/schema, số lượng và loại câu, độ dài, answer/options/evidence, ràng buộc source. Reading Paper phải giữ quy tắc hiện có: 1–3 sections, phân bố nhóm `[7+6, 6+7, 7+7]`, 13/26/40 câu, passage 720–915 từ/section và các điều kiện nguồn/đáp án trong `ReadingPaperRules`. Exam-service vẫn kiểm tra lại ở import.
4. **Independent review:** reviewer chỉ nhận source và artifact, không nhận lời giải thích của generator; đánh giá fidelity, câu hỏi mơ hồ, đáp án, evidence và độ khó. Có thể dùng model/provider khác khi sẵn có, nhưng không coi một lần self-review là bằng chứng chất lượng.
5. **Targeted repair → revalidate:** sửa đúng phần lỗi, chạy lại deterministic validation và review phần bị ảnh hưởng; giới hạn số vòng, token/cost/calls và wall time **theo job**. Hết budget hoặc không đạt thì `failed`/`needs_review`, tuyệt đối không import payload chưa đạt.
6. **Whole-paper gate:** kiểm tra chéo các sections, trùng nguồn/nội dung, tính đầy đủ và provenance trước khi import Draft. Ghi version của toàn bộ artifact/diagnostics để so sánh chất lượng khi thay model hoặc prompt.

Giữ các kiểm tra source/license, source-fidelity review/repair và answer review đang có trong `reading_paper.py` khi chuyển code; không bỏ đi chỉ để đơn giản hóa service. Chất lượng phải được đánh giá trên bộ đề mẫu và review của người làm nội dung (tính đúng, độ khó, nhiễu, độ trung thành nguồn), ngoài tỷ lệ pass schema.

## 5. Thứ tự migration

1. **Baseline & contract:** kiểm kê job lịch sử/in-flight và hành vi FE; đối chiếu `autogen_loop`/`generation_main` đang thiếu. Chốt schema/version, bộ dữ liệu đánh giá, ngưỡng chất lượng và ngân sách mặc định. Ghi rõ loại source/giấy phép chấp nhận và thời hạn giữ snapshot.
2. **Exam import trước:** triển khai internal import, validator, transaction và unique origin key; kiểm thử payload hợp lệ/sai, duplicate, conflict và crash sau commit. Không dời worker cho tới khi exam import chứng minh parity với cách dựng Draft hiện tại.
3. **Generation runtime:** tạo project/image, generation-db migration, API/worker và job lifecycle; chuyển **cả năm** AI autogen endpoint theo bảng mục 1 (section thành bước nội bộ), provider/source modules và loop. Chạy scenario nguồn → job → checkpoint → import Draft; thử worker restart, lease expiry, lỗi provider và retry.
4. **Chuyển các caller và triển khai:** sửa `readingPaperApi.ts`/page, `aiConfig.ts`, `questionGeneration.ts`, `AiAuthorModal.tsx`, `QuestionEditor.tsx`; bỏ direct provider/browser key và lưu tuần tự ở modal. AppHost hiện chạy cả Next.js qua `AddNpmApp` (port 3000, gateway URL từ resource graph); thêm generation API/worker/database và Admin gateway route vào `AppHost/Program.cs`, cùng Compose/local Compose và secrets/health/OTel riêng. Exam không còn `AI_SERVICE_URL` chỉ để gọi generation; các consumer AI khác giữ cấu hình cần thiết. Cập nhật `docs/standards/reading-paper-workflow.md` và contract FE. Smoke một lệnh `dotnet run --project AppHost/AppHost.csproj`: FE → gateway → generation → exam Draft.
5. **Cutover sạch:** ngừng nhận job ở đường cũ, drain worker cũ trước khi chuyển route; không transplant checkpoint đang chạy giữa hai schema nếu chưa có migration kiểm chứng. Backfill **toàn bộ lịch sử `ReadingPaperJob` cần hiển thị**, gồm ID cũ/mapping, status, source snapshot/metadata, section checkpoints/log, `examId` và thời gian vào generation DB (hoặc archive đọc được bởi API mới). `GET jobs`/`GET jobs/{id}` và retry/replace theo trạng thái phải cho kết quả nhất quán cho cả lịch sử và job mới; kiểm tra deep-link Admin và Draft theo `examId` trước khi bỏ bảng cũ, đồng thời bảo đảm slug/import ID không va chạm. Sau smoke UI, xóa `ReadingPaperAiClient`/worker/job ownership cũ, từng route AI theo bảng mục 1, gateway route cũ, FE legacy config và test/doc đã lỗi thời. Rollback release mới phải giữ generation DB/job mới và không tái chạy worker cũ trên cùng dữ liệu.

## 6. Nghiệm thu và vận hành

- [ ] Qua gateway Admin, tạo/search/resolve/ingest nguồn và tạo Reading Paper; xem tiến độ, thay nguồn, retry; nguồn mới thực sự được dùng sau `PUT .../sources`.
- [ ] Tạo Reading Paper 1, 2 và 3 sections; kết quả hợp lệ sinh **đúng một** Draft theo exam validator; nguồn/license, evidence và đáp án không hợp lệ không sinh Draft.
- [ ] `AiAuthorModal` preview/approve question batch; nhập nguyên tử hoặc không nhập gì. `QuestionEditor` nhận kết quả để chỉnh sửa; không có provider key hay lời gọi trực tiếp provider trong browser.
- [ ] Crash/retry ở mỗi ranh giới checkpoint và sau exam commit không sinh trùng Draft/questions; worker hết lease dù gửi checkpoint/import trễ không thể thay artifact/đề của owner mới nhờ fencing token và CAS; status và `examId` cuối cùng nhất quán.
- [ ] API/worker scale, giới hạn concurrency/budget và quan sát được job ID, trace, model/prompt version, latency, token/cost, validation/review failures; source text/API key không lọt log công khai.
- [ ] Không còn caller của `/api-ai/v1/autogen/*`, bốn reading AI endpoint hoặc exam Admin Reading Paper job/source API cũ; lịch sử `ReadingPaperJob` vẫn xem được qua list/get và deep-link mới; `ai-service` khởi động không cần generation modules. Build/test contract hai service và FE, rồi smoke end-to-end qua gateway/AppHost (cả frontend do Aspire chạy) và kiểm tra Draft thực tế.

**Quyết định mặc định:** một service Python với hai deployment API/worker và PostgreSQL riêng; dùng database queue trước, không thêm RabbitMQ cho job generation khi chưa cần. Ngưỡng chất lượng, budget tiền/token và retention nguồn cần được định lượng từ bộ đề đánh giá trước khi bật tạo đề thật, không dùng con số tùy ý trong prompt.
