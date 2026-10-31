# Reading domain extension

13 independent native tools (seven existing checks plus six creation builders), backed by the unchanged canonical contract at `../contracts/question-types.v1.schema.json` (`urn:langfens:question-types:1.0.0`). Product code is strict ESM TypeScript; tests/finite benchmarks are `.mjs`. No new packages, orchestration, inference or policy hooks. The Reading startup profile uses four native specialist definitions and an Exam Designer prompt. Separately scoped backend bug repairs and their offline evidence are recorded in `PROGRESS.md`; the canonical contract remains unchanged. The operator-authorized P1-06 SDK exception adds only an opt-in preparation-error formatter; it does not change runtime orchestration or default tool errors.

## Loading

From `services/generation-harness/`, run `npm run start:reading` for native TUI, or `npm run start:reading -- --mode rpc` for RPC. The alias explicitly loads `.generation/extensions/reading.ts`, native Subagents and `/config`. Native CLI flags select `SYSTEM.md`, a Reading tool allowlist (including native bash for deterministic local artifact operations), no ambient extension/skill/prompt/context discovery, and no project trust (`--no-approve`). There is no Reading workflow or coordinator.

Reading state, credentials and workspace are separate: `<runtime>/reading/{agent,home,sessions,workspace}` (default runtime `.runtime`). `settings.json` seeds native user settings once, disabling SWE builtins and scanning the owned `agents/` directory. Edit this profile's provider/model settings with its `/config`; coding credentials are not copied. The explicit Reading extensions remain loaded even with `--no-extensions`, as native CLI explicit paths do. Ordinary `npm start` retains its existing coding prompt, tools, discovery, state and `.runtime/workspace` CWD. A direct extension load adds tools only, not the Reading profile.

`semantic-checker` and `ielts-examiner` are advertised native roles alongside `passage-author` and `question-author`. All four replace the coding prompt, default to fresh context and explicitly load the Reading extension with distinct tool allowlists and role instructions. The parent acts as Exam Designer, orchestrating the workflow through native Subagents according to the `using-reading-superpowers` skill.

## Automatic Reading Superpowers

The Reading profile configures skill discovery and instructs automatic, model-directed entry using native Subagents, without a custom coordinator or bespoke runtime. Offline scripted probes establish wiring, not autonomous skill compliance or IELTS quality. See [latest stabilization evidence](STABILIZATION.md).

- **Exam Designer (Parent Coordinator)**: Automatically activates `using-reading-superpowers` on any IELTS Reading generation request, orchestrating the lifecycle across specialized roles.
- **Specialized Native Agents**:
  - `passage-author`: Authors authentic academic passages grounded in topic and section requirements; saves initial structure in `exam.json`.
  - `question-author`: Derives canonical questions from the established passage using native builders (`create_*`), validates exam structure.
  - `semantic-checker`: Fresh-context independent reviewer verifying factual entailment, UTF-16 evidence spans, and answerability.
  - `ielts-examiner`: Fresh-context independent examiner evaluating authentic task design, difficulty progression, distractors, and scoring parity.
- **Four Minimal Skills**:
  - `using-reading-superpowers`: Automatic entry, workflow activation, role handoffs, and completion gates.
  - `reading-authoring`: Passage guidelines, canonical question builder standards, student-content vs. answer key separation.
  - `reading-quality-review`: Semantic review and IELTS examination protocols.
  - `reading-verification`: 6 completion gates checklist, targeted repair routing without restarting successful stages, and fail-closed stop rule.

## Tools

```js
get_question_spec({type: 'SENTENCE_COMPLETION'})
validate_question({question})
validate_group({group})
validate_exam({exam})
validate_exam({exam: {file: 'exam.json'}, pilot: true}) // explicit 13-mark pilot gate
verify_evidence({question, passage: {id: 'p1', text: 'A river flows.'},
  evidence: {sourceId: 'p1', start: 2, end: 7, quote: 'river'}})
check_grading_parity({question, submission})
inspect_delivery_projection({question})
```

### Reusing saved artifacts

```js
validate_exam({exam: {file: 'exam.json'}})
validate_group({group: {file: 'exam.json', pointer: '/sections/0/questionGroups/0'}})
inspect_delivery_projection({question: {file: 'exam.json', pointer: '/sections/0/questionGroups/0/questions/0'}})
```

For a 13-mark pilot, `pilot:true` on the existing validate_exam tool requires complete=true, embedded nonblank passages, exactly 13 Questions/answer slots/scoring units, and one independently scored slot per Question. Unsupported multi-target matching, multiple selection, multi-blank and process-ordering structures fail the pilot gate without removing their canonical practice support. `data.pilot.status=PASS` is mechanical only; independent, revision-bound, transcript-verifiable Semantic Checker and IELTS Examiner reports are still required for quality PASS. The qualifier is a tool input, not an Exam contract field.

