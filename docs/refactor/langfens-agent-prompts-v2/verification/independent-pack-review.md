# Independent review — Agent Prompt Pack V2

## Scope and limits

This is document QA of instructions for a coding agent. The actual Langfens repository is not present in this workspace. No implementation tests, live semantic benchmarks or deployment observations were executed by this reviewer. This report does not assert that any actual G00–G15 gate is PASS.

Inputs inspected: the complete uploaded Phase 08 report; original master plan and Validation Matrix; all original phase specifications and the canonical planning test manifest; all 16 rewritten phase files; the five core files `00-START-HERE.md`, `01-ORCHESTRATOR-PROMPT.md`, `02-G07-G08-RECOVERY-PROMPT.md`, `03-OUTPUT-AND-GATE-CONTRACT.md` and `04-FINAL-VERIFICATION-PROMPT.md`.

The contract correctly distinguishes real errors from external prerequisites; prevents fake PASS, stale SHA-only evidence and self-grounding; requires wired integration paths and actionable remedies; protects dirty worktrees; and separates document/process independence from model independence.

## Findings

| ID | Severity | Finding | Concrete remedy |
|---|---|---|---|
| PR-01 | Medium | The execution contract permits handoff for external blockers or platform termination, but does not explicitly permit an honest INTERNAL unresolved handoff after an evidence-based stagnation condition. A hard internal bug can cause indefinite repeated agent activity while technically avoiding the listed stop conditions. | Define bounded execution campaigns: stop repeating identical patches; after verified no-progress, inspect a new hypothesis/approach or cross-review; if no safe plausible fix remains in the active session, checkpoint INTERNAL BLOCKED with attempted approaches, repro, next diagnostic task and owner. Do not relabel it external or pretend success. Persistence means useful work, not infinite spend. |
| PR-02 | Low | Long-running sessions are required to poll/await, but benchmark resumption needs explicit operation IDs and terminal result reconciliation to avoid duplicate billable live work after session loss. | Require benchmark case/run IDs, persisted progress, status-first reconciliation, bounded provider campaign budget and resumable partial reports. Never restart a finished expensive batch only because the terminal tool output was lost. |
| PR-03 | High, phase-draft requirement | The uploaded report identifies unsupported PASSAGE in both GroundingFidelityEvaluator and PassageWordCountEvaluator. A remediation prompt focused only on Grounding can leave the production passage pipeline without required structural checks. | Phase 07/08 prompts must audit every required evaluator's applicability to PASSAGE; specifically WordCount and Grounding; verify actual required registry coverage and acceptance with unsupported-type/missing-result fail-closed cases. |
| PR-04 | High, phase-draft requirement | A canary passage can be rejected by a word-count/schema issue without proving the grounding defect is repaired. | Integration canaries must satisfy structural prerequisites. Assert specific fidelity/error codes and sentence/claim coverage, not just non-PASS. Place canaries at the first sentence, sentence 11, middle and final factual assertion; include valid controls. |
| PR-05 | High, phase-draft requirement | Softening “proves/causes” in the provided repair example leaves unsupported “immediate anxiety elimination”. | Require post-repair review of every remaining assertion against independently resolved evidence, with immutable version diffs and fresh whole-passage fidelity evaluation when context changes. UNMEASURED_OUTCOME may terminate/escalate safely; automatic repair is not mandatory if evidence cannot justify one. |
| PR-06 | Medium, phase-draft requirement | Required G07 semantic validation can accidentally be deferred to Phase 10, creating an acceptance circular dependency. | Keep G07 entailment/contradiction/neither validation and clean corpus as required G07 outputs. Phase 10 adds full blind solver/adversary workflow. Separate coding-only readiness with fakes from dependency acceptance. |
| PR-07 | Medium, phase-draft requirement | Source envelope delimiters are prompt formatting, not proof of injection resistance. | Require actual serialized context tests, forged delimiter/role/tool-policy canaries, trusted configuration immutability and post-output validation. Never claim a delimiter guarantees model compliance. |

Findings marked “phase-draft requirement” were raised as acceptance checks during drafting, rather than assertions that a finished draft already violated them.

## Closure review

