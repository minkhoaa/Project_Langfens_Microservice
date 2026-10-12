# Final Acceptance Report — Template

**Trạng thái mẫu:** Chưa có implementation/test execution. Không dùng mẫu này như report PASS.

## 1. Release identity

| Field | Giá trị thực cần điền |
|---|---|
| Release SHA/image digest | Chưa có |
| Test environment / UTC run window | Chưa chạy |
| Engine/schema/policy versions | Chưa chốt |
| Provider/model/config versions | Chưa xác minh |
| Prompt/evaluator version manifest | Chưa có |
| Corpus hash/source-rights manifest | Chưa có |
| Migration set | Chưa triển khai |
| Reviewers / findings | Chưa review |
| Overall result | PLANNED |

## 2. Gate status

| Gate | Status | Required tests pass/total | Evidence | Blockers |
|---|---|---|---|---|
| G00 | PLANNED | — | — | Repository chưa cung cấp |
| G01 | PLANNED | — | — | — |
| G02 | PLANNED | — | — | — |
| G03 | PLANNED | — | — | — |
| G04 | PLANNED | — | — | — |
| G05 | PLANNED | — | — | — |
| G06 | PLANNED | — | — | — |
| G07 | PLANNED | — | — | — |
| G08 | PLANNED | — | — | — |
| G09 | PLANNED | — | — | — |
| G10 | PLANNED | — | — | — |
| G11 | PLANNED | — | — | — |
| G12 | PLANNED | — | — | — |
| G13 | PLANNED | — | — | — |
| G14 | PLANNED | — | — | — |
| G15 | PLANNED | — | — | — |

## 3. Business/contract evidence

- [ ] Four public endpoints và NDJSON .NET consumer parity report.
- [ ] Source license/provenance/SSRF tests.
- [ ] Counts 13/13/14, 6 types, numbering 1–40, word ranges, correct graph.
- [ ] Type-aware answer/evidence/NG checks.
- [ ] Manual CRUD/Draft/Publish/Retry/NeedsSources E2E.
- [ ] AI luôn Draft; no unauthorized auto-publish.

Ghi actual tests/command/result refs cho mỗi mục, không chỉ tick.

## 4. Reliability/security evidence

| Check | Cases executed | Expected/observed | Evidence ref |
|---|---|---|---|
| Artifact commit/ACK crash boundaries | — | — | — |
| Lease takeover/stale writer/cancel | — | — | — |
| Q-level resume/dependency invalidation | — | — | — |
| Atomic shared budgets/unknown cloud outcome | — | — | — |
| Final DB graph rollback/idempotent exam | — | — | — |
| Stream replay/disconnect/backpressure | — | — | — |
| Internal auth/SSRF/secret redaction | — | — | — |

## 5. Semantic quality và paired benchmark

| Metric | N/sample size | Legacy | V2 | Gate criterion | Result |
|---|---|---|---|---|---|
| Fidelity critical canaries | — | — | — | 100% rejected | NOT_RUN |
| Blocking recall/false reject | — | — | — | Matrix thresholds | NOT_RUN |
| Ambiguity per type | — | — | — | ≥90% recall | NOT_RUN |
| Valid Draft completion | — | — | — | V2 no worse in sample | NOT_RUN |
| Accepted graph invariants | — | — | — | 100% | NOT_RUN |
| Latency P50/P95 | — | — | — | P95 ratio + deadline | NOT_RUN |
| Calls/tokens/cost observed-vs-estimated | — | — | — | Ratio + caps | NOT_RUN |

Ghi pinned providers/prompts, annotated labels, per-type confusion matrix, repeated-run worst-case, distributions/intervals và missing usage. Không ghép invalid source failures vào eligible completion denominator.

## 6. Legacy deletion report

| Old exact path/symbol | Responsibility replacement | Callers=0 evidence | Behavior tests | Drain/schema proof | Deleted SHA |
|---|---|---|---|---|---|
| `router.py` scope TBD G00 | `api/reading.py` | — | — | — | — |
| `extractor.py` scope TBD G00 | ingestion/evidence | — | — | — | — |
| `llm.py` scope TBD G00 | providers gateway | — | — | — | — |
| `prompts.py` scope TBD G00 | capability prompt assets + policy | — | — | — | — |
| Legacy generation functions | Capability mapping G00 | — | — | — | — |
| Temporary flags/wrappers/deps | Inventory items | — | — | — | — |

Boundary adapters/compatibility readers còn sống phải ghi rationale, owner và expiry nếu là transition code. Không yêu cầu xóa mọi adapter chỉ để đạt tên checklist.

## 7. Feedback và offline improvement

- [ ] Edit capture có before/after lineage và reason.
- [ ] Transaction retry không duplicate feedback.
- [ ] Raw→curated labels có review, export/version/hash đúng.
- [ ] Source-family split/no benchmark leakage.
- [ ] Candidate promotion có quality report và reviewer.
- [ ] In-flight runs/prompt caches pin versions.

## 8. Rollout/rollback

Ghi actual canary %/run counts/observation window, incidents, abort decisions, previous image compatibility với current DB, resume readiness và rollback rehearsal. Chưa rollout thì G15 không hoàn thành release; staging PASS report riêng.

## 9. Remaining limitations và quyết định

Issue→severity→affected invariant→owner/ticket→resolution. Cosmetic accepted warnings phải có rationale. Required security/durability/grounding blockers không được waiver trong plan này.

**Quyết định cuối:** NOT_RUN / BLOCKED / PASS. Điền bằng evidence, không copy mặc định PASS.
