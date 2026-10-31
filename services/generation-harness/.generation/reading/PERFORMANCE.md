# Minimal Reading performance fix — offline evidence

## Scope and provenance

No Core/SDK/Subagents package, canonical contract, backend contract, model, scheduler or coordinator changed. Existing dirty-tree Reading work was retained. No live provider calls, publication, commits or pushes were made.

Analyzed the actual native parent session:

`.runtime/reading/sessions/2026-10-30T17-08-07-902Z_01a18dc8-785e-76b2-9564-05c109039883.jsonl`

SHA-256: `6efe7d95a0794c0eb42ae788720db2b605ed1b41d589fdaa5b9f4fd942310f2d`.

Its matching directory contains seven native child `run-0/session.jsonl` files. Do not also count `subagent-artifacts/*_transcript.jsonl` or async event mirrors: those duplicate events. `bench/native-trace.mjs` reads only the native parent and matching child sessions. Raw session/artifact data remain local and were not copied into the patch.

## Measured historical run (not a benchmark estimate)

| Metric | Parent | Parent + seven children |
| --- | ---: | ---: |
| Model responses | 120 | 248 |
| Recorded request duration sum | 4,139.793 s | 8,153.807 s (overlapping children) |
| Input tokens, excluding cached reads | 1,404,936 | 2,684,589 |
| Output tokens | 656,991 | 1,378,676 |
| Cached input token reads | 45,772,388 | 57,144,123 |
| Total recorded usage | 47,834,315 | 61,207,388 |
| Tool calls / error results | 268 / 92 | 627 / 291 |
| Exact repeated calls within a session | 10 | 34 |
| First-tool-name attempts accepted | 9/15 | 35/62 (56.5%) |
| Tool argument JSON bytes | 857,315 | 1,636,181 |
| Tool result text bytes | 2,181,065 | 4,715,082 |

“First attempt” means the first invocation of each tool name in each session; accepted means `!isError`, including UNVERIFIED, **not** semantic PASS. Exact repeats compare sorted JSON arguments within one session; changed arguments/revisions are not counted as exact repeats. Tokens are provider-recorded request usage, including repeated cached-context reads, **not unique context tokens**. Byte counts are not token estimates.

The first request was at **17:08:19.807Z**, initial completion at **18:29:53.972Z**: **81m34.165s**, six children. Parent request durations alone consumed **64m45.318s** in that phase (110 responses, 258 tools, 91 errors). Follow-up requests at 18:43:20.960Z and 18:44:42.576Z asked where the full exam was and then requested canonical JSON. Export verification launched a seventh child. The last reply at **18:54:51.344Z** gives **106m31.537s** full wall time, including human idle/follow-ups; it is not all generation latency.

Parent request latency: median **23.665s**, p95 **108.645s**, maximum **256.583s**. Largest recorded parent request input plus cached reads: **982,722 tokens**. One compaction occurred at 17:59:22.611Z. These are observed request durations, not isolated model inference time; compaction latency is not separately available.

Recorded tool execution durations total only **1.796s** across parent and children (parent **1.003s**). They exclude asynchronous child work. Local validator CPU/contract-loading optimization cannot explain or remove the hour-long run.

## Verified causes and minimal changes

