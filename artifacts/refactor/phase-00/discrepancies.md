# Discrepancies Register: Observed vs. Documented vs. Proposed (Phase 00 Baseline)

**Date:** 2026-09-30  
**Status:** Frozen for Gate G00  

This register documents all differences identified between the architecture/design documentation, the actual code implementation in the repository, and the proposed resolution in Loop Engine V2. As per rule: **Do not silently treat bugs or implementation quirks as invariants.**

---

## 1. Short Answer Validation Exception Message in `ReadingPaperRules.Validate`

- **Documented:** The architecture documentation states that `ReadingPaperRules.Validate` verifies completion answers (Sentence Completion, Summary Completion) and Short Answer questions for exact passage occurrence and 1–3 words limit.
- **Observed in Code:** In `services/exam-service/Features/ReadingPaper/ReadingPaperModels.cs` (lines 87–91):
  ```csharp
  else if ((group.Type is "SENTENCE_COMPLETION" or "SUMMARY_COMPLETION"
            && !q.Prompt.Contains($"[{next}]", StringComparison.Ordinal))
           || Words.Matches(q.Answer).Count is < 1 or > 3
           || !Regex.IsMatch(section.Passage, $@"(?<!\w){Regex.Escape(q.Answer)}(?!\w)", RegexOptions.IgnoreCase))
      throw new InvalidOperationException($"Question {next} has an invalid completion answer");
  ```
  When a `SHORT_ANSWER` question fails the word count (e.g. > 3 words) or does not match the passage regex, the exception thrown is `"Question {next} has an invalid completion answer"`.
- **Proposed in V2:** In Phase 01 ADR and Phase 12 validation, decouple the branches to emit accurate, type-aware error messages: `"Question {next} has an invalid short answer"` vs `"Question {next} has an invalid completion answer"`.

---

## 2. Microservice Topology: `ai-service` vs. Dedicated `generation-service`

- **Documented:** Earlier documentation (`00-master-plan.md`, `docs/standards/exam-generation-architecture.md`) described generation routes being hosted inside `services/ai-service/app/routers/reading_paper.py`.
- **Observed in Code:** As recorded in `HANDOFF_SEPARATE_GENERATION_SERVICE.md` and visible in `AppHost/Program.cs`, `deploy/compose.yaml`, and `services/generation-service/`:
  - The generation logic has been split into an independent, lightweight Python service `services/generation-service`.
  - `services/ai-service` has had `reading_paper.py` deleted to remain lean (only writing, speaking, embeddings).
  - `exam-service` communicates with `generation-service` via `GENERATION_SERVICE_URL`.
- **Proposed in V2:** Affirm and standardize `services/generation-service` as the canonical home for Loop Engine V2. Keep `ai-service` strictly focused on learner evaluations.

---

## 3. Gateway Routing & Client Timeouts

- **Documented:** Gateway cluster timeout was described as 20s default, with 60s for `ai-cluster`.
- **Observed in Code:**
  - `gateway/api-gateway/appsettings.json` defines `generation-cluster` (`http://generation-service:8080`) with no explicit timeout override (inheriting 20s).
  - However, `ReadingPaperAiClient` in `exam-service` connects directly to `GENERATION_SERVICE_URL` (`http://generation-service:8080`), configured with `Timeout = TimeSpan.FromMinutes(45)` and per-request `CancellationTokenSource.CancelAfter(TimeSpan.FromMinutes(45))`.
- **Proposed in V2:** Long-running generation jobs executed by `ReadingPaperWorker` MUST continue calling `GENERATION_SERVICE_URL` directly over the internal container network. External admin calls through the API Gateway (`/api-generation/...`) should be limited to low-latency queries (`/sources`, `/source/ingest`) or configured with appropriate streaming timeouts in Phase 13.

---

## 4. Rate-Limit Handling in LLM Calls

- **Documented:** Master plan calls for bounded retries with shared parent budgets and circuit breaking.
- **Observed in Code:** In `services/generation-service/app/pipeline.py` (lines 120–124):
  ```python
  if attempt == 2 or not any(token in error for token in ("429", "rate limit", "rate_limit")):
      await _progress(progress, f"LLM request failed: {exc}", "Error")
      raise
  await _progress(progress, f"LLM rate limited the request; retrying after 65 seconds (attempt {attempt + 2}/3).", "Warning")
  await asyncio.sleep(65)
  ```
  The legacy pipeline performs a hardcoded 65-second sleep upon encountering HTTP 429.
- **Proposed in V2:** In Phase 03 (`ProviderGateway`), replace fixed sleeps with exponential backoff respecting `Retry-After` headers and enforce an authoritative job token/call budget so jobs do not hang indefinitely.

---

## 5. Ingestion Word Count Boundary Condition

- **Documented:** Minimum source length is 600 words.
- **Observed in Code:**
  - In `extractor.py` `parse_full_text`: `if len(WORD.findall(content)) < 600: raise SourceError(...)`
  - In `extractor.py` `ingest_source`: `if word_count < 600: raise SourceError(...)`
  - An article with exactly 600 words is valid; 599 words is rejected.
- **Proposed in V2:** Maintain `word_count >= 600` as the strict invariant.
