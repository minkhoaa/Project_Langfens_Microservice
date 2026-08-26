import type { QuestionTypeSlug } from '../src/discriminator';
import { canonicalExamples, type CanonicalExample } from '../src/examples';

/**
 * Public test/sample shape. The envelope `type` matches the per-type slug,
 * and each payload/answer already carries its own `type` for Zod's
 * discriminated unions.
 */
export interface SampleQuestion extends CanonicalExample {
  type: QuestionTypeSlug;
  payload: Record<string, unknown> & { type: QuestionTypeSlug };
  correctAnswer: Record<string, unknown> & { type: QuestionTypeSlug };
}

/** 21 samples, one per type. Single source of truth: `src/examples/index.ts`. */
export const samples: Record<QuestionTypeSlug, SampleQuestion> = canonicalExamples;
