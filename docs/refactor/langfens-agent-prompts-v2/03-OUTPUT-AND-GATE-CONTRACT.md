# Hợp đồng thực thi, đầu ra và kiểm định — Prompt Pack V2

Đây là hướng dẫn cho coding agent trong repository Langfens thật. Bộ prompt không phải evidence implementation hoặc kết quả gate đã chạy. Plan gốc và Validation Matrix vẫn là source of truth về policies, test IDs và thresholds.

## 1. Thực thi đến kết quả

Làm công việc thực sự: reproduce → implement/fix → test → independent verify → fix findings → rerun impacted checks. Không kết thúc phase sau một báo cáo FAIL/BLOCKED nếu có thể sửa trong phạm vi được giao. Không dùng số vòng cố định, hết một lượt tool, hoặc độ dài phản hồi làm lý do dừng. Không cần xin lại xác nhận cho sửa code/test/config reversible đã được giao.

Nếu cách sửa đầu tiên thất bại, xác định nguyên nhân, thử cách khác có cơ sở và kiểm tra lại. Không lặp cùng patch/test vô ích. Giữ thresholds, required evaluators, hard invariants và golden labels; không làm test yếu đi để có PASS.

Khi nhiều attempts không tạo tiến triển, supervisor yêu cầu review root cause, thu nhỏ reproduction, đổi hypothesis hoặc chia lại task trước khi chạy tiếp. Nếu đã có evidence và không còn hướng khả thi trong tools/quyền/budget thực sự còn lại, ghi unresolved INTERNAL blocker và resumable handoff với các cách đã thử, quyết định kỹ thuật/input cần thiết và next executable experiment. Không đổi bế tắc nội bộ thành NOT_RUN_EXTERNAL và không tạo vòng lặp vô hạn chỉ để đáp ứng chữ “long-running”.

Chỉ handoff khi đã đạt đầu ra, có unresolved INTERNAL blocker đã được kiểm tra theo điều kiện ở trên, có dependency/credential/environment/budget/authorization thực sự ngoài khả năng xử lý, người dùng hủy, hoặc giới hạn nền tảng kết thúc phiên. Trước handoff, hoàn tất phần độc lập có thể làm và ghi checkpoint khôi phục được. Không coi implementation thiếu, harness chưa viết hay test chưa map là external blocker.

## 2. Long-running và agents

Supervisor giữ ownership, task graph, evidence và quyết định gate. Nếu spawn tools có sẵn, giao worker các phạm vi file rõ, test engineer giữ harness/tests, reviewer độc lập chỉ đọc implementation và viết findings/evidence vào thư mục được giao. Reviewer của một thay đổi không đồng thời là tác giả thay đổi đó. Có thể đổi vai người viết/người review giữa các nhóm để review chéo; độ độc lập này là về quy trình, không phải độc lập thống kê của cùng model.

Giới hạn concurrency theo slots, CPU/RAM, DB và budget thực sự có sẵn. Không chạy hai writers trên cùng file. Khi có giao nhau, supervisor tích hợp tuần tự. Tests/live benchmarks dùng DB/schema/temp paths và ports riêng hoặc serialize để tránh nhiễu.

Spawn agent cho nhiệm vụ cụ thể với inputs, files ownership, invariants, acceptance, output paths và handoff. Không spawn chỉ để chờ hoặc chép báo cáo. Nếu runtime không hỗ trợ subagents, thực hiện các vai tuần tự và nêu đúng limitation; không giả đã spawn hay independent review đã diễn ra.

Theo dõi running sessions/task IDs của tools; poll/await kết quả và exit codes. Tránh waits đơn lẻ vượt 60 giây; có update ngắn mỗi khoảng 60 giây về kết quả và bước xử lý. Không fire-and-forget tests/agents, không gọi process running là PASS, không hứa tiếp tục sau khi phiên kết thúc khi chưa có cơ chế chạy nền thực sự.

Agent execution dài không làm tăng runtime caps của production (vẫn giữ nguyên hard caps 15 calls / 60k tokens / 300s cho production và các provider khác).

