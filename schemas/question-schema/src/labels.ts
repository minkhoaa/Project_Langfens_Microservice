import { QUESTION_TYPES, DEPRECATED_TYPE_ALIASES, type AnyQuestionType } from './discriminator';

/** Runtime assert: every label key must be either canonical or a deprecated alias. */
function assertLabelKeys(keys: readonly string[]): void {
  const allowed: Record<AnyQuestionType, true> = {
    MULTIPLE_CHOICE_SINGLE: true,
    MULTIPLE_CHOICE_SINGLE_IMAGE: true,
    MULTIPLE_CHOICE_MULTIPLE: true,
    TRUE_FALSE_NOT_GIVEN: true,
    YES_NO_NOT_GIVEN: true,
    SUMMARY_COMPLETION: true,
    TABLE_COMPLETION: true,
    NOTE_COMPLETION: true,
    FORM_COMPLETION: true,
    SENTENCE_COMPLETION: true,
    SHORT_ANSWER: true,
    AUDIO_RESPONSE: true,
    DIAGRAM_LABEL: true,
    MAP_LABEL: true,
    MATCHING_HEADING: true,
    MATCHING_INFORMATION: true,
    MATCHING_FEATURES: true,
    MATCHING_ENDINGS: true,
    CLASSIFICATION: true,
    FLOW_CHART: true,
    FLOW_CHART_COMPLETION: true,
    MCQ_SINGLE: true,
    MCQ_MULTIPLE: true,
  };
  for (const key of keys) {
    if (!Object.prototype.hasOwnProperty.call(allowed, key)) {
      throw new Error(`QUESTION_TYPE_LABELS contains unknown key: ${key}`);
    }
  }
}

/**
 * 23 labels — 21 canonical + 2 deprecated aliases. Values mirror `_registry.json`.
 */
export const QUESTION_TYPE_LABELS: Readonly<Record<AnyQuestionType, string>> = {
  MULTIPLE_CHOICE_SINGLE: 'Multiple Choice (Single Answer)',
  MULTIPLE_CHOICE_SINGLE_IMAGE: 'Multiple Choice (Single Answer, Image-Based)',
  MULTIPLE_CHOICE_MULTIPLE: 'Multiple Choice (Multiple Answers)',
  TRUE_FALSE_NOT_GIVEN: 'True / False / Not Given',
  YES_NO_NOT_GIVEN: 'Yes / No / Not Given',
  SUMMARY_COMPLETION: 'Summary Completion',
  TABLE_COMPLETION: 'Table Completion',
  NOTE_COMPLETION: 'Note Completion',
  FORM_COMPLETION: 'Form Completion',
  SENTENCE_COMPLETION: 'Sentence Completion',
  SHORT_ANSWER: 'Short Answer',
  AUDIO_RESPONSE: 'Audio Response',
  DIAGRAM_LABEL: 'Diagram Labelling',
  MAP_LABEL: 'Map Labelling',
  MATCHING_HEADING: 'Matching Headings',
  MATCHING_INFORMATION: 'Matching Information',
  MATCHING_FEATURES: 'Matching Features',
  MATCHING_ENDINGS: 'Matching Sentence Endings',
  CLASSIFICATION: 'Classification',
  FLOW_CHART: 'Flow Chart (Ordering)',
  FLOW_CHART_COMPLETION: 'Flow Chart Completion',
  // Deprecated aliases
  MCQ_SINGLE: 'Multiple Choice (deprecated — use MULTIPLE_CHOICE_SINGLE)',
  MCQ_MULTIPLE: 'Multiple Selection (deprecated — use MULTIPLE_CHOICE_MULTIPLE)',
};

assertLabelKeys(Object.keys(QUESTION_TYPE_LABELS));
