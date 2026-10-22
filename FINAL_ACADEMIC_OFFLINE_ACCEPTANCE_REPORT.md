# FINAL ACADEMIC OFFLINE ACCEPTANCE REPORT

**Platform:** Langfens IELTS Preparation Platform (Autonomous Reading Paper Generation)  
**Role:** Lead Backend Reliability, Academic Quality & Integration Engineer  
**Branch:** `autonomous-generation`  
**Starting SHA:** `bb5dc347445717061ffe4cc25f6865074312e799`  
**Evaluation Mode:** TARGETED CORRECTIVE IMPLEMENTATION + FINAL ACCEPTANCE VERIFICATION  
**Offline Policy:** STRICT OFFLINE_HARDENING (Zero live provider calls, zero live generation jobs mutated, zero baseline modifications)

---

## 1. Audited Starting SHA & Final Worktree

- **Initial Commit SHA:** `bb5dc347445717061ffe4cc25f6865074312e799`
- **Worktree Base Branch:** `autonomous-generation`
- **PostgreSQL Test Infrastructure:** Port 5433, container `exam-db-port5433` (PostgreSQL 17.6, database `exam-db`, user `exam`). Verified disposable test container with isolated connection assertions.
- **Production Provider Calls:** **ZERO** (No MiniMax LIVE, no Groq, no Ollama inference).
- **Real Generation Jobs Mutated:** **ZERO**
- **Baseline Directory Modifications:** **ZERO** (`generation_baseline/` unmodified).

---

## 2. Confirmed Corrections & Modified Files

### Core Production Logic & Services Modified

| Component | Path | Exact Correction Applied |
|---|---|---|
| **Semantic Claim Binding** | `services/generation-service/app/blueprint/claim_binding.py` | Added explicit `check_claim_eligibility_for_family()`, separated eligibility filtering from heuristic ranking. Implemented fail-closed rejection for empty/ineligible candidates. Prohibited cross-section claims and synthetic claim prefixes (`claim:synthetic:`, `claim:placeholder:`, `claim:None:`). Fixed metal homograph "lead" in `PROCESS_KEYWORDS`. |
| **Blueprint Validation** | `services/generation-service/app/blueprint/validators.py` | Enhanced `validate_blueprint` to enforce claim membership verification against `evidence_map` on both `dict` and `Mapping` payloads. Prevented fabricated claim prefixes while allowing genuine run IDs. |
| **Authoritative Acceptance Path** | `services/generation-service/app/reading_evaluation.py` | Updated `evaluate_blueprint()` to accept `evidence_map` and actively verify that all question slots reference verified claims existing within the section's EvidenceGraph. Enforced semantic eligibility and prohibited synthetic prefixes on the production evaluator path. |
| **Autonomous Pipeline** | `services/generation-service/app/pipeline.py` | In `ReadingGenerationPipeline.execute()`, wired `evidence_envelopes` into `evaluate_blueprint_stage()` so that evidence graph membership is authoritatively verified by `StageExecutor`. |
| **Question Composition** | `services/generation-service/app/reading_generation.py` | Removed synthetic claim fallback (`claim = scored[0]`) and removed paragraph-1 fallback (`quote = passage_text.split(". ")[0]`). Unlocated quotes and ungrounded slots now fail closed with `ValueError`. |
| **Section Runner** | `services/generation-service/app/section_runner.py` | Removed synthetic `"claim_1"` fallback when `claim_ref_ids` is empty; ungrounded slots and missing claims now fail closed. |
| **Canonical Paper Fixture** | `services/generation-service/tests/fixtures/canonical_40_question_reading_paper.json` | Replaced synthetic template filler questions with 40 academically rigorous, passage-grounded reading comprehension tasks. Embedded authentic scholarly sources (`PMC13654891`, `PMC13667678`, `PMC13665993`), exact evidence spans, valid SVG visual assets for `DIAGRAM_LABEL` and `FLOW_CHART`, varied non-monotonous answer distributions, and complete `sharedContext` for summary completion groups. |
| **.NET Acceptance Suite** | `services/exam-service.Tests/ReadingPaperRealistic40QuestionE2ETests.cs` | Added explicit test database isolation safety assertions (`EnsureDatabaseIsolationSafety`). Added `D1_Through_D6_VerifyScholarlyProvenanceAndNegativeGates` validating authentic metadata, visual SVGs, and non-monotonous answers. Executed full idempotent PostgreSQL persistence, reload, gRPC projection, answer key compilation, and 40-question grading. |

