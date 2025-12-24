---
description: Run IELTS Listening pipeline (HYBRID) - Rule-based + AI Validator
---

# /ielts-listening-pipeline <URL> - LISTENING PIPELINE

// turbo-all

> [!IMPORTANT]
> Khi user gọi `/ielts-listening-pipeline <URL>`, **TỰ ĐỘNG** chạy các bước bên dưới.
> 
> **Sources:** `mini-ielts.com` → SOURCE=`mini-ielts`

## 📍 QUICK INDEX
| Section | Jump To |
|---------|---------|
| Commands | [Steps 1-14](#-commands) |
| Fix Issues | [Claude FIX](#step-8-claude-fix) |
| Listening Rules | [Audio/Passage](#-listening-rules) |
| Hints | [Related Hints](#-hints) |

## 🔗 HINTS
Call `@[/hint-xxx]` for type details:
`summary-completion` `matching-information` `mcq-single` `mcq-multiple` `table-completion` `short-answer` `map-diagram`

---

## 🚀 COMMANDS

> [!CAUTION]
> **MANDATORY 14-STEP PIPELINE - KHÔNG ĐƯỢC BỎ QUA BẤT KỲ BƯỚC NÀO!**
> 
> Cho dù Step 1-5 SUCCESS, vẫn PHẢI chạy đủ 14 bước. Mỗi step PHẢI được execute.

### Step 1-5: Orchestrator
```bash
// turbo
cd /home/khoa/RiderProjects/Project_Langfens_Microservice/scripts/pipeline_v2 && python orchestrator.py "<URL>" --type listening --hints="<HINTS>" 2>&1
```

### Step 6: Gemini PRE
```bash
// turbo
cd /home/khoa/RiderProjects/Project_Langfens_Microservice/scripts/pipeline_v2 && timeout 90 python gemini_qa.py <SOURCE> <ITEM_ID> 2>&1
```

### Step 7: Codex PRE
```bash
// turbo
cd /home/khoa/RiderProjects/Project_Langfens_Microservice/scripts/pipeline_v2 && timeout 300 python codex_qa.py <SOURCE> <ITEM_ID> --mode pre 2>&1
```

### Step 8: Claude FIX
```python
import json
from pathlib import Path
json_path = Path("data/normalized/<SOURCE>/<ITEM_ID>.json")
data = json.loads(json_path.read_text())
# Fix issues from Step 6-7
json_path.write_text(json.dumps(data, indent=2, ensure_ascii=False))
```

After fix: `python reembed_images.py <SOURCE> <ITEM_ID>`

### Step 9: Gemini POST
```bash
// turbo
cd /home/khoa/RiderProjects/Project_Langfens_Microservice/scripts/pipeline_v2 && timeout 90 python gemini_qa.py <SOURCE> <ITEM_ID> 2>&1
```

### Step 10: Codex VALIDATE
```bash
// turbo
cd /home/khoa/RiderProjects/Project_Langfens_Microservice/scripts/pipeline_v2 && timeout 300 python codex_qa.py <SOURCE> <ITEM_ID> --mode validate 2>&1
```

### Step 11: Claude FIX #2 (if needed)

### Step 12: Invariants
```bash
// turbo
cd /home/khoa/RiderProjects/Project_Langfens_Microservice/scripts/pipeline_v2 && python invariants.py <SOURCE> <ITEM_ID> --type listening 2>&1
```

### Step 12.5: Cloudinary
```bash
// turbo
cd /home/khoa/RiderProjects/Project_Langfens_Microservice/scripts/pipeline_v2 && python upload_images.py <SOURCE> <ITEM_ID> 2>&1
```

### Step 13: Export
```bash
cd /home/khoa/RiderProjects/Project_Langfens_Microservice/scripts/pipeline_v2 && python export.py <SOURCE> <ITEM_ID> --type listening
```

### Step 14: Seed
```bash
PGPASSWORD=exam psql -h localhost -p 5433 -U exam -d exam-db -f "deploy/seeds/seed_exam_*.sql"
```

---

## 📋 LISTENING RULES

### Audio:
- Format: `https://www.youtube.com/embed/VIDEO_ID`
- Field: `audio_url` in exam metadata (BẮT BUỘC)

### passage_md Format (TRANSCRIPT/NOTES ONLY):
```markdown
# Title

**Section 1:** Transcript content...

**Section 2:** More content...
```

### instruction_md Format (FULL QUESTION DETAILS):
```markdown
## QUESTIONS 1-6

Complete the notes below.
Write **NO MORE THAN TWO WORDS** for each answer.

**1.** Location: _______
**2.** Name: _______
**3.** Date: _______

---

## QUESTIONS 7-10

Label the map below.
Choose **FOUR** answers from the box.

![Map](https://cloudinary.com/xxx/map.jpg)

### Options:
- **A** bicycle parking
- **B** drinks machine

**7.** Location 7: _______
**8.** Location 8: _______
```

> [!IMPORTANT]
> **KHÔNG merge instruction_md vào passage_md!**
> 
> - `passage_md`: Transcript/notes only
> - `instruction_md`: Full question details với maps, diagrams, options
> - Frontend hiển thị `instruction_md` (bên trái, sau passage)

### Key Rules:
| Field | Content |
|-------|---------|
| `passage_md` | Transcript/notes only |
| `instruction_md` | Full: headings, options, maps, diagrams |
| `audio_url` | YouTube embed URL (BẮT BUỘC) |
| Passage length | ≥ 100 words |

### instruction_md MUST include:
- Question group headings (`## QUESTIONS 1-6`)
- Full instruction text (từ source)
- Options list (A, B, C...) nếu có
- Maps/diagrams nếu có (`![](cloudinary_url)`)
- Blanks với số thứ tự

### Common Fixes:
| Issue | Fix |
|-------|-----|
| instruction_md quá ngắn | Extract đầy đủ từ source |
| Missing map/diagram | Add `![](cloudinary_url)` |
| MAP_LABEL type | Convert to `MATCHING_INFORMATION` |
| Choose TWO | Use `MULTIPLE_CHOICE_MULTIPLE` |
| Missing audio | Extract from iframe |

---

## 🔗 RELATED
- `@[/ielts-data-format]` - Strict JSON schemas
- `@[/hints]` - All question types reference

