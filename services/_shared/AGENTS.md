# Shared packages
Cross-service bootstrap and wire contracts; build/test affected consumers after changes.

- `Shared.PublicContracts/` owns DTOs/events and string-valued `QuestionType`; preserve persisted/wire values, serialization and nullability.
- `Shared.Grpc/Contracts/exam_internal.proto` generates client/server types; edit the proto, not `obj/` output.
- `Shared.Bootstrap/` owns JWT/JSON/CORS/Kestrel; `Shared.Security/` roles/scopes/claims; `Shared.ServiceDefaults/` telemetry/health/resilience.
- Boundary DTOs use records/init properties; question-type changes also require exam delivery and attempt grader registrations.
- Paper normalization makes question indices 1-based across the paper and adjusts group bounds, not option/group indices; retain legacy ungrouped-section adapters.
- Test normalization/contracts via `dotnet test services/attempt-service.Tests/attempt-service.Tests.csproj` from root.
