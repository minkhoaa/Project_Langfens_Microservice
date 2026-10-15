# Research extension — canonical target proposal and comprehensive behavior

## Thesis alignment

**Vietnamese title (UNCHANGED):** Phát triển hệ thống học tiếng Anh tích hợp trợ lý AI hội thoại và tự động tạo nội dung bằng đa tác nhân.

**English title (UNCHANGED):** Developing an English Learning System Integrated with Conversational AI Assistant and Multi-Agent Automated Test Generation.

The submitted outline explicitly centers RQ1 (phoneme-level Speaking) and RQ2 (multi-agent content generation). **This baseline addresses RQ2 and the relevant product integration only.** It must not assert RQ1 speaking/STT/GOP milestones have been fulfilled.

### Proposal section linkage and traceability

Based on the approved repository summary and reconciled proposal definitions:
- **Section 2.2.e:** Multi-agent exercise generation and verification with bounded review/repair for passage-based Reading and contextual Grammar exercises.
- **Section 2.2.f:** Product integration covering learner attempts, grading, feedback delivery, and owned learning progress history.
- **Section 3.b:** Explicitly defines the two representative Multi-Agent content groups: (1) Passage-grounded Reading questions, and (2) Grammar exercises with reference answers. Fully consistent with Sections 2.2.e, 2.3 (RQ2), 4.e, and 4.g.
- **Section 4.e:** System methodology specifying task decomposition across specialized roles (Coordinator, Generator, Reviewer, Validator) and bounded repair loops.
- **Section 4.g:** Evaluation methodology specifying 25–40 benchmark tasks per domain across experimental arms, paired statistical analysis, and independent partially blind human review.

*Provenance note on original proposal source:* The original submitted KLTN proposal document is unavailable in the repository; original-source verification remains `NOT_RUN`. Section 3.b mapping is recorded as user-confirmed (defining the two representative Multi-Agent content groups: Passage-grounded Reading questions and Grammar exercises with reference answers), consistent with Sections 2.2.e, 2.3 (RQ2), 4.e, and 4.g.
### Research question definition

**RQ2:** Does task decomposition across specialized agents for generation, semantic review, validation and bounded repair improve exercise quality relative to a single LLM (Arm A) and a single-LLM sequential self-review (Arm B)? What are the latency and cost tradeoffs?
## End-to-end learner/product objective

Authorized admin or research actor chooses task domain, source(s)/rule(s), learning level, blueprint, model and policy. For Reading, verified sources lead to grounded passages and questions; for Grammar, retrieved, versioned grammatical rules lead to exercises and justified reference answers. Both have recoverable execution and independent semantic checking. Production candidate accepted by authoritative service becomes **Draft**, with human editorial approval preceding immutable publish. A student receives an answer-free versioned payload, submits attempts, obtains grading/feedback according to release policy and sees progress aggregated from owned attempts.

Research A/B/C is **separate**: identical frozen request specs through three distinct generating configurations; each final/partial/failed output mapped to neutral, policy-safe research result and scored by a frozen downstream evaluator that cannot see configuration/internal verdict/gold. Final paired analysis includes every assigned outcome and honest uncertainty.

## Historical Reading V2 pipeline (preserve, audit actual code)

1. Authenticated frontend/gateway and .NET API create Job/Run; pin source/config/model/prompt/runtime profile.
2. Leased worker ingests authorized source into `SourcePack` with identity, license, normalized content and evidence claims.
3. Blueprint fixes required slots and groups (S1 7 TFNG+6 sentence, S2 6 MCQ+7 summary, S3 7 YNNG+7 short answer).
4. Passage Loop generates, evaluates fidelity/qualifiers/length/structure, records issue, repairs boundedly and accepts hash-bound passage artifacts.
5. Question Candidate Loop generates options/answers/evidence; validators, independent blind solver and adversary assess errors, ambiguous answers, acceptable verbatim responses and uniqueness; selection/backtracking forms groups.
6. Section Loop validates/coheres passage and accepted groups, commits accepted heads and dependency closure.
7. Paper Loop assembles current heads, checks duplicates, leakage, answer monotony, paper structure and content-hash closure; scoped repairs invalidate related verdicts.
8. .NET final validation atomically persists one Draft Exam/3 sections/6 groups/40 questions and completes Job/Run. Failure rolls back, ACK-loss replays idempotently to existing ExamId.
9. Admin Editor reviews Draft; publication is explicitly separate. Student payload omits private answers/metadata. Feedback can be curated offline RAW→ANNOTATED→REVIEWED→CURATED.