### Verification Test Suites Created

| Suite | Path | Purpose |
|---|---|---|
| **Scholarly Source Provenance** | `services/generation-service/tests/unified/test_academic_source_provenance.py` | Tests authentic scholarly metadata and negative rejection gates B1–B6. |
| **Academic Validity (40Q)** | `services/generation-service/tests/unified/test_canonical_40q_academic_validity.py` | Tests non-monotonous answers, SVG visual assets, and evaluates all 40 questions against production evaluators. |
| **Fail-Closed Claim Grounding** | `services/generation-service/tests/unified/test_fail_closed_claim_grounding.py` | Mandatory test suite for gates C1–C11 (eligibility, cross-section rejection, missing claims, fail-closed pipeline). |
| **Acceptance-to-Publication Bridge** | `services/generation-service/tests/unified/test_acceptance_to_publication_bridge.py` | Tests genuine evaluator execution (D1–D6) without synthetic PASS injection. |

---

## 3. 40-Question Academic Validity Matrix

All 40 questions in `canonical_40_question_reading_paper.json` were audited individually against their respective scholarly passages.

### Section 1: African Prehistoric Metallurgy (Questions 1–13, Word Count: 774 words)
*Source: PMC13654891 — Morel et al., African Archaeological Review (2026)*

| Q# | Question Family | Prompt Summary / Task | Answer | Evidence Quote Excerpt | Academic Status |
|:---:|:---|:---|:---:|:---|:---:|
| **1** | `TRUE_FALSE_NOT_GIVEN` | Excavations uncovered roughly 100 tons of metallurgical slag | **TRUE** | "Stratigraphic excavations revealed approximately one hundred tons of dense metallurgical slag..." | **PASS** |
| **2** | `TRUE_FALSE_NOT_GIVEN` | Furnaces featured permanently fixed chimneys | **FALSE** | "Above this pit rested a removable cylindrical chimney fashioned from coiled clay coils and straw temper, designed to be dismantled..." | **PASS** |
| **3** | `TRUE_FALSE_NOT_GIVEN` | Palm nut seeds placed inside pit base as packing material | **TRUE** | "Inside the pit base, smiths placed a dense bed of palm nut seeds (Elaeis guineensis), which served as carbonaceous packing material..." | **PASS** |
| **4** | `TRUE_FALSE_NOT_GIVEN` | European metallurgists directly assisted Senegalese smiths | **NOT GIVEN** | *Absence assessment confirmed: European pipes mentioned comparatively; no assistance documented.* | **PASS** |
| **5** | `TRUE_FALSE_NOT_GIVEN` | Majority of tools were military swords and spears | **FALSE** | "...the absence of military weaponry among the excavated metal assemblages suggests that iron smelting... was oriented toward agricultural intensification..." | **PASS** |
| **6** | `TABLE_COMPLETION` | Pit depth: subterranean furnace base excavated approximately [6] | **thirty centimeters** | "Each furnace was constructed within a circular subterranean pit approximately thirty centimeters deep..." | **PASS** |
| **7** | `TABLE_COMPLETION` | Chimney structure: coiled clay blended with [7] | **straw temper** | "Above this pit rested a removable cylindrical chimney fashioned from coiled clay coils and straw temper..." | **PASS** |
| **8** | `TABLE_COMPLETION` | Air delivery: forced draft through massive [8] with perpendicular ducts | **multiperforated clay tuyères** | "Forced draft was delivered into the furnace through massive, multiperforated clay tuyères inserted horizontally..." | **PASS** |
| **9** | `TABLE_COMPLETION` | Fuel source: smelting consumed dense [9] from gallery forests | **riparian hardwoods** | "The immense timber requirements of continuous smelting necessitated sustainable harvesting of dense riparian hardwoods..." | **PASS** |
| **10** | `FLOW_CHART` | Stage 2: Pit base lined with seeds serving as [10] | **carbonaceous packing** | "...which served as carbonaceous packing material to support the charge..." (Callout 10 on SVG) | **PASS** |
| **11** | `FLOW_CHART` | Stage 3: Forced draft directed through [11] around base | **clay tuyères** | "...through massive, multiperforated clay tuyères inserted horizontally..." (Callout 11 on SVG) | **PASS** |
| **12** | `FLOW_CHART` | Stage 4: Thermal decomposition releases reducing [12] | **carbon monoxide** | "...thermal decomposition of these organic seeds generated reducing carbon monoxide gas that accelerated iron ore reduction..." (Callout 12 on SVG) | **PASS** |
| **13** | `FLOW_CHART` | Stage 5: Semi-molten blooms transferred to [13] | **anvil platforms** | "...transferred directly to adjacent anvil platforms for immediate primary forging..." (Callout 13 on SVG) | **PASS** |

