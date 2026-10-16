# Human Review Panel Scoring Packet (RG10 Independent Acceptance)

**Protocol Specification:** `generation_baseline/research/HUMAN_REVIEW_PROTOCOL_AND_RUBRIC.md`  
**Status:** `AWAITING_HUMAN_PANEL` (Zero synthetic or simulated human scores)  
**Governance Invariant:** Research ready gate requires actual qualified human expert review. Under Langfens repository rules, no automated evaluator or secondary LLM may fabricate human review data.

---

## 1. Instructions to Expert Reviewers

1. **Independent Blind Scoring:** Evaluate each anonymized item independently across the 4 rubric dimensions (1 to 5 scale).
2. **Key Determination:** Determine the single defensible answer independently without consulting any suggested answer key.
3. **Acceptability:** Assign a binary acceptability decision (`PASS` vs `FAIL`) based on whether the question meets IELTS Academic publishing standards.

---

## 2. Evaluation Form Matrix

| Task ID | Domain | Target Focus | Question Prompt Preview | Annotator 1 (Key / Pass) | Annotator 2 (Key / Pass) | Adjudication Status |
|---|---|---|---|---|---|---|
| `task_hrev_9b814a012c41` | Reading | Factual Entailment | Submarine volcanism accounts for about seventy percent... | `[UNPOPULATED]` | `[UNPOPULATED]` | `AWAITING_PANEL` |
| `task_hrev_1847c0b29d11` | Reading | Factual Contradiction | Pyroclastic fragmentation occurs in deep benthic... | `[UNPOPULATED]` | `[UNPOPULATED]` | `AWAITING_PANEL` |
| `task_hrev_47a02c84e1b3` | Grammar | Negative Inversion | Which of the following sentences correctly uses subject-auxiliary... | `[UNPOPULATED]` | `[UNPOPULATED]` | `AWAITING_PANEL` |
| `task_hrev_82d901f4c391` | Grammar | Mandative Subjunctive | Which of the following sentences correctly uses the mandative... | `[UNPOPULATED]` | `[UNPOPULATED]` | `AWAITING_PANEL` |

---

## 3. Epistemic Certification

- **Fabrication Disclosure:** The fields above are explicitly unpopulated. No mock, synthetic, or agent-simulated human review data has been entered.
- **Prerequisite for RESEARCH_READY:** Unsealing holdout data and executing the confirmatory human evaluation panel can only occur once external provider quotas are restored and human experts are contracted.
