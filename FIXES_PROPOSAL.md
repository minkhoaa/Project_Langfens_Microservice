# LANGFENS — Reading Extension & Backend Parity Fixes Proposal

**Baseline:** `85d87ea16cccefa8b1a3877647df5086ac7cb441`  
**Target Scope:** `services/generation-harness/` and related backend contracts (`services/exam-service/`, `services/attempt-service/`)  
**Audit Verdict:** `NEEDS_FIXES`  
**Execution Context:** Strict read-only audit executed via 5 independent concurrent Gemini subagents (`contract-auditor`, `api-reviewer`, `failure-auditor`, `security-verifier`, `integration-verifier`) with isolated contexts, followed by parent reconciliation against the source tree and runtime contracts.

---

## 1. Executive Summary

An independent blind quality and reliability audit was conducted across the Reading domain extension (`services/generation-harness/.generation/reading/`), canonical schemas (`question-types.v1.schema.json`), and .NET backend services (`exam-service`, `attempt-service`).

The generation harness demonstrates high architectural discipline:
- **Zero Registration Footprint:** Registration is inert (<16 KB RAM delta, ~0.012 ms latency, 0 file/schema reads).
- **Execution Performance:** Median validation latency is ~0.07 ms for individual questions and ~3.88 ms for full 100-question papers.
- **Compact Tool Surface:** 7 native tools total 3,972 declaration bytes (~993 tokens), utilizing only 24.2% of the 16 KB ceiling.
- **Fail-Closed Boundaries:** Status elevation hierarchy (`ERROR > FAIL > UNVERIFIED > PASS`) guarantees that unverified quality, semantic entailment, or missing runtime execution can never be reported as `PASS`.
- **Test Integrity:** All 88 domain tests (`.generation/reading/test/*.test.mjs`) pass cleanly offline.

However, the audit identified **3 P0 blockers**, **12 P1 high-priority defects**, and **8 P2 consistency/ergonomic gaps** across backend scoring, persistence lifecycle, API contract coverage, subagent isolation, and regex parsing. This document serves as the implementation handoff proposal to resolve all identified defects.

---

## 2. P0 Blockers & Architectural Asymmetries

### `P0-01` [Scoring Asymmetry]: 1 Question Entity = 1 Scoring Unit vs. Authentic IELTS Multi-Slot Marks
- **File & Line:**
  - `services/attempt-service/Features/Helpers/BuildQuestionIdSet.cs:178-184, 228-234`
  - `services/attempt-service/Features/Helpers/Grader.cs:169-170, 318-322, 400-404`
  - `services/generation-harness/.generation/contracts/question-types.v1.schema.json:465-470`
  - `services/generation-harness/.generation/reading/hierarchy.ts:25`
- **Issue:**
  In `BuildQuestionIdSet.cs`, every Question row is hardcoded to 1 scoring point (`points = 1m; total += points;`). In `Grader.cs`, `CompletionGrader`, `MatchingHeadingGrader`, and `MultipleChoiceGrader` evaluate answer slots all-or-nothing (`isAllMatched = total > 0 && get == total`). If a 5-blank summary completion table or a "Choose TWO letters" question is authored as 1 Question row, getting 4/5 blanks or 1/2 letters awards **0 points** instead of authentic IELTS partial marks.
- **Proposed Fix:**
  1. *Authoring Contract Policy (Preferred & Non-Breaking):* Enforce that authoring tools generate 1 platform `ExamQuestion` entity per answer slot (e.g. 5 Question rows for a 5-blank summary table, or 2 Question rows for a 2-answer multiple choice).
  2. *Backend Grading Parity:* Update `BuildQuestionIdSet.cs` to assign points proportional to slot count (e.g., `points = question.BlankAcceptTexts?.Count ?? 1m`), and update `Grader.cs` to award fractional or per-slot points (`ScoreFor(matchedCount, totalSlots, key.QuestionPoints)`).

---

### `P0-02` [Data Loss]: `AttemptService.Submit` Ignores Inline Request Answers
- **File & Line:**
  - `services/attempt-service/Features/Attempt/AttemptEndpoint/AttemptService.cs:445-455, 504-517`
- **Issue:**
  When a candidate invokes the `Submit` endpoint, `AttemptService` queries only persisted database rows: `context.AttemptAnswers.Where(x => x.AttemptId == attemptId)`. Any answer array sent directly in the `Submit` HTTP request body (`SubmitAttemptReq`) is ignored without error. If a client failed to autosave or relied on submit-time flushing, those answers are graded as empty (`null` / 0 points).
- **Proposed Fix:**
  In `AttemptService.cs` before initiating the grading transaction, check if `req.Answers` contains items. If present, drain and upsert them into `context.AttemptAnswers` using the existing autosave logic.

---

### `P0-03` [Persistence Defect]: `AttemptService.Autosave` Skips `null` / Omitted `TextAnswer`, Blocking Answer Clears
- **File & Line:**
  - `services/attempt-service/Features/Attempt/AttemptEndpoint/AttemptService.cs:330-345`
  - `services/generation-harness/.generation/contracts/question-types.v1.schema.json:368-372`
  - `services/generation-harness/.generation/reading/grading.ts:25, 32`
