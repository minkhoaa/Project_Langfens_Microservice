# Hướng dẫn thực thi cho AI coding agent

## 1. Operating rules

Làm trong repository thật, đọc AGENTS.md và existing conventions trước. Dùng master plan và file phase làm source of truth. Tài liệu kiến trúc đầu vào mô tả hệ thống; code khảo sát G00 quyết định schema/path thực tế. Không giả định file, endpoint, test script hoặc database column đã tồn tại.

Không bắt đầu bằng xóa legacy. Tạo new capabilities → regression/quality/contract evidence → staged migration → cutover → delete. Không nâng framework/SDK/model ngoài scope nếu chưa có compatibility reason. Tận dụng workers/lease/database có sẵn.

Mỗi phase phải thực hiện code thật, meaningful tests và reports; không kết thúc chỉ ở skeleton/TODO, và không stamp PASS cho lệnh chưa chạy. Missing credential/input được báo cụ thể; tiếp tục independent coding có thể làm, nhưng không promote required dependency chưa đạt.

## 2. Prompt khởi động đầy đủ

> Bạn đang refactor Langfens Generation Service sang Loop Engine V2. Đọc `00-master-plan.md`, `01-validation-matrix.md`, `04-source-traceability.md`, toàn bộ AGENTS.md áp dụng và `phases/phase-00-discovery-baseline.md`. Bắt đầu Phase 00; khảo sát repository, bind paths/schemas/symbols, dựng regression baseline và gate evidence. Giữ public API, NDJSON consumer, section policies, source protections, .NET durable worker, Draft/Publish và manual CRUD. Chưa xóa legacy. Hoàn thành từng work package và T00 tests có thể chạy, ghi command/exit code/SHA/fixtures hashes. Nếu repo khác tài liệu, ghi observed/documented/proposed, giải quyết invariant bằng ADR thay vì bịa. Chỉ G00 PASS khi có test evidence đầy đủ; thiếu repo thì BLOCKED_INPUT. Sau đó tiếp tục phase tiếp theo theo dependencies và scope đã được ủy quyền. Không gọi cloud nếu chưa có configured credential/allowed budget. Không báo pass khi tests bị skip hay evaluator lỗi. Bàn giao phase report có changed files, checks, limitations, rollback và exact next actions.

Đây là prompt thực thi khi người dùng có repo, không phải claim repo đã được khảo sát trong bộ tài liệu này.

## 3. Template prompt cho phase N

> Thực hiện Phase NN theo `phases/phase-NN-...md` tại release branch/worktree đang dùng. Đọc predecessor gate.json, kiểm tra commit/config/corpus version còn hợp lệ. Liệt kê impacted symbols và caller contracts trước chỉnh sửa. Hoàn thành tất cả work packages; dùng canonical contracts, durable artifact client, provider gateway và generic LoopRuntime. Không thêm orchestration/retry loop thứ hai. Viết tests TNN-xx có assertion về outcome/invariants, chạy required checks và impacted regressions. Lưu evidence thật vào `artifacts/refactor/phase-NN/`; cập nhật deletion inventory/ADR. Gate PASS chỉ khi required tests đầy đủ và dependencies đạt. Nếu external checks thiếu, ghi NOT_RUN_EXTERNAL và tiếp tục việc độc lập, không giả kết quả. Không xóa implementation cũ trước G15. Cuối phase báo behavior changed, files, validation, remaining blockers và next phase.

## 4. Chu trình mỗi phase

1. **Preflight:** SHA/worktree sạch hoặc biết rõ changes của user; read instructions; predecessor gates và config/schema compatibility.
2. **Bind plan:** PNN task→actual path/symbol; TNN test→actual test name/command; cập nhật inventory nếu path khác.
3. **Implement:** changes cohesive, exact version refs, scoped repair, authenticated/fenced checkpoints và atomic budget grants.
4. **Verify:** run meaningful unit/contract/integration/quality/fault checks theo manifest; không thêm tests chỉ mirror implementation.
5. **Record:** commands/exit codes/reports/hashes; explain skipped tests; no secrets/raw reasoning.
6. **Gate:** tổng hợp đúng PASS/BLOCKED/NOT_RUN_EXTERNAL; kiểm tra resume/rollback; handoff.

## 5. Kiểm định trước review

- DTO cross-language dùng cùng schema và type semantics; no missing null/Unicode/date handling.
- Every provider call có operation reservation và deadline; mọi accept có exact dependencies/required evaluations.
- Evaluator ERROR và unsupported claim fail-closed; NG absence semantics được xử lý riêng.
- Passage/group sửa làm impacted questions stale; unrelated accepted refs không thay.
- Stream completion dựa durable event/job, không dựa EOF hoặc progress message.
- Cloud call unknown outcome không bị gọi exactly-once; DB final graph idempotency được test thật.
- In-flight run pin versions; cache keys đủ configs; source license/provenance/SSRF không bị mất khi migration.
- Legacy deletion exact paths có caller/behavior/drain evidence; boundary compatibility adapter còn cần thì giữ.

## 6. Khi có vấn đề

Fixture sai → sửa annotation/fixture với rationale, không sửa validator để ăn gian. Code sai → fix rồi rerun impacted tests. Live model quality thấp → giữ gate blocked, benchmark candidate offline, không đổi prompt production tự động. Chưa có permission deployment theo repo → hoàn tất reviewable code/reports rồi làm release approval ở đúng bước. Không cần approval riêng để viết plan hoặc thực hiện read-only/reversible work trong scope đã cho.
