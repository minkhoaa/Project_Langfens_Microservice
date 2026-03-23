# Langfens Phase 2 — Redesigned Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement 3 AI-powered learning modules (Writing Comparative, Speaking Roleplay, Grammar Explainer) with full-stack ownership per developer.

**Architecture:** Python FastAPI AI Service + Qdrant vector DB + fine-tuned Gemini 2.5 Flash Lite models, integrated into existing .NET microservices via YARP gateway. Frontend in Next.js 16.

**Tech Stack:** Python 3.12/FastAPI, Qdrant v1.13.6, Gemini 2.5 Flash Lite (fine-tuned x3), Gemini text-embedding-004, Redis 7.4, .NET 8/EF Core, Next.js 16/React 19/TypeScript 5, Tailwind CSS 4/shadcn-ui.

**Spec:** `docs/superpowers/specs/2026-03-18-phase2-redesign-spec.md`

---

## Current Status (Mar 23, 2026)

**Timeline:** Week 1 complete | Deadline: May 29, 2026 (~9 weeks remaining)

### Milestone Progress

| Milestone | Target | Status | Notes |
|-----------|--------|--------|-------|
| MS1: Infrastructure Ready | Mar 16 | ✅ DONE | Qdrant, AI Service, YARP |
| MS2: Data Indexed | Apr 3 | ⚠️ PARTIAL | Cloud Qdrant has 40,122 essays (expanded) |
| MS3: Writing Module | Apr 24 | 🔄 IN PROGRESS | AI endpoint done, .NET integration done, frontend partial |
| MS4: Grammar Module | Apr 24 | ❌ NOT STARTED | Task 22 not started |
| MS5: Speaking Module | May 15 | 🔄 PARTIAL | Scenarios done (10), endpoint done, frontend not started |
| MS6: Production Ready | May 29 | ❌ NOT STARTED | - |

### Task Summary

| Phase | Tasks | Done | In Progress | Pending |
|-------|-------|------|-------------|---------|
| Phase 1 (Foundation) | 12 | 5 | 1 | 6 |
| Phase 2 (Writing+Grammar) | 11 | 0 | 2 | 9 |
| Phase 3 (Speaking) | 9 | 0 | 0 | 9 |
| Phase 4 (QA+Deploy) | 4 | 0 | 0 | 4 |
| **Total** | **37** | **5** | **3** | **29** |

### Critical Path Items

1. **Fine-tuning** - NOT STARTED (Tasks 13, 14, 20) - Must start Week 2
2. **Speaking Module** - Scenarios + endpoint done, but backend/frontend integration pending
3. **Grammar Module** - Not started at all
4. **Frontend** - Writing comparative UI partial (backend done)

---

## Owner Legend

- **MK** = Tu Minh Khoa (Writing Comparative + Grammar Explainer, full-stack)
- **TK** = Nguyen Ba Trong Khoi (Speaking Roleplay, full-stack)
- Tasks marked with owner indicate primary responsibility

---

## PHASE 1: FOUNDATION + DATA (Weeks 1-3)

### Task 1: Qdrant Container Setup [MK] — Week 1 ✅ DONE

**Files:**
- Modify: `deploy/compose.yaml`
- Modify: `deploy/compose.local.yaml`

- [x] Qdrant v1.13.6 container added to Docker Compose on `backend` network
- [x] Ports 6333 (HTTP) and 6334 (gRPC) exposed
- [x] Healthcheck configured
- [x] Verified: `curl http://localhost:6333/healthz` returns 200

---

### Task 2: AI Service Scaffold [MK] — Week 1 ✅ DONE

**Files:**
- Create: `services/ai-service/` (FastAPI project)
- Key files: `app/main.py`, `app/config.py`, `app/routers/health.py`
- Create: `services/ai-service/Dockerfile`
- Modify: `deploy/envs/ai.env`

- [x] FastAPI app with `/api/healthz` endpoint
- [x] Pydantic settings (`app/config.py`) for Qdrant, Gemini, Redis config
- [x] Dockerfile with Python 3.12
- [x] Environment file `deploy/envs/ai.env`

---

### Task 3: YARP Gateway Route [MK] — Week 1 ✅ DONE

**Files:**
- Modify: `gateway/api-gateway/appsettings.json`

- [x] Route `/api-ai/*` -> `ai-service:8080` with 60s timeout
- [x] Verified end-to-end: Frontend -> Gateway -> AI Service

---

### Task 4: Embedding Service [MK] — Week 2 ✅ DONE

**Files:**
- Modify: `services/ai-service/app/services/embedding_service.py`
- Modify: `services/ai-service/app/routers/embed.py`
- Modify: `services/ai-service/app/config.py`

- [x] **Step 1: Implement Gemini text-embedding-004 wrapper**
  - `embedding_service.py`: `embed_text(text: str) -> list[float]` (768-dim)
  - `embed_batch(texts: list[str]) -> list[list[float]]` for batch processing
  - Use `google-generativeai` SDK with model `models/gemini-embedding-001`

- [x] **Step 2: Create `/api/v1/embed` test endpoint**
  - `embed.py`: POST endpoint accepting `{"text": "..."}`, returns vector

