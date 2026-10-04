# Langfens Question-Type Spec — Single Source of Truth

## 0. Status

| Field | Value |
|---|---|
| Status | **DRAFT, pending sign-off** |
| Replaces | `docs/question-type-reports/INDEX.md` + 19 per-type JSON files |
| Audience | exam-service, attempt-service, FE do-test/result, generator authors |
| Locked decisions | D1–D7 below |
| Open items | §12 |

This document is the **only** canonical reference for question-type schemas. The per-type JSON files in `docs/question-type-reports/` are retained as historical evidence and will be removed once the schema migration (§11) completes.

---

## 1. Locked-in Decisions

### D1. Score rule — all-or-nothing, 1 mark per question

Every question awards exactly **1 mark** on Submit. No partial credit at any layer.

| Family | Rule |
|---|---|
| MCQ single / TFNG / YNNG / MCQ-single-image | 1 mark on exact match (selected GUID set == correct GUID set) |
| MCQ multiple | 1 mark on exact set equality |
| ShortAnswer | 1 mark if user text matches any of `ShortAnswerAcceptTexts` or any `ShortAnswerAcceptRegex` |
| Completion family (Summary / Table / Note / Form / Sentence / Diagram / Map) | 1 mark **iff every blank matches** (TextNorm equality OR regex). Any single blank wrong → 0 |
| Matching family (Heading / Information / Features / Endings / Classification) | 1 mark **iff every pair matches**. Any single pair wrong → 0 |
| FlowChart | 1 mark **iff user's node-key sequence equals `OrderCorrects` exactly** (after `NormNode` normalization) |

**Rationale:** IELTS Reading/Listening band scoring = correct count out of 40, mapped to band. Each question = 1 mark. The internal "got/total" tracking inside `MatchingHeadingGrader` / `CompletionGrader` is kept **for diagnostics only** (`AwardedPoints` always 0 or 1).

`QuestionPoints = 1` is hardcoded in `AnswerKeyBuilder.FromProto` (`BuildQuestionIdSet.cs:178`) and `FromDto` (line 228) — do not change without re-deriving band-table.

### D2. Enum cleanup — drop 2 enum values

| Constant | Status | Reason |
|---|---|---|
| `FLOW_CHART_COMPLETION` | **REMOVED** | Identical wire shape to `FLOW_CHART` but seeder q10 stored `BlankAcceptTexts` (completion-style). Folded into `SUMMARY_COMPLETION` per migration §11.3 |
| `AUDIO_RESPONSE` | **REMOVED** | Speaking-skill type; routed through ai-service / RabbitMQ, not in reading/listening auto-grader scope |

Net: 21 → **19** reading/listening types.

### D3. Single FE renderer stack

| Stack | File | Status |
|---|---|---|
| Live runner | `langfens-fe-app/src/app/do-test/[skill]/[attemptId]/_components/TestV2Runner.tsx` + `QuestionCard.tsx` + `cards/*` | **CANONICAL** |
| Engine-v3 standalone | `langfens-fe-app/src/components/exam-v3/*` + `app/test-v3/[examId]/page.tsx` | **DEPRECATE** — client-side grader bypasses BE |
| Legacy v1 registry | `langfens-fe-app/src/app/do-test/[skill]/[attemptId]/components/QuestionComponentRegistry.tsx` + `common/QuestionPanel.tsx` + `reading/*` | **DEPRECATE** — used only by `ResultReviewScreen.tsx` and `placement/[attemptId]/page.tsx` (will be replaced) |

After migration (§11.5), the entire legacy `components/QuestionComponentRegistry.tsx` tree is deleted. `resultApi.ts` merges BE `paperJson` with `getresult` and feeds `ResultV3Review.tsx` only.

### D4. Answer shape contract — `UserAnswerValue` union, JSON-encoded into TextAnswer

The single wire shape per type:

```ts
type UserAnswerValue = string | string[] | Record<string, string>;
```

| Family | In-memory `answers[qIdx]` | Autosave wire format |
|---|---|---|
| MCQ single / TFNG / YNNG / MCQ-single-image | `string` (option GUID) | `selectedOptionIds: [guid]`, `textAnswer: null` |
| MCQ multiple | `string[]` (option GUIDs) | `selectedOptionIds: [guid,...]`, `textAnswer: null` |
| ShortAnswer | `string` | `textAnswer: <raw text>` |
| Completion family (incl. Diagram, Map) | `Record<string, string>` keyed by blankId | `textAnswer: JSON.stringify(value)` |
| Matching family (incl. Classification) | `Record<string, string>` keyed by leftKey | `textAnswer: JSON.stringify(value)` |
| FlowChart | `string[]` (node keys in user order) | `textAnswer: JSON.stringify(value)` |

`buildAnswerPayload` in `langfens-fe-app/src/app/utils/hook.ts:8` is updated to:
- Accept `Record<string, UserAnswerValue>` (not `Record<string, string>`)
- For `Record<string, string>` / `string[]` → `textAnswer = JSON.stringify(value)` (and `selectedOptionIds = []`)
- For GUID-shape `string` → `selectedOptionIds = [value]`, `textAnswer = null`
- For other `string` → `textAnswer = value`, `selectedOptionIds = []`

### D5. Per-type storage validation

`AdminQuestion_Service.AddAsync` / `UpdateAsync` enforce that only the relevant fields are populated:

| Type | Required fields | Forbidden fields |
|---|---|---|
| `MULTIPLE_CHOICE_SINGLE` / `_SINGLE_IMAGE` | `Options` (≥2, exactly 1 `IsCorrect=true`) | MatchPairs, BlankAcceptTexts, OrderCorrects, ShortAnswerAcceptTexts |
| `MULTIPLE_CHOICE_MULTIPLE` | `Options` (≥2, ≥1 `IsCorrect=true`) | same as above |
| `TRUE_FALSE_NOT_GIVEN` / `YES_NO_NOT_GIVEN` | `Options` (exactly 3, exactly 1 `IsCorrect=true`) | same as above |
| `SUMMARY_COMPLETION` / `TABLE_COMPLETION` / `NOTE_COMPLETION` / `FORM_COMPLETION` / `SENTENCE_COMPLETION` / `DIAGRAM_LABEL` / `MAP_LABEL` | `BlankAcceptTexts` (Dict non-empty) | Options, MatchPairs, OrderCorrects, ShortAnswerAcceptTexts |
| `SHORT_ANSWER` | `ShortAnswerAcceptTexts` (List non-empty) | Options, MatchPairs, OrderCorrects, BlankAcceptTexts |
| `MATCHING_HEADING` / `_INFORMATION` / `_FEATURES` / `_ENDINGS` / `CLASSIFICATION` | `MatchPairs` (Dict non-empty, each value `[acceptedKey, displayLabel]`) | Options, BlankAcceptTexts, OrderCorrects, ShortAnswerAcceptTexts |
| `FLOW_CHART` | `OrderCorrects` (List non-empty, all keys match `[a-z0-9]+(?:-[a-z0-9]+)*$`) | Options, MatchPairs, BlankAcceptTexts, ShortAnswerAcceptTexts |

