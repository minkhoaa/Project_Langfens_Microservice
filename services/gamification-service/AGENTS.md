# Gamification service
Owns XP, achievements, streaks and notifications; reacts to other services' domain events.

- `Features/Consumers/` handles `AttemptCompleted`, `CardReviewed`, `LessonCompleted` and `UserCreated`.
- Register consumers with `AddConsumer`; `ConfigureEndpoints` supplies the existing queue convention.
- Check duplicate-delivery behavior when changing consumers; do not assume existing handlers provide exactly-once XP awards.
- `Infrastructure/Persistence/GamificationDbContext.cs` owns progress/achievement data.
- `Features/GamificationService.cs` and `Features/NotificationService.cs` support REST projections; `AddGamificationAuthorization()` defines local policies.
- Coordinate changed event fields with attempt/vocabulary/course/auth producers; this service does not own those workflows.
- Build from root: `dotnet build services/gamification-service/gamification-service.csproj`.
- No dedicated test project exists; consumer tests should cover duplicate delivery and XP/notification state using isolated persistence.
