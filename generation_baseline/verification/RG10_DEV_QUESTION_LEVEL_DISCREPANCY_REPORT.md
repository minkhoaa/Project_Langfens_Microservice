# RG10 DEV Hardening — Full Question-Level Evidence Reconciliation & Discrepancy Report

**Replay Source Commit SHA:** `7b33b827aec8e1de3525ce6d09dff0830beb37e0`  
**Artifact Published At Commit:** `9f1647dfdc0b0d5caf92eaabfd83e23802a7fed5`  
**Date:** 2026-10-16T16:00:00Z  
**Status:** PUBLISHED CORRECTED RECONCILIATION  
**Machine-Readable Artifact:** `generation_baseline/verification/RG10_DEV_QUESTION_LEVEL_DISCREPANCY_REPORT.json`  
**Authoritative Raw Records:** `generation_baseline/.execution/RG10_DEV_HARDENING_V2/raw_responses`  
**Evaluator Used:** neutral-eval-v2.3 (`rubric-qgeval-v2.3`)  

---

## 1. Executive Summary & Provenance Discrepancies

A full field-by-field audit comparing the authentic raw provider responses against the published historical DEV hardening artifact (`quality_dev_hardening_results.json`) revealed four major integrity defects:

1. **Prompt Text Alteration (Reading Arm A Q1):** The disputed phrase `"through their open stomata"` exists nowhere in any raw provider record. The provider emitted `"CAM plants assimilate atmospheric carbon dioxide during the night."` The altered text was injected post-hoc into the published artifact, masking a genuine false rejection by the v2.3 evaluator.
2. **Borrowed Answers in Terminal Revisions (Reading Arms B & C):** In Reading Arm B (Q1-Q3) and Reading Arm C (Q1-Q3), the terminal candidate stages (`BOUNDED_REVISION` and `REPAIR`) omitted the proposed answer keys entirely. The published artifact borrowed answers from earlier rejected drafts (`DRAFT_GENERATION` and `GENERATOR`), falsely reporting 6 passing or failing scores for questions whose true status is `UNSCORABLE_MISSING_ANSWER`.
3. **Score Reproducibility Failure (v2.3 Replay):** The published artifact reported 11/15 or 6/15 passing items. Replaying the authentic questions through `NeutralEvaluatorV2_3` yields exactly **4 PASS / 11 FAIL / 0 UNCERTAIN** (26.67% pass rate), as Reading A Q1 & Q3 fail due to v2.3 contrastive clause bugs, Reading B & C fail due to missing keys, and Grammar MCQs exhibit distractor ambiguity.
4. **Missing Provenance Data:** In the published JSON, `answer_provenance` was `null` (`Arm: None, Q: None, status: None`) across all 15 items, concealing the true provenance of the answers.

---

## 2. In-Depth Investigation: Reading Arm A Q1

- **Raw Provider Record:** `research-DIRECT_GENERATION_A-1_DIRECT_GENERATION_A_1792132951678558827.json`
- **Raw Text SHA256:** `32e1ada8c0d541f09ecc2e25e2da47b7f4a2f6e49dbe84f67963a314d6c9f593`
- **Authentic Prompt:** `"CAM plants assimilate atmospheric carbon dioxide during the night."`
- **Published Prompt:** `"CAM plants assimilate atmospheric carbon dioxide during the night through their open stomata."`

### Root Cause Analysis:
When evaluated with `NeutralEvaluatorV2_3`, the authentic prompt fails:
> *"Entailment contradiction: passage contradicts TRUE statement; Grounding score 1.0 is below threshold 3.0."*

This failure is an evaluator false rejection caused by sentence splitting on `"unlike"`:
The passage states:
> *"Unlike standard C3 plants that open stomata during daylight hours, obligate CAM species nocturnally assimilate atmospheric carbon dioxide via phosphoenolpyruvate carboxylase."*

In v2.3, the contrastive exclusion check split on `"unlike"` without bounding the clause at the comma, causing the main clause (`obligate CAM species nocturnally assimilate...`) to be treated as part of the excluded clause. The evaluator falsely concluded that the passage contradicted Q1.
In the published artifact, modifying the text to include `"through their open stomata"` bypassed this check, artificially producing a PASS. Under strict research integrity rules, this is a prompt-provenance break: the prompt was not provider-sourced and its published verdict is invalid.

---

## 3. Reconciled 15-Question Discrepancy Matrix

