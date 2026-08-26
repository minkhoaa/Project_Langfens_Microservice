# @langfens/question-schema

Single source of truth (SSOT) for the 21 Langfens question type payloads and
their correct answers, expressed as [Zod](https://zod.dev) schemas.

The package is derived directly from the canonical JSON Schema files at
`Project_Langfens_Microservice/docs/schemas/`. The mapping is one-to-one: each property,
constraint, enum, regex, `uniqueItems`, `additionalProperties: false`, and
`required` array in the JSON becomes the corresponding Zod construct.

## What this is

- **21 payload schemas** (one per question type) covering every shape the BE,
  FE, and authoring tools need to read or write.
- **21 correct-answer schemas** mirroring `CorrectAnswer` in the JSON.
- **Discriminated unions** (`QuestionPayloadSchema`, `AnswerSchema`) keyed by
  the `type` field, so consumers never have to write a manual switch.
- A label registry, authoring metadata, and deprecated-alias schema
  (`MCQ_SINGLE`, `MCQ_MULTIPLE`) preserved for backward compatibility.
- A strong `LocalIdSchema` regex used for every per-question inner id
  (option, gap, paragraph, node, edge, …).

## Usage

```ts
import {
  QuestionPayloadSchema,
  AnswerSchema,
  QUESTION_TYPES,
  payloadSchemas,
} from '@langfens/question-schema';
import { z } from 'zod';

const raw: unknown = JSON.parse(await fs.readFile('question.json', 'utf8'));

// Discriminated union — picks the right payload schema by `type`.
const payload = QuestionPayloadSchema.parse(raw.payload);

// Companion discriminated union over correct-answer shapes.
const answer = AnswerSchema.parse(raw.correctAnswer);

// Iterate every supported type:
for (const slug of QUESTION_TYPES) {
  console.log(slug, payloadSchemas[slug]?.description);
}

// Compose into a full question envelope:
const QuestionEnvelopeSchema = z.object({
  type: z.string(),
  payload: QuestionPayloadSchema,
  correctAnswer: AnswerSchema,
  rubric: z.unknown().optional(),
});
```

```ts
// Sub-export import path:
import { QUESTION_TYPE_LABELS } from '@langfens/question-schema/labels';
```

## How to add a new question type

1. Add the JSON Schema file to `Project_Langfens_Microservice/docs/schemas/` and register the new
   slug in `_registry.json`. Follow the existing `oneOf` block in
   `_index.schema.json`.
2. In `src/types.ts`:
   - Add `xxxPayloadSchema` extending `BasePayloadSchema`.
   - Add the schema to the `payloadSchemas` array (preserves declaration order).
   - Add a `PayloadSchemaBySlug[SLUG]` entry.
3. In `src/answers.ts`:
   - Add `xxxAnswerSchema`.
   - Add it to the `AnswerSchema` discriminated union.
   - Add an `AnswerSchemaBySlug[SLUG]` entry.
4. Update `src/discriminator.ts`:
   - Add the slug to `QUESTION_TYPES` (and to `AnyQuestionType` automatically).
   - Update `QUESTION_TYPES.length` test if you keep count tests.
5. Update `src/labels.ts` and `src/metadata.ts` so the new slug appears in
   `QUESTION_TYPE_LABELS` and `QUESTION_TYPE_METADATA`. The runtime asserts at
   module load will fail otherwise.
6. Add a minimal valid sample in `tests/samples.ts`.
7. Add at least one edge-case test in `tests/edge-cases.test.ts` that exercises
   a constraint unique to the new type (e.g., a `maxItems` boundary).
8. Run `npm run build && npm test`. Both must pass.

## Security note: `FLOW_CHART_COMPLETION`

## OpenAPI emission

`npm run gen:openapi` emits an OpenAPI 3.1 document from the SSOT Zod
schemas to `dist/openapi/question-schema.openapi.json` and
`dist/openapi/question-schema.openapi.yaml`. The document is the wire
contract consumed by
`services/_shared/Shared.PublicContracts/nswag.json` (Phase 2 of the
SSOT wire-up), which in turn produces
`Generated/QuestionSchema.cs` for the BE.

Components emitted:

- 21 per-type payload schemas (`<Slug>Payload`, e.g.
  `MultipleChoiceSinglePayload`).
- 21 per-type answer schemas (`<Slug>Answer`).
- 5 envelope schemas (`Envelope_FlowChart`, `Envelope_FlowChartCompletion`,
  `Envelope_MultipleChoiceMultiple`, `Envelope_MatchingHeading`,
  `Envelope_MatchingInformation`) — one per Zod `superRefine` variant.
- One discriminated union envelope `QuestionEnvelope` with
  `discriminator.propertyName: 'type'` mapping each slug to its
  payload component. The `payload` and `correctAnswer` properties are
  `anyOf` over every per-type schema so downstream generators (NSwag)
  emit polymorphic classes.

The script also runs as the last step of `npm run build`, so the OpenAPI
document stays in lock-step with the Zod source.


The package ships with a roundtrip parity check that proves the Zod
package stays in lock-step with the JSON Schema docs in
`Project_Langfens_Microservice/docs/schemas/`.

```bash
npm run parity
```

Runs **`86` cross-layer checks** across 6 phases:

1. **Per-type parity** — a valid sample must be accepted by both Ajv
   (against the dereferenced JSON) and the corresponding Zod schemas;
   a discriminator-swapped invalid sample must be rejected by both.
2. **Discriminator match** — the `const` value in the JSON
   `type` field equals the literal expected by Zod for all 21 types.
3. **`FLOW_CHART_COMPLETION` security invariant** — both layers reject
   the four forbidden payload/answer mutations and accept a well-formed
   sample.
4. **`LocalId` pattern** — both layers reject ids >16 chars and ids with
   spaces; both accept the 16-char boundary id.
5. **`maxItems` enforcement** — 14 boundary cases (8/20/12/24/50/etc.)
   uniformly accepted/rejected by both layers.
6. **`BasePayload` field set** — Zod and JSON expose the same properties
   (including `provenance`) and the same `required` set.

Expected output, last line:

```
[done] 86 checks, 86 pass, 0 fail
```

Exit non-zero if any check fails. A full per-check report is written to
`parity-results.json` next to this README.

Run `npm test` (125 vitest cases across 3 files) for the in-package test
suite, and `npm run build` to refresh `dist/` before re-running parity.
