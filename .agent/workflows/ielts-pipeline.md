---
description: Run IELTS pipeline and act as final validator for content and context
---

# /ielts-pipeline - IELTS Crawl + AI Final Validator Workflow

**BẠN LÀ: "IELTS RECORD REPAIR AGENT"** - Agent parse, validate, và fix dữ liệu IELTS.
**MỤC TIÊU**: Output chuẩn render frontend ĐÚNG TỪ source, KHÔNG paraphrase, KHÔNG bịa.

---

## 📋 WORKFLOW STEPS

### Bước 1: Chạy Pipeline V2
```bash
// turbo
cd /home/khoa/RiderProjects/Project_Langfens_Microservice/scripts/pipeline_v2 && python orchestrator.py "<URL>" 2>&1
```

### Bước 2: Load dữ liệu đã parse
```bash
// turbo
cat /home/khoa/RiderProjects/Project_Langfens_Microservice/data/normalized/ielts-mentor/<ITEM_ID>.json
```

```bash
// turbo  
cat /home/khoa/RiderProjects/Project_Langfens_Microservice/data/cleaned/ielts-mentor/<ITEM_ID>.txt | head -150
```

### Bước 3: AI FINAL VALIDATION (BẮT BUỘC!)

Bạn PHẢI kiểm tra từng item dưới đây:

#### 3.1 QUESTION TYPE VALIDATION
| Type | Expected Format | Common Errors |
|------|-----------------|---------------|
| MATCHING_INFORMATION (A-Z) | Options: single letters A,B,C... | ❌ Full paragraphs as options |
| MATCHING_HEADING (i-x) | Options: roman numerals + heading text | ❌ Missing heading text |
| TRUE_FALSE_NOT_GIVEN | Options: TRUE, FALSE, NOT GIVEN | ❌ Wrong type (confused with MATCHING) |
| YES_NO_NOT_GIVEN | Options: YES, NO, NOT GIVEN | ❌ Confused with TFNG |
| SUMMARY_COMPLETION | Prompt has blank marker `_______` | ❌ Placeholder prompts like "Question 1" |
| MULTIPLE_CHOICE_SINGLE | Options: A. text, B. text... | ❌ Missing option labels |

#### 3.2 PROMPT VALIDATION
- [ ] Prompts có nội dung thực tế không? (không phải "Question 1", "Statement 9")
- [ ] Prompts được trích NGUYÊN VĂN từ source?
- [ ] COMPLETION types có blank marker `_______`?
- [ ] Blank marker đúng vị trí? (`Question? _______` không phải `Question _______?`)

#### 3.3 PASSAGE VALIDATION  
- [ ] Passage có đủ nội dung?
- [ ] MATCHING questions: Passage có paragraph labels (A, B, C...) với format:
  ```markdown
  **A.** Paragraph text...
  
  **B.** Paragraph text...
  ```
- [ ] Không có noise (questions, instructions lẫn trong passage)?

#### 3.4 ANSWER VALIDATION
- [ ] Tất cả questions có `correct_answers`?
- [ ] Answers khớp với source website?
- [ ] MATCHING: Options có chứa correct answer? (VD: answer "G" thì options phải có G)

### Bước 4: Apply Fixes (Python Script)

```python
import json
from pathlib import Path

data_path = Path("/home/khoa/RiderProjects/Project_Langfens_Microservice/data/normalized/ielts-mentor/<ITEM_ID>.json")
data = json.loads(data_path.read_text())

# Fix prompts - extract verbatim from source
CORRECT_PROMPTS = {
    1: "Actual question text from source...",
    # ...
}

# Fix answers
CORRECT_ANSWERS = {
    1: "A", 2: "B",  # MATCHING
    9: "TRUE", 10: "FALSE",  # TFNG
}

for q in data['questions']:
    idx = q['idx']
    
    # Fix prompt
    if idx in CORRECT_PROMPTS:
        q['prompt_md'] = CORRECT_PROMPTS[idx]
    
    # Fix type và options
    if idx >= 9:  # TFNG section
        q['type'] = 'TRUE_FALSE_NOT_GIVEN'
        q['options'] = [
            {"value": "TRUE", "label": "TRUE", "is_correct": CORRECT_ANSWERS[idx] == "TRUE"},
            {"value": "FALSE", "label": "FALSE", "is_correct": CORRECT_ANSWERS[idx] == "FALSE"},
            {"value": "NOT GIVEN", "label": "NOT GIVEN", "is_correct": CORRECT_ANSWERS[idx] == "NOT GIVEN"}
        ]
        q['correct_answers'] = [CORRECT_ANSWERS[idx]]

# Fix passage format for MATCHING questions
passage_formatted = """**Title**

**A.** Paragraph A text...

**B.** Paragraph B text...
"""
data['sections'][0]['passage_md'] = passage_formatted

data_path.write_text(json.dumps(data, indent=2, ensure_ascii=False))
```

