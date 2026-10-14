# Statistical and reporting obligations

## Predeclared sample and primary endpoint

The unit of assignment/inference is the benchmark request, paired across A/B/C. Primary outcome is `independent_final_PASS / all_assigned`, with UNCERTAIN, no-output, timeout and failed validation as non-PASS; count missing external evaluation separately and add sensitivity analysis. The same classification policy must apply to all three arms. Report domains Reading and Grammar separately and pooled only with an explicitly defined weighting and rationale.

## Paired contrasts

C−A and C−B differences in pass proportions estimated within paired dataset_item_id, with 95% confidence intervals (paired bootstrap or appropriate matched binary method) and a suitable source-family cluster sensitivity where overlap exists. Confidence intervals must reflect limited 25–40 tasks per domain; do not treat 40 questions within one Reading paper as 40 independent assignments. Secondary metrics and exploratory ablations clearly labeled. Avoid equivalence claims from merely non-significant p-values.

## Efficiency and transparency

Report P50/P95 end-to-end latency with timeout-handling disclosure; call count, repairs, retries, prompt/completion tokens, provider-reported vs estimated, dollar cost with dated price assumptions and proportion UNKNOWN. Include costs of failed attempts in resource means and cost per valid output. Plot quality-versus-cost/latency, showing uncertainty and which results are conditional on being evaluable. Report judge-human discrepancies, groupwise bias, abstention and failure taxonomy.

## Reproduction bundle

Freeze human-readable method, machine-readable assignment ledger, manifest hashes, evaluator/rubric model configuration, raw safe artifact references, anonymized human labels, exact analysis script/version and report table IDs. A separate recomputation must match aggregate counts within declared numeric tolerance.
