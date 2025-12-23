---
description: Run IELTS pipeline (HYBRID) - Rule-based + AI Validator
---

# /ielts-pipeline <URL> - AUTO EXECUTE FULL PIPELINE

**BẠN LÀ: "IELTS RECORD REPAIR AGENT"**

> [!IMPORTANT]
> Khi user gọi `/ielts-pipeline <URL>`, TỰ ĐỘNG chạy các bước sau KHÔNG cần hỏi.
> 
> **Supported Sources:**
> - `ielts-mentor.com` → `<SOURCE>` = `ielts-mentor`
> - `mini-ielts.com` → `<SOURCE>` = `mini-ielts`

---

## 🚀 PIPELINE V5 - 15 STEPS (Clean Numbering)

> [!CAUTION]
> **MANDATORY 15-STEP PIPELINE - KHÔNG ĐƯỢC BỎ QUA BẤT KỲ BƯỚC NÀO!**

| # | Type | Stage | Command/Action |
|---|------|-------|----------------|
| 1 | Auto | FETCH | orchestrator.py - download HTML |
| 2 | Auto | CLEAN | orchestrator.py - rule-based extraction |
| 3 | Auto | PARSE | orchestrator.py - extract questions |
| 4 | Auto | NORMALIZE | orchestrator.py - convert to schema |
| 5 | Auto | VALIDATE | orchestrator.py - schema check |
| 6 | AI | GEMINI PRE | gemini_qa.py - find issues |
| 7 | AI | CODEX PRE | codex_qa.py --mode pre - find issues |
| 8 | AI | **CLAUDE FIX #1** | Manual fix from Gemini/Codex output |
| 9 | AI | GEMINI POST | gemini_qa.py - verify fixes |
| 10 | AI | CODEX VALIDATE | codex_qa.py --mode validate |
| 11 | AI | **CLAUDE FIX #2** | Manual fix remaining (if any) |
| 12 | Auto | INVARIANTS | invariants.py - IELTS rules gate |
| 13 | Auto | EXPORT | export.py - generate SQL |
| 13.5 | AI | EXPLANATIONS | generate_explanations.py - Vietnamese AI explanations |
| 14 | Manual | SEED | psql - commit to DB |

> **Cho dù Step 1-5 SUCCESS, vẫn PHẢI chạy đủ 15 bước!**

---

## 📋 STEP-BY-STEP EXECUTION

### Step 1-5: TIER 1 Rule-Based (Auto)
```bash
// turbo
cd /home/khoa/RiderProjects/Project_Langfens_Microservice/scripts/pipeline_v2 && python orchestrator.py "<URL>" 2>&1
```

Read output để xác định `<SOURCE>` và `<ITEM_ID>`:
```bash
// turbo 
cat data/cleaned/<SOURCE>/<ITEM_ID>.txt | head -150
```
```bash
// turbo
cat data/normalized/<SOURCE>/<ITEM_ID>.json | head -100
```

### Step 6: GEMINI PRE-CHECK
```bash
// turbo
cd /home/khoa/RiderProjects/Project_Langfens_Microservice/scripts/pipeline_v2 && timeout 90 python gemini_qa.py <SOURCE> <ITEM_ID> 2>&1
```
**Purpose:** AI phát hiện schema/content issues → output cho Claude FIX

### Step 7: CODEX PRE-CHECK
```bash
// turbo
cd /home/khoa/RiderProjects/Project_Langfens_Microservice/scripts/pipeline_v2 && timeout 600 python codex_qa.py <SOURCE> <ITEM_ID> --mode pre 2>&1
```
**Purpose:** AI phát hiện issues chi tiết hơn → output cho Claude FIX

### Step 8: CLAUDE FIX #1 (Manual)
Đọc output từ Step 6-7 và FIX:

| Issue Pattern | Fix Action |
|---------------|------------|
| Type mismatch | Đổi `type` field |
| Options concatenated | Extract lại từ source |
| Wrong question type | Change to correct type |
| MATCHING_INFO has options | Clear to `[]` |
| Missing instruction_md | Add proper format |
| Multi-passage | Split sections |

