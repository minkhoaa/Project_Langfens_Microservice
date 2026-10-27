# Gamification service
XP, achievements, streaks and notifications in `GamificationDbContext`.

- `Features/Consumers/` handles attempt completion, card review, lesson completion and user creation.
- Consumers use `AddConsumer` + `ConfigureEndpoints`; preserve generated queue names and producer event compatibility.
- Do not assume exactly-once XP awards: verify duplicate delivery and notification behavior explicitly.
- `Features/GamificationService.cs` and `NotificationService.cs` expose projections under local authorization policies.
- Consumer checks need isolated persistence; test repeated events and unauthorized projection access.
