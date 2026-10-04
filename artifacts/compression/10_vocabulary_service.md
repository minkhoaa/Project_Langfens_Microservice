# 10 — vocabulary-service

> Source-of-truth: `services/vocabulary-service/*`. Verified by direct reads.

## Role in the system

Flashcards with **SM2 spaced repetition**:

- Decks (admin-managed; categories: TOEIC / IELTS / VSTEP).
- Cards per deck (admin CRUD + bulk create).
- User subscribes to decks, gets due cards, reviews cards (SM2 update).
- AI enrichment (Azure OpenAI, optional) + vocabulary extraction from a passage.
- Publishes `CardReviewedEvent` to RabbitMQ (consumed by `gamification-service`).

## Stack

- ASP.NET Core 10, EF Core + Npgsql (`NonRetryingExecutionStrategy`).
- MassTransit + RabbitMQ (publisher only — no consumers registered).
- Optional Azure OpenAI (`AZURE_OPENAI__ENDPOINT/APIKEY/DEPLOYMENT`, default `gpt-4o-mini`).

## Persistence

`VocabularyDbContext` (`Decks`, `FlashCards`, `UserDeckStatus`). Cards track SM2 state (`EasinessFactor`, `Repetitions`, `Interval`, `NextReviewDate`).

## SM2 algorithm

Implemented in `Features/User/UserService.ReviewCard()` (or `Sm2Calculator`). Quality rating 0–5:

- 0–2 → fail: reset interval to 1 day, repetitions = 0.
- 3–5 → pass: update EF (clamped to ≥ 1.3) and compute next interval:
  - rep 1 → 1 day
  - rep 2 → 6 days
  - rep n>2 → previous_interval × EF

(Specific constants in `UserService.ReviewCard()` — see source.)

## Endpoints

`Features/VocabularyEndpoint.cs`:

Public (anonymous):

| Method | Path |
|---|---|
| GET | `/api/decks/` |
| GET | `/api/decks/{slug}` |
| GET | `/api/decks/slug:{slug}/cards` |
| GET | `/api/decks/deck:{deckId}/cards` |
| GET | `/api/vocabulary/enrich?word=...` |
| POST | `/api/vocabulary/extract` (body `{passageText, maxWords?}`) |

User (`Roles.User`):

| Method | Path |
|---|---|
| POST | `/api/users/{userId}/subscribe/{deckId}` |
| GET | `/api/users/{userId}/subscribe` |
| GET | `/api/users/{userId}/own` |
| GET | `/api/users/{userId}/flashcard/due` |
| POST | `/api/users/{userId}/flashcard/{cardId}/review` |
| GET | `/api/users/{userId}/flashcard/progress` |

Admin (deck/card management, also under `/api/users` group but admin policy applies):

| Method | Path |
|---|---|
| POST | `/api/users/deck` |
| PUT | `/api/users/deck/{deckId}` |
| DELETE | `/api/users/deck/{deckId}` |
| POST | `/api/users/deck/{deckId}/card` |
| POST | `/api/users/deck/{deckId}/cards` (bulk) |
| PUT | `/api/users/deck/card/{cardId}` |
| DELETE | `/api/users/deck/card/{cardId}` |
| DELETE | `/api/users/deck/{deckId}/publish` |

(Admin paths are under the same `/api/users` group; routes use no additional `RequireAuthorization` on each — they inherit the group's `Roles.User` policy. For admin paths the code in `AdminHandler` enforces admin role internally — see source.)

## AI integration

`IAiEnrichmentService` (Azure OpenAI) — returns example sentences, synonyms, definitions.

`IVocabularyExtractionService` — extracts vocabulary from passage text.

Both are optional — service logs a warning and degrades gracefully if env vars are missing.

## RabbitMQ

- Publisher only.
- Publishes `CardReviewedEvent(UserId, CardId, Grade, IsCorrect)` on flashcard review.

## Health checks

- `vocabulary-db` (NpgSql) only. RabbitMQ probe intentionally omitted (comment in code: MassTransit retries).

## Environment variables (verified)

| Key | Purpose |
|---|---|
| `AZURE_OPENAI__ENDPOINT` | optional |
| `AZURE_OPENAI__APIKEY` | optional |
| `AZURE_OPENAI__DEPLOYMENT` | default `gpt-4o-mini` |
| `RABBITMQ__HOST/PORT/USERNAME/PASSWORD/VHOST/USESSL` | broker |
| `ConnectionStrings__vocabulary-db` | Aspire-injected |

## Authorization

`AddVocabularyAuthorization()` (service-local):

- `Roles.User` → `RequireRole(Roles.User)`
- `Roles.Admin` → `RequireRole(Roles.Admin)`
- `VocabScope.VocabRead` / `VocabScope.VocabManage` via `HasAnyScope`.