1. **Offset guessing, not expensive evidence execution.** Parent made 33 `verify_evidence` calls, 32 failed; it supplied **913 spans**, often sliding the same quote over many adjacent offsets. Evidence alone contributed 287,424 argument bytes and 498,214 result bytes in the initial phase. Native `bash` was deliberately absent from the Reading author and reviewer allowlists. Restored that existing capability for deterministic JSON assembly, JavaScript UTF-16 offsets, counts and hashes; profile instructions prohibit offset sweeps. Exact evidence validation/semantic uncertainty are unchanged.
2. **Opaque nested tool schemas and repeated reserialization.** Native calls contain `idx:"1"`, `complete:"true"`, `options:{item:...}`, `sections:{item:...}`, boolean truth labels, missing option indices and inconsistent reconstructed group IDs, while saved files contain valid JSON. The export-verification child retried 18 structural calls including a canonical control example. Explicit structural wire hints and bounded `{file,pointer}` inputs on the existing tools avoid retyping saved Questions/Groups/Exams. Reads use native tool cwd, RFC 6901 selection, no cross-call cache, no coercion or repair. Raw type mismatches are rejected before native coercion. Missing/invalid artifact inputs return ERROR, not a domain verdict. Canonical fields and domain rules remain authoritative.
3. **Unproductive retries mixed with genuine content revisions.** There were 89 evidence errors, 86 question errors, 42 grading errors, 33 group errors, 23 exam errors and 16 projection errors across all sessions (plus two builder errors). Repeating local authoring IDs as submission UUIDs cannot establish a verified backend identity map. Profiles now report unavailable identity/.NET evidence once rather than chase PASS. Native malformed calls remain rejected; they are not silently “fixed”. For example, the examiner's raw assistant tool-call record at 18:15:24.777Z already contains boolean `true`/`false` as truth-label `contentMd`, before the domain result. The exact upstream source of the provider's malformed argument encodings is **not established offline**. In particular, reviewer assertions of a broken canonical validator/transport are not proof of a Core defect: saved canonical truth-label objects pass the native offline path.
4. **Speculation and reconstruction inflated context.** Parent retrieved 10 distinct type specs (12 calls), though the final paper uses two types; the final two specs were retrieved again. It called `create_single_choice` **70 times** for 13 final items. Nine writes included multiple full reconstructions and late Markdown/JSON exports. Profiles now choose task types before retrieval, reuse specs once per context, save the canonical Exam before review, use file references, and recognize that builders validate returned Questions and `validate_exam` already traverses contained Questions/Groups. Structural calls need not be triplicated for unchanged content. Independent reviewers still retrieve their own needed specs.
5. **Review churn and mutable review inputs.** Review pairs launched at 17:36:30, 17:47:32 and 18:14:45; the second pair started before the first semantic review finished (17:51:02). The seventh child only checked the late export. Eight parent status queries added no content review. Profiles now freeze the same artifact revision for both fresh, independent reviewers, permit native parallel read-only review, collect both reports before consolidating material changes, and rerun only affected reviews. Native completion wakes replace polling. Cosmetic report bookkeeping does not invalidate unchanged content review. Some recorded reviews found real weaknesses; **not every revision/review is redundant**, and there is no hard two-child cap or automated stopping rule.
6. **Incomplete handoff and polluted explanations.** The final canonical export has 13 Questions and keys but no passage or passage reference; its outer `section.json` references companion files. All 13 exported `explanationMd` values contain review/revision history. Author/reviewer instructions now require an embedded `sections[].passageMd` (or explicit companion references in the final handoff), private canonical keys, and separate revision-bound review reports, never review history in `explanationMd`. These are model instructions, not a new content sanitizer or contract restriction. Existing user artifacts were not rewritten.

## Before/after offline measurements

### Same saved 13Q export: recorded malformed calls versus file-backed validation

Input export: `.runtime/reading/workspace/exam-rewetting-the-north.json`, SHA-256 `4dcfb571fc0364ac96753e30864890170316bd6f47de62a3149036110b4491e9`.

`bench/artifact-replay.mjs` replays the export-verification child's failed structural calls whose Question IDs belong to this export, excluding its unrelated control example. It uses the actual native tool path with in-memory credentials and a faux provider. The “before” inputs are historical malformed calls through the **patched** preparation boundary, not a rerun of old source/provider code. The “after” uses one file-backed Exam call, which checks every contained Question/Group.

| Metric | Recorded-input replay | File-backed coverage |
| --- | ---: | ---: |
| Native wall time (one cold offline sample) | 151.660 ms | 36.965 ms |
| Tool calls / failed calls | 17 / 17 | 1 / 0 |
| Call acceptance | 0% | 100% |
| Argument JSON bytes | 69,371 | 163 (absolute path) |
| Result text bytes | 6,936 (preparation failures) | 53,993 (full domain report) |
| Provider tokens / child launches | 0 / 0 | 0 / 0 |

The successful report verifies **1 section, 2 groups, 13 Questions, 13 answer slots and 13 scoring units; hierarchy/structure PASS**. Semantic shape, IELTS semantics and consumer compatibility remain UNVERIFIED. The larger successful report is expected, not hidden. All seven tools also have native regressions proving saved-reference results equal direct-value results, including exact Unicode offsets and submission/projection checks. Changed/bad files are not cached, coerced or repaired.

### Existing offline CLI fixture, before/after scripted tool choices