Validation rejects with HTTP 400 (`ApiResultDto(false, message, null)`).

### D6. Word-count constraint enforcement (IELTS "NO MORE THAN N WORDS")

`PromptMd` may carry an instruction like `NO MORE THAN TWO WORDS AND/OR A NUMBER`. Parsed at Submit time by `AttemptService.Submit` (after autosave flush, before grader):

```
parseWordLimit(promptMd) -> WordLimitRule { mode: "max_words" | "max_words_and_number", n: int }
validateWordCount(textAnswer, blankKey, rule) -> bool
```

If any blank violates the rule → `AwardedPoints=0`, `IsCorrect=false`, `Feedback="Word limit exceeded: <expected> (got <actual>)"`. The user sees the feedback in the result review.

Constraint regex (canonical):
```
/NO MORE THAN (ONE|TWO|THREE|FOUR|\d+)\s+WORDS(?:\s+AND\s*\/\s*OR\s+A\s+NUMBER)?/i
```

### D7. Regex logging (no silent swallow)

When `CompletionGrader` / `ShortAnswerGrader` encounter a malformed regex in `BlankAcceptRegex` / `ShortAnswerAcceptRegex`, they:
1. Log a warning via `ILogger` with the question UUID + regex string
2. Treat the regex as no-match (current behaviour preserved)
3. Return `GradeResult.NeedsManualReview=true` if ALL accepts for that blank fail to parse

---

## 2. Canonical `QuestionType` Enum (19 types)

File: `services/_shared/Shared.PublicContracts/Contracts/Exam/Enums/QuestionType.cs`

```csharp
public static class QuestionType
{
    // Choice family
    public const string MultipleChoiceSingle      = "MULTIPLE_CHOICE_SINGLE";
    public const string MultipleChoiceMultiple    = "MULTIPLE_CHOICE_MULTIPLE";
    public const string MultipleChoiceSingleImage = "MULTIPLE_CHOICE_SINGLE_IMAGE";
    public const string TrueFalseNotGiven         = "TRUE_FALSE_NOT_GIVEN";
    public const string YesNoNotGiven             = "YES_NO_NOT_GIVEN";

    // Completion family (incl. Diagram, Map)
    public const string SummaryCompletion         = "SUMMARY_COMPLETION";
    public const string TableCompletion           = "TABLE_COMPLETION";
    public const string NoteCompletion            = "NOTE_COMPLETION";
    public const string FormCompletion            = "FORM_COMPLETION";
    public const string SentenceCompletion        = "SENTENCE_COMPLETION";
    public const string ShortAnswer               = "SHORT_ANSWER";
    public const string DiagramLabel              = "DIAGRAM_LABEL";
    public const string MapLabel                  = "MAP_LABEL";

    // Matching family
    public const string MatchingHeading           = "MATCHING_HEADING";
    public const string MatchingInformation       = "MATCHING_INFORMATION";
    public const string MatchingFeatures          = "MATCHING_FEATURES";
    public const string MatchingEndings           = "MATCHING_ENDINGS";
    public const string Classification            = "CLASSIFICATION";

    // Ordering
    public const string FlowChart                 = "FLOW_CHART";
}
```

---

## 3. Master Spec Table

| # | Type | Storage field (required) | Answer key shape | User input shape | Wire `TextAnswer` format | FE renderer (live) | Grader rule |
|---|---|---|---|---|---|---|---|
| 1 | `MULTIPLE_CHOICE_SINGLE` | `Options` (≥2, exactly 1 correct) | `ExamOption.IsCorrect=true` (1 row) | `string` (option GUID) | `null` + `selectedOptionIds=[guid]` | `McqCard` (single) | Exact GUID match |
| 2 | `MULTIPLE_CHOICE_MULTIPLE` | `Options` (≥2, ≥1 correct) | `ExamOption.IsCorrect=true` (≥1 row) | `string[]` (option GUIDs) | `null` + `selectedOptionIds=[guid,...]` | `McqCard` (multi) | Set equality |
| 3 | `MULTIPLE_CHOICE_SINGLE_IMAGE` | `Options` (≥2, exactly 1 correct) + `ImageUrl` on each option | `ExamOption.IsCorrect=true` | `string` (option GUID) | `null` + `selectedOptionIds=[guid]` | `McqCard` (single) | Exact GUID match |
| 4 | `TRUE_FALSE_NOT_GIVEN` | `Options` (exactly 3) | `ExamOption.IsCorrect=true` (1 of 3) | `string` (option GUID) | `null` + `selectedOptionIds=[guid]` | `TrueFalseCard` | Exact GUID match |
| 5 | `YES_NO_NOT_GIVEN` | `Options` (exactly 3: Yes / No / Not Given) | `ExamOption.IsCorrect=true` (1 of 3) | `string` (option GUID) | `null` + `selectedOptionIds=[guid]` | `TrueFalseCard` | Exact GUID match |
| 6 | `SUMMARY_COMPLETION` | `BlankAcceptTexts` Dict | `{ blankId: [accept1, accept2, ...] }` | `Record<string,string>` | `JSON.stringify({...})` | `CompletionCard` | All blanks match (TextNorm or regex) |
| 7 | `TABLE_COMPLETION` | `BlankAcceptTexts` Dict | same | `Record<string,string>` | `JSON.stringify({...})` | `CompletionCard` | All blanks match |
| 8 | `NOTE_COMPLETION` | `BlankAcceptTexts` Dict | same | `Record<string,string>` | `JSON.stringify({...})` | `CompletionCard` | All blanks match |
| 9 | `FORM_COMPLETION` | `BlankAcceptTexts` Dict | same | `Record<string,string>` | `JSON.stringify({...})` | `CompletionCard` | All blanks match |
| 10 | `SENTENCE_COMPLETION` | `BlankAcceptTexts` Dict | same | `Record<string,string>` | `JSON.stringify({...})` | `CompletionCard` | All blanks match |
| 11 | `SHORT_ANSWER` | `ShortAnswerAcceptTexts` List | `[ "accept1", "accept2", ... ]` | `string` | raw text | `ShortAnswerCard` | Exact text OR regex match |
| 12 | `DIAGRAM_LABEL` | `BlankAcceptTexts` Dict + `ImageUrl` on question | `{ blankId: [...] }` | `Record<string,string>` | `JSON.stringify({...})` | `CompletionCard` | All blanks match |
| 13 | `MAP_LABEL` | `BlankAcceptTexts` Dict + `ImageUrl` on question | `{ blankId: [...] }` | `Record<string,string>` | `JSON.stringify({...})` | `CompletionCard` | All blanks match |
| 14 | `MATCHING_HEADING` | `MatchPairs` Dict + `Options` (heading list) | `{ paraId: [romanNumeral, headingText] }` | `Record<string,string>` | `JSON.stringify({...})` | `MatchingCard` | All pairs match |
| 15 | `MATCHING_INFORMATION` | `MatchPairs` Dict + optional `WordList` | same | `Record<string,string>` | `JSON.stringify({...})` | `MatchingCard` | All pairs match |
| 16 | `MATCHING_FEATURES` | `MatchPairs` Dict + `Options` (feature list) | same | `Record<string,string>` | `JSON.stringify({...})` | `MatchingCard` | All pairs match |
| 17 | `MATCHING_ENDINGS` | `MatchPairs` Dict | same | `Record<string,string>` | `JSON.stringify({...})` | `MatchingCard` | All pairs match |
| 18 | `CLASSIFICATION` | `MatchPairs` Dict | `{ stmtIdx: [categoryLetter, categoryText] }` | `Record<string,string>` | `JSON.stringify({...})` | `MatchingCard` | All pairs match |
| 19 | `FLOW_CHART` | `OrderCorrects` List | `[nodeKey1, nodeKey2, ...]` | `string[]` (node keys) | `JSON.stringify([...])` | `FlowChartCard` | Exact sequence match (after `NormNode`) |

