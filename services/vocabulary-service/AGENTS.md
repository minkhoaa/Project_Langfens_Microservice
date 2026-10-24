# Vocabulary service
Owns decks/flashcards, per-user study state and SM2 review scheduling; optionally enriches vocabulary via Azure OpenAI.

- `Features/{Admin,Public,User}/` separate deck management, discovery and learner operations.
- `Features/User/UserService.cs` applies review state; `Application/Helper/Sm2Scheduler.cs` computes scheduling.
- Preserve grade 0–5 semantics, failure reset, EF floor and UTC-based due dates; test with an explicit clock/time input.
- SM2 state belongs to the learner/card relation; preserve repetitions, easiness, interval and next-due together.
- Publishes `CardReviewed` for gamification; no registered MassTransit consumers.
- `Application/AiEnrichmentService.cs` and `VocabularyExtractionService.cs` use optional `AZURE_OPENAI__*`; missing provider configuration must not require live calls in tests.
- Authorization is tier-specific via `AddVocabularyAuthorization()`; retain deck ownership checks.
- Build from root: `dotnet build services/vocabulary-service/vocabulary-service.csproj`.
- No dedicated test project exists; cover failed/pass review transitions and card-event behavior when changing scheduling.
