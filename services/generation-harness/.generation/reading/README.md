# Reading domain extension

Seven independent native tools, backed by the unchanged canonical contract at `../contracts/question-types.v1.schema.json` (`urn:langfens:question-types:1.0.0`). Product code is strict ESM TypeScript; tests/finite benchmarks are `.mjs`. No new packages, orchestration, inference, agent definitions, policy hooks or consumer mutations.

## Loading

From `services/generation-harness/`, run `npm run start:reading` for native TUI, or `npm run start:reading -- --mode rpc` for RPC. The operator-requested alias selects this project CWD and explicitly loads `.generation/extensions/reading.ts`, retaining native Subagents and `/config` without `--approve` or any Reading workflow.

Native project discovery or an absolute `--extension` path still works. Ordinary `npm start` retains `.runtime/workspace` as its default CWD and does not implicitly load Reading. No native/Core package or automatic project-settings override is changed.

## Tools

```js
get_question_spec({type: 'SENTENCE_COMPLETION'})
validate_question({question})
validate_group({group})
validate_exam({exam})
verify_evidence({question, passage: {id: 'p1', text: 'A river flows.'},
  evidence: {sourceId: 'p1', start: 2, end: 7, quote: 'river'}})
check_grading_parity({question, submission})
inspect_delivery_projection({question})
```

These calls have no required order, sessions, profiles, retries or hidden prerequisites. Exact canonical literals only; unsupported types return available literals. No coercion, normalization, artifact rewrites or silent repair. Unknown fields fail explicitly. Reports include contract hash/version, checks and stable field-level diagnostics. `ERROR > FAIL > UNVERIFIED > PASS`; a successful structure check does not remove semantic/consumer uncertainty.

### Container conventions

Question/Option shapes remain solely canonical. There is no authoritative Group/Section/Exam JSON Schema in v1; these tools use documented source-derived nested authoring containers:

```js
{ id: 'exam1', sections: [
  { id: 'section1', idx: 1, questionGroups: [
    { id: 'group1', idx: 1, questions: [question] }
  ] }
] }
```

Known descriptive source fields are optional. Group `sectionId`, `startIdx`, `endIdx`, `instructionMd` are optional. Completion word-limit validation checks the Question prompt plus supplied containing Group `instructionMd` and Section `instructionsMd`. Without supplied external ancestry, a standalone Question/Group cannot establish that no limit exists; a complete-requested Exam with supplied ancestry and no recognizable limit reports the missing limit. Conflicting recognizable instructions remain `UNVERIFIED`; word-count profile and precedence are not inferred. Legacy Section-level `questions` is recognized without synthesizing a group; simultaneous nonempty grouped/ungrouped collections fail rather than silently discard content. Groups may mix types and sizes. Draft coverage is unverified; only `exam.complete:true` requests full paper-wide coverage. Optional `exam.expectedQuestionCount:N` counts Question records, not slots. No implied 13/40 Questions or type rotation. Typed .NET delivery sorts by idx while JSON snapshot delivery preserves supplied traversal; no transport equivalence is claimed.

### Evidence and answers

Evidence offsets are zero-based UTF-16 code units, end-exclusive; exact slicing only, no normalization/search. A passage string is accepted but cannot prove an asserted source identity. Mechanical spans cannot establish entailment, factual truth or NOT GIVEN absence.

Submission accepts the canonical wire answer directly (lifecycle unspecified), or `{state:'autosave'|'final'|'restored', answer:wireAnswer}`. Only explicit `final` requests a complete answered response; this is not a claim that the backend rejects unanswered final Questions. Autosave/restored subsets preserve exact blank/statement/node identities. Explicit clearing is `selectedOptionIds:[]` plus `textAnswer:''`; omission/null is not clearing. Duplicate encoded JSON members, including escaped-equivalent names, are rejected. Wrong-but-valid answers are not rejected merely for earning zero.

