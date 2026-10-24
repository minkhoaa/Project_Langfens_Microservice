# Vocabulary service
Decks/cards, learner-specific study state and SM2 scheduling; optional Azure AI enrichment/extraction.

- `Features/User/UserService.cs` updates review state; `Application/Helper/Sm2Scheduler.cs` computes schedules.
- Preserve grade 0–5, failure reset, EF floor 1.3 and UTC dates; update repetitions/easiness/interval/next-due together on the learner/card relation.
- Publishes `CardReviewedEvent`; no registered consumers. Keep gamification event compatibility.
- `AddVocabularyAuthorization()` and deck ownership checks enforce tier boundaries; `AZURE_OPENAI__*` is optional.
- No dedicated tests; exercise failed/pass scheduling with explicit time and isolate AI/event dependencies.
