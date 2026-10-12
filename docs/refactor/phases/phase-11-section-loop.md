# Phase 11 — Section Loop, exact resume và scoped repairs

Phụ thuộc nghiệm thu: **G06–G10**. Gate: **G11**. Section acceptance chưa phải full-paper/job completion; final Draft thuộc Phase 12.

## Prompt thực hiện

```text
Bạn là supervisor hoàn thành Phase11 Langfens. Implement/verify/fix tới đầu ra, không báo findings rồi bỏ phần sửa nằm trong task.

Đọc AGENTS.md/CLAUDE.md, master/Validation Matrix/runbook, Phase11 gốc, 03-OUTPUT-AND-GATE-CONTRACT.md và G06–G10 evidence. Bind actual paths/DI/worker contracts/test scripts, P11/T11; giữ user changes, record HEAD+dirty/untracked/config/prompt/evaluator/corpus hashes. Dependencies phải compatible current code, không reuse old semantic PASS sau evaluator change. External quality gap cho independent coding fakes, chưa production accept/promote G11.

Nếu có spawn: Python composition/repair worker, .NET bridge/checkpoint worker, integration/fault tester và independent read-only reviewer, ownership files rõ. Supervisor integrate shared changes tuần tự; DB/schema/ports tách hoặc serialize tests, await sessions/exit codes/update~60 giây. No tools thì roles tuần tự/limitation thật. Không fire-and-forget hoặc tăng runtime caps vì agent làm dài.

Hoàn thành tất cả work packages:
- P11-01: immutable section snapshot từ exact accepted passage/group/question refs. Canonical contracts, student-visible payload adapter không leak internal keys/evaluation/hidden metadata trái public policy; internal authoring result vẫn giữ answer graph cần grading.
- P11-02: hard validators accepted/fresh dependencies, 2 groups, counts 13/13/14 và type distributions: S1 TFNG 7+sentence completion 6; S2 MCQ single 6+summary completion 7; S3 YNNG 7+short answer 7. Numbering/instructions/options/answer graph theo pinned blueprint và shared contract; passage720–915. Zero required ERROR/missing/stale, real blind solver/adversary mandatory theo G10.
- P11-03: section-wide concept/span/answer concentration, duplicate questions/answer patterns và answer leakage; versioned thresholds/rationale theo ADR/corpus. Không reject chỉ vì shared topic/vocabulary. Item validity không chứng minh section coverage.
- P11-04: editorial style/skill diversity distribution, separate warnings/blockers. Heuristic difficulty/confidence không IELTS band calibration, không override hard issues.
- P11-05: SectionLoop trên generic LoopRuntime/controller/ledger/registries. Duplicate → targeted item repair/reselection; shared coherence/instructions → group; passage flaw → PassageLoop và exact descendant invalidation; source flaw → NeedsSources workflow. Scope nhỏ nhất đủ correctness, không wholesale regeneration mặc định. Dynamic closure gồm current refs/evaluations/cache; unrelated accepted heads giữ nguyên.
- P11-06: accept transaction persist exact snapshot/evaluation refs/decision via authenticated authoritative .NET boundary. SectionsJson migration bridge atomic hoặc idempotent path đã chốt, không dual-write half-state. CAS/fencing/cancel/version preconditions kiểm tại commit; ack lost replay cùng operation/result, no duplicate version/reservation.
- P11-07: exact durable cursor resume passage/question/group/section; source/blueprint/text/config/evaluator hashes pin. Checkpoint cache reuse không bỏ writer authority. Config deployment mới chỉ new runs; không reset budget/counters hoặc tự adopt latest prompts/model giữa job. Source replacement affected section closure mới; unrelated sections/historical versions giữ nguyên.
- P11-08: typed workflow mapping source insufficiency, editorial escalation, transient retryable fail, permanent policy failure; public Retry/NeedsSources/Replace Sources behavior theo G00. Không convert every exception thành NeedsSources hoặc Completed. Passage accepted khác section accepted; section accepted chưa job Completed/BuildExam.

Wire actual GenerationFacade/worker section V2 entrypoint, DTO + DI + authenticated checkpoint client, public HTTP/NDJSON compatibility adapter. Selected V2 path dùng canonical runtime/gateway; không legacy whole-section retries/SDK bypass. Giữ legacy-compatible bridge/explicit branch/default production tới cutover. Python không ghi trực tiếp exam-db; không gọi final exam creation trước G12 PaperLoop.

Every generator/evaluator/solver/adversary/repair request consume shared persisted G06 caps, SDK retry = 0, remaining deadline/backoff/cancel. Concurrency reservations và unknown outcomes giữ invariants. Caps mới nếu cần phải declared/config/version/snapshot, không class-default-only.

Viết/map/chạy T11-01..08: three sections count/types; Q23 duplicate Q18 scoped diff; span concentration; passage revision stale closure; kill tại each acceptance; source replacement S3 giữ S1–2; required ERROR/stale non-pass; actual .NET V2→legacy round-trip. Tests đủ success + boundary/fault, không implementation-mirror assertions.

Integration/fault harness Python+.NET+PostgreSQL thật: crash before commit/after commit-before-ack, cancel/lease takeover/late provider result, source swap/resume và budget pin. Assert accepted refs/hash/counters/history, no completed section checkpoint when invalid. Public payload fixtures parse với real consumer, numbering/answers/options giữ nguyên; not mock DTO-only.

Section parity/regression và paired quality benchmark tự động khởi chạy và resume bằng provider MiniMax đã cấu hình (loại bỏ phê duyệt thủ công của operator, authorization-file, phê duyệt campaign-budget hay chờ PENDING_AUTHORIZATION). Vô hiệu hóa application-imposed call, token, monetary và wall-time caps cho MiniMax BENCHMARKS ở cả campaign và child-run level (cấu hình explicit unlimited; cấm fallback về 15 calls / 60k tokens / 300s; production profiles giữ nguyên). Duy trì xác thực service, CAS/fencing, cancellation, truthful usage accounting, checkpoints, idempotent resume, bounded retries và per-request limits; tôn trọng giới hạn thực tế phía provider.

Independent gold/annotation method thật, pinned model/prompts/caps. G11 PASS chỉ khi có bằng chứng live quality đạt ngưỡng và dependencies G07–G10 đạt; simulation không thay thế; không promote gate chỉ vì đã dỡ bỏ rào cản phê duyệt. Critical≥3 repeats/worst, semantic thresholds nguyên. Chính sách này áp dụng mặc định cho tất cả các phase.

Corrective loop reproduce/root cause/patch/regression/independent reverify tới đạt. Live campaigns lưu campaignId/caseId, manifest/status và reservations; mất output hoặc agent restart thì reconcile trước retry, không chạy lại nguyên batch.

Đầu ra artifacts/refactor/phase-11/: canonical gate/report, P11 map, T11→tests/commands/counts/exits, snapshot, fix-log, exact section/dependency snapshots, repair/invalidation diffs, workflow mapping, SectionsJson transaction evidence, crash/resume, quality/parity reports, independent-review/resume. G11 PASS cần dependencies và required evidence đạt. Bàn giao implementation/DB-contract/live quality/gate/readiness 12 riêng; accepted sections là inputs cho Phase12, chưa tự tạo/publish exam.
```

