---
description: Run IELTS pipeline (HYBRID) - Rule-based + AI Validator
---

# /ielts-listening-pipeline <URL> - AUTO EXECUTE LISTENING PIPELINE

**BẠN LÀ: "IELTS LISTENING RECORD AGENT"**

> [!IMPORTANT]
> Khi user gọi `/ielts-listening-pipeline <URL>`, TỰ ĐỘNG chạy các bước sau KHÔNG cần hỏi.

---

## 🚀 AUTO EXECUTION STEPS (Follow in order!)

> [!CAUTION] > **MANDATORY 10-STEP PIPELINE V4 - KHÔNG ĐƯỢC BỎ QUA BẤT KỲ BƯỚC NÀO!**
>
> | #   | AI     | Step                  | Action                                |
> | --- | ------ | --------------------- | ------------------------------------- |
> | 1   | Rule   | TIER 1                | orchestrator.py (fetch→normalize)    |
> | 2   | Gemini | PRE-CHECK             | gemini_qa.py --mode pre              |
> | 3   | Codex  | PRE-CHECK             | codex_qa.py --mode pre               |
> | 4   | Claude | PRE-FIX               | **Manual fix schema issues**         |
> | 5   | Gemini | POST-CHECK            | gemini_qa.py --mode post             |
> | 6   | Codex  | VALIDATE              | codex_qa.py --mode validate (CHỈ NHẬN XÉT) |
> | 7   | Claude | FINAL-FIX             | **Manual fix based on Codex feedback** |
> | 8   | Claude | INVARIANTS            | invariants.py                        |
> | 9   | -      | SEED                  | psql -f seed.sql                     |
> | 10  | -      | QA EXPORT             | Generate report                      |
>
> **Codex chỉ VALIDATE + nhận xét, CLAUDE fix tất cả!**


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

| Rule               | Check                     | Fix                                       |
| ------------------ | ------------------------- | ----------------------------------------- |
| Missing audio_url  | No YouTube embed          | Extract from iframe src                   |
| Missing transcript | No Exam Review            | Fetch from solution page                  |
| Embedded questions | Q1-10 in passage          | Remove from passage                       |
| Wrong type         | MCQ vs Gap-fill           | Match source instruction                  |
| Missing answers    | Empty correct_answers     | Extract from solution table               |
| Leading numbers    | `1. Statement`            | Remove number prefix                      |
| **MAP_LABEL**      | "Label the plan/diagram"  | **Convert to MATCHING_INFORMATION**       |
| **Choose TWO**     | Q1-2 "Choose TWO letters" | **Split to 2 separate MCQ_SINGLE**        |
| **Passage short**  | < 100 words               | Expand with listening notes from questions|

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

### Step 4.5: ⭐ Codex VALIDATE (NEW - 3rd AI Layer)

```bash
// turbo
cd /home/khoa/RiderProjects/Project_Langfens_Microservice/scripts/pipeline_v2 && timeout 300 python codex_qa.py mini-ielts <ITEM_ID> --mode validate 2>&1
```

**Record Codex decision (PASS/FAIL) and confidence for QA report.**

### Step 5: ⭐ Claude FINAL-FIX (Fix based on Codex feedback)

**Dựa trên nhận xét của Codex VALIDATE, Claude fix các vấn đề sau:**

| Codex Feedback | Claude Action |
| -------------- | ------------- |
| Wrong question type | Change `type` field to correct value |
| Missing option text | Add proper text from HTML source |
| Truncated prompt | Fix full text (e.g., "sia" → "Asia") |
| Content completeness | Add missing context/options |
| Answer mismatch | Verify and correct `correct_answers` |

**Create fix script if Codex found issues:**

```python
# Fix based on Codex feedback
import json
from pathlib import Path

NORMALIZED_PATH = Path("data/normalized/mini-ielts/<ITEM_ID>.json")
with open(NORMALIZED_PATH) as f:
    data = json.load(f)

# Apply fixes based on Codex suggestions...
# e.g., change type, add options, fix prompts

with open(NORMALIZED_PATH, 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
```

### Step 7: ⭐ Claude INVARIANTS - Final Verify

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

| Stage | Phase         | Status | Details                     |
| ----- | ------------- | ------ | --------------------------- |
| 1     | FETCH         | ✅/❌  | test page + solution page   |
| 2     | CLEAN         | ✅/❌  | words count                 |
| 3     | PARSE         | ✅/❌  | questions count + audio URL |
| 4     | NORMALIZE     | ✅/❌  | auto-fixes applied          |
| 5     | VALIDATE      | ✅/❌  | warnings count              |
| 6     | INVARIANTS    | ✅/❌  | violations count            |
| 6.5   | **Gemini**    | ✅/❌  | decision + confidence       |
| 7     | REPAIR        | ✅/❌  | repairs count               |
| -     | **Claude #1** | ✅/❌  | manual fixes                |
| -     | **Claude #2** | ✅/❌  | Valid: True/False           |
| 8     | EXPORT+SEED   | ✅/❌  | COMMIT/FAIL                 |

