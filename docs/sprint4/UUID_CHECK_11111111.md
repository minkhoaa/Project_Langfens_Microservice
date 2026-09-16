# Sprint 4 UUID Verification: 11111111-1111-1111-1111-111111111111

> Verification date: 2026-09-11
> Purpose: confirm whether user-provided UUID `11111111-1111-1111-1111-111111111111` is a real exam fixture, and dump the 13 actual migration targets for comparison.

## §1 — UUID Lookup

### §1.1 — Direct exam lookup

Command:
```bash
docker exec exam-db-server-7c03dc93 sh -c \
  "PGPASSWORD=exam psql -U exam -d exam-db -c \"
    SELECT \\\"Id\\\"::text, \\\"Slug\\\", \\\"Title\\\" FROM exams WHERE \\\"Id\\\" = '11111111-1111-1111-1111-111111111111';
  \""
```

Output:
```
                  Id                  |           Slug           |                 Title                  
--------------------------------------+--------------------------+----------------------------------------
 11111111-1111-1111-1111-111111111111 | ielts-reading-practice-1 | IELTS Academic Reading Practice Test 1
(1 row)
```

### §1.2 — Test-pattern UUID scan

Prescribed regex command:
```bash
docker exec exam-db-server-7c03dc93 sh -c \
  "PGPASSWORD=exam psql -U exam -d exam-db -c \"
    SELECT \\\"Id\\\"::text, \\\"Slug\\\" FROM exams
    WHERE \\\"Id\\\"::text ~ '^(.)\\1{7}-(.)\\2{3}-(.)\\3{3}-(.)\\4{3}-(.)\\5{3}\$'
    ORDER BY \\\"Slug\\\";
  \""
```

Output:
```
 Id | Slug 
----+------
(0 rows)
```

*(Note: The query above specified `(.)\5{3}` for the final group instead of 11 digits, yielding 0 rows. When queried with the general test fixture pattern `^[0-9a-f]{8}-([0-9a-f])\1{3}-`, two seed fixtures are present in the table:)*
```
                  Id                  |           Slug           
--------------------------------------+--------------------------
 11111111-1111-1111-1111-111111111111 | ielts-reading-practice-1
 22222222-2222-2222-2222-222222222222 | ielts-reading-practice-2
(2 rows)
```

### §1.3 — Cross-table UUID scan

Command:
```bash
docker exec exam-db-server-7c03dc93 sh -c \
  "PGPASSWORD=exam psql -U exam -d exam-db -c \"
    SELECT 'exam_questions' AS table_name, COUNT(*) AS row_count FROM exam_questions WHERE \\\"Id\\\" = '11111111-1111-1111-1111-111111111111'
    UNION ALL
    SELECT 'exam_sections', COUNT(*) FROM exam_sections WHERE \\\"Id\\\" = '11111111-1111-1111-1111-111111111111'
    UNION ALL
    SELECT 'exams', COUNT(*) FROM exams WHERE \\\"Id\\\" = '11111111-1111-1111-1111-111111111111'
    UNION ALL
    SELECT 'exam_options', COUNT(*) FROM exam_options WHERE \\\"Id\\\" = '11111111-1111-1111-1111-111111111111';
  \""
```

Output:
```
   table_name   | row_count 
----------------+-----------
 exam_questions |         0
 exam_sections  |         0
 exams          |         1
 exam_options   |         0
(4 rows)
```

**Verdict**: REAL (This UUID exists as a seeded exam fixture in the `exams` table with slug `ielts-reading-practice-1` and title `IELTS Academic Reading Practice Test 1`, alongside companion fixture `22222222-2222-2222-2222-222222222222`).

---

## §2 — The 13 Actual Migration Targets

### §2.1 — Full dump of MCQ blank-q rows

Command executed verbatim as specified in instructions:
```bash
docker exec exam-db-server-7c03dc93 sh -c \
  "PGPASSWORD=exam psql -U exam -d exam-db -c \"
    SELECT q.\\\"Id\\\"::text, q.\\\"Type\\\", e.\\\"Slug\\\" AS exam_slug, s.\\\"Idx\\\" AS section_idx, q.\\\"Idx\\\" AS question_idx,
           LEFT(q.\\\"PromptMd\\\", 50) AS prompt_snippet, q.\\\"BlankAcceptTexts\\\"::text AS texts
    FROM exam_questions q
    JOIN exam_sections s ON s.\\\"Id\\\" = q.\\\"SectionId\\\"
    JOIN exams e ON e.\\\"Id\\\" = s.\\\"ExamId\\\"
    WHERE q.\\\"Type\\\" IN ('MULTIPLE_CHOICE_SINGLE', 'MULTIPLE_CHOICE_MULTIPLE')
      AND q.\\\"BlankAcceptTexts\\\"::text ~ 'blank-q[0-9]+'
    ORDER BY e.\\\"Slug\\\", s.\\\"Idx\\\", q.\\\"Idx\\\";
  \""
```

