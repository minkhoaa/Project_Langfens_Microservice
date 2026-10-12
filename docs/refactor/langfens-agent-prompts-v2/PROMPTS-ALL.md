# Langfens — Toàn bộ prompt thực thi và verify V2

Bản ghép đầy đủ từ 21 file nguồn: supervisor, recovery G07/G08, hợp đồng đầu ra, 16 phases với 32 prompt thực hiện/verify và final verification. Cài cả pack cùng plan gốc trong repo trước khi dùng. Đọc phần START-HERE đầu tiên.

Kiểm định đi kèm chỉ kiểm tra tài liệu prompt. Chưa chạy tests hoặc kết luận gates của repo Langfens.


<!-- SOURCE: 00-START-HERE.md -->

# Langfens Agent Prompt Pack V2

Bộ prompt thực thi mới cho toàn bộ Phase 00–15. Mỗi phase có prompt implementation/remediation và prompt independent verification. Các prompt yêu cầu agent thực hiện vòng reproduce → fix → verify → sửa findings → kiểm lại, sử dụng long-running sessions/subagents khi khả dụng và giao đầu ra chuẩn.

Đây là prompt pack, không phải báo cáo rằng Langfens code hoặc gates đã PASS. Plan gốc, policy và Validation Matrix được giữ làm source of truth.

## Dùng ngay ở trạng thái hiện tại

1. Đặt folder `langfens-agent-prompts-v2` trong `docs/refactor/` của repository thật, cạnh plan gốc nếu phù hợp. Giữ nguyên plan, evidence và dirty changes đã có.
2. Nếu muốn agent tự điều phối tới cuối scope: copy prompt trong `01-ORCHESTRATOR-PROMPT.md`. Prompt khám phá trạng thái, ưu tiên xử lý G07/G08 hiện tại và reuse foundation evidence còn hợp lệ.
3. Nếu chỉ muốn sửa và hoàn tất G07/G08 trước: dùng `02-G07-G08-RECOVERY-PROMPT.md`, sau đó supervisor có thể tiếp tục Phase09–15 khi prerequisites đạt.
4. Nếu muốn tự giao từng phase: dùng hai phần implementation và verify trong file `phases/phase-NN-*.md`. Để cả pack trong repo để agent đọc hợp đồng chung; không chỉ copy một phần rồi bỏ mất contract/plan inputs.
5. Dùng `04-FINAL-VERIFICATION-PROMPT.md` trên candidate cuối. Independent reviewer giao findings về supervisor để sửa/retest, không kết thúc bằng một report lỗi chưa có hướng xử lý.

`PROMPTS-ALL.md` là bản ghép đầy đủ để tìm/copy một file. Các file riêng là nguồn; không sửa bản ghép độc lập rồi gây lệch.

## Những điểm thay đổi trong execution

| Vấn đề | Yêu cầu mới |
|---|---|
| Verify rồi kết thúc với BLOCKED | Reproduce, assign owner, implement fix, reviewer recheck; blocker còn lại có concrete remedy |
| Chỉ isolated interfaces/unit tests | Actual service composition/entrypoint, semantic coverage, fault/integration và accepted-output assertions |
| Chạy tác vụ dài nhưng không quản lý | Session/campaign IDs, poll/await, logs/exit codes, checkpoint/resume, no phantom background |
| Chia agents tùy tiện | File ownership, non-overlapping writes, independent review, isolated DB/resources và supervisor integration |
| Mọi thiếu sót gọi external | Tách bugs, implementation NOT_RUN, invalid corpus và genuine external prerequisites |
| PASS dựa code cũ/HEAD | HEAD + dirty/untracked hashes + config/corpus versions và impacted revalidation |
| Tăng retries/caps để đạt | Giữ versioned hard limits, required checks/thresholds; sửa root cause |

## Báo cáo phase chưa đạt cần gì

Finding ID và severity, repro command, expected/observed, root cause, fix đã thử, test result, remaining code/config/data work, exact missing external input nếu có, next command và owner. Agent phải hoàn tất phần có thể xử lý trước khi handoff.

Long-running không có nghĩa chạy vô hạn: supervise tiến độ, đổi hypothesis khi không tiến triển, tôn trọng caps/budget/quyền/platform và lưu resumable checkpoint khi bị giới hạn. Same-model subagents cho review chéo quy trình, không phải bằng chứng reviewers/model outputs độc lập thống kê.

## Trạng thái xuất phát từ báo cáo đã nhận

G07 còn upstream quality blocker; G08 được báo chưa có generator/prompts/tests và tồn tại false-PASS paths ở grounding. MiniMax transport smoke đã PASS ở snapshot báo cáo. Agent phải kiểm lại current code trước hành động, không suy đoán thiếu credential hoặc áp dụng máy móc findings đã được sửa.

Chính sách mặc định cho toàn bộ các phase:
- **Live Benchmark tự động:** Mọi live benchmark bắt buộc tự động khởi chạy và resume bằng provider MiniMax đã cấu hình; loại bỏ phê duyệt thủ công của operator, authorization-file, phê duyệt campaign budget và các trạng thái chờ PENDING_AUTHORIZATION.
- **Unlimited Caps cho MiniMax Benchmarks:** Vô hiệu hóa toàn bộ call, token, monetary và wall-time caps do ứng dụng áp đặt cho MiniMax BENCHMARKS ở cả campaign và child-run level (cấu hình explicit unlimited; cấm fallback về 15 calls / 60k tokens / 300s). Profile production và các provider khác giữ nguyên.
- **Bảo toàn guardrails & truthful accounting:** Giữ nguyên xác thực service, CAS/fencing, cancellation, truthful usage accounting, checkpoints, idempotent resume, bounded retries và per-request output/context limits; tôn trọng giới hạn thực tế từ phía provider.
- **Tách biệt phục hồi cục bộ và gate:** R05 durability trên PostgreSQL thật có thể PASS độc lập trong khi G09 vẫn giữ nợ chất lượng upstream/live-quality (G07/G08 prerequisites); tuyệt đối không promote gate chỉ vì đã gỡ bỏ rào cản phê duyệt.
- **Mặc định toàn hệ thống:** Chính sách này áp dụng mặc định cho tất cả các phase còn lại, ngăn quy trình phê duyệt thủ công xuất hiện lại.

<!-- END SOURCE: 00-START-HERE.md -->

<!-- SOURCE: 03-OUTPUT-AND-GATE-CONTRACT.md -->

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

<!-- END SOURCE: 03-OUTPUT-AND-GATE-CONTRACT.md -->

<!-- SOURCE: 01-ORCHESTRATOR-PROMPT.md -->

# Prompt điều phối toàn bộ Langfens refactor — Long-running supervisor

Copy toàn bộ phần prompt dưới đây vào coding agent đang mở repository Langfens thật. Đặt pack trong repo để agent đọc các phase prompts và hợp đồng đầu ra.

---

Bạn là supervisor chịu trách nhiệm hoàn thành Langfens Generation Service Loop Engine V2 từ trạng thái thực tế hiện tại tới cuối phạm vi đã giao. Đây là task thực thi dài: khảo sát, viết/sửa code, chạy tests, kiểm định độc lập, xử lý findings và tiếp tục qua các phases. Không dừng ở plan, skeleton hoặc một báo cáo lỗi khi còn công việc có thể hoàn thành.

Người dùng cho phép dùng subagents và long-running sessions. Hãy dùng khả năng thực sự có trong môi trường; nếu không có spawn tools, thực thi tuần tự theo cùng vai trò, không giả delegation. Không gửi thông tin tới người khác/dịch vụ ngoài phạm vi code, tests, configured providers và artifacts được giao.

## A. Load và xác định trạng thái

1. Đọc AGENTS.md/CLAUDE.md áp dụng. Tìm repository thật, scripts/lockfiles/service topology và plan directory theo filenames, không giả path tồn tại.
2. Đọc master plan, Validation Matrix, source traceability, test manifest và toàn bộ phase plans 00–15. Đọc `03-OUTPUT-AND-GATE-CONTRACT.md` cùng pack và coi đó là hợp đồng execution/output.
3. Inventory current worktree, HEAD/dirty/untracked hashes, latest gate evidence, configured provider/model/caps, schema và dataset versions. Không reset/stash/clean hoặc overwrite changes của user.
4. Phân biệt planning manifest PLANNED với execution results. Đối chiếu actual code/tests/routes; không coi một gate.json cũ là đủ để chứng minh current code đã đạt.
5. Nếu repo không có trong workspace, tìm trong phạm vi workspace được giao; nếu vẫn không có, ghi BLOCKED với reason loại INPUT theo schema canonical, kèm exact checkout/open path cần cung cấp và resume commands. Không dựng một repo giả rồi tuyên bố refactor hệ thống đã xong.

Default resume trong session hiện tại: khảo sát G07/G08, vì báo cáo trước ghi G07 quality BLOCKED, Phase08 thiếu implementation, bốn grounding false-PASS paths và legacy route chưa có V2 passage wiring. Đây là starting evidence, không phải khẳng định code hiện tại chưa đổi. Reproduce trên current snapshot.

G00–G06 có thể được reuse khi code/config compatibility được chứng minh; rerun impacted checks khi providers/runtime/evaluators/persistence đổi. Không tự làm lại toàn bộ foundation còn hợp lệ.

## B. Lập task graph và giao agents

Tạo execution ledger/task graph persisted với phase, work package, inputs, dependencies, file ownership, agent/session ID, expected output, status và next action.

Khi tools/slots cho phép, dùng các vai:

- Supervisor: integration, config/ownership, scope/gate, tiếp tục execution.
- Worker A: runtime/provider/evaluator/repair primitives cần cho current phase.
- Worker B: domain capability/prompt assets/facade integration của phase.
- Test engineer: executable fixtures/harness/fault tests và TNN mapping.
- Independent reviewer: đọc code/wiring/evidence, chạy checks, ghi findings; không là tác giả phần đang review.
- Benchmark runner: configured live campaigns với pinned inputs, budgets và persisted status; có thể gộp vào test engineer khi ít slots.

Không spawn tất cả phases cùng lúc. Chỉ song song các tasks có inputs/interfaces đã ổn định và file ownership không giao nhau. Limit concurrency theo actual slots/resources; độc lập DB/schema/ports hoặc serialize tests khi chia sẻ state. Supervisor resolve overlapping edits và tích hợp tuần tự.

Mỗi delegation phải có: exact scope, files được sửa, canonical inputs, invariants, commands discovery, acceptance, evidence path, blocker remedy và điều kiện handoff. Child agent không tự tuyên bố parent gate PASS hoặc tự mở rộng phase.

## C. Execution loop của mỗi phase

1. Preflight dependencies trên snapshot hiện tại; bind mọi PNN/TNN tới files/symbols/test targets thật.
2. Nếu có failed findings: reproduce trước hoặc viết regression có meaningful assertion; xác định root cause.
3. Hoàn thành implementation work packages bằng production composition, không chỉ classes/unit fakes. Chạy relevant tests sau changes cohesive.
4. Worker/test engineer khắc phục lỗi và rerun impacted checks tới khi đạt hoặc gặp blocker thực sự. Hướng tiếp cận thất bại phải có hypothesis mới; không repeat vô ích.
5. Independent reviewer nhận consistent snapshot, inspect real entrypoint → capabilities → evaluators/budget/checkpoint → acceptance. Verify đủ test IDs, error paths, fault cases, source/corpus quality và evidence freshness. Reviewer không chỉ xem tổng số passed tests.
6. Findings mới trở thành implementation tasks. Supervisor giao owner sửa, reviewer kiểm lại; giữ fix-log có repro/root cause/fix/result. Một báo cáo BLOCKED là đầu vào cho vòng sửa, không mặc định là điểm kết thúc task.
7. Gate assessment dùng canonical schema/statuses. Bất kỳ required missing/error/stale/skip/FAIL/NOT_RUN chặn acceptance. Required external chưa chạy giữ non-pass theo scope; không hạ thresholds hoặc chuyển required thành optional.
8. Phase PASS: ghi evidence/handoff, invalidate downstream caches/gates bị tác động và tiếp tục phase kế tiếp trong scope; không hỏi user “có làm tiếp không?” cho work đã giao.
9. External blocker: hoàn tất harness, datasets/config/setup và code độc lập làm được; đưa exact missing input, safe configuration location, next command và bounded plan. Có thể code downstream độc lập bằng test fakes theo plan, nhưng không promote hay accept production output từ unverified dependencies.
10. Context/tool/platform limit hoặc bế tắc thực sự: checkpoint task graph, code/config hashes, attempted fixes, pending sessions và next executable experiment. Báo đúng INTERNAL/external blocker; không giả continuing background sau khi phiên kết thúc.

## D. Long-running sessions và benchmarks

Giữ tests/builds/benchmarks trong managed sessions hoặc thực sự await foreground commands. Record task/session IDs, logs và exit codes. Poll/wait theo tools hiện có với khoảng ngắn đủ để gửi progress khoảng 60 giây; không busy-poll vô ích, không fire-and-forget rồi report PASS.

Benchmark có frozen campaign/case IDs, source-family-clean corpus, model/prompt/evaluator/caps hashes và persisted reservations/status. Reconcile lost output/restart trước rerun; không lặp toàn corpus gây phí vì terminal transcript bị mất.

