---
description: Run IELTS pipeline (HYBRID) - Rule-based + AI Validator
---

# /ielts-pipeline - HYBRID 10-ROLE IELTS Pipeline

**BẠN LÀ: "IELTS RECORD REPAIR AGENT"**
**APPROACH**: Rule-Based Auto (Tier 1) + 10 AI Roles (Tier 2)
**QUALITY**: Production-ready, 100% verified
**TOKEN BUDGET**: ~6600 tokens per exam | ~24 exams/session

> [!CRITICAL]
> ## 🔒 STRICT OUTPUT FORMAT - PHẢI TUÂN THỦ!
> 
> **Xem @[/ielts-data-format] để biết CHÍNH XÁC format JSON cho mỗi question type.**
> 
> **BLANK PATTERN**: Completion types PHẢI dùng `_{3,}` (3+ underscores) để frontend render input!
> - ✅ `"pay _______ per week"` → Frontend renders input box
> - ❌ `"pay ... per week"` → Frontend KHÔNG render input!
> 
> **TYPE-SPECIFIC RULES:**
> - `TFNG/YNNG`: 3 options (TRUE/FALSE/NOT GIVEN hoặc YES/NO/NOT GIVEN)
> - `MATCHING_HEADING`: options = all headings, matchPairs = answer
> - `MATCHING_INFO/FEATURES`: options = [], matchPairs = answer letter
> - `SHORT_ANSWER/SUMMARY_COMPLETION`: options = [], promptMd có `_______`

---

## TIER 1: RULE-BASED AUTO

```bash
// turbo
cd /home/khoa/RiderProjects/Project_Langfens_Microservice/scripts/pipeline_v2 && python orchestrator.py "<URL>" 2>&1
```

---

## TIER 2: AI 10-ROLE VALIDATION

### PHASE 1: INPUT VALIDATION

#### Role 1: Validate Input
- Check raw HTML có đủ content (>5000 chars)
- Check có markers: question, passage, answer

#### Role 2: Duplicate Detector  
- Check exam đã tồn tại trong DB chưa
- Check trùng title/slug với exams khác

### PHASE 2: CONTENT EXTRACTION

```bash
// turbo
cat /home/khoa/RiderProjects/Project_Langfens_Microservice/data/cleaned/ielts-mentor/<ITEM_ID>.txt | head -120
```

#### Role 3: Passage Validator ⚠️ CRITICAL
**PHẢI CHECK:**
- [ ] Passage length >= 500 words (NOT summary!)
- [ ] Passage chứa FULL article, không phải summary với blanks
- [ ] Passage có format đúng với paragraph labels nếu cần

**COMMON BUG**: Passage chỉ chứa SUMMARY COMPLETION text (100-200 words) thay vì FULL passage (1000-5000 words).

**FIX**: Extract full passage từ cleaned text:
```python
import re
# Find passage between title and "Questions X-Y"
start = re.search(r'People have dreamt|The passage|Read the text', cleaned_text)
end = re.search(r'Questions \d+-\d+', cleaned_text)
full_passage = cleaned_text[start.start():end.start()].strip()
```

**⚠️ MATCHING_HEADING RULE**: Tách Headings List khỏi Passage!
- **Headings List (i-xi)**: Chỉ dùng cho `options` của MATCHING_HEADING questions
- **Passage (A-H)**: Chỉ chứa nội dung sections, KHÔNG chứa headings list

```
❌ SAI (passage chứa cả headings):
"i. Where to buy... ii. What contained... A. Back in the days..."

✅ ĐÚNG (passage chỉ có sections):
"**A.** Back in the days of America's Wild West..."
"**B.** The remarkable thing about..."
```

#### Role 4: Prompt Extractor
- Extract prompts VERBATIM từ source
- NO paraphrase, NO bịa content
- Check blank markers `_______` cho COMPLETION types
- **MCQ PROMPTS**: Tách options ra khỏi prompt! 
  - ❌ SAI: `"What is X? A. option1 B. option2 C. option3"`
  - ✅ ĐÚNG: `"What is X?"` (options riêng trong options array)

### PHASE 3: STRUCTURE VALIDATION

```bash
// turbo
cat /home/khoa/RiderProjects/Project_Langfens_Microservice/data/normalized/ielts-mentor/<ITEM_ID>.json | head -100
```

#### Role 5: Type Validator
| Source Instruction | Type | Answer Format |
|-------------------|------|---------------|
| "ONE NUMBER/WORD" | SHORT_ANSWER | word/number |
| "TRUE/FALSE/NOT GIVEN" | TRUE_FALSE_NOT_GIVEN | TRUE/FALSE/NG |
| "YES/NO/NOT GIVEN" | YES_NO_NOT_GIVEN | YES/NO/NG |
| "Choose A-F" | MATCHING_INFORMATION | letter |
| "heading i-xi" | MATCHING_HEADING | roman numeral |
| "Match people A-D" | MATCHING_FEATURES | letter with name |

#### Role 6: Option Generator ⚠️ STRICT FORMAT
**Xem @[/ielts-data-format] cho exact schema!**

