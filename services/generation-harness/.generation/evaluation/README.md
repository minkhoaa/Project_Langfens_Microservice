# VS4 offline semantic-evaluation package — research rubric vs4.1

**Provisional research thresholds, not official IELTS standards or previously approved Langfens policy.** This package is an offline evaluation instrument, not a generator, coordinator, runtime, publication tool or production-quality certificate. A readiness GO never authorizes running a live pilot. No inference is performed by these scripts.

## Canonical v1 hardening follow-up

See [CONTRACT-HARDENING-AUDIT.md](CONTRACT-HARDENING-AUDIT.md) and [the v1 implementation](../contracts/IMPLEMENTATION-v1.md). The historical VS4 protocol below retains its legacy schema; it is not canonical-v1 compatibility evidence. The first strict canonical pilot is TFNG/single-MCQ/one-slot-summary only. V1 MATCHING_* multi-target exercises cannot satisfy one-slot/one-mark generation without a deliberate versioned representation change. `run-offline.mjs` now also executes the related canonical/native-replay/actual-.NET tests using cached packages and records failures by scoped command dependency; a frozen-backend failure is not relabeled as a schema/test failure. The launcher remains fail-fast and refuses an existing receipt directory.

## Scope and artifacts

- `rubric.json`: versioned, machine-readable provisional cutoffs.
- `schemas.mjs`: executable, noncoercing TypeBox/JSON schemas for records, generator, solver, reviewer and human adjudication outputs. Generator groups reuse the existing native canonical schema, not a second backend contract.
- `report.mjs`: validates supplied records, checks coverage/independence/spans, resolves human adjudications, reports question/group/section/paper summaries and three-way pilot decisions.
- `evidence.mjs`: manifest binding and SHA-256 verification within an explicitly supplied run root; traversal and escaping symlinks fail closed.
- `statistics.mjs`: exact two-sided 95% Clopper–Pearson bounds under an explicitly disclosed independence working model; section-level bounds separately reported.
- `readiness.mjs`, `run-offline.mjs`: readiness evaluator and sequential **test-only** verification launcher. Neither launches agents or models. The launcher refuses an existing output directory and retains command logs, hashes, source hashes, a receipt and readiness report.
- `fixtures/records.mjs`: incomplete three-item synthetic record with UNCERTAIN. `fixtures/pilot.mjs`: complete synthetic 13-item branch fixture with deliberately fake receipts/human attestations. Neither is semantic evidence.
- `fixtures/held-out-section.json`: separately versioned fictional pilot stimulus, with no approved answer key, examples or model outputs. It is short and not representative of IELTS passage length/authenticity. An independent human must assess/replace and version it **before freezing any separately authorized live assignment**. It has not been certified suitable.

VS3's predetermined 40/40 faux-model answers demonstrate plumbing, not IELTS semantic quality. Native `verify_evidence` validates quotation location and supplied coverage/identities, not entailment; its existing PASS/FAIL schema is untouched. VS4 UNCERTAIN lives only in the evaluation record and is never converted to native approval. The semantic-reviewer specialist accepts the explicit VS4 output schema when supplied, retaining its legacy default otherwise.

## Rubric vs4.1

Two independent judgments **per criterion per question**. Review passage/group/section context, not an isolated sentence. For genuinely inapplicable criteria, record PASS with a substantive not-applicable reason. Never invent certainty to complete a record.

| Criterion | PASS requires | FAIL / UNCERTAIN examples |
| --- | --- | --- |
| `answerability` | Defensible correct intended key, exactly one valid answer/set using passage and instructions only | no answer, two defensible answers, answer hint; unresolved interpretation is UNCERTAIN |
| `evidence` | Exact section-local UTF-16 quotations support all propositions and the key, not just lexical overlap | unsupported inference or contradicted key; uncertain scope/support or incomplete absence search |
| `truth_status` | TRUE/YES supported, FALSE/NO contradicted, NOT GIVEN neither; YES/NO concerns writer views | absence confused with falsity, misattributed opinion; unresolved negation/scope |
| `distractors` | Incorrect choices plausible but excluded, no unintended clue or second valid answer | giveaway/implausible distractor; disputed plausibility is UNCERTAIN; second valid answer is critical |
| `matching_completion` | Correct mapping/reuse, accepted variants, passage wording, grammar and explicit word/number limits; scoring agrees | wrong key, excluded valid variant, word-limit/scoring conflict; uncertain normalization |
| `style` | Coherent academic passage, clear natural questions, no contradictions or external assumptions | register/coherence/clarity defect; insufficient subject expertise |
| `difficulty` | Defensible qualitative prediction of appropriate demand/variation for the intended section, with rationale | trivial/repetitive or inaccessible items; no defensible prediction without learner data is UNCERTAIN |
| `format` | Faithful Academic Reading instructions, diversity and section suitability, one independent mark per question | misleading task instructions, unsupported format, backend imitation; unresolved compatibility |

