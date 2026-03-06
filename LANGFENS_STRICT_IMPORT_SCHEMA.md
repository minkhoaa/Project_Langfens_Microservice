# LANGFENS STRICT IMPORT SCHEMA
> **Source of Truth — Generated March 5, 2026**
> Reverse-engineered from:
> - `scripts/crawler/exam-import.schema.json` ← **AUTHORITATIVE** (includes MULTIPLE_CHOICE_MULTIPLE)
> - `templates/exam-import.schema.json` (older, missing MCQ_MULTIPLE — do NOT use for new data)
> - `.agent/workflows/ielts-data-format.md` (31 strict rules)
> - `.agent/workflows/hints/` (type-by-type schemas)
> - `scripts/pipeline_v2/models.py` (Pydantic validators)
> - `scripts/pipeline_v2/invariants.py` (hard constraints)
> - `scripts/pipeline_v2/schema_enforcer.py` (enforcement logic)
> - `deploy/seeds/` (real SQL seeds as ground truth)

---

## ⚠️ PRIME DIRECTIVE

> **All future scraping scripts MUST map scraped HTML directly into this exact JSON structure.**
> **Any crawled data that fails validation against `exam-import.schema.json` MUST be rejected or sent to a dead-letter queue.**
> Violations cause: **Frontend will not render** and **Backend grader will fail silently**.

---

## 1. STRICT RULESET (Root-Level Constraints)

Derived directly from `exam-import.schema.json` → `additionalProperties: false` on ALL objects.

### 1.1 Root Object
- ✅ **REQUIRED**: `schemaVersion` (string, pattern `^\d+\.\d+\.\d+$`, e.g. `"1.0.0"`)
- ✅ **REQUIRED**: `exams` (array, minItems: 1)
- ❌ No extra fields allowed (`additionalProperties: false`)

### 1.2 Exam Object
| Field | Type | Required | Constraints |
|-------|------|----------|-------------|
| `id` | string (UUID) | ✅ | RFC 4122 UUID format |
| `slug` | string | ✅ | Pattern: `^[a-z0-9]+(?:-[a-z0-9]+)*$`, minLen 3, maxLen 128 |
| `title` | string | ✅ | minLen 1 |
| `category` | string enum | ✅ | `IELTS` \| `TOEIC` \| `VSTEP` \| `PLACEMENT` |
| `level` | string enum | ✅ | `A1` \| `A2` \| `B1` \| `B2` \| `C1` \| `C2` |
| `durationMin` | integer | ✅ | minimum: 1 |
| `sections` | array | ✅ | minItems: 1 |
| `descriptionMd` | string \| null | ❌ optional | Markdown |
| `status` | string enum | ❌ optional | `DRAFT` \| `PUBLISHED` \| `ARCHIVED` (default: `DRAFT`) |

### 1.3 Section Object
| Field | Type | Required | Constraints |
|-------|------|----------|-------------|
| `id` | string (UUID) | ✅ | RFC 4122 UUID |
| `idx` | integer | ✅ | minimum: 1 (1-based) |
| `title` | string | ✅ | minLen 1 |
| `questions` | array | ✅ | minItems: 1 |
| `instructionsMd` | string \| null | ❌ optional | Markdown; question group headers go here |
| `audioUrl` | string \| null | ❌ optional | Absolute URL to .mp3 (Listening only) |
| `transcriptMd` | string \| null | ❌ optional | Full transcript in Markdown (Listening only) |

### 1.4 Question Object — ALL 12 FIELDS REQUIRED
| Field | Type | Required | Constraints |
|-------|------|----------|-------------|
| `id` | string (UUID) | ✅ | RFC 4122 UUID |
| `idx` | integer | ✅ | 1–50 (from Pydantic: `ge=1, le=50`) |
| `type` | string enum | ✅ | See Section 3 — 19 valid values |
| `skill` | string enum | ✅ | `READING` \| `LISTENING` \| `WRITING` \| `SPEAKING` |
| `difficulty` | integer | ✅ | minimum: 1 (1=easy, 2=medium, 3=hard) |
| `promptMd` | string | ✅ | minLen 1; **NO leading number** (e.g. ❌ "1. Statement") |
| `options` | array | ✅ | `[]` if not applicable; non-null |
| `blankAcceptTexts` | object \| null | ✅ | `{}` if not applicable; keys → `string[]` |
| `blankAcceptRegex` | object \| null | ✅ | `{}` if not applicable; keys → `string[]` |
| `matchPairs` | object \| null | ✅ | `{}` if not applicable; keys → `string[]` |
| `orderCorrects` | array \| null | ✅ | `[]` if not applicable; items: slug-pattern `^[a-z0-9]+(?:-[a-z0-9]+)*$` |
| `shortAnswerAcceptTexts` | array \| null | ✅ | `[]` if not applicable |
| `shortAnswerAcceptRegex` | array \| null | ✅ | `[]` if not applicable |
| `explanationMd` | string \| null | ❌ optional | Markdown solution/rationale |

### 1.5 Option Object
| Field | Type | Required | Constraints |
|-------|------|----------|-------------|
| `id` | string (UUID) | ✅ | RFC 4122 UUID |
| `idx` | integer | ✅ | minimum: 1 (1-based) |
| `contentMd` | string | ✅ | minLen 1; see format rules |
| `isCorrect` | boolean | ✅ | exactly 1 `true` for single-choice types |

---

## 2. THE 31 STRICT RULES (Full List)

### RULE 1 — Empty vs Null for Answer Fields
```
For non-applicable answer fields, use EMPTY COLLECTIONS, NOT null:
✅ "blankAcceptTexts": {}       (not null)
✅ "blankAcceptRegex": {}       (not null)
✅ "matchPairs": {}             (not null)
✅ "orderCorrects": []          (not null)
✅ "shortAnswerAcceptTexts": [] (not null)
✅ "shortAnswerAcceptRegex": [] (not null)
✅ "options": []                (not null)

Exception: null is valid per schema, but {} / [] is preferred by importer.
```

### RULE 2 — Blank Marker (CRITICAL — Frontend Only Recognizes This)
```javascript
// Frontend detection: /_{3,}/g
✅ _______   (7 underscores)
✅ ____      (4 underscores)
✅ ___       (3 underscores)
❌ ...       (dots — ignored by frontend)
❌ [blank]   (ignored)
❌ (blank)   (ignored)
❌ ( )       (ignored)
```

