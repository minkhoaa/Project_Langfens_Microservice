---
name: reading-authoring
description: Guidelines and procedures for authoring authentic IELTS Academic reading passages and deriving passage-grounded questions using canonical Reading builders.
---

# Reading Authoring

Authoring standards and procedures for IELTS Academic Reading passages and canonical questions.

## Passage Authoring Guidelines (`passage-author`)

1. **Academic Register & Authenticity**:
   - Write in formal, objective, academic English.
   - Topics must reflect authentic IELTS Academic domains (e.g. natural sciences, history, architecture, environmental studies, psychology, technological development).
   - Avoid casual narratives, informal contractions, or overly simplistic syntax.

2. **Structure & Length**:
   - Typical academic section length: 700–1000 words.
   - Organize into 5–8 clearly demarcated paragraphs with coherent topic sentences.
   - Paragraphs should develop distinct aspects: introductory overview, historical background, core mechanism/findings, conflicting theories/evidence, and future implications.

3. **Factual Density for Testing**:
   - Include specific names, dates, numerical data, methodologies, and contrasting viewpoints.
   - Ensure clear propositions that support TRUE/FALSE/NOT GIVEN and matching without ambiguity.

4. **Storage & Handoff**:
   - Save initial structure in `exam.json`:
     ```json
     {
       "id": "exam-reading-01",
       "complete": false,
       "expectedQuestionCount": 13,
       "title": "Academic Reading Test",
       "sections": [
         {
           "id": "section-1",
           "idx": 1,
           "title": "Passage Title",
           "passageMd": "...",
           "questionGroups": [],
           "questions": []
         }
       ]
     }
     ```
   - Use native bash to compute exact word counts and inspect JSON structure.

## Question Authoring Guidelines (`question-author`)

1. **Passage Grounding**:
   - Every question must be derived solely from the authored passage in `exam.json`.
   - Do not require external domain knowledge to answer.
   - Distractors must be plausible given the topic but demonstrably incorrect or unmentioned based on the passage text.

2. **Retrieve Canonical Specifications Once**:
   - Retrieve type spec once per type in the context: `get_question_spec({ type: "..." })`.
   - Never guess schema rules or invent properties.

3. **Use Native Canonical Builders**:
   - Before drafting a 13-mark pilot, require 13 Questions with exactly one independent answer slot each. Multi-target matching, multiple selection/Choose TWO, multi-blank Questions and process ordering are unsupported for this pilot. Do not author them then wait for reviewers to discover the scoring conflict; the builders remain available for other practice tasks.
   - **Single Choice / True-False / Yes-No**: `create_single_choice`
     - Supply `options` with exactly one `isCorrect: true`.
     - For TRUE_FALSE_NOT_GIVEN: options TRUE, FALSE, NOT GIVEN.
     - For YES_NO_NOT_GIVEN: options YES, NO, NOT GIVEN.
   - **Multiple Choice (Multiple)**: `create_multiple_choice`
     - Supply at least 2 correct options and at least 1 distractor.
     - Explicit selection count in `promptMd` (e.g., "Choose TWO letters, A-E.").
   - **Completion & Diagram**: `create_completion`
     - Use `[1]`, `[2]` blank markers in `promptMd`.
     - Supply `blankAcceptTexts` with accepted string alternatives.
     - Include word limit instructions (e.g., "NO MORE THAN TWO WORDS").
   - **Matching**: `create_matching`
     - Supply target statements, options bank, and `matchPairs` (`[gradingKey, displayLabel]`).
     - Heading matching: prompt must include "List of Headings".
   - **Short Answer**: `create_short_answer`
     - Supply `shortAnswerAcceptTexts` and clear question prompt.
   - **Flow Chart Ordering**: `create_flow_chart`
     - Process ordering. Supply public `- key: label` lines and private `orderCorrects`.

4. **Separation of Student Content & Answer Keys**:
   - Student-facing fields (`promptMd`, `options[].contentMd`, instructionMd) must NEVER contain answers or key leaks.
   - `explanationMd` must be strictly limited to passage-grounded rationale; never include revision notes, review history, or editor commentary.

5. **Assembly & Validation**:
   - Assemble questions into groups and section in `exam.json`. A grouped Question has exactly one owner: questionGroups[].questions. Do not also copy it into sections[].questions; that duplicates records, identities and marks.
   - Use compact `{file: "exam.json", pointer: "..."}` references for validation.
   - For the 13-mark pilot run `validate_exam({ exam: { file: "exam.json" }, pilot: true })`; require PILOT_13_MARKS PASS (13 Questions/slots/scoring units, complete=true, embedded passage). Other tasks use ordinary validate_exam.
   - Builders already validate each Question and validate_exam traverses Questions/Groups; do not repeat all standalone validations for unchanged content. Diagnose only a specific failure.
   - Group word limits are checked in the containing Exam context. Standalone WORD_LIMIT_CONTEXT_UNAVAILABLE is not evidence that inherited instructions are defective; do not run removal/reversion cycles to chase UNVERIFIED.
   - Save deterministic evidence offsets as JSON numbers using JavaScript indexOf/slice and JSON.stringify, then reference the file. Never retype offsets as quoted strings or sweep alternative tool shapes.
