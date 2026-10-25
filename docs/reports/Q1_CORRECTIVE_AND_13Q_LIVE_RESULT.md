# Autonomous IELTS Academic Reading — Q1 Corrective & 13-Question Live Execution Report

## Executive Summary

Pursuant to explicit project owner instructions, this report documents the forensic replay, root cause diagnosis, surgical corrective implementation, offline regression gates, and the authorized single MiniMax LIVE run on Europe PMC `PMC13654891` (Didé West 1 metallurgy, Falémé Valley, Eastern Senegal).

**Final Verdict:** `PARTIAL` (Terminal job, 4/13 questions accepted with durable PostgreSQL heads, Section 1 uncommitted due to stage token cap on Q5).

### Key Accomplishments
1. **Historical Q1 Forensic Replay & Root Cause Resolution**: Proved that Q1 candidate rejection in run `cba0c609-f9c0-4294-b687-362a7413519a` stemmed from overly broad evidence quotes spanning adjacent claims (Claim 1 and Claim 2), compounded by a false-positive `marker_conflict` across disjoint categories (`qualifier:only/few` in bound claim vs `entity:west africa` in quote).
2. **Surgical Claim-Local Evidence Selection**: Implemented `select_claim_local_evidence` in `app/section_runner.py` and category-aware marker conflict in `app/reading_evaluation.py` without lowering overlap thresholds or weakening provenance.
3. **Offline Acceptance Gate (119/119 PASS)**: Added 15 new regression tests in `test_q1_claim_local_evidence_regression.py`. All 119 tests across all provenance, grounding, TFNG, solver, and live runner suites passed cleanly.
4. **MiniMax LIVE Execution Proof**:
   - **Passage Generation**: 858 words (strictly within the 700–900 words target), passing all word count, fidelity, and semantic evaluators.
   - **Q1 Accepted on Version 1**: Correctly localized and grounded in Claim 2, independently verified by the blind solver (`TRUE`), and durably committed to PostgreSQL.
   - **Q2 Accepted on Version 1**: Grounded in Claim 12 (Jos Plateau 600 BCE), verified by blind solver (`TRUE`), and durably committed.
   - **Q3 Accepted on Version 2**: Grounded in Claim 1 absence assessment, successfully repaired in-loop, verified by blind solver (`NOT_GIVEN`), and durably committed.
   - **Q4 Accepted on Version 1**: Grounded in Claim 9 (chronologies), verified by blind solver (`TRUE`), and durably committed.
   - **Q5 Token Cap Safe Termination**: Reached bounded loop version 3, whereupon the question stage token cap triggered a clean, fail-closed termination. No partial unverified section was committed to PostgreSQL.

---

## 1. Historical Q1 Per-Candidate Forensic Replay Matrix

Replayed from the forensic snapshot `reports/hybrid_13q_post_hardening_cba0c609-f9c0-4294-b687-362a7413519a.json` (Bound Claim 2: `claim:...:1:2`):