### RULE 3 — blankAcceptTexts Key Convention
```
For COMPLETION types: keys = positional blank index (0-based string)
  "blankAcceptTexts": {"0": ["answer1"], "1": ["answer2"]}

For DIAGRAM_LABEL / MAP_LABEL: keys = question idx number
  "blankAcceptTexts": {"29": ["label1"], "30": ["label2"]}
```

### RULE 4 — matchPairs Key Conventions
```
MATCHING_INFORMATION:  {"info-q{idx}": ["LETTER"]}
MATCHING_HEADING:      {"section-{letter}": ["roman", "roman. Full heading"]}
MATCHING_FEATURES:     {"feature-q{idx}": ["Full Name", "LETTER"]}
MATCHING_ENDINGS:      {"ending-q{idx}": ["LETTER"]}
CLASSIFICATION:        {"class-q{idx}": ["LETTER"]}
MAP_LABEL:             {"info-q{idx}": ["LETTER"]}
```

### RULE 5 — Options contentMd Format
```
TFNG / YNNG:       Plain text — "TRUE", "FALSE", "NOT GIVEN", "YES", "NO"
MCQ_SINGLE:        "A. Full option text" (Letter + dot + space + text)
MCQ_MULTIPLE:      "A. Full option text" (same)
MATCHING_HEADING:  "i. Full heading text" (roman + dot + space + text)
CLASSIFICATION:    "A. Category name"
```

### RULE 6 — promptMd Number Prefix Forbidden
```
✅ "Which paragraph mentions climate change?"
❌ "1. Which paragraph mentions climate change?"
❌ "Question 28: What does the writer mean?"
```
Frontend auto-renders: `{idx}. {promptMd}` — adding number = double display.

### RULE 7 — isCorrect Count Rules
```
TFNG, YNNG, MCQ_SINGLE, MCQ_IMAGE, CLASSIFICATION → exactly 1 isCorrect=true
MCQ_MULTIPLE → 2 or more isCorrect=true
MATCHING_HEADING → exactly 1 isCorrect=true
All others → options=[] (no isCorrect needed)
```

### RULE 8 — Options Minimum Counts (from validate.py)
```
TFNG / YNNG:          exactly 3 options
MCQ_SINGLE:           >= 2 options (typically 4)
MCQ_MULTIPLE:         >= 3 options
MATCHING_HEADING:     >= 5 options (full heading bank i–x)
```

### RULE 9 — Slug Format
```
Pattern: ^[a-z0-9]+(?:-[a-z0-9]+)*$
✅ "ielts-reading-a-new-ice-age"
✅ "mini-ielts-reading-section-3"
❌ "IELTS Reading" (uppercase, spaces)
❌ "ielts_reading" (underscores)
❌ "ielts-reading-" (trailing dash)
```

### RULE 10 — Question Sequence Gap (from models.py)
```python
gap = indices[i+1] - indices[i]
if gap > 5:
    raise ValueError("Large gap — section break max gap is 5")
✅ Q1, Q2, Q3, Q4, Q5
✅ Q1, Q2, Q6 (gap=4, section break OK)
❌ Q1, Q2, Q20 (gap=18, INVALID)
```

### RULE 11 — Passage Paragraph Labels Format
```markdown
✅ CORRECT:
**Paragraph A.**
First paragraph content starts here on a new line...

**Paragraph B.**
Second paragraph content...

❌ WRONG:
A. Content (not bold)
A) Content (wrong bracket)
**A** Content (no dot)
**Paragraph A.** Content on same line (no newline)
```

### RULE 12 — MATCHING_HEADING: Options = Full Heading Bank
```
All headings i–x (or i–xi) MUST be in options[].
Passage MUST NOT contain the headings list.
```

### RULE 13 — MATCHING_INFORMATION: options Always Empty
```
"options": []   ✅
"options": [{"contentMd": "A. Paragraph A..."}]   ❌ VIOLATION
```

### RULE 14 — Completion Prompt Must Have Blanks
```
Every SUMMARY_COMPLETION / NOTE_COMPLETION / TABLE_COMPLETION /
FORM_COMPLETION / SENTENCE_COMPLETION / DIAGRAM_LABEL prompt
MUST contain at least one _{3,} pattern.

If blank count ≠ blankAcceptTexts key count → REJECT
```

### RULE 15 — SHORT_ANSWER vs COMPLETION
```
SHORT_ANSWER:
  - Single blank in prompt: "When did it happen? _______"
  - Answer: shortAnswerAcceptTexts: ["1982"]
  - blankAcceptTexts: {}

*_COMPLETION (multi-blank):
  - Multiple blanks: "pays _______ per week for _______"
  - Answer: blankAcceptTexts: {"0": ["$68.50"], "1": ["utilities"]}
  - shortAnswerAcceptTexts: []
```

### RULE 16 — FLOW_CHART orderCorrects Key Format
```
items pattern: ^[a-z0-9]+(?:-[a-z0-9]+)*$
✅ "warm-intake", "evaporator-dome", "turbine-hall"
❌ "Warm Intake" (uppercase, spaces)
❌ "warm_intake" (underscores)
```

### RULE 17 — Frontend HeadingDropdown Value Extraction
```tsx
value = opt.contentMd.split(".")[0].trim()  // extracts "i", "ii", "v"
```
```
✅ "i. Where to buy the best Echinacea" → value="i"
❌ "Where to buy..." → value="" (BROKEN — no dot)
❌ "i) Where to buy..." → value="i)" (WRONG format)
```

### RULE 18 — MatchingLetter Input Validation
```
Frontend only accepts: A–J (uppercase, single letter)
❌ a–j (lowercase rejected)
❌ K–Z (out of range rejected)
❌ numbers (rejected)
→ matchPairs answers MUST be A–J only
```

### RULE 19 — TFNG/YNNG Prompt = Statement Only
```
✅ "Scientists believe the universe is expanding."
❌ "A. Scientists believe... B. Scientists doubt..."
❌ "TRUE/FALSE: Scientists believe..."
```

### RULE 20 — JSON Newlines Must Be Escaped
```json
✅ "promptMd": "Line 1\\nLine 2"
❌ "promptMd": "Line 1
Line 2"
```

### RULE 21 — instructionsMd Question Group Header Format
```markdown
✅ CORRECT:
**Questions 1–6:**
The passage has eight paragraphs **A–H**.
Which paragraph contains the following information?
Write the correct letter **A–H** in boxes 1–6.

---

**Questions 7–9:**
Choose the correct letter **A**, **B**, **C** or **D**.
```

### RULE 22 — MATCHING_HEADING promptMd Length
```
Max ~100 chars. Short reference like:
✅ "Choose the correct heading for Section C"
✅ "Section D"
❌ Full paragraph (>100 chars)
```

