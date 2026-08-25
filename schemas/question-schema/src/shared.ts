import { z } from 'zod';

/**
 * LocalId — every per-question inner ID (option.id, gap.id, paragraph.id, etc.)
 * uses this regex. The top-level question id is a uuid (see BasePayloadSchema).
 */
export const LocalIdSchema = z
  .string()
  .regex(/^[a-zA-Z0-9_-]{1,16}$/)
  .describe('Local identifier (1-16 chars, ASCII letters, digits, underscore, hyphen).');

/** Skill bands that every question belongs to. */
export const SkillSchema = z.enum(['READING', 'LISTENING']).describe('Skill band this question belongs to.');

/** Sidecar provenance for AI-generated questions. All fields optional. */
export const ProvenanceSchema = z
  .object({
    generatorVersion: z.string().min(1).optional().describe('Version of the generator that emitted this question.'),
    generatorType: z.enum(['human', 'llm', 'mixed']).optional().describe('How the question was authored.'),
    promptHash: z
      .string()
      .regex(/^sha256:[a-f0-9]{64}$/)
      .optional()
      .describe('SHA-256 of the generation prompt in the form `sha256:<64-hex>`.'),
    modelId: z.string().min(1).optional().describe('Model identifier used to generate the question.'),
    generatedAt: z.string().datetime().optional().describe('Generation timestamp (RFC 3339 / ISO 8601).'),
    reviewStatus: z
      .enum(['draft', 'pending', 'approved', 'rejected'])
      .optional()
      .describe('Editorial review status of the generated question.'),
    reviewerId: z.string().min(1).optional().describe('Editor who reviewed the question.'),
    reviewedAt: z.string().datetime().optional().describe('Review timestamp (RFC 3339 / ISO 8601).'),
    rejectionReason: z.string().optional().describe('Reason given when reviewStatus is `rejected`.'),
    regenerationCount: z.number().int().min(0).optional().describe('How many times this question was regenerated.'),
  })
  .strict()
  .describe('Sidecar provenance metadata for AI-generated questions.');

/** A candidate option for any option-bearing multiple choice question. */
export const OptionSchema = z
  .object({
    id: z.string().min(1).describe('Stable identifier for the option. Must be unique within its question.'),
    idx: z.number().int().min(0).describe('Zero-based display index of the option.'),
    contentMd: z.string().min(1).describe('Option text rendered as Markdown.'),
    mediaUrl: z.string().url().optional().describe('Optional media (image/audio) attached to this option.'),
    altText: z
      .string()
      .optional()
      .describe('Alt text for option media, required when mediaUrl is image-like.'),
    isCorrect: z.boolean().optional().describe('Whether this option is marked correct (used by multi-select types).'),
  })
  .strict()
  .describe('Multiple-choice option descriptor.');

/** Normalization applied to learner input before matching. */
export const NormalizationSchema = z
  .object({
    case: z.enum(['sensitive', 'insensitive']).default('insensitive').describe('Whether matching is case-sensitive.'),
    trimWhitespace: z.boolean().default(true).describe('Strip leading/trailing whitespace before matching.'),
    collapseInnerWhitespace: z.boolean().default(true).describe('Collapse runs of internal whitespace to a single space.'),
    stripArticles: z.boolean().default(false).describe('Strip leading English articles (a, an, the) before matching.'),
    stripTrailingPunctuation: z
      .boolean()
      .default(false)
      .describe('Strip trailing punctuation before matching.'),
    unicode: z
      .enum(['NFC', 'NFKC', 'none'])
      .default('NFKC')
      .describe('Unicode normalization form applied before matching.'),
  })
  .strict()
  .describe('Normalization rules applied to learner input before matching.');

/** How multi-answer selections are scored. */
export const ScoringModeSchema = z
  .enum(['all-or-nothing', 'proportional', 'afi', 'rubric'])
  .describe('How multi-answer selections are scored.');

/** A single grading criterion within a Rubric. */
export const CriterionSchema = z
  .object({
    id: z.string().min(1).describe('Stable identifier for the rubric criterion.'),
    label: z.string().min(1).describe('Human-readable label for the criterion.'),
    weight: z
      .number()
      .min(0)
      .max(1)
      .describe('Relative weight of this criterion; weights across criteria typically sum to 1.'),
  })
  .strict()
  .describe('Single rubric criterion.');

