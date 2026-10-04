# Phase 09 — Six-type candidates, coherent groups và bounded selection

Phụ thuộc nghiệm thu: **G05–G08**. Gate: **G09**. G09 kiểm định candidate composition; live blind solver/adversary final-quality gate thuộc G10.

## Prompt thực hiện

```text
Bạn là supervisor triển khai hoàn chỉnh Phase09 Langfens. Implement, chạy meaningful tests, giao independent verify, sửa findings rồi rerun tới đạt; không dừng ở report nếu fix nằm trong scope.

Đọc AGENTS.md/CLAUDE.md, master/Validation Matrix/runbook, Phase09 gốc, 03-OUTPUT-AND-GATE-CONTRACT.md, relevant Phase07–08 reports và latest audit. Bind P09/T09/paths/scripts vào repo; giữ user changes, pin HEAD+dirty/untracked/config hashes. G05–G08 evidence phải tương thích actual candidate. Chưa có approved grounded passage không được tự lấy raw/generated passage làm production dependency. External quality gap cho phép code/tests bằng fakes, ghi simulation, chưa promote G09.

Nếu spawn tools sẵn có, giao generator/prompt worker, selector/persistence worker, test engineer và independent reviewer files riêng. Supervisor quản lý task graph, integrate shared edits tuần tự, await tasks/exit codes, update khoảng60 giây. Không hỗ trợ spawn thì roles tuần tự với limitation thật. Long-running agent không tăng candidate/call/token/deadline caps.

Hoàn thành tất cả work packages:
- P09-01: 6 versioned prompt families TFNG, YNNG, sentence completion, summary completion, MCQ single, short answer; IDs/hash/version/schema; examples ngoài final holdout. Không generic mega-prompt che type semantics.
- P09-02: canonical slotId/candidateId, target type/skill, exact passage/group context/evidence refs; final numbering từ pinned blueprint. Không LLM tự đổi slot distributions.
- P09-03: bounded pool policy trong typed Settings/versioned profile: completion/short answer 1–2; TFNG/YNNG 2–3; MCQ ≤3 khởi điểm, theo policy đã chốt. Summary coherent group variants hoặc shared draft+targeted blanks; không ghép incompatible summaries. Group variant/candidate counters định nghĩa rõ. Batch type requests không tăng outputs ngoài cap.
- P09-04: hard filters schema/options labels+cardinality/answer membership/encoding/exact span/≤3words/blanks/instructions/evidence/leakage. Normalization/boundaries canonical; NG không bắt fabricate quote chứa missing answer. Malformed output non-pass, không partial accept.
- P09-05: NG context pointer + checked whole passage scope, TFNG entailment/contradiction và YNNG author stance từ G07. Missing topical quote không chứng minh NG, scope incomplete/error không eligible.
- P09-06: eligibility required fresh evaluations/zero unresolved blockers/exact accepted dependencies. Solver interface fake được dùng để kiểm tra composition tại G09; không gắn nhãn live uniqueness hoặc bypass real semantic checks khác. Không tạo circular G09→G10 dependency, nhưng final-quality acceptance/cutover chờ G10.
- P09-07: versioned normalized ranking weights, hard fail độc lập scores; self-confidence không truth probability. Deterministic tie-break candidateId/hash; report scoring rationale, không invented band calibration.
- P09-08: joint constraints cho coverage/fact/span/answer redundancy và group coherence; finite backtracking/node/search caps/deadline từ config. Không chọn từng top score rồi bỏ global constraints. Infeasible → bounded targeted generation/escalation có reason.
- P09-09: item/option/distractor repair scope đúng, summary shared context đổi invalidate group. Passage immutable trong question generation; cần passage change thì route lên parent workflow và invalidate descendants, không sửa âm thầm cứu candidate. Rerun required closure/unique-answer checks, không đổi key chỉ để agree reviewer.
- P09-10: persist candidates/rejected reasons/evaluation refs/selected heads và cursor qua authoritative .NET artifact boundary. Replay idempotent; resume Q17 giữ accepted Q14–16/hash/accounting khi exact deps còn fresh. Rejected history không biến mất để reset attempt caps.

Candidate loop compose trên generic runtime/ledger/registry/controller; không nested retries hoặc direct provider SDK. Source/data serialization đúng trust boundaries, không tag-only security claims. Shared persisted budgets bao trùm generator/evaluator/repair/selection requests, reservations survive restart/unknown outcome. Config changes chỉ run mới; stale lease/cancel không commit heads. Wire actual GenerationFacade/engine-selected composition, giữ public adapter và legacy branch tới cutover; chưa auto default production.

Viết/map/chạy T09-01..08: six-type valid/invalid encodings; 4-word/absent/leaked completion; duplicate labels vs multiple plausible MCQ answers; seven summary blanks/shared closure; duplicate-fact top scores; all-fail/near-exhausted budget; Q17 crash/resume; reordered/tied candidates deterministic.

Test meaningful boundaries: pool N/N+1/group variants, node cap, parallel admission, invalid option member, lexical false positives, wrong passage refs, required evaluator ERROR/stale, malicious source/question output, coherent/ incoherent summary controls. Structural failures zero semantic calls. Test actual wired service composition and real PostgreSQL cursor/heads/operations where persistence changes; impacted G06/G07/G08 regressions.

G09 fake solver tests chứng minh input/composition behavior, không benchmark live solver quality. Nếu live check cần cho other required semantic coverage, khảo sát configured provider, dùng clean frozen corpus/pinned model/prompt/caps/budget. Không lấy evaluator output làm gold, không tune final holdout. Làm harness/corpus trong scope trước viện external gap.

Loop thực thi: reproduce failure → root cause → fix → regression → rerun impacted checks → independent reviewer xác nhận. Không weaken constraints/tests/thresholds hoặc tự optionalize. External input thật thiếu: hoàn tất độc lập, exact missing input/config location/setup/next repo command/owner và bounded execution plan, không mỗi report “blocked”.

Live campaigns phải persist campaignId/caseId, manifest/status và reservations; mất output hoặc agent restart thì reconcile trước retry, không chạy lại nguyên batch. Hết budget/deadline thì checkpoint partial results và kế hoạch resume có cap. Nếu nhiều fixes không tiến triển, review root cause/đổi hypothesis; không còn hướng khả thi thì handoff unresolved INTERNAL với experiments đã thử và next executable experiment, không giả external hay lặp vô hạn.

Đầu ra artifacts/refactor/phase-09/: gate.json canonical; P09 files/symbols; test-report T09 mappings+cases; commands/exits; snapshot; fix-log; prompt manifests; sanitized candidate pools/rejections; selection traces/counters; invalidation/repair diffs; DB crash/resume; independent-review/resume. Tất cả paths tồn tại. Bàn giao behavior, fixes và G09/readiness 10 trên actual hashes. G09 PASS cần required predecessor/candidate evidence; final solver/adversary quality ghi pending G10, không pretend final exam ready.
```

