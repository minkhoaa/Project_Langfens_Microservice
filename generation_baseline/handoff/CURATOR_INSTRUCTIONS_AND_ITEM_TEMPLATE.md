# Independent Human Curator Instructions & Item Templates

**Document Version:** 1.0  
**Phase:** RG10 Confirmatory Research Freeze  
**Governing Documents:** `generation_baseline/research/CONFIRMATORY_HOLDOUT_SPECIFICATION.md` & `DATA_GOVERNANCE.md`  
**Target:** Independent Human Curation Panel  

---

## 1. Objective and Independence Mandate

The confirmatory research phase of the Langfens generation system requires an uninspected, independently curated Judge Holdout corpus of exactly **$N = 30$ evaluation items** (18 Reading items, 12 Grammar MCQs).

### Inviolable Independence Rules
1. **Zero LLM / Synthetic Data Generation:** All texts, passages, stems, distractors, and keys must be curated and written exclusively by human domain experts. Under no circumstances may AI generation tools (ChatGPT, Claude, Gemini, local models, etc.) be used to draft or edit holdout items.
2. **Zero Developer Inspection:** System developers and prompt engineers must have no access to the holdout items prior to research unsealing.
3. **Dedicated Post-Freeze Purpose:** The 30-item Judge Holdout is intended solely for post-freeze evaluator reliability assessment (measuring False Rejection Rate [FRR], False Acceptance Rate [FAR], and abstention rate). It is strictly forbidden to use holdout items for prompt tuning, evaluator threshold adjustment, or parameter calibration.
4. **Separation from RQ2 Final Evaluation:** This 30-item Judge Holdout is strictly separate from the 150–240 assignment experimental corpus used for RQ2 hypothesis testing (`FINAL_EVAL`).

---

## 2. Reading Item Curation Guidelines ($n = 18$)

### 2.1 Source Families and Passages
Passages must be selected from human-authored, peer-reviewed monographs, textbooks, or open-access scientific publications within the following quarantined source families:
- **`fam-astrophysics-pulsar-08`** (9 items): Millisecond Pulsar Magnetospheres, Relativistic Plasma, and High-Energy Emission.
- **`fam-paleontology-cambrian-09`** (9 items): Burgess Shale Arthropod Radiation, Soft-Tissue Taphonomy, and Early Metazoan Evolution.

### 2.2 Passage Specifications
- **Passage Length:** 720 to 915 words per passage.
- **Academic Register:** Formal academic prose matching IELTS Academic Reading Section 2/3 difficulty.
- **Source Citation:** Complete bibliographic citation, including title, author(s), publisher/journal, year, and stable DOI/URL.

### 2.3 Question Distribution ($n = 18$)
Each source family contributes exactly 9 True/False/Not Given (TFNG) items:
- **Strict Factual Entailment (`TRUE`):** 3 items per family ($3 \times 2 = 6$ total). The statement must be directly and unequivocally supported by explicit text in the passage.
- **Explicit Factual Contradiction (`FALSE`):** 3 items per family ($3 \times 2 = 6$ total). The statement must assert a proposition directly contradicted by explicit text in the passage (e.g. inverted causal direction, conflicting numerical value, mutually exclusive classification).
- **Unmentioned Topical Assertion (`NOT GIVEN`):** 3 items per family ($3 \times 2 = 6$ total). The statement mentions topic-relevant concepts but asserts a relationship, outcome, or fact neither confirmed nor contradicted anywhere in the passage.

### 2.4 Evidence Spans
For all `TRUE` and `FALSE` items, curators must record the exact verbatim passage sentence or clause providing the factual foundation in the `evidence_span` field.

---

## 3. Grammar MCQ Curation Guidelines ($n = 12$)

### 3.1 Target Structures
Items must target formal academic English syntax within the following quarantined source families:
- **`fam-mood-subjunctive-08`** (6 items): Mandative Subjunctive in formal, legal, and academic institutional registers (e.g., *It is imperative that the committee convene...*, *The regulation requires that each institution submit...*).
- **`fam-aspect-participle-09`** (6 items): Reduced Participle Clauses and Adverbial Qualification (e.g., *Having synthesized the compound, the researchers observed...*, *Seen from this perspective, the outcome suggests...*).

### 3.2 Question Requirements
- **Format:** 4-option Multiple Choice Question (A, B, C, D).
- **Single Defensible Key:** Exactly ONE option must be grammatically standard and fully defensible under descriptive and prescriptive academic English grammars (e.g., Quirk et al., Huddleston & Pullum).
- **Three Syntactically Flawed Distractors:** Each distractor must be naturalistic yet contain an unambiguous, documented syntactic flaw.
- **Documented Error Codes:** Each distractor must have a documented error code (e.g., `INFLECTION_3RD_S`, `MODAL_TENSE_DISCORD`, `DANGLING_PARTICIPLE`, `COMPLEMENTIZER_OMISSION`).

---

## 4. JSON Submission Item Templates

Curators must provide submissions in valid UTF-8, NFKC-normalized JSON adhering to the following templates.

### 4.1 Reading Corpus Item Template (`reading_corpus.json`)

