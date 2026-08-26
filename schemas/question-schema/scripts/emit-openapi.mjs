/**
 * Emit an OpenAPI 3.1 document from the SSOT Zod schemas.
 *
 * Components:
 *   - 21 per-type payload schemas, registered as `<Slug>Payload`
 *     (e.g. `MultipleChoiceSinglePayload`).
 *   - 21 per-type answer schemas, registered as `<Slug>Answer`
 *     (e.g. `MultipleChoiceSingleAnswer`).
 *   - 5 envelope schemas, registered as `Envelope_<Variant>` (one per
 *     variant with cross-reference `superRefine` rules).
 *   - One discriminated union envelope `QuestionEnvelope` keyed on `type`
 *     with `discriminator.propertyName: 'type'` mapping each slug to its
 *     corresponding payload component. Its `payload` and `correctAnswer`
 *     properties are post-processed to `anyOf` over every per-type
 *     payload/answer so NSwag emits a real polymorphic class instead of
 *     falling back to `object`.
 *
 * Output:
 *   - dist/openapi/question-schema.openapi.json
 *   - dist/openapi/question-schema.openapi.yaml
 *
 * Run as the final step of `npm run build`. The OpenAPI document is the
 * wire contract used by NSwagMSharp to generate C# records for
 * `services/_shared/Shared.PublicContracts/Generated/QuestionSchema.cs`.
 */
import { mkdir, writeFile } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { OpenApiGeneratorV31, OpenAPIRegistry, extendZodWithOpenApi } from '@asteasolutions/zod-to-openapi';
import { z } from 'zod';
import { QUESTION_TYPES } from '../dist/discriminator.js';
import { PayloadSchemaBySlug } from '../dist/types.js';
import { AnswerSchemaBySlug } from '../dist/answers.js';
import {
  flowChartEnvelopeSchema,
  flowChartCompletionEnvelopeSchema,
  multipleChoiceMultipleEnvelopeSchema,
  matchingHeadingEnvelopeSchema,
  matchingInformationEnvelopeSchema,
} from '../dist/envelopes.js';

extendZodWithOpenApi(z);

const __dirname = dirname(fileURLToPath(import.meta.url));
const pkgRoot = join(__dirname, '..');
const outDir = join(pkgRoot, 'dist', 'openapi');
await mkdir(outDir, { recursive: true });

const registry = new OpenAPIRegistry();

const ENVELOPE_VARIANTS = [
  ['FlowChart', flowChartEnvelopeSchema],
  ['FlowChartCompletion', flowChartCompletionEnvelopeSchema],
  ['MultipleChoiceMultiple', multipleChoiceMultipleEnvelopeSchema],
  ['MatchingHeading', matchingHeadingEnvelopeSchema],
  ['MatchingInformation', matchingInformationEnvelopeSchema],
];

function toPascal(slug) {
  return slug
    .toLowerCase()
    .split('_')
    .map((s) => s.charAt(0).toUpperCase() + s.slice(1))
    .join('');
}

function registerPayload(slug) {
  const schema = PayloadSchemaBySlug[slug];
  const name = `${toPascal(slug)}Payload`;
  registry.register(
    name,
    schema.openapi({
      description: `Payload schema for question type ${slug}.`,
    })
  );
  return name;
}

function registerAnswer(slug) {
  const schema = AnswerSchemaBySlug[slug];
  const name = `${toPascal(slug)}Answer`;
  registry.register(
    name,
    schema.openapi({
      description: `Correct-answer schema for question type ${slug}.`,
    })
  );
  return name;
}

const payloadNames = new Map();
const answerNames = new Map();
for (const slug of QUESTION_TYPES) {
  payloadNames.set(slug, registerPayload(slug));
  answerNames.set(slug, registerAnswer(slug));
}

const envelopeNames = new Map();
for (const [variant, schema] of ENVELOPE_VARIANTS) {
  const name = `Envelope_${variant}`;
  registry.register(
    name,
    schema.openapi({
      description: `Envelope for ${variant} (payload + correctAnswer + optional rubric).`,
    })
  );
  envelopeNames.set(variant, name);
}

const discriminatorMapping = {};
for (const slug of QUESTION_TYPES) {
  discriminatorMapping[slug] = `#/components/schemas/${payloadNames.get(slug)}`;
}

