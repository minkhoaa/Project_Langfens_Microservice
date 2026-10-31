---
name: using-reading-superpowers
description: Automatic entry, workflow activation, role handoffs, and completion gates for IELTS Reading generation. Use whenever an IELTS Reading generation, passage, or question request is received.
---

# Using Reading Superpowers

Automatic entry point and orchestration protocol for IELTS Academic Reading generation.

## The Rule

**Invoke this skill automatically on ANY IELTS Reading generation or authoring request BEFORE taking any other action.**

When a reading generation request arrives:
1. Do NOT write passage text or questions directly in the parent context.
2. The parent acts as Exam Designer, orchestrating the workflow through native Subagents.
3. Execute the 5-phase workflow systematically. Do not skip phases or completion gates.
4. Pass compact artifact references (`{file: "exam.json", pointer: "..."}`) rather than full context dumps.

## Roles & Responsibilities

| Role | Agent Name | Primary Responsibility | Authorized Tools | Context |
|---|---|---|---|---|
| **Exam Designer** | Parent (Coordinator) | Coordinates phases, verifies handoffs and gates, preserves evidence | `read`, `bash`, `write`, `subagent`, Reading validators/builders | Parent |
| **Passage Author** | `passage-author` | Authors authentic, topic-grounded academic passage | `read`, `bash`, `write`, `validate_exam` | Fresh |
| **Question Author** | `question-author` | Creates canonical questions using native builders | `read`, `bash`, `write`, Reading builders & validators | Fresh |
| **Semantic Checker** | `semantic-checker` | Independently verifies factual entailment, evidence, answerability | `read`, `bash`, `verify_evidence`, Reading validators | Fresh |
| **IELTS Examiner** | `ielts-examiner` | Independently evaluates task design, difficulty, distractors, scoring | `read`, `bash`, `check_grading_parity`, `inspect_delivery_projection`, Reading validators | Fresh |

## Workflow Phases & Acceptance Gates

### Phase 1: Passage Authoring
- **Action**: Delegate passage authoring to `passage-author`.
  ```js
  subagent({
    agent: "passage-author",
    task: "Author IELTS Academic Reading passage on [TOPIC]. Save initial exam structure with passage into exam.json.",
    options: { context: "fresh" }
  })
  ```
- **Inputs**: Topic, target word count (700-1000 words for Academic Section), section metadata.
- **Handoff Artifact**: `exam.json` with `sections[0].passageMd` populated.
- **Acceptance Gate 1**:
  - Passage text is non-empty and well-structured into clear paragraphs.
  - Word count within target range (verified via native bash).
  - Rich factual content to support subsequent question types.

### Phase 2: Question Authoring
- **Precondition**: Phase 1 Acceptance Gate passed. Passage authoring precedes question creation.
- **Action**: Delegate question authoring to `question-author`.
  ```js
  subagent({
    agent: "question-author",
    task: "Author [N] canonical questions grounded in the passage in exam.json. Use native builders and validate exam structure.",
    options: { context: "fresh" }
  })
  ```
- **Inputs**: Reference to `exam.json` containing the established passage. Requested question count (e.g. 13 questions), requested question types (no hardcoded distribution).
- **Handoff Artifact**: `exam.json` with `sections[0].questionGroups` and questions populated.
- **Acceptance Gate 2**:
  - All questions built with canonical builders (`create_*`).
  - Total question count matches requested count (e.g. 13Q).
  - For a 13-mark pilot, plan and require 13 independent one-slot Questions BEFORE building. Multi-target matching, multiple selection/Choose TWO, multi-blank Questions and process ordering cannot award independent marks here; block these structures, not just warn. Keep their builders available for other practice tasks.
  - `validate_exam({exam:{file:"exam.json"},pilot:true})` must return PILOT_13_MARKS PASS, with questionCount=answerSlots=scoringUnits=13, complete=true and exact passage embedded. Resolve companion passage text before checking; a missing passage blocks handoff.
  - Other tasks use `validate_exam` with no structural FAIL/ERROR.
  - Private answer keys separate from student-facing prompts; explanationMd contains only passage-grounded rationale.