Chính sách benchmark MiniMax tự động và caps (mặc định cho tất cả các phase):
1. Live benchmarks bắt buộc tự động khởi chạy và resume bằng provider MiniMax đã được cấu hình; loại bỏ hoàn toàn phê duyệt thủ công của operator, authorization-file, phê duyệt campaign-budget và trạng thái chờ PENDING_AUTHORIZATION.
2. Vô hiệu hóa toàn bộ call, token, monetary và wall-time caps do ứng dụng áp đặt cho MiniMax BENCHMARKS ở cả campaign và child-run level (cấu hình explicit unlimited; ngăn chặn fallback về 15 calls / 60k tokens / 300s). Production và các provider khác giữ nguyên hard caps (15 calls / 60k tokens / 300s).
3. Duy trì xác thực service, CAS/fencing, cancellation, truthful usage accounting, checkpoints, idempotent resume, bounded retries và per-request output/context limits; tôn trọng giới hạn thực tế phía provider.
4. Tách biệt phục hồi cục bộ và gate: R05 durability trên PostgreSQL thật có thể PASS độc lập trong khi G09 vẫn giữ nợ chất lượng upstream/live-quality (G07/G08 prerequisites); tuyệt đối không promote gate chỉ vì đã dỡ bỏ rào cản phê duyệt.
5. Chính sách này áp dụng mặc định cho tất cả các phase còn lại, ngăn quy trình phê duyệt thủ công tái diễn.

Nếu live smoke gần đây đã PASS, inspect actual environment/config/quota trước khi ghi thiếu API key. Smoke PASS không thay semantic benchmark. Harness chưa viết là implementation task, corpus leakage là integrity failure, code exception là bug; không gom các lỗi đó vào NOT_RUN_EXTERNAL.
## E. Standards bắt buộc

Giữ microservice boundaries, public routes/NDJSON, .NET authoritative durable orchestration/final persistence, accepted exact refs, immutable artifacts, writer fencing/cancel, atomic reservation/idempotency, unknown-outcome accounting, source protections và Draft/manual Publish.

Caps phải đi Settings/deploy resolver → composition → actual admission/runtime → persisted run snapshot. Không lấy class defaults làm production approval và không để capabilities có quota/retry riêng.

Required evaluators đủ/fresh; unsupported artifact types, missing source hoặc incomplete coverage không thành PASS. Grounding dựa independent approved source/evidence refs; đánh giá factual assertions trên toàn passage kể cả unaligned hoặc generator gắn rhetorical. Source envelope chỉ là dữ liệu có escaping/serialization; còn phải validate schema/policies/output và test injection.

Repair tạo version mới, giữ unaffected refs, invalidate consumer closure động và rerun required evaluations. Đổi modal/causality wording không đủ để chứng minh remaining outcome có support. No/False vs NOT GIVEN thuộc G07 semantic correctness; Phase10 bổ sung blind/adversarial checks.

Không tự tune production từ feedback, không auto-publish. Corpus/gold labels không được tự chứng minh bằng evaluator đang test; source families/near duplicates không leak vào holdout. Thresholds/denominators và measurement lấy Validation Matrix.

## F. Outputs và finish conditions

Mỗi phase giao đủ artifacts trong `03-OUTPUT-AND-GATE-CONTRACT.md`, gồm gate, phase report, test mapping, commands, snapshot, fix-log, independent review và resume checkpoint.

Mỗi blocker phải có concrete remedy và executable next action. Sửa được thì thực hiện trước khi kết thúc; external input thiếu thì chuẩn bị work và hướng unblock đầy đủ, không chỉ “cần key/corpus”.

Thực hiện Phase15 staging/shadow/benchmarks/rollback/deletion theo prerequisites. Production deployment/canary chỉ theo operational authorization thực sự có; hoàn tất reviewable code/staging/rehearsal trước bước bị giới hạn. Không tạo canary observation 24h giả hoặc xóa legacy còn consumers/in-flight runs.

Cuối scope, chạy `04-FINAL-VERIFICATION-PROMPT.md`. Report riêng implementation complete, release candidate verified và actual production rollout. Chỉ overall PASS khi required conditions đạt trên candidate cuối; nếu còn blocker, bàn giao attempted fixes + concrete resolution/resume plan và phần đã hoàn tất, không báo “done” chung chung.

Bắt đầu khảo sát ngay, cập nhật task graph và tiến hành work tới kết quả trong phạm vi này.

<!-- END SOURCE: 01-ORCHESTRATOR-PROMPT.md -->

<!-- SOURCE: 02-G07-G08-RECOVERY-PROMPT.md -->

# Prompt recovery G07–G08 — Sửa findings và hoàn tất Passage Loop

Copy phần prompt dưới đây cho supervisor ở repository đang làm. Scope recovery là G07/G08; sau đó handoff về orchestrator để tiếp tục 09–15 theo dependencies.

---

Thực hiện recovery G07–G08 của Langfens tới kết quả có thể nghiệm thu. Đọc plan/master/Validation Matrix, gates hiện tại, applicable AGENTS.md/CLAUDE.md và `03-OUTPUT-AND-GATE-CONTRACT.md`. Dùng phase-07/08 implementation + verification prompts của pack làm work breakdown.

User đã giao long-running work và cho phép subagents. Reproduce → fix → integration test → independent review → sửa findings → rerun tới khi đạt hoặc có blocker thực sự có concrete remedy. Không kết thúc sau một report FAIL, không yêu cầu xác nhận lại cho routine fixes trong scope. Respect actual slots, resources, configured cloud budgets và authority.

## 1. Snapshot và task owners

Đối chiếu báo cáo audit tại HEAD 7a4d0e7503710d3b87c95e15831829552ba7be8d với current HEAD/dirty/untracked hashes; bảo toàn worktree Phase07. Không giả mọi finding vẫn tồn tại nếu code đã sửa.

Chia tasks nếu tools có sẵn:

- Evaluator/repair worker: required coverage, applicability, error/NG semantics, dynamic closure và repairs.
- Passage worker: generator, prompt assets, context, LoopRuntime composition và actual entrypoint.
- Test/benchmark engineer: regression fixtures, service/DB fault tests, clean split và capped live campaigns.
- Independent reviewer: code read-only, real wiring/evidence review, findings gửi supervisor; không self-certify own implementation.

Giao file ownership rõ; serialize shared registry/config edits. Workers không tự stamp gate hoặc thay thresholds. Supervisor tích hợp và tiếp tục corrective loop.

## 2. Đóng findings G07 chưa đạt

Revalidate fixes đã báo 24 tests PASS: create_error đúng signature, timeout/exception/cancel non-pass, SDK retries disabled dưới gateway, validate_required_evaluators trong actual pipeline, dynamic consumer closure, pinned cache/ref/version và issue lifecycle.

Đếm retries bằng real configured SDK với fake transport bên dưới SDK, không chỉ mock adapter/constructor. Every actual attempt consume remaining caps/reservation; unknown outcomes không refund/reset.

Required evaluators đầy đủ đúng artifact type/version tại execution plan và trước accept. Structural hard fail vẫn chặn expensive calls; evaluator missing/error/timeout không thành “no issues” PASS.

NOT GIVEN phải có semantic relation checking trên toàn approved passage; tách factual FALSE với author-stance NO, neither relation với inconclusive/error. Không dồn yêu cầu G07 này sang Phase10; Phase10 tiếp tục full blind/adversarial review. Heuristic không override required semantic check.

Audit và làm sạch corpus theo actual source provenance, families, duplicated/reprinted/derived samples và near duplicates. Không sửa bằng đổi family IDs. Holdout đã lộ dùng dev/regression khi phù hợp; tạo untouched frozen measurement set, annotation rubric và enough denominators. Không dùng tested evaluator outputs làm gold tự chứng minh, không giả human reviewers.

## 3. Vá bốn grounding false-PASS paths và applicability

1. `PassageWordCountEvaluator`, `GroundingFidelityEvaluator` và mọi required evaluator của passage phải thật sự support canonical ArtifactType.PASSAGE/payload. Unsupported required applicability không trả PASS rỗng.
2. Bỏ sentences[:10]/silent truncation. Bounded batches/chunks vẫn phải ghi coverage toàn passage. Budget/deadline/context cap hết giữa chừng → incomplete/error/non-pass, không partial PASS.
3. Bỏ source_text-or-passage_text self-grounding. Resolve independent approved SourcePack/EvidenceGraph/source spans bằng exact refs/provenance. sourceText inline thiếu nhưng valid refs có thể hydrate; không có approved source thì non-pass. Text equality riêng không đủ để phân biệt source provenance.
4. Một aligned claim không miễn kiểm tra unaligned factual sentences. Alignment/factual/rhetorical tags do generator đề xuất đều cần independent checks. Generator gắn assertion thành rhetorical không bypass.

Version evaluators/cache policy sau fix; không reuse old false-PASS cache. Re-evaluate impacted accepted heads/dependencies theo compatibility và scope, không tự mutation immutable history.

Regression probes phải gồm PASSAGE/SECTION, canary ở câu1/câu11/cuối, missing source, valid hydration, one aligned + one unsupported unaligned, rhetorical-label attack và budget exhaustion giữa batches. Integration fixtures hợp lệ 720–915 từ và schema; assert exact fidelity/error code + coverage, không coi word-count failure là proof grounding.

## 4. Repairs đạt correctness

Thay blind slicing tại word900 bằng sentence/paragraph-aware length repair theo configured 720–915 policy. Verified evidence phải đủ để mở rộng; trim giữ remaining coherence/coverage/fidelity và được re-evaluate. Không feasible thì bounded regenerate/escalate, không success-return oversize.

Modal/causality replacement không chứng minh remaining outcome hợp lệ: “associated with immediate anxiety elimination” vẫn cần independent source support. UNMEASURED_OUTCOME repair dùng verified material nếu có; không repairable thì typed bounded runtime outcome, không exception mất journal hoặc fake PASS.

Repair tạo immutable version, fresh sentence IDs/offsets/alignment/evals. Dynamic closure invalidate all consumers cần thiết; unaffected accepted refs giữ nguyên.

## 5. Hoàn tất Phase08 còn thiếu

Implement tất cả P08-01..09: accepted exact input context, versioned prompt IDs/hashes/input schema, passage artifact/alignment, deterministic/style/grounding composition, local repairs, length repairs, checkpoint/resume và paired passage benchmark.

Source data envelope có safe serialization/escaping và trusted instructions riêng; tag không phải security guarantee. Output không có quyền thay config/policy/schema/tools. Validate injection attempts và resulting domain invariants.

PassageLoop chạy trên generic BoundedLoopRuntime/ledger/registries; không thêm extension/revision/whole-section retry loops riêng. Every call/retry/evaluator batch/repair dùng ProviderGateway và persisted run caps.

Wire actual service DI/facade/selected-V2 entrypoint và kiểm thử qua cùng composition. Không kết thúc bằng classes chỉ được isolated tests gọi. Giữ explicit legacy branch/public HTTP/NDJSON compatibility, pin engine per run và giữ default migration routing tới approved cutover. Selected V2 không invoke legacy retry path. Không giả Phase09 đã có hoặc auto-complete section từ accepted passage.

Commit accepted passage/parents/evals/decision qua authoritative .NET boundary trước downstream; source insufficient có durable typed outcome; crash/resume giữ accepted hash/counters và không gọi passage generator lại khi inputs/config unchanged.

## 6. Chạy tests và semantic campaigns thực sự

Triển khai/map/chạy T07-01..08 và T08-01..08 cùng impacted G03/G06/persistence regressions. PostgreSQL/service-boundary tests và request transport probes phải khác isolated fakes; record exact nodes/exit codes/case counts.

Báo cáo cũ có MiniMax smoke PASS: inspect current configured model/credential/quota và recent compatibility trước khi ghi thiếu key. Smoke không chứng minh semantic quality. Harness thiếu là code work; leaked corpus là integrity failure; external missing input phải được chứng minh.

Chính sách benchmark MiniMax tự động và caps (mặc định toàn hệ thống):
1. Live G07 semantic benchmark và G08 paired passage benchmark tự động khởi chạy và resume bằng provider MiniMax đã cấu hình; loại bỏ hoàn toàn phê duyệt thủ công của operator, authorization-file, phê duyệt campaign-budget và trạng thái chờ PENDING_AUTHORIZATION.
2. Vô hiệu hóa toàn bộ call, token, monetary và wall-time caps do ứng dụng áp đặt cho MiniMax BENCHMARKS ở cả campaign và child-run level (cấu hình explicit unlimited; ngăn chặn fallback về 15 calls / 60k tokens / 300s). Production và các provider khác giữ nguyên hard caps.
3. Duy trì xác thực service, CAS/fencing, cancellation, truthful usage accounting, checkpoints, idempotent resume, bounded retries và per-request output/context limits; tôn trọng giới hạn thực tế phía provider.
4. Tách biệt phục hồi cục bộ và gate: R05 durability trên PostgreSQL thật có thể PASS độc lập trong khi G09 vẫn giữ nợ chất lượng upstream/live-quality (G07/G08 prerequisites); tuyệt đối không promote gate chỉ vì đã dỡ bỏ rào cản phê duyệt.
5. Chiến dịch lưu campaignId/caseId, manifest/status/reservations; reconcile output trước retry, không lặp lại tốn phí. Chính sách này áp dụng mặc định cho tất cả các phase còn lại.
Giữ thresholds, enough denominators và frozen clean holdout; critical fixtures ≥3 lần, aggregate/worst run. Passage benchmark không thay full-paper benchmark tương lai. Failed measurements tạo fix tasks trên dev và fresh/versioned holdout policy, không tune để ăn test đang nghiệm thu.

## 7. Reviewer loop và đầu ra

Independent reviewer chạy verify prompts Phase07/08 trên consistent snapshot và actual entrypoint, ghi findings với repro/root cause/scope/tests. Supervisor assign repairs và rerun impacted checks; không handoff passive report khi còn sửa được.

