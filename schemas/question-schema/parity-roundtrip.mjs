// Parity roundtrip v2 — JSON Schema (dereferenced) vs Zod package.
// Strategy: dereference every JSON file (including cross-file $refs to
// _shared.schema.json) with @apidevtools/json-schema-ref-parser, compile with
// Ajv 8 (2020-12 + ajv-formats, strict:false), and compare against the Zod
// per-type schemas at runtime.
//
// No source files in either layer are modified.
import { readFileSync } from 'node:fs';
import { resolve as pathResolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import RefParser from '@apidevtools/json-schema-ref-parser';

const ZodPkgDir = '/home/khoa/Projects/langfens/Project_Langfens_Microservice/schemas/question-schema';
const SCHEMAS_DIR = '/home/khoa/Projects/langfens/docs/standards/schemas';

const Z = await import(pathResolve(ZodPkgDir, 'dist/index.mjs'));
const AjvMod = await import('ajv').catch(() => null);
if (!AjvMod) throw new Error('ajv not installed — run `npm install --no-save ajv@8 ajv-formats @apidevtools/json-schema-ref-parser` in question-schema/');
const AjvCtor = AjvMod.default || AjvMod;
// Prefer Ajv2020 so the draft-2020-12 meta-schema is recognized (our JSON files declare draft 2020-12).
const _Ajv2020Mod = await import('ajv/dist/2020.js').catch(() => null);
const FinalAjv = _Ajv2020Mod ? (_Ajv2020Mod.default || _Ajv2020Mod) : AjvCtor;
let ajvFormatsFn = null;
try {
  const mod = await import('ajv-formats');
  ajvFormatsFn = mod.default || mod;
} catch (e) {
  ajvFormatsFn = null;
}

const REGISTRY = JSON.parse(readFileSync(`${SCHEMAS_DIR}/_registry.json`, 'utf8'));

// ---------------------------------------------------------------------------
// Ajv compilation against a DEREFERENCED schema.
// We dereference the full schema once, then compile. This means cross-file
// $refs (e.g. `_shared.schema.json#/$defs/BasePayload`) are resolved inline
// before compilation, so `unevaluatedProperties: false` and any required
// properties pulled in via $ref are honoured correctly.
// ---------------------------------------------------------------------------
async function derefJsonSchema(slug) {
  const entry = REGISTRY.types.find((t) => t.slug === slug);
  if (!entry) throw new Error('unknown slug ' + slug);
  const file = `${SCHEMAS_DIR}/${entry.file}`;
  const localResolver = {
    async order() { return 1; },
    canRead: /^https?:\/\/langfens\.dev\//,
    async read({ url }) {
      const m = url.match(/\/schemas\/([^?#]+)$/);
  const ajv = new FinalAjv({ allErrors: true, strict: false });
      const localPath = `${SCHEMAS_DIR}/${m[1]}`;
      return readFileSync(localPath, 'utf8');
    },
  };
  const dereffed = await RefParser.dereference(file, { resolve: { local: localResolver } });
  return dereffed;
}

function compileAjv(schemaJson) {
  const ajv = new FinalAjv({ allErrors: true, strict: false });
  if (ajvFormatsFn) ajvFormatsFn(ajv);
  let validate;
  try {
    validate = ajv.compile(schemaJson);
  } catch (e) {
    return { ok: false, errors: [`compile-error: ${e.message}`], validate: null };
  }
  return { ok: true, errors: null, validate };
}

function tryAjv(ajvObj, sample) {
  if (!ajvObj.validate) return ajvObj;
  const ok = ajvObj.validate(sample);
  return {
    ok,
    errors: ok ? null : (ajvObj.validate.errors || []).map((e) => {
      const where = e.instancePath || '/';
      const params = e.params ? JSON.stringify(e.params) : '';
      return `${where} ${e.message}${params ? ' ' + params : ''}`;
    }).slice(0, 8),
    validate: null,
  };
}

function tryZod(schema, sample) {
  const r = schema.safeParse(sample);
  if (r.success) return { ok: true, errors: null };
  return { ok: false, errors: r.error.issues.slice(0, 6).map((i) => `${(i.path || []).join('.') || '/'} ${i.message}`) };
}

// ---------------------------------------------------------------------------
// Sample builders. JSON contract: type is OUTER; Zod per-type: type is INNER.
// ---------------------------------------------------------------------------
function basePayload() {
  return {
    id: '00000000-0000-4000-8000-000000000001',
    skill: 'READING',
    difficulty: 3,
    promptMd: 'Pick the best option.',
    schemaVersion: '1.0.0',
  };
}

function jsonSample(slug) {
  const base = basePayload();
  switch (slug) {
    case 'MULTIPLE_CHOICE_SINGLE':
      return {
        type: slug,
        payload: { ...base, options: [
          { id: 'a', idx: 0, contentMd: 'first' },
          { id: 'b', idx: 1, contentMd: 'second' },
        ]},
        correctAnswer: { correctOptionId: 'a' },
      };
    case 'MULTIPLE_CHOICE_SINGLE_IMAGE':
      return {
        type: slug,
        payload: { ...base, options: [
          { id: 'a', idx: 0, contentMd: 'first', mediaUrl: 'https://example.com/a.png', altText: 'a' },
          { id: 'b', idx: 1, contentMd: 'second', mediaUrl: 'https://example.com/b.png', altText: 'b' },
        ]},
        correctAnswer: { correctOptionId: 'a' },
      };
    case 'MULTIPLE_CHOICE_MULTIPLE':
      return {
        type: slug,
        payload: { ...base, options: [
          { id: 'a', idx: 0, contentMd: 'A' },
          { id: 'b', idx: 1, contentMd: 'B' },
          { id: 'c', idx: 2, contentMd: 'C' },
        ], minSelections: 1, maxSelections: 2 },
        correctAnswer: { correctOptionIds: ['a', 'b'], scoring: 'afi' },
      };
    case 'TRUE_FALSE_NOT_GIVEN':
      return {
        type: slug,
        payload: { ...base, statement: 'The sky is blue.', options: [
          { id: 't', idx: 0, contentMd: 'TRUE' },
          { id: 'f', idx: 1, contentMd: 'FALSE' },
          { id: 'ng', idx: 2, contentMd: 'NOT GIVEN' },
        ]},
        correctAnswer: { choice: 'TRUE' },
      };
    case 'YES_NO_NOT_GIVEN':
      return {
        type: slug,
        payload: { ...base, statement: 'Cats are mammals.', options: [
          { id: 'y', idx: 0, contentMd: 'YES' },
          { id: 'n', idx: 1, contentMd: 'NO' },
          { id: 'ng', idx: 2, contentMd: 'NOT GIVEN' },
        ]},
        correctAnswer: { choice: 'YES' },
      };
    case 'SUMMARY_COMPLETION':
      return {
        type: slug,
        payload: { ...base, gaps: [{ id: 'g1' }] },
        correctAnswer: { answers: { g1: ['leak', 'drip'] } },
      };
    case 'TABLE_COMPLETION':
      return {
        type: slug,
        payload: { ...base, cells: [
          { rowId: 'r1', colId: 'c1', gapId: 'g1' },
          { rowId: 'r1', colId: 'c2', gapId: 'g2' },
        ], gaps: [
          { id: 'g1' },
          { id: 'g2' },
        ]},
        correctAnswer: { answers: { g1: ['x'], g2: ['y'] } },
      };
    case 'NOTE_COMPLETION':
      return { type: slug, payload: { ...base, gaps: [{ id: 'g1' }] }, correctAnswer: { answers: { g1: ['answer'] } } };
    case 'FORM_COMPLETION':
      return { type: slug, payload: { ...base, gaps: [{ id: 'g1', expectedKind: 'date' }] }, correctAnswer: { answers: { g1: ['2024-01-01'] } } };
    case 'SENTENCE_COMPLETION':
      return { type: slug, payload: { ...base, gap: { id: 'g1' } }, correctAnswer: { acceptedTexts: ['because'], acceptedRegexes: ['^beca?use$'] } };
    case 'SHORT_ANSWER':
      return { type: slug, payload: { ...base, wordLimit: 3 }, correctAnswer: { acceptedTexts: ['paris'], acceptedRegexes: ['^par[ie]s$'] } };
    case 'AUDIO_RESPONSE':
      return {
        type: slug,
        payload: { ...base, maxDurationSec: 60, promptAudioUrl: 'https://example.com/p.mp3' },
        correctAnswer: { acceptedTranscriptions: ['hello world'], modelTranscription: 'hello world', scoring: 'ai+human' },
      };
    case 'DIAGRAM_LABEL':
      return {
        type: slug,
        payload: { ...base, diagramImageUrl: 'https://example.com/d.png', diagramAltText: 'diagram',
          labels: [{ id: 'l1', text: 'A', region: { x: 0, y: 0, w: 0.1, h: 0.1 } }],
          gaps: [{ id: 'g1' }] },
        correctAnswer: { answers: { g1: ['A'] } },
      };
    case 'MAP_LABEL':
      return {
        type: slug,
        payload: { ...base, diagramImageUrl: 'https://example.com/m.png', diagramAltText: 'map',
          labels: [{ id: 'l1', text: 'A', region: { x: 0, y: 0, w: 0.1, h: 0.1 } }],
          gaps: [{ id: 'g1' }] },
        correctAnswer: { answers: { g1: ['A'] } },
      };
    case 'MATCHING_HEADING':
      return {
        type: slug,
        payload: { ...base, paragraphs: [{ id: 'p1', romanNumeral: 'i' }, { id: 'p2', romanNumeral: 'ii' }],
          headings: [{ id: 'h1', text: 'Intro' }, { id: 'h2', text: 'Body' }], arity: '1-1' },
        correctAnswer: { pairs: [{ paragraphId: 'p1', headingId: 'h1' }, { paragraphId: 'p2', headingId: 'h2' }], scoring: 'all-or-nothing' },
      };
    case 'MATCHING_INFORMATION':
      return {
        type: slug,
        payload: { ...base, paragraphs: [{ id: 'p1', label: 'A' }, { id: 'p2', label: 'B' }],
          questions: [{ id: 'q1', prompt: 'Where?' }], allowReuse: false },
        correctAnswer: { pairs: [{ questionId: 'q1', paragraphId: 'p1' }], scoring: 'all-or-nothing' },
      };
    case 'MATCHING_FEATURES':
      return {
        type: slug,
        payload: { ...base, items: [{ id: 'i1', text: 'item' }],
          features: [{ id: 'f1', label: 'feat' }, { id: 'f2', label: 'feat2' }], allowReuse: true },
        correctAnswer: { pairs: [{ itemId: 'i1', featureId: 'f1' }], scoring: 'proportional' },
      };
    case 'MATCHING_ENDINGS':
      return {
        type: slug,
        payload: { ...base, beginnings: [{ id: 'b1', text: 'begin' }],
          endings: [{ id: 'e1', text: 'end' }, { id: 'e2', text: 'end2' }] },
        correctAnswer: { pairs: [{ beginId: 'b1', endId: 'e1' }], scoring: 'all-or-nothing' },
      };
    case 'CLASSIFICATION':
      return {
        type: slug,
        payload: { ...base, items: [{ id: 'i1', text: 'item' }],
          categories: [{ id: 'c1', label: 'cat' }, { id: 'c2', label: 'cat2' }] },
        correctAnswer: { pairs: [{ itemId: 'i1', categoryId: 'c1' }], scoring: 'all-or-nothing' },
      };
    case 'FLOW_CHART':
      return {
        type: slug,
        payload: { ...base, nodes: [
          { id: 'n1', label: 'A', position: { x: 0, y: 0 } },
          { id: 'n2', label: 'B', position: { x: 1, y: 1 } },
        ], edges: [{ from: 'n1', to: 'n2' }] },
        correctAnswer: { order: ['n1', 'n2'], scoring: 'lcs' },
      };
    case 'FLOW_CHART_COMPLETION':
      return {
        type: slug,
        payload: { ...base, nodes: [
          { id: 'n1', label: 'A', position: { x: 0, y: 0 } },
          { id: 'n2', label: 'B', position: { x: 1, y: 1 } },
        ], edges: [{ from: 'n1', to: 'n2' }],
          gaps: [{ nodeId: 'n1', wordLimit: 2 }] },
        correctAnswer: { order: ['n1', 'n2'], gapAnswers: { n1: { acceptedTexts: ['ok'] } } },
      };
    default:
      throw new Error('unknown slug ' + slug);
  }
}

// Zod per-type schemas want `type` inside payload/answer.
function zodSample(jsonS) {
  return {
    payload: { type: jsonS.type, ...jsonS.payload },
    correctAnswer: { type: jsonS.type, ...jsonS.correctAnswer },
  };
}

// Map slugs to Zod schema names.
const SLUG_TO_ZOD = {
  MULTIPLE_CHOICE_SINGLE: { payload: 'multipleChoiceSinglePayloadSchema', answer: 'multipleChoiceSingleAnswerSchema' },
  MULTIPLE_CHOICE_SINGLE_IMAGE: { payload: 'multipleChoiceSingleImagePayloadSchema', answer: 'multipleChoiceSingleImageAnswerSchema' },
  MULTIPLE_CHOICE_MULTIPLE: { payload: 'multipleChoiceMultiplePayloadObjectSchema', answer: 'multipleChoiceMultipleAnswerSchema' },
  TRUE_FALSE_NOT_GIVEN: { payload: 'trueFalseNotGivenPayloadSchema', answer: 'trueFalseNotGivenAnswerSchema' },
  YES_NO_NOT_GIVEN: { payload: 'yesNoNotGivenPayloadSchema', answer: 'yesNoNotGivenAnswerSchema' },
  SUMMARY_COMPLETION: { payload: 'summaryCompletionPayloadSchema', answer: 'summaryCompletionAnswerSchema' },
  TABLE_COMPLETION: { payload: 'tableCompletionPayloadSchema', answer: 'tableCompletionAnswerSchema' },
  NOTE_COMPLETION: { payload: 'noteCompletionPayloadSchema', answer: 'noteCompletionAnswerSchema' },
  FORM_COMPLETION: { payload: 'formCompletionPayloadSchema', answer: 'formCompletionAnswerSchema' },
  SENTENCE_COMPLETION: { payload: 'sentenceCompletionPayloadSchema', answer: 'sentenceCompletionAnswerSchema' },
  SHORT_ANSWER: { payload: 'shortAnswerPayloadSchema', answer: 'shortAnswerAnswerSchema' },
  AUDIO_RESPONSE: { payload: 'audioResponsePayloadSchema', answer: 'audioResponseAnswerSchema' },
  DIAGRAM_LABEL: { payload: 'diagramLabelPayloadSchema', answer: 'diagramLabelAnswerSchema' },
  MAP_LABEL: { payload: 'mapLabelPayloadSchema', answer: 'mapLabelAnswerSchema' },
  MATCHING_HEADING: { payload: 'matchingHeadingPayloadSchema', answer: 'matchingHeadingAnswerSchema' },
  MATCHING_INFORMATION: { payload: 'matchingInformationPayloadSchema', answer: 'matchingInformationAnswerSchema' },
  MATCHING_FEATURES: { payload: 'matchingFeaturesPayloadSchema', answer: 'matchingFeaturesAnswerSchema' },
  MATCHING_ENDINGS: { payload: 'matchingEndingsPayloadSchema', answer: 'matchingEndingsAnswerSchema' },
  CLASSIFICATION: { payload: 'classificationPayloadSchema', answer: 'classificationAnswerSchema' },
  FLOW_CHART: { payload: 'flowChartPayloadSchema', answer: 'flowChartAnswerSchema' },
  FLOW_CHART_COMPLETION: { payload: 'flowChartCompletionPayloadObjectSchema', answer: 'flowChartCompletionAnswerSchema' },
};

// ---------------------------------------------------------------------------
// Phase 1: Per-type parity (valid sample, one-rule-break invalid sample).
// ---------------------------------------------------------------------------
console.error('[phase 1] per-type parity…');
const perTypeResults = [];
let totalChecks = 0;
let passCount = 0;
let failCount = 0;

for (const t of REGISTRY.types) {
  const slug = t.slug;
  const js = jsonSample(slug);
  const zs = zodSample(js);
  const zodNames = SLUG_TO_ZOD[slug];

  const dereffed = await derefJsonSchema(slug);
  const ajvObj = compileAjv(dereffed);

  // Valid sample — both layers should accept.
  const ajvValid = tryAjv(ajvObj, js);
  const zodPayloadValid = tryZod(Z[zodNames.payload], zs.payload);
  const zodAnswerValid = tryZod(Z[zodNames.answer], zs.correctAnswer);
  const zodValidCombined = (zodPayloadValid.ok && zodAnswerValid.ok) ? { ok: true, errors: null } : { ok: false, errors: zodPayloadValid.ok ? zodAnswerValid.errors : zodPayloadValid.errors };

  totalChecks++;
  const validPass = ajvValid.ok && zodValidCombined.ok;
  if (validPass) passCount++; else failCount++;

  // Invalid sample: mutate the valid sample to break exactly ONE rule
  // (typically a discriminator swap, or a missing required field). Both
  // layers should reject.
  const inv = JSON.parse(JSON.stringify(js));
  inv.type = inv.type === 'MULTIPLE_CHOICE_SINGLE' ? 'YES_NO_NOT_GIVEN' : 'MULTIPLE_CHOICE_SINGLE';
  const ajvInvalid = tryAjv(ajvObj, inv);
  const zodPayloadInvalid = tryZod(Z[zodNames.payload], zodSample(inv).payload);
  const zodAnswerInvalid = tryZod(Z[zodNames.answer], zodSample(inv).correctAnswer);
  const zodInvalidCombined = (zodPayloadInvalid.ok && zodAnswerInvalid.ok) ? { ok: true, errors: null } : { ok: false, errors: zodPayloadInvalid.ok ? zodAnswerInvalid.errors : zodPayloadInvalid.errors };

  totalChecks++;
  const invalidPass = !ajvInvalid.ok && !zodInvalidCombined.ok;
  if (invalidPass) passCount++; else failCount++;

  perTypeResults.push({
    slug,
    jsonFile: `${SCHEMAS_DIR}/${t.file}`,
    zodPayload: zodNames.payload,
    zodAnswer: zodNames.answer,
    valid: { ajv: ajvValid, zodPayload: zodPayloadValid, zodAnswer: zodAnswerValid, zodCombined: zodValidCombined, pass: validPass },
    invalid: { ajv: ajvInvalid, zodPayload: zodPayloadInvalid, zodAnswer: zodAnswerInvalid, zodCombined: zodInvalidCombined, pass: invalidPass },
    overall: validPass && invalidPass ? 'PASS' : 'FAIL',
  });
}

// ---------------------------------------------------------------------------
// Phase 2: Discriminator constants — 21 type constants must match.
// ---------------------------------------------------------------------------
console.error('[phase 2] discriminator match…');
const discResults = [];
for (const t of REGISTRY.types) {
  const slug = t.slug;
  const dereffed = await derefJsonSchema(slug);
  const jsonDisc = dereffed.properties.type.const;
  const zodDisc = (() => {
    const payloadSchema = Z[SLUG_TO_ZOD[slug].payload];
    const typeNode = payloadSchema._def.shape().type;
    // z.literal('XYZ') → _def.value === 'XYZ'
    const v = typeNode._def?.value;
    return v;
  })();
  const match = jsonDisc === zodDisc && jsonDisc === slug;
  totalChecks++;
  if (match) passCount++; else failCount++;
  discResults.push({ slug, jsonDisc, zodDisc, match });
}

// ---------------------------------------------------------------------------
// Phase 3: FLOW_CHART_COMPLETION security invariant.
// ---------------------------------------------------------------------------
console.error('[phase 3] FLOW_CHART_COMPLETION security…');
const fccSlug = 'FLOW_CHART_COMPLETION';
const fccDeref = await derefJsonSchema(fccSlug);
const fccAjv = compileAjv(fccDeref);
const fccBase = jsonSample(fccSlug);

const securityTests = [
  {
    name: 'sec-payload-acceptedTexts',
    description: 'payload.gaps[0].acceptedTexts must be rejected by both layers.',
    expectedAjv: false,
    expectedZod: false,
    mutate: (s) => { s.payload.gaps = [{ nodeId: 'n1', acceptedTexts: ['leak'] }]; return s; },
    zodFn: (s) => tryZod(Z.flowChartCompletionPayloadObjectSchema, { type: fccSlug, ...s.payload }),
  },
  {
    name: 'sec-payload-acceptedRegexes',
    description: 'payload.gaps[0].acceptedRegexes must be rejected by both layers.',
    expectedAjv: false,
    expectedZod: false,
    mutate: (s) => { s.payload.gaps = [{ nodeId: 'n1', acceptedRegexes: ['^leak$'] }]; return s; },
    zodFn: (s) => tryZod(Z.flowChartCompletionPayloadObjectSchema, { type: fccSlug, ...s.payload }),
  },
  {
    name: 'sec-answer-bareStringArray',
    description: 'correctAnswer.gapAnswers[n1] = bare string[] must be rejected by both layers.',
    expectedAjv: false,
    expectedZod: false,
    mutate: (s) => { s.correctAnswer.gapAnswers = { n1: ['just-a-string'] }; return s; },
    zodFn: (s) => tryZod(Z.flowChartCompletionAnswerSchema, { type: fccSlug, ...s.correctAnswer }),
  },
  {
    name: 'sec-correctSample',
    description: 'well-formed payload + answer must be accepted by both layers.',
    expectedAjv: true,
    expectedZod: true,
    mutate: (s) => {
      s.payload.gaps = [{ nodeId: 'n1', wordLimit: 2 }];
      s.correctAnswer.gapAnswers = { n1: { acceptedTexts: ['ok'] } };
      return s;
    },
    zodFn: (s) => {
      const p = tryZod(Z.flowChartCompletionPayloadObjectSchema, { type: fccSlug, ...s.payload });
      const a = tryZod(Z.flowChartCompletionAnswerSchema, { type: fccSlug, ...s.correctAnswer });
      return { ok: p.ok && a.ok, errors: p.ok ? a.errors : p.errors };
    },
  },
];

const secResults = [];
for (const test of securityTests) {
  const mutated = JSON.parse(JSON.stringify(fccBase));
  test.mutate(mutated);
  const ajv = tryAjv(fccAjv, mutated);
  const zod = test.zodFn(mutated);
  const consistent = (ajv.ok === test.expectedAjv) && (zod.ok === test.expectedZod);
  totalChecks++;
  if (consistent) passCount++; else failCount++;
  secResults.push({ name: test.name, description: test.description, expectedAjv: test.expectedAjv, expectedZod: test.expectedZod, ajv, zod, pass: consistent });
}

// ---------------------------------------------------------------------------
// Phase 4: LocalId pattern.
// ---------------------------------------------------------------------------
console.error('[phase 4] LocalId pattern…');
const lidTests = [
  {
    name: 'localId-options-spaces',
    description: 'options[0].id with spaces. Pattern: id is NOT LocalId-restricted; both layers should consistently ACCEPT.',
    slug: 'MULTIPLE_CHOICE_SINGLE',
    expectedAjv: true,
    expectedZod: true,
    mutate: (s) => { s.payload.options[0].id = 'has spaces'; return s; },
  },
  {
    name: 'localId-nodes-20chars',
    description: 'flow-chart node id 20 chars long. Both layers REJECT.',
    slug: 'FLOW_CHART',
    expectedAjv: false,
    expectedZod: false,
    mutate: (s) => { s.payload.nodes[0].id = 'a'.repeat(20); return s; },
  },
  {
    name: 'localId-nodes-with-spaces',
    description: 'flow-chart node id with spaces. Both layers REJECT.',
    slug: 'FLOW_CHART',
    expectedAjv: false,
    expectedZod: false,
    mutate: (s) => { s.payload.nodes[0].id = 'has spaces'; return s; },
  },
  {
    name: 'localId-valid-16chars',
    description: 'flow-chart node id 16 valid chars (boundary). Both layers ACCEPT.',
    slug: 'FLOW_CHART',
    expectedAjv: true,
    expectedZod: true,
    mutate: (s) => { s.payload.nodes[0].id = 'abcdefghijklmnop'; return s; },
  },
];

const lidResults = [];
for (const test of lidTests) {
  const s = test.mutate(JSON.parse(JSON.stringify(jsonSample(test.slug))));
  const ajvObj = compileAjv(await derefJsonSchema(test.slug));
  const ajv = tryAjv(ajvObj, s);
  const zod = tryZod(Z[SLUG_TO_ZOD[test.slug].payload], { type: test.slug, ...s.payload });
  const consistent = (ajv.ok === test.expectedAjv) && (zod.ok === test.expectedZod);
  totalChecks++;
  if (consistent) passCount++; else failCount++;
  lidResults.push({ name: test.name, description: test.description, expectedAjv: test.expectedAjv, expectedZod: test.expectedZod, ajv, zod, pass: consistent });
}

// ---------------------------------------------------------------------------
// Phase 5: maxItems enforcement per JSON table.
// ---------------------------------------------------------------------------
console.error('[phase 5] maxItems enforcement…');
const maxItemsTests = [
  { name: 'classification-items-21', description: 'classification.items with 21 entries (limit 20).', slug: 'CLASSIFICATION', expectedAjv: false, expectedZod: false, mutate: (s) => { while (s.payload.items.length < 21) s.payload.items.push({ id: 'i' + s.payload.items.length, text: 't' }); return s; } },
  { name: 'matching-endings-beginnings-11', description: 'matching-endings.beginnings with 11 entries (limit 10).', slug: 'MATCHING_ENDINGS', expectedAjv: false, expectedZod: false, mutate: (s) => { while (s.payload.beginnings.length < 11) s.payload.beginnings.push({ id: 'b' + s.payload.beginnings.length, text: 'b' }); return s; } },
  { name: 'flow-chart-nodes-13', description: 'flow-chart.nodes with 13 entries (limit 12).', slug: 'FLOW_CHART', expectedAjv: false, expectedZod: false, mutate: (s) => { while (s.payload.nodes.length < 13) s.payload.nodes.push({ id: 'n' + s.payload.nodes.length, label: 'L', position: { x: 0, y: 0 } }); return s; } },
  { name: 'flow-chart-edges-25', description: 'flow-chart.edges with 25 entries (limit 24).', slug: 'FLOW_CHART', expectedAjv: false, expectedZod: false, mutate: (s) => { while (s.payload.nodes.length < 3) s.payload.nodes.push({ id: 'n' + s.payload.nodes.length, label: 'L', position: { x: 0, y: 0 } }); while (s.payload.edges.length < 25) s.payload.edges.push({ from: 'n1', to: 'n' + (s.payload.edges.length % 3 + 1) }); return s; } },
  { name: 'flow-chart-completion-gaps-13', description: 'flow-chart-completion.gaps with 13 entries (limit 12).', slug: 'FLOW_CHART_COMPLETION', expectedAjv: false, expectedZod: false, mutate: (s) => { while (s.payload.nodes.length < 13) s.payload.nodes.push({ id: 'n' + s.payload.nodes.length, label: 'L', position: { x: 0, y: 0 } }); while (s.payload.gaps.length < 13) s.payload.gaps.push({ nodeId: 'n' + s.payload.gaps.length, wordLimit: 1 }); return s; } },
  { name: 'diagram-label-labels-13', description: 'diagram-label.labels with 13 entries (limit 12).', slug: 'DIAGRAM_LABEL', expectedAjv: false, expectedZod: false, mutate: (s) => { while (s.payload.labels.length < 13) s.payload.labels.push({ id: 'l' + s.payload.labels.length, text: 'A', region: { x: 0, y: 0, w: 0.1, h: 0.1 } }); return s; } },
  { name: 'summary-completion-gaps-11', description: 'summary-completion.gaps with 11 entries (limit 10).', slug: 'SUMMARY_COMPLETION', expectedAjv: false, expectedZod: false, mutate: (s) => { while (s.payload.gaps.length < 11) s.payload.gaps.push({ id: 'g' + s.payload.gaps.length }); return s; } },
  { name: 'table-completion-cells-51', description: 'table-completion.cells with 51 entries (limit 50).', slug: 'TABLE_COMPLETION', expectedAjv: false, expectedZod: false, mutate: (s) => { while (s.payload.cells.length < 51) { const i = s.payload.cells.length; s.payload.cells.push({ rowId: 'r' + (i % 5), colId: 'c' + (i % 7), gapId: 'g' + i }); } return s; } },
  { name: 'multiple-choice-multiple-options-9', description: 'multiple-choice-multiple.options with 9 entries (limit 8).', slug: 'MULTIPLE_CHOICE_MULTIPLE', expectedAjv: false, expectedZod: false, mutate: (s) => { while (s.payload.options.length < 9) s.payload.options.push({ id: 'o' + s.payload.options.length, idx: s.payload.options.length, contentMd: 'x' }); return s; } },
  { name: 'audio-response-acceptedTranscriptions-6', description: 'audio-response.acceptedTranscriptions with 6 entries (limit 5).', slug: 'AUDIO_RESPONSE', expectedAjv: false, expectedZod: false, mutate: (s) => { s.correctAnswer.acceptedTranscriptions = Array.from({length:6}, (_,i) => 't' + i); return s; } },
  { name: 'short-answer-acceptedTexts-11', description: 'short-answer.acceptedTexts with 11 entries (limit 10).', slug: 'SHORT_ANSWER', expectedAjv: false, expectedZod: false, mutate: (s) => { s.correctAnswer.acceptedTexts = Array.from({length:11}, (_,i) => 'a' + i); return s; } },
  { name: 'sentence-completion-acceptedTexts-11', description: 'sentence-completion.acceptedTexts with 11 entries (limit 10).', slug: 'SENTENCE_COMPLETION', expectedAjv: false, expectedZod: false, mutate: (s) => { s.correctAnswer.acceptedTexts = Array.from({length:11}, (_,i) => 'a' + i); return s; } },
  { name: 'sentence-completion-acceptedRegexes-6', description: 'sentence-completion.acceptedRegexes with 6 entries (limit 5).', slug: 'SENTENCE_COMPLETION', expectedAjv: false, expectedZod: false, mutate: (s) => { s.correctAnswer.acceptedRegexes = Array.from({length:6}, (_,i) => '^a' + i + '$'); return s; } },
  { name: 'fcc-acceptedRegexes-11', description: 'flow-chart-completion.gapAnswers.*.acceptedRegexes with 11 entries (Zod limit 10; JSON limit? to be verified).', slug: 'FLOW_CHART_COMPLETION', expectedAjv: false, expectedZod: false, mutate: (s) => { s.correctAnswer.gapAnswers = { n1: { acceptedTexts: ['ok'], acceptedRegexes: Array.from({length:11}, (_,i) => '^a' + i + '$') } }; return s; } },
];

const maxResults = [];
for (const test of maxItemsTests) {
  const s = test.mutate(JSON.parse(JSON.stringify(jsonSample(test.slug))));
  const ajvObj = compileAjv(await derefJsonSchema(test.slug));
  const ajv = tryAjv(ajvObj, s);
  // Use payload schema for payload-level checks, answer for answer-level.
  let zod;
  if (test.name.startsWith('multiple-choice-multiple')) zod = tryZod(Z.multipleChoiceMultiplePayloadObjectSchema, { type: test.slug, ...s.payload });
  else if (test.name.startsWith('audio-response')) zod = tryZod(Z.audioResponseAnswerSchema, { type: test.slug, ...s.correctAnswer });
  else if (test.name.startsWith('short-answer') || test.name.startsWith('sentence-completion')) zod = tryZod(Z[SLUG_TO_ZOD[test.slug].answer], { type: test.slug, ...s.correctAnswer });
  else if (test.name.startsWith('fcc-')) zod = tryZod(Z.flowChartCompletionAnswerSchema, { type: test.slug, ...s.correctAnswer });
  else zod = tryZod(Z[SLUG_TO_ZOD[test.slug].payload], { type: test.slug, ...s.payload });
  const consistent = (ajv.ok === test.expectedAjv) && (zod.ok === test.expectedZod);
  totalChecks++;
  if (consistent) passCount++; else failCount++;
  maxResults.push({ name: test.name, description: test.description, expectedAjv: test.expectedAjv, expectedZod: test.expectedZod, ajv, zod, pass: consistent });
}

// ---------------------------------------------------------------------------
// Phase 6: BasePayload field set match (provenance check on DEREFERENCED
// schema). The previous report said JSON was missing provenance — re-verify
// by reading the BasePayload after dereferencing.
// ---------------------------------------------------------------------------
console.error('[phase 6] BasePayload field set…');
const sharedRaw = JSON.parse(readFileSync(`${SCHEMAS_DIR}/_shared.schema.json`, 'utf8'));
// Use a deref of any per-type schema to pull in the BasePayload $ref inline.
const anyDeref = await derefJsonSchema(REGISTRY.types[0].slug);
function findBasePayloadDef(obj) {
  if (!obj || typeof obj !== 'object') return null;
  if (Array.isArray(obj)) { for (const x of obj) { const r = findBasePayloadDef(x); if (r) return r; } return null; }
  if (obj.type === 'object' && obj.properties && obj.properties.id && obj.properties.skill && obj.properties.difficulty && obj.properties.promptMd && obj.properties.schemaVersion) {
    return obj;
  }
  for (const k of Object.keys(obj)) { const r = findBasePayloadDef(obj[k]); if (r) return r; }
  return null;
}
const basePayloadInDeref = findBasePayloadDef(anyDeref);
const zodBasePayloadKeys = Object.keys(Z.BasePayloadSchema._def.shape()).sort();
const jsonBasePayloadKeys = Object.keys((basePayloadInDeref && basePayloadInDeref.properties) || {}).sort();
const requiredJson = ((basePayloadInDeref && basePayloadInDeref.required) || []).slice().sort();
const requiredZod = ['id', 'skill', 'difficulty', 'promptMd', 'schemaVersion']; // Zod BasePayloadSchema extends z.object({...}); all listed are required (no .optional())

const basePayloadParity = {
  jsonProperties: jsonBasePayloadKeys,
  zodProperties: zodBasePayloadKeys,
  jsonOnly: jsonBasePayloadKeys.filter((p) => !zodBasePayloadKeys.includes(p)),
  zodOnly: zodBasePayloadKeys.filter((p) => !jsonBasePayloadKeys.includes(p)),
  matches: JSON.stringify(jsonBasePayloadKeys) === JSON.stringify(zodBasePayloadKeys),
  jsonRequired: requiredJson,
  zodRequired: requiredZod,
  jsonHasProvenance: jsonBasePayloadKeys.includes('provenance'),
  zodHasProvenance: zodBasePayloadKeys.includes('provenance'),
};

// Acceptance: both layers should have the SAME set including provenance.
// (If JSON lacks provenance, that's a real drift.)
totalChecks++;
if (basePayloadParity.matches && basePayloadParity.jsonHasProvenance === basePayloadParity.zodHasProvenance) {
  passCount++;
  basePayloadParity.pass = true;
} else {
  failCount++;
  basePayloadParity.pass = false;
}

// ---------------------------------------------------------------------------
// Final report
// ---------------------------------------------------------------------------
const report = {
  timestamp: new Date().toISOString(),
  jsonSource: 'docs/standards/schemas/*.schema.json (dereferenced via @apidevtools/json-schema-ref-parser)',
  zodSource: 'Project_Langfens_Microservice/schemas/question-schema/dist/',
  ajvMode: 'Ajv 8 / draft 2020-12 + ajv-formats / strict:false',
  totalChecks,
  passCount,
  failCount,
  perType: perTypeResults,
  discriminator: discResults,
  securityContract: secResults,
  localIdPattern: lidResults,
  maxItems: maxResults,
  basePayload: basePayloadParity,
};

import('node:fs').then((fs) => {
  fs.writeFileSync('/tmp/parity-results.json', JSON.stringify(report, null, 2));
  console.error(`\n[done] ${totalChecks} checks, ${passCount} pass, ${failCount} fail`);
  console.error('[done] results → /tmp/parity-results.json');
});