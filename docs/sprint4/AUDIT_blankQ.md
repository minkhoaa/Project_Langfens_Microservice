# Sprint 4 Audit: Blank-Q Rows

> Audit date: 2026-09-11
> Source claim: HANDOFF_SPRINT3 §7 item 2 ("18 blank-q rows in mentor/* and mini-ielts*")
> Verdict: PARTIAL — 13 rows across 4 exams (10 in ielts-mentor, 3 in mini-ielts); count is wrong AND slug scope is wrong

## §1 — Methodology

Five queries against live `exam-db` (container `exam-db-server-7c03dc93`, port 32779). Read-only SELECTs.

## §2 — Query Results

### Q1: mentor/* and mini-ielts* exams present

```
                                        Slug                                         |                              Title                               
-------------------------------------------------------------------------------------+------------------------------------------------------------------
 mini-ielts-listening-different-types-of-supermarket-layout                          | Different Types of Supermarket Layout
 mini-ielts-listening-directions-on-a-map                                            | Directions on a map
 mini-ielts-listening-dolphin-conservation-trust                                     | Dolphin Conservation Trust
 mini-ielts-listening-fiddy-working-heritage-farm                                    | Fiddy Working Heritage Farm
 mini-ielts-listening-giving-the-presentation                                        | Giving the presentation
 mini-ielts-listening-hollylands                                                     | Hollylands
 mini-ielts-listening-identifying-detail                                             | Identifying detail
 mini-ielts-listening-non-driving-vehicle-competition-driverless-vehicle-competition | Non-driving vehicle competition (Driverless vehicle competition)
 mini-ielts-listening-paper-on-public-libraries                                      | Paper on Public Libraries
 mini-ielts-listening-self-drive-tours-in-the-usa                                    | Self-drive tours in the USA
 mini-ielts-listening-self-regulatory-focus-theory                                   | Self-regulatory focus theory
 mini-ielts-listening-talk-to-new-kitchen-assistants                                 | Talk to new kitchen assistants
 mini-ielts-listening-theatre-studies-course                                         | Theatre Studies Course
 mini-ielts-listening-visiting-the-sheepmarket-area                                  | Visiting the Sheepmarket area
 mini-ielts-reading-a-new-ice-age                                                    | A New Ice Age
 mini-ielts-reading-astronaut-ice-cream-anyone                                       | Astronaut ice cream, anyone
 mini-ielts-reading-carbon-capture-and-storage                                       | Carbon Capture and Storage
 mini-ielts-reading-crows-can-be-craftsmen-too                                       | Crows Can be Craftsmen too
 mini-ielts-reading-detection-of-a-meteorite-lake                                    | Detection of a meteorite Lake
 mini-ielts-reading-hunting-perfume-in-madagascar                                    | Hunting Perfume in Madagascar
 mini-ielts-reading-migratory-beekeeping                                             | Migratory Beekeeping
 mini-ielts-reading-mrs-carlill-and-the-carbolic-smoke-ball                          | Mrs. Carlill and the Carbolic Smoke Ball
 mini-ielts-reading-nature-works-for-nature-work-pla                                 | Nature works for Nature Work PLA
 mini-ielts-reading-nature-works-polylactic-acid                                     | Nature works Polylactic acid
 mini-ielts-reading-radio-automation                                                 | Radio Automation
 mini-ielts-reading-recent-research-on-humour                                        | Recent research on humour
 mini-ielts-reading-space-the-final-archaeological-frontier                          | Space: The Final Archaeological Frontier
 mini-ielts-reading-spider-silk-2                                                    | Spider silk 2
 mini-ielts-reading-sunset-for-the-oil-business                                      | Sunset for the Oil Business
 mini-ielts-reading-tattoo-on-tikopia                                                | Tattoo on Tikopia
 mini-ielts-reading-termite-mounds                                                   | Termite Mounds
 mini-ielts-reading-the-history-of-cakes-at-weddings                                 | The history of cakes at weddings
 mini-ielts-reading-the-history-of-the-poster                                        | The history of the poster
 mini-ielts-reading-the-invention-of-television                                      | The Invention of Television
 mini-ielts-reading-the-story-of-coffee                                              | THE STORY OF COFFEE
(35 rows)
```

