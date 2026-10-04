# Phase 10 — Blind Solver, Adversary và evidence-backed uniqueness

Phụ thuộc nghiệm thu: **G07–G09**. Gate: **G10**. Blindness là dữ liệu thực gửi đi; hai requests cùng model không có độc lập thống kê.

## Prompt thực hiện

```text
Bạn là supervisor triển khai Phase10 Langfens đến kết quả kiểm định thật. Implement, giao test/review độc lập, fix findings và rerun impacted checks; không kết thúc bằng report khi còn sửa được.

Đọc AGENTS.md/CLAUDE.md, master/Matrix/runbook, Phase10 gốc, 03-OUTPUT-AND-GATE-CONTRACT.md và G07–G09 evidence/current diff. Bind P10/T10 vào symbols/scripts thật, giữ user changes, pin HEAD+dirty/untracked/prompt/model/config/corpus hashes. G07 NG/corpus phải giải quyết ở predecessor, không coi Phase10 là nơi miễn upstream debt. External quality thiếu cho phép independent coding/fakes, chưa promote G10.

Nếu có spawn tools: DTO/prompt worker, solver/adversary/compare worker, payload+benchmark tester và read-only independent reviewer với ownership rõ. Supervisor tích hợp shared files tuần tự, await tools/agents và exit codes, update~60 giây. No spawn thì sequential roles, ghi limitation. Long-running verify phải bounded provider budget/deadline, không vô hạn model consensus.

Hoàn thành work packages:
- P10-01: minimal canonical solver/adversary DTO chỉ approved passage + student-visible question/instructions/options và shared context cần thiết. Loại expected key, hidden evidence explanations, generation prompts, rejected alternatives/hints và internal metadata có thể leak đáp án. Dùng allowlist serializer, không chỉ DTO comments.
- P10-02: solver/adversary versioned prompts riêng, input/output schemas, asset IDs/hash và redacted logs. Serialize untrusted student/source text đúng envelope; không để content chỉnh trusted policy/tools.
- P10-03: solver output normalized answer, cited exact passage spans và short justification theo schema; self-reported confidence chưa calibrated. Không thu/lưu hidden chain-of-thought. Missing/invalid spans non-pass theo required policy.
- P10-04: adversary outputs plausible alternatives/ambiguity type/evidence. Validate evidence và relevance trước tạo blocker; unsupported outside-knowledge allegation không tự fail valid item.
- P10-05: comparison canonical TFNG/YNNG, option-ID MCQ, exact/explicit allowed normalization/aliases completion/short answer. Không fuzzy matching hoặc mở alias policy sau mismatch để pass. Expected key chỉ comparison service, không solver/adversary request/cache input.
- P10-06: diversity profile theo available credentials/budget: separate provider/model khi có. Trace đúng actual providers/model versions. Same model khác requests/prompt không “independent model”; ghi correlated-review limitation, không fake external reviewer.
- P10-07: disagreement HIGH blocker → bounded evidence-backed adjudication hoặc repair/regenerate đúng closure. Không majority vote override grounding, không tự đổi answer key theo solver. Fresh reviewed spans và complete passage coverage; no-answer/inconclusive không default agreement.
- P10-08: persist solver/adversary outputs/evaluation refs; cache keyed exact student-visible text/passage/instructions/prompt/model/evaluator config. Key swap không đổi solver request/cache, comparison phải chạy đúng current key. Payload/dependencies đổi invalidate; cache reuse vẫn authority check tại commit.
- P10-09: mọi calls/retries/adjudication qua ProviderGateway, shared persisted reservation/caps/deadlines; SDK retry0. Required timeout/malformed/error/exhausted budget non-pass, không silent skip để complete. Resume/cancel/stale writer xử lý qua generic runtime.

NG kiểm neither entailment nor contradiction trên toàn approved passage; TFNG facts và YNNG stance khác nhau. Contradicted numeric/stance pairs không NG; missing topical evidence không automatically FALSE/NO. Bounded batching/scope record, incomplete coverage/error non-pass.

Wire real evaluator registry/runtime/GenerationFacade composition. Actual transport payload tests phải chứng minh DTO isolation qua serialization, prompts, middleware/context builders; không only inspect declared fields. Giữ legacy branch/default tới cutover; G11 section acceptance bắt buộc real required solver/adversary sau G10.

Viết/map/chạy T10-01..08: hidden-key/evidence canary absent serialized payload; key-swap request hash invariant và compare outcome đổi; TFNG/YNNG annotated pairs; MCQ/completion ambiguity; unsupported adversary alternatives; timeout/malformed/budget; option/passage cache invalidation; true diversity traces.

Thêm adversarial hidden nested fields, metadata concatenation/logging, stable answer-policy normalization, malicious option text, stale refs, partial coverage, gateway retries0 accounting, cancellation/lease loss. Inspect SDK thật + fake HTTP recording trên transport; secret canary không public logs. Real PostgreSQL khi checkpoint/cache durability changes. Impacted G03/G06/G07/G09 checks.

Live smoke và held-out benchmark riêng. Kiểm configured providers/caps trước nói thiếu keys. Harness/data thiếu thì viết trong scope. Freeze clean source-family/near-duplicate split, provenance, labels/annotations độc lập evaluator, prompt/model/caps trước measurement. Tuning dùng dev. Thresholds Matrix: blocking recall≥95% total/≥90% each type; ambiguity≥90%; false rejection≤10% trên ≥60 valid; critical 100%≥3 runs aggregate/worst. Corpus/small sample limitations minh bạch. Fake payload proof không thay live quality.

Failure loop: reproduce/root cause/fix/regression/reverify. Không lower thresholds/required flags/labels. External gap thật: complete code/tests/harness, exact missing credential/environment/data/budget, secure config steps và actual next command+owner/bounded plan. Không yêu cầu keys paste chat, không fabricate labels/reviewers/measurements.

Live campaigns phải persist campaignId/caseId, manifest/status và reservations; mất output hoặc agent restart thì reconcile trước retry, không chạy lại nguyên batch. Hết budget/deadline thì checkpoint partial results và kế hoạch resume có cap. Nếu nhiều fixes không tiến triển, review root cause/đổi hypothesis; không còn hướng khả thi thì handoff unresolved INTERNAL với experiments đã thử và next executable experiment, không giả external hay lặp vô hạn.

Đầu ra artifacts/refactor/phase-10/: gate/report, P10 map, T10 tests/case counts/commands/exits, snapshot, fix-log, sanitized serialized requests/hashes, key-swap proof, cache/adjudication/repair examples, confusion matrices/per-type metrics/usage, diversity report, independent-review/resume. G10 PASS khi dependencies/deterministic/live required evidence đạt; output implementation, isolation proof, live quality, gate và readiness 11 riêng. Không khẳng định zero ambiguity từ finite corpus.
```

