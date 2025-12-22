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

## 🚀 AUTO EXECUTION STEPS (Follow in order!)

> [!CAUTION]
> **MANDATORY 10-STEP PIPELINE V3 - KHÔNG ĐƯỢC BỎ QUA BẤT KỲ BƯỚC NÀO!**
> 
> | # | AI | Step | Action |
> |---|-----|------|--------|
> | 1 | Rule | TIER 1 | orchestrator.py (fetch→normalize) |
> | 2 | Gemini | PRE-CHECK | gemini_qa.py --mode pre |
> | 3 | Claude | PRE-FIX | **Manual fix schema issues** |
> | 4 | Gemini | POST-CHECK | gemini_qa.py --mode post |
> | 5 | Codex | VALIDATE | codex_qa.py --mode validate |
> | 6 | Codex | FIX | codex_qa.py --mode fix |
> | 7 | Claude | FINAL-FIX | **Manual fix remaining issues** |
> | 8 | Claude | INVARIANTS | invariants.py |
> | 9 | - | SEED | psql -f seed.sql |
> | 10 | - | QA EXPORT | Generate report |
> 
> **Cho dù TIER 1 SUCCESS, vẫn PHẢI chạy đủ 10 bước!**


### Step 1: Run TIER 1 Rule-Based
```bash
// turbo
cd /home/khoa/RiderProjects/Project_Langfens_Microservice/scripts/pipeline_v2 && python orchestrator.py "<URL>" 2>&1
```

### Step 2: Read Cleaned Text + Normalized JSON
> **Note:** Replace `<SOURCE>` with detected source (`ielts-mentor` or `mini-ielts`)

```bash
// turbo 
cat data/cleaned/<SOURCE>/<ITEM_ID>.txt | head -150
```
```bash
// turbo
cat data/normalized/<SOURCE>/<ITEM_ID>.json | head -100
```

### Step 3: ⭐ Claude CHECK #1 - FIX STRICT RULES
Check và FIX ngay nếu vi phạm:

| Rule | Check | Fix |
|------|-------|-----|
| Passage garbage | Contains user comments | Extract full from cleaned text |
| No paragraph labels | Missing `**Paragraph A.**` | Add proper format |
| Embedded questions | Q1-8 in passage | Remove from passage |
| Wrong type | MCQ_SINGLE ≠ source instruction | Change to correct type |
| MATCHING_INFO options | Has options[] | Clear to `[]` |
| Missing instruction_md | None | Add `**Questions X-Y:**` format |
| Leading numbers | `1. Statement` | Remove number prefix |
| **Multi-Passage** | 2+ distinct texts in 1 section | Split into 2+ sections |
| **MATCHING_HEADING options** | Missing `i. ii. iii.` list | Add all heading options |

**Create fix script if needed:**
```python
# /tmp/fix_<ITEM_ID>.py
import json, re
from pathlib import Path
# ... apply fixes ...
```

### Step 4: ⭐ Gemini POST-CHECK (MANDATORY)
```bash
// turbo
cd /home/khoa/RiderProjects/Project_Langfens_Microservice/scripts/pipeline_v2 && timeout 90 python gemini_qa.py <SOURCE> <ITEM_ID> 2>&1
```
**Record Gemini decision (PASS/FAIL) and issues for QA report.**

### Step 4.5: ⭐ Codex VALIDATE (3rd AI Layer)
```bash
// turbo
cd /home/khoa/RiderProjects/Project_Langfens_Microservice/scripts/pipeline_v2 && timeout 300 python codex_qa.py <SOURCE> <ITEM_ID> --mode validate 2>&1
```
**Record Codex decision (PASS/FAIL) and confidence for QA report.**

### Step 5: ⭐ Codex FIX (Auto-fix content issues)
```bash
// turbo
cd /home/khoa/RiderProjects/Project_Langfens_Microservice/scripts/pipeline_v2 && timeout 300 python codex_qa.py <SOURCE> <ITEM_ID> --mode fix 2>&1
```
**Codex will:**
1. Validate to find issues
2. Auto-fix what it can
3. Re-validate to confirm fixes

### Step 6: ⭐ Claude FINAL-FIX (Manual fix remaining)

Check Codex output. If still issues remain, fix manually.

### Step 7: ⭐ Claude INVARIANTS - Final Verify
```bash
// turbo
python invariants.py <SOURCE> <ITEM_ID> 2>&1
```
**MUST show: `Valid: True`**