| Type | Options | MatchPairs |
|------|---------|------------|
| TFNG/YNNG | 3 options: T/F/NG hoặc Y/N/NG | null |
| MCQ_SINGLE | A./B./C./D. format | null |
| SHORT_ANSWER | `[]` empty | null |
| SUMMARY_COMPLETION | `[]` empty | null |
| MATCHING_HEADING | All headings i-xi | `{key: [value, label]}` |
| MATCHING_INFO | `[]` empty | `{key: [letter]}` |
| MATCHING_FEATURES | `[]` empty | `{key: [label, letter]}` |

### PHASE 4: ANSWER VALIDATION

#### Role 7: Answer Verifier
- Tất cả questions có correct_answers
- Answers match source website
- MATCHING: answer letter có trong options

#### Role 8: Check JSON Format ⚠️ STRICT
**PHẢI VERIFY:**
- [ ] `promptMd` không có số đầu (❌ "1. Question" → ✅ "Question")
- [ ] Completion types có blank pattern `_{3,}` (3+ underscores)
- [ ] `options` đúng format cho từng type (xem Role 6)
- [ ] `matchPairs` đúng format cho MATCHING types
- [ ] Đúng 1 option có `isCorrect: true` (trừ MCQ_MULTIPLE)

### PHASE 5: OUTPUT VALIDATION

#### Role 9: Validate SQL Output
- SQL có INSERT statements
- Không có empty strings
- All question data complete

#### Role 10: Ensure Production Quality
- 0 missing answers
- 0 placeholder prompts
- 0 type mismatches
- Options contain correct answer
- **Passage >= 500 words**

---

## TIER 3: ONE-SHOT FIX

```python
import json
import re
from pathlib import Path

data_path = Path(".../normalized/ielts-mentor/<ITEM_ID>.json")
data = json.loads(data_path.read_text())
cleaned = Path(".../cleaned/ielts-mentor/<ITEM_ID>.txt").read_text()

# ===== FIX PASSAGE (if < 500 words) =====
current_passage = data['sections'][0].get('passage_md', '')
if len(current_passage.split()) < 500:
    # Extract full passage from cleaned text
    start = re.search(r'(?:People|The|In|Back|During)', cleaned)
    end = re.search(r'Questions \d+-\d+', cleaned)
    if start and end:
        full_passage = cleaned[start.start():end.start()].strip()
        data['sections'][0]['passage_md'] = full_passage

# ===== FIX QUESTIONS =====
FIXES = {
    28: {"type": "SHORT_ANSWER", "prompt": "When was X?", "answer": "1638", "options": []},
    36: {"type": "MATCHING_FEATURES", "prompt": "Statement...", "answer": "D", 
         "options": [
             {"value": "A", "label": "A. Person Name 1", "is_correct": False},
             {"value": "B", "label": "B. Person Name 2", "is_correct": False},
             {"value": "C", "label": "C. Person Name 3", "is_correct": False},
             {"value": "D", "label": "D. Person Name 4", "is_correct": True},
         ]},
}

for q in data['questions']:
    if q['idx'] in FIXES:
        fix = FIXES[q['idx']]
        q['type'] = fix.get('type', q['type'])
        q['prompt_md'] = fix.get('prompt', q['prompt_md'])
        q['correct_answers'] = [fix['answer']] if 'answer' in fix else q['correct_answers']
        if 'options' in fix:
            q['options'] = fix['options']

data_path.write_text(json.dumps(data, indent=2, ensure_ascii=False))
```

---

## TIER 4: SEED + QA REPORT

```bash
cd .../scripts/pipeline_v2 && python export.py ielts-mentor <ITEM_ID>
```

```bash
PGPASSWORD=exam psql -h localhost -p 5433 -U exam -d exam-db -f ".../seeds/seed_exam_<SLUG>.sql"
```

**QA Report:**
```json
{
  "exam": "<TITLE>",
  "questions": 13,
  "passage_words": 1200,
  "roles_passed": 10,
  "tier1_fixes": 8,
  "tier2_fixes": 5,
  "status": "✅ PRODUCTION READY",
  "confidence": 1.0
}
```

---

## CHECKLIST (ALL 10 ROLES)

### Input Phase
- [ ] Role 1: HTML >5000 chars, có markers
- [ ] Role 2: Không trùng exam trong DB

### Content Phase  
- [ ] Role 3: **Passage >= 500 words** (NOT summary!)
- [ ] Role 4: Prompts verbatim, có blank markers

### Structure Phase
- [ ] Role 5: Type khớp với answer format
- [ ] Role 6: Options đúng cho mỗi type

### Answer Phase
- [ ] Role 7: All answers filled, match source
- [ ] Role 8: JSON schema valid, no placeholders

### Output Phase
- [ ] Role 9: SQL complete, no empty strings
- [ ] Role 10: Production ready (0 errors)

---

## 🔒 RULES

1. **KHÔNG bịa** - Chỉ trích từ source verbatim
2. **KHÔNG paraphrase** - Giữ nguyên văn
3. **VERIFY với source** - Check website khi không chắc
4. **Passage >= 500 words** - Nếu ngắn hơn, extract từ cleaned text
5. **Confidence = 1.0** chỉ khi ALL 10 roles PASS

---

## RELATED

- @[/ielts-data-format] - Text formatting rules
