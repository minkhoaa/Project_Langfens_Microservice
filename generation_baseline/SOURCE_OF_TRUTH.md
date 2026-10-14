# Normative source of truth — precedence, status and fixed invariants

## Authority and precedence

1. User-approved unchanged KLTN topic, research scope, RQ2 and explicit safety constraints govern goals.
2. This document and `MASTER_PROPOSAL.md` govern feature invariants and cross-phase behavior.
3. `AGENT_PIPELINE.md` governs internal agent execution without overriding feature, security or scientific constraints. `contracts/CONTRACT_REGISTRY.md`, `research/RQ2_PROTOCOL.md` and `research/RUBRIC.md` govern their respective semantics.
4. An individual `prompt-phase-XX.md` defines the bounded phase execution and acceptance; a `prompt-sprint-XX-YY.md` narrows only its named sprint without weakening any higher rule.
5. Audited current source establishes **existing implementation reality**, not a license to silently change target requirements. Conflicts require explicit documented decisions; unknowns remain UNKNOWN.
6. Historical handoff is background evidence only, not an instruction to clean the source or adopt another orchestration workflow.

This baseline's artifact schemas are **target interfaces**, not proof of the existing code's wire format. A different concrete DTO name is acceptable if an explicit tested mapping preserves semantics and compatibility.

## Pinned product/research truth

- Reading V2: full-paper generator historically uses 3 sections, 6 question groups, exactly 40 continuously numbered questions. Section 1: TFNG 7 + Sentence Completion 6; Section 2: MCQ Single 6 + Summary Completion 7; Section 3: YNNG 7 + Short Answer 7. Target historical passage words 720–915 per passage and total 2,150–2,750. Enforce these for strict full-paper V2; **do not blindly impose 40 questions on the smaller research unit**.
- SourcePack extraction/provenance/licensing and applicable source-specific restrictions must hold (historical Europe PMC CC-BY/CC0 and at least 600 original source words on that route); this is a source-specific rule, not automatically a universal one.
- .NET exam-service/PostgreSQL owns authoritative Job/Run/Artifact/Operation/Accepted Heads/Checkpoint/Exam state. Python AI service persists via authenticated internal APIs; no direct Python mutation of authoritative exam graph.
- Accepted content requires fresh content-hash-bound evaluations, valid reference closure and policy-compliant accepted-head transitions. Lease/epoch fencing, retry/idempotency, cancellation and EF transaction atomicity are invariants.
- Four **logical** agent roles, not necessarily four processes: COORDINATOR decides route/repair proposal, GENERATOR creates/repairs content, REVIEWER diagnoses/raises issues, VALIDATOR checks required conditions; only authoritative storage commits state. BLOCKING reviewer issues cannot be ignored before acceptance.
- SolverView cannot include generated/proposed/gold answers or internal verdicts. AnswerVerificationView is constructed only **after** the blinded solve. GoldReferenceView is restricted to research scoring/adjudication, never fed to generator/solver.
- Research output must never be published by any route. Disabling optional semantic stages for RESEARCH_ABLATION must preserve source license/auth, hashes, dependency closure, lease fencing and accurate NOT_RUN records. `publish_eligible=false` alone does not satisfy enforcement.
- `ExecutionStatus`, `OutputAvailability` and `EvaluationVerdict` are independent. A failed run with a parseable output can be assessed; unevaluable output remains in assigned-request denominators. Never synthesize a score or substitute missing accounting with zero.
- Provider pinning applies to the actual model used; no fallback for pinned MiniMax-only runs. Historical approved uncapped cumulative application budgets **do not** remove per-request limits, finite repairs, cancellation, provider quotas, accounting or consent requirements.
- Manual Admin approval produces immutable PublishedSnapshot; student payload excludes answers/evidence/private metadata until authorized release; learner attempts bind the published version and enforce ACL.

## Quality and science

- Task validity (wrong answer, multiple valid answers, unsupported claim) is a hard blocker even when clarity/fluency scores are high.
- Judge calibration, evaluator holdout and FINAL_EVAL are disjoint from prompt-tuning data by provenance/source-family as defined in the research protocol.
- A direct generation, B same-model sequential self-review and C separated multi-agent are **experimental arms** on paired inputs and the same independent evaluation rubric. C's internal PASS never counts as independent PASS.
- Report all assigned requests, failed and partial outcomes, uncertainty and real usage; pre-register primary outcome and analysis before final campaign.
- Do not equate a 100% passing test suite with guaranteed accuracy of future generated content; no mandatory outcome that C "wins".

## Status vocabulary and truthfulness

`TARGET_SPEC`, `UNKNOWN`, `NOT_RUN`, `VERIFIED`, `PARTIAL`, `BLOCKED`, `FAILED`, `PASS` are distinct. `PASS` for a gate requires executed, source/config-bound evidence and its mandatory criteria. `NOT_RUN` is never silently upgraded. A source snapshot that differs from evidence build must be disclosed.

**No side effects authorized by this package:** do not infer permission to push, deploy, migrate production data, publish exams, rotate credentials, destroy docs or run an expensive live research campaign merely because a phase is described.

## Native agent workflow authority

Every phase and sprint prompt is an executable **coding-agent task instruction** in addition to an immutable feature specification. Each embeds the autonomous inspect → small plan → minimal implement → positive/negative/edge/regression verify → durable checkpoint → gate close cycle from `AGENT_PIPELINE.md`. No external planning/execution skills are prerequisites. Successful offline package checks never upgrade source-verification status.