**Note:** Zero rows with `Slug` matching `mentor/%`. The mentor-series exams use slugs prefixed `ielts-mentor-ielts-academic-reading-test-119` and `ielts-mentor-reading-test-119-passage-2-driverless-cars` — these were not returned by Q1.

### Q2: ALL blank-q rows in exam-db (any scope)

```
                            Slug                            | section_idx | question_idx |     Type     |           texts           
------------------------------------------------------------+-------------+--------------+--------------+---------------------------
 ielts-mentor-ielts-academic-reading-test-119               |           1 |           27 | MCQ_SINGLE   | {"blank-q27": ["A", "a"]}
 ielts-mentor-ielts-academic-reading-test-119               |           1 |           28 | MCQ_SINGLE   | {"blank-q28": ["C", "c"]}
 ielts-mentor-ielts-academic-reading-test-119               |           1 |           29 | MCQ_SINGLE   | {"blank-q29": ["C", "c"]}
 ielts-mentor-ielts-academic-reading-test-119               |           1 |           30 | MCQ_SINGLE   | {"blank-q30": ["D", "d"]}
 ielts-mentor-ielts-academic-reading-test-119               |           1 |           31 | MCQ_SINGLE   | {"blank-q31": ["A", "a"]}
 ielts-mentor-ielts-academic-reading-test-119               |           1 |           32 | MCQ_SINGLE   | {"blank-q32": ["B", "b"]}
 ielts-mentor-reading-test-119-passage-2-driverless-cars    |           1 |           23 | MCQ_MULTIPLE | {"blank-q23": ["C", "c"]}
 ielts-mentor-reading-test-119-passage-2-driverless-cars    |           1 |           24 | MCQ_MULTIPLE | {"blank-q24": ["D", "d"]}
 ielts-mentor-reading-test-119-passage-2-driverless-cars    |           1 |           25 | MCQ_MULTIPLE | {"blank-q25": ["A", "a"]}
 ielts-mentor-reading-test-119-passage-2-driverless-cars    |           1 |           26 | MCQ_MULTIPLE | {"blank-q26": ["E", "e"]}
 mini-ielts-reading-mrs-carlill-and-the-carbolic-smoke-ball |           1 |           13 | MCQ_SINGLE   | {"blank-q13": ["B", "b"]}
 mini-ielts-reading-space-the-final-archaeological-frontier |           1 |           12 | MCQ_MULTIPLE | {"blank-q12": ["C", "c"]}
 mini-ielts-reading-space-the-final-archaeological-frontier |           1 |           13 | MCQ_MULTIPLE | {"blank-q13": ["C", "c"]}
(13 rows)
```

### Q3: blank-q rows scoped to mentor/mini-ielts

```
                            Slug                            | row_count 
------------------------------------------------------------+-----------
 mini-ielts-reading-mrs-carlill-and-the-carbolic-smoke-ball |         1
 mini-ielts-reading-space-the-final-archaeological-frontier |         2
(2 rows)
```

**Why only 3 rows?** The `mentor/%` LIKE pattern does not match `ielts-mentor-*` slugs. Q2 already showed the ielts-mentor slugs contain 10 rows that are excluded here due to the wrong LIKE pattern in the query. See Q2 for the full ielts-mentor breakdown.

### Q4: Legacy `___` underscore placeholder rows scoped to mentor/mini-ielts

```
 Slug | row_count 
------+-----------
(0 rows)
```

### Q5: Migration script audit output