## Prompt verify độc lập và vòng sửa

```text
Review G10 theo Phase10/Matrix/03-OUTPUT-AND-GATE-CONTRACT.md và G07–G09 current evidence. Reviewer read-only khác tác giả; supervisor phải sửa findings và reverify trước handoff khi trong scope. Spawn nếu supported, sequential roles nếu không và ghi limitations thật.

Inspect full serialization tại actual HTTP transport, không chỉ DTO/schema. Chạy T10-01/T10-02: canary expected key/hidden explanation/generation hint không trong messages/metadata; swap key giữ student inputs và request hash, comparison đổi đúng. Logs redacted, short justification không hidden reasoning. Inspect answer-policy và cache separation để key không vòng ngược vào solver.

Chạy T10-03, T10-04, T10-05, T10-06, T10-07, T10-08: annotated facts/stance NG pairs toàn passage; ambiguous MCQ/completion; outside-knowledge alternative rejected; malformed/timeouts/budget non-pass; exact cache invalidation; same/different model traces thật. No default agreement/key swap/majority override. Required evaluator coverage fresh và error non-pass.

Verify actual runtime/registry/gateway/checkpoint wiring, per-attempt accounting/deadline/unknown outcome, no nested SDK retry, cancel/fencing/resume. Fake transport proves isolation only; live held-out labels prove finite-corpus quality. Test DB durability khi impacted và rerun G03/G06/G07/G09 checks.

Audit corpus source families/near duplicates, pinned clean holdout, labeling method/limitations, no evaluator-as-gold. Semantic thresholds≥95% total,≥90% per type+ambiguity, false rejection≤10%, critical 100%≥3 repeats/worst; denominators/confusion matrices. Smoke không benchmark, optional provider diversity chỉ theo actual policy; không fabricate independent models.

Phát hiện skip/zero collected/nonzero exits/incompatible evidence. Finding phải có repro command, expected/observed, root cause file/symbol, concrete code/data/config remedy, acceptance/regression. Supervisor thực hiện remedy rồi rerun/review; true external gap cần safe setup/exact next command/owner/pinned resume. Không dừng với “thiếu API/corpus” khi harness/data có thể làm.

Verify campaign/case persisted status và reconcile-before-retry; không duplicate whole benchmark sau lost transcript. No-progress phải có root-cause review và resumable INTERNAL remedy đúng output contract.

Lưu independent-review, command/results/snapshot/payload hashes/metrics/findings. Kết luận implementation, transport blindness, deterministic/integration, corpus/live semantic, overall G10 và Phase11 coding/acceptance readiness riêng. Required missing quality BLOCKED; keep V2 chưa default, không nhận section production acceptance bằng fake solver.
```
