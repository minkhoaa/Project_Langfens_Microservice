# Prompt recovery G07–G08 — Sửa findings và hoàn tất Passage Loop

Copy phần prompt dưới đây cho supervisor ở repository đang làm. Scope recovery là G07/G08; sau đó handoff về orchestrator để tiếp tục 09–15 theo dependencies.

---

Thực hiện recovery G07–G08 của Langfens tới kết quả có thể nghiệm thu. Đọc plan/master/Validation Matrix, gates hiện tại, applicable AGENTS.md/CLAUDE.md và `03-OUTPUT-AND-GATE-CONTRACT.md`. Dùng phase-07/08 implementation + verification prompts của pack làm work breakdown.

User đã giao long-running work và cho phép subagents. Reproduce → fix → integration test → independent review → sửa findings → rerun tới khi đạt hoặc có blocker thực sự có concrete remedy. Không kết thúc sau một report FAIL, không yêu cầu xác nhận lại cho routine fixes trong scope. Respect actual slots, resources, configured cloud budgets và authority.

## 1. Snapshot và task owners

Đối chiếu báo cáo audit tại HEAD 7a4d0e7503710d3b87c95e15831829552ba7be8d với current HEAD/dirty/untracked hashes; bảo toàn worktree Phase07. Không giả mọi finding vẫn tồn tại nếu code đã sửa.

Chia tasks nếu tools có sẵn:

- Evaluator/repair worker: required coverage, applicability, error/NG semantics, dynamic closure và repairs.
- Passage worker: generator, prompt assets, context, LoopRuntime composition và actual entrypoint.
- Test/benchmark engineer: regression fixtures, service/DB fault tests, clean split và capped live campaigns.
- Independent reviewer: code read-only, real wiring/evidence review, findings gửi supervisor; không self-certify own implementation.

Giao file ownership rõ; serialize shared registry/config edits. Workers không tự stamp gate hoặc thay thresholds. Supervisor tích hợp và tiếp tục corrective loop.

## 2. Đóng findings G07 chưa đạt

Revalidate fixes đã báo 24 tests PASS: create_error đúng signature, timeout/exception/cancel non-pass, SDK retries disabled dưới gateway, validate_required_evaluators trong actual pipeline, dynamic consumer closure, pinned cache/ref/version và issue lifecycle.

Đếm retries bằng real configured SDK với fake transport bên dưới SDK, không chỉ mock adapter/constructor. Every actual attempt consume remaining caps/reservation; unknown outcomes không refund/reset.

Required evaluators đầy đủ đúng artifact type/version tại execution plan và trước accept. Structural hard fail vẫn chặn expensive calls; evaluator missing/error/timeout không thành “no issues” PASS.

NOT GIVEN phải có semantic relation checking trên toàn approved passage; tách factual FALSE với author-stance NO, neither relation với inconclusive/error. Không dồn yêu cầu G07 này sang Phase10; Phase10 tiếp tục full blind/adversarial review. Heuristic không override required semantic check.

Audit và làm sạch corpus theo actual source provenance, families, duplicated/reprinted/derived samples và near duplicates. Không sửa bằng đổi family IDs. Holdout đã lộ dùng dev/regression khi phù hợp; tạo untouched frozen measurement set, annotation rubric và enough denominators. Không dùng tested evaluator outputs làm gold tự chứng minh, không giả human reviewers.

## 3. Vá bốn grounding false-PASS paths và applicability

1. `PassageWordCountEvaluator`, `GroundingFidelityEvaluator` và mọi required evaluator của passage phải thật sự support canonical ArtifactType.PASSAGE/payload. Unsupported required applicability không trả PASS rỗng.
2. Bỏ sentences[:10]/silent truncation. Bounded batches/chunks vẫn phải ghi coverage toàn passage. Budget/deadline/context cap hết giữa chừng → incomplete/error/non-pass, không partial PASS.
3. Bỏ source_text-or-passage_text self-grounding. Resolve independent approved SourcePack/EvidenceGraph/source spans bằng exact refs/provenance. sourceText inline thiếu nhưng valid refs có thể hydrate; không có approved source thì non-pass. Text equality riêng không đủ để phân biệt source provenance.
4. Một aligned claim không miễn kiểm tra unaligned factual sentences. Alignment/factual/rhetorical tags do generator đề xuất đều cần independent checks. Generator gắn assertion thành rhetorical không bypass.

Version evaluators/cache policy sau fix; không reuse old false-PASS cache. Re-evaluate impacted accepted heads/dependencies theo compatibility và scope, không tự mutation immutable history.

Regression probes phải gồm PASSAGE/SECTION, canary ở câu1/câu11/cuối, missing source, valid hydration, one aligned + one unsupported unaligned, rhetorical-label attack và budget exhaustion giữa batches. Integration fixtures hợp lệ 720–915 từ và schema; assert exact fidelity/error code + coverage, không coi word-count failure là proof grounding.