Severity: `critical` invalidates safety/correctness (unsupported keys, unanswerable items, multiple defensible answers, wrong truth status, leakage, scoring incompatibility). `major` is a significant noncritical quality defect; `minor` is a localized noncritical imperfection; `none` is required for PASS. FAIL requires severity. The evaluator conservatively treats any FAIL in answerability/evidence/truth_status/matching_completion as critical, and disallows noncritical severity for critical categories even under another criterion. UNCERTAIN may have provisional severity but is never PASS.

Use categories such as `unsupported_key`, `unanswerable`, `multiple_answers`, `wrong_truth_status`, `unsupported_entailment`, `leakage`, `scoring`, `word_limit`, `span`, `distractor`, `clarity`, `register`, `difficulty`, `format`; use `none` on PASS. Reviewers explain why alternatives fail. For NOT GIVEN, search the whole passage and document scope: a quotation alone cannot establish absence. For matching, enumerate mappings/reuse; for completion, enumerate accepted variants and count words/numbers. Do not assign empirical IELTS bands without calibration.

## Independent review and human adjudication procedure

1. Before a separately authorized pilot, freeze/version/hash the assignment, passage, rubric, prompt, provider/model/version, parameters, budget/currency, run ID and code revision. Select once, with no retries/cherry-picking. Do not use held-out answers or examples in prompts/training/tuning. A repaired item is a new artifact/version, not an overwritten success.
2. Use only the existing native generator and extension tools. Preserve the exact canonical artifact and raw response. Validate every question/group, 13 independent one-mark questions in one Section, native scoring parity on intended answers and plausible alternatives, exact student projection and known leakage attacks. Require **100% PASS**, no ungradable keys or ignored errors. Restrict pilot types to TRUE_FALSE_NOT_GIVEN, MATCHING_INFORMATION, SUMMARY_COMPLETION and MULTIPLE_CHOICE_SINGLE. Exclude FLOW_CHART (backend ordering, not IELTS blank completion), regex-bearing keys (JS does not prove .NET regex parity), multi-slot/all-or-nothing imitations and other unsupported cases.
3. Pass only the exact inspected PASS student projection to a fresh blind-solver child. No private key, annotations, review text, raw generator response, parent history, shell/file/network tools or corrective feedback. Its sole tool remains `get_question_spec`. Retain native lifecycle/transcripts and exact input/output hashes. Validate one answer per ID, no duplicates/missing/foreign IDs. Solve before revealing any key/review. Red-team unmarked answer hints and manually inspect content as well as private fields/encodings.
4. Two fresh independent semantic-reviewer sessions receive passage/questions/keys/evidence and this rubric/schema, but neither solver output, other reviews nor parent history. Freeze both full responses before comparison. Each records all eight judgments, rationale and spans for each question. Bind reviewer identities to actual native lifecycle session IDs, never self-asserted labels. Prefer separately selected model families; shared weights/provider and residual correlated errors must be disclosed. Session isolation is not statistical independence.
5. A qualified independent human, distinct from generator/solver/both reviewers, adjudicates **every** verdict/severity/category disagreement, UNCERTAIN and critical defect (even agreed critical failures). Cite exact evidence and explain alternatives/whole-passage searches. Preserve original reviews unchanged. If still uncertain, record UNCERTAIN; never forward it as PASS to `verify_evidence`.
6. Compare the blind answer to the declared accepted-answer representations. A literal mismatch is a trigger, not semantic proof of a bad key; use native grading receipts and human reasoning to resolve synonyms/normalization. `solverAdjudications[].verdict=PASS` means the human established key defensibility despite solver mismatch; FAIL means a confirmed critical key/answerability defect; UNCERTAIN remains unresolved. Human resolutions must include evidence spans. No solver agreement proves correctness.
7. An independent accountable human audits manifest completeness, raw-response-to-record correspondence, canonical/key/projection correspondence, native receipts, actual fresh-context/tool isolation, known and unmarked leakage, compatibility, pre-generation freezing and held-out suitability. Record each protocol check as PASS/FAIL/UNCERTAIN and bind the audit to the manifest digest. A failed security/isolation check is NO-GO. Keep these private artifacts away from the solver. Human identity/authenticity must be established organizationally; this offline package cannot authenticate a person or their expertise.