Every artifact check argument (not `type` or the boolean `pilot` qualifier) also accepts `{file, pointer?}`. RFC 6901 pointers select exact JSON values; a passage reference without a pointer reads exact UTF-8 text. Paths are relative to native tool cwd. Reads are bounded to 2 MB, performed anew, and never repair types or `{item:...}` wrappers. Missing files/pointers, invalid JSON and oversized inputs return `ARTIFACT_INPUT_INVALID` ERROR, not a validation verdict. References are extension inputs, not canonical Question/Exam fields. Filesystem access is not sandboxed. Freeze the same artifact revision for both independent reviewers.

Builders validate their returned Questions; `validate_exam` validates all contained Questions/Groups. Avoid redundant unchanged structural calls, specification retrieval and artifact reconstruction. Compute exact UTF-16 evidence offsets locally with native bash; never guess/sweep offsets. Keep the full passage in `sections[].passageMd`, private keys in canonical Questions, and review history in separate reports, not `explanationMd`. The author still decides when/how to call tools and both specialists; no automatic orchestration or retries were added.

### Creation inputs

The six native builders cover all 19 canonical types. Input schemas are compact projections of the same canonical contract, not a second Question schema. Every builder requires `id`, `sectionId`, `idx`, `difficulty` and supplied `promptMd`; optional common fields are `groupId`, `explanationMd` and `imageUrl`. No difficulty, passage, answer, explanation, asset or evidence is invented.

| Tool | Types / additional inputs |
| --- | --- |
| `create_single_choice` | Four `single` types; explicit `type`, `options` with supplied `contentMd` and boolean `isCorrect` |
| `create_multiple_choice` | Fixed `MULTIPLE_CHOICE_MULTIPLE`; `options` with explicit correctness flags |
| `create_completion` | Seven `completion` types; explicit `type`, `blankAcceptTexts`, optional `blankAcceptRegex`; diagram/map media remains required |
| `create_matching` | Five `matching` types; explicit `type`, public `options`, canonical `matchPairs`; optional `wordList` only for matching information |
| `create_short_answer` | Fixed `SHORT_ANSWER`; `shortAnswerAcceptTexts`, optional `shortAnswerAcceptRegex` |
| `create_flow_chart` | Fixed `FLOW_CHART`; `orderCorrects` and supplied public `- key: label` prompt lines; process ordering, not blank completion |

Fixed-type builders omit the `type` input. Choice/matching options allow optional supplied `id`, `imageUrl` and `altText`. Builders assign option `idx` from display order and omitted option IDs as `<questionId>:option:<idx>`; these are local identities, not persisted UUIDs. Matching correctness defaults to false. `skill` is fixed to `READING`; non-bank families receive `options:[]`. All authored content and explicit private answers are preserved without renumbering blanks/targets or copying canonical examples.

Each builder invokes the existing canonical Question validator before returning `data.question` with `data.validation`. Any structural/semantic `FAIL` or `ERROR` withholds the Question. Invalid inputs receive bounded, value-free, field-level diagnostics and suggested corrections, including at native preparation time before coercion. Successful construction remains `UNVERIFIED` for passage truth, IELTS quality, media, regex parity, parent membership and consumers; it is not publication readiness. Evidence/reviews remain separate artifacts.

The tools themselves have no required order, retries or hidden prerequisites. The Reading author prompt requires specifications, canonical validation and specialist review before readiness. Exact canonical literals only; unsupported types return available literals. The seven existing checks retain direct-value inputs and canonical domain semantics, adding optional saved-artifact references: no coercion, normalization, artifact rewrites or silent repair. Typed wire-shape errors are rejected before native coercion, with sanitized native-preparation diagnostics. Builders add only the explicit mechanical defaults described above. Unknown fields fail explicitly. Reports include contract hash/version, checks and stable field-level diagnostics. `ERROR > FAIL > UNVERIFIED > PASS`; a successful structure check does not remove semantic/consumer uncertainty.

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

Submission accepts the canonical wire answer directly (lifecycle unspecified), or `{state:'autosave'|'final'|'restored', answer:wireAnswer}`. Only explicit `final` requests a complete answered response; this is not a claim that the backend rejects unanswered final Questions. Autosave/restored subsets preserve exact blank/statement/node identities. Canonical tool clearing is `selectedOptionIds:[]` plus `textAnswer:''`; omission/null is not a canonical clear. The backend REST lifecycle separately supports explicit `textAnswer:null` to clear text while omission preserves it; this wire-policy divergence is recorded in `sources.v1.json`, not silently normalized by the tool. Duplicate encoded JSON members, including escaped-equivalent names, are rejected. Wrong-but-valid answers are not rejected merely for earning zero.

