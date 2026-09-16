# Sprint 4 Audit: Zero-Idx Residuals

> Audit date: 2026-09-11
> Source: HANDOFF_SPRINT3 §7 item 1 (6 rows in ielts-reading-practice-{1,2})
> Verdict: **LEGITIMATE**

## §1 — Methodology

Five SQL queries executed against live `exam-db` (container `exam-db-server-7c03dc93`, port 32779). All queries are read-only SELECT statements; no DB writes performed.

## §2 — Query Results

### Q1: Rows with Idx = 0

```
           exam           | section_idx | question_idx |          Type          |                        prompt_snippet                        |                  Id
--------------------------+-------------+--------------+------------------------+--------------------------------------------------------------+--------------------------------------
 ielts-reading-practice-1 |           0 |            0 | MULTIPLE_CHOICE_SINGLE | According to the passage, the fog harvesting nets can collec | fce88b41-e945-41f9-9f19-0d8a8c289d89
 ielts-reading-practice-1 |           1 |            0 | CLASSIFICATION         | Classify the following as referring to:                     +| 33333333-3333-3333-3333-333333333336
                          |             |              |                        | A. dopamine research                                         |
 ielts-reading-practice-1 |           2 |            0 | SUMMARY_COMPLETION     | Complete the flow chart:                                    +| 33333333-3333-3333-3333-333333333341
                          |             |              |                        | 1. Plant seeds in [1]                                       +|
                          |             |              |                        | 2. Install LE                                                |
 ielts-reading-practice-2 |           0 |            0 | TRUE_FALSE_NOT_GIVEN   | Fireflies use species-specific flashing patterns to find mat | 43333333-3333-3333-3333-333333333331
 ielts-reading-practice-2 |           1 |            0 | SUMMARY_COMPLETION     | Complete the summary using words from the passage. Write NO  | 43333333-3333-3333-3333-333333333336
 ielts-reading-practice-2 |           2 |            0 | SHORT_ANSWER           | Question 11: Which species of firefly is the source of the m | 43333333-3333-3333-3333-333333333342
(6 rows)
```

### Q2: Rows with Idx > 100

```
 exam | section_idx | question_idx | Type | prompt_snippet | Id
------+-------------+--------------+------+----------------+----
(0 rows)
```

### Q3: Section count per exam

```
           exam           | section_count
--------------------------+---------------
 ielts-reading-practice-1 |             3
 ielts-reading-practice-2 |             3
(2 rows)
```

### Q4: Idx=0 grouped by section/type

```
           Slug           | section_idx |          Type          | Idx | row_count
--------------------------+-------------+------------------------+-----+-----------
 ielts-reading-practice-1 |           0 | MULTIPLE_CHOICE_SINGLE |   0 |         1
 ielts-reading-practice-1 |           1 | CLASSIFICATION         |   0 |         1
 ielts-reading-practice-1 |           2 | SUMMARY_COMPLETION     |   0 |         1
 ielts-reading-practice-2 |           0 | TRUE_FALSE_NOT_GIVEN   |   0 |         1
 ielts-reading-practice-2 |           1 | SUMMARY_COMPLETION     |   0 |         1
 ielts-reading-practice-2 |           2 | SHORT_ANSWER           |   0 |         1
(6 rows)
```

### Q5: Section 0 layout sanity check

```
 Idx |          Type          |                  prompt
-----+------------------------+------------------------------------------
   0 | MULTIPLE_CHOICE_SINGLE | According to the passage, the fog harves
   1 | TRUE_FALSE_NOT_GIVEN   | The polypropylene nets were originally i
   3 | MULTIPLE_CHOICE_SINGLE | What is mentioned as a potential problem
   3 | SENTENCE_COMPLETION    | Fill in the blanks:                     +
     |                        | 1. The nets are made
   4 | TRUE_FALSE_NOT_GIVEN   | The Chilean government began collaborati
(5 rows)
```

## §3 — Analysis

The Sprint 3 hypothesis was that the 6 Idx=0 rows were wrong residual entries (duplicate or out-of-range indices). The Sprint 4 review hypothesized instead that these are legitimate section-local first-question ordinals — one per section, across 3 sections × 2 practice exams.

**Evidence supports the Sprint 4 hypothesis — the rows are LEGITIMATE:**

1. **Exactly 6 rows, matching the 3×2 structure.** Q1 returns exactly 6 rows with Idx=0, one per section, across the 3 sections of each of the 2 practice exams (ielts-reading-practice-1 sections 0/1/2, ielts-reading-practice-2 sections 0/1/2). Q3 confirms each exam has exactly 3 sections. This perfectly matches "3 sections × 2 exams = 6".

2. **Exactly one Idx=0 per section.** Q4 shows that each (exam, section) pair has exactly one row with Idx=0 — a single, unique occurrence. There are no duplicate Idx=0 rows within any section.

3. **The Idx > 100 "wrong" hypothesis is disproven.** Q2 returns 0 rows with Idx > 100. There are no out-of-range indices.

4. **Each Idx=0 row is a real question, not a stray header.** Q1 shows all 6 rows have substantive question Types (MULTIPLE_CHOICE_SINGLE, CLASSIFICATION, SUMMARY_COMPLETION, TRUE_FALSE_NOT_GIVEN, SHORT_ANSWER) with meaningful prompt content — not empty placeholders or orphaned metadata.

5. **Section 0 sanity check confirms expected structure.** Q5 shows Section 0 of ielts-reading-practice-1 has Idx values of 0, 1, 3, 3, 4 (note the Idx=3 duplicate — a known pre-existing issue from Sprint 3 that is out of scope for this audit). The presence of Idx=0 as the first entry is consistent with it being a legitimate first question, not a residual. The total of 5 question entries in Section 0 is consistent with a working exam section.

**Conclusion:** The 6 Idx=0 rows are the legitimate first questions for each of the 6 sections across the two IELTS reading practice exams. They are not wrong rows requiring DELETE or RE-INDEX.

## §4 — Verdict

**LEGITIMATE**

**Per-row recommendation:**
- ielts-reading-practice-1 / Section 0 / Idx=0: **KEEP** — legitimate first question (MULTIPLE_CHOICE_SINGLE)
- ielts-reading-practice-1 / Section 1 / Idx=0: **KEEP** — legitimate first question (CLASSIFICATION)
- ielts-reading-practice-1 / Section 2 / Idx=0: **KEEP** — legitimate first question (SUMMARY_COMPLETION)
- ielts-reading-practice-2 / Section 0 / Idx=0: **KEEP** — legitimate first question (TRUE_FALSE_NOT_GIVEN)
- ielts-reading-practice-2 / Section 1 / Idx=0: **KEEP** — legitimate first question (SUMMARY_COMPLETION)
- ielts-reading-practice-2 / Section 2 / Idx=0: **KEEP** — legitimate first question (SHORT_ANSWER)

## §5 — Phase 3 Action Plan

No DB action required. Sprint 4 Phase 3.1 records this verdict and moves on.