The legacy three-paper/120-question acceptance is *reported evidence*, not an independently rerun current-code test. Historical operational canary and rollback remain unverified.

## Research Reading unit

A bounded exercise consisting of **one evidence-grounded passage + one or two question groups** with a fixed number/type per request. It must use genuine V2 components where feasible but must not create/fake an entire 40-question Draft Exam. It supports completed, invalid, partially parseable, timed out and cancelled runs with references, outputs and accounting. Passage size, group count and semantic criteria are predeclared for this **research task**; historical full-paper constraints are not blindly transferred when the task has a different scope.

## Grammar exercise unit

Task describes topic/rule target, level, context, question type and output count. `KnowledgeRetrievalPort` supplies a provenance-checked `GrammarRulePack` with examples, applicability and exceptions. Generation produces candidates and proposed answers with context/evidence; blind solver never receives proposal. Verifier checks rule compatibility, alternative legitimate answers, MCQ distractors, explanations and format. Independent research gold is validated separately; retrieved source text is **not** proof a newly generated answer is correct. Unsupported, ambiguous or no-evidence cases are rejected/abstained rather than fabricated.

## Roles and ownership

| Role | Logical capability | Owns | Explicitly does NOT own |
|---|---|---|---|
| COORDINATOR | Blueprint planner, loop orchestration, issue/repair routing | decisions/proposals and runtime progression | authoritative accepted commit |
| GENERATOR | passage/question/grammar generator and scoped content repair | candidate output/proposed answer | gold reference or acceptance state |
| REVIEWER | semantic/adversarial/pedagogical critique | issues, severity, evidence | final commit/secret gold |
| VALIDATOR | schema/rule/hard grounding and blinded solving | verdict + evidence/violations | direct DB mutation or repair |
| .NET authority | durable checkpoint/storage owner (not an AI agent) | lease fencing, accepted heads, atomic state | silently bypassing failed validators |

## Definition of successful research

- Verified executable source-to-contract mapping; strict legacy Reading V2 regression and isolated research policies.
- Qualified independent evaluation calibrated on labels, sealed holdout and documented false accept/reject/abstain.
- 25–40 **Reading requests** plus 25–40 **Grammar requests**; each preassigned A/B/C (150–240 arm assignments before optional repeats), with frozen common model/inputs, run status, costs and output regardless of success.
- RQ2 report presents request-level end-to-end valid-pass rates, quality of evaluable output, per-type errors, token/calls/repair/time/cost and paired uncertainty; includes blinded human review subset; reports limitations without assuming C is always better.
- Admin publish→immutable student snapshot→attempt→grading→history is secured; RQ1 remains an independent evaluation requirement for the overall thesis.

## Explicit non-goals and safety boundaries

1. **RQ1 separation:** No evaluation or claim of phoneme-level pronunciation accuracy, Goodness of Pronunciation (GOP), speech-to-text (STT), or Speaking efficacy is derived from RQ2 exercise generation. Claiming RQ1 completion from RQ2 evidence is strictly forbidden.
2. **No production source modification:** This phase freezes requirements, authority, and traceability only; it makes no application code changes, database migrations, or infrastructure deployments.
3. **No automatic or unverified publication:** Research artifacts and unapproved candidates cannot be published to learners through any route. Publication requires explicit human editorial approval.
4. **No silent fallback or model drift:** Pinned models (e.g., MiniMax-Text-01) must not silently fall back to unpinned providers.
5. **No fabricated evidence or zero-cost accounting:** All assigned request slots (including failures, timeouts, and cancellations) must remain visible in denominators.
6. **No thesis title changes:** The Vietnamese and English thesis titles are frozen and immutable.