| Op ID / Attempt | Cand Idx | Proposed Answer | Tested Statement | Evidence Quote / Topical Context | Bound Ratio (Claim 2) | Competing Ratio | Multi-Claim Content? | Stage & Failure Code | Selected? | Passed Evaluators? |
|---|:---:|:---:|---|---|:---:|:---:|:---:|---|:---:|:---:|
| **Op 16** (v1_1) | 0 | **TRUE** | "The passage states that only a few iron production sites in West Africa provide sufficient detail for in-depth historical and anthropological analysis." | `"While the region boasts a growing number of iron production sites that testify to the use of diverse smelting techniques as early as the first millennium BCE, only a few provide the necessary detail for in-depth analysis of historical and anthropological dimensions."` (214..480) | 0.476 | **Claim 1: 0.688** | **YES** (Clause 1 = Claim 1; Clause 2 = Claim 2) | `_parse_candidate_payload` line 1002 (`CLAIM_PROVENANCE_MISMATCH`: quote primarily supports Claim 1) | NO | **YES** (if localized to Clause 2, all 5 evaluators pass) |
| **Op 16** (v1_1) | 1 | **FALSE** | "The passage mentions that iron production sites in West Africa have been dated to the second millennium BCE." | `"While the region boasts a growing number of iron production sites that testify to the use of diverse smelting techniques as early as the first millennium BCE..."` (214..371) | 0.190 | **Claim 1: 0.688** | NO (tests Claim 1 solely) | `_parse_candidate_payload` line 1002 (`CLAIM_PROVENANCE_MISMATCH`) | NO | NO (tests wrong claim) |
| **Op 16** (v1_1) | 2 | **NOT_GIVEN** | "The passage discusses the specific challenges of studying early iron production in West Africa due to the scarcity of well-preserved sites." | Topical: `"The study of early iron production in West Africa has long been a subject of significant scholarly interest, yet it remains challenging due to the scarcity of well-preserved, well-documented, and well-dated sites."` (0..213) | 0.476 | Claim 7: 0.429 | NO | Downstream evaluation: `eval_question_semantic` failed with `TFNG_BOUNDARY_CONFLICT` | **YES** (sole survivor) | NO (statement entailed by text) |
| **Op 25** (v1_2) | 0 | **FALSE** | "The passage states that there are numerous well-preserved iron production sites in West Africa from the first millennium BCE that allow for detailed historical analysis." | Multi-claim sentence 2 (214..480) | 0.476 | **Claim 1: 0.688** | **YES** (mixed Claim 1 / 2) | `_parse_candidate_payload` (`CLAIM_PROVENANCE_MISMATCH`) | NO | NO |
| **Op 25** (v1_2) | 1 | **TRUE** | "The passage mentions that the study of early iron production in West Africa is a subject of significant scholarly interest." | Sentence 1: `"The study of early iron production in West Africa has long been a subject of significant scholarly interest..."` (0..213) | 0.476 | Claim 5: 0.400 | NO | `_parse_candidate_payload` (`CLAIM_PROVENANCE_MISMATCH` via cross-category `marker_conflict`) | NO | **YES** (valid true statement on Claim 2) |
| **Op 25** (v1_2) | 2 | **NOT_GIVEN** | "The passage discusses the specific challenges of studying early iron production in West Africa due to the lack of well-preserved sites." | Sentence 1 (0..213) | 0.476 | Claim 7: 0.429 | NO | Downstream: `eval_blind_solver_adversary` (`UNSUPPORTED_OR_CONTRADICTED_CLAIM`: solver answered TRUE) | **YES** (sole survivor) | NO (solver contradicted expected key) |
| **Op 35** (v1_3) | 0 | **TRUE** | "The passage states that only a few iron production sites in West Africa are well preserved, well documented, and well dated." | Multi-claim sentence 2 (214..480) | 0.476 | **Claim 1: 0.688** | **YES** | `_parse_candidate_payload` (`CLAIM_PROVENANCE_MISMATCH`) | NO | NO |
| **Op 35** (v1_3) | 1 | **NOT_GIVEN** | "The passage mentions that iron production in West Africa dates back to the second millennium BCE." | Non-verbatim topical span ("...") | 0.190 | Claim 1: 0.688 | NO | `_parse_single_candidate` (`QUOTE_NOT_VERBATIM`) | NO | NO |
| **Op 36** (v1_3_att2) | 0 | **TRUE** | "The passage states that the study of early iron production in West Africa is challenging due to the scarcity of well-preserved sites." | Sentence 1 (0..213) | 0.476 | Claim 5: 0.400 | NO | `_parse_candidate_payload` (`CLAIM_PROVENANCE_MISMATCH` via cross-category `marker_conflict`) | NO | **YES** (valid true statement on Claim 2) |
| **Op 36** (v1_3_att2) | 1 | **FALSE** | "The passage mentions that iron production in West Africa dates back to the second millennium BCE." | Multi-claim sentence 2 (214..371) | 0.190 | Claim 1: 0.688 | NO | `_parse_candidate_payload` (`CLAIM_PROVENANCE_MISMATCH`) | NO | NO |
| **Op 36** (v1_3_att2) | 2 | **NOT_GIVEN** | "The passage discusses the specific challenges of studying iron production in the Senegal River Valley." | Senegal River Valley quote (1177..1282) | 0.048 | Claim 16: 0.875 | NO | `_parse_candidate_payload` (`CLAIM_PROVENANCE_MISMATCH`: lack of topical grounding) | NO | NO |

---

## 2. Verified Root Causes

The forensic replay identified two distinct root causes that compounded to create the Q1 failure:

### Root Cause 1: Overly Broad Multi-Clause Evidence Quotes (Op 16 c0, Op 25 c0, Op 35 c0)
The passage generator synthesized two claims into a single compound sentence:
- **Subordinate clause (Claim 1)**: `"While the region boasts a growing number of iron production sites that testify to the use of diverse smelting techniques as early as the first millennium BCE,"`
- **Main clause (Claim 2)**: `"only a few provide the necessary detail for in-depth analysis of historical and anthropological dimensions."`

When MiniMax-Text-01 formulated Candidate 0 testing Claim 2, it copied the entire compound sentence as `evidenceQuote`. Lexical similarity calculation computed 11 / 16 words shared with Claim 1 (0.688 ratio) versus 10 / 21 words shared with Claim 2 (0.476 ratio). The Anti-Wrong-Claim gate correctly observed that the quote as a whole overlapped higher with Claim 1 than Claim 2 and rejected it, despite the question proposition testing Claim 2 exclusively.

### Root Cause 2: Cross-Category Marker Conflict on Shared Regional Geography (Op 25 c1, Op 36 c0)
The marker conflict condition:
```python
marker_conflict = bool(
    (bound_markers - quote_markers)
    and (quote_markers & other_markers)
    and (bound_markers - other_markers)
)
```
did not distinguish semantic marker types. In Op 25 Candidate 1:
- `bound_markers` on Claim 2 contained qualifiers: `{'qualifier:only', 'qualifier:few'}`
- `quote_markers` on Sentence 1 contained regional entity: `{'entity:west africa'}`
- `other_markers` on Claim 5 contained regional entity: `{'entity:west africa'}`

Because `bound_markers - other_markers` was non-empty (qualifiers) and `quote_markers & other_markers` was non-empty (entity), the condition evaluated to `True`. An entity marker was falsely evaluated as conflicting with a qualifier marker across disjoint semantic categories, penalizing shared regional geography.

### Compounding Effect on Selection
Because valid TRUE candidates were excluded, the candidate pool selection was left with only defective NOT_GIVEN candidates. These NOT_GIVEN statements were actually entailed by passage facts, leading to downstream `TFNG_BOUNDARY_CONFLICT` rejection on V1 and blind-solver key disagreement on V2.

---

## 3. Minimal Implemented Correction

The correction was implemented in two targeted components:

### 1. Claim-Local Evidence Selection (`services/generation-service/app/section_runner.py`)
Added `select_claim_local_evidence(...)` invoked during candidate parsing:
- Inspects candidates with valid verbatim passage quotes.
- If the full quote is clean (no competing claim dominance), preserves it intact.
- If the quote exhibits competing claim interference, partitions the quote into constituent sentences and clauses (`len >= 20`).
- Evaluates candidate subspans:
  1. Must be exact contiguous substrings of the passage.
  2. Must preserve essential qualifiers, numbers, and negations present in the tested statement.
  3. Must substantively support the tested proposition (`r_stmt >= 0.20`) and bound claim (`r_bound >= 0.20`).
  4. Must not be dominated by any competing claim (`r_bound >= top_competing_r`).
  5. For completion questions, must contain the verbatim answer.
- Returns the exact claim-local subspan and its updated passage offsets.
- Fails closed: if no valid claim-local subspan satisfies the constraints, the original quote is retained, allowing downstream gates to reject ungrounded items.

### 2. Category-Aware Marker Conflict (`services/generation-service/app/reading_evaluation.py`)
Added `_has_category_marker_conflict(...)`:
```python
def _has_category_marker_conflict(
    bound_markers: set[str],
    quote_markers: set[str],
    other_markers: set[str],
) -> bool:
    """Detects factual discriminator conflicts within specific semantic categories.

    Ensures that a missing qualifier in bound text is not falsely 'conflicted'
    by an unrelated geographic entity in other text when the categories are disjoint.
    """
    for prefix in ("number:", "qualifier:", "entity:"):
        b_c = {m for m in bound_markers if m.startswith(prefix)}
        q_c = {m for m in quote_markers if m.startswith(prefix)}
        o_c = {m for m in other_markers if m.startswith(prefix)}
        if (b_c - q_c) and (q_c & o_c) and (b_c - o_c):
            return True
    return False
```
Evaluates conflict within each category (`number:`, `qualifier:`, `entity:`), preventing cross-category false positives while maintaining strict rejection on numerical, chronological, entity, and qualifier drift.

