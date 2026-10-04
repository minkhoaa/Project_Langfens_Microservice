# ADR-003: Artifact Dependency DAG and Invalidation Semantics

**Status:** Accepted  
**Date:** 2026-09-30  
**Phase:** Phase 01  
**Deciders:** Langfens Engineering Team  

---

## 1. Context

Generating an IELTS Academic Reading Paper is a multi-stage compilation pipeline where downstream stages depend on outputs from upstream stages. For example:
- Question creation depends on the generated Passage and Evidence Claims.
- Passage drafting depends on the EvidenceGraph and Blueprint.
- Evidence extraction depends on the ingested SourcePack.

When an evaluator detects a critical defect (e.g. passage word count violation or factual contradiction), the engine triggers repair or regeneration. Without explicit dependency tracking, a system risks reusing questions that were generated against an older, discarded passage version, leading to phantom answers, evidence mismatches, and severe hallucinations.

## 2. Decision

We define a strict directed acyclic graph (DAG) of immutable artifacts with cryptographic parent lineage:

### 2.1 The Canonical Dependency Hierarchy
```
SourcePack (v1)
    │
    ▼
EvidenceGraph (v1)
    │
    ▼
ExamBlueprint (v1)
    │
    ▼
Passage (v1)
    │
    ├──► QuestionGroup / Questions (v1)
    │        │
    ▼        ▼
Section (v1)
    │
    ▼
ReadingPaper (v1)
```

### 2.2 Exact Parent References
Every `ArtifactEnvelope` includes a list of exact `parentRefs`:
```json
{
  "artifactId": "art_passage_01",
  "artifactType": "Passage",
  "version": 2,
  "contentHash": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
  "parentRefs": [
    {
      "artifactId": "art_evidence_01",
      "artifactType": "EvidenceGraph",
      "version": 1,
      "contentHash": "4a7d1ed414474e4033ac29ccb8653d9b0021c172a5a17688172944b0f9c2d13b"
    }
  ]
}
```

### 2.3 Strict Invalidation Cascade Rules
1. **Immutability:** An artifact version `(artifactId, version, contentHash)` is permanently immutable. Changing any single character in the payload produces a new version `version + 1` with a new `contentHash`.
2. **Downward Invalidation:** If an upstream artifact $A$ changes from $v_1$ to $v_2$, any downstream artifact $B$ that references $A(v_1)$ is immediately marked as **STALE / INVALID**.
3. **No Promotion of Stale Dependencies:** The final exam assembler in `exam-service` strictly enforces that every Question and Group in a Section references the exact `(PassageId, Version, Hash)` that is included in the Section. Reusing questions across different passage versions is rejected at validation time.
4. **Deterministic Cache Reuse:** If an upstream artifact has not changed (exact hash match), cached downstream evaluations and intermediate artifacts may be safely reused.

## 3. Consequences

### Positive:
- **Zero Evidence Mismatches:** Impossible for a question to ask about an entity that existed in passage $v_1$ but was deleted in passage $v_2$.
- **Full Traceability:** Every question in an exam can be audited back through the passage, evidence claim, and scientific paper PMCID.
- **Clear Repair Scoping:** When a single question has a bad distractor, only that question group needs repair, without re-running the entire passage generator.

### Negative / Trade-offs:
- Regenerating a passage necessitates regenerating or re-evaluating all question groups for that section.
- Graph lineage metadata must be stored alongside artifacts.