---

## 4. Per-Type Detail

### 4.1 `MULTIPLE_CHOICE_SINGLE`

**Storage:** `ExamQuestion { Type, Options: [ExamOption x N] }`. Exactly one `ExamOption.IsCorrect=true`.

**Options UI:** Each option's `ContentMd` is `"<letter>. <text>"` (e.g. `"A. 18 liters"`). The renderer strips the `"<letter>. "` prefix before display (`QuestionComponentRegistry.tsx:50-53`).

**Answer shape:** `string` = selected option GUID.

**Grader** (`Grader.cs:18-38`):
```csharp
selected = answer.SelectedOptionIds?.ToHashSet() ?? {}
correctIds = key.CorrectOptionIds.Select(id).ToHashSet()
ok = selected.Count == 1 && correctIds.Contains(selected.First())
    || (!TextAnswer.IsNullOrWhiteSpace && (
        Guid.TryParse(TextAnswer, out g) && correctIds.Contains(g)
        || correct.Any(c => c.content?.Trim() == TextAnswer.Trim())
    ))
return new GradeResult(ok ? 1 : 0, ok)
```

The TextAnswer fallback is a **legacy back-compat shim** for old FE builds that routed GUIDs into `TextAnswer`. The canonical FE path uses `selectedOptionIds`. The shim is preserved indefinitely.

**Autosave payload:**
```json
{ "questionId": "<uuid>", "sectionId": "<uuid>",
  "selectedOptionIds": ["<optionGuid>"], "textAnswer": null }
```

**Review display:** `ResultV3Review` shows the correct option highlighted in green; user selection in red if wrong.

---

### 4.2 `MULTIPLE_CHOICE_MULTIPLE`

**Storage:** Same as single-choice, but **≥1** options have `IsCorrect=true` (typically 2–4 for "Choose THREE").

**Answer shape:** `string[]` = selected option GUIDs.

**Grader** (`Grader.cs:42-55`):
```csharp
selected = answer.SelectedOptionIds?.ToHashSet() ?? {}
correctIds = key.CorrectOptionIds.Select(id).ToHashSet()
isCorrect = selected.SetEquals(correctIds)
return new GradeResult(isCorrect ? 1 : 0, isCorrect)
```

Set equality is order-insensitive. Partial-correct subset always scores 0.

**Autosave payload:**
```json
{ "questionId": "<uuid>", "sectionId": "<uuid>",
  "selectedOptionIds": ["<g1>", "<g2>", "<g3>"], "textAnswer": null }
```

---

### 4.3 `MULTIPLE_CHOICE_SINGLE_IMAGE`

Identical to `MULTIPLE_CHOICE_SINGLE` (reuses `SingleChoiceGrader`). The only delta:
- `ExamOption.ImageUrl` populated on each option
- `Question.ImageUrl` may be set for context image (above options)
- Renderer is the same `McqCard` — images are rendered alongside option text

**Open item §12.2:** Decide whether to render images inline (current `McqCard`) or replace option text entirely. Generator must emit `ImageUrl` on options.

---

### 4.4 `TRUE_FALSE_NOT_GIVEN` / 4.5 `YES_NO_NOT_GIVEN`

**Storage:** 3 options, exactly 1 correct.

| TFNG | YNNG |
|---|---|
| `"A. True"` | `"A. Yes"` |
| `"B. False"` | `"B. No"` |
| `"C. Not Given"` | `"C. Not Given"` |

**Grader:** Reuses `SingleChoiceGrader` (registered for both types).

**Migration §11.2:** ReadingSeeder q9 currently has only 2 options (Yes/No). Add 3rd option `"C. Not Given"`, Idx=2, `IsCorrect=false`.

**Answer shape:** `string` (GUID). `TrueFalseCard` translates `"YES"` / `"TRUE"` / `"NOT GIVEN"` etc. → option GUID.

---

### 4.6–4.10 Completion Family (`SUMMARY_COMPLETION`, `TABLE_COMPLETION`, `NOTE_COMPLETION`, `FORM_COMPLETION`, `SENTENCE_COMPLETION`)

**Storage:** `ExamQuestion.BlankAcceptTexts: Dictionary<string, string[]?>`.

BlankId conventions (auto-generator must follow):
- **Numeric `"0"`, `"1"`, ..., `"N"`** — preferred for completion inside numbered sentences ("1. The nets are made from ___ and ..."). Question prompt must contain matching `[0]` brackets or `___` underscores.
- **`"blank-q<N>"`** — used by some listening seeds for sub-question indexing.