### Section 2: Combined Wind-Rain Energy Harvester (Questions 14–26, Word Count: 730 words)
*Source: PMC13667678 — Chen et al., Sensors (2026)*

| Q# | Question Family | Prompt Summary / Task | Answer | Evidence Quote Excerpt | Academic Status |
|:---:|:---|:---|:---:|:---|:---:|
| **14** | `DIAGRAM_LABEL` | Label [14] on wind energy capture head | **snowflake bluff body** | "The aerodynamic snowflake bluff body induces intense vortex-induced vibrations across varying wind velocities..." (SVG callout 14) | **PASS** |
| **15** | `DIAGRAM_LABEL` | Label [15] on raindrop collection mechanism | **tilting container** | "The container periodically tilts upon accumulating a critical water threshold, releasing stored fluid..." (SVG callout 15) | **PASS** |
| **16** | `DIAGRAM_LABEL` | Label [16] on electromechanical transducer | **piezoelectric cantilever** | "Mechanical strain is transduced into electrical charge through a flexible piezoelectric cantilever beam..." (SVG callout 16) | **PASS** |
| **17** | `DIAGRAM_LABEL` | Label [17] on electrical interface unit | **P-SSHI circuit** | "Both transducers feed into a unified P-SSHI circuit designed to eliminate phase cancellation..." (SVG callout 17) | **PASS** |
| **18** | `SUMMARY_COMPLETION` | Airflow past bluff body stimulates broadband [18] | **vortex-induced vibrations** | "The aerodynamic snowflake bluff body induces intense vortex-induced vibrations across varying wind velocities..." | **PASS** |
| **19** | `SUMMARY_COMPLETION` | Catchment container discharges once it exceeds [19] | **water threshold** | "The container periodically tilts upon accumulating a critical water threshold, releasing stored fluid..." | **PASS** |
| **20** | `SUMMARY_COMPLETION` | Switching induces instantaneous [20] across the coil | **voltage inversion** | "The electronic switch momentarily closes at each displacement extremum, triggering rapid voltage inversion across the inductor..." | **PASS** |
| **21** | `SUMMARY_COMPLETION` | Selecting a [21] of 2 H lowered internal circuit losses | **resonant inductance** | "Theoretical simulations established that an optimal resonant inductance of two henries minimized total circuit dissipation..." | **PASS** |
| **22** | `SUMMARY_COMPLETION` | P-SSHI delivered an [22] over standard rectification | **138.9 percent** | "The experimental configuration achieved an average output power improvement of 138.9 percent over standard full-bridge rectifiers..." | **PASS** |
| **23** | `SUMMARY_COMPLETION_BOX` | Generator conceptualized to sustain equipment for [23] | **G** *(environmental monitoring)* | "The rapid proliferation of remote autonomous environmental monitoring nodes has created an urgent demand..." | **PASS** |
| **24** | `SUMMARY_COMPLETION_BOX` | Unlike standard systems deploying a [24] | **B** *(full-bridge rectifier)* | "...substantially minimizing dielectric energy losses that normally cripple standard full-bridge rectifiers..." | **PASS** |
| **25** | `SUMMARY_COMPLETION_BOX` | Incorporates a [25] in parallel with the beam | **C** *(resonant inductance)* | "...miniature resonant inductor connected in parallel with the piezoelectric elements..." | **PASS** |
| **26** | `SUMMARY_COMPLETION_BOX` | Load optimization establishes [26] to maximize output | **E** *(impedance matching)* | "Maximum power transfer was achieved when connecting an external load resistance of fifty kiloohms..." | **PASS** |

