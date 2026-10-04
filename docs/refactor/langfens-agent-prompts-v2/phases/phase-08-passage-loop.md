# Phase 08 — Passage Loop được wire thật và grounding toàn bài

Phụ thuộc nghiệm thu: **G03–G07**. Gate: **G08**. Báo cáo đính kèm là đầu vào remediation, không chứng minh current code vẫn ở snapshot đó.

## Prompt thực hiện và remediation

```text
Bạn là supervisor hoàn thành Phase 08 Langfens, bao gồm findings audit và Passage Loop thực sự. Chỉ scope Phase08 cùng upstream fixes cần thiết; không chạy verify trên capability chưa viết rồi kết thúc ở “unimplemented”.

Đọc AGENTS.md/CLAUDE.md, master/Matrix/runbook, Phase07–08 gốc, 03-OUTPUT-AND-GATE-CONTRACT.md và toàn audit đính kèm. Bind P08/T08, actual entrypoint/DI/checkpoint/test commands. Giữ user changes; record HEAD + dirty/untracked/config hashes. Kiểm tra G03–G07 current compatibility. G07 NG/corpus/live quality không tự dời sang Phase10; upstream thiếu quality vẫn có thể coding bằng fakes, chưa accept/promote G08.

Nếu có spawn tools, giao generator/prompts worker, evaluator/repair worker với files riêng, test/harness worker và reviewer độc lập read-only. Supervisor integrate tuần tự khi shared files, await running tasks/exit codes và update mỗi khoảng 60 giây. Không fire-and-forget. Không support spawn thì thực hiện roles tuần tự và ghi đúng limitation. Khi findings sửa được, tiếp tục corrective loop tới đạt; agent runtime dài không nới caps production.

Audit đầu vào ghi generator/style/prompts/T08 chưa có, public route chạy legacy, PASSAGE unsupported, sentences[:10], self-grounding và claims-bypass. Reproduce trên current code; đã sửa thì chứng minh bằng tests, không patch mù.

Đóng bốn false-PASS paths trước acceptance: PassageWordCountEvaluator và GroundingFidelityEvaluator đều phải hỗ trợ ArtifactType.PASSAGE; audit applicability toàn required registry cho PASSAGE/SECTION. Kiểm tra toàn factual content bằng bounded batches với coverage record; missing source inline hydrate approved exact refs hoặc non-pass; generated passage không làm truth source; một aligned claim/rhetorical label không miễn câu khác. Unsupported/incomplete/error non-pass, evaluator version/cache invalidation đúng. Không coi EVIDENCE_GRAPH canaries là passage fidelity proof.

Hoàn thành toàn work packages:
- P08-01: PassageGenerator context nhận accepted exact ExamBlueprint/EvidenceGraph refs, verified spans/provenance, section constraints và pinned policy/config. Untrusted source dùng serialized data envelope, không concatenate vào trusted instructions; tag không tự là security boundary.
- P08-02: generators/passage/prompts versioned assets: ID/version/hash/input schema, three style profiles, output contract. Không holdout examples. Provider logic chỉ gateway.
- P08-03: ArtifactEnvelope PASSAGE với paragraphs/sentence IDs theo text version, word count và proposed claim/span alignment. Generator proposals không tự xác nhận truth.
- P08-04: PassageStyle/Word/Fidelity/qualifier/unmeasured-outcome evaluators compose trên registry. Required coverage fresh trước acceptance; raw approved source spans độc lập vẫn resolve được. Caps không đủ full evaluation → non-pass.
- P08-05: targeted fidelity repair đúng sentence/paragraph, immutable new version; semantic context đổi phải evaluate toàn fidelity/coherence và closure. “proves→suggests” không sửa unsupported outcome còn lại. UNMEASURED_OUTCOME không repairable trả typed bounded outcome, không unhandled exception/false success.
- P08-06: length repair chỉ thêm verified evidence đủ nội dung, tránh paraphrase lặp. Không đủ cho ≥720 words chất lượng → durable SOURCE_INSUFFICIENT/escalation.
- P08-07: oversize trim theo sentence/paragraph boundaries và policy 720–915; không words[:900], không trả oversize như thành công. Re-evaluate grammar/coherence/grounding sau trim; không có feasible repair thì bounded regenerate/escalate.
- P08-08: checkpoint accepted payload/alignment/exact parents/evaluations/decision qua authenticated authoritative .NET boundary trước question generation. CAS/fencing/cancel và idempotent op. Kill/resume accepted passage không generate lại, counters/versions giữ pinned snapshot.
- P08-09: paired legacy passage benchmark cùng sources/profiles/conditions, quality rubric/usage/latency/cost; text không cần giống nhau. Không giả full-paper benchmark khi chưa G12.

PassageLoop là composition trên BoundedLoopRuntime/IssueLedgerManager/controller/registries, không thêm extension/revision/whole-section retry riêng. Mọi generation/evaluation/repair requests dùng ProviderGateway và shared persisted budgets/deadlines, SDK retries = 0. Caps/config phải đi từ production Settings qua actual DI, không chỉ class defaults.

Wire capability vào service entrypoint/GenerationFacade V2 thực sự với real DI. Chọn explicit versioned/internal seam hoặc engine-selected path đúng contracts; test bằng actual composition, không chỉ instantiate class trong unit. Selected V2 passage path không chạy legacy ad-hoc loops. Giữ explicit legacy branch/functions tới cutover, không auto-switch default production. Chưa có V2 questions thì không giả full /section completed; passage accept khác section/job Completed. Document bridge boundaries.

Viết/map/chạy T08-01..08 đầy đủ: 3 profiles/719–720–915–916; quantity/causality/qualifier/outcome fidelity; local repair immutable; source-insufficient bounded; unaligned facts; kill/resume accepted; adversarial injection; clean semantic + paired benchmark. Fixtures integration hợp lệ schema/length, assert actual fidelity codes để không “pass” nhờ word rejection. Canaries câu 1/11/cuối, partial batch timeout, misleading rhetorical labels, missing/valid source hydration, stale cache. T08-07 gồm forged closing envelope/schema override; assert trusted config/output/acceptance không đổi, không chỉ tìm tag. Impacted G03/G06/G07 và real PostgreSQL checkpoint harness.

Audit từng ghi MiniMax smoke PASS: khảo sát current safe credential/config và harness trước gán NOT_RUN_EXTERNAL. Viết harness/corpus nếu thiếu; smoke riêng, semantic benchmark riêng. Freeze corpus/labels/prompts/model/config/caps trước measurement; no leakage/no evaluator-as-gold. Thresholds Matrix: critical 100%, recall 95% overall/90% each type, ambiguity 90%, false rejection≤10%; critical ≥3 repeats aggregate/worst. Passage-stage metrics đủ scope; release ratios ở G15.

Findings → reproduce/root cause/fix/regression/reverify liên tục; không tự giảm thresholds hoặc weaken tests. External gap thật: hoàn tất independent code/tests/harness, exact missing input + secure config/setup + next actual command + cap/estimate có cơ sở + owner/resume. “Chưa viết test” không external.

Live campaigns phải persist campaignId/caseId, manifest/status và reservations; mất output hoặc agent restart thì reconcile trước retry, không chạy lại nguyên batch. Hết budget/deadline thì checkpoint partial results và kế hoạch resume có cap. Nếu nhiều fixes không tiến triển, review root cause/đổi hypothesis; không còn hướng khả thi thì handoff unresolved INTERNAL với experiments đã thử và next executable experiment, không giả external hay lặp vô hạn.

Đầu ra artifacts/refactor/phase-08/: canonical gate/report, P08→files, T08→tests/commands/case counts/exits, snapshot, fix-log, prompt inventory, sentence coverage, lineage/repair diffs, wired-entrypoint trace, caps accounting, DB crash/resume, paired/live quality, independent-review/resume. G08 PASS cần dependencies + required evidence; tách implementation/integration/G07 quality/G08 quality/readiness 09. Không gọi independent fake composition là approved production passage.
```