Mixed conventions are allowed as long as `CompletionCard`'s auto-detection logic (`CompletionCard.tsx:21-50`) can find them.

**Answer shape:** `Record<string, string>` (blankId → user text).

**Wire format:** `TextAnswer = JSON.stringify(record)`.

**Grader** (`CompletionGrader`, `Grader.cs:60-227`):
```csharp
map = JSON.parse(TextAnswer) ?? {}
total = 0
matched = 0
foreach blankId in BlankAcceptTexts.Keys ∪ BlankAcceptRegex.Keys:
    if no accepts → continue
    total += 1
    userText = map[blankId] ?? ""
    userNorm = TextNorm.Normalize(userText)
    if BlankAcceptTexts[blankId].Any(t => TextNorm.Normalize(t) == userNorm):
        matched += 1
    elif BlankAcceptRegex[blankId].Any(rx => Regex.IsMatch(userText, ^rx$, IgnoreCase)):
        matched += 1
ok = total > 0 && matched == total
return new GradeResult(ok ? 1 : 0, ok)
```

**Fallback path** (legacy / partial-fill): single-blank `TextAnswer` (raw string) or newline-separated values. Used only when FE ships a build that does not JSON-encode.

**Autosave payload:**
```json
{ "questionId": "<uuid>", "sectionId": "<uuid>",
  "selectedOptionIds": [],
  "textAnswer": "{\"0\":\"polypropylene\",\"1\":\"underground\"}" }
```

---

### 4.11 `SHORT_ANSWER`

**Storage:** `ExamQuestion.ShortAnswerAcceptTexts: List<string>` (OR-alternates) and/or `ShortAnswerAcceptRegex: List<string>`.

**Constraint:** Each question is **one** short answer (one mark). If the generator needs N sub-questions, emit N `SHORT_ANSWER` questions (or use `SENTENCE_COMPLETION`).

**Answer shape:** `string` (raw user text).

**Grader** (`ShortAnswerGrader`, `Grader.cs:357-391`):
```csharp
input = TextAnswer ?? ""
norm = TextNorm.Normalize(input)
matched = ShortAnswerAcceptTexts.Any(t => TextNorm.Normalize(t) == norm)
if !matched:
    foreach rx in ShortAnswerAcceptRegex:
        if Regex.IsMatch(input, ^rx$, IgnoreCase): matched = true
return new GradeResult(matched ? 1 : 0, matched)
```

**Word-count constraint (D6)** applies — parsed from `PromptMd`, validated before grading.

**Autosave payload:**
```json
{ "questionId": "<uuid>", "sectionId": "<uuid>",
  "selectedOptionIds": [],
  "textAnswer": "twenty one" }
```

---

### 4.12 `DIAGRAM_LABEL` / 4.13 `MAP_LABEL`

**Storage:** Same as completion family: `BlankAcceptTexts` Dict. Plus `ExamQuestion.ImageUrl` set to the diagram/map image URL.

**BlankId convention:** Numeric `"0"`, `"1"`, ... (one per numbered location in the diagram).

**Answer shape:** `Record<string, string>`.

**Renderer:** `CompletionCard` (same as completion family) — reads `BlankAcceptTexts` from question, renders one input per blankId, displays the image above.

**Grader:** `LabelGraderRegistration` → `LabelGrader` → pass-through to `CompletionGrader`. Same all-or-nothing rule.

**Autosave payload:** same as completion family.

---

### 4.14–4.18 Matching Family (`MATCHING_HEADING`, `MATCHING_INFORMATION`, `MATCHING_FEATURES`, `MATCHING_ENDINGS`, `CLASSIFICATION`)

**Storage:** `ExamQuestion.MatchPairs: Dictionary<string, string[]?>`. Each value is a 2-element array: `[acceptedKey, displayLabel]`.

| Type | LeftKey (key) | RightKey (value[0]) | Display label (value[1]) |
|---|---|---|---|
| `MATCHING_HEADING` | paragraph identifier (`"A"`, `"B"`, ..., or `"para-0"`, etc.) | roman numeral (`"iii"`) | full heading (`"iii. The Spread of Coffee"`) |
| `MATCHING_INFORMATION` | statement index (`"0"`, `"1"`, ...) | paragraph letter (`"A"`) OR word from `WordList` | paragraph title OR word |
| `MATCHING_FEATURES` | item identifier (`"item-0"`, ..., or `"feature-q1"`) | uppercase letter (`"D"`) | full feature text |
| `MATCHING_ENDINGS` | sentence index (`"0"`, `"1"`, ...) | uppercase letter (`"A"`) | sentence ending text |
| `CLASSIFICATION` | statement index (`"0"`, `"1"`, ...) | uppercase letter (`"A"`) | category text |

**Answer shape:** `Record<string, string>` (leftKey → user-selected rightKey).

**Grader** (`MatchingHeadingGrader`, `Grader.cs:238-293`):
```csharp
map = JSON.parse(TextAnswer) ?? {}
total = pairs.Count
matched = 0
foreach (left, right) in pairs:
    if map[left] is not null && right.Any(r => OrdinalIgnoreCase.Equals(r, map[left])):
        matched += 1
ok = total > 0 && matched == total
return new GradeResult(ok ? 1 : 0, ok)
```

All-or-nothing per D1.

**Renderer:** `MatchingCard` (`_components/cards/MatchingCard.tsx`):
- Walks `matchPairs` to determine prompt items (leftKeys)
- Walks `options` or `matchPairs` values to determine the choice pool
- Renders one `<select>` per leftKey, pre-filled with `userDict[leftKey]`
- On change → `onChange({ ...userDict, [leftKey]: selectedGradingKey })`

**`MATCHING_INFORMATION` has two sub-shapes** distinguished at render time by prompt structure:
1. **matching_paragraph** — single-letter inputs (use `MatchingCard` with paragraph-letter choices)
2. **matching_information** (word-list variant) — uses `WordList` from question, picks one word per blank without repeat

Generator chooses sub-shape based on `WordList` presence:
- `WordList != null && WordList.Length > 0` → word-list variant
- else → paragraph-letter variant

**Autosave payload:**
```json
{ "questionId": "<uuid>", "sectionId": "<uuid>",
  "selectedOptionIds": [],
  "textAnswer": "{\"para-0\":\"iii\",\"para-1\":\"i\"}" }
```

---

### 4.19 `FLOW_CHART`

**Storage:** `ExamQuestion.OrderCorrects: List<string>` — node keys in correct order. Each key must match `^[a-z0-9]+(?:-[a-z0-9]+)*$`.

