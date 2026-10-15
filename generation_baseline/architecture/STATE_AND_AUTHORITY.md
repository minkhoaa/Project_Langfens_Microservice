# State machines and decision authority

## Distinct dimensions

- ExecutionStatus: `PENDING`, `RUNNING`, `COMPLETED`, `FAILED_VALIDATION`, `FAILED_RUNTIME`, `TIMED_OUT`, `CANCELLED` (persisted legacy names can differ; adapter must preserve semantics).
- OutputAvailability: `NONE`, `RAW_ONLY`, `PARSEABLE`, `NORMALIZED`; independent of execution status.
- EvaluationVerdict: `PASS`, `FAIL`, `UNCERTAIN`, or `NOT_RUN` (the last is an execution status for a check, never a false PASS).
- EvidenceStatus: `TARGET_SPEC`, `UNKNOWN`, `NOT_RUN`, `VERIFIED`, `PARTIAL`, `BLOCKED`, `FAILED`.

## Proposals vs commits

Reviewer issue (INFO/WARNING/BLOCKING) → Validator constraints/evidence and solver finding → Coordinator policy decision (`CONTINUE`, `REPAIR`, `ABORT`, `PROPOSE_COMMIT`) → .NET authoritative transition after hash/lease/policy/dependency checks. Reviewer may flag BLOCKING; it may not write accepted state. Validator cannot directly commit. Invalidated/stale eval cannot justify commit.

## Production and research invariants inventory

Every invariant in this inventory possesses a stable unique ID (`INV-01` through `INV-15`), defined scope, accountable owner layer, explicit failure behavior / prohibited transitions, required proof class, and target verification gate.

| Invariant ID | Boundary / Topic | Normative requirement | Prohibited transition & failure behavior | Owner layer | Proof class | Verification Gate |
|---|---|---|---|---|---|---|
| `INV-01` | Strict full-paper Reading | 3 sections, 6 groups, exactly 40 continuously numbered questions (S1: 7 TFNG + 6 sentence; S2: 6 MCQ + 7 summary; S3: 7 YNNG + 7 short answer). | Incompatible full-paper candidate cannot transition to Draft or Accepted. Attempt to commit non-40 question full exam fails closed. | .NET Exam Service / Policy Engine | Schema / state test | RG05 |
| `INV-02` | Full-paper source & passage length | 720–915 words/passage; 2,150–2,750 total words; source eligibility (PMC CC-BY/CC0, >= 600 words on that route). | Passages outside length bounds or from ineligible sources are rejected at ingestion/synthesis; cannot be accepted. | Ingestion / Passage Synthesizer | Content audit & length check | RG01, RG05 |
| `INV-03` | Historical 3×40 evidence separation | 3 historical full papers / 120 questions are reported acceptance; distinct from 1-passage research units. | Historical acceptance cannot be claimed as current verified code PASS without fresh test execution. | Historical Evidence Custodian | Documentation & audit record | RG00, RG01 |
| `INV-04` | Authoritative ownership | .NET exam-service / PostgreSQL owns durable Job, Run, Artifact, Operation, Accepted Heads, Checkpoint, and Exam state. | Python AI service and subagents cannot mutate PostgreSQL graph directly. Direct DB write bypass is forbidden. | .NET Storage Authority | AuthZ / API isolation test | RG02 |
| `INV-05` | Hash and closure integrity | Acceptance requires fresh content-hash-bound evaluations, valid source provenance, and dependency closure. | Stale or mismatched evaluation hashes invalidate acceptance; commit blocked if referenced artifact hashes diverge. | .NET Closure Engine | Hash fault injection | RG02, RG08 |
| `INV-06` | Fencing and recovery | Worker lease token/epoch and compare-and-swap (CAS) version checked on every commit; idempotent retries. | Stale worker or expired epoch cannot commit (CAS failure). Cancelled or superseded job execution rejected. | Leased Worker / Job Manager | Concurrency / CAS test | RG02, RG08 |
| `INV-07` | Draft persistence atomicity | Strict full-paper transaction persists complete Exam/Section/Group/Question graph or none; lost ACK resolves same ExamId. | Partial graph write rolls back entire transaction. Lost-ACK retry returns existing ExamId, never duplicates. | Storage / EF Core Context | Transaction rollback test | RG02, RG05 |
| `INV-08` | Role separation & issue blocking | 4 logical roles (Coordinator, Generator, Reviewer, Validator); BLOCKING issues cannot be ignored before acceptance. | Unresolved BLOCKING reviewer issues block transition to accepted head. AI roles cannot self-authorize commit. | Coordinator / Orchestrator | Issue routing test | RG02 |
| `INV-09` | Answer and gold privacy | SolverView excludes proposed/generated/gold answers and internal verdicts; AnswerVerificationView built only after solve. | Leakage of answers or internal verdicts into student or solver views causes immediate schema validation failure. | Security / View Projection | Leakage canary test | RG02, RG03 |
| `INV-10` | Independent evaluation isolation | Arms A, B, C receive identical paired inputs and same downstream rubric; judge is blinded to arm identity and traces. | Arm labels, execution traces, or internal generator PASS leaking to judge voids evaluation validity. | Independent Research Evaluator | Blinded view test | RG03, RG04, RG10 |
| `INV-11` | Research isolation from production | Research exercise units and ablation candidates cannot publish through any production route. | Research artifact marked with publication request is rejected. Research ablation never bypasses hash or lease fencing. | Policy Engine / Publish Guard | Negative publish test | RG02, RG12 |
| `INV-12` | Human publication & learner ACL | Explicit authorized human editorial approval creates immutable PublishedSnapshot; attempts enforce learner ACL. | Automated publish is forbidden. Unreleased exams remain inaccessible. Attempt binds frozen snapshot ID. | Admin Gateway / Attempt Service | ACL & snapshot test | RG12 |
| `INV-13` | Provider pinning & no silent fallback | Pinned provider/model (MiniMax-Text-01) obeyed; finite repairs; per-request token/time ceilings enforced. | Pinned model failure cannot silently fall back to unpinned alternative. Budget ceilings cannot be bypassed. | LLM Client / Routing Port | Fail-closed fallback test | RG01, RG09 |
| `INV-14` | Failure-inclusive accounting | ExecutionStatus, OutputAvailability, EvaluationVerdict independent; failures/partials stay in assigned denominators. | Failed/timed-out assignments cannot be omitted from evaluation denominators; unknown usage cannot be zeroed out. | Campaign Analytics Lead | Accounting integrity test | RG07, RG10, RG11 |
| `INV-15` | Trust boundaries & data minimization | Authentication, tenant isolation, data minimization, SSRF protection, and license compliance hold at all boundaries. | Unsanitized external URL access blocked (SSRF). Cross-tenant access or unlicensed source usage rejected. | Gateway / Security Middleware | SSRF & security test | RG01, RG02 |

### Invariant enforcement and non-waiver rules
1. **No research policy weakens durability:** Ablation or research experimentation may omit optional prompt/generation stages, but NEVER exempts underlying authentication, cryptographic hashing, reference closure, lease fencing, or atomic transactions.
2. **No research artifact publication:** Under no circumstances may an experimental or research artifact enter the production `PublishedSnapshot` graph or become student-visible.
3. **Fail-closed default:** Any invariant violation results in immediate rejection, rollback, or blocked transition; silent PASS or fallback is strictly prohibited.