- [x] **Step 3: Test embedding**
  ```bash
  curl -X POST http://localhost:5000/api-ai/api/v1/embed \
    -H "Content-Type: application/json" \
    -d '{"text": "IELTS writing sample"}'
  ```
  Expected: 768-dim float array

- [x] **Step 4: Commit**
  ```bash
  git add services/ai-service/app/services/embedding_service.py services/ai-service/app/routers/embed.py
  git commit -m "feat(ai): implement Gemini text-embedding-004 wrapper"
  ```

---

### Task 5: Qdrant Collections + Embedding Pipeline [MK] — Week 2-3 ⚠️ PARTIAL

**Files:**
- Create: `scripts/embed_and_upload.py`
- Modify: `services/ai-service/app/services/ingestion_service.py`
- Modify: `services/ai-service/app/services/search_service.py`
- Data: `data/rag/writing_samples.jsonl` (27MB, 12,339 docs)
- Data: `data/rag/grammar_knowledge.jsonl` (2.5MB, 5,659 docs)

**Status (Mar 23, 2026):**
- Cloud Qdrant: writing_samples has **40,122 points** (expanded beyond original 12,339 plan)
- Local Qdrant: Empty (0 collections)
- `/api/v1/writing/search` endpoint: ✅ IMPLEMENTED

- [x] **Step 1: Create `writing_samples` collection in Qdrant**
  - Vector size: 768 (Gemini embedding dim)
  - Distance: Cosine
  - Metadata fields: `band_overall` (float), `task_type` (keyword), `topic` (keyword), `quality_tier` (keyword)
  - HNSW index with default params

- [x] **Step 2: Build `scripts/embed_and_upload.py`**
  - Read `data/rag/writing_samples.jsonl`
  - Batch embed (50 at a time) via Gemini
  - Upsert to Qdrant with metadata
  - Progress bar, resume capability (skip existing IDs)

- [x] **Step 3: Run embedding pipeline**
  ```bash
  cd services/ai-service
  python scripts/embed_and_upload.py --collection writing_samples --input ../../data/rag/writing_samples.jsonl
  ```
  Actual: 40,122 points indexed (cloud Qdrant)

- [x] **Step 4: Create `grammar_knowledge` collection**
  - Same schema but metadata: `error_type` (keyword), `source` (keyword)
  - Embed `data/rag/grammar_knowledge.jsonl` (5,659 docs)

- [x] **Step 5: Implement `/api/v1/writing/search` endpoint**
  - `services/ai-service/app/routers/writing.py`
  - Input: `{"query": "essay text", "top_k": 3, "filters": {"band_overall": 7}}`
  - Embed query -> Qdrant search -> return top-K essays with scores

- [ ] **Step 6: Verify search quality**
  ```bash
  curl -X POST http://localhost:5000/api-ai/api/v1/writing/search \
    -H "Content-Type: application/json" \
    -d '{"query": "Climate change affects...", "top_k": 3}'
  ```
  Expected: 3 relevant Band 7+ essays returned

- [x] **Step 7: Commit**
  ```bash
  git add scripts/embed_and_upload.py services/ai-service/
  git commit -m "feat(ai): Qdrant collections + embedding pipeline for writing and grammar"
  ```

---

### Task 6: Writing Fine-Tuning Data Validation [MK] — Week 2

**Files:**
- Data: `/home/khoa/dataset_ielts/export/finetune/m1_writing.jsonl` (80MB, 23,961 pairs)

- [ ] **Step 1: Spot-check 50 random training examples**
  - Verify input/output format matches Gemini fine-tuning spec
  - Check: proper JSON structure, reasonable content quality
  - Document issues found

- [ ] **Step 2: Create validation script**
  ```bash
  python -c "
  import json, random
  with open('/home/khoa/dataset_ielts/export/finetune/m1_writing.jsonl') as f:
      lines = f.readlines()
  samples = random.sample(lines, 50)
  for s in samples:
      d = json.loads(s)
      assert 'input' in d and 'output' in d, f'Missing keys: {d.keys()}'
  print(f'Validated 50/{len(lines)} samples OK')
  "
  ```

---

### Task 7: Speaking Fine-Tuning Data Validation [TK] — Week 3

**Files:**
- Data: `/home/khoa/dataset_ielts/export/finetune/m2_speaking.jsonl` (15MB, 8,938 pairs)

- [ ] **Step 1: Spot-check 50 random training examples**
  - Same validation as Task 6 but for speaking data
  - Verify conversation format, role assignments, vocabulary targets

---

### Task 8: Frontend Research + Mockups [TK] — Weeks 1-2

**Files:**
- No code files — design deliverables

- [ ] **Step 1: Research side-by-side text comparison UI patterns** (Week 1)
  - Document approach: diff-style highlight, two-column layout, inline annotations
  - Reference: existing `WritingGradeResult.tsx` layout

- [ ] **Step 2: Research chat interface patterns for roleplay** (Week 1)
  - Document: message bubble styles, typing indicators, audio input integration
  - Reference: existing `SpeakingRecorderBar.tsx`

