# ADR-005: Question-Type Schemas, Absence Semantics for NOT GIVEN, and Error Categorization

**Status:** Accepted  
**Date:** 2026-09-30  
**Phase:** Phase 01  
**Deciders:** Langfens Engineering Team  

---

## 1. Context

During the Phase 00 baseline and discovery audit, several architectural and behavioral discrepancies were identified in the legacy generation system:
1. **NOT GIVEN Evidence Fallacy:** The legacy generator required an `evidenceQuote` for every question, including `NOT_GIVEN` items. This forced LLMs to hallucinate or strain unrelated quotes to "prove" that information was absent, violating IELTS academic integrity.
2. **Short Answer Error Misclassification:** In legacy `ReadingPaperRules.cs`, validation for `SHORT_ANSWER` branched into a shared clause with completion, emitting `"Question {next} has an invalid completion answer"`. This confused administrators and downstream reporting.
3. **Option Deduplication:** Multiple-choice options were not consistently checked for uniqueness across both languages before evaluation.

## 2. Decision

We establish canonical question-type schemas and explicit validation rules:

### 2.1 Absence Semantics for NOT GIVEN
- For `TRUE_FALSE_NOT_GIVEN` and `YES_NO_NOT_GIVEN`:
  - When the answer is `TRUE`, `FALSE`, `YES`, or `NO`, an `evidenceQuote` (minimum 10 characters) matching a verbatim span in the passage is **strictly required**.
  - When the answer is `NOT_GIVEN`, an `evidenceQuote` is **not required** and should not assert positive proof.
  - Instead, `NOT_GIVEN` items must provide an `AbsenceAssessment`:
    ```json
    {
      "assessmentId": "abs_001",
      "claimOrTopic": "The exact founding date of the observatory",
      "absenceReason": "The passage discusses the equipment and location of the observatory, but completely omits when construction began or concluded.",
      "topicalContextSpan": "Paragraph 2 discusses early instruments...",
      "absenceConfirmed": true
    }
    ```

### 2.2 Verbatim Answer & Word Limits
- For `SENTENCE_COMPLETION`, `SUMMARY_COMPLETION`, and `SHORT_ANSWER`:
  - Answers must contain at most **3 words and/or 1 number** according to `\b[\w'-]+\b`.
  - The answer text must appear **verbatim** in the passage text (case-insensitive substring).

### 2.3 Independent Error Diagnostics
- `SHORT_ANSWER` validation failures are strictly diagnosed under their own typed issue code and descriptive messages, never masquerading as completion errors.

### 2.4 Multiple Choice Distinct Options
- `MULTIPLE_CHOICE_SINGLE` questions strictly require exactly 4 options labeled A, B, C, D where all 4 option texts are unique (normalized case-insensitive check).

## 3. Consequences

### Positive:
- **IELTS Pedagogical Accuracy:** Eliminates hallucinated "proof of absence" quotes, accurately reflecting how IELTS testers assess unmentioned claims.
- **Accurate Error Reporting:** Diagnostics reflect the exact question type and specific failure mode.
- **Cross-Language Uniformity:** Both Python Pydantic validators and .NET models enforce the identical invariants.

### Negative / Trade-offs:
- Evaluators must implement a specialized prompt and validation path for `AbsenceAssessment` rather than relying solely on string-matching quotes.