/** Authoring rubric used by AI / human graders. */
export const RubricSchema = z
  .object({
    version: z
      .string()
      .regex(/^[a-z0-9-]+-v\d+$/)
      .describe('Rubric version slug, e.g. `ielts-writing-task2-v1`.'),
    criteria: z
      .array(CriterionSchema)
      .min(1)
      .describe('Scoring criteria comprising this rubric.'),
    requiredTokens: z
      .array(z.string().min(1))
      .optional()
      .describe('Tokens that must appear in the learner response.'),
    forbiddenTokens: z
      .array(z.string().min(1))
      .optional()
      .describe('Tokens that must NOT appear in the learner response.'),
    minLength: z.number().int().min(0).optional().describe('Minimum acceptable response length (characters).'),
    maxLength: z.number().int().min(1).optional().describe('Maximum acceptable response length (characters).'),
    scoringStrategy: z
      .enum(['rubric-weighted-key-token', 'llm-judge'])
      .describe('Algorithm used to score the response against the rubric.'),
  })
  .strict()
  .describe('Authoring rubric used by AI / human graders.');

/**
 * Gap descriptor for payload-side use. Accepted answers NEVER belong here;
 * they live in the per-type CorrectAnswer definition. This mirrors the JSON
 * `Gap` $defs after the flow-chart-completion security fix.
 */
export const GapSchema = z
  .object({
    id: LocalIdSchema.describe('Stable identifier for the gap within its question.'),
    normalization: NormalizationSchema.optional().describe(
      'Normalization applied to learner input before matching.',
    ),
    wordLimit: z.number().int().min(1).optional().describe('Maximum number of words allowed in the learner response.'),
    expectedKind: z
      .enum(['text', 'date', 'number'])
      .optional()
      .describe('Expected semantic kind of the accepted answer.'),
  })
  .strict()
  .describe('Payload-side gap descriptor. Accepted answers NEVER belong here.');

/** Optional UI rendering hints shared across all question types. */
export const UiHintsSchema = z
  .object({
    inputControl: z
      .enum(['text', 'textarea', 'select', 'radio', 'checkbox', 'drag', 'audio', 'image-pick'])
      .optional()
      .describe('Recommended frontend input control for this question.'),
    layout: z
      .enum(['inline', 'stacked', 'grid', 'columns', 'full-bleed'])
      .optional()
      .describe('Recommended layout for the rendered question.'),
    columns: z
      .number()
      .int()
      .min(1)
      .max(12)
      .optional()
      .describe('Recommended column count when layout is `columns` or `grid`.'),
    mediaPosition: z
      .enum(['above', 'below', 'left', 'right', 'inline'])
      .optional()
      .describe('Position of the question media relative to the prompt.'),
    estimatedSeconds: z
      .number()
      .int()
      .min(1)
      .optional()
      .describe('Author-declared estimate of how long this question takes (seconds).'),
    tags: z
      .array(z.string().min(1))
      .optional()
      .refine((arr) => (arr ? new Set(arr).size === arr.length : true), { message: 'tags must be unique' })
      .describe('Free-form UI/authoring tags used for filtering or grouping.'),
  })
  .strict()
  .describe('Optional UI rendering hints shared across all question types.');

/** Base fields shared by every question payload. */
export const BasePayloadSchema = z
  .object({
    id: z.string().uuid().describe('Stable UUID for this question.'),
    skill: SkillSchema,
    difficulty: z
      .number()
      .int()
      .min(1)
      .max(5)
      .default(1)
      .describe('Difficulty band from 1 (easiest) to 5 (hardest).'),
    promptMd: z.string().min(1).describe('Question prompt rendered as Markdown.'),
    explanationMd: z.string().optional().describe('Optional author-facing explanation shown after grading.'),
    schemaVersion: z
      .string()
      .regex(/^\d+\.\d+\.\d+$/)
      .default('1.0.0')
      .describe('Version of the question payload schema this document conforms to.'),
    uiHints: UiHintsSchema.optional().describe('Optional UI rendering hints for the frontend.'),
    provenance: ProvenanceSchema.optional().describe('Optional generation/editorial provenance.'),
  })
  .strict()
  .describe('Base fields shared by every question payload. Each per-type schema extends this.');
