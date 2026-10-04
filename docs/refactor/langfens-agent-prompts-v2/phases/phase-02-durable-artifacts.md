# Phase 02 — Durable artifacts, fencing và exact resume

Phụ thuộc: G01. Gate: G02.

Work packages: P02-01, P02-02, P02-03, P02-04, P02-05, P02-06, P02-07, P02-08, P02-09, P02-10.

Test IDs: T02-01, T02-02, T02-03, T02-04, T02-05, T02-06, T02-07, T02-08, T02-09.

## Prompt A — Thực hiện và khắc phục

```text
Hoàn thành Phase 02 Langfens trên authoritative .NET checkpoint boundary và PostgreSQL thật. Đọc AGENTS.md/CLAUDE.md, master, Validation Matrix, Phase 02 gốc, G01 schemas/ADR và 03-OUTPUT-AND-GATE-CONTRACT.md. Chưa xây domain loops hoặc auto-deploy.

Làm long-running reproduce→fix→test→independent review→fix findings→rerun. Nếu spawn khả dụng, chia persistence/migrations, Python client+worker wiring, fault harness và reviewer với files riêng; serialize integration/DB writes hoặc dùng isolated schemas/ports. Supervisor await mọi task/process; không coi mock repository là durability proof.

Discover actual EF migrations, job worker/lease, service-auth, checkpoints, BuildExam và test commands. Giữ changes, pin actual dirty snapshot. Bind P02-01..10 và names thật; table/routes trong plan là đề xuất cần chốt, không giả endpoint đã tồn tại.

P02-01: expand-first migration/backfill cho legacy jobs, giữ SectionsJson/completed exams. P02-02: claim tăng leaseEpoch, renew match owner/epoch. P02-03: authenticated checkpoint API validate run/epoch/expiry/cancelVersion/requestHash, không tin caller tự khai. P02-04: durable intent/reservation grants trước side effect. P02-05: atomic payload/evaluation/decision/accepted head/outbox. P02-06: ack/replay operationId. P02-07: exact-ref resume/compatibility resolver. P02-08: source replacement closure. P02-09: final BuildExam idempotency nền tảng. P02-10: quantitative payload/retention/index/redaction và rollback.

Canonical data model giữ immutable artifacts/dependencies/evaluations/issues/decisions, operations và event outbox. Unique (run,artifact,version), (run,operation), (run,event); exact ref constraints, CAS head và transactional counter reservations. Same operationId+hash replay cùng committed result, khác hash conflict. Run pin engine/schema/policy/source revisions/authority.

Wire .NET worker truyền writer grant tới actual V2 entry/client; Python chỉ gọi authenticated API và advance sau ack. Lost ack replay không tạo version/reservation mới. NDJSON progress không phải commit proof. Không Python direct exam-db writes hoặc second authoritative store.

UNKNOWN_OUTCOME giữ reservation khi provider có thể đã xử lý; bounded retry operation mới tiêu cap, không free replay hoặc cloud exactly-once claim. Cancel/expired lease/stale epoch chặn late accepted writes. Cache không thay authority check.

Source replace invalidate graph closure affected section và aggregate paper, giữ unrelated accepted refs/history. Compatibility resolver kiểm tra hashes/schema/producer; unsupported old run có migration/pause rõ, không fabricate lịch sử.

P02-09 ở phase này chứng minh nền final graph idempotency qua existing integration fixture; không gọi full PaperLoop đã triển khai. Final uniqueness ở DB, không check-then-insert trong RAM.

Chạy T02-01..09 trên PostgreSQL thật: concurrent same operation; different hash conflict; crash pre/postcommit/pre-ack; takeover; cancel; section2 replacement; crash final commit; bad hash/schema; no/wrong/stale auth. Fault injection phải tại transaction boundaries, assert DB rows/heads/counters/outbox/ref graph, không chỉ HTTP codes.

Apply migration trên DB clone, khởi động/đọc bằng compatible previous app; rollback app giữ additive tables/data. Sửa failures, rerun impacted G01/G00 contracts. Không drop artifacts để rollback.

Lưu migrations/constraints, actual transaction/API/worker traces, fault/replay/rollback evidence và contract output bundle artifacts/refactor/phase-02/. G02 PASS khi mọi T02 đạt real DB và compatibility rollback có proof. Thiếu DB env thì dựng supported local harness trong scope; external access thật thiếu có setup/next commands, hoàn tất code/harness độc lập. Không handoff chỉ báo BLOCKED. Bàn giao G02 và Phase03 readiness.
```

## Prompt B — Verify độc lập và đóng findings

```text
Kiểm định độc lập Phase02 theo plan, Validation Matrix, G01 ADR và 03-OUTPUT-AND-GATE-CONTRACT.md. Reviewer đọc diff/API/auth/worker/client/migrations và DB evidence; không làm tác giả patch mình review. Spawn reviewer khi khả dụng.

Chạy T02-01..09 trên real PostgreSQL isolated harness:
01 hai writers same op: một result/reservation, cùng replay response.
02 same ID khác request hash: conflict, old payload không đổi.
03 crash trước/sau commit/trước ack: heads/rows/result đúng boundary.
04 takeover: stale epoch reject mọi writes kể cả late result.
05 cancellation: terminal không sống lại, no accepted late output.
06 source section2: chỉ affected closure+paper stale; unrelated refs giữ.
07 crash final graph commit: retry cùng ExamId, một graph.
08 corrupted hash/incompatible schema: typed failure không reuse.
09 missing/wrong-run/stale auth: không sửa DB.

Trace actual worker→grant→Python persistence client→.NET authenticated transaction→ack→cursor. Progress event không advance durability. Inspect unique constraints/CAS/request hashes/atomic outbox và budget counts trực tiếp DB; mock tests không thay proof.

Kiểm tra UNKNOWN_OUTCOME/reconciliation không refund/reset, additive migration/backfill không sửa completed exams/SectionsJson, retention/caps có units/source/version. Thực hiện migration+previous-app recovery trên clone, không destructive production operations.

Findings cần exact reproduction, root cause, file/symbol remedy, assertions/regressions. Supervisor fix rồi reviewer rerun impacted checks; mọi running sessions có completion/exit evidence.

Lưu independent report, commands/SQL/fault traces và snapshot hashes theo contract. G02 PASS chỉ real transactional/auth/resume checks đạt. Phân biệt groundwork final idempotency với future Phase12 paper acceptance. Remaining external blocker có explicit setup/next commands, không stamp PASS. Kết luận Phase03 readiness.
```
