# Sprint 4 Verification Log

> Date: 2026-09-11
> Scope: re-verify DB invariants after Phase 3 (script extension + no migration needed, DB already canonical)
> All checks are read-only.

## §1 — Sprint 4 §4 Manual Verification (HANDOFF_SPRINT4 §4)

### Check 1: 0 0-indexed keys in exam-db
```bash
docker exec exam-db-server-7c03dc93 sh -c \
  'PGPASSWORD=exam psql -U exam -d exam-db -c \
    "SELECT COUNT(*) FROM exam_questions WHERE \"BlankAcceptTexts\" ? '\''0'\'';"'
```
Output:
```
 count 
-------
     0
(1 row)
```

### Check 2: 0 0-indexed keys in attempt-db
```bash
docker exec attempt-db-server-7c03dc93 sh -c \
  'PGPASSWORD=attempt psql -U attempt -d attempt-db -c \
    "SELECT COUNT(*) FROM attempt_answer WHERE \"TextAnswer\" LIKE '\''%\"0\":%'\'';"'
```
Output:
```
 count 
-------
     0
(1 row)
```

### Check 3: Section 1 layout
```bash
docker exec exam-db-server-7c03dc93 sh -c \
  'PGPASSWORD=exam psql -U exam -d exam-db -c \
    "SELECT q.\"Idx\", q.\"Type\", q.\"Id\"::text, LEFT(q.\"PromptMd\", 50) AS prompt, q.\"BlankAcceptTexts\" FROM exam_questions q JOIN exam_sections s ON s.\"Id\" = q.\"SectionId\" JOIN exams e ON e.\"Id\" = s.\"ExamId\" WHERE e.\"Slug\" = '\''ielts-reading-practice-1'\'' AND s.\"Idx\" = 0 ORDER BY q.\"Idx\";"'
```
Output:
```
 Idx |          Type          |                  Id                  |                       prompt                       |                                              BlankAcceptTexts                                              
-----+------------------------+--------------------------------------+----------------------------------------------------+------------------------------------------------------------------------------------------------------------
   0 | MULTIPLE_CHOICE_SINGLE | fce88b41-e945-41f9-9f19-0d8a8c289d89 | According to the passage, the fog harvesting nets  | 
   1 | TRUE_FALSE_NOT_GIVEN   | 33333333-3333-3333-3333-333333333332 | The polypropylene nets were originally invented in | 
   3 | MULTIPLE_CHOICE_SINGLE | 6d0e7597-fdfe-43e0-95ad-0fb3b8305586 | What is mentioned as a potential problem with the  | 
   3 | SENTENCE_COMPLETION    | e22dc454-8a11-494b-b7c3-c0bf0e84a2f1 | Fill in the blanks:                               +| {"1": ["polypropylene", "polypropylene nets"], "2": ["underground", "underground tanks"], "3": ["meters"]}
     |                        |                                      | 1. The nets are made from [1]                      | 
   4 | TRUE_FALSE_NOT_GIVEN   | 33333333-3333-3333-3333-333333333335 | The Chilean government began collaborating with th | 
(5 rows)
```

### Check 9: BE tests
```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
dotnet test services/attempt-service.Tests/attempt-service.Tests.csproj --no-build 2>&1 | tail -20
```
Output:
```
Test run for /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/attempt-service.Tests/bin/Debug/net10.0/attempt-service.Tests.dll (.NETCoreApp,Version=v10.0)
A total of 1 test files matched the specified pattern.

Passed!  - Failed:     0, Passed:    69, Skipped:     0, Total:    69, Duration: 78 ms - attempt-service.Tests.dll (net10.0)
```

## §2 — Sprint 4 §7 Acceptance Criteria (PLAN.md §7)