```json
[
  {
    "item_id": "[CURATOR: SUPPLY ITEM ID, e.g. holdout-reading-pulsar-01]",
    "source_family_id": "[CURATOR: MUST BE EXACTLY fam-astrophysics-pulsar-08 OR fam-paleontology-cambrian-09]",
    "domain": "READING",
    "question_type": "TFNG",
    "passage_id": "[CURATOR: SUPPLY PASSAGE IDENTIFIER]",
    "passage_title": "[CURATOR: SUPPLY PASSAGE TITLE]",
    "passage_word_count": "[CURATOR: INTEGER 720-915]",
    "passage_text": "[CURATOR: SUPPLY VERIFIED PASSAGE TEXT (720-915 WORDS) EXTRACTED FROM HUMAN SCHOLARLY SOURCE]",
    "statement": "[CURATOR: SUPPLY FACTUAL ASSERTION STATEMENT]",
    "ground_truth_label": "[CURATOR: MUST BE ONE OF 'TRUE', 'FALSE', 'NOT GIVEN']",
    "evidence_span": "[CURATOR: VERBATIM PASSAGE CITATION SPAN SUPPORTING TRUE/FALSE; NULL IF NOT GIVEN]",
    "curator_notes": "[CURATOR: QUALITATIVE JUSTIFICATION OF ENTAILMENT / CONTRADICTION / UNMENTIONED STATUS]",
    "provenance": {
      "source_title": "[CURATOR: SUPPLY FULL WORK TITLE]",
      "author": "[CURATOR: SUPPLY REAL SCHOLARLY AUTHOR(S)]",
      "publisher": "[CURATOR: SUPPLY ACADEMIC PUBLISHER / JOURNAL]",
      "year": "[CURATOR: SUPPLY INTEGER PUBLICATION YEAR]",
      "doi_or_url": "[CURATOR: SUPPLY VALID DOI OR STABLE URL]",
      "license": "[CURATOR: SUPPLY VERIFIED OPEN ACCESS / FAIR USE CATEGORY]"
    }
  }
]
```

### 4.2 Grammar Rule Pack and Item Template (`grammar_rule_packs.json`)

```json
[
  {
    "item_id": "[CURATOR: SUPPLY ITEM ID, e.g. holdout-grammar-subjunctive-01]",
    "source_family_id": "[CURATOR: MUST BE EXACTLY fam-mood-subjunctive-08 OR fam-aspect-participle-09]",
    "domain": "GRAMMAR",
    "question_type": "GRAMMAR_MCQ",
    "topic": "[CURATOR: TARGET SYNTACTIC STRUCTURE DESCRIPTION]",
    "stem": "[CURATOR: SUPPLY QUESTION PROMPT STEM]",
    "options": [
      "A) [CURATOR: OPTION A TEXT]",
      "B) [CURATOR: OPTION B TEXT]",
      "C) [CURATOR: OPTION C TEXT]",
      "D) [CURATOR: OPTION D TEXT]"
    ],
    "ground_truth_key": "[CURATOR: MUST BE EXACTLY ONE OF 'A', 'B', 'C', 'D']",
    "distractor_flaws": {
      "[CURATOR: FIRST DISTRACTOR OPTION LETTER]": {
        "error_code": "[CURATOR: SYNTACTIC DEFECT CODE, e.g. INFLECTION_3RD_S]",
        "explanation": "[CURATOR: GRAMMATICAL EXPLANATION OF SYNTACTIC FLAW]"
      },
      "[CURATOR: SECOND DISTRACTOR OPTION LETTER]": {
        "error_code": "[CURATOR: SYNTACTIC DEFECT CODE]",
        "explanation": "[CURATOR: GRAMMATICAL EXPLANATION OF SYNTACTIC FLAW]"
      },
      "[CURATOR: THIRD DISTRACTOR OPTION LETTER]": {
        "error_code": "[CURATOR: SYNTACTIC DEFECT CODE]",
        "explanation": "[CURATOR: GRAMMATICAL EXPLANATION OF SYNTACTIC FLAW]"
      }
    },
    "provenance": {
      "reference_grammar": "[CURATOR: CITATION TO AUTHORITATIVE DESCRIPTIVE GRAMMAR]",
      "chapter_section": "[CURATOR: CHAPTER AND SECTION CITATION]",
      "curator_attestation": "[CURATOR: ATTESTATION OF SINGLE DEFENSIBLE KEY]"
    }
  }
]
```

---

## 5. Submission and Sealing Checklist

Before submitting the curated dataset to the repository lead:
- [ ] Exactly 18 Reading items and 12 Grammar items are provided.
- [ ] No items were generated, translated, or modified using LLM systems.
- [ ] Passages belong strictly to `fam-astrophysics-pulsar-08` and `fam-paleontology-cambrian-09`.
- [ ] Grammar items belong strictly to `fam-mood-subjunctive-08` and `fam-aspect-participle-09`.
- [ ] Reading passages contain between 720 and 915 words.
- [ ] Reading labels are balanced: 6 TRUE, 6 FALSE, 6 NOT GIVEN.
- [ ] Evidence spans are documented for all TRUE and FALSE items.
- [ ] Each Grammar MCQ has exactly 1 defensible key and 3 syntactically flawed distractors with error codes.
- [ ] Disjointness and leakage scripts (`check_corpus_disjointness.py`) execute with zero errors.
