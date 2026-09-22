# Standard: Scientific Paper / Article Crawler to Question Generation Contract

## 1. Overview & Purpose

In IELTS preparation, authentic exam passages are sourced from academic journals, science periodicals (e.g., *Nature*, *New Scientist*, *Scientific American*, *National Geographic*), and formal essays.

The **Passage-Grounded Question Auto-Generation** subsystem decouples passage ingestion from question generation. When the automated paper/article crawler extracts content, it stores authentic source text directly into `ExamSection.PassageMd`. All question authoring tools (`AiAuthorModal`, `QuestionTypeCardPicker`, `QuestionEditor`, and batch ingestion pipelines) bind directly to this section text without requiring manual copy-pasting.

```
┌──────────────────────────────────────────────┐
│  Scientific Article / Paper Crawler Engine    │
│  (ArXiv, CrossRef, ScienceDirect, OpenAlex)  │
└──────────────────────┬───────────────────────┘
                       │ Sanitized Markdown Text
                       ▼
┌──────────────────────────────────────────────┐
│  exam-service: ExamSection                    │
│  - Title: Paper / Article Headline           │
│  - PassageMd: Full Authentic Academic Text   │
│  - InstructionsMd: IELTS Section Directives   │
└──────────────────────┬───────────────────────┘
                       │ Grounds LLM Prompts
                       ▼
┌──────────────────────────────────────────────┐
│  AI Question Generation Engine                │
│  - AiAuthorModal (Preview & batch save)      │
│  - QuestionTypeCardPicker ("Generate with AI")│
│  - QuestionEditor ("AI Auto-fill" in draft)  │
│  - Headless Batch Authoring (13-14 Qs/Paper) │
└──────────────────────────────────────────────┘
```

---

## 2. Ingestion Data Contract (Crawler Schema)

When the crawler creates a new `ExamSection`, it must populate the following fields according to the schema expected by `adminApi` and `exam-service`:

### Section Ingestion Payload (`AdminSectionUpsert`)

| Field | Type | Description | Crawler Requirement |
|---|---|---|---|
| `ExamId` | `string (UUID)` | Parent exam UUID | Required |
| `Idx` | `number` | 1, 2, or 3 (for IELTS Reading Passages 1, 2, or 3) | Required |
| `Title` | `string` | Academic article headline / paper title | Required (max 250 chars) |
| `PassageMd` | `string (Markdown)` | Full, clean text of the article or paper | **Mandatory** for Reading sections |
| `InstructionsMd` | `string (Markdown)` | IELTS candidate instruction banner | Optional (defaults to standard IELTS prompt) |
| `TranscriptMd` | `string (Markdown)` | Spoken script / audio transcript | Mandatory for Listening sections without audio |
| `AudioUrl` | `string` | Audio asset URL | Optional (Listening only) |

### Recommended Default Instructions

For Reading sections:
```markdown
You should spend about 20 minutes on Questions {START_Q}-{END_Q}, which are based on Reading Passage {SECTION_IDX} below.
```

---

## 3. Grounding Flow & UI Integration

With the implementation of the centralized engine `questionGeneration.ts`, three authoring workflows are fully grounded in `section.passageMd`:

1. **Card Picker Workflow ("Add Question" -> "Generate with AI Preview")**:
   - Selecting any of the 19 IELTS question types while the section has a passage renders **"✨ Generate with AI Preview"**.
   - Clicking this automatically opens `AiAuthorModal` with the section's `passageMd`, question type, and skill pre-populated in preview mode.

2. **Section AI Author Modal (`AiAuthorModal`)**:
   - Automatically resolves `section.passageMd` (falling back to `section.transcriptMd`).
   - Displays a passage attachment badge: `📄 Using Section Passage: "<Title>" (<Length> chars)`.
   - Allows collapsing/expanding the passage preview or switching to custom text if desired.

3. **In-Editor Auto-fill (`QuestionEditor`)**:
   - Admins editing a blank question card can click **"✨ AI Auto-fill"**.
   - The engine sends `section.passageMd` alongside the card's current type and difficulty to the AI service.
   - Automatically populates `PromptMd`, `ExplanationMd`, and answer options (including `MatchPairs`, `BlankAcceptTexts`, etc.) directly into the editor draft for review and `Ctrl+S` saving.

---

## 4. Automated Headless Exam Assembly (Future Crawler Pipeline)

Because `generateQuestionsFromPassage` and `persistGeneratedQuestions` in `questionGeneration.ts` operate programmatically on `section.passageMd`, an automated pipeline can generate complete 40-question IELTS papers without UI interaction:

```typescript
import { generateQuestionsFromPassage, persistGeneratedQuestions } from "@/app/admin/_lib/questionGeneration";

// Example: Synthesizing Reading Passage 1 (13 Questions total)
const sectionPassage = crawledPaper.contentMd;
const sectionId = createdSection.id;

// Question Group 1: 5x Matching Headings
const headings = await generateQuestionsFromPassage({
  type: "MATCHING_HEADING",
  skill: "READING",
  passage: sectionPassage,
  count: 5,
  sectionId,
});
await persistGeneratedQuestions(sectionId, headings.questions);

// Question Group 2: 4x True/False/Not Given
const tfng = await generateQuestionsFromPassage({
  type: "TRUE_FALSE_NOT_GIVEN",
  skill: "READING",
  passage: sectionPassage,
  count: 4,
  sectionId,
});
await persistGeneratedQuestions(sectionId, tfng.questions);

// Question Group 3: 4x Summary Completion
const summary = await generateQuestionsFromPassage({
  type: "SUMMARY_COMPLETION",
  skill: "READING",
  passage: sectionPassage,
  count: 4,
  sectionId,
});
await persistGeneratedQuestions(sectionId, summary.questions);
```

---

## 5. Text Sanitization Requirements for Crawlers

Before inserting scientific text into `PassageMd`:
1. **Strip HTML Tags**: Retain markdown formatting (e.g., `## Heading`, `**bold**`, `*italic*`), but remove inline CSS, scripts, and non-semantic DOM tags.
2. **Remove Citations & Footnote Markers**: Convert citations like `[1]`, `[2, 3]`, `(Smith et al., 2021)` into clean natural sentences, or remove bracket markers so they do not conflict with IELTS blank placeholders like `[1]`, `[2]`.
3. **Paragraph Preservation**: Separate paragraphs with double newlines (`\n\n`) to preserve paragraph structure essential for `MATCHING_HEADING` and `MATCHING_INFORMATION`.
4. **Length Targets**:
   - Academic Reading Passage 1: ~750 - 900 words.
   - Academic Reading Passage 2: ~800 - 950 words.
   - Academic Reading Passage 3: ~850 - 1050 words.