### RULE 23 — Answer Consistency Rule
```
For MATCHING_HEADING:
  matchPairs answer value MUST exist in options[].contentMd.split(".")[0]

For MCQ/TFNG/YNNG:
  There MUST be exactly 1 option with isCorrect=true
  0 correct options → ungradeable
  2+ correct options for single-choice → ambiguous
```

### RULE 24 — Passage Must Be Complete
```
Full passage: >= 500 words
✅ Extract full reading passage
❌ Summary completion text only (100-200 words) — WRONG extraction
```

### RULE 25 — Special Characters in SQL Seeds
```sql
✅ 'snake''s oil'     -- apostrophe doubled
✅ E'line1\\nline2'   -- E prefix for escape strings
❌ 'snake's oil'      -- SQL error
```

### RULE 26 — Status Default
```
Default: "DRAFT" (not "PUBLISHED")
Only set "PUBLISHED" for validated, complete exams.
```

### RULE 27 — Multiple Valid Answers
```
Always include case variants and alternative spellings:
✅ "blankAcceptTexts": {"0": ["one-sixth", "One-Sixth", "one sixth"]}
✅ "blankAcceptTexts": {"1": ["16th century", "16Th Century", "sixteenth century"]}
```

### RULE 28 — Optional Words Must Be Expanded
```
Source: "(commemorative) coin" → expand to two valid answers:
✅ ["coin", "commemorative coin"]

Source: "colour // color" → split by "//":
✅ ["colour", "color"]
```

### RULE 29 — CLASSIFICATION Must Have Both options AND matchPairs
```json
{
  "type": "CLASSIFICATION",
  "options": [
    {"idx": 1, "contentMd": "A. Category One", "isCorrect": false},
    {"idx": 2, "contentMd": "B. Category Two", "isCorrect": true}
  ],
  "matchPairs": {"class-q20": ["B"]}
}
```

### RULE 30 — Section passageMd vs instructionsMd
```
instructionsMd = Question group headers (Questions 1-6, Questions 7-9...)
                 The full passage text goes here for Reading sections.

audioUrl       = Required for Listening sections, null for Reading.
```

### RULE 31 — UUID Must Be Pre-Generated
```
All id fields MUST be valid RFC 4122 UUIDs pre-generated by pipeline.
❌ Empty string ""
❌ Sequential integers "1", "2"
❌ Short hashes "abc123"
✅ "03cc85b0-accd-4fd9-a6e1-7e46b8533c4d"
```

---

## 3. QUESTION TYPE → REQUIRED FIELDS MATRIX

| # | Type | options | blankAcceptTexts | matchPairs | orderCorrects | shortAnswerAcceptTexts |
|---|------|---------|-----------------|------------|---------------|----------------------|
| 1 | `TRUE_FALSE_NOT_GIVEN` | ✅ exactly 3 | `{}` | `{}` | `[]` | `[]` |
| 2 | `YES_NO_NOT_GIVEN` | ✅ exactly 3 | `{}` | `{}` | `[]` | `[]` |
| 3 | `MULTIPLE_CHOICE_SINGLE` | ✅ 3–5 | `{}` | `{}` | `[]` | `[]` |
| 4 | `MULTIPLE_CHOICE_MULTIPLE` | ✅ 3–5 (2+ correct) | `{}` | `{}` | `[]` | `[]` |
| 5 | `MULTIPLE_CHOICE_SINGLE_IMAGE` | ✅ 3–5 | `{}` | `{}` | `[]` | `[]` |
| 6 | `CLASSIFICATION` | ✅ categories | `{}` | ✅ `class-q{idx}` | `[]` | `[]` |
| 7 | `SHORT_ANSWER` | `[]` | `{}` | `{}` | `[]` | ✅ strings |
| 8 | `SUMMARY_COMPLETION` | `[]` | ✅ `{"0":[], "1":[]}` | `{}` | `[]` | `[]` |
| 9 | `TABLE_COMPLETION` | `[]` | ✅ indexed keys | `{}` | `[]` | `[]` |
| 10 | `NOTE_COMPLETION` | `[]` | ✅ indexed keys | `{}` | `[]` | `[]` |
| 11 | `FORM_COMPLETION` | `[]` | ✅ indexed keys | `{}` | `[]` | `[]` |
| 12 | `SENTENCE_COMPLETION` | `[]` | ✅ indexed keys | `{}` | `[]` | `[]` |
| 13 | `DIAGRAM_LABEL` | `[]` | ✅ `{qIdx:[]}` | `{}` | `[]` | `[]` |
| 14 | `MAP_LABEL` | `[]` | ✅ `{qIdx:[]}` | `{}` | `[]` | `[]` |
| 15 | `MATCHING_HEADING` | ✅ all i–x | `{}` | ✅ `section-{letter}` | `[]` | `[]` |
| 16 | `MATCHING_INFORMATION` | `[]` | `{}` | ✅ `info-q{idx}` | `[]` | `[]` |
| 17 | `MATCHING_FEATURES` | `[]` | `{}` | ✅ `feature-q{idx}` | `[]` | `[]` |
| 18 | `MATCHING_ENDINGS` | `[]` | `{}` | ✅ `ending-q{idx}` | `[]` | `[]` |
| 19 | `FLOW_CHART` | `[]` | `{}` | `{}` | ✅ slug-array | `[]` |

---

## 4. THE "HOLY GRAIL" JSON TEMPLATE

A complete, schema-valid IELTS Reading + Listening exam demonstrating all major question types.

