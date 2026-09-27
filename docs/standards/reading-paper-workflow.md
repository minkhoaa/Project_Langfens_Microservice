# IELTS Academic Reading paper generation

The admin entry point is **Exams → Generate Reading paper** in the frontend repo (`langfens-fe-app`). An admin enters a topic, reviews verified source suggestions, chooses one to three distinct articles in passage order, and starts one durable job. The job URL can be reopened; the page also lists recent jobs.

## Configuration

- `AI_SERVICE_URL` on `exam-service` points to `ai-service`. Aspire and both Compose files set it.
- `OPENALEX_API_KEY` on `ai-service` is optional, but anonymous [OpenAlex](https://help.openalex.org/api/) search can be rate limited. The UI reports that response and asks the admin to retry or configure a key. Keep the key in the AI service environment, never in the frontend.
- The existing Groq configuration on `ai-service` is needed to rewrite passages, create question groups, and review answer keys.

OpenAlex search is limited to recent open-access works. Each DOI is resolved to a PMCID through Europe PMC metadata, then checked for downloadable [Europe PMC full text XML](https://europepmc.org/RestfulWebService). The XML must contain at least 600 source words, author attribution, and a verifiable CC BY or CC0 license. The service reads a fixed Europe PMC URL from a validated PMCID; the client cannot supply a fetch URL. Candidate DOI values are deduplicated. Network failures remain visible as network failures rather than being reported as ineligible articles.

In addition to Europe PMC academic articles, the system supports Universal Source Ingestion from arbitrary plain text, HTML documents, Markdown, and Web URLs. See [Universal Source Ingestion Specification](reading-paper-universal-source-ingestion.md) for data schemas and content sanitization rules.

## Job and paper lifecycle

Admin APIs under `/api/admin/reading-paper`:

| Method | Path | Use |
| --- | --- | --- |
| GET | `/sources?topic=...` | Search and verify suggestions; return up to three recommended PMCIDs when available. The UI initially selects only the first. |
| POST | `/jobs` | Verify one to three selected PMCIDs and create a `Pending` or `NeedsSources` job. |
| GET | `/jobs` | List recent jobs. |
| GET | `/jobs/{id}` | Read status, checkpoints, source metadata, generated sections and persisted generation logs. |
| PUT | `/jobs/{id}/sources` | Replace sources for `NeedsSources` or `Failed` jobs and reset section checkpoints. |
| POST | `/jobs/{id}/retry` | Retry a `Failed` job from its last saved section. |

The worker claims jobs with a database lease, renews it during generation, and saves each complete section to `reading_paper_jobs`. An expired `Running` lease can be reclaimed after a restart. A failed section can be retried without repeating earlier sections. Checkpoint and final-save transactions run inside the PostgreSQL execution strategy on the same DbContext as the transaction; the change tracker is cleared before each attempt. Retrying an acknowledged checkpoint is safe, and a completed job is recognized if commit succeeded before its acknowledgment was lost. The final `Exam`, selected sections, groups, questions and answer rows are inserted in one transaction together with the job's `ExamId`. The exam slug is unique per job and the status is always `DRAFT`.

The worker stores timestamped progress entries on the job. During section generation, the AI service streams source-fetch, model-call, validation, repair and independent-answer-review events as newline-delimited JSON; the worker persists each event immediately. The admin page polls the job, displays the complete log including exception tracebacks, and can copy all entries. Logs remain available after completion, failure, retry and source replacement.

Each section is checked for 720–915 passage words, its fixed question types and counts, continuous numbering, a distinct source, complete answer keys, distinct options, nonduplicate prompts, an evidence quote in the passage, and an explanation. A separate model call reviews every answer against the generated passage. One source creates a 13-question, 20-minute practice exam; two sources create a 26-question, 40-minute practice exam; three sources create the complete 40-question, 60-minute paper with 2150–2750 passage words, matching the [IELTS Academic Reading format](https://ielts.org/take-a-test/test-types/ielts-academic-test/ielts-academic-format-reading). Every completion has one numbered blank, so the current attempt grader gives each item one point. Source title, authors, URL, DOI, PMCID and license are stored on each section; attribution is appended to the displayed passage.

The finished job page shows passages, groups, answer keys, explanations and source links. The existing exam editor handles correction and publication. AI review is a screening step; the admin still checks the Draft before publishing.

## Verification

Run from this repository root:

```sh
dotnet test services/exam-service.Tests/exam-service.Tests.csproj
cd services/ai-service && PYTHONDONTWRITEBYTECODE=1 PYTHONPATH=. .venv/bin/pytest -q -p no:cacheprovider tests/test_reading_paper.py
```

The PostgreSQL integration test runs only when `READING_TEST_POSTGRES` points to an **empty isolated database**. It enables Npgsql retries, applies migrations, fails section 2 once, resumes from the section 1 checkpoint, and verifies that exactly one complete Draft is stored for that job. It then verifies a separate one-passage Draft. The test refuses a database that already has public tables.

Run from `langfens-fe-app`:

```sh
npm run typecheck
npx vitest run src/app/admin/exams/reading-paper/page.test.tsx
```

The tests cover source eligibility, missing or duplicate sources, one-to-three-passage output, answer and count validation, EF graph construction, migration discovery, compatibility with current attempt graders, and the web flow with mocked APIs. A live generation run additionally requires working OpenAlex, Europe PMC and Groq services.
