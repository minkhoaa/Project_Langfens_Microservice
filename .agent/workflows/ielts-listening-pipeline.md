# /ielts-listening-pipeline <URL> - AUTO EXECUTE LISTENING PIPELINE

**BẠN LÀ: "IELTS LISTENING RECORD AGENT"**

> [!IMPORTANT]
> Khi user gọi `/ielts-listening-pipeline <URL>`, TỰ ĐỘNG chạy các bước sau KHÔNG cần hỏi.

---

## 🚀 AUTO EXECUTION STEPS (Follow in order!)

> [!CAUTION]
> **MANDATORY 4 AI CHECKS - KHÔNG ĐƯỢC BỎ QUA BẤT KỲ BƯỚC NÀO!**
> 
> | # | AI | Step | Action |
> |---|-----|------|--------|
> | 1 | Gemini | TIER 1 (orchestrator) | Auto-run in pipeline |
> | 2 | Claude | CHECK #1 | **LUÔN check issues** |
> | 3 | Gemini | POST-CHECK | **LUÔN chạy gemini_qa.py** |
> | 4 | Claude | CHECK #2 | **LUÔN chạy invariants.py** |
> 
> **Cho dù TIER 1 SUCCESS, vẫn PHẢI chạy đủ 4 bước!**

---

### Step 1: Run TIER 1 Rule-Based
```bash
// turbo
cd /home/khoa/RiderProjects/Project_Langfens_Microservice/scripts/pipeline_v2 && python orchestrator.py "<URL>" --type listening 2>&1
```

### Step 2: Read Cleaned Text + Normalized JSON
```bash
// turbo 
cat data/cleaned/mini-ielts/<ITEM_ID>.txt | head -150
```
```bash
// turbo
cat data/normalized/mini-ielts/<ITEM_ID>.json | head -100
```

### Step 3: ⭐ Claude CHECK #1 - FIX STRICT RULES
Check và FIX ngay nếu vi phạm:

| Rule | Check | Fix |
|------|-------|-----|
| Missing audio_url | No YouTube embed | Extract from iframe src |
| Missing transcript | No Exam Review | Fetch from solution page |
| Embedded questions | Q1-10 in passage | Remove from passage |
| Wrong type | MCQ vs Gap-fill | Match source instruction |
| Missing answers | Empty correct_answers | Extract from solution table |
| Leading numbers | `1. Statement` | Remove number prefix |
| **4 Sections** | Parts 1-4 | Create proper sections |

**Create fix script if needed:**
```python
# /tmp/fix_listening_<ITEM_ID>.py
import json, re
from pathlib import Path
# ... apply fixes ...
```

### Step 4: ⭐ Gemini POST-CHECK (MANDATORY)
```bash
// turbo
cd /home/khoa/RiderProjects/Project_Langfens_Microservice/scripts/pipeline_v2 && timeout 90 python gemini_qa.py mini-ielts <ITEM_ID> --type listening 2>&1
```
**Record Gemini decision (PASS/FAIL) and issues for QA report.**

### Step 5: ⭐ Claude CHECK #2 - Final Verify
```bash
// turbo
python invariants.py mini-ielts <ITEM_ID> --type listening 2>&1
```
**MUST show: `Valid: True`**

### Step 6: Export + Seed
```bash
python export.py mini-ielts <ITEM_ID> --type listening
```
```bash
PGPASSWORD=exam psql -h localhost -p 5433 -U exam -d exam-db -f "deploy/seeds/seed_listening_*.sql"
```

### Step 7: 📋 Full QA Report
**MANDATORY** - Notify user với bảng chi tiết:

```markdown
## 📋 QA REPORT - Listening <ITEM_ID>

### Pipeline Execution:
| Stage | Phase | Status | Details |
|-------|-------|--------|---------|
| 1 | FETCH | ✅/❌ | test page + solution page |
| 2 | CLEAN | ✅/❌ | words count |
| 3 | PARSE | ✅/❌ | questions count + audio URL |
| 4 | NORMALIZE | ✅/❌ | auto-fixes applied |
| 5 | VALIDATE | ✅/❌ | warnings count |
| 6 | INVARIANTS | ✅/❌ | violations count |
| 6.5 | **Gemini** | ✅/❌ | decision + confidence |
| 7 | REPAIR | ✅/❌ | repairs count |
| - | **Claude #1** | ✅/❌ | manual fixes |
| - | **Claude #2** | ✅/❌ | Valid: True/False |
| 8 | EXPORT+SEED | ✅/❌ | COMMIT/FAIL |

### Audio & Transcript:
| Field | Status | URL/Length |
|-------|--------|------------|
| Audio URL | ✅/❌ | YouTube embed URL |
| Transcript | ✅/❌ | X words |

### Sections (Full IELTS = 4 parts):
| Part | Questions | Types |
|------|-----------|-------|
| Part 1 | Q1-10 | Gap-fill |
| Part 2 | Q11-20 | MCQ/Matching |
| Part 3 | Q21-30 | Gap-fill |
| Part 4 | Q31-40 | Gap-fill |

### DB Status: COMMIT/FAIL
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
| Storage | `transcript_md` in section |

### Question Types (Listening):
| Type | Description | Options |
|------|-------------|---------|
| GAP_FILL | Write word/number | `[]` empty |
| MCQ_SINGLE | Choose A/B/C | 3-4 options |
| MATCHING | Match A-F | Letter input |
| MAP_LABEL | Label diagram | Position-based |

### Sections:
| Part | Typical Content |
|------|-----------------|
| Part 1 | Daily conversation (2 speakers) |
| Part 2 | Monologue (social context) |
| Part 3 | Discussion (academic) |
| Part 4 | Lecture (academic) |

---

## 🔧 FIX TEMPLATES

### Audio URL Fix:
```python
# Extract YouTube embed URL
import re
iframe_match = re.search(r'src="(https://www\.youtube\.com/embed/[^"]+)"', html)
audio_url = iframe_match.group(1) if iframe_match else None
data['exam']['audio_url'] = audio_url
```

### Transcript Fix:
```python
# Fetch solution page
solution_url = url.replace('/listening/', '/view-solution/listening/')
# Parse Exam Review section
transcript = extract_transcript(solution_html)
data['sections'][0]['transcript_md'] = transcript
```

### Gap-Fill Answer Fix:
```python
# From solution table
for q in data['questions']:
    if q['type'] == 'GAP_FILL':
        q['correct_answers'] = [answer.strip()]
        q['options'] = []
```

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