- **Issue:**
  In `AttemptService.cs`, incoming text updates are guarded with `if (eachIncomingAnswer.TextAnswer is not null)`. When a student clears a text input and the client sends `null` or omits `textAnswer`, the database update is bypassed and the old answer remains persisted.
- **Proposed Fix:**
  Align client and backend behavior:
  1. Frontend / caller must send `""` (empty string) to clear answers (`ClearSubmission`).
  2. In `AttemptService.cs:330`, update logic to differentiate omitted fields from explicit null clears: if an answer update is explicitly sent with `null`, reset `TextAnswer = null` and clear `IsCorrect`.

---

## 3. P1 High-Priority Findings & Recommended Fixes

### `P1-01` [Contract Omission]: Admin API (`Dto.Admin.cs`) Omits `GroupId` and `WordList`
- **File & Line:**
  - `services/exam-service/Contracts/Exams/Dto.Admin.cs:48-61, 63-75`
  - `services/exam-service/Domains/Entities/ExamQuestion.cs:18, 48`
  - `services/exam-service/Features/Exams/AdminEndpoint/QuestionEndpoint/AdminQuestion_Service.cs:175-197, 240-256`
- **Issue:**
  The domain entity `ExamQuestion` contains `GroupId` and `WordList`. However, `AdminQuestionUpsert` and `AdminQuestionUpdate` do not expose either field. Questions cannot be associated with groups or word lists via admin REST endpoints.
- **Proposed Fix:**
  Add `Guid? GroupId = null` and `IReadOnlyList<string>? WordList = null` to `AdminQuestionUpsert` and `AdminQuestionUpdate`. Assign them to entity properties in `AdminQuestion_Service.cs:180, 243`.

---

### `P1-02` [Pipeline Failure]: `attempt-service` Silently Drops Ungrouped Section Questions
- **File & Line:**
  - `services/attempt-service/Features/Helpers/BuildQuestionIdSet.cs:17-27, 40-48`
  - `services/exam-service/Application/Common/PaperWideNormalizer.ExamService.cs:48-73`
- **Issue:**
  `BuildQuestionIdSet.Build` and `QuestionIndex.Build` only traverse `sections[].questionGroups[].questions`. If an exam snapshot contains section-level `questions` without explicit groups, `Build` discovers 0 questions, causing `Submit` to fail with HTTP 500 (`Snapshot index/keys empty`).
- **Proposed Fix:**
  In `BuildQuestionIdSet.cs` and `QuestionIndex.cs`, enumerate `section.Questions` whenever `section.QuestionGroups` is absent or empty.

---

### `P1-03` [Security / Privacy]: Leakage Detection Regex Misses Standard Answer Headers and Markdown Lists
- **File & Line:**
  - `services/generation-harness/.generation/reading/projection.ts:6`
- **Issue:**
  Tested in Node.js REPL:
  `Answer: A`, `Answers: A`, `Teacher note: A`, `Key: A`, and `\n- solution: A` all evaluate to `false` under `privateAnnotation`. Natural-language answers authored into `promptMd` leak into public student projections.
- **Proposed Fix:**
  Update `privateAnnotation` in `projection.ts:6` to:
  ```ts
  const privateAnnotation = /(?:["'](?:blankAcceptTexts|blankAcceptRegex|shortAnswerAcceptTexts|shortAnswerAcceptRegex|matchPairs|orderCorrects|isCorrect|explanationMd|modelAnswers|evidence|reviews?)["']\s*:)|(?:^|[\n.!?]\s*(?:[-*+]\s+)?)(?:the\s+)?(?:correct\s+answers?|answer\s+keys?|correct\s+order|solutions?|teacher['’]?s?\s+notes?|keys?|answers?)\s*[:=]/i;
  ```

---

### `P1-04` [Security Isolation]: Blind Solver Worktree/CWD Separation Lacks Filesystem Access Denial
- **File & Line:**
  - `services/generation-harness/packages/generation-subagents/src/runs/shared/child-session.ts:636-648`
  - `services/generation-harness/packages/generation-harness-core/src/core/tools/read.ts:15-20`
  - `services/generation-harness/.generation/reading/projection.ts:42`
- **Issue:**
  Subagents receive an isolated `cwd`, but ambient tools (`read`, `bash`, `grep`, `find`) have unconstrained filesystem access. Any child agent can traverse `../../` or inspect absolute paths to read private authoring JSON files.
- **Proposed Fix:**
  1. Add negative-access verification harness asserting that child blind solvers cannot access paths outside their allocated sandbox.
  2. Implement path allowlisting in `read.ts`, `grep.ts`, `find.ts` restricting file access to `launch.cwd` when running under `blind-solver` profile.

---

### `P1-05` [Runtime Deadlock]: Permanent Failure Latching on Transient Contract I/O Glitches
- **File & Line:**
  - `services/generation-harness/.generation/reading/domain.ts:22, 27-28`
  - `services/generation-harness/.generation/reading/tools.ts:13`
- **Issue:**
  In `domain.ts`, `loadFailure` is latched in the module closure: `catch(e) { loadFailure = e; throw e; }`. Once an initial load fails (e.g., transient `EMFILE`), all subsequent calls immediately re-throw `loadFailure` without retrying.
