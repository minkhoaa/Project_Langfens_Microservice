---
description: Quy tắc format dữ liệu IELTS questions - KHÔNG SỬA BACKEND/FRONTEND
---

# IELTS Question Data Format Rules (LOCKED v12.0)

## 🔄 New Pipeline (v12.0)

```
Crawl --json → Validate → Review → json_to_sql → Seed
```

| Step | Command | Output |
|------|---------|--------|
| 1. Crawl | `python crawler-ieltswriting.py URL --json` | `output/*.json` |
| 2. Validate | `python validate_exam.py output/exam.json` | PASS/FAIL |
| 3. Review | `python review_exam.py output/exam.json` | Human readable |
| 4. Convert | `python json_to_sql.py output/exam.json` | `seeds/*.sql` |
| 5. Seed | `bash run_seed.sh` | Database |

---

## 📊 Question Types Supported

| # | Type | MatchPairs | BlankAcceptTexts | Options |
|---|------|------------|------------------|---------|
| 1 | TRUE_FALSE_NOT_GIVEN | - | - | ✅ 3 options |
| 2 | YES_NO_NOT_GIVEN | - | - | ✅ 3 options |
| 3 | MATCHING_INFORMATION | ✅ `{"info-q1": ["C", "c"]}` | - | - |
| 4 | MATCHING_HEADING | ✅ `{"section-a": ["vi", "vi. Full"]}` | - | ✅ headings |
| 5 | MATCHING_FEATURES | ✅ `{"feature-q1": ["A", "A. Full"]}` | - | - |
| 6 | SUMMARY_COMPLETION | - | ✅ `{"blank-q1": ["word"]}` | - |
| 7 | MULTIPLE_CHOICE_SINGLE | - | - | ✅ A-D |
| 8 | MULTIPLE_CHOICE_MULTIPLE | - | - | ✅ multi correct |

⚠️ **QUAN TRỌNG**: Chỉ được sửa **data và script**, KHÔNG được sửa backend hoặc frontend.

---

## 🛡️ Validation Rules

### Schema Validation (`validate_exam.py`)
- ✅ Required fields: id, slug, title, category, level, durationMin, sections
- ✅ Valid enums: category ∈ {IELTS, TOEIC, VSTEP, PLACEMENT}
- ✅ Valid enums: level ∈ {A1, A2, B1, B2, C1, C2}
- ✅ Valid question types (see list above)
- ✅ promptMd not empty

### Content Validation
- ✅ Passage length > 500 chars (warning if shorter)
- ✅ SUMMARY_COMPLETION has blankAcceptTexts
- ✅ MATCHING_* has matchPairs
- ✅ MULTIPLE_CHOICE has >= 2 options

### Noise Detection (Auto-reject)
```python
NOISE_PATTERNS = [
    'SHARE THIS PAGE',
    'CONTACT US', 
    'IELTS QUESTIONS',
    'While using this site',
    'terms of use, cookie and privacy policy',
    'Dear readers,',
    'OK, I understand',
    'Written by IELTS',
    'Last Updated:',
    'Hits: \d+',
]
```

---

## 📝 JSON Schema Format

```json
{
  "schemaVersion": "1.0.0",
  "exams": [{
    "id": "uuid",
    "slug": "ielts-reading-exam-name",
    "title": "IELTS Reading Sample",
    "category": "IELTS",
    "level": "B2",
    "status": "PUBLISHED",
    "durationMin": 20,
    "sections": [{
      "id": "uuid",
      "idx": 1,
      "title": "Reading Passage",
      "instructionsMd": "# Passage\n\nContent...",
      "questions": [{
        "id": "uuid",
        "idx": 1,
        "type": "MATCHING_INFORMATION",
        "skill": "READING",
        "difficulty": 2,
        "promptMd": "Statement text",
        "options": [],
        "blankAcceptTexts": {},
        "matchPairs": {"match-q1": ["C", "c"]}
      }]
    }]
  }]
}
```

---

## Question Types - SQL Format

### MATCHING_INFORMATION
```sql
INSERT INTO exam_questions (..., "MatchPairs")
VALUES (..., '{"info-q1": ["C", "c"]}'::jsonb);
-- NO exam_options
```

### MATCHING_HEADING
```sql
INSERT INTO exam_questions (..., "MatchPairs")
VALUES (..., '{"section-a": ["vi", "vi. Full heading text"]}'::jsonb);
-- ALSO insert exam_options for dropdown
INSERT INTO exam_options VALUES (..., 'i. Heading one', false);
INSERT INTO exam_options VALUES (..., 'vi. Full heading text', true);
```

### SUMMARY_COMPLETION
```sql
INSERT INTO exam_questions (..., "BlankAcceptTexts")
VALUES (..., '{"blank-q15": ["CONTRIBUTION"]}'::jsonb);
-- NO exam_options
```

### MULTIPLE_CHOICE_SINGLE
```sql
INSERT INTO exam_questions (..., "MatchPairs")
VALUES (..., NULL);
INSERT INTO exam_options VALUES (..., 'A. Option text', true);
INSERT INTO exam_options VALUES (..., 'B. Other option', false);
```

---

## Scripts

| Script | Purpose |
|--------|---------|
| `crawler-ieltswriting.py` | Crawl ielts-writing.info |
| `crawler-ieltsmentor.py` | Crawl ielts-mentor.com |
| `validate_exam.py` | Schema + content validation |
| `review_exam.py` | Human-readable review |
| `json_to_sql.py` | JSON → SQL converter |
| `run_seed.sh` | Seed database |

---

## Passage Cleaning Rules

### ielts-writing.info
Remove footer patterns:
- × (close button)
- SHARE THIS PAGE
- CONTACT US
- Cookie notices
- Domain migration messages

### ielts-mentor.com  
Use `get_direct_text()` to extract only direct text from `<p>` tags, avoiding nested element text pollution.

---

## Changelog

- **v12.0**: New validation pipeline (JSON → Validate → SQL)
- **v11.0**: Passage noise cleanup, MATCHING_HEADING fix
- **v10.0**: SUMMARY_COMPLETION blank format