```json
{
  "schemaVersion": "1.0.0",
  "exams": [
    {
      "id": "ec95f0a9-952e-425a-83d4-5c2c22f958cc",
      "slug": "ielts-reading-a-new-ice-age",
      "title": "IELTS Reading - A New Ice Age",
      "descriptionMd": "IELTS Academic Reading Practice Test. 13 questions covering MCQ, Matching Features, and Flow Chart.",
      "category": "IELTS",
      "level": "B2",
      "status": "DRAFT",
      "durationMin": 20,
      "sections": [
        {
          "id": "08902d29-64b3-4e93-b6c5-e92ac384147e",
          "idx": 1,
          "title": "Reading Passage 1 - A New Ice Age",
          "audioUrl": null,
          "transcriptMd": null,
          "instructionsMd": "**Questions 1–4:**\nChoose the correct letter, **A**, **B**, **C** or **D**.\n\n---\n\n**Questions 5–9:**\nMatch each statement with the correct person **A–D**.\n\n**A.** William Curry\n**B.** Bob Dickson\n**C.** Terrence Joyce\n**D.** Scientists generally\n\n---\n\n**Questions 10–13:**\nComplete the flow chart below.\nChoose **NO MORE THAN THREE WORDS** from the passage for each answer.\n\n---\n\n**Passage:**\n\n**Paragraph A.**\nWilliam Curry is a serious, sober climate scientist, not an art critic. But he has spent a lot of time perusing Emanuel Gottlieb Leutze's famous painting \"George Washington Crossing the Delaware\"...\n\n**Paragraph B.**\nBut it may again soon. And ice-choked scenes, similar to those immortalised by the 16th-century Flemish painter Pieter Brueghel the Elder, may also return to Europe...\n\n**Paragraph C.**\n\"It could happen in 10 years,\" says Terrence Joyce, who chairs the Woods Hole Physical Oceanography Department. \"Once it does, it can take hundreds of years to reverse.\"...\n\n**Paragraph D.**\nA drop of 5 to 10 degrees entails much more than simply bumping up the thermostat and carrying on...\n\n**Paragraph E.**\nThe reason for such huge effects is simple. A quick climate change wreaks far more disruption than a slow one...\n\n**Paragraph F.**\nPolitical changes since the last ice age could make survival far more difficult for the world's poor...\n\n**Paragraph G.**\nBut first things first. Isn't the earth actually warming? Indeed it is, says Joyce...\n\n**Paragraph H.**\nThe freshwater trend is major news in ocean-science circles. Bob Dickson, a British oceanographer who sounded an alarm at a February conference in Honolulu...\n\n**Paragraph I.**\nThe trend could cause a little ice age by subverting the northern penetration of Gulf Stream waters...\n\n**Paragraph J.**\nHaving given up its heat to the air, the now-cooler water becomes denser and sinks into the North Atlantic...",
          "questions": [
            {
              "id": "bd9aa6b8-9385-42f9-b741-954bc4111d01",
              "idx": 1,
              "type": "MULTIPLE_CHOICE_SINGLE",
              "skill": "READING",
              "difficulty": 2,
              "promptMd": "The writer uses paintings in the first paragraph to illustrate",
              "explanationMd": "Answer: B. The paintings show historical evidence of frozen rivers — climate change of the last two centuries.",
              "options": [
                { "id": "opt-1a", "idx": 1, "contentMd": "A. possible future climate change", "isCorrect": false },
                { "id": "opt-1b", "idx": 2, "contentMd": "B. climate change of the last two centuries", "isCorrect": true },
                { "id": "opt-1c", "idx": 3, "contentMd": "C. the river doesn't freeze in winter anymore", "isCorrect": false },
                { "id": "opt-1d", "idx": 4, "contentMd": "D. how George Washington led his troops across the river", "isCorrect": false }
              ],
              "blankAcceptTexts": {},
              "blankAcceptRegex": {},
              "matchPairs": {},
              "orderCorrects": [],
              "shortAnswerAcceptTexts": [],
              "shortAnswerAcceptRegex": []
            },
            {
              "id": "bd9aa6b8-9385-42f9-b741-954bc4111d02",
              "idx": 2,
              "type": "MULTIPLE_CHOICE_SINGLE",
              "skill": "READING",
              "difficulty": 2,
              "promptMd": "Which of the following do scientists believe to be possible?",
              "explanationMd": "Answer: A.",
              "options": [
                { "id": "opt-2a", "idx": 1, "contentMd": "A. The temperature may drop over much of the Northern Hemisphere", "isCorrect": true },
                { "id": "opt-2b", "idx": 2, "contentMd": "B. It will be colder than 12,000 years ago", "isCorrect": false },
                { "id": "opt-2c", "idx": 3, "contentMd": "C. The entire Northern Hemisphere will be covered in ice", "isCorrect": false },
                { "id": "opt-2d", "idx": 4, "contentMd": "D. Europe will look more like Lapland", "isCorrect": false }
              ],
              "blankAcceptTexts": {},
              "blankAcceptRegex": {},
              "matchPairs": {},
              "orderCorrects": [],
              "shortAnswerAcceptTexts": [],
              "shortAnswerAcceptRegex": []
            },
            {
              "id": "bd9aa6b8-9385-42f9-b741-954bc4111d03",
              "idx": 3,
              "type": "MULTIPLE_CHOICE_SINGLE",
              "skill": "READING",
              "difficulty": 2,
              "promptMd": "Why is it difficult for the poor to survive the next ice age?",
              "explanationMd": "Answer: D. Migration has become impossible because of closed borders.",
              "options": [
                { "id": "opt-3a", "idx": 1, "contentMd": "A. People don't live in tribes anymore", "isCorrect": false },
                { "id": "opt-3b", "idx": 2, "contentMd": "B. Politics are changing too fast today", "isCorrect": false },
                { "id": "opt-3c", "idx": 3, "contentMd": "C. Abrupt climate change causes people to live off their land", "isCorrect": false },
                { "id": "opt-3d", "idx": 4, "contentMd": "D. Migration has become impossible because of closed borders", "isCorrect": true }
              ],
              "blankAcceptTexts": {},
              "blankAcceptRegex": {},
              "matchPairs": {},
              "orderCorrects": [],
              "shortAnswerAcceptTexts": [],
              "shortAnswerAcceptRegex": []
            },
            {
              "id": "bd9aa6b8-9385-42f9-b741-954bc4111d04",
              "idx": 4,
              "type": "MULTIPLE_CHOICE_SINGLE",
              "skill": "READING",
              "difficulty": 3,
              "promptMd": "Freshwater entering the North Atlantic",
              "explanationMd": "Answer: C.",
              "options": [
                { "id": "opt-4a", "idx": 1, "contentMd": "A. comes from the Arctic alone", "isCorrect": false },
                { "id": "opt-4b", "idx": 2, "contentMd": "B. is melted by solar energy directly", "isCorrect": false },
                { "id": "opt-4c", "idx": 3, "contentMd": "C. has origins that are not fully understood", "isCorrect": true },
                { "id": "opt-4d", "idx": 4, "contentMd": "D. has increased the salinity of the ocean", "isCorrect": false }
              ],
              "blankAcceptTexts": {},
              "blankAcceptRegex": {},
              "matchPairs": {},
              "orderCorrects": [],
              "shortAnswerAcceptTexts": [],
              "shortAnswerAcceptRegex": []
            },
            {
              "id": "bd9aa6b8-9385-42f9-b741-954bc4111d05",
              "idx": 5,
              "type": "MATCHING_FEATURES",
              "skill": "READING",
              "difficulty": 2,
              "promptMd": "Match each statement with the correct person.\n**A.** William Curry\n**B.** Bob Dickson\n**C.** Terrence Joyce\n**D.** Scientists generally",
              "explanationMd": "Answer: C — Joyce is alarmed that Americans haven't taken the threat seriously.",
              "options": [],
              "blankAcceptTexts": {},
              "blankAcceptRegex": {},
              "matchPairs": { "feature-q5": ["Terrence Joyce", "C"] },
              "orderCorrects": [],
              "shortAnswerAcceptTexts": [],
              "shortAnswerAcceptRegex": []
            },
            {
              "id": "bd9aa6b8-9385-42f9-b741-954bc4111d06",
              "idx": 6,
              "type": "MATCHING_FEATURES",
              "skill": "READING",
              "difficulty": 2,
              "promptMd": "Match each statement with the correct person.\n**A.** William Curry\n**B.** Bob Dickson\n**C.** Terrence Joyce\n**D.** Scientists generally",
              "explanationMd": "Answer: B — Dickson described the Labrador Sea changes as the largest on record.",
              "options": [],
              "blankAcceptTexts": {},
              "blankAcceptRegex": {},
              "matchPairs": { "feature-q6": ["Bob Dickson", "B"] },
              "orderCorrects": [],
              "shortAnswerAcceptTexts": [],
              "shortAnswerAcceptRegex": []
            },
            {
              "id": "bd9aa6b8-9385-42f9-b741-954bc4111d07",
              "idx": 7,
              "type": "MATCHING_FEATURES",
              "skill": "READING",
              "difficulty": 2,
              "promptMd": "Match each statement with the correct person.\n**A.** William Curry\n**B.** Bob Dickson\n**C.** Terrence Joyce\n**D.** Scientists generally",
              "explanationMd": "Answer: A — Curry studies the painting to show historical evidence of freezing.",
              "options": [],
              "blankAcceptTexts": {},
              "blankAcceptRegex": {},
              "matchPairs": { "feature-q7": ["William Curry", "A"] },
              "orderCorrects": [],
              "shortAnswerAcceptTexts": [],
              "shortAnswerAcceptRegex": []
            },
            {
              "id": "bd9aa6b8-9385-42f9-b741-954bc4111d08",
              "idx": 8,
              "type": "MATCHING_FEATURES",
              "skill": "READING",
              "difficulty": 2,
              "promptMd": "Match each statement with the correct person.\n**A.** William Curry\n**B.** Bob Dickson\n**C.** Terrence Joyce\n**D.** Scientists generally",
              "explanationMd": "Answer: D — Scientists generally believe the Gulf Stream warms Europe.",
              "options": [],
              "blankAcceptTexts": {},
              "blankAcceptRegex": {},
              "matchPairs": { "feature-q8": ["Scientists generally", "D"] },
              "orderCorrects": [],
              "shortAnswerAcceptTexts": [],
              "shortAnswerAcceptRegex": []
            },
            {
              "id": "bd9aa6b8-9385-42f9-b741-954bc4111d09",
              "idx": 9,
              "type": "MATCHING_FEATURES",
              "skill": "READING",
              "difficulty": 3,
              "promptMd": "Match each statement with the correct person.\n**A.** William Curry\n**B.** Bob Dickson\n**C.** Terrence Joyce\n**D.** Scientists generally",
              "explanationMd": "Answer: C — Joyce says the Gulf Stream warming is not solely a European phenomenon.",
              "options": [],
              "blankAcceptTexts": {},
              "blankAcceptRegex": {},
              "matchPairs": { "feature-q9": ["Terrence Joyce", "C"] },
              "orderCorrects": [],
              "shortAnswerAcceptTexts": [],
              "shortAnswerAcceptRegex": []
            },
            {
              "id": "bd9aa6b8-9385-42f9-b741-954bc4111d10",
              "idx": 10,
              "type": "FLOW_CHART",
              "skill": "READING",
              "difficulty": 3,
              "promptMd": "Complete the flow chart. Choose **NO MORE THAN THREE WORDS** from the passage.\n\nArrange the following stages in the correct order as described in the passage:\n- warm-intake\n- evaporator-dome\n- turbine-hall\n- condenser-bay\n- return-line",
              "explanationMd": "Correct sequence: warm-intake → evaporator-dome → turbine-hall → condenser-bay → return-line",
              "options": [],
              "blankAcceptTexts": {},
              "blankAcceptRegex": {},
              "matchPairs": {},
              "orderCorrects": ["warm-intake", "evaporator-dome", "turbine-hall", "condenser-bay", "return-line"],
              "shortAnswerAcceptTexts": [],
              "shortAnswerAcceptRegex": []
            },
            {
              "id": "bd9aa6b8-9385-42f9-b741-954bc4111d11",
              "idx": 11,
              "type": "SUMMARY_COMPLETION",
              "skill": "READING",
              "difficulty": 2,
              "promptMd": "Complete the summary. Write **NO MORE THAN THREE WORDS** from the passage for each answer.\n\nThe freshwater is mostly coming from _______ caused by a build-up of _______.",
              "explanationMd": "Q11-0: melting Arctic ice | Q11-1: carbon dioxide",
              "options": [],
              "blankAcceptTexts": {
                "0": ["melting Arctic ice", "melting arctic ice"],
                "1": ["carbon dioxide"]
              },
              "blankAcceptRegex": {
                "0": ["melting\\s+arctic\\s+ice"],
                "1": ["carbon\\s+dioxide"]
              },
              "matchPairs": {},
              "orderCorrects": [],
              "shortAnswerAcceptTexts": [],
              "shortAnswerAcceptRegex": []
            },
            {
              "id": "bd9aa6b8-9385-42f9-b741-954bc4111d12",
              "idx": 12,
              "type": "SHORT_ANSWER",
              "skill": "READING",
              "difficulty": 2,
              "promptMd": "What does the writer say about Boston and Rome? Write **NO MORE THAN TWO WORDS**.\n\nThey are at the same _______.",
              "explanationMd": "Answer: latitude",
              "options": [],
              "blankAcceptTexts": {},
              "blankAcceptRegex": {},
              "matchPairs": {},
              "orderCorrects": [],
              "shortAnswerAcceptTexts": ["latitude"],
              "shortAnswerAcceptRegex": ["lati?tude"]
            },
            {
              "id": "bd9aa6b8-9385-42f9-b741-954bc4111d13",
              "idx": 13,
              "type": "TRUE_FALSE_NOT_GIVEN",
              "skill": "READING",
              "difficulty": 2,
              "promptMd": "The Gulf Stream has already stopped flowing northward.",
              "explanationMd": "NOT GIVEN — the passage discusses the risk but not a current stoppage.",
              "options": [
                { "id": "opt-13a", "idx": 1, "contentMd": "TRUE", "isCorrect": false },
                { "id": "opt-13b", "idx": 2, "contentMd": "FALSE", "isCorrect": false },
                { "id": "opt-13c", "idx": 3, "contentMd": "NOT GIVEN", "isCorrect": true }
              ],
              "blankAcceptTexts": {},
              "blankAcceptRegex": {},
              "matchPairs": {},
              "orderCorrects": [],
              "shortAnswerAcceptTexts": [],
              "shortAnswerAcceptRegex": []
            }
          ]
        }
      ]
    }
  ]
}
```