- **Proposed Fix:**
  In `domain.ts:27`, do not permanently latch transient errors:
  ```ts
  if (!context) {
    try {
      context = loadCanonical(contractUrl);
      loadFailure = undefined;
    } catch (e) {
      // Allow retry on subsequent calls
      throw e;
    }
  }
  ```

---

### `P1-06` [Channel Inconsistency]: Pre-Execution Argument Rejections Drop `structuredContent` and `details`
- **File & Line:**
  - `services/generation-harness/.generation/reading/tools.ts:16-18`
  - `services/generation-harness/packages/generation-harness-core/src/agent-loop.ts:783, 922`
- **Issue:**
  When `prepareArguments` rejects an invalid outer argument, core intercepts the exception with `createErrorToolResult(error.message)`. This populates `content[0].text`, but leaves `details: {}` and `structuredContent: undefined`.
- **Proposed Fix:**
  In `packages/agent/src/agent-loop.ts:922`, attempt JSON parsing of the error string. If valid JSON and `tool.outputSchema` is declared, populate `details` and `structuredContent` with the parsed object.

---

### `P1-07` [Subagent Delegation]: Subagents Fail Tool Discovery Without `subagentOnlyExtensions`
- **File & Line:**
  - `services/generation-harness/packages/generation-subagents/src/runs/shared/child-launch.ts:316-325`
- **Issue:**
  Child subagents run in fresh sessions and do not inherit ambient parent extension tools. Declaring Reading tools in `tools:` without specifying `subagentOnlyExtensions: .generation/extensions/reading.ts` causes child startup to fail immediately.
- **Proposed Fix:**
  Update subagent agent definitions under `.generation/agents/` to include:
  ```yaml
  subagentOnlyExtensions:
    - .generation/extensions/reading.ts
  ```

---

### `P1-08` [Schema Mismatch]: `parameters` Declares `additionalProperties: true` But Runtime Fails with `FIELD_UNKNOWN`
- **File & Line:**
  - `services/generation-harness/.generation/reading/tools.ts:19`
  - `services/generation-harness/.generation/reading/support.ts:80`
- **Issue:**
  The TypeBox parameter schema states `additionalProperties: true`. If an LLM passes auxiliary properties (e.g., `{"question": {...}, "reasoning": "step 1"}`), `support.ts` strictly fails closed with `FIELD_UNKNOWN`.
- **Proposed Fix:**
  In `tools.ts:19`, set `additionalProperties: false` in the parameter schema so models are explicitly told extra properties are prohibited.

---

### `P1-09` [Output Schema Omission]: `outputSchema` Excludes `data` Property
- **File & Line:**
  - `services/generation-harness/.generation/reading/tools.ts:15-17`
- **Issue:**
  `outputSchema` defines only `status`, `contractVersion`, `checks`, and `diagnostics`. The primary domain payloads (`data.studentQuestion`, `data.example`, `data.counts`) are omitted from schema declarations.
- **Proposed Fix:**
  Add `data: { type: 'object', additionalProperties: true }` to `outputSchema.properties` in `tools.ts:15`.

---

### `P1-10` [Rule Rigidity]: Missing Word Limit Rule Fails on Parent Group Instructions
- **File & Line:**
  - `services/generation-harness/.generation/reading/rules/completion.ts:16`
  - `services/exam-service/Data/ReadingSeeder.cs:364`
- **Issue:**
  Rule `BLANKS` checks `/\b(?:\d+|one|...)\s+(?:words?|numbers?)\b/i.test(q.promptMd)`. In authentic exams, word limit instructions live on `ExamQuestionGroup.InstructionMd`. Running `validate_question` on an isolated prompt emits false `WORD_LIMIT_MISSING` `FAIL`.
- **Proposed Fix:**
  Allow `validate_question` to accept optional parent instruction context, or downgrade `WORD_LIMIT_MISSING` to `UNVERIFIED` unless parent group context is explicitly present and lacks word limits.

---

### `P1-11` [Parser Defect]: Heading Bank Parser Fails When Header Lacks Trailing Colon
- **File & Line:**
  - `services/generation-harness/.generation/reading/rules/matching.ts:32`
  - `services/exam-service/Data/ReadingSeeder.cs:209`
- **Issue:**
  `matching.ts` searches for `q.promptMd.indexOf('List of Headings:')`. In `ReadingSeeder.cs:209`, the seed prompt uses `### List of Headings` without a trailing colon. `indexOf` returns `-1`, causing valid platform seed questions to fail with `HEADING_BANK_MISSING`.
- **Proposed Fix:**
  In `matching.ts:32`, locate the heading bank using regex: `/(?:###?\s*)?List of [Hh]eadings:?/i`.

---

### `P1-12` [Public API Dropout]: Public Exam DTO Drops `FlowChartNodes` in REST Endpoint
- **File & Line:**
  - `services/exam-service/Contracts/Exams/Dto.Public.cs:49-55`
  - `services/exam-service/Contracts/Exams/Dto.Internal.cs:44`
  - `services/generation-harness/.generation/contracts/question-types.v1.schema.json:280`
