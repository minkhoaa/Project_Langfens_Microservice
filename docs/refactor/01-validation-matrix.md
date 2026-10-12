# Ma trận kiểm định và nghiệm thu

## 1. Trạng thái và cách ra quyết định

Đây là specification cho tests sẽ triển khai trong repository, không phải test report đã chạy. Trạng thái ban đầu toàn bộ gates là `PLANNED`; không có bằng chứng pass implementation.

| Status | Ý nghĩa | Có được promote release? |
|---|---|---|
| PLANNED | Có plan, chưa bắt đầu | Không |
| IN_PROGRESS | Đang triển khai/kiểm định | Không |
| NOT_RUN | Test chưa chạy | Không cho required checks |
| NOT_RUN_EXTERNAL | Thiếu credential/model/dataset/environment | Không cho required live checks |
| BLOCKED_INPUT | Chưa có repo/schema/input bắt buộc | Không |
| BLOCKED | Có failed test hoặc dependency chưa đạt | Không |
| PASS | Tất cả required tests/checks pass trên commit/config chỉ định | Có, nếu dependencies và rollout authorization cũng đạt |
| FAIL | Đã kiểm định và không đạt | Không |
| NOT_APPLICABLE | Không áp dụng, có rationale theo policy | Chỉ khi check được định nghĩa optional/not applicable |

Gate tổng hợp không lấy majority pass. Một required FAIL/ERROR/NOT_RUN chặn gate. Gate artifact quality khác job Completed: completed job chỉ sau PaperLoop, .NET final validation và final transaction.

## 2. Evidence bundle và runner contract

Mỗi phase dùng `artifacts/refactor/phase-NN/` với:

- `gate.json`: phase/gate ID, git SHA, status, dependencies, required test IDs, results, evidence paths và limitations.
- `commands.jsonl`: exact commands đã chạy, UTC time, working directory, exit code; không lưu secret.
- Test reports JUnit/TRX/JSON theo repo, tổng run/pass/fail/skip và duration; required tests skip phải bị chặn.
- Fixture/corpus/config hashes; schema/policy/prompt/evaluator/model/provider versions.
- Contract snapshot/diff, migration logs, fault/replay traces, metrics report tùy phase.
- Reviewer findings và ticket references cho scope còn thiếu.

G00 implement runner như `scripts/refactor/verify_phase.py --phase NN` hoặc target tương đương theo repository. Đây là command đề xuất cần xây, không tuyên bố đã tồn tại. Runner chọn đúng tests theo manifest, phát hiện zero-tests-collected, unexpected skip, non-zero exit và missing evidence; không tự động stamp PASS từ lệnh build thành công.

Các lệnh test chính xác (pytest/dotnet/frontend/lint/typecheck/migration) lấy từ repo inventory. Dùng existing scripts/lockfiles; không tự thêm Make/Poetry/npm version requirements ngoài task. Live evaluation chạy qua runner riêng với service credentials và capped budget, secret ở env manager.

## 3. Traceability của gate

| Gate | Phải chứng minh | Loại evidence chính |
|---|---|---|
| G00 | Baseline API/policy/workflow thật | Snapshots, recordings, source→symbol inventory |
| G01 | Schema/model/policy cross-language | JSON round-trips, ADR, boundary fixtures |
| G02 | Transaction, ack, fencing, durable resume | PostgreSQL integration fault tests, constraints |
| G03 | Provider parity, bounded retry/shared budget | Fake transport + live configured-model smoke |
| G04 | Source security/provenance/verified claims | Network security cases, offsets/entailment labels |
| G05 | Feasible blueprint và policy counts | Rejected/accepted source plans, Python/.NET parity |
| G06 | Terminating runtime và fresh dependencies | State coverage, kill/resume, no-progress tests |
| G07 | Evaluator quality + scoped repair | Held-out labels, confusion matrix, repair diffs |
| G08 | Approved grounded passage | Fidelity corpus, paired benchmarks, passage resume |
| G09 | Six-type candidates/group selection | Pools, hard filtering, constrained selection |
| G10 | Blind input và uniqueness checks | Serialized requests, disagreement/adversary labels |
| G11 | Section invariants/locality/resume | Snapshot refs, section fault E2E |
| G12 | Full paper và exactly-once DB final graph | Worker integration, .NET final tests, transaction crash |
| G13 | Compatibility/stream/privacy/UI | Consumer tests, backpressure, UI smoke, secret scan |
| G14 | Durable feedback/curation/offline comparison | Edit transaction, export/hash/split, promotion report |
| G15 | Release quality, deletion, canary và rollback | All gates + release manifests + canary + deletion inventory |