---

## 5. QUESTION TYPE SNIPPETS — ALL 19 TYPES

### Type 1: `TRUE_FALSE_NOT_GIVEN`
```json
{
  "id": "UUID",
  "idx": 14,
  "type": "TRUE_FALSE_NOT_GIVEN",
  "skill": "READING",
  "difficulty": 2,
  "promptMd": "The Gulf Stream warms both Europe and North America.",
  "explanationMd": "TRUE — Joyce explicitly states it warms Americans and Canadians too.",
  "options": [
    { "id": "UUID", "idx": 1, "contentMd": "TRUE", "isCorrect": true },
    { "id": "UUID", "idx": 2, "contentMd": "FALSE", "isCorrect": false },
    { "id": "UUID", "idx": 3, "contentMd": "NOT GIVEN", "isCorrect": false }
  ],
  "blankAcceptTexts": {}, "blankAcceptRegex": {},
  "matchPairs": {}, "orderCorrects": [],
  "shortAnswerAcceptTexts": [], "shortAnswerAcceptRegex": []
}
```

### Type 2: `YES_NO_NOT_GIVEN`
```json
{
  "type": "YES_NO_NOT_GIVEN",
  "promptMd": "The writer agrees that migration is still possible for poor people.",
  "options": [
    { "id": "UUID", "idx": 1, "contentMd": "YES", "isCorrect": false },
    { "id": "UUID", "idx": 2, "contentMd": "NO", "isCorrect": true },
    { "id": "UUID", "idx": 3, "contentMd": "NOT GIVEN", "isCorrect": false }
  ],
  "blankAcceptTexts": {}, "blankAcceptRegex": {},
  "matchPairs": {}, "orderCorrects": [],
  "shortAnswerAcceptTexts": [], "shortAnswerAcceptRegex": []
}
```