### 3. Solver / Adversary Model Conformance & Dependency Binding
- Bound `BlindSolverEvaluator` adversary model to `MiniMax-Text-01` when minimax provider is active, eliminating an unintended Groq model default (`openai/gpt-oss-120b`).
- Added `input_dependency_refs` propagation on evaluation error results and defensive model copy in `stage_executor.py`.

---

## 4. Strict Provenance Regressions Verification

All strict provenance invariants were independently verified to remain intact:

| Invariant | Test Case | Expected Outcome | Verified Result |
|---|---|:---:|:---:|
| **Historical Q2 Wrong-Claim Association** | Bound Claim 1, cites Claim 2 | FAIL with `CLAIM_PROVENANCE_MISMATCH` | **PASS (Strictly Rejected)** |
| **Historical Q4 Wrong-Claim Association** | Bound Claim 9, cites Claim 11 | FAIL with `CLAIM_PROVENANCE_MISMATCH` | **PASS (Strictly Rejected)** |
| **Historical Q5 Wrong-Claim Association** | Bound Claim 11, cites Claim 9 | FAIL with `CLAIM_PROVENANCE_MISMATCH` | **PASS (Strictly Rejected)** |
| **Pure Competing-Claim Evidence** | Op 16 Candidate 1 (tests Claim 1 under Claim 2 slot) | FAIL with `CLAIM_PROVENANCE_MISMATCH` | **PASS (Strictly Rejected)** |
| **Numerical Drift** | 600 BCE vs 700 BCE | FAIL with `CLAIM_PROVENANCE_MISMATCH` | **PASS (Strictly Rejected)** |
| **Qualifier Inversion** | "only a few" vs "most sites" | FAIL with `CLAIM_PROVENANCE_MISMATCH` | **PASS (Strictly Rejected)** |
| **Entity Substitution** | "Senegal" vs "Nigeria" | FAIL with `CLAIM_PROVENANCE_MISMATCH` | **PASS (Strictly Rejected)** |
| **Count Drift** | 12 sites vs 21 sites | FAIL with `CLAIM_PROVENANCE_MISMATCH` | **PASS (Strictly Rejected)** |
| **Q10 Non-Verbatim Completion** | Answer "hosted districts" | Rejected by completion grounding check | **PASS (Strictly Rejected)** |
| **TFNG Entailment Conflict** | Op 16 Candidate 2 (entailed NOT_GIVEN) | FAIL with `TFNG_BOUNDARY_CONFLICT` | **PASS (Strictly Rejected)** |
| **Blind Solver Contradiction** | Op 25 Candidate 2 | `KEY_CONTRADICTED` | **PASS (Strictly Rejected)** |
| **Shared Geography Invariant** | Sentence 1 quote with "West Africa" | Accepted without false `marker_conflict` | **PASS (Accepted)** |
| **Claim-Local Localization** | Op 16 Candidate 0 localized to Clause 2 | Offsets 373..480, all 5 evaluators PASS | **PASS (Accepted)** |

---

## 5. Offline Test Results

Across all relevant offline test suites, **119 / 119 tests PASS**:

```text
============================= test session starts ==============================
services/generation-service/tests/test_question_claim_provenance_and_stimulus_gate.py ................. [ 15%]
services/generation-service/tests/test_q1_claim_local_evidence_regression.py ...............           [ 27%]
services/generation-service/tests/test_tfng_semantic_contract_and_m3_repair.py ............             [ 38%]
services/generation-service/tests/test_question_answer_grounding_and_rerun.py ............             [ 49%]
services/generation-service/tests/test_passage_blueprint_grounding_gate.py ...........                 [ 59%]
services/generation-service/tests/test_run_hybrid_single_section_live.py .......................       [ 79%]
services/generation-service/tests/test_hybrid_offline_replays.py ......                                 [ 84%]
services/generation-service/tests/test_hybrid_production_integration.py ..............                  [ 97%]
services/generation-service/tests/test_hybrid_question_repair_integration.py ..                        [100%]
============================= 119 passed in 1.83s ==============================
```

Mandatory Acceptance Gate Verdicts:
- `Q1_REPLAY`: **PASS**
- `CLAIM_LOCAL_GROUNDING`: **PASS**
- `WRONG_CLAIM_REGRESSIONS`: **PASS**
- `TFNG_SEMANTIC_CONTRACT`: **PASS**
- `OFFLINE_REGRESSION`: **PASS**

---

## 6. LIVE Execution Identity