Lưu đầy đủ output contract, gồm coverage, source refs, prompt inventory, repair diffs, wiring trace, budget journal, kill/resume, corpus/split audit và actual measurements. Record HEAD + dirty/untracked/config/corpus hashes; old report preserved.

Tách runtime remediation, corpus integrity, live smoke, semantic quality, G07 overall, Phase08 implementation, G08 overall và Phase09 readiness. G07/G08 PASS chỉ khi required prerequisites/evidence đạt. Nếu external/input thực sự còn thiếu, hoàn tất independent code và báo exact input/setup/next command/budgeted resume plan. Không gọi Phase09 READY khi approved passage/quality requirements chưa đạt.

Nếu task bị tools/context/budget giới hạn hoặc evidence-based internal deadlock, checkpoint với attempts và next experiment/decision thật; không fake external blocker hay tiếp tục vô hạn. Hoàn thành recovery rồi handoff supervisor scope09–15, không tự phát sinh Phase09 code trong worker recovery.

<!-- END SOURCE: 02-G07-G08-RECOVERY-PROMPT.md -->

<!-- SOURCE: phases/phase-00-discovery-baseline.md -->

# Phase 00 — Discovery và baseline có thể kiểm chứng

Phụ thuộc: không. Gate: G00. Chạy prompt A rồi prompt B; supervisor xử lý findings và verify lại trước handoff.

Work packages: P00-01, P00-02, P00-03, P00-04, P00-05, P00-06, P00-07, P00-08.

Test IDs: T00-01, T00-02, T00-03, T00-04, T00-05, T00-06.

## Prompt A — Thực hiện và khắc phục

```text
Thực hiện Phase 00 Langfens đến đầu ra kiểm định được, chưa refactor production hoặc xóa legacy. Đọc AGENTS.md/CLAUDE.md áp dụng, master plan, Validation Matrix, Phase 00 gốc và 03-OUTPUT-AND-GATE-CONTRACT.md của Prompt Pack V2; contract này bắt buộc cho execution, reports và gates.

Làm long-running: reproduce → implement harness/inventory → test → independent review → fix findings → rerun. Nếu spawn khả dụng, giao inventory/contract tracing, fixture/test engineering và reviewer độc lập phạm vi files riêng; supervisor tích hợp. Không fire-and-forget, không dừng ở report BLOCKED khi thiếu harness có thể viết. Cập nhật tiến độ/session IDs và resume checkpoint theo contract.

Khám phá repo/lockfiles/scripts thật, giữ changes của user. Ghi HEAD, dirty diff/untracked hashes, runtime/config và fixture versions. Bind đầy đủ:
- P00-01: repo inventory, actual commands và conventions.
- P00-02: bốn public Python routes → .NET DTO/consumer/worker → final validator → admin CRUD.
- P00-03: legacy imports, DI/startup/entrypoints/callers/tests và replacement dự kiến.
- P00-04: request/response/null/status/error/content-type/NDJSON recordings.
- P00-05: policy counts, ranges, word/number counting, answer normalization và duplication.
- P00-06: lease/renew/retry/NeedsSources/cancel/checkpoint/final persistence transitions.
- P00-07: fixtures, fake provider, stream replay và deterministic regression harness.
- P00-08: frozen legacy benchmark, measured usage/latency và missing-data notes.

Tạo docs/refactor/repo-inventory.md, legacy-symbol-map.csv, contracts/legacy/ recordings/schemas, policy-baseline.json và state-transition inventory theo paths thực tế. Mọi assertion phân loại observed/documented/proposed. Không bịa schema từ architecture notes. Bugs sẵn có có finding và remedy; không tự biến bug thành policy đúng hoặc âm thầm sửa production ngoài discovery scope.

Corpus ban đầu: ≥6 suitable sources cho 3 profiles, ≥6 unsuitable sources; mỗi trong 6 question types ≥5 valid +≥5 invalid. Có quantity/causality/certainty/unmeasured outcome cases, Unicode, tables/XML, long text, redirects, changed content, malformed JSON và cut stream. Ghi quyền sử dụng/provenance/labels/hash. Usage thiếu là unknown, không 0; mô tả 3–5 phút chưa phải SLA đo được.

Khám phá và triển khai phase verifier/manifest target theo conventions repo. Runner map IDs tới executable tests, phát hiện zero collected, required skip, nonzero exit và missing evidence. Không assert tên command đề xuất đã tồn tại. Exercise actual .NET stream consumer và workflow; fixture-only schema tests không đủ.

Chạy T00-01..06: bốn routes; NDJSON split UTF-8/JSON và incomplete EOF; source/policy boundaries; crash sau section 2 rồi Retry reuse sections 1–2; manual Draft→edit→Publish; fake-provider suite chạy hai lần deterministic/no cloud. Sửa harness/findings trong scope rồi rerun impacted checks.

Đầu ra theo contract tại artifacts/refactor/phase-00/: gate.json, phase-report.md, test reports, commands.jsonl, snapshot-manifest.json, fix-log.jsonl, independent-review.md, resume.md cùng recordings/policy/corpus/baseline. P00→files/symbols và T00→commands/assertions phải đầy đủ.

G00 PASS khi T00 required đạt, critical fields/policy/workflow đã rõ và evidence khớp snapshot. Nếu repo/environment thật thiếu, hoàn tất phần độc lập, ghi BLOCKED với reason loại INPUT theo schema canonical và concrete acquisition/setup/next commands; không chỉ nói cần repo. Chưa đổi routing hoặc deploy. Bàn giao G00, findings đã sửa, limitations và readiness Phase 01.
```

## Prompt B — Verify độc lập và đóng findings

```text
Kiểm định độc lập Phase 00 theo master, Validation Matrix, Phase 00 gốc và 03-OUTPUT-AND-GATE-CONTRACT.md. Reviewer không sửa implementation mình review; giao repro/remedy cho supervisor, nhận snapshot mới và rerun impacted checks đến kết quả.

Đọc actual diff, inventory, manifests/lockfiles và evidence. Xác minh observed/documented/proposed, caller→symbol paths, public routes và .NET consumer. Review phải là vai khác tác giả; nếu không có spawn, thực hiện tuần tự và ghi limitation trung thực.

Chạy/map đầy đủ T00-01..06:
T00-01: replay đủ bốn routes, ghi đúng fields/null/status/media type.
T00-02: actual consumer xử lý splits giữa UTF-8/JSON; EOF không terminal là incomplete.
T00-03: source eligibility/license và boundaries khớp baseline; discrepancies có provenance.
T00-04: worker crash/retry giữ accepted sections 1–2, chỉ resume phần thiếu.
T00-05: manual CRUD Draft/edit/Publish vẫn hoạt động.
T00-06: hai lần fake-provider suite cùng result, xác nhận transport không cloud calls.

Kiểm tra corpus minimum, licenses/labels/hash, benchmark denominators và usage unknown. Không coi fixture input một mình là recording behavior. Runner phải bắt zero collected/skip/nonzero/missing report; test-ID counts khác case counts.

Với mỗi defect ghi evidence/repro, root cause hoặc check phân biệt, exact scope fix, acceptance và next executable test. Supervisor sửa các phần có thể xử lý; không handoff chỉ một list blockers.

Lưu independent-review, commands/exit codes và gate trên code/config/corpus snapshot thật; không reuse evidence incompatible. G00 PASS chỉ khi required checks và inventory đạt. Chưa có repo thì BLOCKED với reason loại INPUT theo schema canonical, kèm setup/resume cụ thể. Kết luận Phase 01 readiness; không tuyên bố live SLA hoặc quality từ fake tests.
```

<!-- END SOURCE: phases/phase-00-discovery-baseline.md -->

<!-- SOURCE: phases/phase-01-contracts-policies.md -->

# Phase 01 — Canonical contracts, policies và ADR

Phụ thuộc: G00. Gate: G01.

Work packages: P01-01, P01-02, P01-03, P01-04, P01-05, P01-06, P01-07, P01-08, P01-09, P01-10, P01-11.

Test IDs: T01-01, T01-02, T01-03, T01-04, T01-05, T01-06.

## Prompt A — Thực hiện và khắc phục

```text
Hoàn thành Phase 01 Langfens, chưa xây generation/provider loops hoặc đổi production routes. Đọc AGENTS.md/CLAUDE.md, master, Validation Matrix, Phase 01 gốc, G00 evidence và 03-OUTPUT-AND-GATE-CONTRACT.md. Chỉ reuse G00 khi actual code/config compatibility được chứng minh.

Execution long-running: reproduce → implement → test → review độc lập → fix → rerun. Nếu có spawn, phân file ownership cho Python contracts, .NET fixtures/DTO và reviewer; supervisor giải quyết shared schemas tuần tự. Theo dõi sessions, exit codes, cập nhật resume; không kết thúc khi còn bug nội bộ sửa được.

Discover canonical models, serializer/hash conventions, DTO/validators và test scripts thật; giữ dirty changes. Bind P01-01..11:
01 artifact envelope với immutable version và exact parent {id,version,hash};
02 run/job/section/source revision identities, operation khác artifact version;
03 typed evaluation target/dependencies/version/status/usage;
04 issue lifecycle/fingerprint/evidence;
05 issue-code taxonomy;
06 versioned policies;
07 type-specific question schemas;
08 decisions/state transitions;
09 authoritative-store/service-auth/ack ADR;
10 dependency invalidation ADR;
11 persisted budget/event delivery ADR.

Một canonical domain definition, domain modules import/re-export cùng type. Không tạo models thứ hai ở artifacts/blueprint. Corresponding .NET DTO/codegen và JSON Schema theo repo, có explicit schema/compatibility versions. Wire validation tại real deserialization/policy boundaries; chỉ thêm dataclasses chưa đủ.

Envelope gồm artifact/run/type/version/hash/UTC/producer/schema, payload và exact parents. Hash canonicalization phải reproducible cross-language; JSON field order không được đổi identity ngoài spec. IDs không tái dùng cho khác nội dung. Evaluation PASS/FAIL/ERROR/NOT_APPLICABLE có requiredness/prerequisites; exception không trở thành empty issues/PASS.

Issues gồm unsupported/contradicted, causal/certainty overstatement, unmeasured outcome, source insufficient, evidence missing, ambiguity, leakage, bad distractor, limits, duplicate, unavailable evaluator, stale dependency, budget exhausted. Unresolved blockers giữ lifecycle qua versions.

Enforce bằng code: 3 sections, 40 contiguous ordinals, 13/13/14; S1 TFNG7+sentence6, S2 MCQ6+summary7, S3 YNNG7+short7; passage720–915, paper2150–2750. Giữ baseline word/number normalization. Completion/short answer exact passage support, ≤3 words/numbers. NG dùng absence assessment: topical quote không phải positive proof, thiếu positive quote tự thân không làm NG invalid. Difficulty/confidence chưa calibrated không gọi là IELTS band.

Decision PASS/REPAIR/REGENERATE/ESCALATE/FAIL có reason/scope/expected version/budget grant. Fresh required evaluations và zero blockers trước PASS. ADR chốt .NET sở hữu job/lease/exam-db, Python authenticated API+ack, CAS/fencing/cancel, exact closure/cache versions; không hai authoritative stores. Events at-least-once/idempotent; không exactly-once cloud inference.

Triển khai/chạy T01-01..06: Python↔JSON↔.NET round-trip; invalid/unknown schema theo compatibility policy; payload/parent change đổi hash/ref; evaluator error/critical không PASS; valid NG vs exact completion; section/paper boundaries enforce thật. Fixtures có Unicode/null/enums/UTC. Sửa mismatches rồi rerun cross-language checks và impacted G00 tests.

Lưu contract diff/schemas, policy fixture hashes, ADR owners/decisions và output bundle contract tại artifacts/refactor/phase-01/. P01→symbols, T01→executable targets đầy đủ. G01 PASS khi tests đạt và ownership/ack/invalidation/budget decisions chốt. Missing authority decision không ghi external nếu có thể ADR trong scope. Real blocker có concrete remedy/setup/next command. Giữ public routing/legacy, rollback contracts chưa dùng qua code change có kiểm định, không drop data. Bàn giao G01 và Phase 02 readiness.
```

## Prompt B — Verify độc lập và đóng findings

```text
Review độc lập Phase 01 theo plan, Validation Matrix và 03-OUTPUT-AND-GATE-CONTRACT.md. Đọc G00, diff, schemas/ADR và actual boundary wiring. Reviewer không là tác giả; spawn khi khả dụng, hoặc sequential review có limitation rõ.

Search duplicate definitions, divergent enums và DTO default/null compatibility. Trace canonical types tới API/deserialization/validators. Không coi schema document hoặc prompt constraints là enforcement.

Chạy đủ T01-01..06:
01 Python/JSON/.NET không mất Unicode/null/UTC/enums/version/hash.
02 invalid types/counts/unknown fields reject hoặc đúng compatibility policy đã chốt.
03 một ký tự hoặc parent version đổi identity; old version không mutable.
04 ERROR/missing required evaluation/critical issue không có đường PASS.
05 valid NG không đòi impossible positive quote, completion vẫn exact supported span.
06 boundaries/count/type/ordinal được Python và .NET enforce.

Kiểm tra P01-01..11 có owner/files/test evidence; ADR không để store/ack/fencing/invalidation/budget là TODO. Parent refs exact; operation identity khác artifact identity. No-calibrated-band claims và cloud exactly-once claims không được xuất hiện trong contracts/docs.

Đối chiếu status/usage/error serializers, hashes và public contract diffs. Chạy impacted G00 regression, phát hiện zero collected/skip/nonzero theo manifest.

Mỗi finding cần reproduction, expected/observed, affected invariant, root cause và exact repair acceptance. Giao supervisor sửa; reviewer rerun snapshot mới, không dừng ở report FAIL khi nội bộ xử lý được.

Lưu independent evidence/commands/hashes và canonical G01 report. PASS chỉ khi required checks đạt, no duplicate divergent model và architecture decisions chốt. BLOCKED phải kèm concrete work/setup/next commands. Bàn giao Phase 02 readiness, không gọi foundation schemas là model-quality certification.
```