## Prompt verify độc lập và vòng sửa

```text
Review G08 độc lập theo Phase08/Matrix/03-OUTPUT-AND-GATE-CONTRACT.md, original audit và current snapshot. Nếu có tools, spawn reviewer read-only, không tác giả code; supervisor nhận findings, sửa rồi rerun/review, không kết thúc ở report khi sửa được.

Trace actual service entrypoint/DI → V2 PassageLoop → runtime/registry/gateway → authoritative checkpoint. Không substitute isolated constructor tests. Selected V2 không legacy loops/budget bypass; legacy branch còn sống trong migration không tự là defect. Default production chưa tự cutover. Accepted passage khác completed section.

Reproduce four false-PASS cases ở PASSAGE và SECTION: unsupported type, canary sentence 11/cuối, missing source self-ground, aligned claim + unaligned unsupported sentence. Xác nhận PassageWordCountEvaluator và GroundingFidelityEvaluator đều xử lý ArtifactType.PASSAGE; audit applicability toàn required registry. Required coverage toàn factual content; source refs independent; partial/error non-pass; cache invalidated. Integration fixtures valid schema/word range, assert fidelity issue code và valid control; word-count rejection không chứng minh grounding hoạt động.

Chạy T08-01, T08-02, T08-03, T08-04, T08-05, T08-06, T08-07, T08-08 đúng scenarios; test IDs/cases riêng. Kiểm trim boundary720–915, sentence completeness, unsupported repair typed outcome, no invented padding, exact parents/CAS/fencing/cancel, PostgreSQL kill-after-accept generator thêm = 0. Inject forged envelope/instructions/policy requests; tag existence không proof.

Audit prompt versions/schema/hash và real effective caps; every batch/repair charged. Kiểm G03–G07 compatibility, source family holdout/provenance, smoke versus live semantic benchmark, annotated paired passage report. EVIDENCE_GRAPH12/12 và provider smoke không thay passage quality. Critical≥3 runs/worst + Matrix thresholds, denominator/latency/usage unknown minh bạch. No full-paper claims sớm.

Required missing/skip/zero collected/nonzero exit chặn gate. Remediation concrete: repro command, expected/observed, file/symbol root cause, fix/data/config work, regression + acceptance. Supervisor implement và reverify; true external gap có secure setup/exact next command/owner/pinned resume, không generic “cần key/corpus”.

Verify campaign/case persisted status và reconcile-before-retry; không duplicate whole benchmark sau lost transcript. No-progress phải có root-cause review và resumable INTERNAL remedy đúng output contract.

Lưu independent evidence bundle với SHA/dirty/config/corpus hashes, wiring/coverage/repair/DB traces, commands/exits và findings. Kết luận implementation complete, deterministic/integration, G07 dependency, live passage quality, overall G08 và Phase09 coding/acceptance readiness riêng. Coding bằng fake khi external thiếu chỉ simulation; G08 nghiệm thu/approved production refs vẫn BLOCKED tới required evidence đạt.
```
