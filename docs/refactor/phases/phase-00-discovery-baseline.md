# Phase 00 — Discovery và baseline có thể kiểm chứng

Phụ thuộc: không. Gate: G00. Chạy prompt A rồi prompt B; supervisor xử lý findings và verify lại trước handoff.

Work packages: P00-01, P00-02, P00-03, P00-04, P00-05, P00-06, P00-07, P00-08.

Test IDs: T00-01, T00-02, T00-03, T00-04, T00-05, T00-06.

## Prompt A — Thực hiện và khắc phục

```text
Thực hiện Phase 00 Langfens đến đầu ra kiểm định được, chưa refactor production hoặc xóa legacy. Đọc AGENTS.md/CLAUDE.md áp dụng, master plan, Validation Matrix, Phase 00 gốc và 03-OUTPUT-AND-GATE-CONTRACT.md của Prompt Pack V2; contract này bắt buộc cho execution, reports và gates.

Làm long-running: reproduce → implement harness/inventory → test → independent review → fix findings → rerun. Nếu spawn khả dụng, giao inventory/contract tracing, fixture/test engineering và reviewer độc lập phạm vi files riêng; supervisor tích hợp. Không fire-and-forget, không dừng ở report BLOCKED khi thiếu harness có thể viết. Cập nhật tiến độ/session IDs và resume checkpoint theo contract.

Khám phá repo/lockfiles/scripts thật, giữ changes của user. Ghi HEAD, dirty diff/untracked hashes, runtime/config và fixture versions. Bind đầy đủ:
- P00-01: repo inventory, actual commands và conventions.
- P00-02: bốn public Python routes → .NET DTO/consumer/worker → final validator → admin CRUD.
- P00-03: legacy imports, DI/startup/entrypoints/callers/tests và replacement dự kiến.
- P00-04: request/response/null/status/error/content-type/NDJSON recordings.
- P00-05: policy counts, ranges, word/number counting, answer normalization và duplication.
- P00-06: lease/renew/retry/NeedsSources/cancel/checkpoint/final persistence transitions.
- P00-07: fixtures, fake provider, stream replay và deterministic regression harness.
- P00-08: frozen legacy benchmark, measured usage/latency và missing-data notes.

Tạo docs/refactor/repo-inventory.md, legacy-symbol-map.csv, contracts/legacy/ recordings/schemas, policy-baseline.json và state-transition inventory theo paths thực tế. Mọi assertion phân loại observed/documented/proposed. Không bịa schema từ architecture notes. Bugs sẵn có có finding và remedy; không tự biến bug thành policy đúng hoặc âm thầm sửa production ngoài discovery scope.

Corpus ban đầu: ≥6 suitable sources cho 3 profiles, ≥6 unsuitable sources; mỗi trong 6 question types ≥5 valid +≥5 invalid. Có quantity/causality/certainty/unmeasured outcome cases, Unicode, tables/XML, long text, redirects, changed content, malformed JSON và cut stream. Ghi quyền sử dụng/provenance/labels/hash. Usage thiếu là unknown, không 0; mô tả 3–5 phút chưa phải SLA đo được.

Khám phá và triển khai phase verifier/manifest target theo conventions repo. Runner map IDs tới executable tests, phát hiện zero collected, required skip, nonzero exit và missing evidence. Không assert tên command đề xuất đã tồn tại. Exercise actual .NET stream consumer và workflow; fixture-only schema tests không đủ.

Chạy T00-01..06: bốn routes; NDJSON split UTF-8/JSON và incomplete EOF; source/policy boundaries; crash sau section 2 rồi Retry reuse sections 1–2; manual Draft→edit→Publish; fake-provider suite chạy hai lần deterministic/no cloud. Sửa harness/findings trong scope rồi rerun impacted checks.

Đầu ra theo contract tại artifacts/refactor/phase-00/: gate.json, phase-report.md, test reports, commands.jsonl, snapshot-manifest.json, fix-log.jsonl, independent-review.md, resume.md cùng recordings/policy/corpus/baseline. P00→files/symbols và T00→commands/assertions phải đầy đủ.

G00 PASS khi T00 required đạt, critical fields/policy/workflow đã rõ và evidence khớp snapshot. Nếu repo/environment thật thiếu, hoàn tất phần độc lập, ghi BLOCKED với reason loại INPUT theo schema canonical và concrete acquisition/setup/next commands; không chỉ nói cần repo. Chưa đổi routing hoặc deploy. Bàn giao G00, findings đã sửa, limitations và readiness Phase 01.
```

## Prompt B — Verify độc lập và đóng findings

```text
Kiểm định độc lập Phase 00 theo master, Validation Matrix, Phase 00 gốc và 03-OUTPUT-AND-GATE-CONTRACT.md. Reviewer không sửa implementation mình review; giao repro/remedy cho supervisor, nhận snapshot mới và rerun impacted checks đến kết quả.

Đọc actual diff, inventory, manifests/lockfiles và evidence. Xác minh observed/documented/proposed, caller→symbol paths, public routes và .NET consumer. Review phải là vai khác tác giả; nếu không có spawn, thực hiện tuần tự và ghi limitation trung thực.

Chạy/map đầy đủ T00-01..06:
T00-01: replay đủ bốn routes, ghi đúng fields/null/status/media type.
T00-02: actual consumer xử lý splits giữa UTF-8/JSON; EOF không terminal là incomplete.
T00-03: source eligibility/license và boundaries khớp baseline; discrepancies có provenance.
T00-04: worker crash/retry giữ accepted sections 1–2, chỉ resume phần thiếu.
T00-05: manual CRUD Draft/edit/Publish vẫn hoạt động.
T00-06: hai lần fake-provider suite cùng result, xác nhận transport không cloud calls.

Kiểm tra corpus minimum, licenses/labels/hash, benchmark denominators và usage unknown. Không coi fixture input một mình là recording behavior. Runner phải bắt zero collected/skip/nonzero/missing report; test-ID counts khác case counts.

Với mỗi defect ghi evidence/repro, root cause hoặc check phân biệt, exact scope fix, acceptance và next executable test. Supervisor sửa các phần có thể xử lý; không handoff chỉ một list blockers.

Lưu independent-review, commands/exit codes và gate trên code/config/corpus snapshot thật; không reuse evidence incompatible. G00 PASS chỉ khi required checks và inventory đạt. Chưa có repo thì BLOCKED với reason loại INPUT theo schema canonical, kèm setup/resume cụ thể. Kết luận Phase 01 readiness; không tuyên bố live SLA hoặc quality từ fake tests.
```