### Audio & Transcript:

| Field      | Status | URL/Length        |
| ---------- | ------ | ----------------- |
| Audio URL  | ✅/❌  | YouTube embed URL |
| Transcript | ✅/❌  | X words           |

### Sections (Full IELTS = 4 parts):

| Part   | Questions | Types        |
| ------ | --------- | ------------ |
| Part 1 | Q1-10     | Gap-fill     |
| Part 2 | Q11-20    | MCQ/Matching |
| Part 3 | Q21-30    | Gap-fill     |
| Part 4 | Q31-40    | Gap-fill     |

### DB Status: COMMIT/FAIL
```

---

## 🔊 LISTENING SPECIFIC RULES

### Audio:

| Rule          | Format                                   |
| ------------- | ---------------------------------------- |
| YouTube embed | `https://www.youtube.com/embed/VIDEO_ID` |
| Audio field   | `audio_url` in exam metadata             |

### Transcript:

| Rule    | Format                      |
| ------- | --------------------------- |
| Source  | Solution page → Exam Review |
| Storage | `transcript_md` in section  |

### Question Types (Listening):

| Type                 | Description              | Options     | Notes                            |
| -------------------- | ------------------------ | ----------- | -------------------------------- |
| SUMMARY_COMPLETION   | Gap-fill/Write word      | `[]` empty  | Dùng cho Q1-10 thường            |
| MCQ_SINGLE           | Choose A/B/C             | 3-4 options | Choose ONE letter                |
| MATCHING_INFORMATION | Match/Label diagram A-G  | `[]` empty  | **Dùng cho cả MAP_LABEL**        |

> [!IMPORTANT]
> **MAP_LABEL → MATCHING_INFORMATION**: Khi gặp "Label the plan/diagram", convert thành `MATCHING_INFORMATION`:
> - `prompt_md`: tên vị trí (vd: "box office")
> - `options`: `[]` (empty)
> - `correct_answers`: `["G"]` (letter)

> [!TIP]
> **Choose TWO letters → 2 MCQ_SINGLE**: Khi gặp Q1-2 "Choose TWO", tách thành 2 câu MCQ_SINGLE riêng biệt:
> - Q1: Answer 1 of 2 (correct: first answer)
> - Q2: Answer 2 of 2 (correct: second answer)

### Sections:

| Part   | Typical Content                 |
| ------ | ------------------------------- |
| Part 1 | Daily conversation (2 speakers) |
| Part 2 | Monologue (social context)      |
| Part 3 | Discussion (academic)           |
| Part 4 | Lecture (academic)              |

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

### MAP_LABEL → MATCHING_INFORMATION Fix:

```python
# Convert "Label the plan/diagram" questions
# Q7-10: answers G, D, B, F
matching_answers = {
    7: ("box office", "G"),
    8: ("theatre manager's office", "D"),
    9: ("lighting box", "B"),
    10: ("artistic director's office", "F")
}

for idx, (prompt, answer) in matching_answers.items():
    new_questions.append({
        "idx": idx,
        "type": "MATCHING_INFORMATION",  # NOT MAP_LABEL
        "prompt_md": prompt,
        "options": [],  # empty for matching
        "correct_answers": [answer]
    })
```

### Choose TWO → 2 MCQ_SINGLE Fix:

```python
# Split Q1-2 "Choose TWO letters A,E" into 2 separate questions
# Answer 1 = A, Answer 2 = E
new_questions.append({
    "idx": 1,
    "type": "MULTIPLE_CHOICE_SINGLE",
    "prompt_md": "Which change during refurbishment? (Answer 1 of 2)",
    "options": [
        {"label": "A", "text": "Option A text", "is_correct": True},
        {"label": "B", "text": "Option B text", "is_correct": False},
        # ... other options
    ],
    "correct_answers": ["A"]
})

new_questions.append({
    "idx": 2,
    "type": "MULTIPLE_CHOICE_SINGLE",
    "prompt_md": "Which change during refurbishment? (Answer 2 of 2)",
    "options": [
        {"label": "A", "text": "Option A text", "is_correct": False},
        {"label": "E", "text": "Option E text", "is_correct": True},
        # ... other options with E as correct
    ],
    "correct_answers": ["E"]
})
```

---

## 🔗 SOURCES

| Source           | URL Pattern                            | Status    |
| ---------------- | -------------------------------------- | --------- |
| mini-ielts.com   | `mini-ielts.com/{id}/listening/{slug}` | ✅ Active |
| ielts-mentor.com | `ielts-mentor.com/listening-sample`    | 🔮 Future |

---

## 🔗 RELATED

- @[/ielts-pipeline] - Reading pipeline
- @[/ielts-data-format] - Strict JSON schemas