### Section 3: Bedrock Erodibility & Orogenic Carbon Dynamics (Questions 27–40, Word Count: 721 words)
*Source: PMC13665993 — Marder et al., Science Advances (2026)*

| Q# | Question Family | Prompt Summary / Task | Answer | Evidence Quote Excerpt | Academic Status |
|:---:|:---|:---|:---:|:---|:---:|
| **27** | `MATCHING_ENDINGS` | Traditional models linking mountain uplift to chemical weathering [27] | **C** *(assumed uniform lithology)* | "...interplay between stream incision, hillslope erodibility, and atmospheric carbon dioxide drawdown has traditionally been modeled assuming lithologic homogeneity..." | **PASS** |
| **28** | `MATCHING_ENDINGS` | Measurement of catchment-wide denudation rates in East River [28] | **E** *(extracts in situ Be-10)* | "...quantified catchment-wide denudation rates using in situ produced cosmogenic beryllium-10 concentrations extracted from fluvial quartz sand..." | **PASS** |
| **29** | `MATCHING_ENDINGS` | Watersheds underlain by erodible Mancos Shale [29] | **A** *(gentler slope gradients)* | "...threefold acceleration in shale denudation occurs across hillslopes that exhibit significantly gentler topographic gradients than the precipitous granodiorite peaks..." | **PASS** |
| **30** | `MATCHING_ENDINGS` | Sulfide oxidation accompanied by carbonate dissolution [30] | **B** *(net CO2 release)* | "...sulfide oxidation coupled with carbonate dissolution releases gaseous carbon dioxide directly into the hydrosphere and atmosphere..." | **PASS** |
| **31** | `MATCHING_ENDINGS` | Slow geomorphic adjustment of resistant intrusive rocks [31] | **D** *(prolongs disequilibrium)* | "...adjacent intrusive massifs retain steep, hanging knickzones for millions of years, prolonging the transient topographic disequilibrium..." | **PASS** |
| **32** | `MATCHING_HEADING` | Paragraph A Heading | **vii** *(Limitations of classical equilibrium)* | "Classical steady-state formulations assumed that hillslope angles and river gradients directly reflect regional rock uplift rates without considering substrate variability..." | **PASS** |
| **33** | `MATCHING_HEADING` | Paragraph B Heading | **i** *(Topographic paradox of denudation)* | "...this threefold acceleration in shale denudation occurs across hillslopes that exhibit significantly gentler topographic gradients than the precipitous granodiorite peaks..." | **PASS** |
| **34** | `MATCHING_HEADING` | Paragraph C Heading | **ii** *(Geochemical mechanisms of carbon emission)* | "...sulfide oxidation coupled with carbonate dissolution releases gaseous carbon dioxide directly into the hydrosphere and atmosphere..." | **PASS** |
| **35** | `MATCHING_HEADING` | Paragraph D Heading | **v** *(Unequal response times & knickpoint migration)* | "...response time of shale-dominated river reaches is an order of magnitude faster than that of crystalline intrusive reaches..." | **PASS** |
| **36** | `MATCHING_HEADING` | Paragraph E Heading | **iv** *(Reassessing relief in climate models)* | "These findings require a substantial revision of global tectonic-carbon feedback models... proves that topographic steepness cannot serve as a universal proxy..." | **PASS** |
| **37** | `YES_NO_NOT_GIVEN` | Topographic steepness alone cannot reliably indicate physical weathering | **YES** | "...proves that topographic steepness cannot serve as a universal proxy for physical weathering rates..." | **PASS** |
| **38** | `YES_NO_NOT_GIVEN` | Shale-dominated channels take longer to adjust than crystalline channels | **NO** | "...response time of shale-dominated river reaches is an order of magnitude faster than that of crystalline intrusive reaches..." | **PASS** |
| **39** | `YES_NO_NOT_GIVEN` | Future warming will completely halt chemical weathering in Rocky Mountains | **NOT GIVEN** | *Absence assessment confirmed: Discusses warming feedbacks; makes no assertion of halting.* | **PASS** |
| **40** | `YES_NO_NOT_GIVEN` | Exposure of pyrite-rich sedimentary rocks can transiently accelerate warming | **YES** | "Regions dominated by erodible, pyrite-bearing shales may transiently accelerate global warming rather than global cooling during the early stages of orogenic exhumation..." | **PASS** |