### Phase 3: Independent Quality Review
- **Precondition**: Phase 2 Acceptance Gate passed.
- **Action**: Obtain independent reviews from `semantic-checker` and `ielts-examiner` in fresh contexts, preferably in parallel.
  ```js
  subagent({
    workflow: "parallel",
    async: true,
    options: { context: "fresh", outputMode: "file-only" },
    args: {
      tasks: [
        {
          agent: "semantic-checker",
          task: "Independently review exam.json revision r1. Verify evidence spans, answerability, and ambiguity."
        },
        {
          agent: "ielts-examiner",
          task: "Independently review exam.json revision r1. Verify IELTS authenticity, distractors, and scoring parity."
        }
      ]
    }
  })
  ```
- **Inputs**: Frozen artifact reference, full SHA-256 and report destination to both reviewers. Do not repeat the protocols already in their role-specific skills. Neither receives the other's findings, expected answer lists, 'must be' keys or an asserted verdict. Each independently derives answers from the passage before comparing private keys.
- Issue exactly ONE subagent call per turn. Use the native parallel workflow for the pair, never two sibling calls. Return control for native async completion; do not poll or call bg_wait. Read native returned output paths; never guess transcript/report filenames.
- **Handoff Artifacts**: `semantic-review.json` and `examiner-review.json` (or review reports returned by each subagent).
- **Acceptance Gate 3**:
  - Both reports identify reviewer, full artifact SHA-256, native child run/session reference, per-item verdicts, actual toolCallIds/check results, findings and unresolved issues.
  - Verify these against the native child transcripts and metadata (fresh context, authorized tools, role-specific skills). Native attested acceptance is a child's claim, not verified execution or independent quality PASS.
  - Reviewers actually used authorized domain tools successfully; a failed invocation or parent substitute does not satisfy specialist execution. Missing, stale, primed or unverifiable reports block quality PASS. Keep independent content-quality verdicts separate from runtime/parity limitations.
  - Actionable findings identified and classified (Blocker vs. Editorial).

### Phase 4: Targeted Repair Loop
- **Trigger**: Material findings or FAIL/BLOCKED reported by either reviewer. Do not regenerate for optional editorial preferences, missing backend identities or unchanged UNVERIFIED checks. Ambiguous/alternative defensible answers are material blockers, not editorial.
- **Action**:
  - Passage defects (unsupported claims, contradictions) -> dispatch to `passage-author`.
  - Question/distractor/scoring defects -> dispatch to `question-author`.
  - Provide concise, actionable finding details (specific question pointer, issue description). Do NOT send full transcript dumps.
  - Author corrects ONLY the affected item in `exam.json`.
  - Revalidate modified item: `validate_question`, then `validate_exam`.
  - Request re-review ONLY from the affected reviewer (do not restart successful stages).
- **Bounds**: Maximum 2 material repair rounds, including rollbacks; no third repair disguised as a reversion. After one corrected invocation still fails, stop that capability UNVERIFIED instead of sweeping shapes. Maximum 2 repair rounds. If issues remain unresolved after 2 rounds, stop immediately with `BLOCKED: <unresolved issues>` or `UNVERIFIED`. Do NOT loop indefinitely.

### Phase 5: Verification & Completion Gates
- **Completion Gates Checklist**:
  1. `validate_exam` traverses all sections, groups and questions: require relevant structural/hierarchy checks PASS, not overall PASS (semantics/transport remain UNVERIFIED). For the pilot also require PILOT_13_MARKS PASS.
  2. `verify_evidence` EVIDENCE_SPAN PASS for all applicable spans; overall semantics remains UNVERIFIED by design. NOT GIVEN requires independent absence reasoning, never a fabricated supporting quote.
  3. `inspect_delivery_projection` PASS (no answer leaks, valid public projection).
  4. `check_grading_parity` verified.
  5. Both independent reports are revision-bound, transcript-verifiable and have no unresolved material issues. A prose content PASS alone is insufficient; failed/missing checks or any defensible alternative answer block quality PASS.
  6. Final artifacts (`exam.json`), review findings, and metrics preserved in workspace.
- **Outcome Rule**:
  - If ALL gates are satisfied: Report `PASS` with evidence summary and execution metrics.
  - If ANY gate cannot be established: Report `BLOCKED` or `UNVERIFIED`. NEVER report PASS without required evidence!