### Type 3: `MULTIPLE_CHOICE_SINGLE`
```json
{
  "type": "MULTIPLE_CHOICE_SINGLE",
  "promptMd": "What is the main purpose of the passage?",
  "options": [
    { "id": "UUID", "idx": 1, "contentMd": "A. To warn about economic collapse", "isCorrect": false },
    { "id": "UUID", "idx": 2, "contentMd": "B. To explain the risk of a new ice age", "isCorrect": true },
    { "id": "UUID", "idx": 3, "contentMd": "C. To compare European and American climates", "isCorrect": false },
    { "id": "UUID", "idx": 4, "contentMd": "D. To argue for reducing carbon dioxide", "isCorrect": false }
  ],
  "blankAcceptTexts": {}, "blankAcceptRegex": {},
  "matchPairs": {}, "orderCorrects": [],
  "shortAnswerAcceptTexts": [], "shortAnswerAcceptRegex": []
}
```

### Type 4: `MULTIPLE_CHOICE_MULTIPLE`
```json
{
  "type": "MULTIPLE_CHOICE_MULTIPLE",
  "promptMd": "Which TWO consequences of abrupt climate change are mentioned?",
  "options": [
    { "id": "UUID", "idx": 1, "contentMd": "A. Disappearing forests", "isCorrect": true },
    { "id": "UUID", "idx": 2, "contentMd": "B. Rising sea levels", "isCorrect": false },
    { "id": "UUID", "idx": 3, "contentMd": "C. Lower crop yields", "isCorrect": true },
    { "id": "UUID", "idx": 4, "contentMd": "D. Increased volcanic activity", "isCorrect": false },
    { "id": "UUID", "idx": 5, "contentMd": "E. Stronger hurricanes", "isCorrect": false }
  ],
  "blankAcceptTexts": {}, "blankAcceptRegex": {},
  "matchPairs": {}, "orderCorrects": [],
  "shortAnswerAcceptTexts": [], "shortAnswerAcceptRegex": []
}
```

### Type 5: `MULTIPLE_CHOICE_SINGLE_IMAGE`
```json
{
  "type": "MULTIPLE_CHOICE_SINGLE_IMAGE",
  "promptMd": "Which diagram best shows the thermohaline circulation?",
  "options": [
    { "id": "UUID", "idx": 1, "contentMd": "A. ![Diagram A](https://cdn.langfens.com/img/diagram-a.png)", "isCorrect": false },
    { "id": "UUID", "idx": 2, "contentMd": "B. ![Diagram B](https://cdn.langfens.com/img/diagram-b.png)", "isCorrect": true },
    { "id": "UUID", "idx": 3, "contentMd": "C. ![Diagram C](https://cdn.langfens.com/img/diagram-c.png)", "isCorrect": false }
  ],
  "blankAcceptTexts": {}, "blankAcceptRegex": {},
  "matchPairs": {}, "orderCorrects": [],
  "shortAnswerAcceptTexts": [], "shortAnswerAcceptRegex": []
}
```

### Type 6: `CLASSIFICATION`
```json
{
  "type": "CLASSIFICATION",
  "promptMd": "Classify the following statement about scientists' views.",
  "options": [
    { "id": "UUID", "idx": 1, "contentMd": "A. William Curry", "isCorrect": false },
    { "id": "UUID", "idx": 2, "contentMd": "B. Terrence Joyce", "isCorrect": false },
    { "id": "UUID", "idx": 3, "contentMd": "C. Both scientists", "isCorrect": true }
  ],
  "blankAcceptTexts": {}, "blankAcceptRegex": {},
  "matchPairs": { "class-q20": ["C"] },
  "orderCorrects": [],
  "shortAnswerAcceptTexts": [], "shortAnswerAcceptRegex": []
}
```

### Type 7: `SHORT_ANSWER`
```json
{
  "type": "SHORT_ANSWER",
  "promptMd": "What is the name of the deep-water current described in Paragraph J? _______",
  "explanationMd": "Answer: Great Ocean Conveyor",
  "options": [],
  "blankAcceptTexts": {}, "blankAcceptRegex": {},
  "matchPairs": {}, "orderCorrects": [],
  "shortAnswerAcceptTexts": ["Great Ocean Conveyor", "great ocean conveyor"],
  "shortAnswerAcceptRegex": ["great\\s+ocean\\s+conveyor"]
}
```

