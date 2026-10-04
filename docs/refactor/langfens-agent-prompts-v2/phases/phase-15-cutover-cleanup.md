# Phase 15 — Release verification, cutover và legacy cleanup

Phụ thuộc: **G00–G14**, gồm required external checks. Gate: **G15**. Implementation/staging hoàn tất không thay production observation.

## A. Implementation, remediation và release

```text
Hoàn thành Phase 15 trong operational authorization thực sự có. Đọc repo instructions, master/matrix, Phase15, 03-OUTPUT-AND-GATE-CONTRACT.md, G00–G14 và deletion inventory. Giữ user changes; bind actual scripts/images/deploy targets.

Supervisor giao release test engineer, benchmark worker, deletion worker và read-only reviewer theo ownership. Spawn thật nếu supported; otherwise tuần tự, limitation rõ. Tests dùng isolated DB/ports/budgets; shared writes serialize. Poll/await sessions/agents tới exit, update khoảng 60 giây. Không fire-and-forget, không fabricate overnight observation; keep resume checkpoints. Reproduce→fix→retest→independent review tới đạt hoặc external blocker thật, không kết thúc sau report-only.

Hoàn thành P15-01..10:
P15-01 freeze SHA/dirty/untracked hashes, image digest, schema/policy/caps/prompt/evaluator/model/corpus/pricing versions. Changes sau freeze invalidate impacted evidence.
P15-02 run required matrix: 124 IDs gốc + bổ sung, unit/contract/security/DB-fault/semantic/E2E. Required skip/NOT_RUN/zero collected chặn release; harness thiếu phải viết.
P15-03 shadow staging, frozen sources legacy/V2; chỉ primary persist final exam, shadow budget riêng bounded. ≥18 paired papers/engine, ≥6 distinct source triples; cùng env/providers/corpus/settings, đổi provider thì report experiment riêng. Eligibility denominators, raw distributions, annotation rubric/source-family holdout rõ. Critical semantic cases ≥3 runs, aggregate và worst run. Không tuning holdout hoặc fake independent labels.
P15-04 staging rồi authorized new-run canary 10%→50%→100%, run pin engine/config. Proposed minimum ≥20 completed eligible jobs +≥24 giờ phải freeze trước rollout, điều chỉnh theo volume có rationale trước measurement. Không tăng production quyền từ code task; hoàn tất reversible code/staging/rehearsal trước bước bị giới hạn.
P15-05 abort/pause/rollback khi stale commit, duplicate exam, accepted grounding blocker, unauthorized access hoặc contract break. Không trade hard gates lấy latency/cost.
P15-06 drain/migrate legacy in-flight runs có evidence, compatible old-data readers; không xóa code chúng còn cần.
P15-07/P15-08 delete exact confirmed obsolete generation paths/symbols: old responsibility→new location→caller/import search→behavior tests→data compatibility→drained-run proof. Không xóa file cùng tên service khác hoặc behavior regression tests; giữ living public adapters/readers.
P15-09 remove obsolete flags/branches/DI/imports/assets/deps/env/CI wiring theo caller map, không bỏ rollback compatibility.
P15-10 final runbooks/migrations/retention/promotion/rollback/docs và acceptance report.

Thresholds theo matrix đã pin: hard invariants/security/durability/manual cases 100%; zero invalid accepted graph; critical fidelity 100%; recall tổng ≥95%, từng type ≥90%, ambiguity ≥90%, false rejection ≤10%; valid-Draft/fidelity/ambiguity không kém legacy. V2 P95 ≤1.5× legacy và hard deadline; median billed/estimated cost ≤2× legacy, mọi run trong caps. Unknown usage riêng, không estimate thành billed; nhỏ sample không chứng minh statistical superiority.

Run T15-01..08 trên candidate cuối: complete matrix; post-deletion Python/.NET/frontend startup/build; zero obsolete executable refs; source→40 câu→Draft→edit/feedback→manual Publish; chaos; actual canary; compatible-image rollback DB clone/current additive schema; CRUD/gateway/public consumer contracts. Giữ fencing/cancel/resume/budgets và .NET atomic final graph; cloud calls không exactly-once.

Independent reviewer inspect rồi owner fix/retest impacted checks. Thiếu production access/authorization hoặc observation window chưa đủ: giữ gate BLOCKED, hoàn tất code/staging/rehearsal/runbook; ghi exact owner/input/setup, next actual command, capped execution/observation plan. Không dùng synthetic canary thay production.

Lưu canonical phase-15 bundle và final-acceptance-report.md, release manifest, verified gates, benchmarks/raw outputs, chaos/deletion/drain/canary/rollback evidence, fix log/resume. Rollback bằng pinned compatible previous image; không copy source tay/drop artifacts/feedback/destructive migrations. Bàn giao implementation, candidate readiness và production rollout status riêng; G15 PASS chỉ khi required evidence/review đầy đủ.
```