### Bước 5: Re-export và Seed
```bash
cd /home/khoa/RiderProjects/Project_Langfens_Microservice/scripts/pipeline_v2 && python export.py ielts-mentor <ITEM_ID>
```

```bash
PGPASSWORD=exam psql -h localhost -p 5433 -U exam -d exam-db -f "/home/khoa/RiderProjects/Project_Langfens_Microservice/deploy/seeds/seed_exam_<SLUG>.sql"
```

### Bước 6: Output Report
```json
{
  "status": "PASS",
  "confidence": 1.0,
  "questions_verified": 14,
  "answers_verified": 14,
  "issues_found": ["Q14 wrong type", "Q1-8 placeholder prompts"],
  "fixes_applied": ["Fixed Q14 type", "Extracted actual prompts", "Formatted passage"]
}
```

---

## ⚠️ COMMON ISSUES & FIXES

### Issue 1: Placeholder Prompts
**Symptom**: `"prompt_md": "Question 1"` hoặc `"Statement 9"`
**Fix**: Extract actual question text từ source website

### Issue 2: Wrong Question Type
**Symptom**: Q9-14 là TFNG nhưng được parse thành MATCHING_INFORMATION
**Fix**: Check source instructions ("TRUE/FALSE/NOT GIVEN" vs "Write correct letter A-H")

### Issue 3: Paragraph Options (Noise)
**Symptom**: MATCHING options chứa full paragraph text thay vì A/B/C
**Fix**: Pipeline auto-repairs this, nhưng verify options are simple letters

### Issue 4: Missing Paragraph Labels
**Symptom**: Passage không có **A.** **B.** format
**Fix**: Format passage với bold paragraph labels và line breaks

### Issue 5: Missing Option
**Symptom**: Answer là "G" nhưng options chỉ có A-F
**Fix**: Add missing option G

### Issue 6: Blank Marker Position
**Symptom**: `"Question _______?"` (? sau blank)
**Fix**: `"Question? _______"` (? trước blank)

---

## 🔒 QUY TẮC CỨNG

1. **KHÔNG bịa nội dung** - Chỉ trích từ source verbatim
2. **KHÔNG paraphrase** - Giữ nguyên văn
3. **PHẢI verify với source** - Check website gốc nếu không chắc
4. **PHẢI check từng question type** - Dựa vào instructions trong passage
5. **Confidence = 1.0** chỉ khi TẤT CẢ verified 100%

---

## 📊 QUESTION TYPE REFERENCE

| Instructions Pattern | Type |
|---------------------|------|
| "Write the correct letter, A-H" | MATCHING_INFORMATION |
| "TRUE/FALSE/NOT GIVEN" | TRUE_FALSE_NOT_GIVEN |
| "YES/NO/NOT GIVEN" | YES_NO_NOT_GIVEN |
| "Choose ONE WORD ONLY" | SUMMARY_COMPLETION |
| "Complete the sentences" | SENTENCE_COMPLETION |
| "Which paragraph contains..." | MATCHING_INFORMATION |
| "List of headings" with i, ii, iii | MATCHING_HEADING |

---

## 🗂️ FILE PATHS

- Raw HTML: `/data/raw/ielts-mentor/<ITEM_ID>.html`
- Cleaned text: `/data/cleaned/ielts-mentor/<ITEM_ID>.txt`
- Extracted JSON: `/data/extracted/ielts-mentor/<ITEM_ID>.json`
- Normalized JSON: `/data/normalized/ielts-mentor/<ITEM_ID>.json`
- Output SQL: `/deploy/seeds/seed_exam_<SLUG>.sql`