| ID | Status | Verified correction or coverage |
|---|---|---|
| PR-01 | CLOSED | Shared contract and orchestrator require hypothesis changes after no progress and allow an honest INTERNAL blocker/checkpoint when no feasible path remains in actual tools/authority/budget. No infinite activity or forced external relabeling. |
| PR-02 | CLOSED | Shared contract and recovery require persisted campaign/case progress and reservation status, reconciliation before rerunning lost output, bounded spend and partial resumable results. |
| PR-03 | CLOSED | Phase 08 implementation and verification name both PassageWordCountEvaluator and GroundingFidelityEvaluator for PASSAGE support; recovery also audits applicability of the entire required registry. |
| PR-04 | CLOSED | Phase 07/08 and recovery require structurally valid integration canaries, exact fidelity/error codes, coverage records and valid controls. Specific first/11th/final-sentence cases are mandatory. |
| PR-05 | CLOSED | Phase 08/recovery explicitly require remaining outcome support after modal/causality edits; unsupported outcomes cannot become accepted, and safe bounded escalation is allowed when no evidence-backed repair exists. |
| PR-06 | CLOSED | G07 retains required NG semantic relation validation and clean held-out corpus; Phase 10 adds blind/adversarial workflow without accepting upstream debt. Coding-only readiness is distinct from artifact/gate acceptance. |
| PR-07 | CLOSED | Shared contract, ingestion, passage, recovery and release prompts require actual injection probes and trusted configuration invariants; delimiter presence is explicitly not proof of safety. |
| PR-08 | CLOSED | Both Phase 15 prompts now name the exact `03-OUTPUT-AND-GATE-CONTRACT.md` filename. Re-read confirmed consistent companion-file discovery and the required output standards. |
| PR-09 | CLOSED | Both Phase 00 prompts and the orchestrator now use canonical BLOCKED with an INPUT reason classification, rather than inventing a BLOCKED_INPUT gate enum. Re-read confirmed both Phase 00 replacements. |

## Required final pack checks

- Readable README with exact paste sequence, present-state recovery entry point and original-plan installation.
- Shared supervisor/contract referenced from every prompt, or standalone fallback when files have not been installed.
- All 124 original test IDs preserved, with correct per-phase binding and no relabeling.
- Every phase has implementation, independent verification, correction/retest cycle and concrete domain outputs.
- Full-pack acceptance must be document QA only; actual code gates remain unassessed here.
- Final source/config hashes must reflect corrected draft files; previous QA hashes must be regenerated after edits.

## Final structural and semantic QA

Read-only Python checks compared literal TNN IDs in each rewritten phase file against the original planning manifest, counted executable-prompt text blocks and checked shared-contract references.

- 16 phase files present, one for each Phase 00–15.
- 124 of 124 original required test IDs present in their corresponding phase, with no missing ID.
- Every phase contains two distinct prompt blocks, implementation/remediation and independent verification.
- Work package and test scenarios were compared semantically, not only by ID counts.
- Actual paths/scripts/lockfiles must be discovered in the real repo; proposed commands/endpoints are not represented as implemented here.
- Current-state recovery preserves prior evidence and dirty files, reproduces before fixing and distinguishes a configured live smoke from unexecuted quality measurements.
- Output standards require domain outputs plus traceable command/results, snapshot hashes, fix histories, independent-review limitations and executable blocker remedies.
- Long-running instructions track sessions and completion; subagents have file ownership and do not turn same-model review into statistical independence.
- Release prompts retain authorization limits, real canary/drain observations, rollback compatibility and zero fabricated measurements.

Installing the whole pack and original plan in the real repo is required for file-referencing prompts. The README gives that requirement and an exact paste sequence; these prompts should not be described as standalone when their companion files have not been installed.

## Independent packaging check

The reviewer independently inspected `verification/build_and_check_pack.py` and `verification/document-qa.json`, then ran read-only checks against the generated files:

- 21 embedded source documents in `PROMPTS-ALL.md` matched the corresponding source text verbatim, allowing only the builder's documented trailing-newline normalization.
- All 25 files listed in the package manifest matched their stored SHA-256 hashes.
- All 26 ZIP members matched current source bytes and archive CRC validation succeeded.
- QA states `scope: prompt_documents_only`, `project_execution_verified: false` and actual project gates `NOT_ASSESSED`.
- The builder verifies 150 original work-package IDs in addition to the 124 test IDs and 32 prompt blocks; these are document-coverage checks, not executed implementation results.

These archive checks were executed on the packaging snapshot before the final minor PR-09 source edit and this review-report update. The parent will regenerate and recheck the merge, manifest, QA and ZIP after the final changes so their hashes reflect the delivered artifacts. No source behavior changed after semantic review; PR-09 only clarifies canonical status wording.

## Review status

All review findings PR-01–09 are closed. Source pack and the inspected packaging method are accepted for document delivery, subject to the final automatic regeneration/check after this report update. No substantive design blocker remains in the inspected instructions. This is document QA only: code correctness, live semantic quality, actual gate results and production readiness remain unassessed by this review.