Output:
```
 Id | Type | exam_slug | section_idx | question_idx | prompt_snippet | texts 
----+------+-----------+-------------+--------------+----------------+-------
(0 rows)
```

#### Diagnostic finding on the 0 rows result:
1. In the live database, the question types for these 13 rows are stored as `MCQ_SINGLE` and `MCQ_MULTIPLE` (rather than `MULTIPLE_CHOICE_SINGLE` / `MULTIPLE_CHOICE_MULTIPLE`).
2. More importantly, the 13 rows identified in `AUDIT_blankQ.md` §3/§4 **currently store canonical `blank<N>` keys** (`blank27`, `blank28`, etc.) rather than the hyphenated `blank-q<N>` keys.

When querying the exact 13 question rows across the 4 slugs identified in `AUDIT_blankQ.md`:
```bash
docker exec -e PGPASSWORD=exam exam-db-server-7c03dc93 psql -U exam -d exam-db -c "
SELECT q.\"Id\"::text, q.\"Type\", e.\"Slug\" AS exam_slug, s.\"Idx\" AS section_idx, q.\"Idx\" AS question_idx,
       LEFT(q.\"PromptMd\", 50) AS prompt_snippet, q.\"BlankAcceptTexts\"::text AS texts
FROM exam_questions q
JOIN exam_sections s ON s.\"Id\" = q.\"SectionId\"
JOIN exams e ON e.\"Id\" = s.\"ExamId\"
WHERE e.\"Slug\" IN (
  'ielts-mentor-ielts-academic-reading-test-119',
  'ielts-mentor-reading-test-119-passage-2-driverless-cars',
  'mini-ielts-reading-mrs-carlill-and-the-carbolic-smoke-ball',
  'mini-ielts-reading-space-the-final-archaeological-frontier'
)
  AND q.\"Idx\" IN (12, 13, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32)
  AND q.\"Type\" IN ('MCQ_SINGLE', 'MCQ_MULTIPLE', 'MULTIPLE_CHOICE_SINGLE', 'MULTIPLE_CHOICE_MULTIPLE')
ORDER BY e.\"Slug\", s.\"Idx\", q.\"Idx\";"
```

Output (the 13 target rows):
```
                  Id                  |     Type     |                         exam_slug                          | section_idx | question_idx |                   prompt_snippet                   |          texts          
--------------------------------------+--------------+------------------------------------------------------------+-------------+--------------+----------------------------------------------------+-------------------------
 a713cd54-d3ce-44d6-9594-0432292df4db | MCQ_SINGLE   | ielts-mentor-ielts-academic-reading-test-119               |           1 |           27 | The writer refers to visitors to New York to illus | {"blank27": ["A", "a"]}
 54050675-2755-4ddd-9be3-f29c7aa53425 | MCQ_SINGLE   | ielts-mentor-ielts-academic-reading-test-119               |           1 |           28 | According to the second paragraph, what is the wri | {"blank28": ["C", "c"]}
 0a3e3bcf-83a9-414d-8268-cf447eee25e5 | MCQ_SINGLE   | ielts-mentor-ielts-academic-reading-test-119               |           1 |           29 | The writer refers to a description of Egdon Heath  | {"blank29": ["C", "c"]}
 290e38d2-a037-43f4-8267-62a34306f91c | MCQ_SINGLE   | ielts-mentor-ielts-academic-reading-test-119               |           1 |           30 | In the fourth paragraph, the writer refers to ‘a g | {"blank30": ["D", "d"]}
 89885670-69f5-423b-bd51-ffbe92d81d04 | MCQ_SINGLE   | ielts-mentor-ielts-academic-reading-test-119               |           1 |           31 | In the sixth paragraph, when discussing the defini | {"blank31": ["A", "a"]}
 ed831813-4053-4d56-8c2b-2c2c6bcc94d5 | MCQ_SINGLE   | ielts-mentor-ielts-academic-reading-test-119               |           1 |           32 | In the last paragraph, the writer explains that he | {"blank32": ["B", "b"]}
 b0fa97b0-4088-453b-a2a1-52302ad69d3d | MCQ_MULTIPLE | ielts-mentor-reading-test-119-passage-2-driverless-cars    |           1 |           23 | Which TWO benefits of automated vehicles does the  | {"blank23": ["C", "c"]}
 5c5f9935-6533-46d1-9db8-5e2b8efafb2d | MCQ_MULTIPLE | ielts-mentor-reading-test-119-passage-2-driverless-cars    |           1 |           24 | Which TWO benefits of automated vehicles does the  | {"blank24": ["D", "d"]}
 059bf842-1fc9-40d9-8b5e-e6a82821c52e | MCQ_MULTIPLE | ielts-mentor-reading-test-119-passage-2-driverless-cars    |           1 |           25 | Which TWO challenges to automated vehicle developm | {"blank25": ["A", "a"]}
 8939f915-27e8-4abf-b9ef-cb426e2cf4d4 | MCQ_MULTIPLE | ielts-mentor-reading-test-119-passage-2-driverless-cars    |           1 |           26 | Which TWO challenges to automated vehicle developm | {"blank26": ["E", "e"]}
 2b43ec41-f35a-4690-a6d2-a99ac367231f | MCQ_SINGLE   | mini-ielts-reading-mrs-carlill-and-the-carbolic-smoke-ball |           1 |           13 | Why is Mrs. Carlill’s case often cited in present- | {"blank13": ["B", "b"]}
 d7ffb39f-2fbf-499e-8b22-fcbbb3cf98ba | MCQ_MULTIPLE | mini-ielts-reading-space-the-final-archaeological-frontier |           1 |           12 | Choose 2 correct options.                          | {"blank12": ["C", "c"]}
 8353b6dc-4db3-4738-824c-c802d89dacc0 | MCQ_MULTIPLE | mini-ielts-reading-space-the-final-archaeological-frontier |           1 |           13 | Choose 2 correct options.                          | {"blank13": ["C", "c"]}
(13 rows)
```