- [ ] **Step 3: Design Writing Comparative results page mockup** (Week 2)
  - Tab layout: Scores | Comparative | Suggestions
  - SentenceComparisonTable, SimilarEssaysSidebar, VocabularySuggestions

- [ ] **Step 4: Design Roleplay chat UI + Scenario Selector mockup** (Week 2)
  - ScenarioSelector: grid layout with difficulty badges
  - RoleplayChatUI: message bubbles, audio recorder, memory indicator
  - SessionReportUI: vocabulary stats, error list, suggestions

- [ ] **Step 5: Design Grammar Explainer UI mockup** (Week 3)
  - Error -> Theory (cited) -> Examples layout
  - Inline card within Writing results

---

### Task 9: Roleplay Scenarios Authoring [TK] — Week 3 ✅ DONE

**Files:**
- Create: `services/ai-service/app/data/scenarios/*.json` (10 files)

- [x] **Step 1: Author 10 roleplay scenarios**
  Each JSON file contains:
  ```json
  {
    "id": "airport-checkin",
    "title": "Airport Check-in",
    "description": "Practice checking in for a flight...",
    "difficulty": "intermediate",
    "roles": {
      "agent": "Airport staff at the check-in counter",
      "user": "Traveler checking in for an international flight"
    },
    "target_vocabulary": ["boarding pass", "luggage", "departure gate", ...],
    "opening_message": "Good morning! Welcome to...",
    "suggested_turns": 8
  }
  ```
  Scenarios: airport, job-interview, restaurant, hotel, doctor, shopping, bank, university, phone-call, cue-card-part2

- [ ] **Step 2: Commit**
  ```bash
  git add services/ai-service/app/data/scenarios/
  git commit -m "content: add 10 speaking roleplay scenarios"
  ```

---

### Task 10: Grammar Data Validation [TK] — Week 3

**Files:**
- Data: `data/rag/grammar_knowledge.jsonl` (5,659 GEC pairs, already ready)
- Schema: `/home/khoa/dataset_ielts/scripts/grammar/grammar_rule_schema.json`

- [ ] **Step 1: Validate grammar_knowledge.jsonl against schema**
  - Spot-check 50 entries for quality
  - Verify metadata fields (source_dataset, task, word_count)
  - Document any issues found

- [ ] **Step 2: Confirm data is ready for Qdrant embedding**
  - All entries have valid `text` field for embedding
  - Metadata is consistent and filterable

---

### Task 11: Speaking Scenarios GET Endpoint — Backend Warm-up [TK] — Week 3 ✅ DONE

**Files:**
- Create: `services/ai-service/app/routers/speaking.py`
- Modify: `services/ai-service/app/main.py` (register router)

- [x] **Step 1: Implement `/api/v1/speaking/roleplay/scenarios` GET endpoint**
  ```python
  # services/ai-service/app/routers/speaking.py
  from fastapi import APIRouter
  import json, os
  from app.config import settings

  router = APIRouter(prefix="/api/v1/speaking/roleplay", tags=["speaking"])

  @router.get("/scenarios")
  async def list_scenarios():
      scenarios_dir = os.path.join(settings.data_dir, "scenarios")
      scenarios = []
      for f in os.listdir(scenarios_dir):
          if f.endswith(".json"):
              with open(os.path.join(scenarios_dir, f)) as fh:
                  scenarios.append(json.load(fh))
      return {"scenarios": sorted(scenarios, key=lambda s: s["title"])}
  ```

- [ ] **Step 2: Register router in `main.py`**
  Add `from app.routers.speaking import router as speaking_router` and `app.include_router(speaking_router)`

- [ ] **Step 3: Test endpoint**
  ```bash
  curl http://localhost:5000/api-ai/api/v1/speaking/roleplay/scenarios
  ```
  Expected: JSON array of 10 scenarios

- [ ] **Step 4: Commit**
  ```bash
  git add services/ai-service/app/routers/speaking.py services/ai-service/app/main.py
  git commit -m "feat(speaking): add scenarios list endpoint (TK's first FastAPI endpoint)"
  ```

---

### Task 12: Knowledge Transfer Session [MK -> TK] — Week 2

**No code files — hands-on session (2-3 hours)**

- [ ] **Topics to cover:**
  1. Google AI Studio fine-tuning workflow (upload JSONL, configure, train, evaluate)
  2. AI Service patterns: how routers, services, config work
  3. Qdrant client: create collection, upsert, search, filter
  4. Gemini SDK: chat completion, structured output, temperature settings
  5. Embedding service: how to embed and search
  6. Redis session state pattern

---

## PHASE 2: WRITING + GRAMMAR MODULES (Weeks 4-6) — MK Focus

### Task 13: Fine-Tune Writing Model [MK] — Week 4

**Files:**
- Data: `/home/khoa/dataset_ielts/export/finetune/m1_writing.jsonl`

- [ ] **Step 1: Upload training data to Google AI Studio**
  - Format: Gemini-compatible JSONL (23,961 input/output pairs)
  - Base model: Gemini 2.5 Flash Lite

- [ ] **Step 2: Configure fine-tuning**
  - Epochs: 3-5 (start with 3)
  - Learning rate: default
  - Batch size: default

- [ ] **Step 3: Start training and monitor**
  - Note model endpoint URL when complete

