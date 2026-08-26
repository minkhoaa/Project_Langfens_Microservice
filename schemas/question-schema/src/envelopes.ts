/**
 * Envelope schemas and cross-reference superRefine wrappers.
 *
 * An envelope is `{ payload, correctAnswer }` (with optional `type`, `rubric`).
 * Per-type envelopes compose the existing per-type payload + answer object
 * schemas (so Zod still reports structural errors at the correct place) and
 * chain a single `.superRefine` that invokes a domain helper from
 * `invariants.ts` to emit actionable cross-reference error messages.
 *
 * Naming: `<slug>EnvelopeSchema`.
 */
import { z } from 'zod';
import {
  flowChartCompletionPayloadObjectSchema,
  matchingHeadingPayloadSchema,
  matchingInformationPayloadSchema,
  multipleChoiceMultiplePayloadObjectSchema,
} from './types';
import {
  flowChartCompletionAnswerSchema,
  matchingHeadingAnswerSchema,
  matchingInformationAnswerSchema,
  multipleChoiceMultipleAnswerSchema,
} from './answers';
import {
  refineFccGapsAndOrder,
  refineMcmCorrectOptionIds,
  refineMhPairs,
  refineMiNoDuplicateParagraphs,
} from './invariants';

/** FCC envelope: payload.gaps[].nodeId ⊆ nodes[].id AND correctAnswer.order ⊆ nodes[].id. */
export const flowChartCompletionEnvelopeSchema = z
  .object({
    payload: flowChartCompletionPayloadObjectSchema,
    correctAnswer: flowChartCompletionAnswerSchema,
    rubric: z.unknown().optional(),
  })
  .passthrough()
  .superRefine((env, ctx) => {
    refineFccGapsAndOrder(env, ctx);
  });

/** MULTIPLE_CHOICE_MULTIPLE envelope: correctOptionIds ⊆ options[].id. */
export const multipleChoiceMultipleEnvelopeSchema = z
  .object({
    payload: multipleChoiceMultiplePayloadObjectSchema,
    correctAnswer: multipleChoiceMultipleAnswerSchema,
    rubric: z.unknown().optional(),
  })
  .passthrough()
  .superRefine((env, ctx) => {
    refineMcmCorrectOptionIds(env, ctx);
  });

/** MATCHING_HEADING envelope: pairs.{paragraphId, headingId} ∈ {paragraphs, headings}[].id. */
export const matchingHeadingEnvelopeSchema = z
  .object({
    payload: matchingHeadingPayloadSchema,
    correctAnswer: matchingHeadingAnswerSchema,
    rubric: z.unknown().optional(),
  })
  .passthrough()
  .superRefine((env, ctx) => {
    refineMhPairs(env, ctx);
  });

/** MATCHING_INFORMATION envelope: no duplicate paragraphs when allowReuse=false. */
export const matchingInformationEnvelopeSchema = z
  .object({
    payload: matchingInformationPayloadSchema,
    correctAnswer: matchingInformationAnswerSchema,
    rubric: z.unknown().optional(),
  })
  .passthrough()
  .superRefine((env, ctx) => {
    refineMiNoDuplicateParagraphs(env, ctx);
  });