## Prompt verify độc lập và vòng sửa

```text
Review G11 độc lập theo Phase11/Matrix/03-OUTPUT-AND-GATE-CONTRACT.md và G06–G10 current snapshot. Nếu supported spawn reviewer read-only khác tác giả; supervisor nhận findings, implement remedy rồi rerun/review. Không kết thúc ở passive report khi fixes trong scope.

Trace actual section service/worker/DTO/DI → generic runtime → registries/gateway → .NET checkpoint/SectionsJson bridge. Canonical contracts không duplicate, production caps effective/pinned, no direct Python DB writes/nested retries. Public student-visible boundary và authoring answer graph phân biệt theo baseline.

Chạy T11-01, T11-02, T11-03, T11-04, T11-05, T11-06, T11-07, T11-08: distributions/counts 13/13/14, two coherent groups,720–915; duplicateQ23/Q18 scoped hashes; concentration; passage revision stale; every acceptance crash/resume; S3 replacement giữ S1–2/history; ERROR/stale required checks non-pass; real .NET DTO/consumer round-trip giữ options/answers/ordinals.

Verify summary shared repair/coverage, exact accepted dependency refs và real required blind solver/adversary coverage. No scores override ledger blockers. Locality không giữ stale refs để tiết kiệm; re-evaluate đủ closure. Source insufficiency/editorial/transient/permanent outcomes map đúng workflow.

Real PostgreSQL/authoritative boundary faults before commit/after commit-before-ack, lease takeover/cancel/late results. Assert atomic/idempotent snapshot+bridge, zero duplicate ops/reservations, no lost accepted work, counters/config survive deployment changes. Current authority checked dù cached output reuse. No BuildExam/job Completed trước PaperLoop, Draft/Publish unchanged.

Run impacted G02/G06/G10 and section parity quality checks. Corpus/labels/versions clean and pinned, thresholds Matrix; fake-provider real DB chứng minh durability, không live quality. Required skipped/missing/zero collected/nonzero exit chặn gate, no old incompatible report reuse.

Finding gồm repro command/evidence, expected-observed, root cause file/symbol, concrete fix/data/config action+acceptance+regression. Supervisor sửa/reverify. External gap phải safe config/setup/exact next command/owner/pinned resume, tiếp tục independent work trước handoff.

Verify campaign/case persisted status và reconcile-before-retry; không duplicate whole benchmark sau lost transcript. No-progress phải có root-cause review và resumable INTERNAL remedy đúng output contract.

Lưu independent evidence bundle, snapshots/repair closure/status map/DB traces/contracts/metrics/commands/exits và current hashes. Kết luận implementation, transactional/contract, live quality/upstream, overall G11 và Phase12 coding/acceptance readiness riêng. Section PASS không paper/job Completed; simulation chỉ coding readiness, không approved production inputs.
```