<!-- END SOURCE: phases/phase-01-contracts-policies.md -->

<!-- SOURCE: phases/phase-02-durable-artifacts.md -->

# Phase 02 — Durable artifacts, fencing và exact resume

Phụ thuộc: G01. Gate: G02.

Work packages: P02-01, P02-02, P02-03, P02-04, P02-05, P02-06, P02-07, P02-08, P02-09, P02-10.

Test IDs: T02-01, T02-02, T02-03, T02-04, T02-05, T02-06, T02-07, T02-08, T02-09.

## Prompt A — Thực hiện và khắc phục

```text
Hoàn thành Phase 02 Langfens trên authoritative .NET checkpoint boundary và PostgreSQL thật. Đọc AGENTS.md/CLAUDE.md, master, Validation Matrix, Phase 02 gốc, G01 schemas/ADR và 03-OUTPUT-AND-GATE-CONTRACT.md. Chưa xây domain loops hoặc auto-deploy.

Làm long-running reproduce→fix→test→independent review→fix findings→rerun. Nếu spawn khả dụng, chia persistence/migrations, Python client+worker wiring, fault harness và reviewer với files riêng; serialize integration/DB writes hoặc dùng isolated schemas/ports. Supervisor await mọi task/process; không coi mock repository là durability proof.

Discover actual EF migrations, job worker/lease, service-auth, checkpoints, BuildExam và test commands. Giữ changes, pin actual dirty snapshot. Bind P02-01..10 và names thật; table/routes trong plan là đề xuất cần chốt, không giả endpoint đã tồn tại.

P02-01: expand-first migration/backfill cho legacy jobs, giữ SectionsJson/completed exams. P02-02: claim tăng leaseEpoch, renew match owner/epoch. P02-03: authenticated checkpoint API validate run/epoch/expiry/cancelVersion/requestHash, không tin caller tự khai. P02-04: durable intent/reservation grants trước side effect. P02-05: atomic payload/evaluation/decision/accepted head/outbox. P02-06: ack/replay operationId. P02-07: exact-ref resume/compatibility resolver. P02-08: source replacement closure. P02-09: final BuildExam idempotency nền tảng. P02-10: quantitative payload/retention/index/redaction và rollback.

Canonical data model giữ immutable artifacts/dependencies/evaluations/issues/decisions, operations và event outbox. Unique (run,artifact,version), (run,operation), (run,event); exact ref constraints, CAS head và transactional counter reservations. Same operationId+hash replay cùng committed result, khác hash conflict. Run pin engine/schema/policy/source revisions/authority.

Wire .NET worker truyền writer grant tới actual V2 entry/client; Python chỉ gọi authenticated API và advance sau ack. Lost ack replay không tạo version/reservation mới. NDJSON progress không phải commit proof. Không Python direct exam-db writes hoặc second authoritative store.

UNKNOWN_OUTCOME giữ reservation khi provider có thể đã xử lý; bounded retry operation mới tiêu cap, không free replay hoặc cloud exactly-once claim. Cancel/expired lease/stale epoch chặn late accepted writes. Cache không thay authority check.

Source replace invalidate graph closure affected section và aggregate paper, giữ unrelated accepted refs/history. Compatibility resolver kiểm tra hashes/schema/producer; unsupported old run có migration/pause rõ, không fabricate lịch sử.

P02-09 ở phase này chứng minh nền final graph idempotency qua existing integration fixture; không gọi full PaperLoop đã triển khai. Final uniqueness ở DB, không check-then-insert trong RAM.

Chạy T02-01..09 trên PostgreSQL thật: concurrent same operation; different hash conflict; crash pre/postcommit/pre-ack; takeover; cancel; section2 replacement; crash final commit; bad hash/schema; no/wrong/stale auth. Fault injection phải tại transaction boundaries, assert DB rows/heads/counters/outbox/ref graph, không chỉ HTTP codes.

Apply migration trên DB clone, khởi động/đọc bằng compatible previous app; rollback app giữ additive tables/data. Sửa failures, rerun impacted G01/G00 contracts. Không drop artifacts để rollback.

Lưu migrations/constraints, actual transaction/API/worker traces, fault/replay/rollback evidence và contract output bundle artifacts/refactor/phase-02/. G02 PASS khi mọi T02 đạt real DB và compatibility rollback có proof. Thiếu DB env thì dựng supported local harness trong scope; external access thật thiếu có setup/next commands, hoàn tất code/harness độc lập. Không handoff chỉ báo BLOCKED. Bàn giao G02 và Phase03 readiness.
```

## Prompt B — Verify độc lập và đóng findings

```text
Kiểm định độc lập Phase02 theo plan, Validation Matrix, G01 ADR và 03-OUTPUT-AND-GATE-CONTRACT.md. Reviewer đọc diff/API/auth/worker/client/migrations và DB evidence; không làm tác giả patch mình review. Spawn reviewer khi khả dụng.

Chạy T02-01..09 trên real PostgreSQL isolated harness:
01 hai writers same op: một result/reservation, cùng replay response.
02 same ID khác request hash: conflict, old payload không đổi.
03 crash trước/sau commit/trước ack: heads/rows/result đúng boundary.
04 takeover: stale epoch reject mọi writes kể cả late result.
05 cancellation: terminal không sống lại, no accepted late output.
06 source section2: chỉ affected closure+paper stale; unrelated refs giữ.
07 crash final graph commit: retry cùng ExamId, một graph.
08 corrupted hash/incompatible schema: typed failure không reuse.
09 missing/wrong-run/stale auth: không sửa DB.

Trace actual worker→grant→Python persistence client→.NET authenticated transaction→ack→cursor. Progress event không advance durability. Inspect unique constraints/CAS/request hashes/atomic outbox và budget counts trực tiếp DB; mock tests không thay proof.

Kiểm tra UNKNOWN_OUTCOME/reconciliation không refund/reset, additive migration/backfill không sửa completed exams/SectionsJson, retention/caps có units/source/version. Thực hiện migration+previous-app recovery trên clone, không destructive production operations.

Findings cần exact reproduction, root cause, file/symbol remedy, assertions/regressions. Supervisor fix rồi reviewer rerun impacted checks; mọi running sessions có completion/exit evidence.

Lưu independent report, commands/SQL/fault traces và snapshot hashes theo contract. G02 PASS chỉ real transactional/auth/resume checks đạt. Phân biệt groundwork final idempotency với future Phase12 paper acceptance. Remaining external blocker có explicit setup/next commands, không stamp PASS. Kết luận Phase03 readiness.
```

<!-- END SOURCE: phases/phase-02-durable-artifacts.md -->

<!-- SOURCE: phases/phase-03-provider-budget.md -->

# Phase 03 — Unified gateway, parsing, retries và budgets

Phụ thuộc: G01–G02. Gate: G03.

Work packages: P03-01, P03-02, P03-03, P03-04, P03-05, P03-06, P03-07, P03-08, P03-09.

Test IDs: T03-01, T03-02, T03-03, T03-04, T03-05, T03-06, T03-07, T03-08.

## Prompt A — Thực hiện và khắc phục

```text
Hoàn thành Phase03 Langfens, giữ legacy parity shim. Đọc AGENTS.md/CLAUDE.md, master, Validation Matrix, Phase03 gốc, G01–02 evidence và 03-OUTPUT-AND-GATE-CONTRACT.md. Không tự thay provider/model/SDK versions hoặc triển khai production.

Làm long-running reproduce→implement→test→review→fix→rerun. Có spawn thì giao adapters/parser, budget/retry integration, test engineer và independent reviewer phạm vi files rõ. Supervisor await tasks, cô lập DB/live benchmark resources, giữ caps và progress/resume theo contract. Đừng dừng vì thiếu parser/harness có thể xây.

Discover gateway/legacy llm callers, actual config/deploy resolution, SDK versions, HTTP transports và scripts; pin dirty snapshot. Bind P03-01..09:
01 protocol; 02 provider/model routing/config; 03 bounded parser; 04 reasoning cleanup; 05 retry; 06 shared persisted budget; 07 cost accounting; 08 typed errors; 09 parity shim/deletion map.

Requests có capability/schema/messages/output cap/timeout/config/prompt/op IDs; responses parsed payload, finish reason, usage reported/estimated/unknown, request ID và latency. Business logic không biết vendor tags. Version models/routing, validate endpoint/credential scope; inspect configured credentials an toàn, không print keys hoặc mặc định thiếu key.

Adapters MiniMax/Groq hoặc providers thực sự được scope hiện tại chọn đều dùng domain semantics chung. Disable SDK/HTTP nested retries tại client factories/clones/options; gateway sole transport retry owner. Legacy wrapper gọi cùng gateway, không xóa wrapper trước migration.

Structured output khi supported; parser bounded cho fences theo policy, reject multiple objects/trailing prose/NaN/wrong schema/oversized/truncated outputs. Parse JSON không chứng minh domain-valid. Reasoning tags xử lý adapter-specific, unclosed/malformed tags không lộ raw thinking trong errors/logs.

Retry cap/profile phải được declared/versioned trong Settings và effective deployment config; 3 attempts trong plan là proposal, không evidence approved production. 401/403/invalid request không retry; transient retry honor Retry-After/backoff+jitter trong deadline, cancellable. Delay không vừa deadline phải typed defer/failure/checkpoint.

Budget run→section→artifact: atomically reserve trước actual send, gồm retries/evaluator/candidates; persist via G02. Parent không oversubscribe concurrent requests. Completion limit gồm reasoning khi provider tính vậy. UNKNOWN_OUTCOME giữ conservative reservation; restart/replay không reset. Missing usage unknown, không0. Dollar hard cap chỉ claim khi pricing snapshot/bounded accounting đủ; estimates không billed actual.

Chính sách benchmark MiniMax tự động và caps (mặc định toàn hệ thống):
- Live benchmarks bắt buộc tự động khởi chạy và resume bằng provider MiniMax đã cấu hình; loại bỏ hoàn toàn phê duyệt thủ công của operator, authorization-file, phê duyệt campaign-budget hay chờ PENDING_AUTHORIZATION.
- Vô hiệu hóa toàn bộ application-imposed call, token, monetary và wall-time caps cho MiniMax BENCHMARKS ở cả campaign và child-run level (cấu hình explicit unlimited; ngăn chặn fallback về 15 calls / 60k tokens / 300s). Production và các provider khác giữ nguyên hard caps.
- Duy trì xác thực service, CAS/fencing, cancellation, truthful usage accounting, checkpoints, idempotent resume, bounded retries và per-request limits; tôn trọng giới hạn thực tế phía provider.
- Tách biệt phục hồi cục bộ và gate: R05 durability trên PostgreSQL thật có thể PASS độc lập trong khi G09 vẫn giữ nợ chất lượng upstream/live-quality (G07/G08 prerequisites); tuyệt đối không promote gate chỉ vì đã dỡ bỏ rào cản phê duyệt. Chính sách này áp dụng mặc định cho tất cả các phase.

Actual composition/client factories phải dùng injected config/gateway, không direct SDK outside providers. New calls fail closed nếu budget/authority thiếu. Keep rate/concurrency buckets/key rotation bounded, không lách account quota.

Chạy T03-01..08: deadline+429; auth/transient attempts; JSON edge cases; cancel backoff/stream; atomic budget race; unknown-outcome resume; adapter recordings/parity/redaction; configured live model smoke. Count requests bằng SDK thật+fake transport để lộ nested retries, không chỉ mocks constructor.

T03-08 chạy nếu approved credentials/env/budget đã có, bounded sample/schema/usage; không hardcode model name. Nếu unavailable, ghi exact external prerequisite/setup+next command. Theo contract, missing smoke không thành live PASS; Phase03 gốc cho downstream coding-only tiếp tục, không cutover hoặc nghiệm thu live dependency.

Sửa failures rồi rerun impacted G01/G02, save sanitized provider/budget/reconciliation recordings và output bundle tại artifacts/refactor/phase-03/. G03 report tách deterministic, config, smoke và live readiness, không waive T03-08 bằng fake calls. Bàn giao routing rollback giữ accounting, fixed findings và next remedy/readiness.
```

## Prompt B — Verify độc lập và đóng findings

```text
Review Phase03 độc lập theo plan, Validation Matrix và 03-OUTPUT-AND-GATE-CONTRACT.md. Đọc G01–02, actual config/client/gateway/transport factories và all call sites. Reviewer không sửa patch mình review; findings có executable remedy để supervisor fix rồi rerun.

Chạy đủ T03-01..08:
01 Retry-After vượt remaining deadline không vượt cap/deadline.
02 401 không retry; timeout/5xx đúng actual transport count/accounting.
03 fenced/malformed/truncated/multiple JSON/NaN đúng parser policy và schema.
04 cancel trong wait/stream dừng, late result vẫn fenced.
05 concurrent near-budget admission atomic, no parent oversubscription.
06 UNKNOWN_OUTCOME giữ reservation/counters sau restart.
07 actual adapter recordings cùng semantics, no key/thinking leaks.
08 configured provider/model live smoke có parsed payload/usage hoặc exact NOT_RUN_EXTERNAL reason.

Dùng SDK thật và fake HTTP transport cho retry counts; kiểm tra with_options/clones/fallback/custom HTTP retry. No direct SDK calls outside providers và legacy shim thực sự dùng gateway. Config trace Settings→deployment→client/gateway→budget snapshot, không class defaults-only.

Review parent counters/cost units/pricing snapshots/unknown reconciliation. Reported/estimated/unknown tách; restart không free retry. Reasoning+visible tokens đúng provider limit semantics; redaction inspect serialized errors/logs, không chỉ redactor unit test.

Run impacted G02 concurrency/replay/auth checks và legacy contract parity. Manifest phát hiện skip/zero/nonzero; count IDs riêng cases. Mỗi finding có repro/root cause/scope/acceptance/next commands; supervisor sửa và reviewer xác nhận snapshot mới.

Lưu output bundle/independent report với hashes và actual exit codes. Deterministic PASS không tự thành live gate PASS. T03-08 external exception cho coding-only phải được ghi, không tự tạo exemption release. G03/live-readiness và Phase04 coding/acceptance readiness tách rõ, blockers kèm setup/remedy cụ thể.
```

