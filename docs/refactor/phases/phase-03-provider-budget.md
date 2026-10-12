# Phase 03 — Unified gateway, parsing, retries và budgets

Phụ thuộc: G01–G02. Gate: G03.

Work packages: P03-01, P03-02, P03-03, P03-04, P03-05, P03-06, P03-07, P03-08, P03-09.

Test IDs: T03-01, T03-02, T03-03, T03-04, T03-05, T03-06, T03-07, T03-08.

## Prompt A — Thực hiện và khắc phục

```text
Hoàn thành Phase03 Langfens, giữ legacy parity shim. Đọc AGENTS.md/CLAUDE.md, master, Validation Matrix, Phase03 gốc, G01–02 evidence và 03-OUTPUT-AND-GATE-CONTRACT.md. Không tự thay provider/model/SDK versions hoặc triển khai production.

Làm long-running reproduce→implement→test→review→fix→rerun. Có spawn thì giao adapters/parser, budget/retry integration, test engineer và independent reviewer phạm vi files rõ. Supervisor await tasks, cô lập DB/live benchmark resources, giữ caps và progress/resume theo contract. Đừng dừng vì thiếu parser/harness có thể xây.

Discover gateway/legacy llm callers, actual config/deploy resolution, SDK versions, HTTP transports và scripts; pin dirty snapshot. Bind P03-01..09:
01 protocol; 02 provider/model routing/config; 03 bounded parser; 04 reasoning cleanup; 05 retry; 06 shared persisted budget; 07 cost accounting; 08 typed errors; 09 parity shim/deletion map.

Requests có capability/schema/messages/output cap/timeout/config/prompt/op IDs; responses parsed payload, finish reason, usage reported/estimated/unknown, request ID và latency. Business logic không biết vendor tags. Version models/routing, validate endpoint/credential scope; inspect configured credentials an toàn, không print keys hoặc mặc định thiếu key.

Adapters MiniMax/Groq hoặc providers thực sự được scope hiện tại chọn đều dùng domain semantics chung. Disable SDK/HTTP nested retries tại client factories/clones/options; gateway sole transport retry owner. Legacy wrapper gọi cùng gateway, không xóa wrapper trước migration.

Structured output khi supported; parser bounded cho fences theo policy, reject multiple objects/trailing prose/NaN/wrong schema/oversized/truncated outputs. Parse JSON không chứng minh domain-valid. Reasoning tags xử lý adapter-specific, unclosed/malformed tags không lộ raw thinking trong errors/logs.

Retry cap/profile phải được declared/versioned trong Settings và effective deployment config; 3 attempts trong plan là proposal, không evidence approved production. 401/403/invalid request không retry; transient retry honor Retry-After/backoff+jitter trong deadline, cancellable. Delay không vừa deadline phải typed defer/failure/checkpoint.

Budget run→section→artifact: atomically reserve trước actual send, gồm retries/evaluator/candidates; persist via G02. Parent không oversubscribe concurrent requests. Completion limit gồm reasoning khi provider tính vậy. UNKNOWN_OUTCOME giữ conservative reservation; restart/replay không reset. Missing usage unknown, không0. Dollar hard cap chỉ claim khi pricing snapshot/bounded accounting đủ; estimates không billed actual.

Chính sách benchmark MiniMax tự động và caps (mặc định toàn hệ thống):
- Live benchmarks bắt buộc tự động khởi chạy và resume bằng provider MiniMax đã cấu hình; loại bỏ hoàn toàn phê duyệt thủ công của operator, authorization-file, phê duyệt campaign-budget hay chờ PENDING_AUTHORIZATION.
- Vô hiệu hóa toàn bộ application-imposed call, token, monetary và wall-time caps cho MiniMax BENCHMARKS ở cả campaign và child-run level (cấu hình explicit unlimited; ngăn chặn fallback về 15 calls / 60k tokens / 300s). Production và các provider khác giữ nguyên hard caps.
- Duy trì xác thực service, CAS/fencing, cancellation, truthful usage accounting, checkpoints, idempotent resume, bounded retries và per-request limits; tôn trọng giới hạn thực tế phía provider.
- Tách biệt phục hồi cục bộ và gate: R05 durability trên PostgreSQL thật có thể PASS độc lập trong khi G09 vẫn giữ nợ chất lượng upstream/live-quality (G07/G08 prerequisites); tuyệt đối không promote gate chỉ vì đã dỡ bỏ rào cản phê duyệt. Chính sách này áp dụng mặc định cho tất cả các phase.

Actual composition/client factories phải dùng injected config/gateway, không direct SDK outside providers. New calls fail closed nếu budget/authority thiếu. Keep rate/concurrency buckets/key rotation bounded, không lách account quota.

Chạy T03-01..08: deadline+429; auth/transient attempts; JSON edge cases; cancel backoff/stream; atomic budget race; unknown-outcome resume; adapter recordings/parity/redaction; configured live model smoke. Count requests bằng SDK thật+fake transport để lộ nested retries, không chỉ mocks constructor.

T03-08 chạy nếu approved credentials/env/budget đã có, bounded sample/schema/usage; không hardcode model name. Nếu unavailable, ghi exact external prerequisite/setup+next command. Theo contract, missing smoke không thành live PASS; Phase03 gốc cho downstream coding-only tiếp tục, không cutover hoặc nghiệm thu live dependency.

Sửa failures rồi rerun impacted G01/G02, save sanitized provider/budget/reconciliation recordings và output bundle tại artifacts/refactor/phase-03/. G03 report tách deterministic, config, smoke và live readiness, không waive T03-08 bằng fake calls. Bàn giao routing rollback giữ accounting, fixed findings và next remedy/readiness.
```