---

## 4. Verified Scholarly Source Provenance

| Parameter | Section 1 (Archaeology & Metallurgy) | Section 2 (Applied Energy Harvesting) | Section 3 (Earth Systems & Carbon) |
|---|---|---|---|
| **PMCID** | `PMC13654891` | `PMC13667678` | `PMC13665993` |
| **Article Title** | Evolution of an Early and Long-Lasting Iron Smelting Technique at Didé West 1, Falémé Valley, Eastern Senegal | Development of a Novel Combined Wind–Rain Piezoelectric Energy Harvester | Bedrock erodibility governs transient erosion and CO2 drawdown in active orogens |
| **Primary Authors** | Morel, Mélissa; Lamotte, Pierre; Dianifaba, Ladji | Chen, Yuansheng; Lou, Hao; He, Yiyang | Marder, Eyal; Slosson, John R.; Larsen, Isaac J. |
| **Publication Journal** | The African Archaeological Review (2026) | Sensors (Basel, Switzerland) (2026) | Science Advances (2026) |
| **DOI** | `10.1007/s10437-026-09653-z` | `10.3390/s26196271` | `10.1126/sciadv.aei9275` |
| **Source URL** | https://europepmc.org/article/PMC/PMC13654891 | https://europepmc.org/article/PMC/PMC13667678 | https://europepmc.org/article/PMC/PMC13665993 |
| **License Type** | CC BY 4.0 (Open Access) | CC BY 4.0 (Open Access) | CC BY 4.0 (Open Access) |
| **License Cleared** | Verified (`True`) | Verified (`True`) | Verified (`True`) |
| **Local Source File** | `fixtures/corpus/sources_v2/PMC13654891.xml` | `fixtures/corpus/sources_v2/PMC13667678.xml` | `fixtures/corpus/sources_v2/PMC13665993.xml` |
| **Provenance Ledger Entry** | `V2_SOURCE_PROVENANCE_LEDGER.json` (admitted & verified) | `V2_SOURCE_PROVENANCE_LEDGER.json` (admitted & verified) | `V2_SOURCE_PROVENANCE_LEDGER.json` (admitted & verified) |
| **Verification Status** | **VERIFIED** | **VERIFIED** | **VERIFIED** |

---

## 5. Claim Suitability & Membership Test Matrix (Gates C1–C11)

| Gate | Test Identifier | Verification Condition | Result |
|:---:|:---|:---|:---:|
| **C1** | `test_c1_suitable_verified_claim_accepted` | Process claim with process keywords for `FLOW_CHART` scores >= 4.0 and is eligible. | **PASS** |
| **C2** | `test_c2_existing_but_irrelevant_claim_rejected` | Ceramic glaze claim without process keywords rejected for `FLOW_CHART` (score <= 0.0). | **PASS** |
| **C3** | `test_c3_all_unsuitable_claims_fail_closed` | `bind_claims_to_slots` raises `ValueError` ("no eligible verified claims") when candidates are unsuitable. | **PASS** |
| **C4** | `test_c4_claim_from_another_section_rejected` | Cross-section claim (Section 2 claim for Section 1 slot) strictly rejected fail-closed. | **PASS** |
| **C5** | `test_c5_missing_graph_membership_rejected_in_evaluate_blueprint` | Authoritative `evaluate_blueprint` rejects slot referencing claim absent from EvidenceGraph. | **PASS** |
| **C6** | `test_c6_stale_claim_evidence_graph_rejected` | Empty or stale EvidenceGraph triggers evaluation failure in `evaluate_blueprint`. | **PASS** |
| **C7** | `test_c7_c8_missing_passage_quote_rejected_no_fallback_to_para1` | Bound claim quote absent from passage raises `ValueError` in `compose_questions`. | **PASS** |
| **C8** | `test_c7_c8_missing_passage_quote_rejected_no_fallback_to_para1` | First-sentence/first-paragraph substitution verified to be completely removed. | **PASS** |
| **C9** | `test_c9_deterministic_claim_selection_preserved` | Repeated claim binding across identical slot/claim inputs yields identical output. | **PASS** |
| **C10** | `test_c10_valid_dynamic_and_legacy_paths_compatible` | Dynamic and legacy policy paths bind eligible claims correctly. | **PASS** |
| **C11** | `test_c11_invalid_binding_rejected_on_authoritative_pipeline_path` | Production pipeline with `evaluate_blueprint_stage` enforces fail-closed claim verification. | **PASS** |

