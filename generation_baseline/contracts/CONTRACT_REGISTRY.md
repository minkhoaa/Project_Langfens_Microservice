# Canonical contracts C1–C5 — normative semantic requirements

These contracts define the observable semantics across the research scope; `JSON_SCHEMAS.json` is a **versioned target shape**, not evidence that historical DTO names or persistence columns already match. Source-to-contract mapping must preserve legacy clients, NDJSON/gateway/API conventions and all existing V2 invariants.

## C1 GenerationContract

`GenerationRequest` has stable request/dataset identity, `task_type` discriminator, neutral task spec, provenance/versioned source or grammar-rule pack, model/prompt/sampling/runtime policy pins, actor authorization and requested unit size. Experimental A/B/C receive a **semantically identical** neutral task/source specification; gold answers cannot be embedded in the request.

`GenerationResult` separates execution_status, output_availability, canonical typed content and *private* proposed answer reference, usage reference and structured failure. The student-safe/solver-safe view is not the same as a complete result. Partial results are retained without treating them as completed. Do not make output success equivalent to parseable JSON.

`SourcePack` includes source identity, family, license, canonical evidence claims, hash and selection eligibility. `GrammarRulePack` includes rule/exception/example applicability, context and provenance. `ReferenceAnswerEvidence` is a candidate-produced proposed answer with variants/context/rule ID and must **not** be called gold.

## C2 ExecutionContract

Each logical operation records run/operation/trace ID, role ∈ `{COORDINATOR, GENERATOR, REVIEWER, VALIDATOR}`, capability name, status, timestamps, input/output hashes, dependency heads, policy, issue ID and observed usage. Cumulative application budgets may be uncapped only in explicitly approved profile; bounded retries/repairs, per-call timeouts, cancellation and real accounting remain mandatory.

Usage confidence is EXACT/ESTIMATED/UNKNOWN per metric/provider claim; UNKNOWN is nullable/missing with reason, not 0. Cost is provider-price-version-dependent, with assumptions recorded. Retries/replay are linked and do not duplicate accepted state or billing aggregation.

Only authoritative exam-service can accept a content head after lease/epoch, dependency hash/closure, source/policy/required evaluation checks. Reviewer finding BLOCKING prevents accept until resolved or adjudicated under declared rules. No research policy may weaken durability or permissions.

## C3 EvaluationContract

Frozen external rubric and post-generation evaluator score **the same neutral output** from all A/B/C. `SolverView`: question/source/options/instructions only, excludes proposed answers/gold, private rationale, internal verdict and configuration ID. `AnswerVerificationView`: recorded blind answer + generated proposed answer + evidence; created *after* solve. `GoldReferenceView`: independently verified labels, separate scorer ACL only. Schema and nested-metadata allowlist must prevent indirect leaks.

Hard validators cover structure, instructions, type-specific word limits/verbatim; semantic rubric covers clarity, fluency, relevance/pedagogical fit, grounding, answerability; task-specific checks cover unique answers, TFNG/YNNG NOT GIVEN, MCQ distractors, Grammar rules/variants. Hard invalidity trumps high prose score. Judge returns PASS/FAIL/UNCERTAIN with detailed evidence and rubric/source/output hashes; no output means explicit non-evaluability, never fake PASS. `FAILED_VALIDATION` with PARSEABLE output can be assessed conditionally but does not become end-to-end pass.

Evaluator calibration and holdout are separated; judge freeze controls score thresholds. `UNCERTAIN` is non-pass for the preregistered primary end-to-end outcome and is always reported with abstention/coverage. FAR_decided/FRR_decided denominators include only labeled invalid/valid items for which judge made a PASS/FAIL decision; report groupwise abstention.

## C4 ExperimentContract

Every assigned `(dataset_item_id, configuration A/B/C)` has a stable attempt/lineage and final outcome, including failures and retry link. `DEV`, `CALIBRATION`, `JUDGE_HOLDOUT`, `FINAL_EVAL` are split by family/provenance, with no final gold tuning. A/B/C share same task/spec, foundation model (as feasible), input eligibility and independent rubric; method-specific prompts are versioned and not expected to be text-identical. Document resources, timeout and allowed iteration policies.

Pre-register primary endpoint = independent PASS among **all frozen arm assignments**. Secondary results: completion, conditional quality on evaluable outputs, hard/semantic errors by type, latency P50/P95, calls, repairs, tokens, cost, cost per valid item and confidence. No-output and UNKNOWN accounting remain explicit. Infer with paired input IDs (cluster by passage/source family where applicable), not treating each question as an independent user request. Honest missing rows and blinded human subset are mandatory.

## C5 ProductIntegrationContract

Only explicit authorized manual Admin publish of a strictly eligible production Draft creates immutable PublishedSnapshot. Research/ablation candidates remain unpublishable even if a UI flag is changed. Student output allowlist excludes answers, source private evidence, hidden rationale and internal metadata. Attempt pins snapshot version; private grader uses that version; released feedback follows policy, history and progress require learner/tenant ACL.

## Policy matrix

| Invariant | STRICT_PRODUCTION_V2 | RESEARCH_STANDARD | RESEARCH_ABLATION |
|---|---|---|---|
| Auth, source/license, tenant boundary | required | required | required |
| Artifact hash, dependency closure, lease fencing, transactions | required | required | required |
| Genuine required evaluation evidence | declared strict policy | declared research policy | explicit NOT_RUN for disabled check |
| Blind/adversarial checks | required if configured | per research policy | configurable only in research |
| Publish allowed | authorized admin after strict accept | NEVER | NEVER |
| External independent judge | not required for product acceptance | required for analysis | required for analyzed ablation |

## Compatibility and errors

- Proven legacy REST/gateway/NDJSON format, enum casing, Unicode/content hashing, operation IDs and transactional behavior must be preserved unless an explicit versioned migration is accepted.
- Error semantic families include `AUTH_DENIED`, `SOURCE_INELIGIBLE`, `SCHEMA_INVALID`, `POLICY_MISMATCH`, `STALE_DEPENDENCY`, `EVIDENCE_MISSING`, `TIMEOUT`, `PROVIDER_ERROR`, `USAGE_UNKNOWN`, `CANCELLED`, `RESEARCH_PUBLICATION_FORBIDDEN`. Actual persisted names are resolved from source audit.
- No source/path/route introduced by this document is claimed to be currently implemented.
