# Prompt nghiệm thu cuối — Independent audit và corrective handoff

---

Bạn là independent release reviewer của Langfens Loop Engine V2. Thực hiện final acceptance audit trên repository/candidate thực sự. Đọc applicable AGENTS.md/CLAUDE.md, plan/master/Validation Matrix/all phases, canonical manifest, caps ADR, release/deletion/rollback evidence và `03-OUTPUT-AND-GATE-CONTRACT.md`.

Reviewer không sửa business implementation để tự biến findings thành PASS. Supervisor/test owner nhận corrective tasks, sửa và đưa consistent snapshot mới cho reviewer retest. Task chỉ kết thúc khi đạt hoặc blocker thực sự có executable remediation/checkpoint; không giao mỗi báo cáo lỗi.

## 1. Snapshot và gate coverage

Pin candidate HEAD, dirty/untracked hashes nếu chưa commit, image/config/policy/caps/prompt/evaluator/model/schema/corpus versions. Verify all G00–G15 và 124 test IDs gốc cộng additions; giữ planning manifest khác execution results.

Mỗi required ID phải map executable node/check, command, result, exit code, case count và evidence thật. Detect missing IDs/zero collected/unexpected skips/stale SHA-config/phantom background sessions. Report IDs và test cases riêng. Reuse evidence chỉ khi compatible; rerun invalidated required release checks trên candidate cuối.

## 2. Actual architecture và output chain

Trace public/internal entrypoints và workers qua source ingestion/security/provenance → evidence → blueprint → passage → candidates → blind/adversarial review → section → paper → final .NET validation/transaction.

Một canonical model/policy layer, một bounded runtime/control flow, required registry coverage và shared gateway. Không direct SDK bypass, nested unaccounted retries hoặc classes chỉ được fake unit tests sử dụng. Production Settings/deploy resolver injection/caps snapshot đi tới actual execution.

Every acceptance có exact fresh parent refs/evals và zero ledger blocker; missing/error/unsupported type/incomplete coverage không PASS. Passage word/style/grounding checks support PASSAGE, kiểm tra toàn factual coverage với independent approved sources kể cả unaligned/rhetorical attacks. No generated-text self-grounding. NO/NG relation semantics và serialized blind input phải đúng.

## 3. Durability, budgets, locality

Run kill/replay/resume/unknown provider outcome/cancel/lease takeover/source replacement/version-change cases. Real PostgreSQL/service-boundary evidence, authority/CAS/idempotency constraints và checkpoints kiểm tra trực tiếp.

Không lost committed work, stale writer accept, duplicate final exam, quota reset/double counting hoặc unsafe refund unknown outcome. Repair giữ unrelated accepted refs, invalidates correct consumer closure và re-evaluates required scope. Trim/word count repair không invent facts/cắt ngang câu/giữ unsupported outcome sau đổi modal.

## 4. Compatibility và E2E

Source→3 sections→40 contiguous questions→Draft→admin edit/feedback→manual Publish→attempt/grading compatibility theo affected shared contracts. Types/counts/passage/full-paper ranges theo plan đạt 100% accepted-graph fixtures.

Verify public routes/media/null/errors, .NET NDJSON chunks/UTF8/dedupe/disconnect/reconnect/backpressure, gateway/frontend polling/Retry/NeedsSources/Replace Sources và manual CRUD. EOF/progress không được giả completion; generation không auto-publish. Redaction/privacy không lộ keys/hidden reasoning qua errors/logs/metrics/student views.

## 5. Clean quality và operations measurement

Source-family/near-duplicate-clean frozen datasets; enough minimum cases/valid denominators; annotation provenance/review limitations thật. Tested evaluator/heuristics không được tự làm gold labels. Known leaked measurement invalid, holdout không dùng tuning/examples.

Apply Validation Matrix: critical canaries100%; semantic recall≥95% tổng và≥90% per type; ambiguity recall≥90%; false rejection≤10%; repeated critical runs≥3 với aggregate/worst run. Report confusion matrices/denominators và no unsupported accepted canaries.

Paired release benchmark≥18 papers/engine và≥6 source triples, consistent conditions, actual valid-Draft rate/fidelity/ambiguity không kém legacy theo rubric. P95 latency≤1.5× legacy và hard deadline; median cost/token≤2× theo accounting policy. Report distributions/sample size/unknown usages và limitation, không statistical superiority claim từ mẫu nhỏ.

Smoke không thay semantic benchmark; real DB + fake provider không thay live quality.
Benchmark campaigns tự động khởi chạy và resume bằng provider MiniMax đã cấu hình (loại bỏ phê duyệt thủ công, authorization-file, duyệt campaign-budget hay chờ PENDING_AUTHORIZATION). Vô hiệu hóa application-imposed caps cho MiniMax benchmarks ở cả campaign và child-run level (cấu hình explicit unlimited; cấm fallback về 15 calls / 60k tokens / 300s; production profiles giữ nguyên).
Duy trì xác thực service, CAS/fencing, cancellation, truthful usage accounting, checkpoints, idempotent resume, bounded retries và per-request limits. Tách biệt phục hồi cục bộ (R05 durability PASS trên PostgreSQL thật) khỏi gate tổng thể (G09 nợ live quality upstream); không promote gate chỉ vì dỡ bỏ rào cản phê duyệt. Chính sách này áp dụng mặc định cho tất cả các phase.
## 6. Feedback, cleanup, canary và rollback

Durable edit capture/curation/export/split/offline comparison/reviewed version promotion; new runs vs in-flight pins đúng. Raw admin edits không tự deploy prompt/model hoặc thành gold.

Deletion inventory có exact responsibility transfer, callers/DI/imports, behavior tests, old data compatibility và drained-run proof. Zero executable obsolete pipeline refs, historical docs allowlist; live boundary adapters/readers giữ khi cần.

Rollback pinned image trên current additive schema có rehearsal/checkpoint/feedback proof. Actual canary stage/sample/time-window criteria đã pin trước rollout; production access/authorization/observation được xác nhận thật. Staging hay synthetic tests không thay production observation. Nếu chưa thực hiện, status chưa PASS với exact operational remedy, không sleep24h hoặc tạo số liệu giả.

## 7. Findings thành executable repair tasks

Với mỗi defect: ID/severity/invariant, repro command + expected/observed, root cause/evidence, exact owner/file/symbol fix scope, regression/quality checks và acceptance. Supervisor thực hiện fixes và cung cấp snapshot mới; reviewer rerun impacted checks và update closure.

Với external blocker: exact input/environment/quota/authorization thiếu, work đã chuẩn bị, safe setup location, next command và bounded resume plan. Không gọi code/harness missing là external. Nếu bế tắc nội bộ, giao next experiment/technical decision với attempts đã thử, không false-PASS/false external.

## 8. Final acceptance output

Lưu final independent report, canonical gate reports, fix closure, commands/exit codes, snapshot/fixture/campaign/image hashes, benchmark/chaos/deletion/canary/rollback evidence và reproducible references. Reports/link targets phải tồn tại.

Kết luận riêng:
- Implementation scope complete.
- Required deterministic/integration/semantic release candidate checks verified.
- Staging readiness.
- Actual production deployment/canary status.
- Overall acceptance PASS/BLOCKED và next executable action.

Overall PASS chỉ khi all required conditions đạt trên candidate cuối. Khi còn blocker, evidence/report chính xác là bắt buộc, nhưng supervisor còn phải giải quyết công việc trong quyền/công cụ/budget và bàn giao remedy cụ thể cho phần chưa đạt.
