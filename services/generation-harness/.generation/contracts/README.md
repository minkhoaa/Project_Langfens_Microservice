# Canonical question-type contract v1

**Source of truth:** [`question-types.v1.schema.json`](./question-types.v1.schema.json)

This is the versioned specification for the **19 current objective IELTS platform types**. It consolidates the existing backend contracts/graders, FE admin contracts and source audit. It does not start generation, change a backend DTO, migrate existing exams, or automatically replace a consumer's validator.

## Usage boundary

This directory contains passive contracts and synthetic [test vectors](test-vectors/README.md), not a loaded extension. `question-types.v1.schema.json` is the only authoritative schema; its embedded `x-langfens.registry` and `x-langfens.semanticRules` are normative.

No Reading tools, policy, guards or custom orchestration are installed by these assets. Structural validation does not execute semantic rules or establish actual-.NET grading parity. Historical reference observations and schema consumer-gap metadata are not assertions about a later consumer revision.

## Entry points

| Entry point | Representation |
| --- | --- |
| Schema root / `$defs/<QUESTION_TYPE>` | Private authoring Question; 19 literal-type specializations |
| `$defs/StudentQuestion` | Allowlisted student/blind-solver artifact; no answer keys or explanations |
| `$defs/SingleChoiceSubmission` | One selected persisted option UUID |
| `$defs/MultipleChoiceSubmission` | Multiple selected persisted option UUIDs |
| `$defs/TextSubmission` | Textual wire answer; parse JSON for completion/matching/flow |
| `$defs/ClearSubmission` | Explicit clearing of both selection and text state |
| `$defs/*AnswerValue` | Decoded answer value, selected through `x-langfens.answerFamilies` |
| `x-langfens.registry` | Exhaustive type → schema/family/presentation/semantic-rule mapping |
| `x-langfens.semanticRules` | Mandatory cross-field and consumer-validation requirements |

Use **JSON Schema Draft 2020-12**, including `unevaluatedProperties`, `contains`, `minContains` and `maxContains`. Enable UUID format checking for submissions. Do not silently downgrade to an older JSON Schema dialect or interpret this as TypeBox code.

The `x-langfens` section is machine-readable specification metadata. JSON Schema validators do **not** execute its semantic rules. Thus structural PASS alone is **never** full validation or compatibility PASS.

## Representations are deliberately separate

- Private authoring IDs may be stable local IDs or existing UUIDs. Every Question has `sectionId`; `groupId` is optional because backend membership is optional. Persisted UUID mappings are required before admin/submission adapters run. Never fabricate database identities.
- Optional fields are omitted, not `null`. A legacy import adapter must diagnose nullable/unused fields explicitly; do not blindly remove unknown data or invent keys.
- Each type permits only its own grading family. Matching options have `isCorrect: false`; correctness is in private `matchPairs`. Non-option completion/short/flow Questions have `options: []`.
- Canonical matching pairs are exactly `[gradingKey, displayLabel]`, including classification. Existing one-element classification examples are legacy, not a special canonical exception. The current grader accepts **both** array elements; this specification does not change that behavior.
- Student projection is built by allowlist, not by spreading the private object. Preserve public media/banks and input identities; remove correctness, keys, explanations, model answers, evidence and reviews. Never use a private example to fill missing public targets.
- `TextSubmission.textAnswer` is plain text for short answer; for completion/matching/flow it is serialized JSON whose decoded value must be separately validated and joined to the actual Question. Partial autosaves and completed submissions need different completeness checks.
- To clear an answer, send `selectedOptionIds: []` and `textAnswer: ""`; absence/null is not a clear command.

## Deliberate authoring policies

Policies stronger than today's admin validation are listed in `x-langfens.canonicalPolicyBeyondBackendValidation`. They are **new-authoring requirements**, not claims that all historical rows already follow them. Examples: explicit `[N]` markers, complete visible matching targets, matching distractors, image alt text, accepted texts alongside regexes, and exact truth-label casing.

A normalizer/importer must not turn historical renderer workarounds into canonical rules. In particular:

- Statement `23` stays key `"23"`, never `"22"`.
- Blank IDs may start above 1 and need not equal Question.idx. Group bounds count Question rows, not blanks.
- Option images remain on options; a redundant question image is not required.
- `FLOW_CHART` means **platform process ordering**. Standard IELTS flow-chart blank completion remains a separate unsupported capability.
- `SUMMARY_COMPLETION_BOX` and `CHOOSING_TITLE` from the old generation-service family enum are not current platform wire types. No unknown-type fallback is permitted.
- Word-list completion must not silently replace canonical paragraph matching. Current wordList transport/admin limitations remain blockers.

## Verification order

1. Validate the private Question against this root schema.
2. Execute every registry semantic rule: IDs/ordinals, key-marker/target parity, banks, media and layout, privacy, and answer shape.
3. Build an explicit ingestion plan for current DTOs. The private object is **not** an admin request; options are separate and some fields cannot currently be persisted through those endpoints.
4. Project/validate the student artifact; compare the actual HTTP/proto/legacy transport with a transport-specific adapter.
5. Verify actual renderer inputs and actions: correct, incorrect, partial, empty, cleared and restored answers.
6. Run the resulting answers through actual .NET AnswerValidator/key builder/graders. JavaScript/Python regex or grading simulation is not .NET parity.
7. Record independent IELTS semantic review separately. Compatibility is not pedagogical correctness, publication or deployment permission.

Example structural validation, using an available Draft 2020-12 validator (no service startup):

```python
import json
from jsonschema import Draft202012Validator, FormatChecker

schema = json.load(open("question-types.v1.schema.json"))
Draft202012Validator.check_schema(schema)
private_validator = Draft202012Validator(schema, format_checker=FormatChecker())
# private_validator.validate(private_question)

student_schema = {
    "$schema": schema["$schema"],
    "$defs": schema["$defs"],
    "$ref": "#/$defs/StudentQuestion",
}
student_validator = Draft202012Validator(student_schema, format_checker=FormatChecker())
# student_validator.validate(student_question)
```

## Evidence limits and integration status

The exact reference exam was located by public application GET: **5 sections, 25 Questions, 65 Options, 18 types**. `SUMMARY_COMPLETION` is absent. Persisted private keys, raw Section/Group identities and production deployment provenance remain blocked/unverified. Public group IDs were synthesized and changed between requests. Historical FE/Python mirror examples differ from the running reference and are not a current DB export.

No production answer keys or examples are embedded here. `x-langfens.referenceEvidence` records the observation, and `knownConsumerGaps` records its limits. Existing FE, harness, backend and old generation-service schemas are **not automatically synchronized** by creating this file.

A later consumer integration must pin `contractVersion`, implement the semantic rules and produce revision/hash-bound test evidence before claiming compatibility. Breaking type/field/key/scoring changes require a new major version; do not silently redefine v1.
