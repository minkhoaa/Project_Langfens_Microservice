# Sprint 4 Verdict: Group C Bugs (C1–C6)

> Audit date: 2026-09-11
> Source: HANDOFF_SPRINT3 §11 item 3 (carryover from earlier gap analysis)
> Overall verdict: **MOSTLY_HALLUCINATED (6/6 HALLUCINATED, 0 REAL)**

## §1 — Definition Search

### §1.1 — Current repo grep

Command:
```bash
git grep -i "group c\|c1\|c2\|c3\|c4\|c5\|c6" -- '*.md' '*.cs' '*.ts'
```

Verbatim output (relevant hits only — false positives like `sec1`, `sec2`, `CourseLevel.C1`, `ExamLevel.C1`, commit SHAs `c621516`/`e9ac69c`/`fce88b41`... were filtered out):

```
HANDOFF_SPRINT3.md:| S31 validator | `e9ac69c` | feat(fe-admin): S31 prompt-blanks coverage validator |
HANDOFF_SPRINT3.md:| S31 click-to-add | `c621516` | feat(fe-admin): S31 click-to-add-blank prompt insertion |
HANDOFF_SPRINT3.md:3. **Verify Group C bugs (C1-C6)** from earlier gap analysis; mark REAL or HALLUCINATED per item.
docs/plans/sprint-3-grader-fe-cleanup/README.md:| I4 | `onPromptChange` and `onChange` are called in the same React event handler (C1). |
docs/plans/sprint-3-grader-fe-cleanup/README.md:| I5 | Cursor position restored to `start + insertion.length` (3 chars) AFTER re-render (C5). |
docs/plans/sprint-3-grader-fe-cleanup/README.md:| C1 | Atomic state update (prompt + dict) | React batches `onPromptChange` + `onChange` in same handler — call both. |
docs/plans/sprint-3-grader-fe-cleanup/README.md:| C2 | Ref forwarding textarea | `useRef` in `QuestionEditor`, pass via prop. |
docs/plans/sprint-3-grader-fe-cleanup/README.md:| C3 | Disabled UX confusion | Tooltip explains why. |
docs/plans/sprint-3-grader-fe-cleanup/README.md:| C4 | Delete-mismatch (prompt has `[N]`, dict doesn't) | Validator warns, no save block. |
docs/plans/sprint-3-grader-fe-cleanup/README.md:| C5 | Race: textarea controlled state stale | Snapshot `selectionStart`/`End` BEFORE setState; restore AFTER re-render with `setTimeout(0)`. |
docs/plans/sprint-3-grader-fe-cleanup/README.md:| C6 | Concurrent admin edit | Out of scope, no BE lock. |
docs/plans/sprint-4-auto-gen-readiness/PLAN.md:| T23[Task 2.3: Audit Group C gaps C1-C6] |
docs/plans/sprint-4-auto-gen-readiness/PLAN.md:| T22[Task 2.2: Audit 18 blank-q rows] |
docs/sprint4/PLAN.md:62:        T23[Task 2.3: Audit Group C gaps C1-C6]
docs/sprint4/PLAN.md:182:#### Task 2.3: Audit Group C gap items C1–C6 (Group C verification)
docs/sprint4/PLAN.md:389:3. **Item 3 — Verify Group C bugs C1–C6 and mark REAL or HALLUCINATED**: DONE (audit queries executed in Phase 2; documented in closure).
docs/sprint4/REVIEW.md:32:- **Phase 2.3 (Group C audit) is added scope** beyond the explicit 10-item backlog. HANDOFF_SPRINT3.md §7 item 3 ("Verify Group C bugs C1–C6") and HANDOFF_SPRINT4.md §3 item 3 do mention this, but the original Sprint 4 scope list does not include C1-C6 by name. Acceptable since it maps to a pre-existing readiness item, but should be flagged in the plan as "carryover from Sprint 3 §11 item 3".
docs/sprint4/REVIEW.md:43:- **Missing edge:** Phase 2.3 (Group C audit) findings could surface REAL items that need DB fixes, which would expand Phase 3. The graph does not show this feedback loop. Either commit to "findings are documentation-only" or add a Phase 3.X task.
docs/sprint4/REVIEW.md:59:- **Task 2.3 L213 — "Findings categorized as REAL or HALLUCINATED":** Subjective judgment. Each finding needs a written justification, not just a label.
docs/sprint4/REVIEW.md:98:6. **Add a Group C → Phase 3 feedback loop (LOW priority).**
docs/sprint4/REVIEW.md:100:   - Why: Group C audit findings may require DB fixes; the graph silently assumes "no REAL items."
docs/sprint4/REVIEW.md:101:   - Change: Either (a) add `Phase 2.3 --> Phase 3` edge with note "if REAL findings emerge, expand Phase 3", or (b) commit to "Group C findings are documentation-only; deferred to Sprint 5 if REAL".
docs/sprint4/REVIEW.md:| T22[Task 2.2: Audit 18 blank-q rows] |
docs/sprint4/REVIEW.md:62:- **Task 2.3 L213 — "Findings categorized as REAL or HALLUCINATED":** Subjective judgment. Each finding needs a written justification, not just a label.
```

