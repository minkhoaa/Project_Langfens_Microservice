# Source Provenance & Licensing Checklist

**Phase:** RG10 Confirmatory Research Freeze  
**Document:** Source Provenance and Academic Licensing Verification  
**Target:** Independent External Curation Panel & Repository Auditor  

---

## 1. Overview and Legal Principles

All texts and items included in the confirmatory research corpus must possess verifiable source provenance and lawful copyright status. Synthetic generation and undocumented internet scraping are strictly forbidden.

Each holdout item must trace to an identifiable human author, scholarly publication, or open-access repository.

---

## 2. Quarantined Source Family Verification Matrix

The curation panel must confirm that all source documents belong exclusively to the reserved source families below and have had zero exposure to development or calibration pipelines.

| Domain | Reserved Family ID | Topic / Disciplinary Scope | Acceptable Source Types | Verification Sign-off |
|---|---|---|---|---|
| **Reading** | `fam-astrophysics-pulsar-08` | Millisecond Pulsar Magnetospheres, Relativistic Plasma, Polar Cap Acceleration | Peer-reviewed astrophysics journals (ApJ, MNRAS, Astronomy & Astrophysics), academic monographs | `[PENDING]` |
| **Reading** | `fam-paleontology-cambrian-09` | Burgess Shale Arthropod Radiation, Soft-Tissue Taphonomy, Metazoan Phylogeny | Peer-reviewed paleobiology journals (Paleobiology, Nature/Science historical archives), museum monographs | `[PENDING]` |
| **Grammar** | `fam-mood-subjunctive-08` | Mandative Subjunctive in Legal/Formal Registers | Scholarly descriptive English grammars, formal legislative or statutory corpora, university charters | `[PENDING]` |
| **Grammar** | `fam-aspect-participle-09` | Reduced Participle Clauses and Adverbial Qualification | Published academic writing style manuals, linguistic research corpora, peer-reviewed linguistic papers | `[PENDING]` |

---

## 3. Licensing and Copyright Compliance Checklist

Curators must verify that each source document satisfies at least one of the approved licensing categories:

- [ ] **Category A — Open Access / Creative Commons:**
  - Source is licensed under Creative Commons (CC-BY, CC-BY-SA, or CC0).
  - Explicit license URL and attribution string are recorded.
- [ ] **Category B — Public Domain:**
  - Source was published prior to applicable copyright terms or by a government entity exempt from copyright (e.g. US Government publications).
- [ ] **Category C — Academic Research Fair Use / Scholarly Quotation:**
  - Excerpt length is strictly limited to 720–915 words.
  - Used solely for non-commercial scientific research evaluation and reproducibility verification.
  - Complete bibliographic citation (Author, Title, Publisher, Year, DOI/ISBN) is documented.
- [ ] **Commercial Rights Restriction Check:**
  - Confirm source does not contain explicit prohibitions against scholarly research text mining or fair-use benchmarking.

---

## 4. Academic Citation and Metadata Verification

For each source text, the curator must record the following mandatory metadata fields:

```yaml
source_provenance_record:
  source_id: "[CURATOR: SUPPLY UNIQUE SOURCE IDENTIFIER, e.g. src-astrophysics-pulsar-01]"
  source_family_id: "[CURATOR: MUST BE EXACTLY ONE OF RESERVED QUARANTINED FAMILY IDS]"
  work_title: "[CURATOR: SUPPLY EXACT SCHOLARLY PUBLICATION / MONOGRAPH TITLE]"
  authors:
    - "[CURATOR: REAL HUMAN SCHOLARLY AUTHOR 1]"
    - "[CURATOR: REAL HUMAN SCHOLARLY AUTHOR 2 (IF APPLICABLE)]"
  publication_type: "[CURATOR: 'Journal Article' | 'Book Chapter' | 'Monograph']"
  journal_or_publisher: "[CURATOR: REAL ACADEMIC JOURNAL OR UNIVERSITY PRESS]"
  volume_issue_pages: "[CURATOR: CITATION VOLUME/ISSUE/PAGE RANGE]"
  publication_year: "[CURATOR: INTEGER PUBLICATION YEAR]"
  doi: "[CURATOR: OFFICIAL DOI RESOLVER STRING, e.g. 10.xxxx/...]"
  verified_license: "[CURATOR: VERIFIED LICENSE, e.g. 'CC-BY-4.0' | 'Public Domain' | 'Academic Fair Use']"
  original_word_count_extracted: "[CURATOR: INTEGER COUNT BETWEEN 720 AND 915]"
  human_curator_signoff: "[CURATOR: PANEL CURATOR IDENTIFIER]"

---

## 5. Non-Synthetic Attestation

Every member of the independent curation panel must review and execute this attestation before dataset sealing:

> *"I hereby certify that all source texts, questions, options, and keys submitted under this holdout package are derived from human-authored publications and independent human expert composition. No large language model, automated text generation system, or synthetic data synthesis pipeline was utilized to produce or edit any portion of this corpus."*

- **Panel Lead Name:** `[PENDING_INDEPENDENT_ONBOARDING]`
- **Affiliation / Institution:** `[PENDING_INDEPENDENT_ONBOARDING]`
- **Date Signed:** `[PENDING_INDEPENDENT_ONBOARDING]`
- **Signature / PGP Fingerprint:** `[PENDING_INDEPENDENT_ONBOARDING]`
