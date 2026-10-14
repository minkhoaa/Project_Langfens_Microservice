# Detailed Reading, Grammar and A/B/C generation flows

## Reading production V2

Admin request → permission/profile/source pins → worker lease → SourcePack + provenance → evidence claims → fixed Reading blueprint → 3× Passage Loop → six question-group candidate loops (blind solve, adversary, type check, bounded repair and selection) → 3× Section Loop → Paper Loop cross-section checks → accepted artifact closure → .NET atomic Draft commit → Admin Editor and manual publication → safe student payload.

Strict task-level postconditions: S1 TFNG×7 + Sentence Completion×6, S2 MCQ Single×6 + Summary Completion×7, S3 YNNG×7 + Short Answer×7; exactly Q1–Q40; each passage 720–915 words, sum 2150–2750; no stale evaluation or internal answer leak.

## Reading research task

Frozen research request → verified source/evidence → bounded 1-passage blueprint → Passage Loop → 1–2 question groups with explicit count/type constraints → section-level semantic validation → neutral research result with preserved private answer ref + usage. Partial/error output and status remain visible to external scoring. **No synthetic full Draft Exam.**

## Grammar task

Authorized rule request → KnowledgeRetrievalPort → canonical GrammarRulePack (scope, usage, exceptions, examples, provenance, content hash) → candidate grammar item(s) → private proposed answer/evidence → reviewer + separate grammar blind solve → answer/rule/distractor checks → scoped repair and fresh validation → durable research item, or admin-reviewable production draft when a strict policy actually supports it. Failure/uncertainty preserves diagnostic outcome without declaring gold.

## Independent research A/B/C

- A: one *declared* direct generation path, not post hoc filtered to successes.
- B: same foundation model generates, critiques its own output and performs bounded sequential revision; B's own score is trace only.
- C: production-derived multi-agent roles with defined in-loop constraints, blind solver and bounded repair; internal PASS is trace only.
- Each arm receives the identical frozen task/source/level/blueprint and compatible resource settings; prompts differ by method and are versioned. Each emits neutral GenerationResult irrespective of success.
- External evaluator runs after generation: first answer-free solve, then compare proposed answer, then independent adjudication/gold scoring under access partition. Config ID/internal verdict must not contaminate scoring input. Partial evaluable outputs assessed separately; request-level failure always counts in denominator.

## Data custody

`SourcePack`/`GrammarRulePack` → generation candidate/proposed answer (private) → `SolverView` (answer free) → blind solve → `AnswerVerificationView` (answer now allowed) → sealed `GoldReferenceView` (restricted scorer only) → `EvaluationResult` and anonymized analysis. No backwards leak to candidate generation.
