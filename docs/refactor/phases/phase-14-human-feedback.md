# Phase 14 — Human feedback và offline evaluation

Phụ thuộc: **G02, G07, G12–G13**. Gate: **G14**. Hai prompts bao gồm vòng sửa, không chỉ nghiệm thu bằng báo cáo.

## A. Implementation và remediation

```text
Hoàn thành Phase 14 Langfens Loop Engine V2: feedback capture, curation/export, offline comparisons và reviewed promotion. Chưa làm Phase 15.

Đọc repo instructions, master/matrix, Phase 14 gốc, 03-OUTPUT-AND-GATE-CONTRACT.md và G02/G07/G12–G13. Bind actual edit endpoints/UI/transactions/scripts. Giữ user changes; verify dependencies trên HEAD + dirty/untracked/config hashes. Missing upstream quality vẫn chặn gate; code độc lập với simulated data phải ghi simulation rõ.

Supervisor giao .NET feedback capture, UI/reason taxonomy, dataset/export workers theo file ownership; test engineer dùng real DB và CRUD path; independent reviewer không viết implementation đang review. Spawn nếu supported; otherwise làm tuần tự và ghi limitation. Serialize shared edits/DB tests. Await/poll long-running comparisons/tests tới exit, update khoảng 60 giây. Tiếp tục reproduce→fix→test→review→fix→retest, không dừng với findings còn tự sửa được.

Hoàn thành/map P14-01..10:
- P14-01: stable generated→editorial exam/entity mapping, exact artifact refs và lineage.
- P14-02: immutable feedback gồm before/after refs, diff/hash, editor, timestamp, reasons/comment; generated và human answers tách riêng.
- P14-03: reason taxonomy unsupported claim, ambiguity, too direct/easy, distractor/style/typo/policy/source-license. Too easy là editorial label, chưa calibrated difficulty.
- P14-04: actual accept/reject/edit/publish UX; small-edit reason theo policy; manual CRUD không cần LLM hoạt động.
- P14-05: capture mọi existing manual CRUD path sửa generated Draft, không chỉ special buttons. Mutation+feedback/outbox atomic hoặc idempotent consumer; retry/conflict/rollback không duplicate/orphan record. Manual exams không lineage không tạo fake GenerationRun.
- P14-06: raw→annotated/reviewed/conflict-resolved→curated workflow có audit; publish/edit không tự trở thành ground truth.
- P14-07: reproducible export có dataset version/hash, exact lineage, source rights, labels, partition manifest; remove secrets/unneeded PII. Solver benchmark view không lộ expected keys.
- P14-08: split source-family/hash/near-duplicate connected groups trước tuning; related edits/variants cùng partition. Không đổi family IDs để che leakage.
- P14-09: old/candidate prompt/evaluator/model paired comparison trên frozen corpus; live benchmark tự động khởi chạy và resume bằng provider MiniMax đã cấu hình (loại bỏ phê duyệt thủ công, authorization-file hay chờ PENDING_AUTHORIZATION; unlimited benchmark caps; production profile giữ nguyên); report regressions, denominators và hard-gate failures.
- P14-10: reviewed code/config promotion có version pinning/rollback; new runs nhận version mới, in-flight/cache giữ pinned inputs. Không production job/endpoint tự deploy prompts từ raw edits.

Giữ canonical models, authoritative .NET persistence, immutable versions/CAS, writer fencing, cancellation, budgets/deadlines và manual Draft/Publish. Offline execution dài vẫn có caps, không free cloud retries. Heuristic/evaluator đang test không làm gold labels; giữ annotation provenance và reviewer limitation thật.

Implement/map và chạy T14-01..08: exact edit diffs/impact; retry/conflict idempotency; rollback; manual no-lineage; raw/curated separation; clean split; hard-gate promotion rejection; staging pinned-version update. Exercise actual admin/API→.NET transaction→DB/outbox→curation/export path, không isolated record objects.

Fix findings rồi rerun impacted G02/G12/G13 CRUD/transaction/contract checks và independent review. Synthetic fixtures được phép chứng minh behavior nhưng không mô tả là production feedback đã thu được. Không fabricate human review hoặc live comparison.

Lưu artifacts/refactor/phase-14/ bundle: gate, phase/test reports, commands, snapshot manifest, fix log, independent review, resume. Thêm sanitized examples, SQL/fault traces, annotation audit, export/split manifests, paired offline report và staging promotion/rollback evidence.

G14 PASS khi required outputs/tests/dependencies đạt, export reproducible và không auto-promotion path. Nếu external prerequisite thiếu, hoàn tất code/harness/export checks độc lập; ghi exact input/setup/secret location an toàn, owner, actual next command, acceptance và capped execution plan. Không chỉ báo “thiếu corpus”; curate/build trong khả năng và chỉ rõ phần cần independent labels thật. Bàn giao fixes, evidence, status và readiness Phase 15.
```

## B. Independent verify và vòng sửa

```text
Supervisor kiểm định độc lập Phase 14 và điều phối sửa/retest. Đọc plan/matrix/03-OUTPUT-AND-GATE-CONTRACT.md và G02/G07/G12–G13 evidence; reviewer read-only implementation, code owner làm fixes.

Spawn reviewer/test roles nếu available; sequential fallback ghi limitation, không giả independent human review. Poll/await real long-running tasks tới exit; mọi actionable finding phải có reproduction, implemented remedy và retest trước handoff.

Audit tất cả admin/edit entrypoints, gồm generated Draft sửa qua existing manual CRUD. Trace API/UI→authorization→.NET mutation/feedback transaction→outbox→curation/export. Kiểm tra snapshot code/config/data versions và immutable record visibility.

Chạy đủ:
T14-01: Q17/answer/option/passage edit có exact before/after/diff/impact.
T14-02: retry một committed edit tạo một feedback; conflict không record giả.
T14-03: transaction rollback không orphan feedback/outbox.
T14-04: no-lineage manual exam vẫn CRUD/publish; không fake run.
T14-05: raw labels không tự vào gold set; curation audit đúng.
T14-06: source-family/near-duplicate split thật không leakage.
T14-07: candidate thua hard gate không được promote dù soft metrics tốt.
T14-08: staging new version cho new runs; in-flight/cache giữ version cũ, rollback compatible.

Rerun export trên cùng frozen snapshot: hash/content reproducible theo schema. Inspect labels/provenance/source rights/privacy và full serialized blind benchmark inputs; generated/human keys không leak. Search production routes/jobs/config writers: raw feedback không tự deploy prompt/model/evaluator.

Offline quality checks dùng thresholds đã pin, không đổi labels sau measurement để mở gate. Report synthetic data, single-reviewer limitation, unknown usage và absent live checks đúng trạng thái. Real DB tests không thay live semantic benchmark. Inspect required skip/zero collected/nonzero exit/missing reports.

Route findings tới owner sửa và reviewer verify snapshot mới, rerun impacted CRUD/fencing/transaction suites. Lưu canonical phase-14 bundle, actual commands/exit codes/hashes và final review. Mỗi remaining blocker cần exact symptom/repro/root cause, fix đã thử, files/input/setup/owner, next command và acceptance; không chỉ backlog chung.

Kết luận implementation, transactional capture, corpus/export integrity, offline evidence và G14/Phase15 readiness riêng. PASS chỉ khi toàn required scope đạt; không tuyên bố production dataset tồn tại từ test fixtures.
```
