/** Canonical 21 Langfens question type slugs, derived from QuestionType.cs:5-31. */
export const QUESTION_TYPES = [
  'MULTIPLE_CHOICE_SINGLE',
  'MULTIPLE_CHOICE_SINGLE_IMAGE',
  'MULTIPLE_CHOICE_MULTIPLE',
  'TRUE_FALSE_NOT_GIVEN',
  'YES_NO_NOT_GIVEN',
  'SUMMARY_COMPLETION',
  'TABLE_COMPLETION',
  'NOTE_COMPLETION',
  'FORM_COMPLETION',
  'SENTENCE_COMPLETION',
  'SHORT_ANSWER',
  'AUDIO_RESPONSE',
  'DIAGRAM_LABEL',
  'MAP_LABEL',
  'MATCHING_HEADING',
  'MATCHING_INFORMATION',
  'MATCHING_FEATURES',
  'MATCHING_ENDINGS',
  'CLASSIFICATION',
  'FLOW_CHART',
  'FLOW_CHART_COMPLETION',
] as const;

/** Deprecated type aliases kept for backward compatibility. */
export const DEPRECATED_TYPE_ALIASES = ['MCQ_SINGLE', 'MCQ_MULTIPLE'] as const;

export type QuestionTypeSlug = typeof QUESTION_TYPES[number];
export type DeprecatedTypeAlias = typeof DEPRECATED_TYPE_ALIASES[number];
export type AnyQuestionType = QuestionTypeSlug | DeprecatedTypeAlias;

export const CANONICAL_QUESTION_TYPES: readonly QuestionTypeSlug[] = QUESTION_TYPES;

/**
 * Resolve a deprecated alias to its canonical slug.
 * Returns `null` for unknown or already-canonical input.
 */
export function resolveDeprecatedAlias(input: string): QuestionTypeSlug | null {
  switch (input) {
    case 'MCQ_SINGLE':
      return 'MULTIPLE_CHOICE_SINGLE';
    case 'MCQ_MULTIPLE':
      return 'MULTIPLE_CHOICE_MULTIPLE';
    default:
      return null;
  }
}

/** Type guard: is `input` one of the 21 canonical slugs? */
export function isCanonicalType(input: string): input is QuestionTypeSlug {
  return (QUESTION_TYPES as readonly string[]).includes(input);
}

/** Type guard: is `input` a deprecated alias? */
export function isDeprecatedAlias(input: string): input is DeprecatedTypeAlias {
  return (DEPRECATED_TYPE_ALIASES as readonly string[]).includes(input);
}