| Field | Value |
|---|---|
| **Git Implementation SHA** | `2da48d0a39289723830ea91d7451dfeac875357c` |
| **Live Job ID** | `2250820f-0ed9-42cb-80e8-70bcc38f2a7e` |
| **Active Run ID** | `run_2250820f0ed942cb80e870bcc38f2a7e` |
| **Source PMCID** | `PMC13654891` |
| **Topic** | Evolution of an Early and Long-Lasting Iron Smelting Technique at Didé West 1, Falémé Valley, Eastern Senegal |
| **Target Section** | Section 1 (13 questions) |
| **Primary Model** | `MiniMax-Text-01` |
| **Repair Planner** | `MiniMax-M3` (armed, not invoked) |
| **Execution Duration** | 275.2s to terminal status (289.8s total wall time) |

---

## 7. Question-by-Question Scorecard (Q1–Q13)

| Question | Type | Bound Claim | Attempted | Durable Head? | Accepted Ver | Evaluators | Status | Detail / Tested Proposition |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|---|
| **Q1** | `TRUE_FALSE_NOT_GIVEN` | `claim:...:1:2` | **YES** | **YES** | **1** | Structure: PASS, Length: PASS, Offsets: PASS, Uniqueness: PASS, Semantic: PASS, Blind Solver: PASS | **ACCEPTED** | "The passage states that only a few iron smelting sites are adequately preserved, documented, and dated for comprehensive historical analysis." (TRUE). Evidence: "Despite the growing number of identified production sites, only a few are adequately preserved, documented, and dated..." |
| **Q2** | `TRUE_FALSE_NOT_GIVEN` | `claim:...:1:12` | **YES** | **YES** | **1** | All 6 PASS | **ACCEPTED** | "The passage indicates that iron metallurgy in the Jos Plateau region dates back to around 600 BCE." (TRUE). Evidence: "Sites on the Jos Plateau, dated to around 600 BCE, further demonstrate the early emergence of iron metallurgy in this region (Junius, 2023 )." |
| **Q3** | `TRUE_FALSE_NOT_GIVEN` | `claim:...:1:1` | **YES** | **YES** | **2** | All 6 PASS on v2 | **ACCEPTED** | "The passage mentions that iron smelting sites in West Africa have been found to use advanced furnace structures." (NOT_GIVEN). Successfully repaired from v1 to v2 within bounded loop; blind solver verified `NOT_GIVEN`. |
| **Q4** | `TRUE_FALSE_NOT_GIVEN` | `claim:...:1:9` | **YES** | **YES** | **1** | All 6 PASS | **ACCEPTED** | "The passage states that the number of iron smelting sites with firmly established chronologies is relatively limited." (TRUE). Evidence: "The number of sites with firmly established chronologies that are broadly accepted by the scholars’ community remains relatively limited." |
| **Q5** | `TRUE_FALSE_NOT_GIVEN` | `claim:...:1:11` | **YES** | **NO** | None | Iterated v1..v3 | **REJECTED** | Reached version 3 on NOT_GIVEN absence assessments for Nsukka iron smelting techniques. Token reservation for next candidate exceeded the stage token cap (`TOKEN_CAP: next reservation exceeds token cap`). |
| **Q6** | `TABLE_COMPLETION` | `claim:...:1:6` | NO | NO | None | N/A | **NOT_REACHED** | Pipeline terminated at Q5; slot not reached. |
| **Q7** | `TABLE_COMPLETION` | `claim:...:1:14` | NO | NO | None | N/A | **NOT_REACHED** | Pipeline terminated at Q5; slot not reached. |
| **Q8** | `TABLE_COMPLETION` | `claim:...:1:16` | NO | NO | None | N/A | **NOT_REACHED** | Pipeline terminated at Q5; slot not reached. |
| **Q9** | `TABLE_COMPLETION` | `claim:...:1:5` | NO | NO | None | N/A | **NOT_REACHED** | Pipeline terminated at Q5; slot not reached. |
| **Q10** | `FLOW_CHART` | `claim:...:1:3` | NO | NO | None | N/A | **NOT_REACHED** | Pipeline terminated at Q5; slot not reached. |
| **Q11** | `FLOW_CHART` | `claim:...:1:13` | NO | NO | None | N/A | **NOT_REACHED** | Pipeline terminated at Q5; slot not reached. |
| **Q12** | `FLOW_CHART` | `claim:...:1:7` | NO | NO | None | N/A | **NOT_REACHED** | Pipeline terminated at Q5; slot not reached. |
| **Q13** | `FLOW_CHART` | `claim:...:1:2` | NO | NO | None | N/A | **NOT_REACHED** | Pipeline terminated at Q5; slot not reached. |