- **Issue:**
  `PublicQuestionRecord` in `Dto.Public.cs` omits `FlowChartNodes`. While internal gRPC populates this collection, candidates querying the public REST exam endpoint cannot receive the flowchart node bank.
- **Proposed Fix:**
  Add `IReadOnlyList<InternalFlowChartNode>? FlowChartNodes = null` to `PublicQuestionRecord` in `Dto.Public.cs`.

---

## 4. P2 Medium-Priority Ergonomics, Consistency & Tests

* **`P2-01` [Grader Parity]: `MatchingHeadingGrader` Accepts Display Label as Answer String; Harness Rejects It**
  * **Evidence:** `attempt-service/.../Grader.cs:298-301`, `reading/grading.ts:80`.
  * *Fix:* Document this deliberate authoring constraint in `grading.ts` notes.
* **`P2-02` [Dead Code vs. Validation]: `FlowChartGrader` Steps+Labels vs. Admin Reject**
  * **Evidence:** `AdminQuestion_Service.cs:128`, `attempt-service/.../Grader.cs:337-374`.
  * *Fix:* Remove legacy reorder+label code from `FlowChartGrader` to align with canonical process ordering.
* **`P2-03` [Unchecked Cancellation]: `tools.ts:execute()` Does Not Re-check `signal?.aborted` Post-Await**
  * **Evidence:** `services/generation-harness/.generation/reading/tools.ts:27-29`.
  * *Fix:* Add `if (signal?.aborted) return adapt(...)` immediately following `await getDomain()`.
* **`P2-04` [Rejected Promise Caching]: `tools.ts` Caches Rejection in `pending` Singleton**
  * **Evidence:** `services/generation-harness/.generation/reading/tools.ts:13`.
  * *Fix:* Append `.catch(err => { pending = undefined; throw err; })` to reset `pending` on dynamic import failure.
* **`P2-05` [CI Integration]: Domain Tests Excluded from Root `npm test`**
  * **Evidence:** `services/generation-harness/package.json:20`.
  * *Fix:* Update root `"test"` script in `package.json` to include `node --test .generation/reading/test/*.test.mjs`.
* **`P2-06` [Declaration Size]: Output Schema Repetition Across All 7 Tools**
  * **Evidence:** `services/generation-harness/.generation/reading/tools.ts:16-20`.
  * *Fix:* Reference shared `$defs/Report` or define minimal output schema to reduce declaration size from 3,972 to ~2,200 bytes.
* **`P2-07` [Post-Scan Flowchart Attachment]: `student.flowChartNodes` Attached After Text Scan**
  * **Evidence:** `services/generation-harness/.generation/reading/projection.ts:15, 35`.
  * *Fix:* Move the `scan()` loop to execute after `flowChartNodes` is assigned.
* **`P2-08` [Selection Instruction Regex Fragility]: Rejects "Which TWO..." IELTS Phrasing**
  * **Evidence:** `services/generation-harness/.generation/reading/rules/choice.ts:13`, `GeneratedReadingSeeder.cs:273`.
  * *Fix:* Expand regex to match `\b(?:which|choose|select|pick)\s+(\d+|one|two|...)\s+\w+`.

---

## 5. Seven-Tool API Compactness & Reliability Summary

| Tool Name | Parameters | Declaration Bytes | Est. Tokens | First-Attempt Ergonomics | Status Precedence | Reliability Rating |
|---|---|---|---|---|---|---|
| `get_question_spec` | `(type: string)` | 555 B | ~139 | High; returns canonical example & available types on failure | `PASS` / `FAIL` | **RELIABLE** |
| `validate_question` | `(question: object)` | 555 B | ~139 | Moderate; single parameter; ends in `UNVERIFIED` by design | `UNVERIFIED` / `FAIL` | **RELIABLE** |
| `validate_group` | `(group: object)` | 530 B | ~132 | Moderate; requires standard container shape | `UNVERIFIED` / `FAIL` | **RELIABLE** |
| `validate_exam` | `(exam: object)` | 530 B | ~133 | Moderate; validates 4-tier tree; requires `complete: true` | `UNVERIFIED` / `FAIL` | **RELIABLE** |
| `verify_evidence` | `(question, passage, evidence)` | 605 B | ~151 | Low/Moderate; hidden requirement: forces full question validation | `UNVERIFIED` / `FAIL` | **FRAGILE** |
| `check_grading_parity` | `(question, submission)` | 606 B | ~152 | Low/Moderate; hidden requirement: strict `{state, answer}` envelope | `UNVERIFIED` / `FAIL` | **FRAGILE** |
| `inspect_delivery_projection` | `(question: object)` | 583 B | ~146 | Moderate; requires public markers in `promptMd` | `UNVERIFIED` / `FAIL` | **RELIABLE** |

---

## 6. Edge-Case Coverage Matrix