- [ ] **Step 4: Quality gate — evaluate model**
  - Test with 10 sample essays (diverse topics + band levels)
  - Criteria: structured JSON output correct >90%, relevant comparisons for 8/10 essays
  - If FAIL: adjust training data or hyperparams and retrain
  - If FAIL after 2 attempts: fallback to base Gemini + prompt engineering

- [ ] **Step 5: Update `app/config.py` with fine-tuned model endpoint**
  Add `gemini_writing_model: str = "tunedModels/writing-comparative-v1"` to Settings

---

### Task 14: Fine-Tune Speaking Model [TK] — Week 4

**Files:**
- Data: `/home/khoa/dataset_ielts/export/finetune/m2_speaking.jsonl`

- [ ] **Step 1: Upload training data to Google AI Studio**
  - 8,938 conversation pairs
  - Base model: Gemini 2.5 Flash Lite

- [ ] **Step 2: Configure and start training** (same params as Task 13)

- [ ] **Step 3: Quality gate — evaluate model**
  - Test: 5 different scenarios, 10+ turns each
  - Criteria: stays in character, structured JSON >90% correct, natural conversation
  - If FAIL: retrain or fallback to base Gemini + prompt engineering

- [ ] **Step 4: Update `app/config.py` with Speaking model endpoint**
  Add `gemini_speaking_model: str = "tunedModels/speaking-roleplay-v1"` to Settings

---

### Task 15: Writing Compare Endpoint [MK] — Week 4 ✅ DONE

**Files:**
- Modify: `services/ai-service/app/routers/writing.py`
- Modify: `services/ai-service/app/services/compare_service.py`
- Create: `services/ai-service/app/prompts/writing_compare.py`
- Modify: `services/ai-service/app/schemas.py`

- [x] **Step 1: Define Pydantic schemas**
  ```python
  # schemas.py additions
  class CompareRequest(BaseModel):
      essay_text: str
      topic: str = ""
      task_type: str = "Task 2"
      band_filter: float = 7.0

  class SentenceComparison(BaseModel):
      original: str
      improved: str
      explanation: str

  class CompareResponse(BaseModel):
      overall_analysis: str
      vocabulary_feedback: str
      coherence_feedback: str
      grammar_feedback: str
      task_response_feedback: str
      sentence_comparisons: list[SentenceComparison]
      reference_essays: list[dict]
  ```

- [ ] **Step 2: Design comparative prompt**
  ```python
  # prompts/writing_compare.py
  WRITING_COMPARE_PROMPT = """
  You are an IELTS Writing examiner. Compare the student's essay against
  3 high-scoring reference essays retrieved from our database.
  ...
  """
  ```

- [ ] **Step 3: Implement `/api/v1/writing/compare` endpoint**
  - Embed student essay -> Qdrant search top-3 -> call fine-tuned Gemini with prompt
  - Parse structured JSON response
  - Handle Gemini API errors gracefully

- [ ] **Step 4: Test endpoint**
  ```bash
  curl -X POST http://localhost:5000/api-ai/api/v1/writing/compare \
    -H "Content-Type: application/json" \
    -d '{"essay_text": "Climate change is...", "task_type": "Task 2"}'
  ```
  Expected: CompareResponse JSON with all fields populated

- [ ] **Step 5: Commit**
  ```bash
  git add services/ai-service/app/
  git commit -m "feat(writing): implement comparative analysis endpoint with RAG"
  ```

---

### Task 16: Scaffold Writing Frontend [MK] — Week 4

**Files:**
- Modify: `langfens-fe-app/src/app/do-test/[skill]/[attemptId]/components/writing/WritingGradeResult.tsx`
- Create: `langfens-fe-app/src/app/do-test/[skill]/[attemptId]/components/writing/WritingComparativeTab.tsx`
- Create: `langfens-fe-app/src/app/do-test/[skill]/[attemptId]/components/writing/SimilarEssaysSidebar.tsx`

- [ ] **Step 1: Add tab navigation to WritingGradeResult**
  - Tabs: "Scores" (existing) | "Comparative" (new) | "Suggestions" (new)
  - Use shadcn Tabs component

- [ ] **Step 2: Create WritingComparativeTab with placeholder data**
  - Layout: sentence comparison table structure
  - Mock data for development

- [ ] **Step 3: Create SimilarEssaysSidebar with placeholder data**
  - 3 essay cards with band score + snippet
  - Mock data

- [ ] **Step 4: Commit**
  ```bash
  git add langfens-fe-app/src/app/do-test/
  git commit -m "feat(writing-fe): scaffold comparative tab with placeholder data"
  ```

---

### Task 17: Speaking Chat UI Components [TK] — Week 4

**Files:**
- Create: `langfens-fe-app/src/app/speaking-practice/page.tsx`
- Create: `langfens-fe-app/src/app/speaking-practice/components/ScenarioSelector.tsx`
- Create: `langfens-fe-app/src/app/speaking-practice/components/RoleplayChatUI.tsx`
- Create: `langfens-fe-app/src/app/speaking-practice/components/AudioRecorderBar.tsx`