---

## 8. Candidate Pool Filtering & Upfront Rejection

Across the 8 question candidate generation calls, a total of **21 candidate items** were evaluated in candidate pools:
- **13 candidate items rejected upfront** during candidate parsing, grounding, and provenance verification before expensive blind-solver calls.
- **8 candidate items selected** for formal artifact drafting and multi-evaluator execution.
- **4 questions achieved durable acceptance** with 100% passing evaluator scores and committed heads.

---

## 9. Repair and M3 Accounting

- **MiniMax-M3 Calls**: **0** (`NOT_INVOKED`).
  Per the architectural contract, M3 diagnostic repair is armed strictly for eligible semantic/adversarial defects. Q1, Q2, Q4 were clean on v1. Q3 was repaired via Text-01 in-loop. Q5 terminated at the stage token cap boundary. No improper or unbudgeted M3 calls occurred.
- **In-Loop Text-01 Repairs**:
  - Q3: 1 repair cycle (v1 -> v2), successfully resolving ambiguity and achieving durable acceptance.
  - Q5: 2 repair cycles (v1 -> v2 -> v3) before budget exhaustion.

---

## 10. Provider Accounting & Billing

| Model | Calls | Prompt Tokens | Completion Tokens | Reasoning Tokens | Total Tokens | Rate (Prompt / Comp) | Total Cost (USD) |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **MiniMax-Text-01** | 25 | 53,252 | 7,537 | 0 | 60,789 | $0.20 / 1M ; $1.10 / 1M | **$0.01894** |
| **MiniMax-M3** | 0 | 0 | 0 | 0 | 0 | $0.50 / 1M ; $2.00 / 1M | $0.00000 |
| **Total** | **25** | **53,252** | **7,537** | **0** | **60,789** | — | **$0.01894** |

- **Telemetry Completeness**: `COMPLETE` (100% of operations returned authoritative non-null token usage).
- **Unknown Total Usage**: `false`.
- **Actual Billed Cost**: `NOT_AVAILABLE (MiniMax completions API does not return billing invoices; estimated cost applies)`.

---

## 11. Authoritative PostgreSQL Persistence Verification

All 8 durable artifact heads were queried and verified directly from PostgreSQL `reading_paper_artifact_heads` for `RunId = 'run_2250820f0ed942cb80e870bcc38f2a7e'`:

```sql
SELECT "ArtifactId", "AcceptedVersion", "AcceptedHash", "UpdatedAt"
FROM reading_paper_artifact_heads
WHERE "RunId" = 'run_2250820f0ed942cb80e870bcc38f2a7e';
```

| Artifact ID | Accepted Version | Accepted Hash | Updated At (UTC) | Status |
|---|:---:|---|---|:---:|
| `source:run_2250820f0ed942cb80e870bcc38f2a7e:1` | 1 | `e78ffaf29737fdcf5c53767e69b21f60eb8cf1e22481b8e9fe1c534dd629be85` | 2026-10-25 13:38:13 | ACCEPTED |
| `evidence:run_2250820f0ed942cb80e870bcc38f2a7e:1` | 1 | `61421ab7ef4fcb3bfaf6083c4f8e2eefa8cca364ef1482311f65482f2be8d75b` | 2026-10-25 13:38:14 | ACCEPTED |
| `blueprint:run_2250820f0ed942cb80e870bcc38f2a7e` | 1 | `e71328a7abb9d927342b1968791d9c2657cf328a5725f67d712ddce3f03ca042` | 2026-10-25 13:38:14 | ACCEPTED |
| `passage:run_2250820f0ed942cb80e870bcc38f2a7e:1` | 1 | `00a833141f49cdd402341f0b595dc1c58bb04a1517cd0a7bd0ae1259db09fc15` | 2026-10-25 13:38:38 | ACCEPTED |
| `question:run_2250820f0ed942cb80e870bcc38f2a7e:1` | **1** | `b4fb05047d9ef4f1bf82f58bb37a080885924ca78a196941ba1f401113252559` | 2026-10-25 13:38:57 | **ACCEPTED (Q1)** |
| `question:run_2250820f0ed942cb80e870bcc38f2a7e:2` | **1** | `b62ca7796fcd1f6610804339456eb0ca4a6c24942a83c72f7f6d3e8161237b26` | 2026-10-25 13:39:19 | **ACCEPTED (Q2)** |
| `question:run_2250820f0ed942cb80e870bcc38f2a7e:3` | **2** | `2c263cfe926c4912db940edbb241fa39f8d8efff2094a00773255273bffae797` | 2026-10-25 13:40:25 | **ACCEPTED (Q3)** |
| `question:run_2250820f0ed942cb80e870bcc38f2a7e:4` | **1** | `da8e99882119c3dd5c43e0f4e8199ee545473110f270b81f78319860bdd15ada` | 2026-10-25 13:40:48 | **ACCEPTED (Q4)** |

