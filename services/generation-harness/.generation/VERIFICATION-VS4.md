# VS4 verification — offline readiness only

## Decision

**Readiness: GO** for the restricted, non-regex pilot instrument and offline fixture scope.

**Real-model semantic quality: INSUFFICIENT_EVIDENCE.** No live pilot was run. This GO does not authorize inference, full-paper generation, publication, real student delivery, deployment or spending.

Research rubric **vs4.1** is provisional, not an official IELTS standard or a previously approved Langfens acceptance policy. See [evaluation/README.md](evaluation/README.md) for criterion definitions, human-adjudication protocol, rationale, limitations and explicit GO / NO-GO / INSUFFICIENT_EVIDENCE gates.

## Actual sequential verification

Executed from `services/generation-harness`:

```sh
node .generation/evaluation/run-offline.mjs /tmp/langfens-vs4-offline-final-1
```

| Check | Result |
| --- | --- |
| Root/Subagents typechecks | PASS, exit 0 |
| Domain and child-extension typecheck | PASS, exit 0 |
| Offline build | PASS, exit 0 |
| Harness tests (including VS1–VS3, all 19 native types and VS4) | PASS: 104 passed, 0 failed, 0 skipped |
| Retained Subagents regression suite | PASS: 3,491 passed, 0 failed, 13 skipped |
| Frozen packages/backend/AppHost/gateway tracked diff | PASS: empty, exit 0 |
| Same boundary's untracked status | PASS: empty, exit 0 |
| Whitespace check | PASS, exit 0 |

The 13 retained-suite skips are not claimed as exercised. No new .NET test result is claimed; no backend changes were made. Offline subprocesses inherit the existing provider-key sanitizer and hard external-network guard. Native-child tests use controlled faux outputs, not live inference. No repository commit or push was made.

Evidence snapshots:
- [evaluation/evidence/offline-readiness.json](evaluation/evidence/offline-readiness.json): exact command exits, log hashes, tested source hashes and scope; includes logRoot and test totals.
- [evaluation/evidence/readiness-report.json](evaluation/evidence/readiness-report.json): explicit per-requirement PASS and separate insufficient semantic-pilot evidence.
- Full raw command logs remain under `/tmp/langfens-vs4-offline-final-1/` for this session. Temporary logs may be removed by the host; regenerate with a new output directory rather than treating missing files as approval. The archived JSON is a test receipt, not a human semantic attestation.

## Added checks

- Incomplete/synthetic evidence never grants pilot approval, including a complete synthetic 13-item fixture.
- 13/13 answerability and 12/13 noncritical quality thresholds, 11/13 rejection, independent-session coverage and all eight criteria.
- Critical defects require human adjudication even when both reviewers agree; original model failures remain visible after human resolution.
- UNCERTAIN, severity/category disagreement and blind-solver/key mismatch remain unresolved until independent human adjudication. Human UNCERTAIN remains first-class.
- Known per-call metadata, raw-response hashes, key/evidence coverage, exact section-local UTF-16 spans and accountable protocol-audit records required for pilot GO.
- Missing/tampered evidence, traversal/symlink escapes, malformed schemas, invalid IDs and role-sharing identities fail closed.
- CLI exit codes: 0 GO, 1 invalid input, 2 NO-GO, 3 INSUFFICIENT_EVIDENCE. Same records yield reproducible reports without mutation.
- Actual native `verify_evidence` accepts its legacy PASS/FAIL fixture and rejects UNCERTAIN at its unchanged input boundary. The evaluator never calls it.
- Exact confidence-bound checks show why a single clean Section cannot justify expansion. Unresolved questions/sections count as adverse, not defect-free, in critical-rate bounds.

## Pilot and expansion boundaries

A future separately authorized pilot is limited to one 13-question Section, using TFNG, matching information, summary completion and single choice, one independent mark per Question. FLOW_CHART ordering and regex parity remain excluded. Two independent semantic judgments per criterion/item and human adjudication are required. All 13 correct unique keys need defensible passage evidence, with zero critical defects and at least 12 noncritical-quality passes. Preserve original raw responses, spans, reasoning, unique-call usage/latency/cost and lifecycle evidence, including failures.

The larger-sample proposal is at least **40 independently generated Sections / 520 questions**, independently reviewed across preregistered topics/types/runs. Proposed gates include zero critical defects/unresolved decisions, >=95% noncritical pass, confidence-aware item and section critical-rate upper bounds, and section-cluster uncertainty analysis. These are research proposals, not automatic approval. A single pilot report always retains `advancementDecision: INSUFFICIENT_EVIDENCE`.

## Limitations retained, not waived

- No real-model output or actual IELTS semantic quality has been evaluated.
- The fictional held-out passage is short and not representative; an independent human must assess/version it before any authorized pilot is frozen.
- Known-field/encoding leakage tests cannot guarantee detection of arbitrary unmarked natural-language hints. Future content needs independent manual leakage/isolation review.
- Literal spans, matching answers, claimed identities and model agreement do not prove entailment or independence. Hashes establish bytes, not truth. Counterfeit but consistent attestations cannot be authenticated by an offline script; organizational human accountability remains necessary.
- Qualitative difficulty predictions are not learner-calibrated bands. Binomial intervals disclose working independence assumptions; correlated items/reviewers and selection bias require a larger preregistered study.
- No frozen package, native approval contract or backend service was modified. The only specialist prompt change enables the explicit VS4 reviewer schema while preserving legacy behavior; no coordinator or generation pipeline was added.