### Type 8: `SUMMARY_COMPLETION`
```json
{
  "type": "SUMMARY_COMPLETION",
  "promptMd": "Complete the summary. Write **NO MORE THAN TWO WORDS**.\n\nThe Gulf Stream carries _______ from the tropics northward, warming the air in _______.",
  "options": [],
  "blankAcceptTexts": {
    "0": ["heat", "warm water", "thermal energy"],
    "1": ["Europe", "northern Europe"]
  },
  "blankAcceptRegex": { "0": ["heat|warm\\s+water"], "1": ["europe"] },
  "matchPairs": {}, "orderCorrects": [],
  "shortAnswerAcceptTexts": [], "shortAnswerAcceptRegex": []
}
```

### Type 9: `TABLE_COMPLETION`
```json
{
  "type": "TABLE_COMPLETION",
  "promptMd": "Complete the table. Write **ONE WORD** for each answer.\n\n| Scientist | Institution | Warning |\n|-----------|-------------|--------|\n| Terrence Joyce | Woods Hole | Takes _______ to reverse |\n| Bob Dickson | British oceanography | _______ in Labrador Sea |",
  "options": [],
  "blankAcceptTexts": {
    "0": ["hundreds of years", "centuries"],
    "1": ["largest changes", "full-depth changes"]
  },
  "blankAcceptRegex": {}, "matchPairs": {}, "orderCorrects": [],
  "shortAnswerAcceptTexts": [], "shortAnswerAcceptRegex": []
}
```

### Type 10: `NOTE_COMPLETION` / `FORM_COMPLETION` / `SENTENCE_COMPLETION`
```json
{
  "type": "NOTE_COMPLETION",
  "promptMd": "Complete the notes. Write **NO MORE THAN TWO WORDS**.\n\n**Effects of climate change:**\n- Agricultural losses: $_______ to $250 billion\n- Water supply: _______ fresh water",
  "options": [],
  "blankAcceptTexts": {
    "0": ["100 billion", "100"],
    "1": ["dwindling", "decreasing", "less"]
  },
  "blankAcceptRegex": { "0": ["100\\s*billion?"] },
  "matchPairs": {}, "orderCorrects": [],
  "shortAnswerAcceptTexts": [], "shortAnswerAcceptRegex": []
}
```

### Type 11: `DIAGRAM_LABEL`
```json
{
  "type": "DIAGRAM_LABEL",
  "promptMd": "Label the diagram of the thermohaline circulation.\n\n![Circulation diagram](https://cdn.langfens.com/img/circulation.png)\n\n29. _______\n30. _______\n31. _______",
  "options": [],
  "blankAcceptTexts": {
    "29": ["Gulf Stream", "gulf stream"],
    "30": ["deep water", "cold water"],
    "31": ["North Atlantic", "north atlantic"]
  },
  "blankAcceptRegex": {}, "matchPairs": {}, "orderCorrects": [],
  "shortAnswerAcceptTexts": [], "shortAnswerAcceptRegex": []
}
```

### Type 12: `MAP_LABEL`
```json
{
  "type": "MAP_LABEL",
  "promptMd": "Label the map. Write the correct letter **A–H**.\n\n![Ocean currents map](https://cdn.langfens.com/img/ocean-map.png)\n\n32. Labrador Sea: _______\n33. Gulf Stream path: _______",
  "options": [],
  "blankAcceptTexts": {
    "32": ["C"],
    "33": ["A"]
  },
  "blankAcceptRegex": {}, "matchPairs": {}, "orderCorrects": [],
  "shortAnswerAcceptTexts": [], "shortAnswerAcceptRegex": []
}
```

### Type 13: `MATCHING_HEADING`
```json
{
  "type": "MATCHING_HEADING",
  "promptMd": "Choose the correct heading for **Paragraph G**.",
  "options": [
    { "id": "UUID", "idx": 1, "contentMd": "i. The warming paradox", "isCorrect": false },
    { "id": "UUID", "idx": 2, "contentMd": "ii. Historical painting evidence", "isCorrect": false },
    { "id": "UUID", "idx": 3, "contentMd": "iii. Economic consequences", "isCorrect": false },
    { "id": "UUID", "idx": 4, "contentMd": "iv. Effects on the poor", "isCorrect": false },
    { "id": "UUID", "idx": 5, "contentMd": "v. The role of fresh water", "isCorrect": false },
    { "id": "UUID", "idx": 6, "contentMd": "vi. A contradiction — warming causes cooling", "isCorrect": true },
    { "id": "UUID", "idx": 7, "contentMd": "vii. The deep ocean current", "isCorrect": false }
  ],
  "blankAcceptTexts": {}, "blankAcceptRegex": {},
  "matchPairs": { "section-g": ["vi", "vi. A contradiction — warming causes cooling"] },
  "orderCorrects": [],
  "shortAnswerAcceptTexts": [], "shortAnswerAcceptRegex": []
}
```

### Type 14: `MATCHING_INFORMATION`
```json
{
  "type": "MATCHING_INFORMATION",
  "promptMd": "Which paragraph contains evidence that ocean changes are historically unprecedented?",
  "options": [],
  "blankAcceptTexts": {}, "blankAcceptRegex": {},
  "matchPairs": { "info-q34": ["H"] },
  "orderCorrects": [],
  "shortAnswerAcceptTexts": [], "shortAnswerAcceptRegex": []
}
```

### Type 15: `MATCHING_FEATURES`
```json
{
  "type": "MATCHING_FEATURES",
  "promptMd": "Match each statement to the correct scientist.\n**A.** William Curry\n**B.** Bob Dickson\n**C.** Terrence Joyce",
  "options": [],
  "blankAcceptTexts": {}, "blankAcceptRegex": {},
  "matchPairs": { "feature-q35": ["Bob Dickson", "B"] },
  "orderCorrects": [],
  "shortAnswerAcceptTexts": [], "shortAnswerAcceptRegex": []
}
```

### Type 16: `MATCHING_ENDINGS`
```json
{
  "type": "MATCHING_ENDINGS",
  "promptMd": "Match the sentence beginnings (**A–E**) with the correct endings (**i–v**).\n**A.** The Gulf Stream carries heat...\n**B.** As water flows northward...\n**C.** Cold water sinks...",
  "options": [],
  "blankAcceptTexts": {}, "blankAcceptRegex": {},
  "matchPairs": {
    "ending-q36": ["i"],
    "ending-q37": ["iii"],
    "ending-q38": ["v"]
  },
  "orderCorrects": [],
  "shortAnswerAcceptTexts": [], "shortAnswerAcceptRegex": []
}
```