- [ ] **Step 1: Create ScenarioSelector page**
  - Grid of scenario cards with title, description, difficulty badge
  - Fetch from `/api/v1/speaking/roleplay/scenarios` (real data from Task 11)
  - Click to start roleplay session

- [ ] **Step 2: Create RoleplayChatUI component**
  - Message bubble layout (agent left, user right)
  - Typing indicator for agent responses
  - Scroll to bottom on new messages
  - Placeholder/static data for now

- [ ] **Step 3: Create AudioRecorderBar component**
  - Record button (hold to record or toggle)
  - Waveform visualization during recording
  - Reference: existing `SpeakingRecorderBar.tsx` patterns
  - Audio capture via MediaRecorder API

- [ ] **Step 4: Commit**
  ```bash
  git add langfens-fe-app/src/app/speaking-practice/
  git commit -m "feat(speaking-fe): scaffold scenario selector, chat UI, audio recorder"
  ```

---

### Task 18: .NET Writing Integration [MK] — Week 5 ✅ DONE (Mar 23, 2026)

**Files:**
- Modify: `services/writing-service/Features/RabbitMq/WritingSubmittedConsumer.cs`
- Modify: `services/writing-service/Domains/Entities/WritingEvaluation.cs`
- Create: EF Core migration for `ComparativeAnalysisJson` column
- Modify: `services/writing-service/Features/Service/User/WritingService.cs`

- [x] **Step 1: Add `ComparativeAnalysisJson` column to WritingEvaluation entity**
  ```csharp
  // WritingEvaluation.cs
  public string? ComparativeAnalysisJson { get; set; }  // nullable, JSON string
  ```

- [ ] **Step 2: Create EF migration**
  ```bash
  cd services/writing-service
  dotnet ef migrations add AddComparativeAnalysis
  ```

- [ ] **Step 3: Modify WritingSubmittedConsumer**
  - After existing Gemini grading completes:
  - HTTP POST to AI Service `/api/v1/writing/compare` with essay text
  - Store response JSON in `ComparativeAnalysisJson`
  - Wrap in try/catch — if AI Service fails, grading still returns (circuit breaker)

- [ ] **Step 4: Extend WritingGradeResponse DTO**
  - Add optional `comparativeAnalysis` field
  - Backward-compatible: null if AI Service unavailable

- [ ] **Step 5: Test circuit breaker**
  - Stop AI Service container
  - Submit writing -> should get Gemini grading without comparative data
  - Start AI Service -> submit writing -> should get full response

- [ ] **Step 6: Commit**
  ```bash
  git add services/writing-service/
  git commit -m "feat(writing): integrate AI Service comparative analysis with circuit breaker"
  ```

---

### Task 19: Writing Frontend — SentenceComparisonTable [MK] — Week 5

**Files:**
- Create: `langfens-fe-app/src/app/do-test/[skill]/[attemptId]/components/writing/SentenceComparisonTable.tsx`

- [ ] **Step 1: Build SentenceComparisonTable with test data**
  - Two-column layout: "Your sentence" | "Band 9.0 version"
  - Diff highlighting (red for removed, green for improved)
  - Explanation row below each pair
  - 3-5 comparisons per analysis

- [ ] **Step 2: Commit**
  ```bash
  git add langfens-fe-app/src/app/do-test/
  git commit -m "feat(writing-fe): build sentence comparison table component"
  ```

---

### Task 20: Fine-Tune Grammar Model [MK] — Week 5

**Files:**
- Data: `/home/khoa/dataset_ielts/export/finetune/m3_grammar.jsonl`

- [ ] **Step 1: Upload and fine-tune** (same workflow as Task 13)
  - 5,659 pairs, base model Gemini 2.5 Flash Lite

- [ ] **Step 2: Quality gate**
  - Test with 20 common IELTS grammar errors
  - Criteria: accurate error identification, relevant theory cited, clear examples

- [ ] **Step 3: Update config**
  Add `gemini_grammar_model: str = "tunedModels/grammar-explainer-v1"` to Settings

---

### Task 21: Speaking Backend — Start + Turn Endpoints [TK] — Week 5

**Files:**
- Modify: `services/ai-service/app/routers/speaking.py`
- Create: `services/ai-service/app/services/speaking_service.py`
- Create: `services/ai-service/app/services/session_service.py`
- Create: `services/ai-service/app/prompts/speaking_roleplay.py`

- [ ] **Step 1: Implement Redis session service**
  ```python
  # services/session_service.py
  import redis, json
  class SessionService:
      def create_session(self, session_id, scenario, memory_context) -> dict
      def get_session(self, session_id) -> dict | None
      def add_turn(self, session_id, role, content) -> None
      def delete_session(self, session_id) -> None
  ```
  - Redis key: `session:{session_id}`, TTL: 30 minutes
  - Store: scenario_context, conversation_history (last 20 turns), target_vocabulary, vocabulary_tracker

- [ ] **Step 2: Create Qdrant `speaking_memory` collection**
  - Vector size: 768
  - Metadata: `user_id` (keyword), `session_id` (keyword), `scenario_type` (keyword), `topics_discussed` (keyword[]), `vocabulary_used` (keyword[]), `timestamp` (integer)

