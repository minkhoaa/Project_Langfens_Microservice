# RQ2 experiment protocol — target scientific design

## Hypothesis and contrasts

RQ2: effectiveness of specialized agent collaboration for creating English practice exercises, relative to single-step direct generation and same-model sequential self-review, and the trade-off in latency/tokens/cost. No result is presupposed. Primary pairwise comparisons: C−A and C−B on **end-to-end independently valid completion**. Secondary: B−A, conditional quality differences and resource efficiency. Claims must be limited by sample size and observed validity.

## Units and arms

- 25–40 frozen **Reading tasks**, each a single passage plus 1–2 question groups, and 25–40 frozen **Grammar exercise tasks** each with an eligible verified rule family and contextual specification. Same task item appears in all arms.
- A: direct generation with a declared single generation step; no hidden self-review/repair in generation. B: single foundation model sequential critique/revision (bounded and fully metered). C: full research multi-agent coordination/review/validator/repair under its declared policy.
- Base model/provider pinned identically where technically viable; provider/model revisions, sampling, seed support, prompt versions (arm-specific), tool allowances, retry and timeout policies documented. A, B and C should not be forced to use the exact same prompt text because their methods differ.
- Order/concurrency randomized or counterbalanced where possible to avoid time-of-day/provider drift; operational variations logged. Separate a natural-resource comparison from optional budget-matched sensitivity study.

## Dataset split and gold privacy

DEV for prompt/tool iteration, CALIBRATION for judge thresholds, JUDGE_HOLDOUT for post-freeze judge reliability and FINAL_EVAL for final paired campaign. Families of sources, near-duplicates and overlapping original exercise solutions must be segregated. Gold material is expert-verified, versioned and unavailable to the generation agents and blind solver. Reading newly generated question gold may require independent blind solution/adjudication; do not treat generator answer as independent truth. Grammar rule provenance is not item-level gold.

## Outcome definitions

- **Assigned N:** all frozen `(dataset_item_id × arm)` slots, not only those that returned JSON.
- **Completion rate:** number with declared executable completed/normalized output divided by assigned N (formal structural completeness criteria frozen ahead of FINAL).
- **Primary E2E valid pass rate:** number with independent PASS under frozen rubric and completed eligible output divided by assigned N. `UNCERTAIN`, timed out, failed, no output and missing evaluator result are not PASS; missing-score sensitivity also reported.
- **Conditional evaluable-output quality:** semantic scale means/medians among outputs actually evaluable, with the evaluable denominator shown; partial output may be scored with a transparent evaluability flag but does not become primary end-to-end PASS.
- **Item-level quality:** number of semantically correct evaluated questions divided by total evaluated questions, with type counts and per-request clustering; NOT an independent sample size for inference.
- **Latency:** elapsed from accepted request until terminal status (including failures), with P50/P95 plus timeout censoring disclosure. Usage includes retries/failures, prompt and completion tokens, call count, repair cycles and priced cost with provenance; report EXACT/ESTIMATED/UNKNOWN distributions.
- **Cost per independent valid output:** total attributable cost including failed attempts divided by number of primary passing assigned requests, undefined/N/A if zero.

## Judge calibration

A curated labeled set includes correct, ungrounded, ambiguous, wrong-answer, weak distractor, TFNG/YNNG NOT GIVEN, word-limit and grammar-rule errors. Calibration thresholds/prompt only tuned on allowed split. On sealed JUDGE_HOLDOUT, report confusion counts, `FAR_decided = invalid accepted / invalid decided`, `FRR_decided = valid rejected / valid decided`, abstention by label/type, decided coverage and uncertainty. If no decided cases for a denominator, report N/A rather than 0. Human agreement requires predeclared measure and adjudication of disagreements. Judge cannot use internal C PASS or arm identity as an input.

## Final freeze and statistical honesty

Before FINAL, seal dataset/source family, arm assignment roster, prompts, model, rubric and judge, primary endpoint, handling of missing/partial/uncertain, allowed reruns, resource policy, planned paired contrasts, 95% confidence interval method and secondary metrics. Use paired contrasts and request/source-family clustered uncertainty where feasible; disclose multiple comparisons and analysis deviations. Do not compute intervals pretending every question within the same passage is independent.

Frozen runs must be resumable via small batches with exact assignment/retry IDs; a failed row cannot be secretly replaced by a new sample. Human reviewers receive anonymous randomized items without arm, costs, trace or hidden source of generation, with a separately access-controlled mapping and adjudication history.

## Acceptance of RQ2 report

Reproducible outcome ledger for 150–240 expected arm assignments (depending on frozen 25–40 per domain); independently hashed evaluator outputs and blinded human subset; code and dataset revisions; statistical comparisons and raw counts; cost/latency/quality tradeoffs; failures, biases, missing data, source and provider limitations. Honest null/negative results are valid results, not project failure.