| Question Type / Feature | Case Description | Status | Evidence (file:line) | Notes |
|---|---|---|---|---|
| `MULTIPLE_CHOICE_SINGLE` | Single option selected matching correct UUID | **COVERED** | `reading/test/grading.test.mjs:26` | Canonical passing case. |
| `MULTIPLE_CHOICE_SINGLE` | Text content fallback accepted by .NET grader | **INCORRECT** | `attempt-service/.../Grader.cs:64`, `grading.ts:52` | .NET accepts option text; harness intentionally rejects text fallback. |
| `MULTIPLE_CHOICE_SINGLE` | Multiple option UUIDs selected | **COVERED** | `reading/test/grading.test.mjs:42` | Correctly diagnosed as `ANSWER_COUNT_INVALID`. |
| `MULTIPLE_CHOICE_SINGLE` | Duplicate option text across options | **COVERED** | `reading/rules/choice.ts:8` | Correctly diagnosed as `OPTION_CONTENT_DUPLICATE`. |
| `MULTIPLE_CHOICE_SINGLE` | Distractor collides with correct option text | **COVERED** | `reading/rules/choice.ts:10` | Correctly diagnosed as `DISTRACTOR_KEY_CONFLICT`. |
| `MULTIPLE_CHOICE_MULTIPLE` | Exact set equality of multiple correct UUIDs | **COVERED** | `attempt-service/.../Grader.cs:81` | Fully correct yields 1 scoring unit. |
| `MULTIPLE_CHOICE_MULTIPLE` | Partial correct selection (1 of 2 selected) | **COVERED** | `attempt-service/.../Grader.cs:81` | Awards 0 points (platform all-or-nothing). |
| `MULTIPLE_CHOICE_MULTIPLE` | Instruction: "Choose TWO answers", 2 correct options | **COVERED** | `reading/rules/choice.ts:13` | Regex matches and cardinality agrees. |
| `MULTIPLE_CHOICE_MULTIPLE` | Prompt: "Which TWO reasons does the author give..." | **MISSING** | `reading/rules/choice.ts:13`, `GeneratedReadingSeeder.cs:273` | Regex fails; emits `CHOICE_COUNT_INSTRUCTION_UNVERIFIED`. |
| `TRUE_FALSE_NOT_GIVEN` | Exact options `["True", "False", "Not Given"]` | **COVERED** | `reading/test/choice.test.mjs:15` | Enforced by schema; skill must be READING. |
| `TRUE_FALSE_NOT_GIVEN` | Case mismatch in options (e.g. `["TRUE", "FALSE"]`) | **COVERED** | `contracts/question-types.v1.schema.json:185` | Rejected by schema (exact casing required). |
| `TRUE_FALSE_NOT_GIVEN` | Semantic truth/falsity & NOT GIVEN proof | **UNVERIFIED** | `reading/rules/choice.ts:19` | Mechanically unverified; flagged `TRUTH_AMBIGUOUS`. |
| `YES_NO_NOT_GIVEN` | Exact options `["Yes", "No", "Not Given"]` | **COVERED** | `contracts/question-types.v1.schema.json:198` | Enforced by schema; skill must be READING. |
| `MULTIPLE_CHOICE_SINGLE_IMAGE` | Question `imageUrl` supplied, options have text | **COVERED** | `reading/test/completion.test.mjs:25` | Valid under schema `anyOf` branch 1. |
| `MULTIPLE_CHOICE_SINGLE_IMAGE` | Question `imageUrl` omitted, options have `imageUrl`+`altText` | **COVERED** | `reading/test/review-regression.test.mjs:15` | Valid under schema `anyOf` branch 2. |
| `MULTIPLE_CHOICE_SINGLE_IMAGE` | Option has `imageUrl` but missing `altText` | **COVERED** | `contracts/question-types.v1.schema.json:71` | Fails `dependentRequired` schema validation. |
| `SUMMARY_COMPLETION` | Explicit markers `[1]`, `[2]` match `blankAcceptTexts` keys | **COVERED** | `reading/rules/completion.ts:12` | Valid canonical blank alignment. |
| `SUMMARY_COMPLETION` | Word limit instruction on parent group only | **INCORRECT** | `reading/rules/completion.ts:16`, `ReadingSeeder.cs:364` | Isolated prompt emits false `WORD_LIMIT_MISSING`. |
| `SUMMARY_COMPLETION` | Duplicate marker (e.g. `[1]` occurs twice in prompt) | **COVERED** | `reading/rules/completion.ts:11` | Correctly diagnosed as `BLANK_MARKER_DUPLICATE`. |
| `SUMMARY_COMPLETION` | Blank ID exceeds positive signed Int64 (`long.MaxValue`) | **COVERED** | `reading/rules/completion.ts:14` | Correctly diagnosed as `BLANK_KEY_OVERFLOW`. |
| `TABLE_COMPLETION` | Markdown table syntax (`\| ... \|`) | **COVERED** | `reading/rules/completion.ts:21` | Recognized by layout check. |
| `NOTE_COMPLETION` | Bulleted list items (`- Item [1]`) | **COVERED** | `reading/rules/completion.ts:21` | Recognized by layout check. |
| `FORM_COMPLETION` | Field label formatting (`Name: [1]`) | **COVERED** | `reading/rules/completion.ts:21` | Recognized by layout check. |
| `SENTENCE_COMPLETION` | Freeform sentence layout with `[N]` | **COVERED** | `reading/rules/completion.ts:21` | Recognized by layout check. |
| `SHORT_ANSWER` | Marker-free prompt with `shortAnswerAcceptTexts` | **COVERED** | `reading/test/completion.test.mjs:28` | Enforced; options array must have `maxItems: 0`. |
| `DIAGRAM_LABEL` | Question `imageUrl` supplied with `[N]` callouts | **COVERED** | `contracts/question-types.v1.schema.json:237` | Requires `imageUrl` and completion blank map. |
| `MAP_LABEL` | Question `imageUrl` supplied with `[N]` location markers | **COVERED** | `contracts/question-types.v1.schema.json:241` | Requires `imageUrl` and completion blank map. |
| `MATCHING_HEADING` | Prompt has `List of Headings:` and Roman numeral bank | **COVERED** | `reading/rules/matching.ts:32` | Headings parsed against visible list. |
| `MATCHING_HEADING` | Prompt has `### List of Headings` (no colon) | **MISSING** | `reading/rules/matching.ts:32`, `ReadingSeeder.cs:209` | Fails with `HEADING_BANK_MISSING`. |
| `MATCHING_HEADING` | Reused heading across two targets | **COVERED** | `reading/rules/matching.ts:36` | Correctly diagnosed as `HEADING_REUSED`. |
| `MATCHING_INFORMATION` | Bank format `A. Paragraph A`, `B. Paragraph B` | **COVERED** | `reading/rules/matching.ts:38` | Enforced by rule check. |
| `MATCHING_INFORMATION` | Targets omitted from prompt, present in `MatchPairs` | **INCORRECT** | `ReadingSeeder.cs:248`, `matching.ts:17` | Seed exam omits targets; harness diagnoses `MATCH_TARGET_MISSING`. |
| `MATCHING_FEATURES` | Reused feature without instruction permission | **COVERED** | `reading/rules/matching.ts:44` | Correctly diagnosed as `FEATURE_REUSE_INSTRUCTION_MISMATCH`. |
| `MATCHING_ENDINGS` | Bank options with lettered sentence endings | **COVERED** | `reading/rules/matching.ts:47` | Enforced; reuse diagnosed as `ENDING_REUSED`. |
| `CLASSIFICATION` | Statement numbered 23 mapped to category letter | **COVERED** | `reading/rules/matching.ts:51` | Identity preserved without 0-offset. |
| `FLOW_CHART` | Ordering with unique slug keys (`^[a-z0-9]+(?:-[a-z0-9]+)*$`) | **COVERED** | `reading/rules/matching.ts:11` | Canonical process ordering validated. |
| `FLOW_CHART` | Prompt lacks explicit `- key: label` lines | **MISSING** | `reading/projection.ts:28`, `GeneratedReadingSeeder.cs:288` | Projection fails with `FLOW_PUBLIC_NODES_UNAVAILABLE`. |
| `FLOW_CHART` | Delivery generates labels from keys automatically | **COVERED** | `exam-service/.../ProtoHelper.cs:176` | Derives `Label = key.Replace("-", " ").Trim()`. |
| Group Hierarchy | Standalone group bounds (`startIdx`, `endIdx`) vs question `idx` | **COVERED** | `reading/hierarchy.ts:60` | Checked; mismatch diagnosed as `GROUP_BOUNDS_MISMATCH`. |
| Group Hierarchy | Section with both `questionGroups` and `questions` | **COVERED** | `reading/hierarchy.ts:87` | Correctly diagnosed as `SECTION_MEMBERSHIP_CONFLICT`. |
| Group Hierarchy | Section with 0 question groups in attempt-service | **INCORRECT** | `BuildQuestionIdSet.cs:19` | `attempt-service` silently drops ungrouped questions. |
| Exam Normalizer | Non-contiguous question indices across paper | **COVERED** | `PaperWideNormalizer.ExamService.cs:57` | Backend silently renumbers; harness checks coverage. |
| Submission Clear | `selectedOptionIds: []`, `textAnswer: ""` | **COVERED** | `reading/grading.ts:32` | Valid canonical clear operation. |
| Submission Clear | `textAnswer: null` sent to `AttemptService.Autosave` | **INCORRECT** | `AttemptService.cs:330`, `grading.ts:25` | Backend skips update; previous answer remains. |
| Submission Submit | Inline answers passed to `AttemptService.Submit` | **INCORRECT** | `AttemptService.cs:445` | Backend ignores inline answers; grades DB rows only. |
| .NET TextNorm | Written numbers normalized ("two" $\rightarrow$ "2") | **UNVERIFIED** | `GraderHelper.cs:72`, `completion.ts:27` | Grader normalizes numbers; harness marks UNVERIFIED. |