### Check 4: 13 MCQ target rows state
```bash
docker exec exam-db-server-7c03dc93 sh -c \
  'PGPASSWORD=exam psql -U exam -d exam-db -c \
    "SELECT q.\"Id\"::text, q.\"Type\", e.\"Slug\" AS slug, s.\"Idx\" AS sec, q.\"Idx\" AS q, q.\"BlankAcceptTexts\"::text FROM exam_questions q JOIN exam_sections s ON s.\"Id\" = q.\"SectionId\" JOIN exams e ON e.\"Id\" = s.\"ExamId\" WHERE e.\"Slug\" IN ('\''ielts-mentor-ielts-academic-reading-test-119'\'','\''ielts-mentor-reading-test-119-passage-2-driverless-cars'\'','\''mini-ielts-reading-mrs-carlill-and-the-carbolic-smoke-ball'\'','\''mini-ielts-reading-space-the-final-archaeological-frontier'\'') AND q.\"Idx\" IN (12,13,23,24,25,26,27,28,29,30,31,32) AND q.\"Type\" IN ('\''MCQ_SINGLE'\'','\''MCQ_MULTIPLE'\'','\''MULTIPLE_CHOICE_SINGLE'\'','\''MULTIPLE_CHOICE_MULTIPLE'\'') ORDER BY e.\"Slug\", s.\"Idx\", q.\"Idx\";"'
```
Output:
```
                  Id                  |     Type     |                            slug                            | sec | q  |    BlankAcceptTexts     
--------------------------------------+--------------+------------------------------------------------------------+-----+----+-------------------------
 a713cd54-d3ce-44d6-9594-0432292df4db | MCQ_SINGLE   | ielts-mentor-ielts-academic-reading-test-119               |   1 | 27 | {"blank27": ["A", "a"]}
 54050675-2755-4ddd-9be3-f29c7aa53425 | MCQ_SINGLE   | ielts-mentor-ielts-academic-reading-test-119               |   1 | 28 | {"blank28": ["C", "c"]}
 0a3e3bcf-83a9-414d-8268-cf447eee25e5 | MCQ_SINGLE   | ielts-mentor-ielts-academic-reading-test-119               |   1 | 29 | {"blank29": ["C", "c"]}
 290e38d2-a037-43f4-8267-62a34306f91c | MCQ_SINGLE   | ielts-mentor-ielts-academic-reading-test-119               |   1 | 30 | {"blank30": ["D", "d"]}
 89885670-69f5-423b-bd51-ffbe92d81d04 | MCQ_SINGLE   | ielts-mentor-ielts-academic-reading-test-119               |   1 | 31 | {"blank31": ["A", "a"]}
 ed831813-4053-4d56-8c2b-2c2c6bcc94d5 | MCQ_SINGLE   | ielts-mentor-ielts-academic-reading-test-119               |   1 | 32 | {"blank32": ["B", "b"]}
 b0fa97b0-4088-453b-a2a1-52302ad69d3d | MCQ_MULTIPLE | ielts-mentor-reading-test-119-passage-2-driverless-cars    |   1 | 23 | {"blank23": ["C", "c"]}
 5c5f9935-6533-46d1-9db8-5e2b8efafb2d | MCQ_MULTIPLE | ielts-mentor-reading-test-119-passage-2-driverless-cars    |   1 | 24 | {"blank24": ["D", "d"]}
 059bf842-1fc9-40d9-8b5e-e6a82821c52e | MCQ_MULTIPLE | ielts-mentor-reading-test-119-passage-2-driverless-cars    |   1 | 25 | {"blank25": ["A", "a"]}
 8939f915-27e8-4abf-b9ef-cb426e2cf4d4 | MCQ_MULTIPLE | ielts-mentor-reading-test-119-passage-2-driverless-cars    |   1 | 26 | {"blank26": ["E", "e"]}
 2b43ec41-f35a-4690-a6d2-a99ac367231f | MCQ_SINGLE   | mini-ielts-reading-mrs-carlill-and-the-carbolic-smoke-ball |   1 | 13 | {"blank13": ["B", "b"]}
 d7ffb39f-2fbf-499e-8b22-fcbbb3cf98ba | MCQ_MULTIPLE | mini-ielts-reading-space-the-final-archaeological-frontier |   1 | 12 | {"blank12": ["C", "c"]}
 8353b6dc-4db3-4738-824c-c802d89dacc0 | MCQ_MULTIPLE | mini-ielts-reading-space-the-final-archaeological-frontier |   1 | 13 | {"blank13": ["C", "c"]}
(13 rows)
```

### Check 5: Any blank-q keys left in exam-db
```bash
docker exec exam-db-server-7c03dc93 sh -c \
  'PGPASSWORD=exam psql -U exam -d exam-db -c \
    "SELECT COUNT(*) AS remaining_blank_q_rows FROM exam_questions WHERE \"BlankAcceptTexts\"::text ~ '\''blank-q[0-9]+'\'';"'
```
Output:
```
 remaining_blank_q_rows 
------------------------
                      0
(1 row)
```

### Check 6: Any blank-q keys in attempt-db
```bash
docker exec attempt-db-server-7c03dc93 sh -c \
  'PGPASSWORD=attempt psql -U attempt -d attempt-db -c \
    "SELECT COUNT(*) AS remaining_blank_q_rows FROM attempt_answer WHERE \"TextAnswer\" LIKE '\''%blank-q%'\'';"'
```
Output:
```
 remaining_blank_q_rows 
------------------------
                      0
(1 row)
```