One backend Question is one all-or-nothing scoring unit. Multi-blank/target Questions and multiple selections do not silently become separate IELTS marks. Multi-slot Questions emit `IELTS_SCORING_CONFLICT` (UNVERIFIED), so slots cannot silently be reported as separate IELTS marks. Actual .NET execution/regex/normalization, persisted identity mapping and frontend autosave/restore round trips remain UNVERIFIED. `sources.v1.json` pins inspected source fingerprints, not deployed or executed consumer evidence; flow legacy Steps/Labels divergence is recorded without changing canonical array answers.

### Public-only projection and blind solving

Projection builds fresh objects from canonical StudentQuestion/PublicOption allowlists. It preserves public media, membership, banks and input identities; private keys, correctness, explanations and reviews never become student fields. Known leakage/invalid content withholds the projection. Explicit answer-key/correct-answer/solution/teacher-note headers are screened at line and sentence boundaries, including composed/repeated blockquote, list, heading, indentation and emphasis wrappers. Only finite generic Answer(s) response-direction forms are treated as benign; stronger private headers are never exempted by direction-shaped values. Natural occurrence of an answer word is not automatically leakage; encoded/semantic hints remain unverified.

FLOW_CHART remains process ordering. Public labels must already exist in prompt lines `- key: label`; unsupported presentations remain unverified, not platform-invalid. Nodes display in deterministic key order independent of private solution order. Missing public labels never come from private keys or examples. Separately, backend public REST now exposes its legacy key-derived node bank sorted by key, not solution sequence; this does not establish canonical-label or frontend compatibility.

Only the returned `data.studentQuestion` is a candidate public input, not full reports/spec examples or authoring transcripts. Independent blind solving additionally needs a fresh native context, public-only inputs and verified OS-level denial of access to private files/tools/credentials/history, including symlink/absolute-path negative-access evidence. CWD/worktree separation is not filesystem isolation. This extension installs no solver, sandbox or delegation wrapper.

## Native error/result boundary

Normal execution and Reading outer-argument rejection return equal JSON text, `details` and `structuredContent` in the native execution event. P1-06 adds the public optional `formatPreparationError(error,args)` callback: Reading returns its sanitized argument report without parsing exception messages. Calls remain rejected with `isError:true`; execute and after-tool hooks are not entered. Typed wire-schema rejection returns `NATIVE_ARGUMENT_INVALID` with `contractHash:null` and explicitly states that domain validation was not invoked. In contrast, domain FAIL has canonical diagnostics/hash; infrastructure ERROR is no validation verdict, and UNVERIFIED is not readiness. Other native failures (e.g. unknown tools or malformed provider JSON) retain native errors, not invented domain reports. Tools without the callback retain their original errors, as do callbacks returning undefined or throwing. Provider/RPC JSON parsing, unknown-tool handling and cancellation before preparation retain native behavior.

The existing native tool-result **transcript** still drops `structuredContent` while retaining text/details; transcript schema changes are outside this patch. Cancellation is checked again after lazy domain initialization, before domain execution; rejected lazy imports are cleared for a later explicit call, without automatic retry loops, while concurrent initialization remains shared.

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
GENERATION_HARNESS_OFFLINE=1 npm test -w generation-agent-core
GENERATION_HARNESS_OFFLINE=1 npm run smoke
GENERATION_HARNESS_OFFLINE=1 node .generation/reading/bench/overhead.mjs
```

Legacy heading headers accept `List of Headings` with or without a colon; full bank equality still applies. Multiple-choice counts recognize `Which TWO/THREE…` alongside Choose/Select/Pick forms; conflicting counts remain unverified.

Every executable test/benchmark imports the existing network/credential guard. Native fixtures use disposable directories and in-memory credentials/faux provider. Root `npm test` runs the Reading domain suite after the existing harness tests and before the Subagents workspace suite. No live inference, production data, publishing, commits or pushes are authorized.

See [PERFORMANCE.md](PERFORMANCE.md) for the native 13Q trace analysis, reproducible offline replays, measured costs and limitations. `bench/native-trace.mjs <parent.jsonl>` reads native sessions and their matching child sessions without duplicating transcript mirrors; `bench/artifact-replay.mjs <child-session.jsonl> <exam.json>` replays recorded failures through the native faux-provider tool path.

The finite benchmark measures declaration bytes (total, existing seven, creation six and per tool), canonical JSON module loads/read/parse/compile counts in a fresh instrumented subprocess, registration deltas and warm calls (five warmups, twenty samples). Schema-only JSON import at registration derives the builder declarations; it reads the contract once but compiles no validators and loads no examples or source snapshots. Canonical validation still uses the pinned loader on first execution. An offline Node v24.21.0 measurement records **6,921 bytes before / 18,506 bytes after**, a **+11,585-byte** declaration increment for the six builders. These are serialized declaration bytes, not provider-token counts. Instrumentation is test-only, not a runtime telemetry framework. Mock first-attempt tool-call acceptance is not live-model reliability or IELTS output quality. See `PROGRESS.md` for executed evidence and rulings.