## Prompt verify độc lập và vòng sửa

```text
Review G09 độc lập theo Phase09/Matrix/03-OUTPUT-AND-GATE-CONTRACT.md và G05–G08 actual evidence. Có tools thì spawn read-only reviewer không tác giả implementation; supervisor phải fix/rerun/reverify findings trong scope, không dừng sau report.

Inspect actual service wiring → candidate composition → runtime/registry/gateway → .NET checkpoint. Verify canonical contracts, six prompt versions/schema, accepted exact passage/blueprint/group refs, budgets/candidate+search caps và engine pinning. Fake upstream artifacts chỉ tests, không production-approved dependencies.

Chạy đầy đủ T09-01, T09-02, T09-03, T09-04, T09-05, T09-06, T09-07, T09-08 theo plan. Bao phủ six types/count/encodings, exact phrase/word boundaries, zero expensive calls structural fail, plausible MCQ blockers, summary 7 coherent blanks, joint constraints, pool/search finite caps và deterministic tie ordering.

Crash đang Q17 trên real PostgreSQL/authoritative boundary: Q14–16 heads/hashes không đổi, counters/reservations không reset/double-count. Group variants không bypass pool limits. Passage không bị silently sửa; item/group repair invalidates correct dynamic closure, history immutable, required ERROR/stale không eligible.

Audit no direct SDK/nested retry, no score override hard blockers. Solver fake allowed G09 interface tests, label đúng; không yêu cầu G10 để chứng minh G09 composition, không gọi live uniqueness đã PASS. NG semantic coverage vẫn trách nhiệm G07, không defer.

Run impacted G06–G08 regressions. Bắt missing test IDs, skips/zero collected/nonzero exits và reused incompatible evidence. Semantic reports nếu required phải clean corpus/labels/config, Matrix thresholds, true denominators; simulation không thay measurement.

Mỗi finding: repro exact command/expected-observed/evidence, root cause file/symbol, concrete fix/data/config action, acceptance/regression. Supervisor sửa và review lại. True external gap có secure setup/config+next executable command+owner/resume; không generic “đợi provider/Phase10”.

Verify campaign/case persisted status và reconcile-before-retry; không duplicate whole benchmark sau lost transcript. No-progress phải có root-cause review và resumable INTERNAL remedy đúng output contract.

Lưu independent-review, T09 commands/results, current snapshot/corpus/prompt hashes, pools/selection/DB/repair evidence. Kết luận implementation, deterministic/integration, upstream quality, G09 và readiness 10; tách final-question quality pending G10. Required failed/missing/not-run chặn gate, không average PASS từ ranking scores.
```