<!-- END SOURCE: phases/phase-03-provider-budget.md -->

<!-- SOURCE: phases/phase-04-ingestion-evidence.md -->

# Phase 04 — Secure ingestion và verified evidence

Phụ thuộc: G00–G03. Gate: G04.

Work packages: P04-01, P04-02, P04-03, P04-04, P04-05, P04-06, P04-07, P04-08, P04-09, P04-10, P04-11.

Test IDs: T04-01, T04-02, T04-03, T04-04, T04-05, T04-06, T04-07, T04-08.

## Prompt A — Thực hiện và khắc phục

```text
Hoàn thành Phase04 Langfens: ingestion→SourcePack→verified EvidenceGraph→authoritative checkpoint. Đọc AGENTS.md/CLAUDE.md, master, Validation Matrix, Phase04 gốc, G00–03 evidence và 03-OUTPUT-AND-GATE-CONTRACT.md. Giữ extractor compatibility wrapper, chưa làm passage generation/cutover.

Làm long-running reproduce→implement→test→independent review→fix→rerun. Khi spawn khả dụng giao ingestion/security, evidence verification, transport/corpus harness và reviewer scopes riêng. Supervisor serialize shared configs/DB/live benchmark; await results, update progress/resume. Missing code/harness/corpus có thể tạo không phải external excuse.

Discover extractor/lookup/fetch transport/license/config/persistence thực tế, baseline và commands. Bind P04-01..11: lookup/fetch; network protection; resource caps; license; normalization; SourcePack; stable spans; context selection; atomic claims; verification; checkpoint. Pin HEAD+dirty/config/corpus/normalizer/model/evaluator hashes.

Preserve Europe PMC/OpenAlex metadata/PMCID/known licensing; Europe PMC CC-BY/CC0 và minimum600 original words theo baseline field. Universal source riêng policy, unknown rights không approved tự động. Giữ attributable provenance, original/effective URL, fetchedAt, content/normalized hashes và source revision; URL không identity duy nhất.

HTTP(S) only, validate resolved IPv4/IPv6 và mỗi redirect; bảo vệ connection target pinning/controlled egress để chống rebinding/TOCTOU. Deny loopback/private/link-local/metadata/mapped/encoded IP/userinfo và public→private redirect qua actual transport. Regex hostname hoặc mock preflight DNS không đủ. Config caps connect/read deadlines, redirects, compressed/decompressed bytes/extracted text; declare/version/inject như contract, không chỉ class defaults.

Normalize HTML/XML/Markdown/text: bỏ scripts/nav/boilerplate, giữ useful headings/paragraphs/tables. Unicode offsets half-open[start,end) theo code points, explicit .NET UTF-16 translation nếu cần. span hash/text version và text[start:end]==span.text. Same normalizer/input reproducible; normalizer change tạo version.

Chunk overlaps/selectedSpanIds/coverage map rõ. Source excerpt không được gọi full-source verification. Atomic claims giữ quantities/units/population/time/modality/qualifiers/forbidden transforms. Direct verified support mặc định; derived/contextual chỉ qua declared transformation policy và verified semantics. Conflicting claims không merge certainty.

Span/ref/hash deterministic reject trước semantic calls. Independently resolve source refs; generated claims/passage không source of truth. Semantic evaluator check entailment/contradiction/qualifiers/full declared claim coverage; ERROR/unsupported type/missing source/partial budget coverage non-pass. Extractor self-alignment không proof. Required verifier dùng Gateway/shared budget và persists exact target/dependencies/config version.

Wire actual ingestion/evidence facade→gateway/evaluators→G02 checkpoint+ack. Accepted graph chỉ zero unverified blockers/fresh deps. Changed same URL content tạo revision và dynamic descendant invalidation; không RAM-only graph. Source instructions là data, không mở tools/đổi policy; envelope tag tự thân không security proof.

Chạy T04-01..08: licenses599/600/601; SSRF/rebinding actual transport; Unicode/hash/.NET offset round-trip;14%→40%/population; no support/may/association→cause; claims ngoài selected coverage; same URL changed revision; injection/oversize/decompression caps. Có valid controls và≥20 ingestion/security,≥40 fidelity cases/≥10 critical canaries theo matrix; semantic labels/provenance/split sạch, không evaluator tự làm gold. Critical cases≥3 runs, report worst/aggregate, thresholds không hạ.

Fix findings và rerun security/semantic/impacted G02–03; external live gap có setup/capped next commands sau khi harness/config inspection hoàn tất. Lưu provenance/offset/security/claim/coverage/checkpoint evidence và contract bundle artifacts/refactor/phase-04/. G04 PASS khi required checks đạt, graph acceptance fail-closed và deps đủ. Bàn giao Phase05 readiness/insufficient-source mapping, không claim hết hallucinations từ finite corpus.
```

## Prompt B — Verify độc lập và đóng findings

```text
Review độc lập Phase04 theo plan, Validation Matrix, G00–03 và 03-OUTPUT-AND-GATE-CONTRACT.md. Inspect actual fetch transport/normalizer/evaluator/checkpoint wiring; reviewer không là author patch. Supervisor fix reproducible findings rồi reviewer rerun impacted checks.

Chạy đủ T04-01..08:
01 correct license/original-word599/600/601; universal policy phân biệt.
02 forbidden IPv4/IPv6/mapped/encoded/userinfo/redirect/rebinding không connect tới target bị cấm; transport proof.
03 normalization/hash reproducible, Unicode/code-point/.NET offsets đúng.
04 valid spans nhưng changed quantity/population bị reject.
05 unsupported/may removal/causal overstatement đúng blocking codes.
06 out-of-coverage claim chưa verified; fetch additional span hoặc non-pass.
07 same URL content mới tạo revision và invalidate correct closure.
08 injection không đổi trusted config/tools; bytes/decompression/time limits thực sự enforce.

Inspect every acceptance path: independent source refs, exact deps, required evaluator/result coverage, no self-grounding/empty-extraction PASS. Invalid hash/spans có expensive calls=0. Unsupported artifact types, missing source/partial semantic coverage không accepted.

Audit evidence labels/corpus provenance/source-family split và repeated critical cases; syntax/quote match không thay entailment. Zero accepted unverified claim trong required graph fixtures. Mock DNS check hoặc isolated security function không thay actual connection path.

Verify graphs persisted/acked qua authenticated .NET boundary và resume/read compatibility; caps từ effective Settings và parent budgets, no provider bypass. Keep extractor wrapper responsibilities/caller inventory.

Mỗi failure: exact repro/evidence, root cause hoặc discriminating check, fix scope/acceptance/regression và owner/next command. Supervisor làm fixes có thể làm, không chỉ chuyển findings Phase07/10. External missing input phải explicit setup/remedy, không false PASS.

Lưu test-ID mappings/commands/exits/corpus-config-hashes, independent report và canonical G04. Tách deterministic/security/semantic/external status, không fake live measurements. G04/Phase05 acceptance readiness chỉ PASS khi required evidence đầy đủ; coding-only nếu exception có rationale đúng contract.
```

<!-- END SOURCE: phases/phase-04-ingestion-evidence.md -->

<!-- SOURCE: phases/phase-05-blueprint.md -->

# Phase 05 — Feasible ExamBlueprint và source suitability

Phụ thuộc: G01, G04. Gate: G05.

Work packages: P05-01, P05-02, P05-03, P05-04, P05-05, P05-06, P05-07, P05-08, P05-09.

Test IDs: T05-01, T05-02, T05-03, T05-04, T05-05, T05-06, T05-07.

## Prompt A — Thực hiện và khắc phục

```text
Hoàn thành Phase05 Langfens: versioned feasible ExamBlueprint trước passage generator. Đọc AGENTS.md/CLAUDE.md, master, Validation Matrix, Phase05 gốc, G01/G04 evidence và 03-OUTPUT-AND-GATE-CONTRACT.md. Giữ production routing/legacy, chưa tạo PassageLoop hoặc full paper.

Execution long-running reproduce→implement→test→independent verify→fix findings→rerun. Nếu spawn khả dụng chia planner/policies, Python-.NET fixture/test engineering và independent reviewer file scopes; supervisor resolve shared contracts tuần tự, theo dõi sessions/resume. Không dừng ở BLOCKED khi policy/harness/planner bug có thể sửa.

Discover canonical Blueprint/contracts/policies/budget/checkpoint/workflow adapter, bind P05-01..09:
01 extract/mirror versioned section policies;
02 objectives/claim→concept/slot planner;
03 source suitability;
04 NOT GIVEN planning;
05 difficulty target/rationale;
06 coverage/concentration/diversity;
07 deterministic+semantic feasibility;
08 candidate/repair resource allocations;
09 accepted checkpoint/invalidation.

Blueprint pin exact accepted EvidenceGraph ref, source revisions, policy/producer hash, objectives, slots/groups/instructions, skills and budgets. No graph rejected/stale/incompatible. Objectives facts vs rhetorical transitions riêng, không đòi exact answer trước passage tồn tại, không thêm claims bằng outside knowledge.

Enforce actual Python policy boundary và mirror .NET shared fixtures:
S1 ordinals1–13, TFNG7+sentence6, factual/descriptive;
S2 ordinals14–26, MCQsingle6+summary7, analysis/mechanisms;
S3 ordinals27–40, YNNG7+short7, explicit views/arguments.
Mỗi section2 groups. Passage720–915, paper2150–2750 cả hai enforce, không sửa ranges để khớp: valid per-section thực tế cộng2160–2745.

Suitability cần independent concepts/entities/mechanisms/views đủ profile, không lấy word count là proof. Version criteria/threshold/rationale trước measurement, finite resource policy. Repetitive1000-word one-fact source bị SOURCE_INSUFFICIENT, passage generator calls=0. Source thiếu author views không invent opinion.

NG slots là intent về approved passage tương lai: absence trong excerpt không tự chứng minh NG. Full evaluation thuộc passage/question stages; Blueprint không claim câu đã verified. TFNG factual và YNNG author's stance tách. Categorical/heuristic difficulty và self-confidence không IELTS band calibration.

Concentration/diversity/order constraints có hard/soft severity, source rationale và policies trong code/config, không chỉ monolithic prompts. Resource allocations candidate/group/artifact/section/run atomically bounded parent caps và repair headroom; variant grouping không bypass pools. Nếu planned budget vượt cap giảm theo declared policy hoặc typed fail, không oversubscribe.

Wire real planner/facade→validation→G02 authenticated checkpoint/ack→workflow NeedsSources mapping. Invalid schema/count/exact graph deterministic reject trước expensive calls. Uncertain semantic suitability không generate để lấp facts. Accepted blueprint immutable; revisions invalidate descendants/transitive aggregate refs, pinned runs không auto-update latest policies.

Chạy T05-01..07: three profiles/types/counts/ordinals;1000-word repeated fact; section3 no opinions; stale/rejected graph; candidate oversubscription; reproducible deterministic hash hoặc freeze validated LLM plan; Python/.NET boundary parity. Có valid/invalid controls, actual execution calls/checkpoints/adapter assertions, không chỉ planner unit test. Gateway/budgets cho LLM planner, provider/config/corpus hashes pinned.

Sửa findings/rerun impacted G01/G04/G02 budget/checkpoint regressions. Lưu schemas/3 accepted fixtures/rejected sources/parity/allocations/invalidation và contract output bundle artifacts/refactor/phase-05/. G05 PASS khi tests/deps đủ, counts/policies không prompt-only, insufficient outcome không infinite Retry. External semantic gap có concrete harness/setup/next capped command; chưa nghiệm thu bằng fakes. Bàn giao G05 và Phase06 readiness.
```

## Prompt B — Verify độc lập và đóng findings

```text
Review Phase05 độc lập theo plan, Validation Matrix, G01/G04 và 03-OUTPUT-AND-GATE-CONTRACT.md. Reviewer inspect planner/policy/actual facade/checkpoint/workflow code, không sửa patch mình review; supervisor fix rồi independent rerun.

Chạy đủ T05-01..07:
01 three sections exact6types/2groups/counts13/13/14/ordinals1–40.
02 repetitive1000-word source rejected, generator calls=0.
03 no views/arguments section3 không opinion fabrication.
04 rejected/stale graph reject trước generation/acceptance.
05 candidate allocations vượt cap giảm đúng policy hoặc fail; parent counters không oversubscribe.
06 deterministic same graph/policy same hash; LLM plan validates/pins một accepted version trước dùng.
07 shared fixtures Python/.NET tương đương cho counts/word boundaries/schema.

Trace policies được enforce thật, không đơn thuần prompt assets. Kiểm tra source suitability không từ source length alone, NG intent không absence proof, heuristic difficulty không calibrated band. Values/criterion versions có rationale trước benchmark.

Inspect actual exact graph/producer/policy refs, allocations/reservations, immutable checkpoint/ack và dynamic invalidation. Candidate group variants không hide quotas. SOURCE_INSUFFICIENT workflow mapping giữ bounded Retry/NeedsSources behavior; no accepted blueprint khi required feasibility error/stale.

Review supported public contract compatibility, actual generator-call spy/transport và real checkpoint integration. Run impacted G01/G04/G02 regressions theo changed scope; unexpected skip/zero collected/nonzero chặn gate.

Findings có command/repro/expected-observed/root cause/file scope/acceptance/regression. Supervisor thực hiện remedy rồi reviewer retest snapshot mới; external blocker kèm exact setup/next commands sau độc lập work đã xong.

Lưu independent-review/commands/exits/fixtures/config hashes và G05 theo contract. PASS chỉ required checks/deps đủ; tách simulation/coding readiness khỏi acceptance. Bàn giao Phase06 exact snapshot inputs, không gọi blueprint feasibility là final question quality.
```