---

## 7. Failure-Injection Matrix

| Scenario | Injected Condition | Expected Behavior | Observed Behavior | Status | Evidence (file:line) |
|---|---|---|---|---|---|
| **FI-01** Valid Spec | `get_question_spec` (`SHORT_ANSWER`) | Return canonical spec, status PASS | Spec resolved, status PASS, `isError: false` | **PASS** | `reading/contract.ts:45` |
| **FI-02** Unsupported Type | `get_question_spec` (`ALIEN`) | Domain FAIL, return available types | Status FAIL, `TYPE_UNSUPPORTED`, `isError: true` | **FAIL** | `reading/contract.ts:46` |
| **FI-03** Missing Parameter | `validate_question` (`{}`) | Reject missing `question` key before execute | Throws in `prepareArguments`; `FIELD_REQUIRED` | **FAIL** | `reading/tools.ts:16`, `support.ts:88` |
| **FI-04** Null Parameter | `validate_question` (`null`) | Reject non-object outer argument | Throws in `prepareArguments`; `ARGUMENTS_OBJECT_REQUIRED` | **FAIL** | `reading/tools.ts:16`, `support.ts:95` |
| **FI-05** Primitive Argument | `validate_question` (`'string'`) | Reject non-object outer argument | Throws in `prepareArguments`; `ARGUMENTS_OBJECT_REQUIRED` | **FAIL** | `reading/support.ts:95` |
| **FI-06** Unknown Outer Key | `validate_question` (`{question, EXTRA: 1}`) | Reject unknown property, scrub payload | Throws in `prepareArguments`; `FIELD_UNKNOWN` | **FAIL** | `reading/support.ts:89` |
| **FI-07** Oversized Input | Argument byte length > 2 MB | Deterministic cutoff without OOM | Throws in `prepareArguments`; `INPUT_LIMIT` | **FAIL** | `reading/support.ts:58` |
| **FI-08** Depth Limit Violation | Object nested > 32 levels | Deterministic recursion cutoff | Throws in `prepareArguments`; `INPUT_LIMIT` | **FAIL** | `reading/support.ts:58` |
| **FI-09** Circular Reference | `self: cyclic` graph | Detect cycle without stack overflow | Throws in `prepareArguments`; `INPUT_NON_JSON` | **FAIL** | `reading/support.ts:65` |
| **FI-10** Non-JSON Prototype | Custom class / modified prototype | Reject non-standard prototypes | Throws in `prepareArguments`; `INPUT_NON_JSON` | **FAIL** | `reading/support.ts:64` |
| **FI-11** Proxy Argument | Wrapped in `new Proxy` | Reject proxy without evaluating traps | Throws in `prepareArguments`; `INPUT_NON_JSON` | **FAIL** | `reading/support.ts:63` |
| **FI-12** Getter Accessor | Custom getter accessor property | Reject without invoking accessor | Throws in `prepareArguments`; `INPUT_NON_JSON` | **FAIL** | `reading/support.ts:77` |
| **FI-13** Inner Question Null | `validate_question({question: null})` | Execute runs, domain returns FAIL | Returns status FAIL, `OBJECT_REQUIRED`, `isError: true` | **FAIL** | `reading/question.ts:9` |
| **FI-14** Unevaluated Property | Extra private property in Question | Domain FAIL via `unevaluatedProperties` | Status FAIL, key masked by `propertyIndex` | **FAIL** | `reading/support.ts:121` |
| **FI-15** Option Index Gap | Options with `idx: [1, 4]` | Fail option index coverage 1..N | Status FAIL, `OPTION_INDEX_COVERAGE`, `isError: true` | **FAIL** | `reading/question.ts:27` |
| **FI-16** Distractor Conflict | Distractor matches correct option text | Domain FAIL on distractor collision | Status FAIL, `DISTRACTOR_KEY_CONFLICT`, `isError: true` | **FAIL** | `reading/rules/choice.ts:10` |
| **FI-17** Stated Count Mismatch | "Choose THREE", correct count = 2 | Domain FAIL on cardinality mismatch | Status FAIL, `CHOICE_COUNT_INSTRUCTION_MISMATCH` | **FAIL** | `reading/rules/choice.ts:17` |
| **FI-18** Blank Key Overflow | Blank key `'9223372036854775808'` | Domain FAIL on Int64 overflow | Status FAIL, `BLANK_KEY_OVERFLOW`, `isError: true` | **FAIL** | `reading/rules/completion.ts:15` |
| **FI-19** Duplicate Marker | Prompt has `[23] ... [23]` | Domain FAIL on duplicate marker | Status FAIL, `BLANK_MARKER_DUPLICATE`, `isError: true` | **FAIL** | `reading/rules/completion.ts:13` |
| **FI-20** Heading Reused | Same heading to multiple targets | Domain FAIL on heading reuse | Status FAIL, `HEADING_REUSED`, `isError: true` | **FAIL** | `reading/rules/matching.ts:34` |
| **FI-21** Standalone Question | Canonical Question vector | Parent context unverified | Status UNVERIFIED, `PARENT_CONTEXT_UNVERIFIED` | **UNVERIFIED** | `reading/question.ts:31` |
| **FI-22** Section Conflict | Section has `questionGroups` & `questions` | Competing container ownership | Status FAIL, `SECTION_MEMBERSHIP_CONFLICT` | **FAIL** | `reading/hierarchy.ts:80` |
| **FI-23** Evidence Mismatch | Quote differs from passage slice | Reject quote discrepancy | Status FAIL, `EVIDENCE_SPAN_MISMATCH`, `isError: true` | **FAIL** | `reading/evidence.ts:21` |
| **FI-24** Surrogate Mid-Slice | Offset splits UTF-16 surrogate pair | Reject invalid code unit boundary | Status FAIL, `EVIDENCE_SPAN_INVALID`, `isError: true` | **FAIL** | `reading/evidence.ts:5, 20` |
| **FI-25** Final Incomplete | `state: 'final'`, empty answers | Reject incomplete final submission | Status FAIL, `ANSWER_INCOMPLETE`, `isError: true` | **FAIL** | `reading/grading.ts:86` |
| **FI-26** Malformed JSON Answer | `textAnswer: '{'` | Reject malformed JSON answer string | Status FAIL, `SUBMISSION_JSON_INVALID`, `isError: true` | **FAIL** | `reading/json-answer.ts:20` |
| **FI-27** Duplicate JSON Keys | `textAnswer: '{"23":"a","23":"b"}'` | Reject duplicate JSON keys in answer | Status FAIL, `SUBMISSION_JSON_DUPLICATE_KEY` | **FAIL** | `reading/json-answer.ts:9, 20` |
| **FI-28** Missing Contract File | Contract file path does not exist | Infrastructure ERROR, clean report | Status ERROR, `CONTRACT_UNAVAILABLE`, `isError: true` | **ERROR** | `reading/contract.ts:13`, `domain.ts:30` |
| **FI-29** Corrupt Contract Hash | Contract file tampered | Infrastructure ERROR, hash mismatch | Status ERROR, `CONTRACT_INVALID`, `isError: true` | **ERROR** | `reading/contract.ts:22`, `domain.ts:30` |
| **FI-30** Pre-Execute Abort | `signal.aborted === true` on entry | Cancellation ERROR, clean abort report | Status ERROR, `EXECUTION_ABORTED`, `isError: true` | **ERROR** | `reading/tools.ts:20` |
| **FI-31** Post-Await Abort | `signal.abort()` during `getDomain()` | Cancel tool execution | Executes `domain.call()` without checking signal | **UNVERIFIED** | `reading/tools.ts:29` |
| **FI-32** Latching Recovery | Contract restored after initial error | Reload contract on subsequent call | Latches `loadFailure`; permanently fails until restart | **ERROR** | `reading/domain.ts:27` |
| **FI-33** Diagnostic Cap | Report generating > 250 diagnostics | Cap at 250, emit truncation marker | Emits `DIAGNOSTIC_LIMIT`, elevates to UNVERIFIED | **UNVERIFIED** | `reading/support.ts:36` |

