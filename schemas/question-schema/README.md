# @langfens/question-schema

Single source of truth (SSOT) for the 21 Langfens question type payloads and
their correct answers, expressed as [Zod](https://zod.dev) schemas.

The package is derived directly from the canonical JSON Schema files at
`docs/standards/schemas/`. The mapping is one-to-one: each property,
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

1. Add the JSON Schema file to `docs/standards/schemas/` and register the new
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

After the security fix, accepted answers for flow-chart-completion gaps live
**only** in `CorrectAnswer.gapAnswers` as an object bundle
(`{ acceptedTexts: string[], acceptedRegexes?: string[] }`). The payload
`gaps[]` entries MUST NOT carry `acceptedTexts` or `acceptedRegexes`. The
schemas enforce this — see `tests/edge-cases.test.ts` for regression tests.