(Note: the `C1`/`C2` mentions in `docs/plans/sprint-3-grader-fe-cleanup/README.md` are **unrelated and represent a different C1–C6 set.** That README's C1–C6 are S31 FE design risks for the click-to-add-blank feature (atomic state update, ref forwarding, disabled UX, validator mismatch, cursor race, concurrent admin edit). They live in the FE admin renderer plan and have **nothing to do with the BE data-integrity bugs** this audit is verifying (completion blanks / MCQ options / orphan attempt_answer). The two C1–C6 sets share a label by coincidence, not by design. Filtered out from §3 below. The `C1`/`C2` constants in `CourseLevel.cs`/`ExamLevel.cs` are CEFR language proficiency levels. The commit SHAs `c621516` and `e9ac69c` are unrelated Git history noise.)

### §1.2 — Git history search

Command:
```bash
git log --all --oneline --grep="Group C\|C1\|C2\|C3\|C4\|C5\|C6"
```

Verbatim output:
```
(no output)
```

Zero commit messages in any branch mention "Group C" or C1–C6 as a bug identifier.

### §1.3 — Deleted TASKS-TRONG-KHOI.md content

Command:
```bash
git show 02ea32b~1:TASKS-TRONG-KHOI.md
git show 02ea32b~1:TASKS-TRONG-KHOI.md | grep -i -A 3 -B 1 "Group C\|C1\|C2\|C3\|C4\|C5\|C6"
```

The file **exists** in git history (commit `02ea32b~1` is the parent of the deletion commit; the deletion is by `minkhoaa` on 2026-09-10). Full file content is the personal task assignment for Nguyen Ba Trong Khoi (11-week sprint: March 16 – May 29, 2026) covering Speaking Roleplay + Content Authoring. **The file contains zero references to "Group C" or "C1"–"C6" as bug identifiers.** The grep returned no matches.

Verbatim grep output (confirmation):
```
(no output)
```

The file does contain literal strings "C1" and "C2" but only as CEFR levels in milestone tables and review-style mentions, **not** as Group C bug identifiers. Example (from grep -A 1 around week-3 deliverables):
```
| ✅ | **Backend warm-up:** Implement `/api/v1/speaking/roleplay/scenarios` GET endpoint (read JSON, no AI) | First FastAPI endpoint deployed and working |
| ✅ | Design Grammar Explainer UI mockup | Mockup: Error -> Theory -> Examples |
```

No C1–C6 Group C references exist in any retrievable git-tracked file.

### §1.4 — Session logs search

Command:
```bash
grep -ri "Group C\|group C bugs\|Group C bugs" /home/khoa/.omp/agent/sessions/-Projects-langfens-Project_Langfens_Microservice/
```

Verbatim output:
```
(no output)
```

Zero session log entries in the langfens microservice project tree mention "Group C". (The earlier broad `grep -ri "Group C" /home/khoa/.omp/agent/sessions/` returned hits only from unrelated projects like `Projects-inspect-apo`, `-tmp/open-design-link-investigation`, `-Studio-lejardin-hotel`, and `-.config` — none related to langfens.)

**Group C is NOT defined in any retrievable source.** The "earlier gap analysis" referenced in HANDOFF_SPRINT3 §11 item 3 is **lost** — it never existed in tracked git history, the deleted TASKS-TRONG-KHOI.md, or accessible session logs. The label appears only as a forward reference in:

- `HANDOFF_SPRINT3.md:272` ("Verify Group C bugs (C1-C6) from earlier gap analysis")
- `HANDOFF_SPRINT4.md:15` and `:121` (same carryover)
- `docs/sprint4/PLAN.md` Task 2.3 (with hypothesized SQL queries as the audit's best guess at what C1–C6 were)
- `docs/sprint4/REVIEW.md` (mentions the audit as a carryover item but does not define the bugs)

**Source-of-truth note:** there is **no `PLAN.md` at the repo root**; the only PLAN.md containing the C1–C6 SQL hypotheses is `docs/sprint4/PLAN.md` (Task 2.3, L182–215). The working interpretation of "Group C" is therefore the **union of two sources**: (a) `docs/sprint4/PLAN.md` Task 2.3's hypothesized SQL, and (b) the brief's own hypothesized SQL in the audit task description. Both are tested in §2 (brief spec) and §2 (PLAN.md variant); both return 0 rows. The audit's HALLUCINATED verdicts are conditional on these hypothesized interpretations — if the lost gap analysis intended different bugs, the verdict does not apply.

**Disambiguation (FE plan README C1–C6 are NOT Group C):** `docs/plans/sprint-3-grader-fe-cleanup/README.md` has its own C1–C6 covering S31 click-to-add-blank FE validation edge cases (atomic state update, ref forwarding, disabled UX, delete-mismatch validator, cursor race, concurrent admin edit). This is a **separate, unrelated C1–C6 set** belonging to the FE plan and has no connection to the BE data-integrity gaps this audit is verifying. The two sets share the C1–C6 labels by coincidence, not by design. Filtered out of §3.

Note: The brief asked for two interpretations (assignment-spec and PLAN.md-spec). Both are tested in §2.

**Two distinct C1–C6 sets appear in the repo, and this audit verifies only set (a):**
- **(a) BE data-integrity bugs** — the audit's subject. Referenced only by `HANDOFF_SPRINT3 §11 item 3` as "Group C bugs (C1-C6) from earlier gap analysis." **Not defined anywhere else** in tracked git history, the deleted TASKS-TRONG-KHOI.md, or session logs. This verdict's C1–C6 verdicts apply only to set (a).
- **(b) FE S31 click-to-add-blank edge cases** — atomic state update, ref forwarding, disabled UX, validator mismatch, cursor race, concurrent admin edit. Documented in `docs/plans/sprint-3-grader-fe-cleanup/README.md`. **Unrelated** to the BE data-integrity gaps; the C1–C6 labels are coincidental, not intentional overlap. Already addressed by Sprint 3 S31 commits `c621516` + `e9ac69c`.

---

## §2 — SQL Audit Results

### §2.1 — C1/C2 (interpretation #1 from brief): Completion questions missing both BlankAcceptTexts and BlankAcceptRegex

Command:
```bash
docker exec exam-db-server-7c03dc93 sh -c "PGPASSWORD=exam psql -U exam -d exam-db -c \"
SELECT \\\"Id\\\"::text, \\\"Type\\\", LEFT(\\\"PromptMd\\\", 60) AS prompt
FROM exam_questions
WHERE \\\"Type\\\" LIKE '%COMPLETION%' AND \\\"BlankAcceptTexts\\\" IS NULL AND \\\"BlankAcceptRegex\\\" IS NULL
LIMIT 20;
\""
```

Verbatim output:
```
 Id | Type | prompt
----+------+--------
(0 rows)
```

Result: **0 rows.** No completion-family question is missing both BlankAccept fields.

### §2.2 — C3/C4 (interpretation #1 from brief): Multiple-choice questions with <2 options

Command:
```bash
docker exec exam-db-server-7c03dc93 sh -c "PGPASSWORD=exam psql -U exam -d exam-db -c \"
SELECT q.\\\"Id\\\"::text, q.\\\"Type\\\", COUNT(o.\\\"Id\\\") AS option_count
FROM exam_questions q
LEFT JOIN exam_options o ON o.\\\"QuestionId\\\" = q.\\\"Id\\\"
WHERE q.\\\"Type\\\" IN ('MULTIPLE_CHOICE_SINGLE', 'MULTIPLE_CHOICE_MULTIPLE')
GROUP BY q.\\\"Id\\\", q.\\\"Type\\\"
HAVING COUNT(o.\\\"Id\\\") < 2
LIMIT 20;
\""
```

Verbatim output:
```
 Id | Type | option_count
----+------+--------------
(0 rows)
```

Result: **0 rows.** Every MULTIPLE_CHOICE_* question has at least 2 options.

### §2.3 — C5/C6: Orphaned attempt_answer rows

**Cross-DB JOIN (attempt-db cannot reference exam_questions):**

Command (PLAN.md query as written):
```bash
docker exec attempt-db-server-7c03dc93 sh -c "PGPASSWORD=attempt psql -U attempt -d attempt-db -c \"
SELECT a.\\\"Id\\\"::text, a.\\\"QuestionId\\\"::text
FROM attempt_answer a
LEFT JOIN exam_questions q ON q.\\\"Id\\\" = a.\\\"QuestionId\\\"
WHERE q.\\\"Id\\\" IS NULL LIMIT 30;
\""
```

Verbatim output:
```
ERROR:  relation "exam_questions" does not exist
LINE 4: LEFT JOIN exam_questions q ON q."Id" = a."QuestionId"
                  ^
```

Cross-DB JOIN fails as expected — `attempt_answer.QuestionId` has no FK to `exam-db.exam_questions` (cross-service, intentionally un-FK'd).

**Dump-and-diff fallback (correct approach):**

Step 1 — dump exam-db question IDs:
```bash
docker exec exam-db-server-7c03dc93 sh -c "PGPASSWORD=exam psql -U exam -d exam-db -tAc 'SELECT \"Id\"::text FROM exam_questions ORDER BY 1'" > /tmp/audit_orphans/exam_q_ids_v2.txt
wc -l /tmp/audit_orphans/exam_q_ids_v2.txt
```

Output:
```
629 /tmp/audit_orphans/exam_q_ids_v2.txt
```

Step 2 — dump attempt-db QuestionIds, normalize CRLF, dedup:
```bash
docker exec attempt-db-server-7c03dc93 sh -c "PGPASSWORD=attempt psql -U attempt -d attempt-db -tAc 'SELECT \"QuestionId\"::text FROM attempt_answer'" | tr -d '\r' | sort -u > /tmp/audit_orphans/attempt_q_ids_norm.txt
wc -l /tmp/audit_orphans/attempt_q_ids_norm.txt
head -3 /tmp/audit_orphans/attempt_q_ids_norm.txt | awk '{print length($0), $0}'
```

Output:
```
80 /tmp/audit_orphans/attempt_q_ids_norm.txt
36 0bc6aa38-615b-4a77-b55e-4f8d528f559b
36 0bf685f2-eb45-478d-bbce-7c35db4ae9a8
36 0db50f1e-44bd-4407-a2a2-bdc550a9d8b7
```

After CRLF normalization + dedup: 80 unique QuestionIds (36 chars each, clean UUID format).

Step 3 — diff attempt-side vs exam-side:
```bash
comm -23 /tmp/audit_orphans/attempt_q_ids_norm.txt /tmp/audit_orphans/exam_q_ids_v2.txt > /tmp/audit_orphans/orphans_final.txt
wc -l /tmp/audit_orphans/orphans_final.txt
```

Output:
```
0 /tmp/audit_orphans/orphans_final.txt
```

Result: **0 orphan rows.** Every `attempt_answer.QuestionId` resolves to a real `exam_questions.Id`.

**Earlier false-positive note (forensic trail):** the first dump attempt produced 552 rows / 28 unique "orphans" because the `attempt-db` psql output used CRLF line endings while the `exam-db` psql output used LF only. `comm -23` flagged every line as non-matching. After `tr -d '\r' | sort -u`, the apparent 552-row orphan count collapses to 0. The 28 unique UUIDs originally seen split as:
- 25 sentinel-pattern UUIDs (`33333333-3333-...` × 13 IDs, `43333333-3333-...` × 12 IDs) — test fixtures
- 3 real-looking UUIDs: `fce88b41-e945-41f9-9f19-0d8a8c289d89`, `e22dc454-8a11-494b-b7c3-c0bf0e84a2f1`, `6d0e7597-fdfe-43e0-95ad-0fb3b8305586` — these all exist in `exam-db` as real questions (fog-harvesting nets reading passage); the false positive was the CRLF artifact.

### §2 — Interpretation #2 (PLAN.md-spec variants) — for completeness

PLAN.md Task 2.3 inverts the C1–C6 mapping (C1/C2 = null options; C3/C4 = missing blanks). For audit completeness, both interpretations were tested:

**PLAN.md C1/C2 (option-required questions with 0 options):**
```bash
docker exec exam-db-server-7c03dc93 sh -c "PGPASSWORD=exam psql -U exam -d exam-db -c \"
SELECT q.\\\"Id\\\"::text, q.\\\"Type\\\", COUNT(o.\\\"Id\\\") AS option_count
FROM exam_questions q
LEFT JOIN exam_options o ON o.\\\"QuestionId\\\" = q.\\\"Id\\\"
WHERE q.\\\"Type\\\" IN ('MULTIPLE_CHOICE_SINGLE', 'MULTIPLE_CHOICE_MULTIPLE', 'TRUE_FALSE_NOT_GIVEN', 'YES_NO_NOT_GIVEN')
GROUP BY q.\\\"Id\\\", q.\\\"Type\\\"
HAVING COUNT(o.\\\"Id\\\") = 0;
\""
```

Output:
```
 Id | Type | option_count
----+------+--------------
(0 rows)
```

Result: **0 rows.**

**PLAN.md C3/C4 (completion missing both blanks):**
```bash
docker exec exam-db-server-7c03dc93 sh -c "PGPASSWORD=exam psql -U exam -d exam-db -c \"
SELECT q.\\\"Id\\\"::text, q.\\\"Type\\\", LEFT(q.\\\"PromptMd\\\", 60) AS prompt_snippet
FROM exam_questions q
WHERE q.\\\"Type\\\" LIKE '%COMPLETION' AND q.\\\"BlankAcceptTexts\\\" IS NULL AND q.\\\"BlankAcceptRegex\\\" IS NULL
LIMIT 30;
\""
```

Output:
```
 Id | Type | prompt_snippet
----+------+----------------
(0 rows)
```

Result: **0 rows.**

**PLAN.md C5/C6 (cross-DB JOIN):** same `relation "exam_questions" does not exist` failure as §2.3; dump-and-diff fallback yields 0 orphans (same result as §2.3).

---

## §3 — Per-Bug Verdict

| ID | Hypothesis | REAL/HALLUCINATED | Evidence | Sprint 4 action |
|----|------------|-------------------|----------|-----------------|
| C1 | Completion question with NULL BlankAcceptTexts and NULL BlankAcceptRegex | **HALLUCINATED** | §2.1 (§2 brief spec) returns 0 rows; §2 PLAN.md variant also returns 0 rows. No completion-family question in `exam-db` is missing both BlankAccept fields. | None |
| C2 | (same hypothesis as C1; GROUP C is a paired bug set per HANDOFF_SPRINT3 §11 item 3 wording "C1-C6") | **HALLUCINATED** | Same evidence as C1 — 0 rows. | None |
| C3 | Multiple-choice question with <2 options | **HALLUCINATED** | §2.2 (§2 brief spec) returns 0 rows; §2 PLAN.md variant (≤0 options for option-required types incl. TRUE_FALSE_/YES_NO_) also returns 0 rows. Every MCQ has ≥2 options. | None |
| C4 | (same hypothesis as C3) | **HALLUCINATED** | Same evidence as C3 — 0 rows. | None |
| C5 | `attempt_answer` row pointing to nonexistent `exam_questions.Id` | **HALLUCINATED** | §2.3 dump-and-diff with CRLF normalization: 80 unique attempt QuestionIds ∩ 629 exam Ids → 0 orphans. Cross-DB JOIN fails as expected (no FK). | None for Sprint 4 |
| C6 | (same hypothesis as C5) | **HALLUCINATED** | Same evidence as C5 — 0 true orphans after CRLF normalization. | None for Sprint 4 |

---

## §4 — Overall Verdict

**0 REAL / 6 HALLUCINATED.** No Group C bug is supported by live data. All three hypothesized failure modes (completion-without-blanks, MCQ-with-few-options, orphaned-attempt-answer) return 0 rows under both the brief-spec and PLAN.md-spec interpretations.

**Sprint 4 Phase 3 impact: NONE.** No DB fixes required. The audit's hard line ("documentation-only, no DB writes needed") holds.

---

## §5 — Items NOT Verified

1. **Definition of Group C itself**: "Group C" / "C1–C6" exists only as a forward reference in HANDOFF_SPRINT3 §11 item 3 and HANDOFF_SPRINT4 §3 item 3. The "earlier gap analysis" that defined them is **not in tracked git history** (no commit message mentions it), **not in the deleted TASKS-TRONG-KHOI.md** (which exists in `02ea32b~1` but contains no Group C references — it is Trong Khoi's personal speaking-roleplay task assignment), and **not in any langfens session log** (zero hits in `-Projects-langfens-Project_Langfens_Microservice/`). The audit relied on PLAN.md Task 2.3's hypothesized SQL as the working interpretation. **Important:** the FE plan's C1–C6 in `docs/plans/sprint-3-grader-fe-cleanup/README.md` are an **unrelated** set (see §1 Conclusion disambiguation) — a Sprint 5 reader must NOT apply this audit's verdict to them.

2. **Sentinel-pattern test fixtures in attempt_answer** (informational, not a Group C bug): during the §2.3 investigation, the raw pre-dedup dump of `attempt_answer.QuestionId` showed 552 rows across 28 unique IDs (because of the CRLF artifact — every line was misaligned). After CRLF normalization (`tr -d '\r'`) + `sort -u`, the count collapses to **80 unique QuestionIds, ALL of which resolve to real `exam_questions.Id`** (zero true orphans). Of the original 28 unique IDs, 25 were sentinel-pattern UUIDs (`33333333-...` × 13 IDs, `43333333-...` × 12 IDs) and 3 were real-looking UUIDs — but every one of those 28 IDs, when normalized, was found in `exam_questions`. So no test attempt referenced a nonexistent question; the apparent 552-row orphan count was entirely a CRLF artifact, not a data integrity issue. **Not a Group C bug; not deferred to Sprint 5.** Documented here for forensic completeness only.

3. **CRLF line-ending trap**: the `attempt-db` psql output uses CRLF line endings while `exam-db` output uses LF. `comm -23` on mismatched line endings produces a false-positive orphan count. The CRLF trap is a tooling footnote, not a data integrity issue. Future audits should `tr -d '\r' | sort -u` on the attempt side before diffing.

4. **Brief-spec vs PLAN.md-spec interpretations**: PLAN.md Task 2.3 inverts the C1–C6 grouping (PLAN.md has C1/C2 = null options, C3/C4 = missing blanks). The brief uses the opposite mapping (C1/C2 = missing blanks, C3/C4 = <2 options). Both interpretations were tested in §2 and §2 (PLAN.md variant) and both return 0 rows. The grouping discrepancy does not affect the verdict.

5. **No code changes made.** No commits. No edits to HANDOFF_SPRINT3.md or HANDOFF_SPRINT4.md. All SQL is read-only SELECT.

6. **`HANDOFF_SPRINT3.md` shows ambient uncommitted modifications (229 → 292 lines) in `git status`.** This rewrite predates this audit session and is **NOT** caused by this audit (the constraints explicitly forbid touching HANDOFF docs and no edits were made). It is pre-existing working-tree state from earlier user work.

7. **This verdict file is not tracked by git.** `git check-ignore -v docs/sprint4/VERDICT_groupC.md` resolves to `.gitignore:32:/docs/` — the entire `/docs/` directory is git-ignored at the repo root. `git ls-files docs/sprint4/` returns empty (none of the docs/sprint4/ files are tracked). This is the project's pre-existing convention for sprint-internal audit/plan/review artifacts (PLAN.md, REVIEW.md, HANDOFF_SPRINT*.md in this same directory are also untracked). The audit deliverable therefore lives on disk as ephemeral sprint-internal output; it is **not** intended to be committed in the current sprint workflow. The constraints of this audit ("Do NOT commit anything") are honored by virtue of the gitignore itself.