## 4. Repairs đạt correctness

Thay blind slicing tại word900 bằng sentence/paragraph-aware length repair theo configured 720–915 policy. Verified evidence phải đủ để mở rộng; trim giữ remaining coherence/coverage/fidelity và được re-evaluate. Không feasible thì bounded regenerate/escalate, không success-return oversize.

Modal/causality replacement không chứng minh remaining outcome hợp lệ: “associated with immediate anxiety elimination” vẫn cần independent source support. UNMEASURED_OUTCOME repair dùng verified material nếu có; không repairable thì typed bounded runtime outcome, không exception mất journal hoặc fake PASS.

Repair tạo immutable version, fresh sentence IDs/offsets/alignment/evals. Dynamic closure invalidate all consumers cần thiết; unaffected accepted refs giữ nguyên.

## 5. Hoàn tất Phase08 còn thiếu

Implement tất cả P08-01..09: accepted exact input context, versioned prompt IDs/hashes/input schema, passage artifact/alignment, deterministic/style/grounding composition, local repairs, length repairs, checkpoint/resume và paired passage benchmark.

Source data envelope có safe serialization/escaping và trusted instructions riêng; tag không phải security guarantee. Output không có quyền thay config/policy/schema/tools. Validate injection attempts và resulting domain invariants.

PassageLoop chạy trên generic BoundedLoopRuntime/ledger/registries; không thêm extension/revision/whole-section retry loops riêng. Every call/retry/evaluator batch/repair dùng ProviderGateway và persisted run caps.

Wire actual service DI/facade/selected-V2 entrypoint và kiểm thử qua cùng composition. Không kết thúc bằng classes chỉ được isolated tests gọi. Giữ explicit legacy branch/public HTTP/NDJSON compatibility, pin engine per run và giữ default migration routing tới approved cutover. Selected V2 không invoke legacy retry path. Không giả Phase09 đã có hoặc auto-complete section từ accepted passage.

Commit accepted passage/parents/evals/decision qua authoritative .NET boundary trước downstream; source insufficient có durable typed outcome; crash/resume giữ accepted hash/counters và không gọi passage generator lại khi inputs/config unchanged.

## 6. Chạy tests và semantic campaigns thực sự

Triển khai/map/chạy T07-01..08 và T08-01..08 cùng impacted G03/G06/persistence regressions. PostgreSQL/service-boundary tests và request transport probes phải khác isolated fakes; record exact nodes/exit codes/case counts.

Báo cáo cũ có MiniMax smoke PASS: inspect current configured model/credential/quota và recent compatibility trước khi ghi thiếu key. Smoke không chứng minh semantic quality. Harness thiếu là code work; leaked corpus là integrity failure; external missing input phải được chứng minh.

Khi configured credentials/budget available, thực sự run capped pinned G07 semantic benchmark và G08 full-passage/paired benchmark. Campaign/case IDs, manifest/status/reservations persisted; reconcile lost output trước retry, không chạy lại batch tốn phí vô ích. Không tự mua plan/thay model routing/tăng caps để có PASS.

Giữ thresholds, enough denominators và frozen clean holdout; critical fixtures ≥3 lần, aggregate/worst run. Passage benchmark không thay full-paper benchmark tương lai. Failed measurements tạo fix tasks trên dev và fresh/versioned holdout policy, không tune để ăn test đang nghiệm thu.

## 7. Reviewer loop và đầu ra

Independent reviewer chạy verify prompts Phase07/08 trên consistent snapshot và actual entrypoint, ghi findings với repro/root cause/scope/tests. Supervisor assign repairs và rerun impacted checks; không handoff passive report khi còn sửa được.

Lưu đầy đủ output contract, gồm coverage, source refs, prompt inventory, repair diffs, wiring trace, budget journal, kill/resume, corpus/split audit và actual measurements. Record HEAD + dirty/untracked/config/corpus hashes; old report preserved.

Tách runtime remediation, corpus integrity, live smoke, semantic quality, G07 overall, Phase08 implementation, G08 overall và Phase09 readiness. G07/G08 PASS chỉ khi required prerequisites/evidence đạt. Nếu external/input thực sự còn thiếu, hoàn tất independent code và báo exact input/setup/next command/budgeted resume plan. Không gọi Phase09 READY khi approved passage/quality requirements chưa đạt.

Nếu task bị tools/context/budget giới hạn hoặc evidence-based internal deadlock, checkpoint với attempts và next experiment/decision thật; không fake external blocker hay tiếp tục vô hạn. Hoàn thành recovery rồi handoff supervisor scope09–15, không tự phát sinh Phase09 code trong worker recovery.