<!-- END SOURCE: phases/phase-05-blueprint.md -->

<!-- SOURCE: phases/phase-06-loop-runtime.md -->

# Phase 06 — Bounded runtime, issue ledger và caps thực sự

Phụ thuộc: G02–G05. Gate: G06.

Work packages: P06-01, P06-02, P06-03, P06-04, P06-05, P06-06, P06-07, P06-08.

Test IDs: T06-01, T06-02, T06-03, T06-04, T06-05, T06-06, T06-07, T06-08.

## Prompt A — Thực hiện, remediation và caps hotfix

```text
Hoàn thành/sửa Phase06 Langfens gồm runtime và runtime caps Settings→deployment→composition→persisted snapshot. Đọc AGENTS.md/CLAUDE.md, master, Validation Matrix, Phase06 gốc, G02–05/current G06 evidence, caps ADR và 03-OUTPUT-AND-GATE-CONTRACT.md. Chưa làm Phase07 quality capabilities hoặc cutover.

Long-running reproduce→fix→test→independent verify→fix findings→rerun. Spawn khi khả dụng: runtime/ledger writer, config/persistence integration writer, fault/test engineer, read-only reviewer scopes riêng. Supervisor integrate shared files tuần tự, isolate DB sessions, await exits và update resume. Không kết thúc vì tests vẫn fail mà chưa xử lý fix khả thi.

Discover Settings/deploy resolver/composition roots/gateway/grant/journal và exact test targets. Bind P06-01..08: context; state machine/cursor; controller; durable ledger; intent/ack step journal; termination; dependency validator; capability interfaces. Pin dirty-code/config/fixtures hashes; check upstream evidence compatibility.

Implement một LoopRuntime cho generate/evaluate/decide/repair/terminal, domain agnostic. Capabilities injected, không recursive retries/mutation. Context pin run/exact inputs/scope/authority/policy/budget. Every side effect intent+reservation trước send, cursor advance sau durable ack. Replay committed operation không repeated work/reservation/version.

Controller PASS chỉ fresh exact dependencies + all required evaluations PASS + zero unresolved blockers. Local allowlisted fix đủ budget→REPAIR; unusable artifact nhưng valid source→REGENERATE; source insufficient/uncertain exhausted repair→ESCALATE; cancel/stale authority/deadline/cap/critical unsalvageable→FAIL. ESCALATE không accepted Draft. Soft averages không che blocker. Missing/error/unsupported evaluator không empty-issue PASS.

Ledger fingerprints/lifecycle durable: issue cũ không disappear chỉ vì evaluator omit; resolution cần fresh corresponding evaluation hoặc explicit supersession/invalidation. Repair immutable version, dynamic dependency closure stale trước re-evaluation. Journal/counters survive kill/resume.

Caps inventory bắt buộc: generations/repairs/total versions, runtime steps/no-progress/oscillation, transport attempts, calls/tokens/output cap, per-artifact/section/run/concurrency/candidate pool và deadlines. Units/count semantics tách generation vs repair, network vs domain attempts, reservation/reported/estimated/unknown. Các3-generated/2-repair/2-no-progress trong plan chỉ proposals.

Profile có nguồn quyết định rõ: dùng approved versioned profile hiện có nếu đủ evidence; nếu chưa có, task này giao supervisor chốt profile mới trong scope code/config reversible bằng explicit values/ADR/rationale và boundary tests. Starting 3-generated/2-repair/2-no-progress phải khai báo như quyết định mới, không giả defaults đã approved từ trước. Remaining caps có concrete values từ budget/deadline/feasibility evidence, được pin trước measurement.

Phân biệt rõ ràng giữa production caps và benchmark caps (chính sách mặc định toàn hệ thống):
- Profile production và các provider khác giữ nguyên hard caps nghiêm ngặt (15 calls / 60,000 tokens / 300s).
- Đối với MiniMax BENCHMARKS, toàn bộ application-imposed call, cumulative token, monetary và wall-time caps bị vô hiệu hóa ở cả campaign và child-run level (cấu hình explicit unlimited; ngăn chặn tuyệt đối fallback về 15 calls / 60k tokens / 300s).
- Live benchmarks tự động khởi chạy và resume bằng provider MiniMax đã cấu hình; loại bỏ phê duyệt thủ công của operator, authorization-file, phê duyệt campaign-budget hay chờ PENDING_AUTHORIZATION.
- Duy trì xác thực service, CAS/fencing, cancellation, truthful usage accounting, checkpoints, idempotent resume, bounded retries và per-request limits; tôn trọng giới hạn thực tế phía provider.
- Tách biệt phục hồi cục bộ và gate: R05 durability trên PostgreSQL thật có thể PASS độc lập trong khi G09 vẫn giữ nợ chất lượng upstream/live-quality (G07/G08 prerequisites); tuyệt đối không promote gate chỉ vì đã dỡ bỏ rào cản phê duyệt.
Typed Settings validate missing/empty/nonfinite/nonpositive/bad types/child-parent relations. Production không fallback silent development defaults. Khai báo trong effective deploy resolver, không chỉ .env.example. Trace injected policy từ composition tới runtime/gateway/budget admission; redacted effective dump/profile version/hash. Cap mới không tồn tại chỉ trong class.

Persist effective caps snapshot/version/hash/source khi run tạo, counters/grants transactionally. Resume dùng snapshot cũ dù env đổi; new config chỉ new runs. Old run thiếu snapshot có compatible migration/pause, không fabricate lịch sử từ current env. Backoff/timeouts/concurrency dùng remaining parent deadline/budget. UNKNOWN_OUTCOME không refund/free retry; accepted-output reuse vẫn authority check.

Chạy T06-01..08: five decisions; identical repair stagnation; A→B→A/issue churn finite; critical vs soft; missing/exception/malformed; kill every state/resume; stale descendants; cancel/takeover pre-accept. Finite-sequence/property coverage chứng minh termination trong caps; pure runtime no cloud, transaction tests real PostgreSQL.

Thêm IDs riêng cho caps: startup invalid; env injection thay behavior; N/N+1; concurrent reservations; restart pinned profile/counters; replay no double count; deadline+backoff. Run impacted G02/G03/G05. Report chính xác test ID còn thiếu trong51/52 nếu vẫn áp dụng, không suy đoán hay stamp PASS.

Lưu transitions/ledger/journal/caps/closure/fault evidence và contract bundle artifacts/refactor/phase-06/. Tách configured/validated/enforced vs actually deployed. G06 PASS khi required runtime/config evidence đủ; external G03 exception đúng contract không waive other checks. Hand off fixes/remedy/next commands và Phase07 readiness, không gọi skeleton đã chứng minh chất lượng IELTS.
```

## Prompt B — Verify độc lập và đóng findings

```text
Verify G06 độc lập theo Phase06 gốc, Validation Matrix, upstream evidence/caps ADR và 03-OUTPUT-AND-GATE-CONTRACT.md. Reviewer khác implementation author; supervisor sửa findings, reviewer rerun impacted checks, không report-only handoff nếu fixes nội bộ khả thi.

Trace actual Settings→deploy resolver→composition→runtime/gateway/admission→durable caps snapshot/counters. Field tồn tại/.env.example/class defaults không proof production configuration. Redacted effective hashes/source versions phải match execution. Missing/invalid production caps fail startup, no silent dev fallback.

Chạy T06-01..08:
01 PASS/REPAIR/REGENERATE/ESCALATE/FAIL transitions/reasons đúng.
02 same-hash repair stagnation bounded.
03 oscillation/churn terminate finite caps.
04 critical blocker không soft-score override.
05 required missing/error/malformed non-pass và durable record.
06 kill each durable state resume, no repeated committed work/reset budget.
07 passage changed làm exact descendants stale, section no PASS.
08 cancel/takeover trước accept reject stale commit.

Chạy caps regression IDs riêng: change env changes admission, N/N+1, parallel races, deadlines including waits, pinned profile/counters sau environment change/restart, replay accounting và UNKNOWN_OUTCOME. Kiểm tra total versions gồm repairs/transport semantics/candidate parent allocations. Pure tests fake cloud; transaction/fencing/resume real PostgreSQL harness.

Audit single control flow/capability imports, dynamic closure, ledger omission, atomic cursor/grants/ack. Required evaluator unsupported/missing không PASS; cache không writer authority. Old snapshotless run behavior explicit, no current-env historical fabrication.

Run impacted G02/G03/G05 checks; exact mapping/counts/exits và finite/property state coverage. Xác minh remaining ID nếu report51/52 còn referenced. External smoke exception không override failed internal tests hoặc config thiếu.

Mỗi blocker có proven repro/root cause hoặc discrimination, concrete fix/config decision/file scope, acceptance/regression/next command. Supervisor fix/rerun và khai báo profile còn thiếu trong scope được giao. Chỉ nếu explicit external approval thực sự bắt buộc theo repo/session, ghi rule/source và exact reviewable values/rationale cần chốt; không vague “cần production config”.

Lưu independent report/output bundle và canonical G06. Tách declaration/validation/enforcement/deployment observation. Local production-mode tests không actual deployment. G06/Phase07 readiness theo required evidence, coding-only exception ghi riêng. Không model-quality certification từ skeleton tests.
```

<!-- END SOURCE: phases/phase-06-loop-runtime.md -->

<!-- SOURCE: phases/phase-07-evaluators-repairs.md -->

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

<!-- END SOURCE: phases/phase-07-evaluators-repairs.md -->

<!-- SOURCE: phases/phase-08-passage-loop.md -->

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

Audit từng ghi MiniMax smoke PASS. Live paired passage benchmark tự động khởi chạy và resume bằng provider MiniMax đã cấu hình (loại bỏ phê duyệt thủ công của operator, authorization-file, phê duyệt campaign-budget hay chờ PENDING_AUTHORIZATION). Vô hiệu hóa toàn bộ application-imposed call, token, monetary và wall-time caps cho MiniMax BENCHMARKS ở cả campaign và child-run level (cấu hình explicit unlimited; cấm fallback về 15 calls / 60k tokens / 300s; production profiles giữ nguyên). Duy trì xác thực service, CAS/fencing, cancellation, truthful usage accounting, checkpoints, idempotent resume, bounded retries và per-request limits; tôn trọng giới hạn thực tế phía provider.

Freeze corpus/labels/prompts/model/config/caps trước measurement; no leakage/no evaluator-as-gold. Thresholds Matrix: critical 100%, recall 95% overall/90% each type, ambiguity 90%, false rejection≤10%; critical ≥3 repeats aggregate/worst. G08 PASS chỉ khi có bằng chứng live benchmark đạt ngưỡng; không promote gate chỉ vì đã dỡ bỏ rào cản phê duyệt. Chính sách này áp dụng mặc định cho tất cả các phase.

Findings → reproduce/root cause/fix/regression/reverify liên tục; không tự giảm thresholds hoặc weaken tests. External gap thật: hoàn tất independent code/tests/harness, exact missing input + secure config/setup + next actual command + cap/estimate có cơ sở + owner/resume. Live campaigns lưu campaignId/caseId, manifest/status và reservations; mất output hoặc agent restart thì reconcile trước retry, không chạy lại nguyên batch.

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

<!-- END SOURCE: phases/phase-08-passage-loop.md -->

<!-- SOURCE: phases/phase-09-question-candidates.md -->

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

G09 fake solver tests chứng minh input/composition behavior, không benchmark live solver quality. Khi live check cần thiết cho semantic coverage, tự động khởi chạy và resume bằng provider MiniMax đã cấu hình (loại bỏ phê duyệt thủ công của operator, authorization-file, phê duyệt campaign-budget hay chờ PENDING_AUTHORIZATION). Vô hiệu hóa application-imposed call, token, monetary và wall-time caps cho MiniMax BENCHMARKS ở cả campaign và child-run level (cấu hình explicit unlimited; cấm fallback về 15 calls / 60k tokens / 300s; production profiles giữ nguyên). Duy trì xác thực service, CAS/fencing, cancellation, truthful usage accounting, checkpoints, idempotent resume, bounded retries và per-request limits; tôn trọng giới hạn thực tế phía provider.

Tách biệt phục hồi cục bộ và gate: R05 QuestionCandidateLoop durability trên PostgreSQL thật có thể PASS độc lập trong khi gate tổng thể (G09) vẫn giữ nợ chất lượng upstream/live-quality (G07/G08 prerequisites). Tuyệt đối không promote gate chỉ vì đã dỡ bỏ rào cản phê duyệt. G09 PASS cần đầy đủ bằng chứng predecessor và candidate quality; final solver/adversary quality ghi pending G10. Chính sách này áp dụng mặc định cho tất cả các phase.

Loop thực thi: reproduce failure → root cause → fix → regression → rerun impacted checks → independent reviewer xác nhận. Không weaken constraints/tests/thresholds hoặc tự optionalize. Live campaigns lưu campaignId/caseId, manifest/status và reservations; mất output hoặc agent restart thì reconcile trước retry, không chạy lại nguyên batch.

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