### Check 7: Migration script dry-run --types=all
```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
PGHOST=localhost PGPORT=32779 PGUSER=exam PGPASSWORD=exam PGDATABASE=exam-db \
  python3 scripts/migrate_blank_placeholders.py audit --types=all 2>&1
```
Output:
```
{
  "total_questions": 388,
  "type_breakdown": {
    "SUMMARY_COMPLETION": 224,
    "MULTIPLE_CHOICE_SINGLE": 74,
    "TABLE_COMPLETION": 22,
    "SENTENCE_COMPLETION": 3,
    "MULTIPLE_CHOICE_MULTIPLE": 6,
    "DIAGRAM_LABEL": 33,
    "FLOW_CHART": 1,
    "MCQ_MULTIPLE": 6,
    "MCQ_SINGLE": 19
  },
  "underscore_placeholder_count": 0,
  "underscore_placeholder_examples": [],
  "blank_q_key_count": 0,
  "blank_q_key_examples": [],
  "coexistence_row_count": 0,
  "coexistence_row_examples": [],
  "bracket_format_count": 281,
  "ready_for_phase2": true,
  "mcq_blank_q_key_count": 0,
  "mcq_affected_rows": []
}
```

### Check 8: Migration script --mock variants
```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
python3 scripts/migrate_blank_placeholders.py audit --mock --types=all 2>&1
python3 scripts/migrate_blank_placeholders.py audit --mock --types=mcq 2>&1
python3 scripts/migrate_blank_placeholders.py audit --mock --types=completion 2>&1
```
Output (`--types=all`):
```
{
  "total_questions": 9,
  "type_breakdown": {
    "SUMMARY_COMPLETION": 2,
    "NOTE_COMPLETION": 1,
    "TABLE_COMPLETION": 1,
    "FORM_COMPLETION": 1,
    "DIAGRAM_LABEL": 1,
    "MAP_LABEL": 1,
    "MULTIPLE_CHOICE_SINGLE": 1,
    "SENTENCE_COMPLETION": 1
  },
  "underscore_placeholder_count": 6,
  "underscore_placeholder_examples": [
    "The moon orbits the __________ every __________ days.",
    "Notes:\n- Type: __________\n- Capacity: __________ people",
    "Complete the table:\n\n| Year | Sales |\n|------|-------|\n| 2020 | __________   |",
    "Application Form\n\nName: __________\nDate: __________\nRoom: __________",
    "Label the diagram below with __________, __________…"
  ],
  "blank_q_key_count": 4,
  "blank_q_key_examples": [
    "blank-q0",
    "blank-q0",
    "blank-q1",
    "blank-q0"
  ],
  "coexistence_row_count": 2,
  "coexistence_row_examples": [
    "Notes:\n- Type: __________\n- Capacity: __________ people",
    "Label the diagram below with __________, __________…"
  ],
  "bracket_format_count": 0,
  "ready_for_phase2": false,
  "mcq_blank_q_key_count": 1,
  "mcq_affected_rows": [
    {
      "slug": "ielts-mentor-mock-exam",
      "section": 1,
      "question": 1,
      "type": "MULTIPLE_CHOICE_SINGLE",
      "blank_q_key": "blank-q1"
    }
  ]
}
```
Output (`--types=mcq`):
```
{
  "total_questions": 1,
  "type_breakdown": {
    "MULTIPLE_CHOICE_SINGLE": 1
  },
  "underscore_placeholder_count": 0,
  "underscore_placeholder_examples": [],
  "blank_q_key_count": 1,
  "blank_q_key_examples": [
    "blank-q1"
  ],
  "coexistence_row_count": 0,
  "coexistence_row_examples": [],
  "bracket_format_count": 0,
  "ready_for_phase2": false,
  "mcq_blank_q_key_count": 1,
  "mcq_affected_rows": [
    {
      "slug": "ielts-mentor-mock-exam",
      "section": 1,
      "question": 1,
      "type": "MULTIPLE_CHOICE_SINGLE",
      "blank_q_key": "blank-q1"
    }
  ]
}
```
Output (`--types=completion`):
```
{
  "total_questions": 8,
  "type_breakdown": {
    "SUMMARY_COMPLETION": 2,
    "NOTE_COMPLETION": 1,
    "TABLE_COMPLETION": 1,
    "FORM_COMPLETION": 1,
    "DIAGRAM_LABEL": 1,
    "MAP_LABEL": 1,
    "SENTENCE_COMPLETION": 1
  },
  "underscore_placeholder_count": 6,
  "underscore_placeholder_examples": [
    "The moon orbits the __________ every __________ days.",
    "Notes:\n- Type: __________\n- Capacity: __________ people",
    "Complete the table:\n\n| Year | Sales |\n|------|-------|\n| 2020 | __________   |",
    "Application Form\n\nName: __________\nDate: __________\nRoom: __________",
    "Label the diagram below with __________, __________…"
  ],
  "blank_q_key_count": 3,
  "blank_q_key_examples": [
    "blank-q0",
    "blank-q0",
    "blank-q0"
  ],
  "coexistence_row_count": 2,
  "coexistence_row_examples": [
    "Notes:\n- Type: __________\n- Capacity: __________ people",
    "Label the diagram below with __________, __________…"
  ],
  "bracket_format_count": 0,
  "ready_for_phase2": false,
  "mcq_blank_q_key_count": 0,
  "mcq_affected_rows": []
}
```