- [ ] **Step 3: Implement `POST /api/v1/speaking/roleplay/start`**
  ```python
  @router.post("/start")
  async def start_session(request: StartSessionRequest):
      # 1. Load scenario from JSON
      # 2. Query Qdrant speaking_memory for user's past sessions
      # 3. Load target vocabulary from scenario
      # 4. Create Redis session with context
      # 5. Return opening message from scenario
  ```

- [ ] **Step 4: Implement `POST /api/v1/speaking/roleplay/turn`**
  ```python
  @router.post("/turn")
  async def process_turn(request: TurnRequest):
      # 1. Get session from Redis
      # 2. Add user transcript to history
      # 3. Build prompt: scenario + history + vocabulary + memory
      # 4. Call fine-tuned Gemini
      # 5. Parse response (text + metadata)
      # 6. Track vocabulary usage
      # 7. Update Redis session
      # 8. Return agent response
  ```

- [ ] **Step 5: Test conversation flow**
  ```bash
  # Start session
  curl -X POST http://localhost:5000/api-ai/api/v1/speaking/roleplay/start \
    -d '{"scenario_id": "airport-checkin", "user_id": "test-user-1"}'
  # Send turn
  curl -X POST http://localhost:5000/api-ai/api/v1/speaking/roleplay/turn \
    -d '{"session_id": "...", "transcript": "Hello, I would like to check in for my flight"}'
  ```

- [ ] **Step 6: Commit**
  ```bash
  git add services/ai-service/app/
  git commit -m "feat(speaking): implement roleplay start and turn endpoints with Redis sessions"
  ```

---

### Task 22: Grammar Explain Endpoints [MK] — Week 6

**Files:**
- Modify: `services/ai-service/app/routers/grammar.py`
- Create: `services/ai-service/app/services/grammar_service.py`
- Create: `services/ai-service/app/prompts/grammar_explain.py`

- [ ] **Step 1: Design Grammar Explainer prompt**
  ```python
  # prompts/grammar_explain.py
  GRAMMAR_EXPLAIN_PROMPT = """
  You are an IELTS grammar teacher. Given a sentence with a grammar error
  and relevant grammar theory from our database, explain the error clearly.
  ...
  """
  ```

- [ ] **Step 2: Implement `POST /api/v1/grammar/explain`**
  - Input: `{"error_sentence": "...", "context": "..."}`
  - Embed error -> search `grammar_knowledge` top-3 rules -> call fine-tuned Grammar Gemini
  - Output: `{error_type, explanation, grammar_rule, corrected_sentence, examples[]}`

- [ ] **Step 3: Implement `POST /api/v1/grammar/batch-explain`**
  - Input: `{"errors": [{"sentence": "...", "context": "..."}, ...]}`
  - Process multiple errors from one Writing evaluation
  - Return array of explanations

- [ ] **Step 4: Test**
  ```bash
  curl -X POST http://localhost:5000/api-ai/api/v1/grammar/explain \
    -d '{"error_sentence": "The informations is important.", "context": "IELTS Task 2 essay"}'
  ```
  Expected: explanation about uncountable nouns with cited theory

- [ ] **Step 5: Commit**
  ```bash
  git add services/ai-service/app/
  git commit -m "feat(grammar): implement explain and batch-explain endpoints"
  ```

---

### Task 23: Writing + Grammar Frontend — Wire to Real Data [MK] — Week 6 🔄 PARTIAL

**Files:**
- Modify: `langfens-fe-app/src/app/do-test/[skill]/[attemptId]/components/writing/WritingComparativeTab.tsx`
- Modify: `langfens-fe-app/src/app/do-test/[skill]/[attemptId]/components/writing/SimilarEssaysSidebar.tsx`
- Modify: `langfens-fe-app/src/app/do-test/[skill]/[attemptId]/components/writing/SentenceComparisonTable.tsx`
- Create: `langfens-fe-app/src/app/do-test/[skill]/[attemptId]/components/writing/VocabularySuggestions.tsx`
- Create: `langfens-fe-app/src/app/do-test/[skill]/[attemptId]/components/writing/GrammarExplainerCard.tsx`
- Create: `langfens-fe-app/src/app/do-test/[skill]/[attemptId]/components/writing/GrammarBatchView.tsx`

**Status (Mar 23, 2026):**
- `attempts/[attemptId]/page.tsx`: Added `comparativeAnalysisJson` field + "Compare to Band 8-9" toggle + inline comparative analysis section (✅ DONE)
- Separate components (SentenceComparisonTable, SimilarEssaysSidebar, GrammarExplainerCard, etc.): ❌ NOT CREATED

- [ ] **Step 1: Wire WritingComparativeTab to real API data**
  - Fetch `comparativeAnalysis` from WritingGradeResponse
  - Parse and display in existing tab structure
  - Handle null (AI Service unavailable) gracefully

- [ ] **Step 2: Wire SimilarEssaysSidebar to real data**
  - Display 3 reference essays with band scores and snippets

- [ ] **Step 3: Wire SentenceComparisonTable to real data**
  - Map `sentence_comparisons[]` from API response

- [ ] **Step 4: Build VocabularySuggestions component**
  - Display vocabulary_feedback as actionable word replacements
  - Show context from reference essays