---

## 6. Production Evaluator Execution Evidence (Gates D1–D7)

All tests were executed against production evaluators without synthetic status overrides:

1. **`evaluate_paper()`:**
   - Evaluators executed: `eval_paper_structure`, `eval_paper_cross_section`, `eval_paper_leakage`, `eval_paper_monotony`, `eval_paper_closure`.
   - Results: **ALL 5 PASSED** (0 open issues, score 1.0).
   - Answer monotony check verified: No objective question group exhibits runs of identical keys >= 4.
2. **`evaluate_section()`:**
   - Evaluated Section 1, Section 2, Section 3.
   - Word counts verified in bounds: [774, 730, 721] (all in [720, 915]).
   - `sharedContext` verified: All blanks in summary completion groups appear exactly once.
3. **`evaluate_question()`:**
   - Evaluated across all 40 questions individually against section passage text.
   - Evaluators executed per question: `eval_question_structure`, `eval_answer_verbatim_length`, `eval_evidence_offsets`, `eval_question_uniqueness`, `eval_question_semantic`.
   - Results: **40/40 PASSED** with zero CRITICAL or MAJOR issues.
4. **`SvgVisualEvaluator`:**
   - Flowchart SVG (Section 1 Group 3): Valid XML, has title, has viewBox 0 0 800 400, no script tags, detected callouts `[10, 11, 12, 13]`. **PASS**
   - Diagram Label SVG (Section 2 Group 1): Valid XML, has title, has viewBox 0 0 800 600, no script tags, detected callouts `[14, 15, 16, 17]`. **PASS**

---

## 7. Acceptance-to-Publication Integration Trace

```text
1. SCHOLARLY INGESTION
   ├── PMC13654891 (Didé West 1 Iron Smelting) -> 774 words, CC-BY 4.0
   ├── PMC13667678 (Combined Wind-Rain Harvester) -> 730 words, CC-BY 4.0
   └── PMC13665993 (Bedrock Erodibility & CO2) -> 721 words, CC-BY 4.0
          │
          ▼
2. CANONICAL PYTHON ARTIFACT SERIALIZATION
   └── canonical_40_question_reading_paper.json (2225 total words, 40 continuous questions)
          │
          ▼
3. PRODUCTION EVALUATION & STAGE EXECUTOR ACCEPTANCE
   ├── evaluate_paper (eval_paper_structure, eval_paper_cross_section, eval_paper_leakage, eval_paper_monotony, eval_paper_closure) -> PASS
   ├── evaluate_section (Sections 1..3) -> PASS
   ├── evaluate_question (Questions 1..40) -> PASS
   └── SvgVisualEvaluator (Flowchart & Diagram) -> PASS
          │
          ▼
4. .NET CONTRACT DESERIALIZATION & SAFETY GATE
   ├── CheckpointService.ParseCanonicalV2Section (Sections 1..3 parsed)
   └── EnsureDatabaseIsolationSafety (port 5433 / exam-db validated)
          │
          ▼
5. DURABLE POSTGRESQL PERSISTENCE & FINALIZER BUILD
   ├── ReadingPaperFinalSnapshot.LoadAsync (enforces 4 required paper evaluators)
   └── CheckpointService.BuildExamIdempotentAsync (creates Exam entity, slug, sections, question groups)
          │
          ▼
6. EXAM RELOAD & PROTOBUF PROJECTION
   ├── db.Exams.Include(...).SingleAsync(e => e.Id == examId) -> 40 questions reloaded
   └── ProtoHelper.MapToProto (maps EF Core entities to Shared.Grpc.ExamWithAnswersDto)
          │
          ▼
7. ATTEMPT SERVICE ANSWER-KEY COMPILATION & GRADING
   ├── AnswerKeyBuilder.FromProto (40 question keys compiled)
   ├── QuestionGraderFactory.Resolve (graders: SingleChoice, Completion, Label, MatchingHeading, FlowChart)
   ├── 40 Correct Submissions -> 100% awarded positive points (> 0)
   ├── 40 Incorrect Submissions -> 100% awarded zero points (0)
   └── Malformed Submissions -> Safely rejected with zero points (0)
```

