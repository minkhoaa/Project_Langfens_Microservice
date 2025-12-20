---
description: Run IELTS pipeline (HYBRID) - Rule-based + AI Validator
---

# /ielts-pipeline - IELTS Data Pipeline

**BẠN LÀ: "IELTS RECORD REPAIR AGENT"**

| Key | Value |
|-----|-------|
| **Approach** | Rule-Based Auto (Tier 1) + AI Validation (Tier 2) |
| **Quality** | Production-ready, 100% verified |
| **Token Budget** | ~6600 tokens/exam · ~24 exams/session |

---

## 📌 TABLE OF CONTENTS

1. [Quick Start](#-quick-start)
2. [Strict Rules Summary](#-strict-rules-summary)
3. [Automated Enforcement](#-automated-enforcement)
4. [Pipeline Tiers](#-pipeline-tiers)
5. [Validation Checklist](#-validation-checklist)
6. [Bug Reference](#-bug-reference)
7. [Auto-Fix Templates](#-auto-fix-templates)

---

## 🚀 QUICK START

```bash
// turbo
cd /home/khoa/RiderProjects/Project_Langfens_Microservice/scripts/pipeline_v2 && python orchestrator.py "<URL>" 2>&1
```

**After crawl:**
```bash
cd .../scripts/pipeline_v2 && python export.py ielts-mentor <ITEM_ID>
PGPASSWORD=exam psql -h localhost -p 5433 -U exam -d exam-db -f ".../seeds/seed_exam_<SLUG>.sql"
```

---

## 🔒 STRICT RULES SUMMARY

> [!CRITICAL]
> **VI PHẠM = Frontend KHÔNG render hoặc Backend KHÔNG grade được!**

### Core Rules:

| Rule | Requirement | Example |
|------|-------------|---------|
| **Paragraph Labels** | `**Paragraph A.**\n` + content | ✅ `**Paragraph A.**\nText...` ❌ `A. Text` |
| **Blank Pattern** | `_{3,}` (3+ underscores) | ✅ `pay _______` ❌ `pay ...` |
| **Instruction Format** | `**Questions X-Y:**` bold | ✅ `**Questions 1-8:**` |
| **Prompt Numbers** | NO leading numbers | ✅ `Statement` ❌ `1. Statement` |

### Type-Specific Rules:

| Type | Options | matchPairs | Blanks | isCorrect |
|------|---------|------------|--------|-----------|
| TFNG/YNNG | 3 (T/F/NG or Y/N/NG) | null | ❌ | exactly 1 |
| MCQ_SINGLE | 4+ items | null | ❌ | exactly 1 |
| MCQ_MULTIPLE | 5+ items | null | ❌ | 2+ |
| SHORT_ANSWER | `[]` empty | null | ✅ `_______` | - |
| SUMMARY_COMPLETION | `[]` empty | null | ✅ `_______` | - |
| MATCHING_HEADING | 5+ headings | `{key: [val, label]}` | ❌ | exactly 1 |
| MATCHING_INFO | `[]` empty | `{key: [letter]}` | ❌ | - |
| MATCHING_FEATURES | `[]` empty | `{key: [label, letter]}` | ❌ | - |

**Full details:** @[/ielts-data-format]

---

## 🛡️ AUTOMATED ENFORCEMENT

> [!IMPORTANT]
> **Invariant checks tự động chạy ở Stage 6 của pipeline.**
> - Violations = BLOCK crawl ❌
> - Warnings = proceed với alert ⚠️

### 14 Invariant Checks:

| # | Check | Rule | Violation Example |
|---|-------|------|-------------------|
| 1 | `check_question_sequence` | Core | Gap Q5 → Q15 |
| 2 | `check_single_choice_types` | Core | TFNG có 0 isCorrect |
| 3 | `check_multiple_choice_types` | Core | MCQ_MULTIPLE có <2 correct |
| 4 | `check_matching_heading` | Core | MATCHING_HEADING có <4 options |
| 5 | `check_matching_types` | Core | Missing correct_answers |
| 6 | `check_completion_types` | Core | Missing answer for SHORT_ANSWER |
| 7 | `check_passage_length` | Core | Passage <100 words |
| 8 | `check_no_duplicate_prompts` | Core | Q5 = Q12 duplicated |
| 9 | `check_paragraph_labels` | **Strict** | `A.` instead of `**Paragraph A.**` |
| 10 | `check_instruction_format` | **Strict** | Missing `**Questions X-Y:**` |
| 11 | `check_blank_patterns` | **Strict** | Using `...` not `_______` |
| 12 | `check_prompt_numbering` | **Strict** | `"1. Question"` has leading number |
| 13 | `check_matching_info_options` | **Strict** | MATCHING_INFO has options[] |
| 14 | `check_mcq_multiple_detection` | **Strict** | "Choose TWO" but not MCQ_MULTIPLE |

---

## 📊 PIPELINE TIERS

### TIER 1: Rule-Based Auto
Runs automatically via orchestrator. Stages:
1. FETCH → 2. CLEAN → 3. PARSE → 4. NORMALIZE → 5. VALIDATE → 6. INVARIANTS → 7. EXPORT

**Auto Features:**
- ✅ **Passage cleanup**: Removes metadata garbage (GT Reading, Section markers, Details, Last Updated, Hits, etc.)
- ✅ **MCQ_MULTIPLE detection**: Warns if answer has comma (A, C) but type is not MCQ_MULTIPLE
- ✅ **Blank pattern check**: Flags `...` instead of `_______`
- ✅ **Prompt numbering check**: Detects leading numbers in prompts

### TIER 2: AI 10-Role Validation

| Phase | Roles | Key Checks |
|-------|-------|------------|
| **INPUT** | 1-2 | HTML >5000 chars, no duplicates |
| **CONTENT** | 3-4 | Passage ≥500 words, prompts verbatim |
| **STRUCTURE** | 5-6 | Type matches format, options correct |
| **ANSWER** | 7-8 | Answers filled, JSON valid |
| **OUTPUT** | 9-10 | SQL complete, production ready |

**Role 3 Critical:** Passage MUST be full article (500+ words), NOT summary!

**Role 5 Type Mapping:**
| Source Instruction | Type |
|-------------------|------|
| "ONE NUMBER/WORD" | SHORT_ANSWER |
| "TRUE/FALSE/NOT GIVEN" | TRUE_FALSE_NOT_GIVEN |
| "Choose A-F" | MATCHING_INFORMATION |
| "heading i-xi" | MATCHING_HEADING |

### TIER 3: One-Shot Fix
Manual fixes for complex issues - see [Auto-Fix Templates](#-auto-fix-templates)

### TIER 4: Seed + QA
Export SQL and seed to database, generate QA report.

---

## ✅ VALIDATION CHECKLIST

### Per-Crawl Checklist:
```
[ ] Passage ≥ 500 words
[ ] Paragraph labels: **Paragraph A.**\n format
[ ] Instruction present: **Questions X-Y:**
[ ] All answers filled
[ ] Blanks use _______ not ...
[ ] No leading numbers in prompts
[ ] MATCHING_INFO has empty options[]
[ ] SQL seeds without error
```

### 10-Role Summary:
- [ ] Role 1-2: Input valid, no duplicates
- [ ] Role 3-4: Passage full, prompts verbatim
- [ ] Role 5-6: Types correct, options formatted
- [ ] Role 7-8: Answers correct, JSON valid
- [ ] Role 9-10: SQL complete, production ready

---

## 🚨 BUG REFERENCE

### 1. PASSAGE ISSUES
| Bug | Fix |
|-----|-----|
| Passage <500 words | Extract full from cleaned text |
| Missing paragraph labels | Add `**Paragraph A.**\n` format |
| Contains headings list (i-xi) | Move to MATCHING_HEADING options |
| Missing instruction_md | Add `**Questions X-Y:**` format |

### 2. TYPE MISMATCH
| Bug | Fix |
|-----|-----|
| "Complete sentences" → MCQ | Change to SHORT_ANSWER |
| "Which paragraph" → SHORT_ANSWER | Change to MATCHING_INFO |
| "These TWO films" → MATCHING_INFO | Change to MCQ_MULTIPLE |

### 3. OPTIONS ISSUES
| Bug | Fix |
|-----|-----|
| MATCHING_INFO has options | Clear to `[]` |
| MATCHING_HEADING missing headings | Add all i-xi headings |
| TFNG missing isCorrect | Set exactly 1 correct |

### 4. PROMPT ISSUES
| Bug | Fix |
|-----|-----|
| `"1. Question"` leading number | Remove number prefix |
| `"pay ... week"` ellipsis | Replace with `_______` |
| Contains options A/B/C | Move to options array |

### 5. ENCODING ISSUES
| Bug | Fix |
|-----|-----|
| Smart quotes `""` | Replace with `""` |
| Ligatures `ﬁ ﬂ` | Replace with `fi fl` |
| Em dash `—` | Replace with `--` |

---

## 🔧 AUTO-FIX TEMPLATES

### Quick Fix Template:
```python
import json, re
from pathlib import Path

ITEM_ID = "<ITEM_ID>"
data_path = Path(f"/home/khoa/RiderProjects/Project_Langfens_Microservice/data/normalized/ielts-mentor/{ITEM_ID}.json")
data = json.loads(data_path.read_text())

for q in data['questions']:
    # Fix blank patterns
    q['prompt_md'] = q.get('prompt_md', '').replace('...', '_______').replace('…', '_______')
    # Fix leading numbers
    q['prompt_md'] = re.sub(r'^\d+[\.\)]\s+', '', q['prompt_md'])
    # Fix MATCHING_INFO options
    if q['type'] in ['MATCHING_INFORMATION', 'MATCHING_FEATURES']:
        q['options'] = []

# Fix paragraph labels
passage = data['sections'][0].get('passage_md', '')
for letter in 'ABCDEFGH':
    passage = re.sub(rf'(?:^|\n){letter}\.\s+', f'\n\n**Paragraph {letter}.**\n', passage)
data['sections'][0]['passage_md'] = passage

data_path.write_text(json.dumps(data, indent=2, ensure_ascii=False))
print(f"✓ Fixed {ITEM_ID}")
```

### Passage Extraction Template:
```python
# If passage <500 words, extract from cleaned text
cleaned = Path(f".../cleaned/ielts-mentor/{ITEM_ID}.txt").read_text()
start = re.search(r'(?:People|The|In|Back)', cleaned)
end = re.search(r'Questions \d+-\d+', cleaned)
if start and end:
    full_passage = cleaned[start.start():end.start()].strip()
    data['sections'][0]['passage_md'] = full_passage
```

### MATCHING_HEADING Fix Template:
```python
HEADINGS = [
    {"value": "i", "label": "i. Heading text 1", "is_correct": False},
    {"value": "ii", "label": "ii. Heading text 2", "is_correct": False},
    # ... add all headings
]

for q in data['questions']:
    if q['type'] == 'MATCHING_HEADING':
        correct_ans = q['correct_answers'][0].lower()
        opts = []
        for h in HEADINGS:
            opt = dict(h)
            opt['is_correct'] = (opt['value'] == correct_ans)
            opts.append(opt)
        q['options'] = opts
```

---

## 🔒 GOLDEN RULES

1. **KHÔNG bịa** - Chỉ trích từ source verbatim
2. **KHÔNG paraphrase** - Giữ nguyên văn
3. **VERIFY với source** - Check website khi không chắc
4. **Passage ≥ 500 words** - Extract full nếu ngắn
5. **Paragraph labels BẮT BUỘC** - `**Paragraph A.**\n`

---

## 🔗 RELATED

- @[/ielts-data-format] - Strict JSON schemas (31 rules)