**Create fix script:**
```python
#!/usr/bin/env python3
import json
from pathlib import Path
json_path = Path("data/normalized/<SOURCE>/<ITEM_ID>.json")
data = json.loads(json_path.read_text())
# ... apply fixes ...
json_path.write_text(json.dumps(data, indent=2, ensure_ascii=False))
```

**IMPORTANT: After applying any fix script, re-embed images:**
```bash
// turbo
cd /home/khoa/RiderProjects/Project_Langfens_Microservice/scripts/pipeline_v2 && python reembed_images.py <SOURCE> <ITEM_ID>
```
> This ensures images extracted from source are not lost when passageMd is overwritten by fix scripts.

### Step 9: GEMINI POST-CHECK
```bash
// turbo
cd /home/khoa/RiderProjects/Project_Langfens_Microservice/scripts/pipeline_v2 && timeout 90 python gemini_qa.py <SOURCE> <ITEM_ID> 2>&1
```
**Expected:** PASS ✅ (nếu Claude FIX đúng)

### Step 10: CODEX VALIDATE
```bash
// turbo
cd /home/khoa/RiderProjects/Project_Langfens_Microservice/scripts/pipeline_v2 && timeout 600 python codex_qa.py <SOURCE> <ITEM_ID> --mode validate 2>&1
```
**Purpose:** Final validation - có thể FAIL với minor issues

### Step 11: CLAUDE FIX #2 (If needed)
Nếu Step 10 vẫn có issues, fix thêm. Nếu chỉ là typos từ source gốc → bỏ qua.

### Step 12: INVARIANTS
```bash
// turbo
cd /home/khoa/RiderProjects/Project_Langfens_Microservice/scripts/pipeline_v2 && python invariants.py <SOURCE> <ITEM_ID> 2>&1
```
**MUST show: `Valid: True`** (warnings OK)

### Step 13: EXPORT
```bash
cd /home/khoa/RiderProjects/Project_Langfens_Microservice/scripts/pipeline_v2 && python export.py <SOURCE> <ITEM_ID>
```

### Step 13.5: EXPLANATIONS (AI - Optional)
```bash
// turbo
cd /home/khoa/RiderProjects/Project_Langfens_Microservice/scripts/pipeline_v2 && python generate_explanations.py <SOURCE> <ITEM_ID> --provider gemini 2>&1
```
**Purpose:** Tạo giải thích tiếng Việt cho mỗi câu hỏi với:
- Trích dẫn passage (blockquote)
- Giải thích WHY đáp án đúng
- Chỉ ra lỗi thường gặp

> [!TIP]
> Non-blocking step - nếu fail vẫn có thể SEED

### Step 14: SEED
```bash
PGPASSWORD=exam psql -h localhost -p 5433 -U exam -d exam-db -f "deploy/seeds/seed_exam_*.sql"
```

---

## 📊 QA REPORT TEMPLATE

```markdown
## 📋 QA REPORT - Exam <ITEM_ID>

### Pipeline Execution:
| # | Stage | Status | Details |
|---|-------|--------|---------|
| 1-5 | TIER 1 (Auto) | ✅/❌ | X questions, Y words |
| 6 | Gemini PRE | ✅/❌ | PASS/FAIL + issues |
| 7 | Codex PRE | ✅/❌ | PASS/FAIL + confidence |
| 8 | Claude FIX #1 | ✅ | X fixes applied |
| 9 | Gemini POST | ✅/❌ | PASS/FAIL |
| 10 | Codex VALIDATE | ✅/❌ | PASS/FAIL + confidence |
| 11 | Claude FIX #2 | ✅/- | X fixes or N/A |
| 12 | Invariants | ✅/❌ | Valid: True/False |
| 13 | Export | ✅ | SQL generated |
| 14 | Seed | ✅ | COMMIT |

### Fixes Applied:
| Step | Item | Fix |
|------|------|-----|
| 8 | Q5 | Changed type to X |
| 8 | Q6-10 | Fixed options |
| 11 | Q11-14 | Cleared options |

### Final Status:
- **Invariants:** Valid = True ✅
- **DB Status:** COMMIT ✅
```