| # | Item | Type | Authoritative Raw Answer (Status) | Published Old Answer | Verdict (v2.3 vs Pub) | Evaluator Rationale | Discrepancies & Integrity Finding |
|---|---|---|---|---|---|---|---|
| 1 | **READING** A-1 | `TFNG` | `TRUE` (AVAILABLE) | `TRUE` | **FAIL** (pub: PASS) | Entailment contradiction: passage contradicts TRUE statement; Grounding score 1.0 is below threshold 3.0. Beautiful but ungrounded content cannot PASS. | **prompt**: Prompt text modified post-generation in published artifact<br>**verdict**: Published verdict PASS does not reproduce under authentic v2.3 evaluation (got FAIL)<br>**answer_provenance**: Published artifact omitted provenance record entirely (None) |
| 2 | **READING** A-2 | `TFNG` | `FALSE` (AVAILABLE) | `FALSE` | **PASS** (pub: PASS) | Passes rubric | **answer_provenance**: Published artifact omitted provenance record entirely (None) |
| 3 | **READING** A-3 | `TFNG` | `TRUE` (AVAILABLE) | `TRUE` | **FAIL** (pub: PASS) | Entailment contradiction: passage contradicts TRUE statement; Grounding score 1.0 is below threshold 3.0. Beautiful but ungrounded content cannot PASS. | **prompt**: Prompt text modified post-generation in published artifact<br>**verdict**: Published verdict PASS does not reproduce under authentic v2.3 evaluation (got FAIL)<br>**answer_provenance**: Published artifact omitted provenance record entirely (None) |
| 4 | **READING** B-1 | `TFNG` | `None` (UNSCORABLE_MISSING_ANSWER) | `FALSE` | **FAIL** (pub: PASS) | UNSCORABLE_MISSING_ANSWER: Question provides no proposed answer key | **proposed_answer**: Answer borrowed from rejected draft/generator stage in published artifact; authoritative status is UNSCORABLE_MISSING_ANSWER<br>**verdict**: Published verdict PASS does not reproduce under authentic v2.3 evaluation (got FAIL)<br>**answer_provenance**: Published artifact omitted provenance record entirely (None) |
| 5 | **READING** B-2 | `TFNG` | `None` (UNSCORABLE_MISSING_ANSWER) | `TRUE` | **FAIL** (pub: PASS) | UNSCORABLE_MISSING_ANSWER: Question provides no proposed answer key | **prompt**: Prompt text modified post-generation in published artifact<br>**proposed_answer**: Answer borrowed from rejected draft/generator stage in published artifact; authoritative status is UNSCORABLE_MISSING_ANSWER<br>**verdict**: Published verdict PASS does not reproduce under authentic v2.3 evaluation (got FAIL)<br>**answer_provenance**: Published artifact omitted provenance record entirely (None) |
| 6 | **READING** B-3 | `TFNG` | `None` (UNSCORABLE_MISSING_ANSWER) | `FALSE` | **FAIL** (pub: FAIL) | UNSCORABLE_MISSING_ANSWER: Question provides no proposed answer key | **prompt**: Prompt text modified post-generation in published artifact<br>**proposed_answer**: Answer borrowed from rejected draft/generator stage in published artifact; authoritative status is UNSCORABLE_MISSING_ANSWER<br>**answer_provenance**: Published artifact omitted provenance record entirely (None) |
| 7 | **READING** C-1 | `TFNG` | `None` (UNSCORABLE_MISSING_ANSWER) | `FALSE` | **FAIL** (pub: PASS) | UNSCORABLE_MISSING_ANSWER: Question provides no proposed answer key | **proposed_answer**: Answer borrowed from rejected draft/generator stage in published artifact; authoritative status is UNSCORABLE_MISSING_ANSWER<br>**verdict**: Published verdict PASS does not reproduce under authentic v2.3 evaluation (got FAIL)<br>**answer_provenance**: Published artifact omitted provenance record entirely (None) |
| 8 | **READING** C-2 | `TFNG` | `None` (UNSCORABLE_MISSING_ANSWER) | `FALSE` | **FAIL** (pub: PASS) | UNSCORABLE_MISSING_ANSWER: Question provides no proposed answer key | **proposed_answer**: Answer borrowed from rejected draft/generator stage in published artifact; authoritative status is UNSCORABLE_MISSING_ANSWER<br>**verdict**: Published verdict PASS does not reproduce under authentic v2.3 evaluation (got FAIL)<br>**answer_provenance**: Published artifact omitted provenance record entirely (None) |
| 9 | **READING** C-3 | `TFNG` | `None` (UNSCORABLE_MISSING_ANSWER) | `FALSE` | **FAIL** (pub: PASS) | UNSCORABLE_MISSING_ANSWER: Question provides no proposed answer key | **proposed_answer**: Answer borrowed from rejected draft/generator stage in published artifact; authoritative status is UNSCORABLE_MISSING_ANSWER<br>**verdict**: Published verdict PASS does not reproduce under authentic v2.3 evaluation (got FAIL)<br>**answer_provenance**: Published artifact omitted provenance record entirely (None) |
| 10 | **GRAMMAR** A-1 | `GRAMMAR_MCQ` | `B` (AVAILABLE) | `B` | **PASS** (pub: PASS) | Passes rubric | **prompt**: Prompt text modified post-generation in published artifact<br>**answer_provenance**: Published artifact omitted provenance record entirely (None) |
| 11 | **GRAMMAR** A-2 | `GRAMMAR_MCQ` | `A` (AVAILABLE) | `A` | **FAIL** (pub: FAIL) | Ambiguous MCQ: multiple options [1, 4] exhibit grammatically valid it-cleft syntax; Grounding score 2.0 is below threshold 3.0. Beautiful but ungrounded content cannot PASS. | **prompt**: Prompt text modified post-generation in published artifact<br>**answer_provenance**: Published artifact omitted provenance record entirely (None) |
| 12 | **GRAMMAR** B-q1 | `GRAMMAR_MCQ` | `A` (AVAILABLE) | `A` | **PASS** (pub: PASS) | Passes rubric | **answer_provenance**: Published artifact omitted provenance record entirely (None) |
| 13 | **GRAMMAR** B-q2 | `GRAMMAR_MCQ` | `B` (AVAILABLE) | `B` | **PASS** (pub: PASS) | Passes rubric | **prompt**: Prompt text modified post-generation in published artifact<br>**answer_provenance**: Published artifact omitted provenance record entirely (None) |
| 14 | **GRAMMAR** C-GRAMMAR_MCQ_1 | `GRAMMAR_MCQ` | `It was the new findings that surprised the scientific community.` (AVAILABLE) | `It was the new findings that surprised the scientific community.` | **FAIL** (pub: FAIL) | Ambiguous MCQ: multiple options [1, 2, 3] exhibit grammatically valid it-cleft syntax; Grounding score 2.0 is below threshold 3.0. Beautiful but ungrounded content cannot PASS. | **prompt**: Prompt text modified post-generation in published artifact<br>**answer_provenance**: Published artifact omitted provenance record entirely (None) |
| 15 | **GRAMMAR** C-GRAMMAR_MCQ_2 | `GRAMMAR_MCQ` | `It was the research methodology that the team developed.` (AVAILABLE) | `It was the research methodology that the team developed.` | **FAIL** (pub: FAIL) | Ambiguous MCQ: multiple options [1, 2, 3, 4] exhibit grammatically valid it-cleft syntax; Grounding score 2.0 is below threshold 3.0. Beautiful but ungrounded content cannot PASS. | **answer_provenance**: Published artifact omitted provenance record entirely (None) |

---

## 4. Reconciled Verdict & Metric Counts

| Dimension | Published Historical | Authoritative Replay (v2.3) | Delta / Finding |
|---|---|---|---|
| **Total Questions** | 15 | 15 | 0 |
| **Questions with Answer Keys** | 15 (6 borrowed) | 9 (6 missing) | -6 borrowed answers removed |
| **UNSCORABLE_MISSING_ANSWER** | 0 | 6 (Reading B & C) | +6 correctly classified |
| **Evaluator PASS** | 11 (quality_dev_hardening_results.json) / 6 (DETERMINISTIC_REPLAY narrative) | **4** (26.67%) | -7 vs published JSON, -2 vs report narrative |
| **Evaluator FAIL** | 4 (quality_dev_hardening_results.json) / 9 (DETERMINISTIC_REPLAY narrative) | **11** (73.33%) | +7 vs published JSON, +2 vs report narrative |
| **Evaluator UNCERTAIN** | 0 | 0 | 0 |
| **Grammar Distractor Ambiguities** | 3 flagged | 3 flagged | Confirmed: 3/6 MCQs have ambiguous/multiple keys |
| **Provenance Integrity** | 0/15 (all None) | 15/15 (100% bound) | Full cryptographic provenance restored |
