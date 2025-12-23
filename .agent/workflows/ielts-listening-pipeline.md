---
description: Run IELTS Listening pipeline (HYBRID) - Rule-based + AI Validator
---

# /ielts-listening-pipeline <URL> - AUTO EXECUTE LISTENING PIPELINE

**BẠN LÀ: "IELTS LISTENING RECORD AGENT"**

> [!IMPORTANT]
> Khi user gọi `/ielts-listening-pipeline <URL>`, TỰ ĐỘNG chạy các bước sau KHÔNG cần hỏi.

---

## 🚀 PIPELINE V5 - 14 STEPS (Clean Numbering)

> [!CAUTION]
> **MANDATORY 14-STEP PIPELINE - KHÔNG ĐƯỢC BỎ QUA BẤT KỲ BƯỚC NÀO!**

| # | Type | Stage | Command/Action |
|---|------|-------|----------------|
| 1 | Auto | FETCH | orchestrator.py --type listening |
| 2 | Auto | CLEAN | orchestrator.py - extract transcript |
| 3 | Auto | PARSE | orchestrator.py - extract questions |
| 4 | Auto | NORMALIZE | orchestrator.py - convert to schema |
| 5 | Auto | VALIDATE | orchestrator.py - schema check |
| 6 | AI | GEMINI PRE | gemini_qa.py --type listening |3
| 7 | AI | CODEX PRE | codex_qa.py --mode pre |
| 8 | AI | **CLAUDE FIX #1** | Manual fix from Gemini/Codex output |
| 9 | AI | GEMINI POST | gemini_qa.py --type listening |
| 10 | AI | CODEX VALIDATE | codex_qa.py --mode validate |
| 11 | AI | **CLAUDE FIX #2** | Manual fix remaining (if any) |
| 12 | Auto | INVARIANTS | invariants.py --type listening |
| 13 | Auto | EXPORT | export.py --type listening |
| 13.5 | AI | EXPLANATIONS | generate_explanations.py - Vietnamese AI explanations |
| 14 | Manual | SEED | psql - commit to DB |

> **Cho dù Step 1-5 SUCCESS, vẫn PHẢI chạy đủ 15 bước!**

---

## 📋 STEP-BY-STEP EXECUTION

### Step 1-5: TIER 1 Rule-Based (Auto)
```bash
// turbo
cd /home/khoa/RiderProjects/Project_Langfens_Microservice/scripts/pipeline_v2 && python orchestrator.py "<URL>" --type listening 2>&1
```

Read output để xác định `<ITEM_ID>`:
```bash
// turbo
cat data/cleaned/mini-ielts/<ITEM_ID>.txt | head -150
```
```bash
// turbo
cat data/normalized/mini-ielts/<ITEM_ID>.json | head -100
```

### Step 6: GEMINI PRE-CHECK
```bash
// turbo
cd /home/khoa/RiderProjects/Project_Langfens_Microservice/scripts/pipeline_v2 && timeout 90 python gemini_qa.py mini-ielts <ITEM_ID> --type listening 2>&1
```
**Purpose:** AI phát hiện schema/content issues → output cho Claude FIX

### Step 7: CODEX PRE-CHECK
```bash
// turbo
cd /home/khoa/RiderProjects/Project_Langfens_Microservice/scripts/pipeline_v2 && timeout 300 python codex_qa.py mini-ielts <ITEM_ID> --mode pre 2>&1
```
**Purpose:** AI phát hiện issues chi tiết → output cho Claude FIX

### Step 8: CLAUDE FIX #1 (Manual)
Đọc output từ Step 6-7 và FIX:

| Issue Pattern | Fix Action |
|---------------|------------|
| MAP_LABEL type | Convert to MATCHING_INFORMATION |
| Choose TWO | Split to 2 MCQ_SINGLE |
| Passage < 100 words | Use full transcript |
| Missing audio_url | Extract from iframe |
| Options concatenated | Extract lại từ source |
| Wrong question type | Change to correct type |

**Create fix script:**
```python
#!/usr/bin/env python3
import json
from pathlib import Path
json_path = Path("data/normalized/mini-ielts/<ITEM_ID>.json")
data = json.loads(json_path.read_text())
# ... apply fixes ...
json_path.write_text(json.dumps(data, indent=2, ensure_ascii=False))
```

### Step 9: GEMINI POST-CHECK
```bash
// turbo
cd /home/khoa/RiderProjects/Project_Langfens_Microservice/scripts/pipeline_v2 && timeout 90 python gemini_qa.py mini-ielts <ITEM_ID> --type listening 2>&1
```
**Expected:** PASS ✅ (nếu Claude FIX đúng)

### Step 10: CODEX VALIDATE
```bash
// turbo
cd /home/khoa/RiderProjects/Project_Langfens_Microservice/scripts/pipeline_v2 && timeout 300 python codex_qa.py mini-ielts <ITEM_ID> --mode validate 2>&1
```
**Purpose:** Final validation - có thể FAIL với minor issues

### Step 11: CLAUDE FIX #2 (If needed)
Nếu Step 10 vẫn có issues, fix thêm. Nếu chỉ là typos từ source gốc → bỏ qua.

### Step 12: INVARIANTS
```bash
// turbo
cd /home/khoa/RiderProjects/Project_Langfens_Microservice/scripts/pipeline_v2 && python invariants.py mini-ielts <ITEM_ID> --type listening 2>&1
```
**MUST show: `Valid: True`** (warnings OK)