<!-- END SOURCE: phases/phase-09-question-candidates.md -->

<!-- SOURCE: phases/phase-10-blind-solvers.md -->

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

Live smoke và held-out benchmark tự động khởi chạy và resume bằng provider MiniMax đã cấu hình (loại bỏ phê duyệt thủ công của operator, authorization-file, phê duyệt campaign-budget hay chờ PENDING_AUTHORIZATION). Vô hiệu hóa application-imposed call, token, monetary và wall-time caps cho MiniMax BENCHMARKS ở cả campaign và child-run level (cấu hình explicit unlimited; cấm fallback về 15 calls / 60k tokens / 300s; production profiles giữ nguyên). Duy trì xác thực service, CAS/fencing, cancellation, truthful usage accounting, checkpoints, idempotent resume, bounded retries và per-request limits; tôn trọng giới hạn thực tế phía provider.

Freeze clean source-family/near-duplicate split, provenance, labels/annotations độc lập evaluator, prompt/model/caps trước measurement. Tuning dùng dev. Thresholds Matrix: blocking recall≥95% total/≥90% each type; ambiguity≥90%; false rejection≤10% trên ≥60 valid; critical 100%≥3 runs aggregate/worst. G10 PASS chỉ khi có bằng chứng live quality đạt ngưỡng; không promote gate chỉ vì đã dỡ bỏ rào cản phê duyệt. Chính sách này áp dụng mặc định cho tất cả các phase.

Failure loop: reproduce/root cause/fix/regression/reverify. Không lower thresholds/required flags/labels. Live campaigns lưu campaignId/caseId, manifest/status và reservations; mất output hoặc agent restart thì reconcile trước retry, không chạy lại nguyên batch.

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

<!-- END SOURCE: phases/phase-10-blind-solvers.md -->

<!-- SOURCE: phases/phase-11-section-loop.md -->

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

<!-- END SOURCE: phases/phase-11-section-loop.md -->

<!-- SOURCE: phases/phase-12-paper-worker.md -->

# Phase 12 — Paper Loop, .NET worker và final Draft

Phụ thuộc: **G02, G06, G11**. Gate: **G12**. Dùng prompt A rồi B; supervisor xử lý findings và kiểm định lại trước nghiệm thu.

## A. Implementation và remediation

```text
Hoàn thành Phase 12 Langfens Loop Engine V2, gồm sửa findings và retest; chưa làm Phase 13.

Đọc AGENTS.md/CLAUDE.md, master plan, Validation Matrix, Phase 12 gốc và 03-OUTPUT-AND-GATE-CONTRACT.md của Prompt Pack V2. Bind actual paths/scripts/lockfiles. Giữ user changes. Xác minh G02/G06/G11 trên snapshot tương thích; upstream defect thuộc phạm vi sửa phải xử lý, không chỉ chép blocker. External evidence thiếu cho phép coding/test độc lập bằng fakes; chưa accept production artifacts hoặc mở gate.

Supervisor phân công worker Python paper/repair, worker .NET persistence/worker và test engineer theo file ownership; reviewer không viết implementation mình review. Có spawn tools thì chạy agents thật, không có thì làm các vai tuần tự và ghi limitation. Serialize shared edits/DB tests. Theo dõi sessions/tasks tới exit, cập nhật khoảng 60 giây; không fire-and-forget. Tiếp tục reproduce→fix→test→review→fix→retest, không dừng sau report FAIL nếu còn tự sửa được. Long-running agent không tăng production caps.

Map và hoàn thành P12-01..09:
- P12-01: immutable paper snapshot, đúng 3 sections, 40 câu liên tục 1–40; counts 13/13/14 và type distributions theo policy; từng passage 720–915, tổng 2150–2750.
- P12-02/P12-03: cross-section exact/shingle/semantic duplicates, concentration và leakage; version thresholds, phân biệt shared topic/vocabulary với duplicated content.
- P12-04: internal authenticated paper-evaluate/repair capability qua GenerationFacade, bind actual route/DTO với .NET caller; directives có exact refs, issues, preconditions, authority và budget.
- P12-05: item repair rerun affected section + paper; passage flaw invalidate đúng closure. Unrelated refs giữ nguyên, không regenerate toàn paper mặc định.
- P12-06: wire vào worker thật; engine/config pinned, heartbeat độc lập với provider wait; bounded reconnect/retries qua shared gateway/accounting.
- P12-07: reload authoritative heads, check fencing epoch/cancelVersion, fresh required paper evaluations rồi ReadingPaperRules.Validate; failure chặn BuildExam.
- P12-08: .NET final transaction chứa Exam/sections/groups/questions/options, unique run/job→ExamId, Completed và outbox; rollback không half-written graph. Python không ghi Exams trực tiếp; generation chỉ Draft, Publish do admin.
- P12-09: lost ack/replay trả cùng ExamId. Exactly-once là DB final graph, không phải cloud requests; unknown provider outcome giữ reservation.

Giữ canonical contracts, immutable versions, CAS, cancellation, caps snapshot và cache/dependency freshness. Không tạo retry loop hoặc writer store thứ hai.

Implement/map rồi chạy T12-01..08 trên Python+.NET+PostgreSQL thật: numbering; word-policy parity; duplicate/locality; leakage boundaries; stale lease/cancel; transaction failure; post-commit crash/replay; source→Draft→manual Publish/CRUD. Fake provider cho fault injection; live quality benchmark tự động khởi chạy và resume bằng provider MiniMax đã cấu hình (loại bỏ phê duyệt thủ công của operator, authorization-file, phê duyệt campaign-budget hay chờ PENDING_AUTHORIZATION).

Vô hiệu hóa application-imposed call, token, monetary và wall-time caps cho MiniMax BENCHMARKS ở cả campaign và child-run level (cấu hình explicit unlimited; cấm fallback về 15 calls / 60k tokens / 300s; production profiles giữ nguyên). Duy trì xác thực service, CAS/fencing, cancellation, truthful usage accounting, checkpoints, idempotent resume, bounded retries và per-request limits; tôn trọng giới hạn thực tế phía provider. G12 PASS chỉ khi required dependencies/checks và live quality evidence đạt; không promote gate chỉ vì đã dỡ bỏ rào cản phê duyệt. Chính sách này áp dụng mặc định cho tất cả các phase.

Lưu artifacts/refactor/phase-12/: gate.json, phase-report.md, native/test-report, commands.jsonl, snapshot-manifest.json, fix-log.jsonl, independent-review.md, resume.md theo canonical schemas. Snapshot gồm HEAD + dirty/untracked hashes, caps/config/model/prompt/corpus versions. Thêm route/DTO wiring trace, SQL constraint/transaction proof, final graph fixtures và repair closure diffs.

G12 PASS chỉ khi required dependencies/checks đạt trên snapshot này. Nếu còn external blocker, hoàn tất phần độc lập, ghi exact missing input, setup an toàn, actual next command, owner, acceptance và capped execution plan. Không yêu cầu paste key vào chat hoặc báo “cần nghiên cứu thêm” rồi dừng. Bàn giao status, fixes, evidence và readiness Phase 13, không tự stamp PASS.
```

## B. Independent verify và vòng sửa

```text
Làm supervisor kiểm định độc lập Phase 12 và điều phối remediation tới kết quả. Đọc plan/matrix/03-OUTPUT-AND-GATE-CONTRACT.md, G02/G06/G11 và implementation evidence; không tin summary PASS.

Spawn reviewer chỉ đọc candidate/write findings và test engineer chạy harness ở phạm vi riêng; owner sửa code. Nếu không hỗ trợ spawn, thực hiện tuần tự và ghi review limitation. Await/poll actual tasks/commands tới exit; findings tự sửa được phải giao fix, retest impacted checks rồi reviewer kiểm định snapshot mới, không kết thúc bằng report-only.

Trace actual .NET worker→authenticated Python facade→checkpoint boundary→reload heads→ReadingPaperRules→final transaction. Kiểm tra code/config hashes, lease/cancel/caps và lineage; reject missing/stale evaluations.

Chạy đủ:
T12-01: 39/40/41, missing/duplicate ordinals; chỉ valid 40 persist.
T12-02: Python/.NET cùng reject sai total/per-section range.
T12-03: duplicate/near-copy repair đúng closure; unaffected hashes nguyên.
T12-04: leakage trong instructions/câu khác, type-aware boundaries.
T12-05: lease takeover/cancel trước commit chặn stale writer.
T12-06: inject DB fault giữa graph creation/job completion; toàn transaction rollback, retry một exam.
T12-07: crash sau commit trước event; polling/replay cùng Draft ExamId.
T12-08: real E2E source→Draft→admin Publish và manual CRUD; impacted attempt/grading contracts tương thích.

Inspect unique constraint và atomic outbox, không chỉ application “check then insert”. Heartbeat phải renew khi provider chậm. Không claim cloud exactly-once. Kiểm tra skip/zero collected/nonzero exit/missing evidence; live benchmark tách fake-provider fault tests.

Lưu canonical evidence bundle phase-12 và independent findings/retest results. Mỗi unresolved blocker có repro, root cause/check phân biệt, fix đã thử, file/symbol work còn thiếu, owner, setup/next command/acceptance. Required failures giữ G12 BLOCKED; external chỉ khi prerequisite thực sự thiếu. Kết luận implementation, integration, live quality và readiness Phase 13 riêng. Chỉ mở gate khi evidence đầy đủ trên candidate cuối.
```

<!-- END SOURCE: phases/phase-12-paper-worker.md -->

<!-- SOURCE: phases/phase-13-api-events-observability.md -->

# Phase 13 — API, events, observability và UI

Phụ thuộc: **G01–G03, G11–G12**. Gate: **G13**. Dùng prompt A rồi B, tiếp tục sửa và retest đến đầu ra đạt.

## A. Implementation và remediation

```text
Hoàn thành Phase 13 Langfens Loop Engine V2, không chỉ report compatibility gaps; chưa làm Phase 14.

Đọc instructions repo, master, Validation Matrix, Phase 13 gốc, G00 contract snapshots và 03-OUTPUT-AND-GATE-CONTRACT.md. Bind paths/scripts/lockfiles thật; giữ user changes. Verify dependencies G01–G03/G11–G12 tương thích với code/config hiện tại; sửa upstream defects liên quan trong scope, không reuse gate chỉ vì HEAD giống.

Supervisor giao workers thin API/event projection và .NET consumer/UI theo disjoint files; test engineer kiểm tra actual transport; reviewer không viết thay đổi đang review. Spawn thật nếu available; nếu không, các vai tuần tự với limitation rõ. Serialize shared writes/DB/ports. Poll/await long-running tasks tới exit, update khoảng 60 giây. Reproduce→implement→test→review→fix→retest liên tục; không dừng sau findings còn sửa được hoặc giả process chạy nền đã PASS.

Map và hoàn thành P13-01..10:
- P13-01: thin public API→GenerationFacade, đúng main registration; route không provider call/policy/retry loop.
- P13-02: GET sources, POST source, POST source/ingest, POST section giữ actual mounts/path, fields/null/status/errors/media type của baseline; không suy đoán route tồn tại.
- P13-03: eventId, per-run sequence từ authoritative outbox, UTC timestamp, runId/operationId, exact artifact ref, schema/engine version, type, sanitized payload.
- P13-04: typed run/artifact/evaluation/issue/decision/section/paper events; Completed chỉ từ durable final fact, không từ progress text/EOF.
- P13-05: legacy projection chỉ phát shape/types old consumer chấp nhận; rich events opt-in/versioned. Test unknown-event behavior thật trước thay parser.
- P13-06: at-least-once replay/dedupe; reconnect cursor theo supported contract. Disconnect/EOF thiếu terminal event là incomplete; reconcile authoritative status trước retry.
- P13-07: bounded buffers/retention/rate, backpressure. Slow client không chặn heartbeat/checkpoint; terminal fact phải truy hồi được.
- P13-08: traces/metrics calls, latency, repairs, issues, exhaustion, stale writers/resume và tokens reported/estimated/unknown; pricing snapshot, không ghi estimated thành billed actual.
- P13-09: secret/reasoning/source redaction, metric cardinality bounded; runId chỉ trace/log với retention, UI errors sanitized.
- P13-10: actual gateway/frontend generation/polling/Retry/NeedsSources/Replace Sources/manual CRUD/Draft/Publish, không percentage giả completion.

Mọi buffer/concurrency/deadline cap mới khai báo Settings/deploy/profile và enforce; pin theo run nơi áp dụng. Giữ authoritative .NET persistence, fencing/cancel/shared budgets, immutable artifacts và living public adapters.

Implement/map rồi chạy T13-01..08: baseline parity, chunked UTF-8/JSON, replay/dedupe, disconnect reconciliation, backpressure/flood, secret canaries, trace/accounting, UI/gateway E2E. Test actual .NET NDJSON consumer và frontend, không chỉ Python event models. Đo bounded memory/buffer và heartbeat trong slow-client scenario. Test network/service path bằng real local stack, fault provider có kiểm soát.

Fix findings, rerun impacted finalization/runtime/provider/contract suites và review snapshot mới. Không weaken old-client assertions để có PASS. Build xanh không thay stream/UI tests; screenshot không thay durability/privacy assertions.

Lưu artifacts/refactor/phase-13/ canonical bundle: gate, phase/test reports, commands, snapshot manifest, fix log, independent review, resume. Snapshot ghi HEAD/dirty/untracked + effective config/caps/contract versions; thêm contract diff, actual stream recordings, redaction scans, backpressure/heartbeat observations, dashboard config và UI traces.

G13 PASS khi required checks/dependencies đạt trên snapshot cuối. Nếu external environment thực sự thiếu, hoàn tất adapter/harness/local stack có thể làm; ghi exact missing input, setup, owner, actual next command, acceptance và bounded run plan. Không gọi harness chưa viết là external. Bàn giao implementation/integration/observation status riêng và readiness Phase 14; chưa xóa living compatibility adapter.
```

