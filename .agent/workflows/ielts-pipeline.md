---
description: Run IELTS pipeline (HYBRID) - Rule-based + AI Validator
---

# /ielts-pipeline - IELTS Data Pipeline

**BẠN LÀ: "IELTS RECORD REPAIR AGENT"**

| Key | Value |
|-----|-------|
| **Approach** | Rule-Based (Tier 1) + 4 AI Phases (Gemini 2x + Claude 2x) |
| **Quality** | Production-ready, 100% verified |
| **Claude Work** | 90% - MAIN validator |

---

## 🚨 MANDATORY STRICT RULES (CHECK IN ALL 4 AI PHASES)

> [!CRITICAL]
> **BẮT BUỘC check toàn bộ rules sau trong CẢ 4 phiên AI!**
> VI PHẠM = FAIL output → Fix ngay!

### ✅ Passage Rules:

| Rule | Format | Violation |
|------|--------|-----------|
| **Paragraph Labels** | `**Paragraph A.**\n` | ❌ `A.`, `Step 1`, `1.` |
| **No embedded questions** | Passage = text only | ❌ Q1-8 statements inside passage |
| **Section separator** | `---` between passages | ❌ No separator |
| **Passage length** | ≥100 words per passage | ❌ <100 words |

### ✅ Question Rules:

| Rule | Format | Violation |
|------|--------|-----------|
| **No leading numbers** | `Statement here` | ❌ `1. Statement` |
| **Blank pattern** | `_______` (7 underscores) | ❌ `...`, `___` |
| **instruction_md present** | `**Questions X-Y:**` | ❌ Missing |

### ✅ Type-Specific Rules:

| Type | Options | isCorrect |
|------|---------|-----------|
| TFNG/YNNG | 3 items (T/F/NG) | exactly 1 |
| MCQ_SINGLE | 4+ items | exactly 1 |
| MCQ_MULTIPLE | 5+ items | 2+ |
| MATCHING_INFO | `[]` empty | - |
| MATCHING_FEATURES | `[]` empty | - |
| MATCHING_HEADING | 5+ headings | exactly 1 |

---

## 🔄 4 AI PHASES CHECKLIST

### Phase 1: Gemini PRE-CHECK
```
[ ] Passage length OK
[ ] No obvious encoding garbage
[ ] Question count matches source
```

### Phase 2: ⭐ Claude CHECK #1 (CHÍNH)
```
MANDATORY:
[ ] Verify source website
[ ] Passage has **Paragraph A.** format
[ ] No questions embedded in passage
[ ] Question types match source instructions
[ ] instruction_md present
[ ] All prompts extracted correctly
[ ] All options with correct is_correct
```

### Phase 3: Gemini POST-CHECK
```
[ ] Gemini returns PASS
[ ] Confidence ≥80%
[ ] No HIGH severity issues
```

### Phase 4: ⭐ Claude CHECK #2 + Seed
```
MANDATORY:
[ ] Invariants: 0 violations
[ ] Re-verify passage format
[ ] Re-verify question types
[ ] SQL exports without error
[ ] Seed to DB: COMMIT
```

---

## 🚀 QUICK START

```bash
// turbo
cd /home/khoa/RiderProjects/Project_Langfens_Microservice/scripts/pipeline_v2 && python orchestrator.py "<URL>" 2>&1
```

**After all 4 phases pass:**
```bash
PGPASSWORD=exam psql -h localhost -p 5433 -U exam -d exam-db -f "seed_exam_*.sql"
```

---

## 🛡️ AUTOMATED INVARIANT CHECKS (14)

| # | Check | Severity |
|---|-------|----------|
| 1-8 | Core checks | VIOLATION |
| 9-14 | Strict rule checks | WARNING |

**Violations = BLOCK** ❌ | **Warnings = Alert** ⚠️


---

## 📊 PIPELINE FLOW (Claude = 90% work)

> [!IMPORTANT]
> **Claude BẮT BUỘC check sau MỖI phiên Gemini** - không phải chỉ khi fail!

### Complete Flow:

```
1. TIER 1: Rule-Based Auto (Python)
       ↓
2. Gemini PRE-CHECK
       ↓
3. ⭐ Claude CHECK #1 (bắt buộc)
       ↓
4. Gemini POST-CHECK
       ↓
5. ⭐ Claude CHECK #2 (bắt buộc) + Seed
```

### TIER 1: Rule-Based Auto
```bash
python orchestrator.py "<URL>"
```
Auto xử lý: Fetch → Clean → Parse → Normalize → Validate → Invariants → Export

### Gemini PRE-CHECK
Quick scan: passage length, missing fields, encoding garbage.

### ⭐ Claude CHECK #1 (CHÍNH)
**BẮT BUỘC sau Gemini PRE-CHECK.**

**Checklist:**
- [ ] Verify source website
- [ ] Check question types match instructions
- [ ] Fix options/prompts/answers
- [ ] Add instruction_md

**Key fixes:**
| Source Instruction | Correct Type |
|-------------------|--------------|
| "TRUE/FALSE/NOT GIVEN" | TRUE_FALSE_NOT_GIVEN |
| "Choose A, B, C or D" | MULTIPLE_CHOICE_SINGLE |
| "Which TWO" | MULTIPLE_CHOICE_MULTIPLE |
| "Which paragraph" | MATCHING_INFORMATION |
| "heading i-xi" | MATCHING_HEADING |

### Gemini POST-CHECK
Verify Claude's fixes. Expect: PASS 80-100%.

### ⭐ Claude CHECK #2 + Seed
**BẮT BUỘC sau Gemini POST-CHECK.**

**Final checklist:**
- [ ] Invariants: 0 violations, 0 warnings
- [ ] Export SQL
- [ ] Seed to DB
- [ ] (Optional) Test frontend

```bash
PGPASSWORD=exam psql -h localhost -p 5433 -U exam -d exam-db -f "seed_exam_*.sql"
```

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
[ ] Gemini v2 QA = PASS (Tier 2.5)
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