### Type 17: `FLOW_CHART`
```json
{
  "type": "FLOW_CHART",
  "promptMd": "Arrange the stages of thermohaline circulation in the correct order.",
  "options": [],
  "blankAcceptTexts": {}, "blankAcceptRegex": {},
  "matchPairs": {},
  "orderCorrects": [
    "gulf-stream-flows-north",
    "heat-released-to-air",
    "water-cools-becomes-dense",
    "water-sinks-deep-atlantic",
    "great-ocean-conveyor-flows"
  ],
  "shortAnswerAcceptTexts": [], "shortAnswerAcceptRegex": []
}
```

---

## 6. SCRAPING MANDATE

> **ALL future scraping scripts MUST:**

1. **Map scraped HTML → this exact JSON structure** field by field, type by type.
2. **Validate every output file** against `scripts/crawler/exam-import.schema.json` using a JSON Schema validator before saving.
3. **Reject any file that fails validation** — write it to a dead-letter queue at `dataset_ielts/rejected/` with the validation error logged.
4. **Never use `null`** where schema expects `{}` or `[]` for answer fields.
5. **Pre-generate UUIDs** for all `id` fields using `uuid.uuid4()`.
6. **Strip leading question numbers** from `promptMd` (the `{idx}. ` prefix is auto-rendered by frontend).
7. **Use `_{7}` (7 underscores)** as the blank marker in `promptMd` for all completion types.
8. **Provide case-variant arrays** in `blankAcceptTexts` (e.g., `["one-sixth", "One-Sixth"]`).
9. **Expand optional-word answers** — `(commemorative) coin` → `["coin", "commemorative coin"]`.
10. **Set `status: "DRAFT"`** for all new crawled exams — never `PUBLISHED` until human-reviewed.

### Detection Pipeline for Question Types:
```python
def detect_question_type(prompt, answer, answer_format):
    # Step 1: TFNG vs YNNG
    if answer in ['TRUE', 'FALSE', 'NOT GIVEN']:
        return 'TRUE_FALSE_NOT_GIVEN'
    if answer in ['YES', 'NO', 'NOT GIVEN']:
        return 'YES_NO_NOT_GIVEN'

    # Step 2: MCQ_MULTIPLE
    if re.search(r'\bTWO\b|\bTHREE\b', prompt, re.I):
        return 'MULTIPLE_CHOICE_MULTIPLE'
    if ',' in str(answer) and re.match(r'^[A-E],\s*[A-E]$', str(answer)):
        return 'MULTIPLE_CHOICE_MULTIPLE'

    # Step 3: MATCHING types
    if 'paragraph' in prompt.lower() and re.match(r'^[A-J]$', str(answer)):
        return 'MATCHING_INFORMATION'
    if 'heading' in prompt.lower() and re.match(r'^[ivxlc]+$', str(answer)):
        return 'MATCHING_HEADING'
    if re.search(r'person|scientist|researcher|writer', prompt.lower()):
        return 'MATCHING_FEATURES'

    # Step 4: COMPLETION types
    if re.search(r'_{3,}', prompt):
        blank_count = len(re.findall(r'_{3,}', prompt))
        if blank_count == 1:
            return 'SHORT_ANSWER'
        if 'summary' in prompt.lower():
            return 'SUMMARY_COMPLETION'
        if 'table' in prompt.lower():
            return 'TABLE_COMPLETION'
        if 'note' in prompt.lower() or 'form' in prompt.lower():
            return 'NOTE_COMPLETION'
        return 'SUMMARY_COMPLETION'  # default multi-blank

    # Step 5: MCQ single
    if re.search(r'^[A-D]\.\s', str(answer)):
        return 'MULTIPLE_CHOICE_SINGLE'

    # Default
    return 'MULTIPLE_CHOICE_SINGLE'
```

---

## 7. VALIDATION CHECKLIST (Run Before Every Commit)

```
ROOT:
[ ] schemaVersion = "1.0.0" (string)
[ ] exams[] has >= 1 item

EXAM:
[ ] id = valid UUID
[ ] slug matches ^[a-z0-9]+(?:-[a-z0-9]+)*$ (3-128 chars)
[ ] title not empty
[ ] category ∈ {IELTS, TOEIC, VSTEP, PLACEMENT}
[ ] level ∈ {A1, A2, B1, B2, C1, C2}
[ ] durationMin >= 1
[ ] sections[] has >= 1 item

SECTION:
[ ] id = valid UUID
[ ] idx >= 1 (1-based)
[ ] title not empty
[ ] questions[] has >= 1 item

QUESTION:
[ ] id = valid UUID
[ ] idx 1-50
[ ] type ∈ 19 valid enum values (use scripts/crawler/ version!)
[ ] skill ∈ {READING, LISTENING, WRITING, SPEAKING}
[ ] difficulty >= 1
[ ] promptMd not empty, no leading number
[ ] options not null ([] if empty)
[ ] blankAcceptTexts not null ({} if empty)
[ ] blankAcceptRegex not null ({} if empty)
[ ] matchPairs not null ({} if empty)
[ ] orderCorrects not null ([] if empty)
[ ] shortAnswerAcceptTexts not null ([] if empty)
[ ] shortAnswerAcceptRegex not null ([] if empty)

PER TYPE:
[ ] TFNG/YNNG: exactly 3 options, exactly 1 isCorrect=true
[ ] MCQ_SINGLE: 3-5 options, exactly 1 isCorrect=true
[ ] MCQ_MULTIPLE: 3-5 options, 2+ isCorrect=true
[ ] COMPLETION/*: options=[], promptMd has _{3,}, blankAcceptTexts has data
[ ] SHORT_ANSWER: options=[], promptMd has _{3,}, shortAnswerAcceptTexts has data
[ ] MATCHING_HEADING: options has all headings i-x, matchPairs has section-{letter}
[ ] MATCHING_*: options=[], matchPairs has data, answers are A-J
[ ] FLOW_CHART: options=[], orderCorrects has slug-format keys
```

---

*Document generated from authoritative sources in `/home/khoa/Projects/Project_Langfens_Microservice`.*
*Primary schema: `scripts/crawler/exam-import.schema.json` (includes MULTIPLE_CHOICE_MULTIPLE).*
*Do NOT use `templates/exam-import.schema.json` — it is missing MULTIPLE_CHOICE_MULTIPLE.*