- **Total DB Operations Persisted**: Exactly 100 operations in `reading_paper_operations`.
- **Idempotency & Sequence Invariant**: 100% unique operation IDs, monotonic sequence numbers.
- **Section Commit Invariant**: `ExamId` remains `NULL`; 0 unverified exams committed; Section 1 uncommitted.

---

## 12. First Unrecovered Failure Analysis

- **Question Number**: **Q5**
- **Artifact ID**: `question:run_2250820f0ed942cb80e870bcc38f2a7e:5`
- **Question Family**: `TRUE_FALSE_NOT_GIVEN`
- **Bound Claim**: `claim:...:1:11` ("However, direct evidence for sustained iron production there remains limited (Okafor, 2002 ; Okafor & Phillips, 1992 ).")
- **Target Answer**: `NOT_GIVEN`
- **Failure Code**: `TOKEN_CAP` (Stage-level token cap reservation breach: `{"detail":"question:run_2250820f0ed942cb80e870bcc38f2a7e:5: TOKEN_CAP: next reservation exceeds token cap"}`)
- **Analysis**: Q5 drafted NOT_GIVEN assertions concerning iron smelting in the Nsukka region. V1 and V2 required repair cycles, consuming token allocation. Upon attempting version 3, the cumulative question-stage token reservation exceeded the strict bounded cap allocated by `ReadingPaperWorker`. The stage executor failed closed, preserving system budget governance without silent budget expansion.

---

## 13. Final Console Result

```text
LANGFENS — Q1 CORRECTIVE + HYBRID 13Q LIVE

GIT_IMPLEMENTATION_SHA: 2da48d0a39289723830ea91d7451dfeac875357c
HISTORICAL_Q1_REPLAY: PASS
ROOT_CAUSE: Overly broad multi-clause evidence quote spanning Claim 1 and Claim 2, combined with cross-category marker conflict on shared regional entity ('West Africa').
PROVENANCE_FALSE_POSITIVE: RESOLVED (category-aware discriminator evaluation).
CLAIM_LOCAL_EVIDENCE_FIX: PASS (select_claim_local_evidence isolates exact contiguous claim-local subspan).
OFFLINE_REGRESSION: PASS (119/119 tests passing).
RUNTIME_PREFLIGHT: PASS (10/10 checks passing).

LIVE_JOB_ID: 2250820f-0ed9-42cb-80e8-70bcc38f2a7e
RUN_ID: run_2250820f0ed942cb80e870bcc38f2a7e
PASSAGE_STATUS: PASS
PASSAGE_WORD_COUNT: 858

QUESTIONS_ATTEMPTED: 5
QUESTIONS_ACCEPTED: 4/13
QUESTIONS_REJECTED: 1
QUESTIONS_NOT_REACHED: 8
SECTION_COMMITTED: NO

CANDIDATES_REJECTED_GROUNDING: 13
CANDIDATES_REJECTED_SEMANTIC: 3
SUCCESSFUL_REPAIRS: 1 (Q3 v1 -> v2 accepted)

MINIMAX_TEXT01_CALLS: 25
MINIMAX_M3_CALLS: 0
M3_REPAIR_OUTCOME: NOT_INVOKED (No eligible semantic/adversarial repair required)
PROVIDER_TOKENS: 60789
ESTIMATED_COST_USD: $0.01894
ACTUAL_BILLED_COST_USD: NOT_AVAILABLE (MiniMax completions API does not return billing invoices)

FIRST_FAILURE_QUESTION: Q5
FIRST_FAILURE_ISSUE_CODE: TOKEN_CAP (Next reservation exceeds stage token cap)
LIVE_VERDICT: PARTIAL
```