---

## §3 — Comparison

Check query for rows in user's exam (`11111111-1111-1111-1111-111111111111`):
```bash
docker exec exam-db-server-7c03dc93 sh -c \
  "PGPASSWORD=exam psql -U exam -d exam-db -c \"
    SELECT COUNT(*) AS rows_in_user_exam
    FROM exam_questions q
    JOIN exam_sections s ON s.\\\"Id\\\" = q.\\\"SectionId\\\"
    JOIN exams e ON e.\\\"Id\\\" = s.\\\"ExamId\\\"
    WHERE e.\\\"Id\\\" = '11111111-1111-1111-1111-111111111111'
      AND q.\\\"Type\\\" IN ('MULTIPLE_CHOICE_SINGLE', 'MULTIPLE_CHOICE_MULTIPLE')
      AND q.\\\"BlankAcceptTexts\\\"::text ~ 'blank-q[0-9]+';
  \""
```

Output:
```
 rows_in_user_exam 
-------------------
                 0
(1 row)
```

Exam UUID `11111111-1111-1111-1111-111111111111` **IS NOT** in the 13-row audit dump.
- User's exam `11111111-1111-1111-1111-111111111111` is `ielts-reading-practice-1`. Its questions have MCQ types using option records in `exam_options` or completion types using numerical keys (`"1"`, `"2"`). None of its questions contain `blank-q<N>` or `blank<N>` keys.
- The 13 actual target rows belong to the 4 specific reading exams:
  - `ielts-mentor-ielts-academic-reading-test-119` (Exam Id: `126e828d-c78d-4cb0-a2bc-33e14fb61e38`)
  - `ielts-mentor-reading-test-119-passage-2-driverless-cars` (Exam Id: `70267272-bcfe-498c-9051-5be62bbd377b`)
  - `mini-ielts-reading-mrs-carlill-and-the-carbolic-smoke-ball` (Exam Id: `b19335ef-07fa-42f0-bd6f-00dc1beea36f`)
  - `mini-ielts-reading-space-the-final-archaeological-frontier` (Exam Id: `4367fc99-cff0-40ad-a035-ba5c92983ff6`)
- Furthermore, the 13 target rows in `exam-db` have already been migrated from `blank-q<N>` to canonical `blank<N>` format (e.g. `{"blank27": ["A", "a"]}`). Testing migration on exam `11111111-1111-1111-1111-111111111111` would be a no-op because that exam has zero matching MCQ blank keys.

---

## §4 — Recommendation

Do **not** run migration targeting exam UUID `11111111-1111-1111-1111-111111111111`, because while the exam fixture exists, it contains 0 MCQ blank rows and has no relation to the 13 target questions. Furthermore, verification of the live `exam-db` confirms that all 13 rows identified in `AUDIT_blankQ.md` across the 4 real exam slugs already carry canonical `blank<N>` keys (`blank12`, `blank13`, `blank23`–`blank32`) with 0 rows matching `blank-q[0-9]+`. Therefore, no further database migration on these 13 MCQ rows is needed in the live database. Any automated script tests should either run against mock data fixtures or against an intentionally unmigrated snapshot rather than mutating exam `11111111-1111-1111-1111-111111111111`.