One backend Question is one all-or-nothing scoring unit. Multi-blank/target Questions and multiple selections do not silently become separate IELTS marks. Actual .NET execution/regex/normalization, persisted identity mapping and frontend autosave/restore round trips remain UNVERIFIED. `sources.v1.json` pins inspected source fingerprints, not deployed or executed consumer evidence; flow legacy Steps/Labels divergence is recorded without changing canonical array answers.

### Public-only projection and blind solving

Projection builds fresh objects from canonical StudentQuestion/PublicOption allowlists. It preserves public media, membership, banks and input identities; private keys, correctness, explanations and reviews never become student fields. Known leakage/invalid content withholds the projection. Explicit answer-key/correct-answer/solution/teacher-note headers are screened at line and sentence boundaries, including common blockquote, list, indentation and emphasis wrappers. Only finite generic Answer(s) response-direction forms are treated as benign; stronger private headers are never exempted by direction-shaped values. Natural occurrence of an answer word is not automatically leakage; encoded/semantic hints remain unverified.

FLOW_CHART remains process ordering. Public labels must already exist in prompt lines `- key: label`; unsupported presentations remain unverified, not platform-invalid. Nodes display in deterministic key order independent of private solution order. Missing public labels never come from private keys or examples.

Only the returned `data.studentQuestion` is a candidate public input, not full reports/spec examples or authoring transcripts. Independent blind solving additionally needs a fresh native context, public-only inputs and verified OS-level denial of access to private files/tools/credentials/history, including symlink/absolute-path negative-access evidence. CWD/worktree separation is not filesystem isolation. This extension installs no solver, sandbox or delegation wrapper.

## Native error/result boundary

Normal execution returns equal JSON text, `details` and `structuredContent` in the native execution event. The existing native tool-result **transcript** drops `structuredContent` while retaining text/details; no Core patch is made. Invalid outer calls fail through the public argument hook as sanitized JSON text; pre-execution details/structuredContent are not guaranteed. Provider/RPC JSON parsing and cancellation before this hook retain native behavior. Cancellation is checked again after lazy domain initialization, before domain execution; rejected lazy imports are cleared for a later explicit call, without automatic retry loops, while concurrent initialization remains shared. A consumer requiring uniform structured pre-execution/transcript results needs a separately scoped SDK capability, not fabricated evidence.

## Resource limits

Inputs: 2,000,000 encoded UTF-8 bytes, 50,000 value nodes, depth 32, 10,000 entries/container. Canonical file: 1,000,000 bytes with exact snapshot integrity. Diagnostics: 250 plus truncation; check details: 2,000 plus truncation; encoded results: 2,000,000 bytes. Programmatic non-JSON values/accessors/proxies/cycles fail without invoking their user code. Identical bounded inputs and contract produce equivalent results.

## Offline verification

Run from `services/generation-harness/`:

```sh
GENERATION_HARNESS_OFFLINE=1 node --test .generation/reading/test/*.test.mjs
node node_modules/typescript/bin/tsc -p .generation/reading/tsconfig.json
GENERATION_HARNESS_OFFLINE=1 npm run typecheck
GENERATION_HARNESS_OFFLINE=1 npm run build
GENERATION_HARNESS_OFFLINE=1 npm test
GENERATION_HARNESS_OFFLINE=1 npm run smoke
GENERATION_HARNESS_OFFLINE=1 node .generation/reading/bench/overhead.mjs
```

Every executable test/benchmark imports the existing network/credential guard. Native fixtures use disposable directories and in-memory credentials/faux provider. Root `npm test` runs the Reading domain suite after the existing harness tests and before the Subagents workspace suite. No live inference, production data, publishing, commits or pushes are authorized.

The finite benchmark measures declaration bytes, canonical read/parse/compile counts in a fresh instrumented subprocess, registration deltas and warm calls (five warmups, twenty samples). Instrumentation is test-only, not a runtime telemetry framework. Mock first-attempt tool-call acceptance is not live-model reliability or IELTS output quality. See `PROGRESS.md` for executed evidence and rulings.