### Step 8: Export + Seed
```bash
python export.py <SOURCE> <ITEM_ID>
```
```bash
PGPASSWORD=exam psql -h localhost -p 5433 -U exam -d exam-db -f "deploy/seeds/seed_exam_*.sql"
```

### Step 7: 📋 Full QA Report
**MANDATORY** - Notify user với bảng chi tiết:

```markdown
## 📋 QA REPORT - Exam <ITEM_ID>

### Pipeline Execution:
| Stage | Phase | Status | Details |
|-------|-------|--------|---------|
| 1 | FETCH | ✅/❌ | words count |
| 2 | CLEAN | ✅/❌ | words count |
| 3 | PARSE | ✅/❌ | questions count |
| 4 | NORMALIZE | ✅/❌ | auto-fixes applied |
| 5 | VALIDATE | ✅/❌ | warnings count |
| 6 | INVARIANTS | ✅/❌ | violations count |
| 6.5 | **Gemini** | ✅/❌ | decision + confidence |
| 7 | REPAIR | ✅/❌ | repairs count |
| - | **Claude #1** | ✅/❌ | manual fixes |
| - | **Claude #2** | ✅/❌ | Valid: True/False |
| 8 | EXPORT+SEED | ✅/❌ | COMMIT/FAIL |

### Auto-Fixes (TIER 1):
| Fix | Description |
|-----|-------------|
| ... | ... |

### Claude Fixes (Manual):
| Item | Fix |
|------|-----|
| ... | ... |

### Gemini QA Result:
- Decision: PASS/FAIL
- Confidence: XX%
- Issues: [list]

### Final Validation:
- Invariants: Valid = True/False
- SHORT_ANSWER answers: [table if applicable]

### DB Status: COMMIT/FAIL
```

---

## 🚨 STRICT RULES (MUST FOLLOW!)

> **4 AI CHECK STEPS**: normalize.py → repair.py → Gemini POST → Claude CHECK

### Passage:
| Rule | Format |
|------|--------|
| Paragraph Labels | `**Paragraph A.**\n` |
| No embedded questions | Passage = text only |
| Section separator | `---` between passages |
| Passage length | ≥100 words |

### Multi-Passage Detection (NEW):
| Check | Fix |
|-------|-----|
| Source has 2+ distinct texts | Create 2+ sections |
| Passage contains Q1-7 statements | Remove → questions array |
| Passage has "Paragraph A/B/C" refs | Separate passage for MATCHING_HEADING |
| instruction_md mismatch | Match each section's question type |

### Embedded Questions Detection (NEW):
| Pattern | Action |
|---------|--------|
| `1. Statement...` in passage | Remove → Q array |
| `Paragraph A. 8. ...` | Extract to MATCHING_HEADING |
| Roman numerals `i. ii. iii.` | Extract to MATCHING_HEADING options |
| `A. option B. option` inline | Extract to MCQ options |

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
| `(ornamental) stars` | `["stars", "ornamental stars"]` |
| `colour// color` | `["colour", "color"]` |

> **MANDATORY**: Nếu answer có dạng `(optional) word`, PHẢI có 2 đáp án trong `correct_answers`!

### Types:
| Type | Options | isCorrect |
|------|---------|-----------|
| TFNG | 3 items | exactly 1 |
| MCQ_SINGLE | 4+ items | exactly 1 |
| MATCHING_INFO | `[]` empty | - |
| MATCHING_HEADING | 5+ headings | exactly 1 |

---

## 🔧 FIX TEMPLATES

### Passage Fix:
```python
passage = """# TITLE

**Paragraph A.**
Text paragraph A...

**Paragraph B.**
Text paragraph B..."""
data['sections'][0]['passage_md'] = passage
```

### instruction_md Fix:
```python
data['sections'][0]['instruction_md'] = """**Questions 1-8:**
Do the following statements agree with the information?

Write
- **TRUE** if the statement agrees
- **FALSE** if it contradicts
- **NOT GIVEN** if no information"""
```

### MATCHING_INFO Fix:
```python
for q in data['questions']:
    if q['type'] == 'MATCHING_INFORMATION':
        q['options'] = []
        q['prompt_md'] = re.sub(r'^.*\d+\.\s*', '', q['prompt_md'])
```

---

## 🔒 GOLDEN RULES

1. **KHÔNG bịa** - Chỉ trích từ source
2. **KHÔNG paraphrase** - Giữ nguyên văn  
3. **Paragraph labels BẮT BUỘC** - `**Paragraph A.**\n`
4. **MATCHING_INFO options = []**
5. **instruction_md BẮT BUỘC**

---

## 🔗 RELATED

- @[/ielts-data-format] - Strict JSON schemas
