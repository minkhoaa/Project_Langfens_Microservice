---
name: reading-quality-review
description: Independent semantic and IELTS examination of Reading content, verifying evidence grounding, answerability, distractors, task authenticity, and scoring parity.
---

# Reading Quality Review

Procedures for independent semantic checking and IELTS examination.

## Review Principles

1. **Context Independence**:
   - Reviewers operate in fresh contexts (`options: { context: "fresh" }`).
   - Neither reviewer sees the other reviewer's notes or pre-judged verdicts.
   - Work strictly from the frozen artifact: `exam.json`, identified by full SHA-256. Derive every answer independently before comparing private keys. Expected-key lists or 'must be' verdicts in a handoff contaminate independence: report UNVERIFIED and request a neutral task, not a confirming PASS.

2. **Read-Only Inspection**:
   - Reviewers NEVER edit `exam.json`.
   - Reviewers use authorized Reading tools and native bash for exact calculations.

## Semantic Review Protocol (`semantic-checker`)

1. Read `exam.json` and extract passage and questions.
2. For every question:
   - Identify the exact UTF-16 span in the passage using native bash (`indexOf` / `slice`).
   - Save computed numeric start/end/quote with JavaScript JSON.stringify to your own evidence file and call verify_evidence with saved {file,pointer} references for question, exact passage and evidence. Do not retype offsets as strings. Require the actual EVIDENCE_SPAN check PASS; overall UNVERIFIED is expected. After one corrected invocation still fails, stop and report it rather than sweep argument shapes. Parent checks cannot stand in for your specialist execution.
   - For NOT GIVEN, a context span may be checked mechanically but cannot prove absence; record searches/paraphrases and independent absence reasoning, not a fabricated supporting span.
   - Evaluate propositional entailment:
     - For TRUE/YES: does the passage unequivocally state this fact?
     - For FALSE/NO: does the passage directly contradict this fact?
     - For NOT GIVEN: is there truly no evidence in the text (neither confirmed nor contradicted)?
     - For completion/short answer: is the accepted word found directly in the passage?
   - Check distractors: are any distractors arguably defensible or ambiguous?
3. Produce a structured semantic review report:
   - Status: `PASS`, `FAIL`, or `UNVERIFIED`.
   - Tool calls executed.
   - Concise item-by-item findings.
   - Clear classification: Blocker (factual error, ambiguous or alternative defensible answer) vs. Editorial suggestion. Never downgrade a defensible alternative to editorial to reach PASS; 'most' does not logically prove 'not all'.
   - Include reviewer identity, full artifact SHA-256 (verify unchanged after review), native run/session reference when available, and actual toolCallIds with returned check IDs/statuses per item. Missing execution/provenance means UNVERIFIED, not PASS. Return the report through native output persistence, not a guessed filename.

## IELTS Examination Protocol (`ielts-examiner`)

1. Read `exam.json`.
2. Evaluate IELTS Academic standard compliance:
   - Authentic instruction wording ("Choose the correct letter", "Write NO MORE THAN TWO WORDS").
   - Difficulty progression across questions.
   - Distractor plausibility and quality.
   - Task variety and format adherence.
3. Validate scoring unit parity:
   - One backend Question = one all-or-nothing scoring unit (1 mark).
   - Verify no multi-blank question attempts to award multiple marks.
   - Call `check_grading_parity` for answer compatibility. If backend UUID identities are unavailable, record that shared limitation once; do not repeat the same failing probe for 13 items, invent UUIDs or rebuild content to chase runtime PASS.
4. Run public projection check:
   - Call `inspect_delivery_projection({ question })` to confirm no answer keys, correct flags, or teacher notes appear in student-facing fields.
5. Run full exam validation:
   - For a 13-mark pilot call `validate_exam({ exam: { file: "exam.json" }, pilot: true })`, requiring PILOT_13_MARKS PASS and 13 Questions/slots/scoring units. This traverses Questions/Groups; repeat standalone structural calls only for a specific failure. Reject unsupported multi-slot structures before reviewing content; other tasks use ordinary validate_exam.
6. Produce a structured IELTS examination report:
   - Status: `PASS`, `FAIL`, or `UNVERIFIED`.
   - Tool calls executed.
   - Concise item-specific findings, full artifact SHA-256, reviewer identity, native run/session reference when available, and actual toolCallIds/check results. Verify the artifact hash unchanged after review. Return through native output persistence.
   - Separate content-quality, mechanical structure/privacy, and grading/runtime verdicts. A prose PASS or native attested acceptance is not verified evidence. Missing/stale/failed/primed evidence blocks quality PASS; absent .NET execution also blocks publication readiness.