### Step 13: EXPORT
```bash
cd /home/khoa/RiderProjects/Project_Langfens_Microservice/scripts/pipeline_v2 && python export.py mini-ielts <ITEM_ID> --type listening
```

### Step 13.5: EXPLANATIONS (AI - Optional)
```bash
// turbo
cd /home/khoa/RiderProjects/Project_Langfens_Microservice/scripts/pipeline_v2 && python generate_explanations.py mini-ielts <ITEM_ID> --provider gemini 2>&1
```
**Purpose:** Tạo giải thích tiếng Việt cho mỗi câu hỏi với:
- Trích dẫn transcript (blockquote)
- Giải thích WHY đáp án đúng
- Chỉ ra lỗi thường gặp

> [!TIP]
> Non-blocking step - nếu fail vẫn có thể SEED

### Step 14: SEED
```bash
PGPASSWORD=exam psql -h localhost -p 5433 -U exam -d exam-db -f "deploy/seeds/seed_listening_*.sql"
```

---

## 📊 QA REPORT TEMPLATE

```markdown
## 📋 QA REPORT - Listening <ITEM_ID>

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

### Audio & Transcript:
| Field | Status | Value |
|-------|--------|-------|
| Audio URL | ✅/❌ | YouTube embed URL |
| Transcript | ✅/❌ | X words |

### Fixes Applied:
| Step | Item | Fix |
|------|------|-----|
| 8 | Q1-2 | Split Choose TWO → 2 MCQ_SINGLE |
| 8 | Q7-10 | MAP_LABEL → MATCHING_INFORMATION |

### Final Status:
- **Invariants:** Valid = True ✅
- **DB Status:** COMMIT ✅
```

---

## 🔊 LISTENING SPECIFIC RULES

### Audio:
| Rule | Format |
|------|--------|
| YouTube embed | `https://www.youtube.com/embed/VIDEO_ID` |
| Audio field | `audio_url` in exam metadata |

### Transcript:
| Rule | Format |
|------|--------|
| Source | Solution page → Exam Review |
| Storage | `passage_md` in section (transcript as passage) |
| Min length | ≥100 words |

### Question Types (Listening):
| Type | Description | Options | Notes |
|------|-------------|---------|-------|
| SUMMARY_COMPLETION | Gap-fill/Write word | `[]` empty | Q1-10 typical |
| SHORT_ANSWER | Write answer | `[]` empty | Similar to gap-fill |
| MCQ_SINGLE | Choose A/B/C | 3-4 options | Choose ONE letter |
| MATCHING_INFORMATION | Match/Label A-G | `[]` empty | **For MAP_LABEL too** |

### Special Cases:
> [!IMPORTANT]
> **MAP_LABEL → MATCHING_INFORMATION**
> ```python
> q['type'] = 'MATCHING_INFORMATION'
> q['options'] = []
> q['correct_answers'] = ['G']  # letter only
> ```

> [!TIP]
> **Choose TWO → 2 MCQ_SINGLE**
> ```python
> # Split Q1-2 "Choose TWO letters A,E" into 2 separate questions
> # Q1: correct = A, Q2: correct = E
> ```

---

## 🔧 FIX TEMPLATES

### MAP_LABEL → MATCHING_INFORMATION:
```python
for q in data['questions']:
    if 'MAP_LABEL' in q.get('type', ''):
        q['type'] = 'MATCHING_INFORMATION'
        q['options'] = []
```

### Choose TWO → 2 MCQ_SINGLE:
```python
# Original: Q1-2 "Choose TWO letters" with answers A, E
new_q1 = {
    "idx": 1,
    "type": "MULTIPLE_CHOICE_SINGLE",
    "prompt_md": "Which TWO changes? (Answer 1 of 2)",
    "options": [...],  # mark A as correct
    "correct_answers": ["A"]
}
new_q2 = {
    "idx": 2,
    "type": "MULTIPLE_CHOICE_SINGLE", 
    "prompt_md": "Which TWO changes? (Answer 2 of 2)",
    "options": [...],  # mark E as correct
    "correct_answers": ["E"]
}
```

### Passage Expansion (if < 100 words):
```python
# Use full transcript from solution page
data['sections'][0]['passage_md'] = full_transcript
```

### Audio URL Fix:
```python
import re
iframe_match = re.search(r'src="(https://www\.youtube\.com/embed/[^"]+)"', html)
data['exam']['audio_url'] = iframe_match.group(1) if iframe_match else None
```

---

## 🔒 GOLDEN RULES

1. **KHÔNG bịa** - Chỉ trích từ source
2. **KHÔNG paraphrase** - Giữ nguyên văn
3. **Passage ≥ 100 words** - Use full transcript if needed
4. **MATCHING_INFORMATION options = []**
5. **audio_url BẮT BUỘC** - Must have YouTube embed

---

## 🔗 SOURCES

| Source | URL Pattern | Status |
|--------|-------------|--------|
| mini-ielts.com | `mini-ielts.com/{id}/listening/{slug}` | ✅ Active |
| ielts-mentor.com | `ielts-mentor.com/listening-sample` | 🔮 Future |

---

## 🔗 RELATED

- @[/ielts-pipeline] - Reading pipeline
- @[/ielts-data-format] - Strict JSON schemas