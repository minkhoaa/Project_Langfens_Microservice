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