```
{
  "total_questions": 283,
  "type_breakdown": {
    "SUMMARY_COMPLETION": 224,
    "TABLE_COMPLETION": 22,
    "SENTENCE_COMPLETION": 3,
    "DIAGRAM_LABEL": 33,
    "FLOW_CHART": 1
  },
  "underscore_placeholder_count": 0,
  "underscore_placeholder_examples": [],
  "blank_q_key_count": 0,
  "blank_q_key_examples": [],
  "coexistence_row_count": 0,
  "coexistence_row_examples": [],
  "bracket_format_count": 281,
  "ready_for_phase2": true
}
```

## §3 — Analysis

### Claim inaccuracy

The HANDOFF_SPRINT3 §7 item 2 claim is wrong on three axes:

1. **Count:** Claims 18 rows; actual count is 13.
2. **Slug scope:** Claims `mentor/*` but the actual mentor-series slugs use `ielts-mentor-*` prefix (e.g., `ielts-mentor-ielts-academic-reading-test-119`). The `mentor/%` LIKE pattern returned 0 rows in Q1 and excluded the ielts-mentor exams from Q3.
3. **Script miss:** The migration script (Q5) reports 0 blank_q_key issues because it only audits non-MCQ question types (SUMMARY_COMPLETION, TABLE_COMPLETION, SENTENCE_COMPLETION, DIAGRAM_LABEL, FLOW_CHART). All 13 blank-q rows found in Q2 are `MCQ_SINGLE` or `MCQ_MULTIPLE` — the script never scans these types.

### Actual blank-q row distribution

| Slug | Type | Questions | Count |
|---|---|---|---|
| `ielts-mentor-ielts-academic-reading-test-119` | MCQ_SINGLE | q27–q32 | 6 |
| `ielts-mentor-reading-test-119-passage-2-driverless-cars` | MCQ_MULTIPLE | q23–q26 | 4 |
| `mini-ielts-reading-mrs-carlill-and-the-carbolic-smoke-ball` | MCQ_SINGLE | q13 | 1 |
| `mini-ielts-reading-space-the-final-archaeological-frontier` | MCQ_MULTIPLE | q12, q13 | 2 |
| **Total** | | | **13** |

### Legacy `___` placeholders

Zero `___` (7+ underscores) placeholders found in any mentor or mini-ielts exam.

### Relationship to Phase 1.2 audit

Phase 1.2 audited the migration script's output and found "0 blank-q keys." This is correct for the question types the script scans (non-MCQs). However, the script has a blind spot: MCQ_SINGLE and MCQ_MULTIPLE types also carry `BlankAcceptTexts` with `blank-qN` keys (Q2 proves this), but the script's type filter never reaches them. Phase 1.2 therefore passed a non-comprehensive audit.

## §4 — Verdict

**PARTIAL — 13 rows confirmed, but scope and count differ from claim.**

The 13 rows exist across 4 exams (not 18 across the claimed scope):

| # | Slug | Section | Question | Type | BlankAcceptTexts key |
|---|---|---|---|---|---|
| 1 | `ielts-mentor-ielts-academic-reading-test-119` | 1 | 27 | MCQ_SINGLE | `blank-q27` |
| 2 | `ielts-mentor-ielts-academic-reading-test-119` | 1 | 28 | MCQ_SINGLE | `blank-q28` |
| 3 | `ielts-mentor-ielts-academic-reading-test-119` | 1 | 29 | MCQ_SINGLE | `blank-q29` |
| 4 | `ielts-mentor-ielts-academic-reading-test-119` | 1 | 30 | MCQ_SINGLE | `blank-q30` |
| 5 | `ielts-mentor-ielts-academic-reading-test-119` | 1 | 31 | MCQ_SINGLE | `blank-q31` |
| 6 | `ielts-mentor-ielts-academic-reading-test-119` | 1 | 32 | MCQ_SINGLE | `blank-q32` |
| 7 | `ielts-mentor-reading-test-119-passage-2-driverless-cars` | 1 | 23 | MCQ_MULTIPLE | `blank-q23` |
| 8 | `ielts-mentor-reading-test-119-passage-2-driverless-cars` | 1 | 24 | MCQ_MULTIPLE | `blank-q24` |
| 9 | `ielts-mentor-reading-test-119-passage-2-driverless-cars` | 1 | 25 | MCQ_MULTIPLE | `blank-q25` |
| 10 | `ielts-mentor-reading-test-119-passage-2-driverless-cars` | 1 | 26 | MCQ_MULTIPLE | `blank-q26` |
| 11 | `mini-ielts-reading-mrs-carlill-and-the-carbolic-smoke-ball` | 1 | 13 | MCQ_SINGLE | `blank-q13` |
| 12 | `mini-ielts-reading-space-the-final-archaeological-frontier` | 1 | 12 | MCQ_MULTIPLE | `blank-q12` |
| 13 | `mini-ielts-reading-space-the-final-archaeological-frontier` | 1 | 13 | MCQ_MULTIPLE | `blank-q13` |