---

## 8. Ranked Implementation Roadmap for Handoff

### Phase 1: Critical Core & Persistence Fixes (P0)
1. **Scoring Strategy Alignment (`BuildQuestionIdSet.cs`, `Grader.cs`):** Update backend scoring to award per-slot marks or enforce 1 Question per slot in generation authoring templates.
2. **Submit Pipeline Drain (`AttemptService.cs:445`):** Drain and upsert incoming request answers before executing the grading transaction.
3. **Autosave Clear Support (`AttemptService.cs:330`):** Support explicit text clears when updating answers.

### Phase 2: High-Severity API, Security & Reliability Fixes (P1)
4. **Harden Leakage Regex (`projection.ts:6`):** Update `privateAnnotation` to catch `Answer:`, `Answers:`, `Key:`, `Teacher note:`, and Markdown list bullets `- solution:`.
5. **Transient Contract Loading Retry (`domain.ts:27`):** Clear `loadFailure = undefined` to allow retry on subsequent tool calls.
6. **Admin DTO Parity (`Dto.Admin.cs`):** Add `GroupId` and `WordList` to `AdminQuestionUpsert` and `AdminQuestionUpdate`.
7. **Schema & Runtime Synchronization (`tools.ts:19`):** Set `additionalProperties: false` in TypeBox parameter definitions to match `support.ts` enforcement.
8. **Add `data` to `outputSchema` (`tools.ts:15`):** Expose primary domain payloads to structured callers.
9. **Seed Compatibility Regexes (`matching.ts:32`, `choice.ts:13`):** Tolerate headers without colons (`### List of Headings`) and "Which TWO..." instructions.
10. **Public DTO Parity (`Dto.Public.cs:49`):** Add `FlowChartNodes` to `PublicQuestionRecord`.
11. **Subagent Extension Configuration:** Document and configure `subagentOnlyExtensions: .generation/extensions/reading.ts` in all IELTS agent manifests.
12. **Negative-Access Sandbox Verification:** Implement automated file isolation verification for blind solvers.

### Phase 3: Ergonomics & Integration Polishing (P2)
13. **AbortSignal Post-Await Check (`tools.ts:29`):** Re-check `signal?.aborted` immediately following `await getDomain()`.
14. **Reset Promise on Rejection (`tools.ts:13`):** Clear `pending = undefined` in `.catch()` on dynamic import failures.
15. **CI Script Update (`package.json:20`):** Include `.generation/reading/test/*.test.mjs` in root `npm test`.
16. **Post-Scan Flowchart Attachment (`projection.ts:15`):** Ensure `flowChartNodes` is scanned for text leakage.