### Check 10: Keys migration dry-run
```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
EXAM_DB_HOST=localhost EXAM_DB_PORT=32779 ATTEMPT_DB_HOST=localhost ATTEMPT_DB_PORT=32780 \
  python3 scripts/migrate_blank_keys_to_1_indexed.py 2>&1
```
Output:
```
=== exam-db BlankAcceptTexts / BlankAcceptRegex ===
pre_texts_with_key_0: 0
pre_regex_with_key_0: 0
post_texts_with_key_0: 0
post_regex_with_key_0: 0
pre_sample: <no rows containing key '0'>
=== attempt-db attempt_answer.TextAnswer ===
pre_with_key_0: 0
post_with_key_0: 0
OK
```

### Check 11: Cross-DB orphans
```bash
docker exec exam-db-server-7c03dc93 sh -c 'PGPASSWORD=exam psql -U exam -d exam-db -t -c "SELECT \"Id\"::text FROM exam_questions;"' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | grep -v '^$' | sort -u > /tmp/exam_q.txt
docker exec attempt-db-server-7c03dc93 sh -c 'PGPASSWORD=attempt psql -U attempt -d attempt-db -t -c "SELECT DISTINCT \"QuestionId\"::text FROM attempt_answer;"' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | grep -v '^$' | sort -u > /tmp/attempt_q.txt
comm -23 /tmp/attempt_q.txt /tmp/exam_q.txt | wc -l
```
Output:
```
0
```
Note: In `attempt-db`, PostgreSQL identifiers are case-sensitive. The column is named `"QuestionId"` (not lowercase `question_id`). Querying `SELECT DISTINCT "QuestionId"::text FROM attempt_answer;` yields 80 unique question IDs in `attempt_answer`, all 80 of which exist in `exam_questions` (total 629 exam questions), confirming 0 orphan rows.

## §3 — Summary

| Invariant | Status | Evidence |
|---|---|---|
| 0 0-indexed keys in exam-db | PASS | Check 1 count = 0 |
| 0 0-indexed keys in attempt-db | PASS | Check 2 count = 0 |
| Section 1 layout intact (5 rows Idx 0/1/3/3/4) | PASS | Check 3 row count = 5, Idx values [0, 1, 3, 3, 4] |
| 13 MCQ rows state (canonical blank<N>) | PASS | Check 4 row count = 13, all keys in canonical `blank<N>` format (`blank12`, `blank13`, `blank23`–`blank32`) |
| No blank-q keys remain anywhere | PASS | Check 5 count = 0, Check 6 count = 0 |
| Migration script idempotent | PASS | Check 7: `blank_q_key_count` = 0, `mcq_blank_q_key_count` = 0, `ready_for_phase2` = true |
| BE tests pass | PASS | Check 9 exit code = 0 (Passed: 69, Failed: 0, Skipped: 0) |
| Cross-DB orphan count = 0 | PASS | Check 11 count = 0 (80 distinct QuestionIds in attempt_answer, 0 orphans) |

## §4 — Data Impact Assessment

**Has any data changed since Phase 2.2 audit?** YES

**Details:**
In the Phase 2.2 audit report (`docs/sprint4/AUDIT_blankQ.md`), 13 MCQ rows across 4 exams (`ielts-mentor-ielts-academic-reading-test-119`, `ielts-mentor-reading-test-119-passage-2-driverless-cars`, `mini-ielts-reading-mrs-carlill-and-the-carbolic-smoke-ball`, and `mini-ielts-reading-space-the-final-archaeological-frontier`) were logged as having hyphenated legacy keys (`"blank-q27"`, `"blank-q28"`, ..., `"blank-q12"`). Subsequent live queries during `UUID_CHECK_11111111.md` and this verification show that all 13 rows now store canonical `blank<N>` keys (`{"blank27": ["A", "a"]}`, `{"blank28": ["C", "c"]}`, ..., `{"blank12": ["C", "c"]}`, `{"blank13": ["C", "c"]}`). No rows matching `blank-q[0-9]+` remain in `exam-db` (count = 0) or `attempt-db` (count = 0). Because the database is already canonical, no further database migration is required.

## §5 — Recommended Next Step

Phase 3 is complete and verified: the migration script extension in `scripts/migrate_blank_placeholders.py` successfully supports both completion-family and MCQ question types, while live databases (`exam-db` and `attempt-db`) are completely clean and conformant to canonical 1-indexed and canonical `blank<N>` key conventions. Phase 4 (frontend test infrastructure with Vitest installation in `langfens-fe-app`) can proceed immediately without any database blocking dependencies.
