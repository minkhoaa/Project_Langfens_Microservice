# Phase 07 — Evaluator/Repair Registries và khắc phục quality blockers

Phụ thuộc nghiệm thu: **G01, G04–G06**. Gate: **G07**. Dùng implementation prompt, chờ worker/tester hoàn thành, rồi chạy verify prompt; findings phải quay lại implementation trước handoff.

## Prompt thực hiện và remediation

```text
Bạn là supervisor triển khai Phase 07 Langfens. Hoàn thành implementation/remediation, chạy kiểm định và sửa findings đến khi đạt; không kết thúc chỉ bằng báo cáo BLOCKED khi việc sửa nằm trong scope.

Đọc AGENTS.md/CLAUDE.md áp dụng, master plan, Validation Matrix, runbook, Phase 07 gốc, 03-OUTPUT-AND-GATE-CONTRACT.md và audit Phase 08 được cung cấp. Áp dụng toàn bộ output contract. Bind paths, P07 và T07 vào repo thật, giữ user changes. Kiểm tra G01/G04/G05/G06 trên current HEAD + dirty/untracked hashes; caps phải declared, injected, enforced, pinned.

Nếu có spawn tools, giao implementation worker sở hữu evaluators/repair files, test/corpus worker sở hữu harness/datasets, reviewer độc lập read-only implementation. Chốt ownership tránh concurrent writers. Supervisor tích hợp, await sessions/agents, kiểm tra exit codes và update khoảng 60 giây. Nếu không hỗ trợ spawn, làm các vai tuần tự và ghi limitation. Agent chạy dài không được nới production budgets.

Reproduce findings trước sửa: TypeError trong error factory, required evaluator bypass, nested SDK retry, static NG contradiction, hard-coded repair closure, corpus leakage; audit sau đó còn chỉ ra unsupported PASSAGE, sentences[:10], passage-as-source fallback và aligned-claim bypass. Không coi reports cũ là proof code hiện tại đã sửa.

Hoàn thành mọi work package:
- P07-01: canonical EvaluatorRegistry metadata: types/prerequisites/required/hard-soft/version/timeout/cost/conflicts. Validate required execution plan và coverage tại actual evaluate_pipeline + accept boundary. Unsupported required type, ERROR/missing/stale/wrong-version không thành PASS. Sửa BaseEvaluator theo chữ ký EvaluationResult.create_error thật; typed sanitized errors, cancellation đúng semantics.
- P07-02: schema/ref → deterministic → lexical → grounding → semantic → solver interfaces. Structural rejection chặn expensive calls; deterministic PASS không thay semantic evidence. Không miễn required checks cho artifact được accept.
- P07-03: word/number/group/type/options/answer span/≤3 words/evidence offsets/blanks/refs/duplicates; normalization có spec và boundaries, tránh substring leakage.
- P07-04: entailment/qualifiers/invented quantities/causality/certainty/unmeasured outcomes/ambiguity/distractors/coverage. Scores chỉ ranking/triage, không override blockers. Support PASSAGE/SECTION theo contracts. Bounded batching kiểm tra toàn factual content, coverage record từng sentence/version. Missing nguồn thì hydrate exact approved source refs hoặc non-pass; không self-ground. Generator alignment/rhetorical labels là proposals, không bỏ qua câu còn lại. Coverage thiếu vì cap/deadline là non-pass. Bump evaluator version, invalidate incompatible cache.
- P07-05: semantic relation entailed/contradicted/neither/inconclusive qua ProviderGateway trên toàn approved passage; NG không suy từ missing quote. Phân biệt TFNG facts và YNNG stance. Timeout/incomplete coverage không map NG. G07 phải tự có capability này; Phase 10 sẽ bổ sung blind/adversarial review, không nhận nợ required NG checks.
- P07-06: stable fingerprint/scope/error và ledger merge. Omitted issue không tự resolved; chỉ matching re-evaluation trên version mới hoặc explicit supersession/invalidation.
- P07-07: RepairRegistry allowlist và RepairPlanner traversal dependency graph exact refs, visited set, cycle/missing-metadata failure. Item/group/passage scope nhỏ nhất đúng correctness. Không sửa key để agree reviewer thiếu passage support.
- P07-08: immutable versions; unaffected heads giữ nguyên; impacted closure/evaluations/cache stale tới revalidation. Summary shared text invalidate group, passage đổi invalidate descendants. SDK max_retries=0 tại mọi client/factory/options paths; gateway kiểm soát attempts, reservations, deadlines, unknown outcomes. Không direct SDK/nested loop ở evaluator/repair.
- P07-09: corpus provenance, annotation rubric và source-family/near-duplicate connected-group split. Không đổi family IDs để che leakage. Đã inspect/tune thì không gọi untouched holdout; tạo sạch từ nguồn hợp lệ. Gold không lấy từ evaluator đang test; khai thật reviewer limitations. Minimum 120 questions (mỗi type 10 valid +10 invalid), 40 fidelity cases, 12 section graphs, 12 paper graphs, 20 security cases; false-rejection denominator ≥60 valid questions.

Map/chạy T07-01..08: structural reject/zero expensive calls; held-out semantic metrics; independent-Q repair locality; summary-group closure; passage invalidation; cache versions; lexical-supported nhưng semantic-unsupported claim; evidence-backed answer repair. Thêm regression cho timeout/cancel/malformed, missing required coverage, SDK thật + fake HTTP transport đếm attempts, dynamic closure và bốn false-PASS findings. Canary 40% vs14% ở câu đầu/11/cuối; valid controls; fixture integration đúng schema/word range để không reject vì lý do khác. Chạy impacted G03/G06 và real PostgreSQL khi persistence changes.

Khảo sát configured live provider: audit từng ghi MiniMax smoke PASS. Live semantic benchmark tự động khởi chạy và resume bằng provider MiniMax đã cấu hình (loại bỏ phê duyệt thủ công của operator, authorization-file, phê duyệt campaign-budget hay chờ PENDING_AUTHORIZATION). Vô hiệu hóa toàn bộ application-imposed call, token, monetary và wall-time caps cho MiniMax BENCHMARKS ở cả campaign và child-run level (cấu hình explicit unlimited; cấm fallback về 15 calls / 60k tokens / 300s; production profiles giữ nguyên). Duy trì xác thực service, CAS/fencing, cancellation, truthful usage accounting, checkpoints, idempotent resume, bounded retries và per-request limits; tôn trọng giới hạn thực tế phía provider.

Giữ nguyên các ngưỡng chất lượng: Recall ≥95% tổng, ≥90% từng type; ambiguity ≥90%; false rejection ≤10%; critical canaries 100%, ≥3 runs với aggregate/worst run trên clean frozen holdout. Tuning dùng dev; không đổi threshold/labels sau đo để mở gate. G07 PASS chỉ khi có bằng chứng live benchmark đạt ngưỡng; không promote gate chỉ vì đã dỡ bỏ rào cản phê duyệt. Chính sách này áp dụng mặc định cho tất cả các phase.

Khi test/review FAIL: reproduce → root cause → patch → regression → rerun impacted checks → reviewer xác nhận. Chưa viết harness/dataset là work còn phải làm, không external blocker. Nếu thực sự thiếu external input, hoàn tất phần độc lập, ghi exact missing input, config location an toàn, setup steps và next executable command đã bind vào repo.

Live campaigns lưu campaignId/caseId, manifest/status và reservations; mất output hoặc agent restart thì reconcile trước retry, không chạy lại nguyên batch.

Đầu ra artifacts/refactor/phase-07/: gate.json canonical, phase-report, T07 mapping/test-report, commands.jsonl/exit codes, snapshot-manifest, fix-log, registry/prompt manifests, repair diffs/closure, corpus/split hashes/leakage report, confusion matrices, independent-review và resume.md. Không giả tests/reviewers đã chạy. Tách implementation/runtime/corpus/live smoke/semantic quality. G07 PASS chỉ khi required evidence đủ; external gap cho phép coding downstream bằng fakes, không promote acceptance. Bàn giao fixes, remaining blocker remedies và Phase 08 coding/acceptance readiness riêng.
```