Chính sách benchmark MiniMax tự động và caps (mặc định toàn bộ các phase):
1. Live benchmark bắt buộc tự động khởi chạy và resume bằng provider MiniMax đã cấu hình; loại bỏ hoàn toàn phê duyệt thủ công của operator, authorization-file, phê duyệt campaign-budget và trạng thái chờ PENDING_AUTHORIZATION.
2. Vô hiệu hóa toàn bộ call, token, monetary và wall-time caps do ứng dụng áp đặt cho MiniMax BENCHMARKS ở cả campaign và child-run level (cấu hình explicit unlimited; ngăn chặn fallback về 15 calls / 60k tokens / 300s).
3. Duy trì xác thực service, CAS/fencing, cancellation, truthful usage accounting, checkpoints, idempotent resume, bounded retries và per-request output/context limits; tôn trọng giới hạn thực tế phía provider.
4. Live campaigns có campaignId/caseId, manifest/status và reservation persisted; sau restart/lost transcript thì reconcile status trước retry, không lặp lại tốn phí.
5. Chính sách này áp dụng mặc định cho tất cả các phase còn lại, ngăn quy trình phê duyệt thủ công xuất hiện lại.
## 3. Preflight và snapshot thật

Đọc AGENTS.md/CLAUDE.md áp dụng; khám phá actual paths/scripts/lockfiles; giữ changes của user. Không tự reset/stash/clean. Trước sửa, bind PNN work packages và TNN IDs vào symbols/tests thực tế.

Ghi HEAD, tracked dirty diff hash, relevant untracked file hashes, effective config/policy/caps/model/prompt/evaluator versions và fixture/corpus hashes. Chỉ HEAD giống nhau không chứng minh tests chạy trên cùng code. Không đưa secrets/raw reasoning vào diff/evidence công khai.

Gate cũ chỉ reuse khi input/code/config compatibility có evidence. Rerun impacted checks khi thay shared providers, contracts, evaluators, persistence hoặc runtime; không rerun mọi thứ tùy tiện. Release cuối phải có required release matrix trên candidate cuối.

## 4. Gate và coding readiness

Dùng enums/schema canonical của repo/plan, không tự thay gate schema. Kết luận PASS chỉ khi tất cả required checks có evidence hợp lệ, dependencies đạt và đúng candidate snapshot. Required FAIL/ERROR/NOT_RUN/missing result/unexpected skip/zero-tests-collected chặn gate. Optional/N/A phải có rationale theo policy đã định nghĩa.

Tách implementation, deterministic/integration, corpus integrity, live smoke, semantic quality và deployment observation. NOT_RUN_EXTERNAL chỉ cho prerequisite external thực sự thiếu. Test/harness chưa triển khai là NOT_RUN/BLOCKED; corpus leakage là integrity FAIL; đã chạy dưới threshold là FAIL. Smoke PASS không thay semantic benchmark. Real DB + fake provider không thay live model quality.

Thiếu external quality evidence vẫn có thể coding phần downstream độc lập bằng fakes theo plan, nhưng không promote gate, không accept production artifact/final Draft từ unverified dependency và không gọi downstream đã nghiệm thu. Fake artifacts được dùng trong test environment phải ghi rõ simulation.

Tách biệt phục hồi cục bộ và gate: Kết quả phục hồi độ bền cục bộ (như R05 QuestionCandidateLoop durability trên PostgreSQL thật) có thể PASS độc lập trong khi gate tổng thể (G09) vẫn giữ nợ chất lượng upstream/live-quality (G07/G08 prerequisites). Tuyệt đối không promote gate chỉ vì đã dỡ bỏ rào cản phê duyệt; việc đạt gate vẫn bắt buộc có bằng chứng live benchmark đạt ngưỡng chất lượng.
## 5. Đầu ra bắt buộc của một phase

Lưu theo conventions hiện có trong `artifacts/refactor/phase-NN/`. Cần có:

- `gate.json`: canonical gate report; dependency/results/evidence links trên snapshot thật.
- `phase-report.md`: behavior đã thay đổi; PNN→files/symbols; đầu ra domain và limitation; next executable action.
- `test-report.json` hoặc native reports: TNN→test node/command; số IDs và số cases riêng; pass/fail/skip; duration/exit codes.
- `commands.jsonl`: exact command, cwd, start/end UTC, exit code, sanitized output/report refs.
- `snapshot-manifest.json`: code/config/corpus/versions và relevant hashes.
- `fix-log.jsonl`: finding → repro → root cause → fix attempted/implemented → verification → regression scope → outcome.
- `independent-review.md`: actual reviewer/role, inspected snapshot, findings và limitations của review.
- `resume.md`: completed work, open blockers, latest hashes, outstanding task/session IDs, next commands và pinned inputs. Cập nhật trước context/turn handoff.

Có thể map sang artifacts canonical tương đương đã tồn tại; không tạo schema/report thứ hai gây lệch. Report phải dựa file/log thực sự tồn tại; không điền template như thể tests đã chạy.

## 6. Khi chưa đạt phải có hướng giải quyết

Với mỗi finding/blocker, cung cấp đầy đủ:

1. ID/severity, affected gate/invariant và exact symptom.
2. Reproduction command + expected/observed + evidence.
3. Root cause đã chứng minh hoặc hypothesis + check để phân biệt.
4. Fix đã thực hiện và result; nếu chưa fix, concrete code/config/data work còn thiếu, file/symbol scope, acceptance và regression tests.
5. Nếu còn external blocker: exact missing input, vì sao không tự giải quyết, bước setup cụ thể, nơi cấu hình secret an toàn, next command sau unblock và estimate/capped execution plan khi có cơ sở.
6. Phần tiếp tục độc lập, owner/agent và dependency bị giữ.

Không kết thúc với mỗi câu “cần API key”, “cần corpus”, “cần Phase 10” hoặc “đề nghị nghiên cứu thêm”. Khảo sát configured provider/environment trước; viết harness và làm sạch corpus trong khả năng; đưa executable remedy. Không yêu cầu user paste key vào chat, không fabricate credentials/labels/measurements.

## 7. Invariants và measurement

Giữ authoritative .NET persistence, exact artifact refs, immutable versions, CAS/fencing/cancel, idempotent operations, unknown-outcome reservation, shared persisted caps, dependency invalidation và manual Draft/Publish.

Canonical required evaluations phải đủ/fresh trước acceptance. Unsupported artifact type/missing source/incomplete semantic coverage không thành PASS. Không self-ground bằng generated text. Generator alignment/rhetorical labels là proposals, không proof.

Source/provenance/license/SSRF protections và policy Langfens giữ nguyên. Output JSON hợp cú pháp không chứng minh domain-valid; envelope tag không tự bảo đảm injection safety. Blind solver không nhận expected keys/hidden explanations. Không dùng heuristic/evaluator đang kiểm định làm gold source tự chứng minh.

Thresholds lấy Validation Matrix, không hạ sau measurement: hard invariants 100%; critical fidelity canaries 100%; semantic recall ≥95% tổng, từng type ≥90%; ambiguity recall ≥90%; false rejection ≤10%. Critical semantic fixtures ≥3 runs, aggregate + worst run. Corpus/splits pin trước tuning, source families/near duplicates không overlap.

Full paper: 3 sections; 40 contiguous questions; section counts 13/13/14 với type distribution theo plan; passage 720–915 words mỗi section; tổng 2150–2750; zero stale/missing required evaluation. Full-paper performance criteria áp dụng ở release, không giả kết quả ở phase chưa có paper engine.

## 8. Bàn giao gọn nhưng đủ

Final response của coding agent: phase/scope, kết quả gate trên snapshot, behavior/files, tests/evidence, fixes thực hiện, blockers + concrete remedy, readiness tiếp theo. Nếu đã được giao nhiều phases và còn tiến hành được, update phase rồi tiếp tục; không dừng để hỏi “có làm tiếp không?”. Production rollout chỉ theo operational authorization thực sự có; hoàn thành reviewable code/staging/runbook trước bước bị giới hạn.
