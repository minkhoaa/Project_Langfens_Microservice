# Paired MiniMax-Text vs MiniMax-M3 Live E2E Benchmark Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Execute a controlled, sequential, paired LIVE E2E benchmark comparing `MiniMax-Text-01` (Arm A) and `MiniMax-M3` (Arm B) for autonomous IELTS Academic Reading exam generation inside two isolated Docker Compose environments without altering existing production configurations.

**Architecture:** Two isolated, self-contained Docker Compose topologies (`deploy/compose.benchmark-text.yaml` and `deploy/compose.benchmark-m3.yaml`) run sequentially. Each topology encapsulates `exam-database` (PostgreSQL), `generation-service` (Python/FastAPI pipeline), and `exam-service` (.NET 10 Minimal API with `ReadingPaperWorker`), ensuring zero host bridge firewall interference, single-worker lease isolation, and model pinning. A host-side Python benchmark runner orchestrates source ingestion, job creation, read-only polling, metrics extraction from PostgreSQL, and forensic report generation.

**Tech Stack:** Python 3.12, .NET 10.0, Docker Compose, PostgreSQL 16, MiniMax API (`https://api.minimaxi.chat/v1`), Pydantic v2.

**Spec:** Prompt instructions for LANGFENS — PAIRED MINIMAX TEXT VS M3 LIVE E2E BENCHMARK (Phase 1–4, Safety Rules, Final Report).

## Global Constraints

- Pinned baseline commit: `85974fbc6aed06a6b170a25e39f845d6ad901a18`.
- No modifications to existing production code or configuration files (`services/`, `AppHost/`, `deploy/compose.yaml`, `deploy/envs/`).
- Arm A (`MiniMax-Text-01`) and Arm B (`MiniMax-M3`) must run sequentially, never concurrently.
- Exactly one `ReadingPaperWorker` per database; zero race conditions.
- No Groq or other fallback providers allowed (`LLM_PROVIDER_ORDER=minimax`, `allowed_providers=["minimax"]`).
- Never substitute `MiniMax-M3.1-Flash` for `MiniMax-M3`.
- Strict fail-closed stopping rule: halt remaining campaign jobs after two consecutive confirmed identical systemic defects.
- Zero manual retries, repairs, or interventions during live execution.
- Final deliverable saved strictly to `docs/reports/MINIMAX_TEXT_VS_M3_PAIRED_LIVE_BENCHMARK.md`.

## Review Focus

1. **Worker & Database Isolation:** Ensure the benchmark compose database port (5448) does not conflict with Aspire's local port (5433) and that Aspire workers cannot poll the benchmark database.
2. **Container Network Closure:** Ensure `generation-service` and `exam-service` reach each other over the internal Docker network (`http://exam-service:8080` and `http://generation-service:8080`) with valid internal auth headers.
3. **M3 8192-Token Headroom:** Verify that M3's wire `max_tokens: 8192` completion cap is tracked through `conservative_token_reservation` and reconciled against actual reported usage without budget breaches.
4. **Reasoning Token Accounting:** Ensure `reasoning_tokens` from M3 are parsed and recorded in PostgreSQL `reading_paper_operations.ReasoningTokensUsed`.
5. **Exact Sequential Execution:** Pilot pair on Europe PMC executed first; continue to subsequent pairs only if runtime integrity and model compatibility are confirmed healthy.

---

### Task 1: Create Isolated Docker Compose Topologies for Arm A and Arm B

**Files:**
- Create: `deploy/compose.benchmark-text.yaml`
- Create: `deploy/compose.benchmark-m3.yaml`

**Interfaces:**
- Consumes: `langfens-exam:benchmark` and `langfens-generation:benchmark` images.
- Produces: Two distinct compose environments sharing the same service contracts, differing only in `MINIMAX_MODEL` (`MiniMax-Text-01` vs `MiniMax-M3`).

- [ ] **Step 1: Write `deploy/compose.benchmark-text.yaml`**
  Define `exam-database` (port 5448:5432, volume `bench_text_db`), `generation-service` (port 8086:8080, `MINIMAX_MODEL=MiniMax-Text-01`), and `exam-service` (port 8087:8080, worker enabled, connecting to internal services).

- [ ] **Step 2: Write `deploy/compose.benchmark-m3.yaml`**
  Define identical services with volume `bench_m3_db`, port 5448:5432 for db, 8086:8080 for generation, 8087:8080 for exam, with `MINIMAX_MODEL=MiniMax-M3`.

- [ ] **Step 3: Verify Compose Config Validity**
  Run: `docker compose -f deploy/compose.benchmark-text.yaml config` and `docker compose -f deploy/compose.benchmark-m3.yaml config`
  Expected: Valid YAML output with 0 errors.

---

### Task 2: Phase 1 Runtime and Model Compatibility Preflight

**Files:**
- Create: `scripts/benchmark_preflight_check.py`

**Interfaces:**
- Consumes: MiniMax API, running benchmark compose container, JWT auth secret.
- Produces: Verified preflight status check confirming internal auth, worker singularity, MiniMax API reachability, and model response parsing.

- [ ] **Step 1: Write `scripts/benchmark_preflight_check.py`**
  Implement checks for:
  1. Direct MiniMax API completion test for `MiniMax-Text-01` and `MiniMax-M3`.
  2. Verification that M3 returns `reasoning_content` and `reasoning_tokens`.
  3. Start `compose.benchmark-text.yaml` and verify `/healthz` on port 8087 (exam-service) and 8086 (generation-service).
  4. Test internal auth between services (`X-Internal-Service-Key`).
  5. Check `reading_paper_jobs` in database on 5448 has 0 active competing leases.

