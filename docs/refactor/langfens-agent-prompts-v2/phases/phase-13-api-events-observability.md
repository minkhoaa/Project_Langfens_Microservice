# Phase 13 — API, events, observability và UI

Phụ thuộc: **G01–G03, G11–G12**. Gate: **G13**. Dùng prompt A rồi B, tiếp tục sửa và retest đến đầu ra đạt.

## A. Implementation và remediation

```text
Hoàn thành Phase 13 Langfens Loop Engine V2, không chỉ report compatibility gaps; chưa làm Phase 14.

Đọc instructions repo, master, Validation Matrix, Phase 13 gốc, G00 contract snapshots và 03-OUTPUT-AND-GATE-CONTRACT.md. Bind paths/scripts/lockfiles thật; giữ user changes. Verify dependencies G01–G03/G11–G12 tương thích với code/config hiện tại; sửa upstream defects liên quan trong scope, không reuse gate chỉ vì HEAD giống.

Supervisor giao workers thin API/event projection và .NET consumer/UI theo disjoint files; test engineer kiểm tra actual transport; reviewer không viết thay đổi đang review. Spawn thật nếu available; nếu không, các vai tuần tự với limitation rõ. Serialize shared writes/DB/ports. Poll/await long-running tasks tới exit, update khoảng 60 giây. Reproduce→implement→test→review→fix→retest liên tục; không dừng sau findings còn sửa được hoặc giả process chạy nền đã PASS.

Map và hoàn thành P13-01..10:
- P13-01: thin public API→GenerationFacade, đúng main registration; route không provider call/policy/retry loop.
- P13-02: GET sources, POST source, POST source/ingest, POST section giữ actual mounts/path, fields/null/status/errors/media type của baseline; không suy đoán route tồn tại.
- P13-03: eventId, per-run sequence từ authoritative outbox, UTC timestamp, runId/operationId, exact artifact ref, schema/engine version, type, sanitized payload.
- P13-04: typed run/artifact/evaluation/issue/decision/section/paper events; Completed chỉ từ durable final fact, không từ progress text/EOF.
- P13-05: legacy projection chỉ phát shape/types old consumer chấp nhận; rich events opt-in/versioned. Test unknown-event behavior thật trước thay parser.
- P13-06: at-least-once replay/dedupe; reconnect cursor theo supported contract. Disconnect/EOF thiếu terminal event là incomplete; reconcile authoritative status trước retry.
- P13-07: bounded buffers/retention/rate, backpressure. Slow client không chặn heartbeat/checkpoint; terminal fact phải truy hồi được.
- P13-08: traces/metrics calls, latency, repairs, issues, exhaustion, stale writers/resume và tokens reported/estimated/unknown; pricing snapshot, không ghi estimated thành billed actual.
- P13-09: secret/reasoning/source redaction, metric cardinality bounded; runId chỉ trace/log với retention, UI errors sanitized.
- P13-10: actual gateway/frontend generation/polling/Retry/NeedsSources/Replace Sources/manual CRUD/Draft/Publish, không percentage giả completion.

Mọi buffer/concurrency/deadline cap mới khai báo Settings/deploy/profile và enforce; pin theo run nơi áp dụng. Giữ authoritative .NET persistence, fencing/cancel/shared budgets, immutable artifacts và living public adapters.

Implement/map rồi chạy T13-01..08: baseline parity, chunked UTF-8/JSON, replay/dedupe, disconnect reconciliation, backpressure/flood, secret canaries, trace/accounting, UI/gateway E2E. Test actual .NET NDJSON consumer và frontend, không chỉ Python event models. Đo bounded memory/buffer và heartbeat trong slow-client scenario. Test network/service path bằng real local stack, fault provider có kiểm soát.

Fix findings, rerun impacted finalization/runtime/provider/contract suites và review snapshot mới. Không weaken old-client assertions để có PASS. Build xanh không thay stream/UI tests; screenshot không thay durability/privacy assertions.

Lưu artifacts/refactor/phase-13/ canonical bundle: gate, phase/test reports, commands, snapshot manifest, fix log, independent review, resume. Snapshot ghi HEAD/dirty/untracked + effective config/caps/contract versions; thêm contract diff, actual stream recordings, redaction scans, backpressure/heartbeat observations, dashboard config và UI traces.

G13 PASS khi required checks/dependencies đạt trên snapshot cuối. Nếu external environment thực sự thiếu, hoàn tất adapter/harness/local stack có thể làm; ghi exact missing input, setup, owner, actual next command, acceptance và bounded run plan. Không gọi harness chưa viết là external. Bàn giao implementation/integration/observation status riêng và readiness Phase 14; chưa xóa living compatibility adapter.
```

## B. Independent verify và vòng sửa

```text
Supervisor kiểm định Phase 13 và thực hiện vòng remediation với code owner; reviewer giữ read-only implementation. Đọc plan/matrix/03-OUTPUT-AND-GATE-CONTRACT.md, G00 snapshots và G01–G03/G11–G12 evidence.

Spawn test/review roles thật nếu hỗ trợ, ownership rõ; otherwise sequential review với limitation. Await/poll mọi long-running session, inspect outputs/exit codes. Findings actionable phải reproduce, giao sửa, rerun impacted suites rồi verify candidate mới; không dừng với “BLOCKED” khi có thể sửa.

Trace public request→gateway→thin API/facade và authoritative outbox→projection→actual .NET/frontend consumer. Pin HEAD + dirty/config/contract hashes. Inspect full serialized transport, required statuses/nulls/errors/media types và old unknown-event behavior.

Chạy đủ:
T13-01: 100% required G00 public contract cases trên V2 adapter.
T13-02: UTF-8/JSON split chunks, blank lines; parse đúng hoặc typed error, không unhandled crash.
T13-03: duplicates/out-of-order/replay/reconnect không double-count hoặc duplicate exam.
T13-04: disconnect trước/sau commit; EOF không Completed giả, reconcile chính xác.
T13-05: slow client/flood bounded memory, heartbeat renew, terminal fact truy hồi.
T13-06: secret/thinking canaries không lộ NDJSON/UI/public logs/metrics.
T13-07: trace thật giải thích decisions, ledger, token accounting/unknown usage; dashboards pin config.
T13-08: actual UI/gateway E2E generation, Retry, NeedsSources, CRUD, Draft/manual Publish.

Inspect outbox sequence, replay retention, rate caps, logging/cardinality và transaction authority; live model quality không được suy từ consumer fake tests. Reject unexpected required skips/zero collected/missing evidence. Nếu stream code chạm finalization, rerun impacted G12 fault checks.

Lưu independent review/retest và canonical evidence phase-13. Blocker còn lại cần repro, proved root cause hoặc discriminating check, attempted fix, exact remaining files/setup/input, owner và executable next command/acceptance. G13 PASS chỉ khi required checks đạt trên candidate cuối; tách implementation, compatibility, UI/operational observations và readiness Phase 14. Không fabricated metrics hoặc tự bỏ required cases.
```
