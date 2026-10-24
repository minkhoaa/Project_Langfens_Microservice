# Shared packages
Cross-service bootstrap and wire contracts; build/test affected consumers after changes.

- `Shared.PublicContracts/`: DTOs, events, string-valued `QuestionType` constants and paper-wide normalization; preserve persisted/wire values.
- `Shared.Grpc/Contracts/exam_internal.proto` generates both client/server types at build; edit the proto, not `obj/` output.
- `Shared.Bootstrap/`: JWT/JSON/CORS/Kestrel; `Shared.Security/`: roles/scopes/claims; `Shared.ServiceDefaults/`: telemetry/health/resilience.
- Boundary DTOs use immutable records/init properties; preserve serialization/nullability and endpoint-specific auth policies.
- Question-type changes span exam delivery and attempt grader registrations; migrations are only for persisted schema changes.
- Normalization makes question indices paper-wide and 1-based; group bounds follow questions, without renumbering option/group indices.