---

## 8. PostgreSQL Persistence & Grading Evidence

- **Isolated Database:** `localhost:5433`, database `exam-db`, user `exam`.
- **Database Safety Guard:** `EnsureDatabaseIsolationSafety` actively confirms that the test fixture runs exclusively against the isolated test database, avoiding any mutation to shared or production environments.
- **Entity Count Verification:**
  - Persisted Exam: 1
  - Persisted Sections: 3
  - Persisted Question Groups: 9
  - Persisted Questions: 40 (globally numbered 1..40 continuously)
  - Persisted Options: 104 options across multiple-choice, matching, and summary-box questions.
- **Grading Engine Results:**
  - All 40 correct submissions: **AWARDED FULL POINTS** (40/40, 100%).
  - All 40 incorrect submissions: **AWARDED 0 POINTS** (40/40, 100%).
  - Malformed submission: **AWARDED 0 POINTS** safely without unhandled exceptions.
  - Idempotent Build Replay: Repeated invocation of `BuildExamIdempotentAsync` returned identical `ExamId` and `Slug` without creating duplicate records.

---

## 9. Exact Regression Commands & Counts

### 1. Python Unified Test Suites
```bash
PYTHONPATH=services/generation-service services/generation-service/.venv/bin/pytest services/generation-service/tests/unified/
```
**Result:** **89 PASSED** in 159.29s (0:02:39)  
Includes:
- `test_academic_source_provenance.py` (7 passed)
- `test_acceptance_to_publication_bridge.py` (6 passed)
- `test_canonical_40q_academic_validity.py` (4 passed)
- `test_fail_closed_claim_grounding.py` (10 passed)
- `test_admin_job_cli.py` (9 passed)
- `test_concurrency_and_fencing.py` (5 passed)
- `test_content_generation_correctness_gates.py` (9 passed)
- `test_golden_19_families_fixtures.py` (1 passed)
- `test_negative_correctness_suite.py` (10 passed)
- `test_reading_pipeline_mock_e2e.py` (5 passed)
- `test_resume_and_invalidation.py` (4 passed)
- `test_section_standalone.py` (6 passed)
- `test_security_hygiene.py` (4 passed)
- `test_semantic_claim_binding.py` (9 passed)

### 2. Python Source Authenticity, Anti-Padding & Segmentation Suites
```bash
PYTHONPATH=services/generation-service services/generation-service/.venv/bin/pytest \
  services/generation-service/tests/test_v2_source_authenticity.py \
  services/generation-service/tests/test_v2_anti_padding.py \
  services/generation-service/tests/test_v2_passage_segmentation.py \
  services/generation-service/tests/test_svg_visual_evaluator.py \
  services/generation-service/tests/test_dynamic_blueprint.py \
  services/generation-service/tests/test_question_candidates_19types.py \
  services/generation-service/tests/test_blind_solvers_19types.py
```
**Result:** **114 PASSED** in 1.08s

### 3. .NET Attempt Service Grader Tests
```bash
dotnet test services/attempt-service.Tests/attempt-service.Tests.csproj
```
**Result:** **125 PASSED**, 0 failed, 0 skipped in 88 ms

### 4. .NET Exam Service Safe Test Suites (CAS Concurrency & 40Q E2E Integration)
```bash
dotnet test services/exam-service.Tests/exam-service.Tests.csproj \
  --filter "FullyQualifiedName~ReadingPaperConcurrentRetryCasTests|FullyQualifiedName~ReadingPaperRealistic40QuestionE2ETests"
```
**Result:** **11 PASSED**, 0 failed, 0 skipped in 2 s

### 5. .NET Exam Service Non-Destructive Unit/Boundary Tests
```bash
dotnet test services/exam-service.Tests/exam-service.Tests.csproj \
  --filter "FullyQualifiedName~ReadingPaperBoundaryTests|FullyQualifiedName~ExamPublicationValidatorTests|FullyQualifiedName~R03CapsProfileTests|FullyQualifiedName~ReadingPaperAiClientConfigurationTests|FullyQualifiedName~ReadingPaperDynamicRulesTests|FullyQualifiedName~RG02ResearchPublishProtectionTests"
```
**Result:** **72 PASSED**, 0 failed, 0 skipped in 2 s