`ExamQuestion.FlowChartNodes` is **derived** (not stored) — generated from `OrderCorrects` in `ProtoHelper.BuildFlowChartNodes` (`exam-service/Application/Common/ProtoHelper.cs:155-179`) by replacing `-` with space and trimming.

**Answer shape:** `string[]` (node keys in user's chosen order).

**Wire format:** `TextAnswer = JSON.stringify(arr)`.

**Grader** (`FlowChartGrader`, `Grader.cs:295-355`):
```csharp
correct = OrderCorrects.Select(NormNode).Where(non-empty).ToList()
userList = JSON.parse(TextAnswer) ?? []
user = userList.Select(NormNode).Where(non-empty).ToList()
ok = correct.Count > 0 && correct.SequenceEqual(user)   // exact order match
return new GradeResult(ok ? 1 : 0, ok)
```

**`NormNode`** normalization (line 322-330):
```csharp
NormNode(s) = s.ToLowerInvariant()
                 .Replace('-', ' ')
                 .Replace(non-alphanumeric, ' ')
                 .Replace(\s+, ' ')
                 .Trim()
```

The old LCS-based proportional scoring is **removed** per D1. The function `LCS` is deleted from `Grader.cs`.

**Renderer:** `FlowChartCard` (`_components/cards/FlowChartCard.tsx`):
- Receives `nodes: {key, label}[]` from question (derived from OrderCorrects)
- Renders one numeric input per node (`<input type="number" min=1 max=N>`)
- On change → `onChange(updatedKeyArray)`

**Autosave payload:**
```json
{ "questionId": "<uuid>", "sectionId": "<uuid>",
  "selectedOptionIds": [],
  "textAnswer": "[\"warm intake\",\"evaporator dome\",\"turbine hall\",\"condenser bay\",\"return line\"]" }
```

---

## 5. Storage Contract

### 5.1 `ExamQuestion` entity

File: `services/exam-service/Domains/Entities/ExamQuestion.cs:1-83`

| Column | Type | Used by |
|---|---|---|
| `Id` | `Guid` PK | all |
| `SectionId` | `Guid` FK | all |
| `GroupId` | `Guid?` FK → `ExamQuestionGroup` | all (optional) |
| `Idx` | `int` (1-based, section-local) | all |
| `Type` | `string` (one of the 19 enum values, validated per D5) | all |
| `Skill` | `string` (`READING` / `LISTENNING` / `WRITING` / `SPEAKING`) | all |
| `Difficulty` | `int` (1..N) | all |
| `PromptMd` | `string` (Markdown; may carry word-limit instruction) | all |
| `ExplanationMd` | `string?` | all (post-submit reveal) |
| `ImageUrl` | `string?` | MCQ-single-image, Diagram, Map |
| `BlankAcceptTexts` | `jsonb` `Dictionary<string, string[]?>?` | completion family (6.6–6.10, 6.12, 6.13) |
| `BlankAcceptRegex` | `jsonb` `Dictionary<string, string[]?>?` | completion family |
| `MatchPairs` | `jsonb` `Dictionary<string, string[]?>?` | matching family (6.14–6.18) |
| `OrderCorrects` | `text[]` `List<string>?` | FlowChart (6.19) |
| `ShortAnswerAcceptTexts` | `text[]` `List<string>?` | ShortAnswer (6.11) |
| `ShortAnswerAcceptRegex` | `text[]` `List<string>?` | ShortAnswer (6.11) |
| `ModelAnswers` | `jsonb` `List<string>?` | (reserved for writing/speaking, not in this spec) |
| `WordList` | `jsonb` `List<string>?` | MatchingInformation word-list variant |
| `Options` | `1:N ExamOption` | choice family (6.1–6.5) |

**Migration §11.4:** Add per-type validation to `AdminQuestion_Service.AddAsync` per D5.

### 5.2 `ExamOption` entity

File: `services/exam-service/Domains/Entities/ExamOption.cs`

| Column | Type | Notes |
|---|---|---|
| `Id` | `Guid` PK | |
| `QuestionId` | `Guid` FK | |
| `Idx` | `int` | 0-based; renderer strips `^[A-Z]\.\s+` prefix from `ContentMd` |
| `ContentMd` | `string` | text or `"<letter>. <text>"` |
| `IsCorrect` | `bool` | **Sanitized to `false` before delivery to FE** (`SnapshotSanitizer`) |
| `ImageUrl` | `string?` | MCQ-single-image |
| `AltText` | `string?` | accessibility |

### 5.3 `AttemptAnswer` entity

File: `services/attempt-service/Domain/Entities/AttemptAnswer.cs`

| Column | Type | Used for |
|---|---|---|
| `Id` | `Guid` PK | |
| `AttemptId` | `Guid` FK | |
| `SectionId` | `Guid` | |
| `QuestionId` | `Guid` | |
| `SelectedOptionIds` | `List<Guid>?` | choice family |
| `TextAnswer` | `string?` | all other families (JSON-encoded for non-string shapes) |
| `IsCorrect` | `bool?` | null until Submit; reset on autosave text change (§7.4) |
| `AwardedPoints` | `decimal?` | null until Submit |
| `RagFeedbackJson` | `JsonDocument?` | post-Submit RAG feedback (reading/listening) |

---

## 6. Answer-Key Sanitization

### 6.1 `InternalExamDto.SnapshotSanitizer` (`Shared.PublicContracts/.../SharedInternalExamDto.cs:78-104`)

Before serializing `paperJson` to FE, clear:
- `Options[].IsCorrect = null`
- `BlankAcceptTexts = {}`
- `BlankAcceptRegex = {}`
- `MatchPairs = {}`
- `OrderCorrects = []`
- `ShortAnswerAcceptTexts = []`
- `ShortAnswerAcceptRegex = []`

### 6.2 `GrpcSnapshotSanitizer` (`services/attempt-service/Features/Helpers/ExamGateway.cs:47-69`)

Before serializing gRPC `paperJson`:
- `Options[].ClearIsCorrect()` (proto3 optional clear)
- `CompletionAccepts.Clear()`
- `MatchPairs.Clear()`
- `OrderCorrects.Clear()`
- `ShortAnswerAcceptTexts.Clear()`
- `ShortAnswerAcceptRegex.Clear()`

The FE never receives answer keys via the plain paper payload. Correct-answer text is fetched separately at result-review time via `resultApi.ts` calling `GET /internal/exams/{examId}/delivery?showAnswers=true`.

---

## 7. Autosave Contract

### 7.1 Endpoint

`POST /api/attempt/autosave/{attemptId}` — `services/attempt-service/Features/Attempt/AttemptEndpoint/AttemptService.cs:222-362`

Auth: `Roles.User` + `Scopes.AttemptReadOwn`

### 7.2 Payload

```json
{
  "answers": [
    {
      "questionId": "<uuid>",
      "sectionId": "<uuid>",
      "selectedOptionIds": ["<guid>", ...] | [],
      "textAnswer": "<string>" | null
    }
  ],
  "clientRevision": 1700000000000
}
```

DTO: `AutosaveRequest(List<AnswerItem> Answers, long? ClientRevision)` — `services/attempt-service/Contracts/Attempt/AttemptDtos.cs:34`.

### 7.3 Wire shape per type

See §3 master table.

### 7.4 Reset on autosave (documented behaviour, not a bug)

`AttemptService.Autosave` (line 337-338) sets `IsCorrect = null` and `AwardedPoints = null` for any changed answer. The intent: a partial edit means the previous score is stale; Submit will recompute. Reviewing mid-test shows no score (expected).

### 7.5 FE hook

`useDebouncedAutoSave` (`langfens-fe-app/src/app/utils/hook.ts:74-115`):
- `run(answers, buildSectionId, buildTextAnswer)` — 2000ms debounce
- `saveNow(...)` — immediate flush, called before Submit
- `cancel()` — clear pending timer (called on Submit)

`buildAnswerPayload` (D4 update):
```ts
type QA = Record<string, UserAnswerValue>;  // was Record<string, string>
buildAnswerPayload(answers, buildSectionId, buildTextAnswer?) {
  return {
    answers: Object.entries(answers).map(([qid, value]) => {
      // 1. JSON-encoded object (completion / matching / classification)
      if (value && typeof value === "object" && !Array.isArray(value)) {
        return { questionId: qid, sectionId: buildSectionId(qid) ?? "",
                 selectedOptionIds: [], textAnswer: JSON.stringify(value) };
      }
      // 2. JSON-encoded array (flow chart ordering)
      if (Array.isArray(value)) {
        return { questionId: qid, sectionId: buildSectionId(qid) ?? "",
                 selectedOptionIds: [], textAnswer: JSON.stringify(value) };
      }
      // 3. String — try GUID, else raw text
      if (/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(value)) {
        return { questionId: qid, sectionId: buildSectionId(qid) ?? "",
                 selectedOptionIds: [value], textAnswer: null };
      }
      return { questionId: qid, sectionId: buildSectionId(qid) ?? "",
               selectedOptionIds: [], textAnswer: value || null };
    }),
    clientRevision: Date.now(),
  };
}
```

**Migration §11.6:** Update `buildTextAnswer` in `TestV2Runner.tsx:166-180` — remove the per-type guard, since the hook now handles all types uniformly.

---

## 8. FE Dispatch Contract

### 8.1 Live runner (canonical)

File: `langfens-fe-app/src/app/do-test/[skill]/[attemptId]/page.tsx:123-124` — returns `<TestV2Runner>` for reading/listening.

Dispatch site: `_components/QuestionCard.tsx:45-170`.

| Type branch | Lines | Card file |
|---|---|---|
| `MULTIPLE_CHOICE_SINGLE`, `_SINGLE_IMAGE` | 48-61 | `cards/McqCard.tsx` |
| `MULTIPLE_CHOICE_MULTIPLE` | 63-73 | `cards/McqCard.tsx` (multi mode) |
| `TRUE_FALSE_NOT_GIVEN`, `YES_NO_NOT_GIVEN` | 75-88 | `cards/TrueFalseCard.tsx` |
| Completion family (incl. Diagram, Map) | 90-109 | `cards/CompletionCard.tsx` |
| Matching family (incl. Classification) | 111-128 | `cards/MatchingCard.tsx` |
| `SHORT_ANSWER` | 130-139 | `cards/ShortAnswerCard.tsx` |
| `FLOW_CHART` | 154-163 | `cards/FlowChartCard.tsx` |
| (fallback) | 165-170 | "Question type: ..." |

### 8.2 Result review (canonical)

File: `langfens-fe-app/src/app/attempts/[attemptId]/page.tsx:91` — returns `<ResultV3Review>`.

`ResultV3Review.tsx` renders `<QuestionCardV3 mode="review">` per question, fed by `resultApi.ts` which merges:
- `GET /attempt/getresult/{id}` → `AttemptResultData.answers[]` (per-question correctness + user answer)
- `GET /attempt/{id}` → `AttemptStartData.paper` (full paper, sanitized)
- Optionally `GET /internal/exams/{examId}/delivery?showAnswers=true` → fills `correctAnswerText`

### 8.3 Pre-attempt (placement)

`/placement/[attemptId]/page.tsx` — currently uses legacy `QuestionPanel`. **Migration §11.5** replaces with `<TestV2Runner>`.

### 8.4 Deprecated paths

| Path | Status | Migration |
|---|---|---|
| `/test-v3/[examId]` (`app/test-v3/*`) | DEPRECATE | Redirect to `/do-test/...` flow |
| `components/exam-v3/*` | DEPRECATE | Delete after `TestV2Runner` covers all types |
| `app/do-test/[skill]/[attemptId]/components/QuestionComponentRegistry.tsx` | DEPRECATE | Delete after legacy screens removed |
| `app/do-test/[skill]/[attemptId]/components/common/QuestionPanel.tsx` | DEPRECATE | Delete |
| `app/do-test/[skill]/[attemptId]/components/reading/*` | DEPRECATE | Delete; live cards already in `_components/cards/` |

---

## 9. Cross-Cutting Rules

### 9.1 TextNorm normalization (`GraderHelper.cs:26-130`)

Applied to `userText` and each `BlankAcceptTexts` entry before equality check:
- Unicode decomposition (`Form D`)
- Lowercase
- Trim
- Number-word equivalence (`"two"` == `"2"`, `"a hundred"` == `100`, etc.)
- Contraction stripping (`"don't"` == `"dont"`)
- British → American spelling (selected common pairs)
- Whitespace collapse

**Generator must** apply the same normalization to candidate answers before storing in `BlankAcceptTexts` / `ShortAnswerAcceptTexts`. Otherwise the stored keys may not match what the user is expected to type.

### 9.2 Regex auto-anchoring

User-provided regex in `BlankAcceptRegex` / `ShortAnswerAcceptRegex` is auto-wrapped with `^...$` if not already anchored (`Grader.cs:108, 154, 206`).

### 9.3 Re-grade in-memory on GetResult

`AttemptService.GetResult` (line 791-819) re-runs grader logic against stored answers and returns recomputed values. The DB rows are **not** mutated; this fixes legacy rows where FE routed GUID into `TextAnswer` (pre-`SingleChoiceGrader` shim).

This remains in place even after D4 fixes the FE — it's a defensive layer for any future schema drift.

### 9.4 Word-count constraint enforcement (D6)

Implemented in `AttemptService.Submit` after autosave flush, before grader:
1. For each answer, parse `PromptMd` for `NO MORE THAN N WORDS [AND/OR A NUMBER]` pattern
2. If matched, validate each TextAnswer blank against `n` (and presence of a numeric token if "AND/OR A NUMBER")
3. Violation → `AwardedPoints=0`, `IsCorrect=false`, `Feedback=<message>`

### 9.5 Regex logging (D7)

`CompletionGrader` / `ShortAnswerGrader` log warning via `ILogger.LogWarning` when regex parse fails, including question UUID and raw regex string. The question receives `NeedsManualReview=true` if all accepts for a blank fail to parse.

---

## 10. JSON Import Template

File: `templates/exam-import.schema.json` (canonical) — to be updated per §11.7.

Each `Question` object:

```jsonc
{
  "id": "<uuid>",
  "idx": 1,
  "type": "MULTIPLE_CHOICE_SINGLE",       // one of the 19 enum values
  "skill": "READING",
  "difficulty": 2,
  "promptMd": "According to the passage, ...",
  "explanationMd": "...",

  // === Choice family (1–5) ===
  "options": [
    { "id": "<uuid>", "idx": 0, "contentMd": "A. ...", "isCorrect": false, "imageUrl": null, "altText": null }
    // ...
  ],

  // === Completion family (6–10, 12, 13) — pick one or both ===
  "blankAcceptTexts": { "0": ["polypropylene", "polypropylene nets"], "1": ["underground"] },
  "blankAcceptRegex": { "0": ["poly.+" ] },

  // === ShortAnswer (11) ===
  "shortAnswerAcceptTexts": ["21", "twenty one"],
  "shortAnswerAcceptRegex": [],

  // === Matching family (14–18) ===
  "matchPairs": {
    "para-A": ["iii", "iii. The Spread of Coffee"],
    "para-B": ["i",   "i. Origins"]
  },

  // === FlowChart (19) ===
  "orderCorrects": ["warm-intake", "evaporator-dome", "turbine-hall", "condenser-bay", "return-line"]
}
```

Per-type required field matrix (validated by JSON schema + admin endpoint per D5):

| Type | Must have | Must NOT have |
|---|---|---|
| MCQ single / TFNG / YNNG / MCQ-single-image | `options[]` | blankAccept*, matchPairs, orderCorrects, shortAnswerAccept* |
| MCQ multiple | `options[]` | same |
| Completion (6 types) | `blankAcceptTexts` | options, matchPairs, orderCorrects, shortAnswerAccept* |
| ShortAnswer | `shortAnswerAcceptTexts` | options, blankAccept*, matchPairs, orderCorrects |
| Matching (5 types) | `matchPairs` | options (allowed for Heading/Features), blankAccept*, orderCorrects, shortAnswerAccept* |
| FlowChart | `orderCorrects` | options, blankAccept*, matchPairs, shortAnswerAccept* |

---

## 11. Migration Plan

### 11.1 Remove `FLOW_CHART_COMPLETION` and `AUDIO_RESPONSE` from enum

1. Delete constants from `QuestionType.cs`
2. Update `AnswerValidator.IsSingleChoice` (no change needed — neither was there)
3. Update `QuestionGraderRegistration.cs` — remove `FlowChartCompletion` from `FlowChartGraderRegistration.SupportedTypes` and `AudioResponse` from `ShortAnswerGraderRegistration.SupportedTypes`
4. Update FE `QuestionType` enum (`langfens-fe-app/src/app/admin/_lib/types.ts:40-64`) — same deletions
5. Remove entries from FE `QuestionCard.tsx` dispatcher (lines 141-152 for FlowChartCompletion)
6. Update `templates/exam-import.schema.json` enum to remove both values
7. Add EF migration to delete any rows with these enum values (cleanup)

### 11.2 Fix `ReadingSeeder` q9 (`YES_NO_NOT_GIVEN`)

Add third option `"C. Not Given"` at Idx=2 with `IsCorrect=false` (line 225-237).

### 11.3 Migrate `ReadingSeeder` q10 (`FLOW_CHART_COMPLETION` → `SUMMARY_COMPLETION`)

Change `Type = QuestionType.FlowChartCompletion` → `Type = QuestionType.SummaryCompletion`. The `BlankAcceptTexts` already present is the correct storage for the new type. Remove `OrderCorrects = null`.

### 11.4 Per-type storage validation (D5)

Add validation block in `AdminQuestion_Service.AddAsync` (line 37-93) and `UpdateAsync` (line 95-142). Reject with HTTP 400 + clear error message.

### 11.5 Retire legacy FE stack

1. Replace `placement/[attemptId]/page.tsx`'s `<QuestionPanel>` with `<TestV2Runner>`
2. Replace `attempts/[attemptId]/ResultReviewScreen.tsx` with `ResultV3Review`
3. Delete `components/QuestionComponentRegistry.tsx`
4. Delete `components/common/QuestionPanel.tsx`
5. Delete `components/reading/*` (all 15 files)
6. Delete `components/exam-v3/*` (used only by `/test-v3/[examId]`)
7. Delete `app/test-v3/[examId]/page.tsx`
8. Add redirect: `/test-v3/[examId]` → `/exams/[examId]`

### 11.6 Update autosave hook for `UserAnswerValue` (D4)

1. Change `QA = Record<string, string>` to `QA = Record<string, UserAnswerValue>`
2. Rewrite `buildAnswerPayload` per §7.5
3. Remove `buildTextAnswer` from `TestV2Runner.tsx:166-180` (no longer needed — hook handles all types)

### 11.7 Update import JSON schema

Add `additionalProperties: false` discipline per D5. Per-type `required` matrix per §10. Update enum list to remove deprecated values (§11.1).

### 11.8 Word-count enforcement (D6)

Add `WordLimitRule` parser + validator in `AttemptService.Submit`. Place before grader loop (line 502).

### 11.9 Regex logging (D7)

Inject `ILogger` into `CompletionGrader` / `ShortAnswerGrader` constructors. Replace silent `catch {}` blocks with `catch (Exception e) { _logger.LogWarning(...); }`.

### 11.10 Cleanup `MatchingHeadingGrader` for all-or-nothing

`Grader.cs:267-281` already returns `score = isAllMatched ? points : 0m`. **No change needed** — matches D1. Update `Feedback` strings to be specific:
- "One or more pairs do not match" (was "got=3, total=5")

### 11.11 Simplify `FlowChartGrader` for exact match

Replace LCS with `SequenceEqual` after `NormNode`. Delete `LCS` static method.

---

## 12. Open Items

| # | Question | Owner | Blocker? |
|---|---|---|---|
| 12.1 | Should `CompletionCard` also support non-JSON legacy shapes (single string, newline-separated) for back-compat with old autosaved answers? | FE | No — old answers can be re-submitted to JSON-encode |
| 12.2 | `MULTIPLE_CHOICE_SINGLE_IMAGE` rendering: inline image alongside text, or replace text? | FE | Yes if generator needs to know |
| 12.3 | `MATCHING_INFORMATION` word-list variant — should no-repeat rule be enforced server-side? (i.e., reject if user picks same word twice) | BE | Yes — clarify before implementing |
| 12.4 | `QuestionPoints` configurable per question? (Currently hardcoded 1.) | All | Yes if generator wants 2-mark questions |
| 12.5 | Band-score table — does the existing 40-question band mapping hold after we drop to 19 types? | Attempt-service | No — only if total question count changes |
| 12.6 | Should `ExplanationMd` be shown pre-submit or only post-submit? | FE | No — current behaviour (post-submit only) is correct |
| 12.7 | Migration of existing `paperJson` rows in `attempts` table — do we need a one-time data migration for the dropped enum values? | Attempt-service | Yes if any historical attempts reference FLOW_CHART_COMPLETION or AUDIO_RESPONSE |

---

## 13. Cross-References (file:line)

| Concern | Backend file | Frontend file |
|---|---|---|
| `QuestionType` enum | `services/_shared/Shared.PublicContracts/Contracts/Exam/Enums/QuestionType.cs` | `langfens-fe-app/src/app/admin/_lib/types.ts:40-64` |
| `ExamQuestion` entity | `services/exam-service/Domains/Entities/ExamQuestion.cs` | (consumed via paperJson) |
| `ExamOption` entity | `services/exam-service/Domains/Entities/ExamOption.cs` | (consumed via paperJson) |
| `AttemptAnswer` entity | `services/attempt-service/Domain/Entities/AttemptAnswer.cs` | (consumed via getresult) |
| All graders | `services/attempt-service/Features/Helpers/Grader.cs` | (BE-authoritative) |
| Grader registry | `services/attempt-service/Features/Helpers/QuestionGraderRegistration.cs` | (n/a) |
| Answer-key compile | `services/attempt-service/Features/Helpers/BuildQuestionIdSet.cs` | (n/a) |
| `TextNorm` | `services/attempt-service/Features/Helpers/GraderHelper.cs:26-130` | (n/a) |
| `AnswerValidator` | `services/attempt-service/Features/Helpers/GraderHelper.cs:323-357` | (n/a) |
| Snapshot sanitizer | `services/_shared/Shared.PublicContracts/Contracts/Exam/InternalExamDto/SharedInternalExamDto.cs:78-104` + `services/attempt-service/Features/Helpers/ExamGateway.cs:47-69` | (consumed) |
| Autosave endpoint | `services/attempt-service/Features/Attempt/AttemptEndpoint/AttemptService.cs:222-362` | `langfens-fe-app/src/app/utils/hook.ts:74-115` |
| Autosave payload builder | (BE contract: `AnswerItem`) | `langfens-fe-app/src/app/utils/hook.ts:8-72` |
| Submit endpoint | `services/attempt-service/Features/Attempt/AttemptEndpoint/AttemptService.cs:382-710` | `langfens-fe-app/src/app/do-test/[skill]/[attemptId]/_components/TestV2Runner.tsx:215-249` |
| Result endpoint | `services/attempt-service/Features/Attempt/AttemptEndpoint/AttemptService.cs:712-1058` | `langfens-fe-app/src/app/attempts/_lib/resultApi.ts` |
| Live runner | (n/a) | `langfens-fe-app/src/app/do-test/[skill]/[attemptId]/_components/TestV2Runner.tsx` |
| Question dispatcher | (n/a) | `langfens-fe-app/src/app/do-test/[skill]/[attemptId]/_components/QuestionCard.tsx:45-170` |
| Result review | (n/a) | `langfens-fe-app/src/app/attempts/_components/ResultV3Review.tsx` |
| Import schema | (admin-only) | `templates/exam-import.schema.json` |

---

## 14. Generator Author Checklist

Before emitting a question, the generator MUST verify:

- [ ] `Type` is one of the 19 enum values
- [ ] All required fields per D5 are present (and forbidden fields are absent)
- [ ] If `Type` is choice-family: `Options` count ≥ 2 and exactly one `IsCorrect=true` (or N for MCQ-multiple, 3 for TFNG/YNNG)
- [ ] If `Type` is completion-family: every `blankId` in `BlankAcceptTexts` corresponds to a placeholder in `PromptMd` (either `[N]` bracket or `___` underscore)
- [ ] If `Type` is matching-family: every leftKey in `MatchPairs` is unique; every rightKey is unique within the question
- [ ] If `Type` is `FLOW_CHART`: every `OrderCorrects` entry matches `^[a-z0-9]+(?:-[a-z0-9]+)*$`; auto-generated `FlowChartNodes` will replace `-` with space
- [ ] If `PromptMd` contains "NO MORE THAN N WORDS": the generator's candidate answers per blank do not exceed N words
- [ ] `BlankAcceptTexts` values are normalized via `TextNorm.Normalize` before storage
- [ ] `BlankAcceptRegex` values are valid .NET regex (no malformed patterns)
- [ ] `Difficulty` ∈ [1, 5]

Before emitting an exam, the generator MUST verify:

- [ ] Total question count per skill matches IELTS convention (Reading: 40; Listening: 40)
- [ ] Type distribution follows the canonical IELTS mix per skill (see IELTS Official Practice Materials band descriptors)
- [ ] Each section's `Idx` is unique within the section
- [ ] Each `GroupId` (if used) maps to a valid `ExamQuestionGroup`

---

## 15. Versioning

| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-09-08 | Initial draft, pending sign-off |

This document supersedes `docs/question-type-reports/INDEX.md` and the 19 per-type JSON files upon sign-off. Until then, those files remain as historical evidence.
