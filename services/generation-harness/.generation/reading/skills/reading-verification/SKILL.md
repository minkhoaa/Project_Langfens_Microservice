---
name: reading-verification
description: Evidence-based verification gates, targeted repair routing for detected flaws, revalidation of modified components, and completion readiness criteria.
---

# Reading Verification

Verification gates, targeted repair routing, and completion readiness criteria.

## Completion Gates Checklist

The workflow cannot report `PASS` or readiness without concrete proof across all six gates:

| Gate | Verification Check | Required Evidence | Tool Used |
|---|---|---|---|
| **Gate 1: Structure** | Canonical schema & hierarchy | Zero structural FAIL or ERROR; for the 13-mark pilot also require PILOT_13_MARKS PASS: complete artifact, embedded passage and 13 independently scored one-slot Questions | `validate_exam` with `pilot:true` |
| **Gate 2: Evidence** | Passage quote & span grounding | Exact UTF-16 start/end matching passage text for all keys | `verify_evidence` |
| **Gate 3: Projection** | Privacy & public delivery | Zero leaked answer keys, notes, or private flags in public view | `inspect_delivery_projection` |
| **Gate 4: Parity** | Scoring & grading format | Serialization and grading compatibility verified | `check_grading_parity` |
| **Gate 5: Independent Reviews** | Quality review sign-off | Both independent reports: reviewer, full artifact SHA-256, native child run/session reference, per-item verdicts, actual toolCallIds/check results, findings and unresolved issues; cross-check against native transcripts/metadata, not self-attestation | `subagent` persisted reports + native transcripts |
| **Gate 6: Evidence Preservation** | Durable artifacts | `exam.json`, review reports, and execution metrics preserved in workspace | `write` / filesystem |

## Targeted Repair Protocol

When a reviewer reports a material flaw (FAIL or Blocker finding):
1. **Route to the Responsible Author**:
   - Passage flaw (unsupported fact, internal contradiction, insufficient text) -> `passage-author`.
   - Question flaw (ambiguous key, bad distractor, missing marker, format error) -> `question-author`.
2. **Targeted Handoff**:
   - Send only the specific finding: question index/ID, issue description, suggested correction.
   - Do NOT transfer full chat transcripts or re-author untouched items.
3. **Revalidate Changed Components**:
   - Author repairs only the affected item in `exam.json`.
   - Validate modified question with `validate_question`.
   - Validate exam structure with `validate_exam`.
   - Do NOT restart successful stages (e.g. if question 4 was repaired, do not re-author the passage or questions 1-3).
4. **Targeted Re-Review**:
   - Re-request review ONLY from the reviewer who flagged the issue.
   - If both reviewers flagged issues on the item, both re-review.
5. **Iteration Cap**:
   - Maximum 2 material repair rounds per generation workflow, counting rollbacks. Optional editorial suggestions do not trigger another author/review cycle. A defensible alternative answer is material, never editorial.
   - If defects persist after 2 iterations, stop immediately with `BLOCKED: <unresolved issues>`.
   - Unproductive looping is strictly prohibited.

## Fail-Closed / Unverified Stop Rule

- No quality PASS from prose, structural PASS or native `acceptance.evidenceStatus=attested`. Missing, stale, primed, failed or unverifiable specialist reports block quality PASS. Do not feed expected answers or verdict cues to reviewers; parent-run validation cannot repair a specialist's missing execution.
- Native output persistence (`output` + `outputMode: "file-only"`) preserves reports without reviewer write authority or copying full reports through every context. Inspect the returned output/session/metadata references; do not guess paths. Fresh context is not filesystem isolation or proof of blind review.
- Group instructions are available in validate_exam, not standalone validate_question. WORD_LIMIT_CONTEXT_UNAVAILABLE alone is not an artifact defect. Keep successful stages; do not regenerate or reverse cosmetic instruction edits merely to obtain an impossible overall PASS.
- After one corrected invocation still fails, stop the capability UNVERIFIED and preserve diagnostics. Missing backend identities are a shared blocker, not 13 reasons to retry parity.
- If any gate fails or quality cannot be established:
  - Stop immediately with `BLOCKED` or `UNVERIFIED`.
  - Report the exact blocking reason, failed check, and unresolved findings.
  - Never fabricate evidence, invent UUIDs, or claim publication approval from structure alone.