## B. Independent final verify và vòng sửa

```text
Supervisor audit release candidate Phase15 và toàn refactor, điều phối remediation tới kết quả. Đọc all phase plans, Validation Matrix, 03-OUTPUT-AND-GATE-CONTRACT.md, canonical test manifest, G00–G14, release/deletion/drain/benchmark/canary/rollback evidence. Reviewer không viết implementation; owner sửa findings, test engineer rerun. Spawn thật hoặc sequential fallback rõ, await/poll mọi task tới exit.

Map 124 original IDs + added checks tới executable nodes/commands/evidence. Inspect HEAD/dirty/untracked/image/config/corpus hashes; không reuse incompatible evidence. Runtime/corpus FAIL không ghi NOT_RUN_EXTERNAL. Không stamp PASS từ build hoặc interface presence.

Chạy/đối chiếu:
T15-01: required release matrix/gates/thresholds trên final snapshot, không failed/unknown required checks.
T15-02: Python/.NET/frontend import/startup/build sau deletion.
T15-03: zero obsolete executable pipeline refs; historical allowlist/living adapters phân loại đúng.
T15-04: real source→40 questions→Draft→admin edit/feedback→manual Publish, impacted attempt/grading compatibility.
T15-05: full chaos/resume/Q17/replay/unknown outcome/cancel/takeover/source replacement/config change; zero lost checkpoint/duplicate graph/stale commit/budget reset.
T15-06: actual canary ≥frozen sample/window, sampled exam inspection, quality/usage/latency evidence; chưa đủ vẫn BLOCKED.
T15-07: pinned previous image trên current additive schema/DB clone đọc được checkpoints/artifacts/feedback.
T15-08: manual CRUD/gateway/public HTTP+NDJSON actual consumers không regression.

Audit ≥18 paired papers/engine và ≥6 distinct triples, clean frozen labels, critical ≥3 runs; raw latency/cost distributions, denominators, CI/limitations và exact matrix ratios. Legacy success=0 thì report absolute counts, không ratio tuyên bố superiority. Smoke/fake-provider/real-DB tests không thay live quality/production observation. Same-model subagents không thành statistically independent reviewers.

Inspect entire acceptance chain fresh exact refs/required evaluations, source-independent grounding, blind inputs, dynamic invalidation và shared persisted caps. .NET final graph/Completed/outbox atomic; Draft-only AI, no auto-promotion từ raw feedback.

Findings actionable phải reproduce→owner implement remedy→impacted retest→review snapshot mới, không chỉ tạo backlog. Mỗi external blocker có exact missing input/authorization/environment, setup, owner, actual next command và acceptance/observation plan; hoàn tất phần reversible trước handoff.

Lưu independent final report và canonical phase-15 evidence/fix-log/resume. Kết luận riêng implementation complete, release candidate verified, production rollout complete, overall G15 PASS/BLOCKED. Không hạ thresholds, skip required tests hoặc fabricate canary/drain/rollback proof để nhận PASS.
```