The existing `start:reading`/coding isolation regression used 31 faux responses and 28 calls (22 domain calls), redundantly validating 13 Questions, their Group and Exam. The revised fixture uses a builder plus Exam traversal and references: **18 responses, 15 calls (9 domain calls)**. Both versions launch **two fresh independent native specialists**, make no failed calls (first-name acceptance 100%), and report **NOT READY** for the intentionally poor duplicate-item/tiny-passage fixture. This is a finite native wiring/coverage regression, **not an autonomous LLM decision or IELTS-quality evaluation**. Fixture wall time including its coding-mode probe was 1.802s before and 1.660s in the full after suite; the final targeted rerun took 1.813s, demonstrating that single samples are not a reliable latency comparison. Faux token usage is zero in both versions, not evidence of real token savings.

The offline CLI verifies `SYSTEM.md`, all six builders, canonical validators, both specialist profiles/authorized tools, fresh contexts without author history, and unchanged ordinary coding startup. The output fixture embeds passage, 13 Questions and 13 private keys and excludes review history from explanations. No pipeline is injected into production.

### Cost/trade-off

Explicit nested wire shapes and file-reference descriptions increase declarations. In the measured native CLI author request, declarations grew **21,042 → 38,514 bytes**; reviewer declarations **4,622 → 19,162** (semantic), **4,591 → 18,331** (examiner). These are bytes, not tokens. That upfront cost is intentional to disambiguate the observed malformed shapes and permit small reference calls; live amortization has not been measured.

Fresh offline microbenchmark (Node v24.21.0; 5 warmups, 20 samples): 13 domain tools, **35,402 declaration bytes** excluding native tools; cold registration **137.165ms**, first Question execution **15.205ms**, warm Question median/p95 **0.099/0.175ms**, warm 100-Question Exam **4.092/5.197ms**. Registration loads one canonical JSON module but compiles no validators, reads no vectors/source snapshots. No runtime telemetry infrastructure was added.

## Reproduce and verification

From `services/generation-harness/`, with the local native traces/artifacts retained:

```sh
GENERATION_HARNESS_OFFLINE=1 node .generation/reading/bench/native-trace.mjs \
  .runtime/reading/sessions/2026-10-30T17-08-07-902Z_01a18dc8-785e-76b2-9564-05c109039883.jsonl
GENERATION_HARNESS_OFFLINE=1 node .generation/reading/bench/artifact-replay.mjs \
  .runtime/reading/sessions/2026-10-30T17-08-07-902Z_01a18dc8-785e-76b2-9564-05c109039883/0f2073d3-f77c-42d8-b2e9-aaa20b6a5ac0/run-0/session.jsonl \
  .runtime/reading/workspace/exam-rewetting-the-north.json
GENERATION_HARNESS_OFFLINE=1 node .generation/reading/bench/overhead.mjs
GENERATION_HARNESS_OFFLINE=1 npm test
```

All benchmark/test imports use the repository offline/network/credential guard. Baseline Reading suite: 130 PASS. Full after `npm test`: root 87 PASS; Reading 133 PASS; Subagents 3,491 PASS, 13 skipped, zero failures. The final Reading suite, including the added truth-label regression and handoff assertions, passed **134/134**. Root `npm run typecheck` and `git diff --check` also passed. Focused regressions cover exact references, missing/oversized/mutated files, escaped pointers, truth-label types, native error distinction, profile guidance and trace accounting. No new dependency was added.

## Remaining limitations

- **No after live 13Q run:** real after wall time, tokens, first-attempt reliability, child/review counts and semantic/IELTS quality are unmeasured. Recorded usage and native replays are not a provider speedup claim.
- The real export's missing passage, review-polluted explanations, reviewer-reported difficulty cue/unsourced passage concerns and missing backend identity/.NET/UI evidence are not repaired or certified by this performance patch. Offline schema PASS does not settle those findings.
- Prompt guidance does not guarantee model compliance or eliminate necessary content review iterations. Both independent reviews remain required; material changes invalidate affected evidence. Fresh contexts/read-only instructions/native bash are not filesystem isolation.
- File references require accessible frozen local files; they do not provide snapshot transactions, OS sandboxing or a new artifact contract. Native provider parsing/streaming errors remain native errors. No upstream provider/Core change was attempted.