- [ ] **Step 5: Build GrammarExplainerCard component**
  - Error -> Theory (cited) -> Corrected -> Examples
  - Collapsible card design

- [ ] **Step 6: Build GrammarBatchView component**
  - List of GrammarExplainerCards for all errors in a submission
  - Fetch from `/grammar/batch-explain` when user clicks "Explain Errors"

- [ ] **Step 7: Define Grammar-Writing cross-module UX**
  - Click grammar error in Comparative tab -> scroll to Grammar Explainer
  - Link between the two views

- [ ] **Step 8: Commit**
  ```bash
  git add langfens-fe-app/src/app/do-test/
  git commit -m "feat(writing-fe): wire comparative + grammar UI to real API data"
  ```

---

### Task 24: Speaking Roleplay Prompt + Vocabulary Tracking [TK] — Week 6

**Files:**
- Modify: `services/ai-service/app/prompts/speaking_roleplay.py`
- Modify: `services/ai-service/app/services/speaking_service.py`

- [ ] **Step 1: Design roleplay prompt**
  - Incorporate: scenario context, conversation history, target vocabulary, long-term memory
  - Agent should stay in character, steer toward target vocabulary naturally
  - Output: response text + vocabulary detected + errors detected

- [ ] **Step 2: Implement vocabulary tracking**
  - After each turn, check user transcript against target_vocabulary
  - Track which words used, how many times, in what context
  - Store in Redis session state

- [ ] **Step 3: Test prompt quality**
  - Run 5 different scenarios, 10+ turns each
  - Verify agent stays in character and tracks vocabulary

- [ ] **Step 4: Commit**
  ```bash
  git add services/ai-service/app/
  git commit -m "feat(speaking): implement roleplay prompt and vocabulary tracking"
  ```

---

### Task 25: Scenarios Batch 2 [TK] — Week 6

- [ ] **Step 1: Author 10 more scenarios (total: 20)**
  - Topics: library, gym, travel-agency, landlord, colleague, teacher, neighbor, tourist-info, post-office, cue-card-part2-v2

- [ ] **Step 2: Commit**
  ```bash
  git add services/ai-service/app/data/scenarios/
  git commit -m "content: add 10 more speaking scenarios (total: 20)"
  ```

---

### Task 26: Quick Code Review — Speaking Endpoints [MK reviews TK] — Week 6

- [ ] **Review TK's code from Tasks 21, 24:**
  - `services/ai-service/app/routers/speaking.py`
  - `services/ai-service/app/services/speaking_service.py`
  - `services/ai-service/app/services/session_service.py`
  - `services/ai-service/app/prompts/speaking_roleplay.py`
- [ ] **Check:** API patterns, error handling, Redis usage, Qdrant queries, prompt quality
- [ ] **Provide feedback** for TK to address in Phase 3

---

## PHASE 3: SPEAKING ROLEPLAY MODULE (Weeks 7-9) — TK Focus

### Task 27: Writing E2E Integration Test [MK] — Week 7

- [ ] **Step 1: Test full flow**
  - Submit essay via frontend -> WritingSubmittedConsumer -> Gemini grading -> AI Service compare -> frontend displays
  - Verify: band scores, comparative analysis, grammar explanations all display

- [ ] **Step 2: Test circuit breaker**
  - Stop AI Service -> submit essay -> grading works, comparative is null

- [ ] **Step 3: Cache Qdrant queries in Redis**
  - Cache frequent writing searches (TTL: 1 hour)
  - Target: response time < 5 seconds

---

### Task 28: Assist Writing + Grammar E2E Testing [TK] — Week 7

- [ ] **Step 1: Execute 5 writing submission test scenarios**
  - Various essay types (Task 1, Task 2, different topics)
  - Verify comparative analysis quality
  - Verify grammar explanations accuracy
  - Document issues found for MK

---

### Task 29: Speaking — End Endpoint + Memory + STT [TK] — Week 7

**Files:**
- Modify: `services/ai-service/app/routers/speaking.py`
- Modify: `services/ai-service/app/services/speaking_service.py`

- [ ] **Step 1: Implement repeated idea detection**
  - Before each turn, query `speaking_memory` for user's past sessions
  - If similar topic/idea found, include in prompt context
  - Agent can reference: "As you mentioned in our previous session about..."

- [ ] **Step 2: Implement `POST /api/v1/speaking/roleplay/end`**
  - Generate session report: vocabulary stats, errors, suggestions
  - Call fine-tuned Gemini for feedback summary
  - Output: `{vocabulary_used[], vocabulary_missed[], errors[], suggestions[], overall_feedback}`

- [ ] **Step 3: Whisper STT pairing session with MK (2h)**
  - Understand .NET Speaking Service Whisper integration
  - Plan: audio upload -> Speaking Service (Whisper) -> transcript text -> AI Service roleplay/turn

- [ ] **Step 4: Connect STT pipeline**
  - Frontend sends audio to Speaking Service
  - Speaking Service runs Whisper STT
  - Transcript forwarded to AI Service `/roleplay/turn`
  - Full voice pipeline: record -> transcribe -> AI respond

