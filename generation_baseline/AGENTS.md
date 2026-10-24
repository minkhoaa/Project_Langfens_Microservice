# Research tooling
RQ2 Reading/Grammar experiments and JSON contracts, not proof of RQ1 pronunciation/pedagogical efficacy.

- Implementation lives in `services/generation-service/app/{contracts,evaluators,experiment}/`; also read that service's guide.
- `contracts/JSON_SCHEMAS.json` and examples are target interfaces; verify concrete DTO mappings/tests before changing wire contracts.
- Keep DEV, CALIBRATION, JUDGE_HOLDOUT and FINAL_EVAL source-family/near-duplicate disjointness; no holdout tuning or silent frozen-data/label edits (new version + audit required).
- Gold and arm mappings stay restricted; blind reviewers receive neutral outputs without internal scores. Learner data needs consent/de-identification; never synthesize human review.
- A/B/C use paired inputs and the same independent rubric; C's internal PASS is not independent PASS. Task invalidity overrides fluency; UNKNOWN/NOT_RUN never become PASS.
- Freeze dataset/assignments/prompts/model/evaluator/rubric/analysis/budgets before final execution; no cherry-picking, replacement items or untracked fallback.
- Final design: 25–40 items/domain, ≤5 items/batch across A/B/C; the 30-item judge holdout is separate. Retain one outcome per assignment and bounded retry lineage.
- Primary endpoint: `independent_final_PASS / all_assigned`; failed/partial/missing/UNCERTAIN outcomes remain denominators. Pair by `dataset_item_id`, not individual questions; C−A/C−B with 95% CIs.
- Preserve real failed-attempt costs, usage confidence and latency; report domains separately, uncertainty and missing external evaluation. Never force C to win.
- Local/offline schema check from root: `services/generation-service/.venv/bin/python generation_baseline/tools/verify_baseline.py`; it does not certify a campaign.
- Legacy document-backed approval is retired: readiness must remain HOLD until approved analysis/human-panel evidence is supplied; no automatic approval from instruction files.
- Preserved README/JSON manifests contain historical references/hashes, not current instructions. Recover archived paths via `git show 3ecaf5e4ed1a31f2e7762926042e7130973b3385:<path>`; run historical immutability checks against their original snapshot.