## Record and evidence contract

`schemas.mjs` is executable documentation; additional fields and malformed wire types are rejected, not coerced. Full records require:

- `version: "vs4.1"`, `evidenceClass: "SYNTHETIC" | "REAL_MODEL"` (a label, not proof).
- `artifact`: ID, sections with exact passages/groups, questions with IDs, section/group membership, prompt, declared `acceptedAnswers` and key-supporting `evidence` spans. Answer strings use one frozen canonical representation, consistent with native grading receipts; the reporter does not reimplement the backend grader. Include relevant evidence and full-passage search reasoning for absence claims.
- `generator`, `solverAnswers`, `reviews`: raw responses and actual lifecycle session IDs. Each model call's `metadata` includes provider, model, version, exact prompt, temperature, input/output token usage, latencyMs, cost, currency and costBasis/price schedule. Unknown usage/latency/cost is explicit `null`, never invented zero; this blocks pilot GO. Record failure/timeout calls too in the manifest; do not silently replace them. Questions may reference the same complete raw response/metadata for a section-level call; retain unique call accounting externally to avoid double counting costs.
- Two `reviews` per question, each exactly eight unique criteria; reviewer `source` is model/human/synthetic. Model source requires call metadata; human source still requires raw review. `adjudications` and `solverAdjudications` hold independent human decisions/reasoning/spans. Original reviews remain in the report.
- `deterministic`: structure/scoring/delivery/isolation/compatibility, each PASS/FAIL/UNCERTAIN. Raw receipts must support these claims.
- `manifest`: restricted relative paths, SHA-256 and session IDs for raw model files. Roles: assignment, prompt, rubric, canonical, projection, native_results, lifecycle, generator_raw, solver_raw, reviewer_raw (both sessions), human_review. Cover every call/failure and exact inputs/outputs, tool receipts, transcripts, adjudications, cost records and revisions. Raw file hashes are bound to recorded raw strings. Native/canonical/transcript content is human-audited, not semantically parsed by this script.
- `protocolAudit`: independent human identity, verdict/reasoning, `manifestDigest` calculated by `manifestDigest(entries)`, and every named protocol check. Hashes establish byte integrity, not factual truth or authorization. The audit is not a cryptographic signature.

Spans are `{sectionId,start,end,quote}` with **UTF-16 code-unit offsets**, end exclusive, into the exact stored section passage. Supplied spans are checked, including reviewer/adjudicator spans. Key/evidence coverage is mandatory for GO. A literal span match is not entailment. Missing external evidence is INSUFFICIENT_EVIDENCE; corrupted bytes, invalid spans or escaping paths are NO-GO.

## Execute strictly offline

From `services/generation-harness`, with existing local dependencies (no installation needed):

```sh
# Comprehensive sequential verification; output directory must not already exist.
node .generation/evaluation/run-offline.mjs /tmp/langfens-vs4-UNIQUE
# Emits readiness.json, receipt.json, private logs and source hashes.
node .generation/evaluation/readiness.mjs /tmp/langfens-vs4-UNIQUE/receipt.json

export GENERATION_HARNESS_OFFLINE=1
export NODE_OPTIONS="--import=$PWD/test/offline.mjs"
node --test test/reading-vs4*.test.mjs
# Export model/record schemas as ordinary JSON Schema:
node --input-type=module -e 'import {record,modelOutputSchemas} from "./.generation/evaluation/schemas.mjs"; console.log(JSON.stringify({record,...modelOutputSchemas},null,2))'
# Incomplete synthetic sample: expected reporter exit 3, never approval.
node --input-type=module -e 'import f from "./.generation/evaluation/fixtures/records.mjs"; console.log(JSON.stringify(f))' > /tmp/vs4-record.json
node .generation/evaluation/report.mjs /tmp/vs4-record.json
# Optional future *offline* analysis of already-collected, authorized evidence:
node .generation/evaluation/report.mjs RECORD.json --evidence-root RESTRICTED_RUN_DIRECTORY
```

Reporter exit codes: **0** GO, **1** malformed input/usage, **2** NO-GO, **3** INSUFFICIENT_EVIDENCE. An absent evidence-root always prevents pilot GO. The readiness evaluator consumes supplied test claims; the launcher is the reproducible means of collecting actual command exits/log hashes. Retain its receipt and logs together. Tests bootstrap the existing credential sanitizer and external-network guard; no credentials are discovered, providers called, DBs touched, dependencies installed or approval tools invoked by the evaluator. Build precedes tests sequentially because dist replacement must not race native-child tests. Skipped unrelated provider/platform suites are not claimed as covered.