- [ ] **Step 5: Commit**
  ```bash
  git add services/ai-service/app/
  git commit -m "feat(speaking): implement end endpoint, memory detection, STT pipeline"
  ```

---

### Task 30: Polish Writing + Grammar Frontend [MK] — Week 7-8

- [ ] **Step 1: Polish Writing Comparative UI**
  - Loading states, error states, empty states
  - Responsive design (mobile-friendly)
  - Smooth transitions between tabs

- [ ] **Step 2: Polish Grammar Explainer UI**
  - Collapsible cards, smooth animations
  - "Load more" for many errors

- [ ] **Step 3: Cross-browser testing**
  - Chrome, Firefox, Safari
  - Fix browser-specific issues

---

### Task 31: Speaking Frontend Integration [TK] — Week 8

**Files:**
- Modify: `langfens-fe-app/src/app/speaking-practice/components/RoleplayChatUI.tsx`
- Create: `langfens-fe-app/src/app/speaking-practice/components/SessionReportUI.tsx`

- [ ] **Step 1: Integrate Chat UI with roleplay API**
  - `POST /start` on scenario select -> display opening message
  - Audio record -> send to STT -> get transcript -> `POST /turn` -> display response
  - Show typing indicator while waiting for AI
  - Display vocabulary tracking indicators

- [ ] **Step 2: Build SessionReportUI**
  - Vocabulary stats: used vs missed target words
  - Error list with corrections
  - Suggestions for improvement
  - Overall feedback from AI

- [ ] **Step 3: Store session summary to Qdrant**
  - On session end, embed summary -> upsert to `speaking_memory`
  - Verify persistence for next session

- [ ] **Step 4: Commit**
  ```bash
  git add langfens-fe-app/src/app/speaking-practice/
  git commit -m "feat(speaking-fe): integrate chat UI with real API, add session report"
  ```

---

### Task 32: Full Code Review — Speaking Backend [MK] — Week 8

- [ ] **Review all Speaking code:**
  - All endpoints (scenarios, start, turn, end)
  - Session management (Redis)
  - Memory system (Qdrant speaking_memory)
  - Prompt quality
  - Error handling, edge cases
- [ ] **Provide comprehensive feedback and approve**

---

### Task 33: Speaking Integration Test + Polish [TK] — Week 9

- [ ] **Step 1: Full E2E test**
  - Select scenario -> start -> 5 turns (audio) -> end -> report
  - Verify: all data flows correctly, report accurate

- [ ] **Step 2: Test long-term memory**
  - Session 1: discuss travel, mention specific preferences
  - Session 2: same user, different scenario -> agent recalls past info
  - Verify memory continuity

- [ ] **Step 3: Build MemoryIndicator component**
  - Visual indicator in chat when agent references past sessions
  - "Based on our previous conversation..." badge/icon

- [ ] **Step 4: Polish Roleplay UI**
  - Responsive, smooth transitions, loading states
  - Error handling (network issues, AI timeout)
  - Accessibility

- [ ] **Step 5: Prompt tuning**
  - Iterate on roleplay agent quality
  - Natural conversation, stays in character, steers vocabulary

---

## PHASE 4: TESTING, QA & DEPLOYMENT (Weeks 10-11)

### Task 34: E2E Testing — All Modules [Both] — Week 10

- [ ] **MK: Test Writing + Grammar modules**
  - 10 real user scenarios (diverse essay types)
  - Verify comparative analysis quality
  - Verify grammar explanations accuracy
  - Test report generated

- [ ] **TK: Test Speaking module**
  - 5 different scenarios, 10+ turns each
  - Verify memory persistence across sessions
  - Test STT pipeline reliability
  - Test report generated

---

### Task 35: Load Testing + Performance [MK] — Week 10

- [ ] **Step 1: Load testing: 50 concurrent users**
  - Tool: k6 or locust
  - Scenarios: writing submit, speaking turns, grammar explain
  - Target: p95 < 10s for writing compare, p95 < 3s for speaking turn

- [ ] **Step 2: Rate limiting for AI Service**
  - Configure per-endpoint rate limits
  - 429 response when exceeded

- [ ] **Step 3: Structured logging**
  - Request/response logging for AI calls
  - Latency tracking
  - Error monitoring

---

### Task 36: Cross-browser + Accessibility [TK] — Week 10

- [ ] Chrome, Firefox, Safari testing for Speaking features
- [ ] WCAG accessibility review
- [ ] Mobile responsive testing + fixes

---

### Task 37: Deployment + Documentation [Both] — Week 11

- [ ] **MK: Docker optimization + staging deploy**
  - Multi-stage Docker builds
  - Deploy full system to staging
  - Staging smoke test all 3 modules
  - Security review: API keys, rate limits, input validation

- [ ] **MK: Technical report**
  - Architecture, design decisions, evaluation results

- [ ] **TK: API documentation**
  - OpenAPI/Swagger for AI Service endpoints

- [ ] **TK: User guide**
  - How to use Writing Comparative, Speaking Roleplay, Grammar Explainer

- [ ] **Both: Demo presentation**
  - Live demo of all 3 modules
  - Prepare backup recordings in case of live issues