Detailed TNN-xx tests nằm trong từng phase. Evidence references không được trỏ file không có hoặc response có signed URLs/secrets.

## 4. Acceptance thresholds đề xuất

Các threshold này là starting release criteria. Chốt/phiên bản hóa ở G00–G01 trước tuning; thay đổi sau benchmark cần ADR với rationale, report cả old/new criteria. Không hạ threshold chỉ để biến lỗi thành pass.

| Nhóm | Tiêu chuẩn | Điều kiện measurement |
|---|---|---|
| Deterministic hard invariants | 100% required fixtures pass; zero accepted invalid graph | Đủ boundaries/types/error paths, không chỉ happy path |
| Public API parity | 100% required contract cases pass | Consumer thực .NET, schema + NDJSON + statuses |
| Security | 100% deny fixtures blocked, zero unauthorized checkpoint writes/secret leaks | SSRF includes real redirect/rebinding transport path |
| Durability | Zero lost committed checkpoints; zero stale-epoch commits; zero duplicate final exams | Kill/fault tại mỗi transaction boundary trên PostgreSQL |
| Budget | Zero admissions vượt reserved parent hard caps; counters survive restart | Parallel requests + unknown provider outcome |
| Fidelity must-reject set | 100% critical known canaries rejected, tối thiểu 10 canary cases | Cases gồm invented quantities, causality, certainty, unmeasured outcomes |
| Semantic blocking recall | ≥95% tổng hợp trên labeled invalid items; từng type không dưới 90% | Held-out corpus, denominators và per-type report |
| Ambiguity detection | ≥90% recall trên ambiguous labeled subset | Labels curated, số cases và confidence intervals ghi rõ |
| False rejection | ≤10% valid labeled items bị blocking reject | Corpus ≥60 valid questions, 6 types |
| Full-paper invariants | 100% final accepted papers đạt counts/types/word ranges/fresh evaluations | Áp dụng bất kể overall success rate |
| Comparative valid-Draft rate | V2 không thấp hơn legacy trong paired sample; mọi failures có reason | ≥18 paired papers/engine, ≥6 source triples, các triples khác nhau |
| Comparative fidelity/ambiguity | V2 không kém legacy theo annotated report; must-reject set vẫn 100% | Blind editorial rubric, labels không dùng cho tuning |
| Latency | V2 P95 ≤1.5× legacy P95 và ≤configured hard run deadline | Cùng env/providers/corpus; initial cap proposed, chốt trước release |
| Cost/tokens | Median V2 billed/estimated token cost ≤2× legacy và mọi run trong cap | Usage unknown báo riêng, không coi estimate là billed actual |
| Manual workflow | 100% required CRUD/Draft/Publish/Retry/NeedsSources cases pass | E2E admin/gateway/backend |

Paired sample ≥18 là regression evidence khởi đầu, không statistical proof of superiority. P95 với sample nhỏ phải ghi sample size và raw distribution; production telemetry cập nhật sau rollout. Confidence intervals/repeated runs cần cho model nondeterminism; chạy critical semantic fixtures ít nhất 3 lần trên pinned configs, báo worst-run cùng aggregate. Các ratio performance/cost áp dụng ở G15; fidelity canaries không được trade off để tiết kiệm tokens.

Nếu legacy success rate 0 ở một fixture set, không dùng ratio để tuyên bố tốt hơn; report counts và evaluator rubric. Benchmark có invalid inputs tách khỏi eligible-source success-rate denominator.

## 5. Dataset yêu cầu