## Prompt verify độc lập và vòng sửa

```text
Kiểm định độc lập G07. Đọc Phase 07, Matrix, 03-OUTPUT-AND-GATE-CONTRACT.md, original findings, current diff và dependency evidence G01/G04–G06. Reviewer không đồng thời viết implementation; dùng subagent read-only nếu có, hoặc ghi sequential-review limitation. Supervisor phải thực hiện fixes sau findings và yêu cầu reverify; không dừng ở report nếu sửa được.

Inspect actual runtime → evaluate_pipeline → decision/accept, canonical models, SDK transport, registry required coverage và persisted caps. Reproduce error/cancel paths, unknown/unsupported type, missing/ERROR/stale required result; mọi trường hợp non-pass. Structural fail zero expensive calls. SDK thật + fake HTTP đếm requests dưới cap, không constructor-only proof.

Chạy T07-01, T07-02, T07-03, T07-04, T07-05, T07-06, T07-07, T07-08 đúng scenarios của plan; map IDs/cases riêng. Audit four false-PASS regressions PASSAGE/all sentences/source provenance/unaligned facts; closure bằng graph thực, unaffected hashes và impacted stale refs. Một claim đúng hoặc rhetorical label không miễn factual evaluation.

Đối chiếu NG annotated relation pairs toàn passage; G07 không defer semantics/corpus sang Phase 10. Kiểm tra provenance/near duplicates/split từ content, clean frozen holdout, labels độc lập với evaluator và denominators. Evidence trên leaked corpus không reuse. Smoke/live quality riêng; semantic thresholds ≥95% overall, ≥90% per-type và ambiguity, false rejection ≤10%, critical 100% trên ≥3 repeats; report worst run. Fake/provider heuristics không thay live measurement.

Chạy impacted G03/G06 checks; persistence dùng PostgreSQL thật khi cần. Bắt zero collected, skip, missing evidence, incompatible snapshot. Không rerun vô hạn cùng failure: phân tích root cause và chọn fix có cơ sở.

Verify campaign/case persisted status và reconcile-before-retry; không duplicate whole benchmark sau lost transcript. No-progress phải có root-cause review và resumable INTERNAL remedy đúng output contract.

Lưu independent-review/test mapping/commands/snapshot/metrics/findings. Với mỗi còn FAIL: repro command, expected/observed, file/symbol root cause, concrete patch/data/config work, acceptance và regression scope. External gap phải có setup location + verified next command, phần có thể tiếp tục và owner. Supervisor sửa code rồi rerun/review trước handoff.

Kết luận implementation, runtime remediation, corpus integrity, live smoke, semantic quality, overall G07 và Phase08 coding/acceptance readiness riêng. Required failed/not-run/missing vẫn BLOCKED; không majority vote hoặc tự optionalize. Mọi assertions dựa evidence thực, không stamp PASS từ interfaces/unit counts.
```