const payloadRefs = QUESTION_TYPES.map((slug) => ({
  $ref: `#/components/schemas/${payloadNames.get(slug)}`,
}));
const answerRefs = QUESTION_TYPES.map((slug) => ({
  $ref: `#/components/schemas/${answerNames.get(slug)}`,
}));

// Register an envelope scaffold; we'll overwrite `payload` / `correctAnswer`
// in the post-processing step so they reference the polymorphic refs above.
const QuestionEnvelopeSchema = z
  .object({
    type: z.enum(QUESTION_TYPES).describe('Discriminator — one of the 21 canonical slugs.'),
    payload: z.unknown().describe('Per-type payload (anyOf over all 21 payload components).'),
    correctAnswer: z.unknown().describe('Per-type correct-answer (anyOf over all 21 answer components).'),
    rubric: z.unknown().optional().describe('Optional rubric sidecar.'),
  })
  .passthrough();

registry.register(
  'QuestionEnvelope',
  QuestionEnvelopeSchema.openapi({
    description: 'Discriminated union envelope for all 21 question types.',
  })
);

const generator = new OpenApiGeneratorV31(registry.definitions);
const document = generator.generateDocument({
  openapi: '3.1.0',
  info: {
    title: 'Langfens Question Schema',
    version: '1.0.0',
    description: 'SSOT Zod-derived OpenAPI document for all 21 Langfens question types and their envelopes.',
  },
  servers: [],
});

// Decorate the QuestionEnvelope component with discriminator metadata so
// downstream tooling (NSwag, OpenAPI codegen) emits polymorphic C#.
if (document.components?.schemas?.QuestionEnvelope) {
  const envelope = document.components.schemas.QuestionEnvelope;
  envelope.discriminator = {
    propertyName: 'type',
    mapping: discriminatorMapping,
  };
  // `oneOf` over every payload variant — NSwag reads this as the
  // polymorphic base class for the envelope.
  envelope.oneOf = payloadRefs.slice();
  // `payload` and `correctAnswer` are `anyOf` over the per-type schemas,
  // so NSwag generates them as the polymorphic `payload` / `correctAnswer`
  // properties rather than `object`.
  envelope.properties = envelope.properties ?? {};
  envelope.properties.payload = { anyOf: payloadRefs };
  envelope.properties.correctAnswer = { anyOf: answerRefs };
}

const jsonPath = join(outDir, 'question-schema.openapi.json');
const yamlPath = join(outDir, 'question-schema.openapi.yaml');

await writeFile(jsonPath, JSON.stringify(document, null, 2) + '\n', 'utf8');

// Hand-roll a small YAML serializer for the limited surface we emit. This
// avoids pulling `yaml` into the runtime dependency set. Property order
// mirrors the JSON document so hand-diffing stays trivial.
function toYaml(value, indent = 0) {
  const pad = ' '.repeat(indent);
  if (value === null || value === undefined) return 'null';
  if (typeof value === 'string') {
    if (/[:#\n]|^\s|\s$|^-/.test(value)) {
      return JSON.stringify(value);
    }
    return value;
  }
  if (typeof value === 'number' || typeof value === 'boolean') return String(value);
  if (Array.isArray(value)) {
    if (value.length === 0) return '[]';
    return value
      .map((item) => {
        const inner = toYaml(item, indent + 2);
        if (typeof item === 'object' && item !== null && !Array.isArray(item)) {
          return `${pad}- ${inner.startsWith(' ') ? inner.slice(1) : inner}`;
        }
        return `${pad}- ${inner}`;
      })
      .join('\n');
  }
  if (typeof value === 'object') {
    const entries = Object.entries(value);
    if (entries.length === 0) return '{}';
    return entries
      .map(([k, v]) => {
        const inner = toYaml(v, indent + 2);
        if (Array.isArray(v) || (typeof v === 'object' && v !== null)) {
          return `${pad}${k}:\n${inner}`;
        }
        return `${pad}${k}: ${inner}`;
      })
      .join('\n');
  }
  return String(value);
}

await writeFile(yamlPath, toYaml(document) + '\n', 'utf8');

console.log(
  `Wrote ${Object.keys(document.components?.schemas ?? {}).length} components to dist/openapi/`,
);