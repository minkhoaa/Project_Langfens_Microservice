# Gamification service
Owns XP, achievements, streaks and notifications in `GamificationDbContext`.

- `Features/Consumers/` handles attempt completion, card review, lesson completion and user creation.
- Consumers use `AddConsumer` + `ConfigureEndpoints`; retain queue naming and producer event compatibility.
- Check duplicate delivery explicitly: do not assume handlers provide exactly-once XP awards.
- `Features/GamificationService.cs` / `NotificationService.cs` expose projections under local authorization policies.
- No dedicated tests; consumer verification needs isolated persistence and duplicate-event/notification cases.