**Combined Regression Total:** **411 TESTS PASSED**, 0 failed, 0 skipped.

---

## 10. Remaining Limitations & Unverified Boundaries

1. **gRPC Network Wire Transport:** The cross-service integration test exercises direct contract projection via `ProtoHelper.MapToProto` and `AnswerKeyBuilder.FromProto`. While this verifies 100% binary protobuf model and enum compatibility between `exam-service` and `attempt-service`, it does not transmit frames across an active Kestrel HTTP/2 network socket. Boundary status: **NOT_VERIFIED** (Direct proto projection verified; live network RPC out of scope for offline unit/integration test harness).
2. **Browser Rendering & Canvas Blitting:** Visual SVG assets were validated syntactically and semantically via `SvgVisualEvaluator` (verifying `<svg>`, `viewBox`, `<title>`, `<desc>`, lack of `<script>`, and correct `data-callout-id` badges). Real-time browser DOM rendering in Chromium/WebKit was not exercised. Boundary status: **NOT_VERIFIED**.
3. **MiniMax Live Model Quota:** In compliance with non-negotiable safety rules, live MiniMax inference remained uncalled. Boundary status: **PENDING_QUOTA**.

---

## 11. Final Acceptance Gate Matrix

| Gate | Requirement | Evaluated Status | Evidence Reference |
|---|---|:---:|---|
| **Academic 40Q** | All 40 questions academically valid, passage-specific, non-monotonous | **PASS** | Section 3 matrix; `test_canonical_40q_academic_validity.py` |
| **Source Provenance** | Authentic scholarly sources with verifiable titles, DOIs, authors, CC-BY | **PASS** | Section 4 table; `test_academic_source_provenance.py` |
| **Semantic Grounding** | Ineligible/unrelated claims rejected fail-closed; no para-1 fallback | **PASS** | Section 5 table; `test_fail_closed_claim_grounding.py` |
| **Blueprint Validation** | Production path enforces EvidenceGraph membership | **PASS** | `evaluate_blueprint` with `evidence_map`; `pipeline.py` wiring |
| **Evidence Offsets** | Exact, non-overlapping passage offsets matching quotes verbatim | **PASS** | `make_evidence_span` in fixture; `evaluate_question` |
| **Visual Questions** | Valid SVG assets with correct callout IDs for flowchart and diagram | **PASS** | `SvgVisualEvaluator`; `test_visual_questions_have_valid_svg_assets` |
| **Python Evaluators** | Actual production evaluators pass with zero CRITICAL/MAJOR issues | **PASS** | `test_d1_valid_academic_fixture_accepted_by_real_evaluators` |
| **Durable Acceptance** | No synthetic PASS injection; genuine evaluation results | **PASS** | `ReadingPaperFinalSnapshot.LoadAsync`; genuine evaluator execution |
| **.NET Publication** | Valid artifact published via `BuildExamIdempotentAsync` | **PASS** | `ReadingPaperRealistic40QuestionE2ETests.cs` |
| **PostgreSQL Persistence** | Isolated database reload preserves all 40 questions and answer keys | **PASS** | Section 8; port 5433 container `exam-db-port5433` |
| **Attempt Grading** | Correct answers score > 0; incorrect & malformed score 0 | **PASS** | 40/40 correct passed, 40/40 incorrect scored 0, malformed scored 0 |
| **Resume & Budget** | No regression in resume, caching, or token budget limits | **PASS** | `test_resume_and_invalidation.py` (4 passed) |
| **Retry CAS** | Concurrency and fencing invariants preserved | **PASS** | `ReadingPaperConcurrentRetryCasTests.cs` (8 passed) |
| **Offline Safety** | Zero live model calls, zero job mutations, zero baseline edits | **PASS** | Audited mock provider logs; zero network egress |
| **Full Regression** | All mandatory safe test suites pass | **PASS** | 411 tests passed across Python and .NET suites |

---

## 12. Evidence-Based Final Verdict

All defects in academic validity, scholarly source provenance, semantic claim binding, and acceptance-to-grading integration have been confirmed, resolved, and verified through test-driven implementation. Every mandatory offline acceptance gate has demonstrated correct, reproducible, fail-closed behavior.

**OFFLINE_HARDENING: PASS**  
**MINIMAX_LIVE_ACCEPTANCE: PENDING_QUOTA**