**All values are canonical:** the keys are `blank-qN` (sequential index), and the accept texts are valid answer letters. No `___` legacy placeholders exist. The rows are real but the `blank-qN` keys are non-canonical (Phase 1 migration used `blank<N>` format). These need migration to canonical `blank<N>` keys.

**Proposed migration order** (grouped by exam for atomicity):
1. `ielts-mentor-ielts-academic-reading-test-119` — 6 rows, section 1, q27–q32
2. `ielts-mentor-reading-test-119-passage-2-driverless-cars` — 4 rows, section 1, q23–q26
3. `mini-ielts-reading-mrs-carlill-and-the-carbolic-smoke-ball` — 1 row, section 1, q13
4. `mini-ielts-reading-space-the-final-archaeological-frontier` — 2 rows, section 1, q12–q13

## §5 — Phase 3.2 Action Plan

**DB action is required.** The 13 rows above need `blank-qN` → `blank<N>` key migration in `BlankAcceptTexts`.

Two-track action:

### Track A — Fix the migration script (before running migrations)

The script at `scripts/migrate_blank_placeholders.py` only scans non-MCQ types. Extend its type filter to also include `MCQ_SINGLE` and `MCQ_MULTIPLE` before executing any migration, so future audits are comprehensive.

### Track B — Migrate the 13 identified rows

SQL migration (read-only verification shown; Phase 3.2 must apply with `--apply`):

```sql
-- Dry-run preview: ielts-mentor-ielts-academic-reading-test-119
SELECT q."Id", q."Idx" AS question_idx, q."BlankAcceptTexts"::text
FROM exam_questions q
JOIN exam_sections s ON s."Id" = q."SectionId"
JOIN exams e ON e."Id" = s."ExamId"
WHERE e."Slug" = 'ielts-mentor-ielts-academic-reading-test-119'
  AND q."BlankAcceptTexts"::text ~ 'blank-q[0-9]+';

-- Pattern: replace "blank-q<N>" with "blank<N>" in BlankAcceptTexts JSONB
-- Example: {"blank-q27": ["A","a"]} → {"blank27": ["A","a"]}
-- Run via migration script with --apply, or direct UPDATE:
UPDATE exam_questions q
SET "BlankAcceptTexts" = (
  SELECT jsonb_object_agg(
    regexp_replace(k, '^blank-q(\d+)$', 'blank\1'),
    v
  )
  FROM jsonb_each_text(q."BlankAcceptTexts"::jsonb) AS t(k, v)
)
FROM exam_sections s
JOIN exams e ON e."Id" = s."ExamId"
WHERE q."SectionId" = s."Id"
  AND e."Slug" = 'ielts-mentor-ielts-academic-reading-test-119'
  AND q."BlankAcceptTexts"::text ~ 'blank-q[0-9]+';
```

Repeat for each of the 4 slugs. Commit atomically per exam.

### Track C — Re-verify after migration

```bash
# Run Q2 again post-migration; expect 0 rows
```
