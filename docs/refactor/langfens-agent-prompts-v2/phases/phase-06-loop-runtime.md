# Phase 06 — Bounded runtime, issue ledger và caps thực sự

Phụ thuộc: G02–G05. Gate: G06.

Work packages: P06-01, P06-02, P06-03, P06-04, P06-05, P06-06, P06-07, P06-08.

Test IDs: T06-01, T06-02, T06-03, T06-04, T06-05, T06-06, T06-07, T06-08.

## Prompt A — Thực hiện, remediation và caps hotfix

```text
Hoàn thành/sửa Phase06 Langfens gồm runtime và runtime caps Settings→deployment→composition→persisted snapshot. Đọc AGENTS.md/CLAUDE.md, master, Validation Matrix, Phase06 gốc, G02–05/current G06 evidence, caps ADR và 03-OUTPUT-AND-GATE-CONTRACT.md. Chưa làm Phase07 quality capabilities hoặc cutover.

Long-running reproduce→fix→test→independent verify→fix findings→rerun. Spawn khi khả dụng: runtime/ledger writer, config/persistence integration writer, fault/test engineer, read-only reviewer scopes riêng. Supervisor integrate shared files tuần tự, isolate DB sessions, await exits và update resume. Không kết thúc vì tests vẫn fail mà chưa xử lý fix khả thi.

Discover Settings/deploy resolver/composition roots/gateway/grant/journal và exact test targets. Bind P06-01..08: context; state machine/cursor; controller; durable ledger; intent/ack step journal; termination; dependency validator; capability interfaces. Pin dirty-code/config/fixtures hashes; check upstream evidence compatibility.

Implement một LoopRuntime cho generate/evaluate/decide/repair/terminal, domain agnostic. Capabilities injected, không recursive retries/mutation. Context pin run/exact inputs/scope/authority/policy/budget. Every side effect intent+reservation trước send, cursor advance sau durable ack. Replay committed operation không repeated work/reservation/version.

Controller PASS chỉ fresh exact dependencies + all required evaluations PASS + zero unresolved blockers. Local allowlisted fix đủ budget→REPAIR; unusable artifact nhưng valid source→REGENERATE; source insufficient/uncertain exhausted repair→ESCALATE; cancel/stale authority/deadline/cap/critical unsalvageable→FAIL. ESCALATE không accepted Draft. Soft averages không che blocker. Missing/error/unsupported evaluator không empty-issue PASS.

Ledger fingerprints/lifecycle durable: issue cũ không disappear chỉ vì evaluator omit; resolution cần fresh corresponding evaluation hoặc explicit supersession/invalidation. Repair immutable version, dynamic dependency closure stale trước re-evaluation. Journal/counters survive kill/resume.

Caps inventory bắt buộc: generations/repairs/total versions, runtime steps/no-progress/oscillation, transport attempts, calls/tokens/output cap, per-artifact/section/run/concurrency/candidate pool và deadlines. Units/count semantics tách generation vs repair, network vs domain attempts, reservation/reported/estimated/unknown. Các3-generated/2-repair/2-no-progress trong plan chỉ proposals.

Profile có nguồn quyết định rõ: dùng approved versioned profile hiện có nếu đủ evidence; nếu chưa có, task này giao supervisor chốt profile mới trong scope code/config reversible bằng explicit values/ADR/rationale và boundary tests. Starting 3-generated/2-repair/2-no-progress phải khai báo như quyết định mới, không giả defaults đã approved từ trước. Remaining caps có concrete values từ budget/deadline/feasibility evidence, được pin trước measurement.

Phân biệt rõ ràng giữa production caps và benchmark caps (chính sách mặc định toàn hệ thống):
- Profile production và các provider khác giữ nguyên hard caps nghiêm ngặt (15 calls / 60,000 tokens / 300s).
- Đối với MiniMax BENCHMARKS, toàn bộ application-imposed call, cumulative token, monetary và wall-time caps bị vô hiệu hóa ở cả campaign và child-run level (cấu hình explicit unlimited; ngăn chặn tuyệt đối fallback về 15 calls / 60k tokens / 300s).
- Live benchmarks tự động khởi chạy và resume bằng provider MiniMax đã cấu hình; loại bỏ phê duyệt thủ công của operator, authorization-file, phê duyệt campaign-budget hay chờ PENDING_AUTHORIZATION.
- Duy trì xác thực service, CAS/fencing, cancellation, truthful usage accounting, checkpoints, idempotent resume, bounded retries và per-request limits; tôn trọng giới hạn thực tế phía provider.
- Tách biệt phục hồi cục bộ và gate: R05 durability trên PostgreSQL thật có thể PASS độc lập trong khi G09 vẫn giữ nợ chất lượng upstream/live-quality (G07/G08 prerequisites); tuyệt đối không promote gate chỉ vì đã dỡ bỏ rào cản phê duyệt.
Typed Settings validate missing/empty/nonfinite/nonpositive/bad types/child-parent relations. Production không fallback silent development defaults. Khai báo trong effective deploy resolver, không chỉ .env.example. Trace injected policy từ composition tới runtime/gateway/budget admission; redacted effective dump/profile version/hash. Cap mới không tồn tại chỉ trong class.

Persist effective caps snapshot/version/hash/source khi run tạo, counters/grants transactionally. Resume dùng snapshot cũ dù env đổi; new config chỉ new runs. Old run thiếu snapshot có compatible migration/pause, không fabricate lịch sử từ current env. Backoff/timeouts/concurrency dùng remaining parent deadline/budget. UNKNOWN_OUTCOME không refund/free retry; accepted-output reuse vẫn authority check.

Chạy T06-01..08: five decisions; identical repair stagnation; A→B→A/issue churn finite; critical vs soft; missing/exception/malformed; kill every state/resume; stale descendants; cancel/takeover pre-accept. Finite-sequence/property coverage chứng minh termination trong caps; pure runtime no cloud, transaction tests real PostgreSQL.

Thêm IDs riêng cho caps: startup invalid; env injection thay behavior; N/N+1; concurrent reservations; restart pinned profile/counters; replay no double count; deadline+backoff. Run impacted G02/G03/G05. Report chính xác test ID còn thiếu trong51/52 nếu vẫn áp dụng, không suy đoán hay stamp PASS.

Lưu transitions/ledger/journal/caps/closure/fault evidence và contract bundle artifacts/refactor/phase-06/. Tách configured/validated/enforced vs actually deployed. G06 PASS khi required runtime/config evidence đủ; external G03 exception đúng contract không waive other checks. Hand off fixes/remedy/next commands và Phase07 readiness, không gọi skeleton đã chứng minh chất lượng IELTS.
```