| Dataset | Minimum khởi điểm | Nội dung và split |
|---|---|---|
| Ingestion/security | ≥20 cases | Formats, license, 599/600/601, SSRF, redirects, caps, injection |
| Fidelity | ≥40 cases | Đúng/sai theo 5 issue families; ≥10 critical canaries subset |
| Question | ≥120 items | Mỗi type ≥10 valid +≥10 invalid; ambiguity/leakage/word limits/distractors/NG |
| Section graph | ≥12 cases | Good/bad counts/types/coverage/groups/stale refs |
| Paper graph | ≥12 cases | Good/bad numbering/word count/duplication/leakage |
| Paired end-to-end | ≥18 papers/engine | ≥6 distinct source triples, chia cân bằng topic/profile, seeds/settings frozen |
| Chaos | Toàn matrix bên dưới | Deterministic fake provider + real DB/process failures |

Split theo source family/hash; no overlap giữa dev và final holdout. Đầu vào, output, labels có license/provenance. Annotation lý do cụ thể theo question type, two-reviewer disagreement resolution cho ambiguous/critical labels khi có reviewers; nếu chỉ một reviewer phải nêu limitation, không ghi fabricated independent review.

## 6. Chaos và recovery matrix

| Fault | Checkpoint expectation | Forbidden outcome |
|---|---|---|
| Provider 429/retry-after | Intent/budget đã lưu; bounded delay/defer | Retry forever hoặc reset cap |
| Timeout sau cloud xử lý | UNKNOWN_OUTCOME giữ reservation | Claim chưa tốn tokens hoặc free duplicate call |
| Truncated/invalid JSON | Typed invalid output record | Accept partial/schema-invalid artifact |
| Evaluator exception | ERROR + bounded retry/escalate | Không issue = PASS |
| Crash trước artifact commit | Không advance head | Head trỏ thiếu payload |
| Crash sau commit trước ack | Replay cùng operation result | Duplicate version/reservation |
| Crash sau passage accepted | Resume questions | Re-generate passage không lý do |
| Crash tại Q17 | Reuse valid accepted previous Qs | Restart section/Q1 mặc định |
| Lease takeover | Epoch cũ mất write authority | Late provider result accepted bởi stale writer |
| Cancel giữa repair | Cancelled run vẫn terminal | Late completion ghi Completed |
| Stream drop/duplicate/reorder | Status/replay reconcile | Frontend/client nhầm incomplete thành completed |
| DB unavailable/outbox retry | Authoritative transaction/replay | Final graph half-written hoặc duplicate exam |
| Source replacement | Invalidate exact dependency closure | Reuse stale evidence/questions |
| Deployment version change | In-flight engine/config pinned | Old eval reused với new prompt/model version |

## 7. Repair locality và invalidation rubric

Mọi repair test lưu before/after `{artifactId,version,hash}` và dependency closure. Unrelated accepted artifacts giữ nguyên; impacted children stale tới khi rerun đủ evaluations. Summary text/blank sửa có thể invalidate group; passage sửa có thể invalidate cả section. Locality không có nghĩa giữ nguyên refs đã sai để tiết kiệm chi phí.

Cache key gồm exact payload/dependencies + schema/policy/evaluator/prompt/model config versions. Cache chỉ artifact evaluation, không quyền writer/lease/cancel state. Reuse output không bỏ qua authority check lúc commit.

## 8. Release-blocking conditions

- Accepted unsupported/contradicted/cause-overstated/uncertain-overstated/unmeasured outcome trên must-reject set.
- Schema/API break, invalid final exam, auto-publish hoặc stale dependency accepted.
- Lost checkpoint, duplicate final exam, stale writer commit, budget reset hoặc unauthorized store access.
- Required semantic/live/chaos checks NOT_RUN; missing artifact lineage; secret/thinking exposure.
- Legacy deletion khi callers/in-flight runs chưa migrate/drain; rollback chưa chứng minh tương thích schema.

Known cosmetic warnings có thể vào backlog nếu không tác động invariants; phải ghi owner/ticket và rationale. Không áp dụng ngoại lệ cho required quality/security/durability blockers.
