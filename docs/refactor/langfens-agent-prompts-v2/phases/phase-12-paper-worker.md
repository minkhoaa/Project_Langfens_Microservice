# Phase 12 — Paper Loop, .NET worker và final Draft

Phụ thuộc: **G02, G06, G11**. Gate: **G12**. Dùng prompt A rồi B; supervisor xử lý findings và kiểm định lại trước nghiệm thu.

## A. Implementation và remediation

```text
Hoàn thành Phase 12 Langfens Loop Engine V2, gồm sửa findings và retest; chưa làm Phase 13.

Đọc AGENTS.md/CLAUDE.md, master plan, Validation Matrix, Phase 12 gốc và 03-OUTPUT-AND-GATE-CONTRACT.md của Prompt Pack V2. Bind actual paths/scripts/lockfiles. Giữ user changes. Xác minh G02/G06/G11 trên snapshot tương thích; upstream defect thuộc phạm vi sửa phải xử lý, không chỉ chép blocker. External evidence thiếu cho phép coding/test độc lập bằng fakes; chưa accept production artifacts hoặc mở gate.

Supervisor phân công worker Python paper/repair, worker .NET persistence/worker và test engineer theo file ownership; reviewer không viết implementation mình review. Có spawn tools thì chạy agents thật, không có thì làm các vai tuần tự và ghi limitation. Serialize shared edits/DB tests. Theo dõi sessions/tasks tới exit, cập nhật khoảng 60 giây; không fire-and-forget. Tiếp tục reproduce→fix→test→review→fix→retest, không dừng sau report FAIL nếu còn tự sửa được. Long-running agent không tăng production caps.

Map và hoàn thành P12-01..09:
- P12-01: immutable paper snapshot, đúng 3 sections, 40 câu liên tục 1–40; counts 13/13/14 và type distributions theo policy; từng passage 720–915, tổng 2150–2750.
- P12-02/P12-03: cross-section exact/shingle/semantic duplicates, concentration và leakage; version thresholds, phân biệt shared topic/vocabulary với duplicated content.
- P12-04: internal authenticated paper-evaluate/repair capability qua GenerationFacade, bind actual route/DTO với .NET caller; directives có exact refs, issues, preconditions, authority và budget.
- P12-05: item repair rerun affected section + paper; passage flaw invalidate đúng closure. Unrelated refs giữ nguyên, không regenerate toàn paper mặc định.
- P12-06: wire vào worker thật; engine/config pinned, heartbeat độc lập với provider wait; bounded reconnect/retries qua shared gateway/accounting.
- P12-07: reload authoritative heads, check fencing epoch/cancelVersion, fresh required paper evaluations rồi ReadingPaperRules.Validate; failure chặn BuildExam.
- P12-08: .NET final transaction chứa Exam/sections/groups/questions/options, unique run/job→ExamId, Completed và outbox; rollback không half-written graph. Python không ghi Exams trực tiếp; generation chỉ Draft, Publish do admin.
- P12-09: lost ack/replay trả cùng ExamId. Exactly-once là DB final graph, không phải cloud requests; unknown provider outcome giữ reservation.

Giữ canonical contracts, immutable versions, CAS, cancellation, caps snapshot và cache/dependency freshness. Không tạo retry loop hoặc writer store thứ hai.

Implement/map rồi chạy T12-01..08 trên Python+.NET+PostgreSQL thật: numbering; word-policy parity; duplicate/locality; leakage boundaries; stale lease/cancel; transaction failure; post-commit crash/replay; source→Draft→manual Publish/CRUD. Fake provider cho fault injection; live quality evidence riêng theo matrix. Tests dùng real worker/service boundary, không chỉ instantiate PaperLoop.

Fix mọi actionable findings và rerun impacted G02/G06/G11, shared-contract/attempt-grading regressions. Missing harness là việc phải implement, không external blocker. Reviewer verify candidate mới sau fixes.

Lưu artifacts/refactor/phase-12/: gate.json, phase-report.md, native/test-report, commands.jsonl, snapshot-manifest.json, fix-log.jsonl, independent-review.md, resume.md theo canonical schemas. Snapshot gồm HEAD + dirty/untracked hashes, caps/config/model/prompt/corpus versions. Thêm route/DTO wiring trace, SQL constraint/transaction proof, final graph fixtures và repair closure diffs.

G12 PASS chỉ khi required dependencies/checks đạt trên snapshot này. Nếu còn external blocker, hoàn tất phần độc lập, ghi exact missing input, setup an toàn, actual next command, owner, acceptance và capped execution plan. Không yêu cầu paste key vào chat hoặc báo “cần nghiên cứu thêm” rồi dừng. Bàn giao status, fixes, evidence và readiness Phase 13, không tự stamp PASS.
```

## B. Independent verify và vòng sửa

```text
Làm supervisor kiểm định độc lập Phase 12 và điều phối remediation tới kết quả. Đọc plan/matrix/03-OUTPUT-AND-GATE-CONTRACT.md, G02/G06/G11 và implementation evidence; không tin summary PASS.

Spawn reviewer chỉ đọc candidate/write findings và test engineer chạy harness ở phạm vi riêng; owner sửa code. Nếu không hỗ trợ spawn, thực hiện tuần tự và ghi review limitation. Await/poll actual tasks/commands tới exit; findings tự sửa được phải giao fix, retest impacted checks rồi reviewer kiểm định snapshot mới, không kết thúc bằng report-only.

Trace actual .NET worker→authenticated Python facade→checkpoint boundary→reload heads→ReadingPaperRules→final transaction. Kiểm tra code/config hashes, lease/cancel/caps và lineage; reject missing/stale evaluations.

Chạy đủ:
T12-01: 39/40/41, missing/duplicate ordinals; chỉ valid 40 persist.
T12-02: Python/.NET cùng reject sai total/per-section range.
T12-03: duplicate/near-copy repair đúng closure; unaffected hashes nguyên.
T12-04: leakage trong instructions/câu khác, type-aware boundaries.
T12-05: lease takeover/cancel trước commit chặn stale writer.
T12-06: inject DB fault giữa graph creation/job completion; toàn transaction rollback, retry một exam.
T12-07: crash sau commit trước event; polling/replay cùng Draft ExamId.
T12-08: real E2E source→Draft→admin Publish và manual CRUD; impacted attempt/grading contracts tương thích.

Inspect unique constraint và atomic outbox, không chỉ application “check then insert”. Heartbeat phải renew khi provider chậm. Không claim cloud exactly-once. Kiểm tra skip/zero collected/nonzero exit/missing evidence; live benchmark tách fake-provider fault tests.

Lưu canonical evidence bundle phase-12 và independent findings/retest results. Mỗi unresolved blocker có repro, root cause/check phân biệt, fix đã thử, file/symbol work còn thiếu, owner, setup/next command/acceptance. Required failures giữ G12 BLOCKED; external chỉ khi prerequisite thực sự thiếu. Kết luận implementation, integration, live quality và readiness Phase 13 riêng. Chỉ mở gate khi evidence đầy đủ trên candidate cuối.
```