---

## 🚨 STRICT RULES

### Passage:
| Rule | Format |
|------|--------|
| Paragraph Labels | `**Paragraph A.**\n` |
| No embedded questions | Passage = text only |
| Section separator | `---` between passages |
| Passage length | ≥100 words |

### 📸 passageMd với Diagrams/Images (QUAN TRỌNG):

> [!IMPORTANT]
> Với các bài có DIAGRAM_LABEL, FLOWCHART, MAP_LABEL, hoặc SUMMARY_COMPLETION có hình ảnh:
> **PHẢI embed ảnh vào cuối passageMd** (giống Story of Coffee format)

**Format chuẩn:**
```markdown
# Title

**Paragraph A.**
Text...

**Paragraph B.**
Text...

---

## Diagram: [Tên Diagram] (Questions X-Y)

![Description](image_url)

Complete the diagram:
- **X** _______
- **Y** _______

---

## Flowchart: [Tên Flowchart] (Questions Z-W)

![Description](image_url)

Complete the flowchart:
- **Z** _______
- **W** _______
```

**Quy tắc:**
| Element | Format |
|---------|--------|
| Separator | `---` trước mỗi diagram/flowchart section |
| Heading | `## Diagram: [Name] (Questions X-Y)` |
| Image | `![Description](url)` |
| Labels | `- **X** _______` cho mỗi blank |

**Ví dụ thực tế (Story of Coffee):**
```markdown
---

## Diagram: Structure of a Coffee Bean (Questions 7-9)

![Coffee Bean Structure](http://images.mini-ielts.com/images/process.png)

Complete the labels:
- **7** _______
- **8** _______  
- **9** _______

---

## Flowchart: Coffee Production Process (Questions 10-13)

![Coffee Production Process](http://images.mini-ielts.com/images/process2.png)

Complete the flowchart:
- **10** _______
- **11** _______
- **12** _______
- **13** _______
```

### instructionMd:
| Rule | Format |
|------|--------|
| Giữ nguyên | Copy từ source gốc (web) |
| All groups | Chứa instructions cho TẤT CẢ các nhóm câu hỏi |
| Separator | `---` giữa các nhóm |
| Format | `**Questions X-Y:**` + instruction text |

### Questions:
| Rule | Format |
|------|--------|
| No leading numbers | `Statement` NOT `1. Statement` |
| Blank pattern | `_______` NOT `...` |
| instruction_md | `**Questions X-Y:**` |

### Answers (SHORT_ANSWER):
| Source Format | correct_answers |
|---------------|-----------------|
| `Treasury` | `["Treasury"]` |
| `(commemorative) coin` | `["coin", "commemorative coin"]` |
| `colour// color` | `["colour", "color"]` |

### Types:
| Type | Options | isCorrect |
|------|---------|-----------|
| TFNG/YNNG | 3 items (value=label) | exactly 1 |
| MCQ_SINGLE | 4+ items | exactly 1 |
| MATCHING_INFO | `[]` empty | - |
| MATCHING_FEATURES | `[]` empty | - |
| MATCHING_HEADING | 5+ headings | exactly 1 |

---

## 🔧 FIX TEMPLATES

### Type Fix:
```python
for q in data['questions']:
    if q['idx'] == 5:
        q['type'] = 'YES_NO_NOT_GIVEN'  # or correct type
```

### MCQ Options Fix:
```python
q['options'] = [
    {"label": "A", "text": "...", "is_correct": True},
    {"label": "B", "text": "...", "is_correct": False},
    {"label": "C", "text": "...", "is_correct": False},
    {"label": "D", "text": "...", "is_correct": False},
]
```

### MATCHING Clear Options:
```python
for q in data['questions']:
    if q['type'] in ['MATCHING_INFORMATION', 'MATCHING_FEATURES']:
        q['options'] = []
```

### instruction_md Fix:
```python
data['sections'][0]['instruction_md'] = """**Questions 1-5:**
Do the following statements agree with...

**Questions 6-10:**
Choose the correct letter..."""
```