- [ ] **Step 2: Run Preflight Verification Script**
  Run: `python3 scripts/benchmark_preflight_check.py`
  Expected: All preflight gates PASS.

- [ ] **Step 3: Shut down test container**
  Run: `docker compose -f deploy/compose.benchmark-text.yaml down`

---

### Task 3: Build Benchmark Harness and Metrics Collector

**Files:**
- Create: `scripts/run_paired_benchmark.py`

**Interfaces:**
- Consumes: 6 candidate source definitions (Europe PMC, HTTPS URL, HTML, Markdown, Plain Text, Mixed).
- Produces: Execution logs, PostgreSQL operational metrics extraction, JSON results in `reports/benchmark/`.

- [ ] **Step 1: Define Source Set Definitions and Payload Formats**
  Encode the 6 identical source triples matching `MINIMAX_MULTI_SOURCE_LIVE_CAMPAIGN.md`:
  1. Europe PMC (`PMC13654891`, `PMC13667678`, `PMC13621526`)
  2. HTTPS URL (NASA Temperature, PLOS ONE Executive Function, Stanford Cognitive Science)
  3. HTML (NASA Temperature Tracker, NASA Paleoclimatology, Stanford Cognitive Science)
  4. Markdown (Alan Turing FAIR, Alan Turing Storage, Alan Turing Ethics)
  5. Plain Text (Einstein Relativity, Adam Smith Wealth of Nations, Darwin Origin of Species)
  6. Mixed (PMC13654891, NASA URL, Turing Markdown)

- [ ] **Step 2: Implement Sequential Job Submission and Read-Only Polling**
  Implement job creation via `POST /api/admin/reading-paper/jobs`, monitor logs without intervention, record start/end wall-time, and extract PostgreSQL operation rows (`reading_paper_operations`, `reading_paper_runs`, `reading_paper_evaluations`).

- [ ] **Step 3: Implement Database Metrics Aggregator**
  Query PostgreSQL 5448 to collect:
  - Calls count, Prompt tokens, Completion tokens, Reasoning tokens, Total tokens.
  - Cost estimate calculation based on official MiniMax pricing:
    - Text-01: Prompt $0.001 / 1k tokens, Completion $0.001 / 1k tokens.
    - M3: Prompt $0.0008 / 1k tokens, Completion $0.002 / 1k tokens.
  - First-pass question acceptance rate, bounded repair count, evaluator pass/fail breakdown.

---

### Task 4: Execute Pilot Pair on Europe PMC (Arm A & Arm B)

**Interfaces:**
- Consumes: `deploy/compose.benchmark-text.yaml`, `deploy/compose.benchmark-m3.yaml`, `scripts/run_paired_benchmark.py`.
- Produces: Verified pilot pair outcomes for Pair 1 (Europe PMC).

- [ ] **Step 1: Start Arm A (Text-01) Environment and Run PMC Pilot Job**
  Command: `python3 scripts/run_paired_benchmark.py --pair 1 --arm text`
  Monitor until terminal status (`Completed` or `Failed`).

- [ ] **Step 2: Tear down Arm A Environment and Start Arm B (M3) Environment**
  Command: `python3 scripts/run_paired_benchmark.py --pair 1 --arm m3`
  Monitor until terminal status (`Completed` or `Failed`).

- [ ] **Step 3: Evaluate Pilot Pair Health Gate**
  Verify: Did both models run without infrastructure/authentication failure?
  If 2 consecutive systemic failures occur, invoke Early Stop Rule.
  If healthy, proceed to Task 5.

---

### Task 5: Execute Sequential Benchmark Across Remaining Source Sets (Pairs 2–6)

- [ ] **Step 1: Execute Pair 2 (HTTPS URL) — Arm A then Arm B**
- [ ] **Step 2: Execute Pair 3 (HTML) — Arm A then Arm B**
- [ ] **Step 3: Execute Pair 4 (Markdown) — Arm A then Arm B**
- [ ] **Step 4: Execute Pair 5 (Plain Text) — Arm A then Arm B**
- [ ] **Step 5: Execute Pair 6 (Mixed Sources) — Arm A then Arm B**
- [ ] **Step 6: Stop containers and preserve database records**

---

### Task 6: Compile Authoritative Benchmark Report

**Files:**
- Create: `docs/reports/MINIMAX_TEXT_VS_M3_PAIRED_LIVE_BENCHMARK.md`

**Interfaces:**
- Consumes: Extracted PostgreSQL records, JSON summaries from `reports/benchmark/`.
- Produces: Authoritative markdown benchmark report.

- [ ] **Step 1: Compile Side-by-Side Comparison Matrix**
  Table comparing all source sets across both arms:
  - Job ID, Run ID, Status, Accepted Questions / 40.
  - MiniMax Calls, Prompt/Completion/Reasoning Tokens, Billable Cost ($), Wall-clock duration.
  - First-pass acceptance rate, repair count, root cause classification.

- [ ] **Step 2: Author Detailed Technical & Forensic Audit**
  Analyze M3 reasoning performance vs Text-01 direct generation, schema adherence, `absenceAssessment` behavior, and evaluator agreement.

- [ ] **Step 3: Conclude Definitive Comparative Verdict**
  Provide clear conclusions:
  - `TEXT_LIVE_E2E: PASS / PARTIAL / FAIL`
  - `M3_LIVE_E2E: PASS / PARTIAL / FAIL`
  - `COMPARATIVE_VERDICT: TEXT / M3 / INCONCLUSIVE`

- [ ] **Step 4: Commit and push report**
  Safely commit `docs/reports/MINIMAX_TEXT_VS_M3_PAIRED_LIVE_BENCHMARK.md` and push to `origin/autonomous-generation`.
