# Phase 01 — Canonical contracts, policies và ADR

Phụ thuộc: G00. Gate: G01.

Work packages: P01-01, P01-02, P01-03, P01-04, P01-05, P01-06, P01-07, P01-08, P01-09, P01-10, P01-11.

Test IDs: T01-01, T01-02, T01-03, T01-04, T01-05, T01-06.

## Prompt A — Thực hiện và khắc phục

```text
Hoàn thành Phase 01 Langfens, chưa xây generation/provider loops hoặc đổi production routes. Đọc AGENTS.md/CLAUDE.md, master, Validation Matrix, Phase 01 gốc, G00 evidence và 03-OUTPUT-AND-GATE-CONTRACT.md. Chỉ reuse G00 khi actual code/config compatibility được chứng minh.

Execution long-running: reproduce → implement → test → review độc lập → fix → rerun. Nếu có spawn, phân file ownership cho Python contracts, .NET fixtures/DTO và reviewer; supervisor giải quyết shared schemas tuần tự. Theo dõi sessions, exit codes, cập nhật resume; không kết thúc khi còn bug nội bộ sửa được.

Discover canonical models, serializer/hash conventions, DTO/validators và test scripts thật; giữ dirty changes. Bind P01-01..11:
01 artifact envelope với immutable version và exact parent {id,version,hash};
02 run/job/section/source revision identities, operation khác artifact version;
03 typed evaluation target/dependencies/version/status/usage;
04 issue lifecycle/fingerprint/evidence;
05 issue-code taxonomy;
06 versioned policies;
07 type-specific question schemas;
08 decisions/state transitions;
09 authoritative-store/service-auth/ack ADR;
10 dependency invalidation ADR;
11 persisted budget/event delivery ADR.

Một canonical domain definition, domain modules import/re-export cùng type. Không tạo models thứ hai ở artifacts/blueprint. Corresponding .NET DTO/codegen và JSON Schema theo repo, có explicit schema/compatibility versions. Wire validation tại real deserialization/policy boundaries; chỉ thêm dataclasses chưa đủ.

Envelope gồm artifact/run/type/version/hash/UTC/producer/schema, payload và exact parents. Hash canonicalization phải reproducible cross-language; JSON field order không được đổi identity ngoài spec. IDs không tái dùng cho khác nội dung. Evaluation PASS/FAIL/ERROR/NOT_APPLICABLE có requiredness/prerequisites; exception không trở thành empty issues/PASS.

Issues gồm unsupported/contradicted, causal/certainty overstatement, unmeasured outcome, source insufficient, evidence missing, ambiguity, leakage, bad distractor, limits, duplicate, unavailable evaluator, stale dependency, budget exhausted. Unresolved blockers giữ lifecycle qua versions.

Enforce bằng code: 3 sections, 40 contiguous ordinals, 13/13/14; S1 TFNG7+sentence6, S2 MCQ6+summary7, S3 YNNG7+short7; passage720–915, paper2150–2750. Giữ baseline word/number normalization. Completion/short answer exact passage support, ≤3 words/numbers. NG dùng absence assessment: topical quote không phải positive proof, thiếu positive quote tự thân không làm NG invalid. Difficulty/confidence chưa calibrated không gọi là IELTS band.

Decision PASS/REPAIR/REGENERATE/ESCALATE/FAIL có reason/scope/expected version/budget grant. Fresh required evaluations và zero blockers trước PASS. ADR chốt .NET sở hữu job/lease/exam-db, Python authenticated API+ack, CAS/fencing/cancel, exact closure/cache versions; không hai authoritative stores. Events at-least-once/idempotent; không exactly-once cloud inference.

Triển khai/chạy T01-01..06: Python↔JSON↔.NET round-trip; invalid/unknown schema theo compatibility policy; payload/parent change đổi hash/ref; evaluator error/critical không PASS; valid NG vs exact completion; section/paper boundaries enforce thật. Fixtures có Unicode/null/enums/UTC. Sửa mismatches rồi rerun cross-language checks và impacted G00 tests.

Lưu contract diff/schemas, policy fixture hashes, ADR owners/decisions và output bundle contract tại artifacts/refactor/phase-01/. P01→symbols, T01→executable targets đầy đủ. G01 PASS khi tests đạt và ownership/ack/invalidation/budget decisions chốt. Missing authority decision không ghi external nếu có thể ADR trong scope. Real blocker có concrete remedy/setup/next command. Giữ public routing/legacy, rollback contracts chưa dùng qua code change có kiểm định, không drop data. Bàn giao G01 và Phase 02 readiness.
```

## Prompt B — Verify độc lập và đóng findings

```text
Review độc lập Phase 01 theo plan, Validation Matrix và 03-OUTPUT-AND-GATE-CONTRACT.md. Đọc G00, diff, schemas/ADR và actual boundary wiring. Reviewer không là tác giả; spawn khi khả dụng, hoặc sequential review có limitation rõ.

Search duplicate definitions, divergent enums và DTO default/null compatibility. Trace canonical types tới API/deserialization/validators. Không coi schema document hoặc prompt constraints là enforcement.

Chạy đủ T01-01..06:
01 Python/JSON/.NET không mất Unicode/null/UTC/enums/version/hash.
02 invalid types/counts/unknown fields reject hoặc đúng compatibility policy đã chốt.
03 một ký tự hoặc parent version đổi identity; old version không mutable.
04 ERROR/missing required evaluation/critical issue không có đường PASS.
05 valid NG không đòi impossible positive quote, completion vẫn exact supported span.
06 boundaries/count/type/ordinal được Python và .NET enforce.

Kiểm tra P01-01..11 có owner/files/test evidence; ADR không để store/ack/fencing/invalidation/budget là TODO. Parent refs exact; operation identity khác artifact identity. No-calibrated-band claims và cloud exactly-once claims không được xuất hiện trong contracts/docs.

Đối chiếu status/usage/error serializers, hashes và public contract diffs. Chạy impacted G00 regression, phát hiện zero collected/skip/nonzero theo manifest.

Mỗi finding cần reproduction, expected/observed, affected invariant, root cause và exact repair acceptance. Giao supervisor sửa; reviewer rerun snapshot mới, không dừng ở report FAIL khi nội bộ xử lý được.

Lưu independent evidence/commands/hashes và canonical G01 report. PASS chỉ khi required checks đạt, no duplicate divergent model và architecture decisions chốt. BLOCKED phải kèm concrete work/setup/next commands. Bàn giao Phase 02 readiness, không gọi foundation schemas là model-quality certification.
```