---

## 🔒 GOLDEN RULES

1. **KHÔNG bịa** - Chỉ trích từ source
2. **KHÔNG paraphrase** - Giữ nguyên văn  
3. **Paragraph labels BẮT BUỘC** - `**Paragraph A.**\n`
4. **MATCHING_INFO/FEATURES options = []**
5. **instruction_md BẮT BUỘC**

---

## 🔗 RELATED

- @[/ielts-data-format] - Strict JSON schemas

---

## 🔄 IMPORTANT PATTERNS (Updated 2024-12-24)

### Pattern Rules for Frontend Display:

| Question Type | Must Have | Frontend Display |
|---------------|-----------|------------------|
| `SUMMARY_COMPLETION` | `_______` in prompt_md | Text input field |
| `MULTIPLE_CHOICE_SINGLE` | options array | Radio buttons |
| `TRUE_FALSE_NOT_GIVEN` | 3 options | Radio buttons |
| `YES_NO_NOT_GIVEN` | 3 options | Radio buttons |
| `MATCHING_HEADING` | options array (i-xi) | Dropdown/Radio |
| `MATCHING_INFORMATION` | options = [] | Text input (single letter) |
| `MATCHING_FEATURES` | options array | Dropdown |

### Gap-fill/Completion Questions:
```python
# Use SUMMARY_COMPLETION with _______ pattern
{
    "type": "SUMMARY_COMPLETION",
    "prompt_md": "The first stage of the process involves _______",
    "correct_answers": ["fermentation"]
}
```

### Choose TWO → Split into 2 MCQ_SINGLE:
```python
# Q27-28 "Choose TWO letters A-E" with answers A, C
# → Split into:
q27 = {"idx": 27, "type": "MULTIPLE_CHOICE_SINGLE", "correct_answers": ["A"]}
q28 = {"idx": 28, "type": "MULTIPLE_CHOICE_SINGLE", "correct_answers": ["C"]}
```

> [!CAUTION]

### After Fix Scripts - Re-embed Images:
```bash
python reembed_images.py <SOURCE> <ITEM_ID>
```

### Choose TWO - Accept Both Answers in Any Order:
> [!IMPORTANT]
> For "Choose TWO" questions, BOTH split questions must accept ALL correct answers.
> This allows users to select answers in any order.

```python
# Q27-28 "Choose TWO letters A-E" with answers A, C
# → BOTH questions accept BOTH A and C:
q27 = {
    "options": [
        {"label": "A", "text": "...", "is_correct": True},
        {"label": "C", "text": "...", "is_correct": True}
    ],
    "correct_answers": ["A", "C"]  # Accept either
}
q28 = {
    "options": [
        {"label": "A", "text": "...", "is_correct": True},
        {"label": "C", "text": "...", "is_correct": True}
    ],
    "correct_answers": ["A", "C"]  # Accept either
}
```

---

## �� UPDATED RULE: Choose TWO/THREE → MULTIPLE_CHOICE_MULTIPLE

> [!IMPORTANT]  
> **Backend và Frontend ĐÃ HỖ TRỢ `MULTIPLE_CHOICE_MULTIPLE`!**
> 
> Thay vì split thành nhiều câu, sử dụng type `MULTIPLE_CHOICE_MULTIPLE` với nhiều `is_correct: true`.

```python
# Q27-28 "Choose TWO letters A-E" with answers A, C
# → 1 câu duy nhất với 2 correct answers:
{
    "idx": 27,
    "type": "MULTIPLE_CHOICE_MULTIPLE",
    "prompt_md": "Which TWO factors are mentioned?",
    "options": [
        {"label": "A", "text": "...", "is_correct": True},
        {"label": "B", "text": "...", "is_correct": False},
        {"label": "C", "text": "...", "is_correct": True},
        {"label": "D", "text": "...", "is_correct": False},
        {"label": "E", "text": "...", "is_correct": False}
    ],
    "correct_answers": ["A", "C"]
}
```

**Frontend:** Hiển thị checkboxes (MultiCheckboxCard)
**Backend:** So sánh array selected với array correct_answers
