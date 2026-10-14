# Administrative/editorial and learner contract

`ValidatedCandidate → Draft (Admin Editor) → Explicit Admin Publish → Immutable PublishedSnapshot(version_id) → StudentPayload(answer-free) → StudentAttempt(version-pinned) → Private Grading → Feedback release → LearningHistory/ProgressReport`.

- PublishedSnapshot immutability includes content identity and private answer mapping; editing a Draft creates a new candidate/version, not a retroactive change to an existing published attempt.
- Student DTO allowlist strips evidence, answers, solver traces, prompts, internal metadata and secrets before authorized solution-release time.
- StudentAttempt records learner/tenant, attempt_id, published_version_id, responses, submitted_at, grading version and per-question results. A later item edit cannot regrade an old attempt against a new answer key implicitly.
- Report aggregates must be recomputable from owned attempts by question type and grammar rule; report pages do not disclose another learner's data.
- Research A/B/C, negative test content, judge holdout and ablation artifacts **cannot** be published. Enforcement at service authorization, not just one `publish_eligible` boolean.
- Learning histories are product telemetry, **not** gold evaluation labels unless explicitly consented/curated through a separately governed research data process.
