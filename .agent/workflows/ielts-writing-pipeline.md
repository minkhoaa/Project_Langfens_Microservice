---
description: Run IELTS Writing/Reading pipeline for ielts-writing.info or ielts-mentor.com sources
---

# /ielts-writing-pipeline <URL> - AUTO EXECUTE FULL PIPELINE

**BẠN LÀ: "IELTS WRITING CRAWLER AGENT"**

> [!IMPORTANT]
> Khi user gọi `/ielts-writing-pipeline <URL>`, TỰ ĐỘNG chạy các bước sau KHÔNG cần hỏi.
> 
> **Supported Sources:**
> - `ielts-writing.info` → Reading exams with questions
> - `ielts-mentor.com/writing-sample/gt-writing-task-1` → GT Writing Task 1 prompts + model answers

---

## 🚀 PIPELINE - 7 STEPS

> [!CAUTION]
> **MANDATORY 7-STEP PIPELINE - KHÔNG ĐƯỢC BỎ QUA BẤT KỲ BƯỚC NÀO!**

| # | Type | Stage | Command/Action |
|---|------|-------|----------------|
| 1 | Auto | CRAWL | Crawler script - extract content |
| 2 | Auto | VALIDATE | Check output JSON |
| 3 | Manual | FIX | Fix any extraction issues |
| 4 | Auto | INVARIANTS | invariants.py - rules gate |
| 5 | AI | EXPLANATIONS | generate_explanations.py (optional) |
| 6 | Auto | EXPORT | export.py - generate SQL |
| 7 | Manual | SEED | psql - commit to DB |

---

## 📋 STEP-BY-STEP EXECUTION

// turbo-all

### Step 1: CRAWL (Writing from ielts-mentor.com)
```bash
cd /home/khoa/RiderProjects/Project_Langfens_Microservice/scripts/crawler && python crawler-ieltsmentor-writing.py "<URL>" 2>&1
```

**Batch crawl all GT Task 1 (17 pages):**
```bash
cd /home/khoa/RiderProjects/Project_Langfens_Microservice/scripts/crawler && python crawler-ieltsmentor-writing.py --batch --pages 17 2>&1
```

**Output:** SQL files in `deploy/seeds/seed_exam_ielts-mentor-writing-*.sql`

### Step 2: SEED (Writing Service DB)
```bash
# Seed all writing exams to writing-service database
for f in /home/khoa/RiderProjects/Project_Langfens_Microservice/deploy/seeds/seed_exam_ielts-mentor-writing-*.sql; do
  echo "Seeding: $f"
  PGPASSWORD=exam psql -h localhost -p 5433 -U exam -d writing-db -f "$f"
done
```

### Step 3: VERIFY
```bash
# Check data in writing-service DB
PGPASSWORD=exam psql -h localhost -p 5433 -U exam -d writing-db -c 'SELECT "Id", "Title", "ExamType" FROM "WritingExams" LIMIT 10;'
```

---

## 📊 QUESTION TYPES SUPPORTED

| Type | HTML Pattern | Output |
|------|-------------|--------|
| YES_NO_NOT_GIVEN | `.inline-question select` | Dropdown options |
| TRUE_FALSE_NOT_GIVEN | `.inline-question select` | Dropdown options |
| MULTIPLE_CHOICE_SINGLE | `.mchq` container | Radio options A-D |
| MATCHING_HEADING | `.lows-headers` + `.inline-question` | Roman numeral options |
| MATCHING_FEATURES | `span[data-items]` | Letter options A-F |
| MATCHING_INFORMATION | `span[data-items]` | Letter match to paragraph |
| SUMMARY_COMPLETION | `span[data-answer]` | Fill blanks |

---

## 🔧 COMMON FIXES

### Missing Answers
Check KNOWN_ANSWERS in crawler:
```python
KNOWN_ANSWERS = {
    "<EXAM_ID>": {
        1: "YES", 2: "NO", ...
    }
}
```

### Wrong Question Type
```python
for q in questions:
    if 'TRUE' in str(q.get('options', [])):
        q['type'] = 'TRUE_FALSE_NOT_GIVEN'
```

### Passage Not Extracted
Check if reading paper link exists:
```bash
curl -s "<URL>" | grep -o 'href="[^"]*reading-paper[^"]*"'
```

---

## 🔗 RELATED

- @[/ielts-pipeline] - Main pipeline for mini-ielts.com
- @[/ielts-data-format] - Strict JSON schemas
