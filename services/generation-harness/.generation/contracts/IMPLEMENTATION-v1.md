# Canonical v1.0.0 executable domain profile

Normative input: [question-types.v1.schema.json](question-types.v1.schema.json), unchanged. Its historical `NOT_YET_INTEGRATED`/consumer-gap metadata is a source-audit snapshot, not a statement about today's harness or frontend. See [corrected findings and evidence](../evaluation/CONTRACT-HARDENING-AUDIT.md).

`reading/canonical.ts` executes the actual Draft 2020-12 definitions through the installed TypeBox Value engine: **19 distinct `$defs/<literal>` validators**, not enum-to-generic fallback. `canonicalValidators` binds each definition to the normative registry's semantic-rule list; every rule has an executable handler. Deterministic cross-field checks are executable; rules requiring passage judgment, image inspection, actual rendering, UUID mapping or consumer round trips explicitly emit **semantic uncertainty / UNVERIFIED**, never fabricated approval. Regex/transport/profile incompatibilities emit **unsupported-capability / BLOCKED**. This is not a complete automatic semantic adjudicator.

## Representations and native tools

The seven tool **names, original argument forms and original result status conventions** remain. New inputs are additive, mutually exclusive alternatives; supplying two targets fails, not silently prioritizes one. Legacy broad schemas are retained for VS1–VS4; their PASS is not canonical-v1 validation.

| Tool | Canonical/additive use |
|---|---|
| `get_question_spec` | Existing `{type}` public platform-reference output retained exactly for the strict-blind static-result guard. Consult the v1 registry for stronger authoring requirements. |
| `validate_question` | `{canonicalQuestion, instructionMd?, profile?}`; alternatively original `{question, profile?}` or permissive `{draft}`. No key/identity invention. |
| `validate_group` | `{canonicalGroup, profile?}` or original `{group, profile?}`. |
| `validate_exam` | `{canonicalExam, complete, requirements?:{profile}}` or original `{exam, complete, requirements?}`. Canonical section-count/40-mark rules apply only to `strict-academic`; legacy `complete:true` retains its Academic-paper meaning. |
| `verify_evidence` | Original interface retained. Span location/coverage is not entailment or proof of Not Given. |
| `check_grading_parity` | Original interface retained. `parityEvidence: SOURCE_DERIVED_JAVASCRIPT_ONLY`, `dotnetVerified:false`. Actual .NET evidence is a separate fixture receipt, not a tool claim. |
| `inspect_delivery_projection` | `{canonicalExam, projectionJson?}` or original `{exam, projectionJson?}`. Allowlist retains v1 sectionId/skill/difficulty and option media; strict-blind public schema accepts those optional public fields. Actual consumer propagation is unverified. |

Canonical groups/exams preserve **Exam → Section → QuestionGroup → Question → Option**. The standalone v1 Question still permits optional groupId; the group-first final artifact profile requires membership matching the enclosing group. IDs and ordinals are never silently repaired. No admin payload/publisher is implemented. No caller should POST the canonical object to an existing consumer.

`draft` is legacy wire-shape inspection: accepts arbitrary JSON and returns missing/malformed fields without filling them. `validForIngestion` is only legacy input eligibility, **not evidence of actual admin persistence**. For permissive canonical inspection, pass even an incomplete object as `canonicalQuestion`; it returns structural diagnostics instead of throwing. Native outer argument failures retain `INPUT_SCHEMA_INVALID`, now with TypeBox JSON pointers, expected constraints, actual shapes (not private values), and repair guidance.

## Profiles and scoring

- `platform-reference`: all 19 literals and platform all-or-nothing Question scoring; no claim that the 5-section/25-Question reference is a standard Academic paper.
- `strict-academic`: READING only; **one answer slot and one independent Question per intended mark**; complete papers require 3 Sections, 40 Questions/slots/units, passage-length warning outside 2,150–2,750 words. These are generation-profile rules, not backend contract mutations.
- The initial canonical pilot is **TFNG + single MCQ + single-slot summary completion**, 13 items. Other candidates do not acquire frontend compatibility from their type name.
- Multi-answer MCQ is BLOCKED under this one-mark profile, not rewritten into single choice. V1 MATCHING_* requires a multi-target exercise (minimum two targets), so it is likewise BLOCKED for one-slot generation. Do not silently weaken v1 or manufacture independent marks. CLASSIFICATION can be one target but still needs its own consumer evidence.
- FLOW_CHART remains platform ordering. Rejecting blank keys is intentional. Standard IELTS flow-chart completion is BLOCKED, not mapped to sentence completion.
- The legacy `PLATFORM_ONLY_TYPES` set is the selected profile's exclusion list, **not proof that official IELTS universally forbids images or any named layout**.

## Question-local repair enforcement and limits

`QuestionRepairPolicy` admits validation/revalidation only; it never executes a repair, starts a model, retries or coordinates. After the first error, at most **two revalidation submissions** are admitted. Unchanged consecutive `(code,path)` signatures stop immediately. Identity/membership/type changes and capability/semantic error blockers stop; a successful check does not erase the lineage. Stop receipts survive native session resume by replaying `validate_question` tool-result details through the public session API. State is local to each question ID; no neighboring content is rewritten.

**Important remaining boundary:** this is a validation-tool budget, not a filesystem mutation lock. Legacy group/exam validation and permissive draft inspection are read-only and do not share that question-repair lineage; changing IDs/new sessions or writing artifacts is not cryptographically linked to an original lineage. Existing workspace snapshots retain edits but do not yet gate all writes against a trusted per-question artifact hash. Do not claim tamper-proof, cross-session/cross-child repair admission. Such a pilot guarantee is **BLOCKED pending domain workspace admission integration**, not a reason to edit frozen Core/SDK/Subagents or add a coordinator.

## Offline verification

```sh
# From services/generation-harness; no remote package feeds, service startup or inference:
GENERATION_HARNESS_OFFLINE=1 node --import ./test/offline.mjs --test test/reading*.mjs
node .generation/evaluation/run-offline.mjs NEW-OUTPUT-DIRECTORY
```

The launcher includes all new contract tests even though `package.json` is outside this task's edit scope. .NET fixture tests reference actual production graders and AnswerValidator in a pure console adapter; cached NuGet packages only (`test/dotnet-contract/NuGet.Config` clears all feeds). The adapter never runs the service Program/DI host or database. Missing .NET SDK/cache is a failed prerequisite, not silently skipped coverage. Correct/wrong/empty/cleared/partial fixtures test grading only; they do not prove actual key-builder ingestion, persistence, network authorization or frontend rendering.
