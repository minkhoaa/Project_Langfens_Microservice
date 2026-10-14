# Three-tier quality rubric and answer verification semantics

## Tier 1 — deterministic hard checks

Schema + supported question group/type, count/numbering under the *specific task blueprint*, instructions/options, answer word limit, verbatim restrictions for types requiring original wording, duplicate IDs and content/dependency hashes. A failure in a hard requirement cannot be compensated by a high fluency score. Production 3×40 structure applies only to full-paper target; research Reading unit has its own declared group/count schema.

## Tier 2 — QGEval-inspired quality dimensions

Scored 1–5 with documented anchors: `clarity` (no vague referents), `fluency` (grammatical and natural expression), `relevance` (matches intended objective and requested type), `grounding` (supported by source/rule without invented details), `answerability` (sufficient unambiguous information). Additional pedagogical fit/difficulty anchors may be reported separately; score thresholds and dimension weights must be calibrated and frozen before FINAL, not invented retrospectively.

Anchors: 1 = clear problem, 2 = major issue, 3 = mixed/uncertain, 4 = solid, 5 = strong and substantiated. Each nontrivial semantic verdict must cite source span or concrete rule plus reason. Applicability and missing-data state required; do not silently score missing evidence as zero if rubric defines non-evaluable.

## Tier 3 — type-specific task validity

- **TFNG/YNNG:** TRUE/YES requires entailment; FALSE/NO requires contradiction; NOT GIVEN requires neither entailment nor contradiction in all relevant passage context. A topical quote alone is inadequate evidence for absence.
- **MCQ Single:** exactly one intended supported option; alternative plausible options must be checked for actual wrongness in passage/context, not merely linguistic plausibility; weak distractors tracked as quality defects.
- **Sentence/Summary Completion and Short Answer:** enforce declared word limit and applicable verbatim constraint, correct completion context/grammar, acceptable alternatives and shared-summary consistency.
- **Grammar:** correctly scoped rule, relevant exceptions, contextualized sentence, one answer unless task explicitly permits multiple, robust distractors, independently verified solution and supported explanation; retrieved rule does not establish per-question answer truth.
- **Cross-question:** check leakage of an answer via another question, duplicate content and contradictions, including cross-group dependencies.

## Verification sequence

`Answer-free SolverView → recorded blind solution → AnswerVerificationView → evidence-grounding check → optional sealed expert gold comparison → verdict`. GoldReferenceView never reaches generation or blind solver. In-loop verification belongs to A/B/C execution trace only; external evaluator cannot inherit C's internal PASS.

## Decision rules

PASS: all applicable mandatory hard and task-validity checks satisfied plus prespecified semantic threshold; FAIL: a proven required condition violated; UNCERTAIN: insufficient support or assessor cannot reliably decide, with abstention reason; NOT_RUN: independent check not executed, never equivalent to PASS. A partial/failed output may be qualitatively evaluable, but does not count as E2E success absent declared completion requirements.