## B. Independent verify và vòng sửa

```text
Supervisor kiểm định Phase 13 và thực hiện vòng remediation với code owner; reviewer giữ read-only implementation. Đọc plan/matrix/03-OUTPUT-AND-GATE-CONTRACT.md, G00 snapshots và G01–G03/G11–G12 evidence.

Spawn test/review roles thật nếu hỗ trợ, ownership rõ; otherwise sequential review với limitation. Await/poll mọi long-running session, inspect outputs/exit codes. Findings actionable phải reproduce, giao sửa, rerun impacted suites rồi verify candidate mới; không dừng với “BLOCKED” khi có thể sửa.

Trace public request→gateway→thin API/facade và authoritative outbox→projection→actual .NET/frontend consumer. Pin HEAD + dirty/config/contract hashes. Inspect full serialized transport, required statuses/nulls/errors/media types và old unknown-event behavior.

Chạy đủ:
T13-01: 100% required G00 public contract cases trên V2 adapter.
T13-02: UTF-8/JSON split chunks, blank lines; parse đúng hoặc typed error, không unhandled crash.
T13-03: duplicates/out-of-order/replay/reconnect không double-count hoặc duplicate exam.
T13-04: disconnect trước/sau commit; EOF không Completed giả, reconcile chính xác.
T13-05: slow client/flood bounded memory, heartbeat renew, terminal fact truy hồi.
T13-06: secret/thinking canaries không lộ NDJSON/UI/public logs/metrics.
T13-07: trace thật giải thích decisions, ledger, token accounting/unknown usage; dashboards pin config.
T13-08: actual UI/gateway E2E generation, Retry, NeedsSources, CRUD, Draft/manual Publish.

Inspect outbox sequence, replay retention, rate caps, logging/cardinality và transaction authority; live model quality không được suy từ consumer fake tests. Reject unexpected required skips/zero collected/missing evidence. Nếu stream code chạm finalization, rerun impacted G12 fault checks.

Lưu independent review/retest và canonical evidence phase-13. Blocker còn lại cần repro, proved root cause hoặc discriminating check, attempted fix, exact remaining files/setup/input, owner và executable next command/acceptance. G13 PASS chỉ khi required checks đạt trên candidate cuối; tách implementation, compatibility, UI/operational observations và readiness Phase 14. Không fabricated metrics hoặc tự bỏ required cases.
```

<!-- END SOURCE: phases/phase-13-api-events-observability.md -->

<!-- SOURCE: phases/phase-14-human-feedback.md -->

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

<!-- END SOURCE: phases/phase-14-human-feedback.md -->

<!-- SOURCE: phases/phase-15-cutover-cleanup.md -->

# Phase 15 — Release verification, cutover và legacy cleanup

Phụ thuộc: **G00–G14**, gồm required external checks. Gate: **G15**. Implementation/staging hoàn tất không thay production observation.

## A. Implementation, remediation và release

```text
Hoàn thành Phase 15 trong operational authorization thực sự có. Đọc repo instructions, master/matrix, Phase15, 03-OUTPUT-AND-GATE-CONTRACT.md, G00–G14 và deletion inventory. Giữ user changes; bind actual scripts/images/deploy targets.

Supervisor giao release test engineer, benchmark worker, deletion worker và read-only reviewer theo ownership. Spawn thật nếu supported; otherwise tuần tự, limitation rõ. Tests dùng isolated DB/ports/budgets; shared writes serialize. Poll/await sessions/agents tới exit, update khoảng 60 giây. Không fire-and-forget, không fabricate overnight observation; keep resume checkpoints. Reproduce→fix→retest→independent review tới đạt hoặc external blocker thật, không kết thúc sau report-only.

Hoàn thành P15-01..10:
P15-01 freeze SHA/dirty/untracked hashes, image digest, schema/policy/caps/prompt/evaluator/model/corpus/pricing versions. Changes sau freeze invalidate impacted evidence.
P15-02 run required matrix: 124 IDs gốc + bổ sung, unit/contract/security/DB-fault/semantic/E2E. Required skip/NOT_RUN/zero collected chặn release; harness thiếu phải viết.
P15-03 shadow staging, frozen sources legacy/V2; chỉ primary persist final exam, shadow budget riêng bounded. Paired release benchmarks tự động khởi chạy và resume bằng provider MiniMax đã cấu hình (loại bỏ phê duyệt thủ công của operator, authorization-file, phê duyệt campaign-budget hay chờ PENDING_AUTHORIZATION). Vô hiệu hóa application-imposed call, token, monetary và wall-time caps cho MiniMax BENCHMARKS ở cả campaign và child-run level (cấu hình explicit unlimited; cấm fallback về 15 calls / 60k tokens / 300s; production profiles giữ nguyên). Duy trì xác thực service, CAS/fencing, cancellation, truthful usage accounting, checkpoints, idempotent resume, bounded retries và per-request limits; tôn trọng giới hạn thực tế phía provider. ≥18 paired papers/engine, ≥6 distinct source triples; cùng env/providers/corpus/settings, đổi provider thì report experiment riêng. Eligibility denominators, raw distributions, annotation rubric/source-family holdout rõ. Critical semantic cases ≥3 runs, aggregate và worst run. Không tuning holdout hoặc fake independent labels.
P15-04 staging rồi authorized new-run canary 10%→50%→100%, run pin engine/config. Proposed minimum ≥20 completed eligible jobs +≥24 giờ phải freeze trước rollout, điều chỉnh theo volume có rationale trước measurement. Quyền triển khai production thực tế phân biệt riêng với benchmark execution; hoàn tất reversible code/staging/rehearsal trước bước bị giới hạn.
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

<!-- END SOURCE: phases/phase-15-cutover-cleanup.md -->

<!-- SOURCE: 04-FINAL-VERIFICATION-PROMPT.md -->

# Prompt nghiệm thu cuối — Independent audit và corrective handoff

---

Bạn là independent release reviewer của Langfens Loop Engine V2. Thực hiện final acceptance audit trên repository/candidate thực sự. Đọc applicable AGENTS.md/CLAUDE.md, plan/master/Validation Matrix/all phases, canonical manifest, caps ADR, release/deletion/rollback evidence và `03-OUTPUT-AND-GATE-CONTRACT.md`.

Reviewer không sửa business implementation để tự biến findings thành PASS. Supervisor/test owner nhận corrective tasks, sửa và đưa consistent snapshot mới cho reviewer retest. Task chỉ kết thúc khi đạt hoặc blocker thực sự có executable remediation/checkpoint; không giao mỗi báo cáo lỗi.

## 1. Snapshot và gate coverage

Pin candidate HEAD, dirty/untracked hashes nếu chưa commit, image/config/policy/caps/prompt/evaluator/model/schema/corpus versions. Verify all G00–G15 và 124 test IDs gốc cộng additions; giữ planning manifest khác execution results.

Mỗi required ID phải map executable node/check, command, result, exit code, case count và evidence thật. Detect missing IDs/zero collected/unexpected skips/stale SHA-config/phantom background sessions. Report IDs và test cases riêng. Reuse evidence chỉ khi compatible; rerun invalidated required release checks trên candidate cuối.

## 2. Actual architecture và output chain

Trace public/internal entrypoints và workers qua source ingestion/security/provenance → evidence → blueprint → passage → candidates → blind/adversarial review → section → paper → final .NET validation/transaction.

Một canonical model/policy layer, một bounded runtime/control flow, required registry coverage và shared gateway. Không direct SDK bypass, nested unaccounted retries hoặc classes chỉ được fake unit tests sử dụng. Production Settings/deploy resolver injection/caps snapshot đi tới actual execution.

Every acceptance có exact fresh parent refs/evals và zero ledger blocker; missing/error/unsupported type/incomplete coverage không PASS. Passage word/style/grounding checks support PASSAGE, kiểm tra toàn factual coverage với independent approved sources kể cả unaligned/rhetorical attacks. No generated-text self-grounding. NO/NG relation semantics và serialized blind input phải đúng.

## 3. Durability, budgets, locality

Run kill/replay/resume/unknown provider outcome/cancel/lease takeover/source replacement/version-change cases. Real PostgreSQL/service-boundary evidence, authority/CAS/idempotency constraints và checkpoints kiểm tra trực tiếp.

Không lost committed work, stale writer accept, duplicate final exam, quota reset/double counting hoặc unsafe refund unknown outcome. Repair giữ unrelated accepted refs, invalidates correct consumer closure và re-evaluates required scope. Trim/word count repair không invent facts/cắt ngang câu/giữ unsupported outcome sau đổi modal.

## 4. Compatibility và E2E

Source→3 sections→40 contiguous questions→Draft→admin edit/feedback→manual Publish→attempt/grading compatibility theo affected shared contracts. Types/counts/passage/full-paper ranges theo plan đạt 100% accepted-graph fixtures.

Verify public routes/media/null/errors, .NET NDJSON chunks/UTF8/dedupe/disconnect/reconnect/backpressure, gateway/frontend polling/Retry/NeedsSources/Replace Sources và manual CRUD. EOF/progress không được giả completion; generation không auto-publish. Redaction/privacy không lộ keys/hidden reasoning qua errors/logs/metrics/student views.

## 5. Clean quality và operations measurement

Source-family/near-duplicate-clean frozen datasets; enough minimum cases/valid denominators; annotation provenance/review limitations thật. Tested evaluator/heuristics không được tự làm gold labels. Known leaked measurement invalid, holdout không dùng tuning/examples.

Apply Validation Matrix: critical canaries100%; semantic recall≥95% tổng và≥90% per type; ambiguity recall≥90%; false rejection≤10%; repeated critical runs≥3 với aggregate/worst run. Report confusion matrices/denominators và no unsupported accepted canaries.

Paired release benchmark≥18 papers/engine và≥6 source triples, consistent conditions, actual valid-Draft rate/fidelity/ambiguity không kém legacy theo rubric. P95 latency≤1.5× legacy và hard deadline; median cost/token≤2× theo accounting policy. Report distributions/sample size/unknown usages và limitation, không statistical superiority claim từ mẫu nhỏ.

Smoke không thay semantic benchmark; real DB + fake provider không thay live quality.
Benchmark campaigns tự động khởi chạy và resume bằng provider MiniMax đã cấu hình (loại bỏ phê duyệt thủ công, authorization-file, duyệt campaign-budget hay chờ PENDING_AUTHORIZATION). Vô hiệu hóa application-imposed caps cho MiniMax benchmarks ở cả campaign và child-run level (cấu hình explicit unlimited; cấm fallback về 15 calls / 60k tokens / 300s; production profiles giữ nguyên).
Duy trì xác thực service, CAS/fencing, cancellation, truthful usage accounting, checkpoints, idempotent resume, bounded retries và per-request limits. Tách biệt phục hồi cục bộ (R05 durability PASS trên PostgreSQL thật) khỏi gate tổng thể (G09 nợ live quality upstream); không promote gate chỉ vì dỡ bỏ rào cản phê duyệt. Chính sách này áp dụng mặc định cho tất cả các phase.
## 6. Feedback, cleanup, canary và rollback

Durable edit capture/curation/export/split/offline comparison/reviewed version promotion; new runs vs in-flight pins đúng. Raw admin edits không tự deploy prompt/model hoặc thành gold.

Deletion inventory có exact responsibility transfer, callers/DI/imports, behavior tests, old data compatibility và drained-run proof. Zero executable obsolete pipeline refs, historical docs allowlist; live boundary adapters/readers giữ khi cần.

Rollback pinned image trên current additive schema có rehearsal/checkpoint/feedback proof. Actual canary stage/sample/time-window criteria đã pin trước rollout; production access/authorization/observation được xác nhận thật. Staging hay synthetic tests không thay production observation. Nếu chưa thực hiện, status chưa PASS với exact operational remedy, không sleep24h hoặc tạo số liệu giả.

## 7. Findings thành executable repair tasks

Với mỗi defect: ID/severity/invariant, repro command + expected/observed, root cause/evidence, exact owner/file/symbol fix scope, regression/quality checks và acceptance. Supervisor thực hiện fixes và cung cấp snapshot mới; reviewer rerun impacted checks và update closure.

Với external blocker: exact input/environment/quota/authorization thiếu, work đã chuẩn bị, safe setup location, next command và bounded resume plan. Không gọi code/harness missing là external. Nếu bế tắc nội bộ, giao next experiment/technical decision với attempts đã thử, không false-PASS/false external.

## 8. Final acceptance output

Lưu final independent report, canonical gate reports, fix closure, commands/exit codes, snapshot/fixture/campaign/image hashes, benchmark/chaos/deletion/canary/rollback evidence và reproducible references. Reports/link targets phải tồn tại.

Kết luận riêng:
- Implementation scope complete.
- Required deterministic/integration/semantic release candidate checks verified.
- Staging readiness.
- Actual production deployment/canary status.
- Overall acceptance PASS/BLOCKED và next executable action.

Overall PASS chỉ khi all required conditions đạt trên candidate cuối. Khi còn blocker, evidence/report chính xác là bắt buộc, nhưng supervisor còn phải giải quyết công việc trong quyền/công cụ/budget và bàn giao remedy cụ thể cho phần chưa đạt.

<!-- END SOURCE: 04-FINAL-VERIFICATION-PROMPT.md -->