## Explicit gates and rationale

### Offline readiness

**GO** only when all applicable deterministic structure/scoring/delivery fixtures pass (100%), known leakage and unauthorized tool/context attacks are rejected, no unresolved critical compatibility defects remain in the *restricted pilot scope*, schemas/fixtures/evidence/reporting reproduce, three-way judgments remain intact, and independent review/human-adjudication procedures are implemented. Frozen/backend sources must be unchanged. Test receipts identify actual scope; mocked semantic judgments prove no real semantic quality.

**NO-GO** on an observed deterministic/security/critical compatibility failure. **INSUFFICIENT_EVIDENCE** for absent/unexecuted checks, unknown results or missing required receipts. No ignored failures or UNCERTAIN-to-PASS coercion. Static tests cannot prove absence of arbitrary natural-language hints in future content; future pilot-specific audit is mandatory. The short held-out stimulus's future human suitability review is not claimed complete.

### Proposed real-model pilot evaluation — NOT execution authorization

Limit to **one Section, exactly 13 questions**, no publication or real student delivery.

**GO** requires 13/13 independently supported or human-adjudicated defensible unique correct keys with passage evidence, zero critical defects/leakage/scoring incompatibility, every deterministic check PASS, at least **12/13 noncritical-rubric passes**, two independent judgments per criterion/item, every disagreement/UNCERTAIN/critical concern/solver mismatch human-resolved, complete known per-call metadata, byte-verified evidence and a PASS human protocol audit. A GO is only an evaluation result, not permission to expand or publish.

**NO-GO** for a confirmed critical defect, failed deterministic/isolation/leakage check, corrupted evidence, or a complete evaluation with fewer than 12/13 quality passes. **INSUFFICIENT_EVIDENCE** for synthetic/incomplete records, missing provenance/usage, unresolved judgments or any UNCERTAIN, unavailable evidence, unverified protocol, or wrong sample size. Known critical failures remain NO-GO even if other evidence is missing; they must still be adjudicated. A human may correct an erroneous model critical judgment with explicit evidence, without erasing the original.

Rationale: 13/13 answerability is intentionally strict; 12/13 permits one noncritical quality imperfection, never one invalid key. This is a small research screening target, not a population-quality estimate. Neither model agreement nor a human attestation alone proves semantic truth. Label spoofing in tests intentionally demonstrates the remaining trust boundary; counterfeit but hash-consistent records require external human accountability to detect.

### Advancement proposal — never approve from this pilot

`advancementDecision` remains INSUFFICIENT_EVIDENCE for every pilot report. Before recommending expansion, preregister **at least 40 independently generated held-out sections / 520 questions**, diverse topics, passage complexity, task types and independent runs; define strata/coverage and section selection before observing outputs, retain failed runs, use two independent reviews/item and human adjudication of every critical disagreement/UNCERTAIN. Include qualified independent human review, not just more calls to the generator's model.

Proposed research advancement conditions in `rubric.json`: zero confirmed critical defects, zero unresolved/missing judgments, >=95% noncritical pass rate, item-level two-sided exact 95% critical-rate upper bound <=1%, section-level upper bound <=10%, and noncritical-pass lower bound >=90%. Independently adjudicate and audit before any recommendation. Report original/adjudicated defect rates, disagreement and agreement denominators, solver/key disagreement, UNCERTAIN/missing rates, per-type/topic results, unique-call costs/usage/latency and failed-run counts. Require a preregistered **section-cluster bootstrap**/cluster-aware sensitivity analysis for quality rates; exact item-binomial intervals are only a working-independence sensitivity calculation, not the sole acceptance criterion. Section-level bounds assume independent representative sections too. These metrics are proposed, not an implemented auto-expansion approval.

Zero defects in 13 gives a one-sided 95% upper bound of about **20.6%**, or a two-sided exact 95% upper bound of about **24.7%**. Zero in 520 yields about **0.71%** two-sided under item independence; zero defective sections in 40 yields about **8.81%** under section independence. Even 30 clean sections miss the proposed 10% section upper bound (~11.6%). Confidence bounds do not fix selection bias or correlated reviewer errors. The reporter conservatively counts unresolved questions/sections as adverse events in critical-rate bounds, never as defect-free passes.

Full-paper generation needs a separate independently reviewed research protocol; publication/student delivery additionally need human governance, security, accessibility and empirically calibrated quality evidence. Sample size or an offline PASS is never authorization.