## Prompt B — Verify độc lập và đóng findings

```text
Review Phase03 độc lập theo plan, Validation Matrix và 03-OUTPUT-AND-GATE-CONTRACT.md. Đọc G01–02, actual config/client/gateway/transport factories và all call sites. Reviewer không sửa patch mình review; findings có executable remedy để supervisor fix rồi rerun.

Chạy đủ T03-01..08:
01 Retry-After vượt remaining deadline không vượt cap/deadline.
02 401 không retry; timeout/5xx đúng actual transport count/accounting.
03 fenced/malformed/truncated/multiple JSON/NaN đúng parser policy và schema.
04 cancel trong wait/stream dừng, late result vẫn fenced.
05 concurrent near-budget admission atomic, no parent oversubscription.
06 UNKNOWN_OUTCOME giữ reservation/counters sau restart.
07 actual adapter recordings cùng semantics, no key/thinking leaks.
08 configured provider/model live smoke có parsed payload/usage hoặc exact NOT_RUN_EXTERNAL reason.

Dùng SDK thật và fake HTTP transport cho retry counts; kiểm tra with_options/clones/fallback/custom HTTP retry. No direct SDK calls outside providers và legacy shim thực sự dùng gateway. Config trace Settings→deployment→client/gateway→budget snapshot, không class defaults-only.

Review parent counters/cost units/pricing snapshots/unknown reconciliation. Reported/estimated/unknown tách; restart không free retry. Reasoning+visible tokens đúng provider limit semantics; redaction inspect serialized errors/logs, không chỉ redactor unit test.

Run impacted G02 concurrency/replay/auth checks và legacy contract parity. Manifest phát hiện skip/zero/nonzero; count IDs riêng cases. Mỗi finding có repro/root cause/scope/acceptance/next commands; supervisor sửa và reviewer xác nhận snapshot mới.

Lưu output bundle/independent report với hashes và actual exit codes. Deterministic PASS không tự thành live gate PASS. T03-08 external exception cho coding-only phải được ghi, không tự tạo exemption release. G03/live-readiness và Phase04 coding/acceptance readiness tách rõ, blockers kèm setup/remedy cụ thể.
```
