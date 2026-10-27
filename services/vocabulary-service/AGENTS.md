# Vocabulary service
Decks/cards and learner-specific SM2 review state; Azure AI enrichment/extraction is optional.

- Reviews: `Features/User/UserService.cs`; scheduling: `Application/Helper/Sm2Scheduler.cs`.
- Preserve grades 0–5, failure reset, EF floor 1.3 and UTC dates; update repetitions/easiness/interval/next-due together on the learner/card relation.
- Publishes `CardReviewedEvent` to gamification; no registered consumers.
- Preserve `AddVocabularyAuthorization()` tier policies and deck ownership checks; `AZURE_OPENAI__*` must remain optional.
- Test failed/pass scheduling with explicit time and isolated AI/event dependencies.