## Prompt B — Verify độc lập và đóng findings

```text
Verify G06 độc lập theo Phase06 gốc, Validation Matrix, upstream evidence/caps ADR và 03-OUTPUT-AND-GATE-CONTRACT.md. Reviewer khác implementation author; supervisor sửa findings, reviewer rerun impacted checks, không report-only handoff nếu fixes nội bộ khả thi.

Trace actual Settings→deploy resolver→composition→runtime/gateway/admission→durable caps snapshot/counters. Field tồn tại/.env.example/class defaults không proof production configuration. Redacted effective hashes/source versions phải match execution. Missing/invalid production caps fail startup, no silent dev fallback.

Chạy T06-01..08:
01 PASS/REPAIR/REGENERATE/ESCALATE/FAIL transitions/reasons đúng.
02 same-hash repair stagnation bounded.
03 oscillation/churn terminate finite caps.
04 critical blocker không soft-score override.
05 required missing/error/malformed non-pass và durable record.
06 kill each durable state resume, no repeated committed work/reset budget.
07 passage changed làm exact descendants stale, section no PASS.
08 cancel/takeover trước accept reject stale commit.

Chạy caps regression IDs riêng: change env changes admission, N/N+1, parallel races, deadlines including waits, pinned profile/counters sau environment change/restart, replay accounting và UNKNOWN_OUTCOME. Kiểm tra total versions gồm repairs/transport semantics/candidate parent allocations. Pure tests fake cloud; transaction/fencing/resume real PostgreSQL harness.

Audit single control flow/capability imports, dynamic closure, ledger omission, atomic cursor/grants/ack. Required evaluator unsupported/missing không PASS; cache không writer authority. Old snapshotless run behavior explicit, no current-env historical fabrication.

Run impacted G02/G03/G05 checks; exact mapping/counts/exits và finite/property state coverage. Xác minh remaining ID nếu report51/52 còn referenced. External smoke exception không override failed internal tests hoặc config thiếu.

Mỗi blocker có proven repro/root cause hoặc discrimination, concrete fix/config decision/file scope, acceptance/regression/next command. Supervisor fix/rerun và khai báo profile còn thiếu trong scope được giao. Chỉ nếu explicit external approval thực sự bắt buộc theo repo/session, ghi rule/source và exact reviewable values/rationale cần chốt; không vague “cần production config”.

Lưu independent report/output bundle và canonical G06. Tách declaration/validation/enforcement/deployment observation. Local production-mode tests không actual deployment. G06/Phase07 readiness theo required evidence, coding-only exception ghi riêng. Không model-quality certification từ skeleton tests.
```
