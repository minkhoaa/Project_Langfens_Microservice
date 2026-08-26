import { QUESTION_TYPES, type QuestionTypeSlug } from './discriminator';

export type QuestionGroup =
  | 'multiple-choice'
  | 'true-false'
  | 'completion'
  | 'short-answer'
  | 'speaking'
  | 'label'
  | 'matching'
  | 'flow-chart';

export type Skill = 'READING' | 'LISTENING';

export interface QuestionTypeMetadata {
  readonly slug: QuestionTypeSlug;
  readonly label: string;
  readonly group: QuestionGroup;
  readonly skill: readonly Skill[];
  readonly autoGradable: boolean;
}

function assertMetadataKeys(): void {
  const allowed = new Set<string>(QUESTION_TYPES);
  for (const key of Object.keys(QUESTION_TYPE_METADATA)) {
    if (!allowed.has(key)) {
      throw new Error(`QUESTION_TYPE_METADATA contains unknown slug: ${key}`);
    }
  }
  for (const slug of QUESTION_TYPES) {
    if (!Object.prototype.hasOwnProperty.call(QUESTION_TYPE_METADATA, slug)) {
      throw new Error(`QUESTION_TYPE_METADATA missing slug: ${slug}`);
    }
  }
}

/**
 * Authoring metadata for every canonical question type, derived 1:1 from
 * `Project_Langfens_Microservice/docs/schemas/_registry.json`.
 */
export const QUESTION_TYPE_METADATA: Readonly<Record<QuestionTypeSlug, QuestionTypeMetadata>> = {
  MULTIPLE_CHOICE_SINGLE: {
    slug: 'MULTIPLE_CHOICE_SINGLE',
    label: 'Multiple Choice (Single Answer)',
    group: 'multiple-choice',
    skill: ['READING', 'LISTENING'],
    autoGradable: true,
  },
  MULTIPLE_CHOICE_SINGLE_IMAGE: {
    slug: 'MULTIPLE_CHOICE_SINGLE_IMAGE',
    label: 'Multiple Choice (Single Answer, Image-Based)',
    group: 'multiple-choice',
    skill: ['READING', 'LISTENING'],
    autoGradable: true,
  },
  MULTIPLE_CHOICE_MULTIPLE: {
    slug: 'MULTIPLE_CHOICE_MULTIPLE',
    label: 'Multiple Choice (Multiple Answers)',
    group: 'multiple-choice',
    skill: ['READING', 'LISTENING'],
    autoGradable: true,
  },
  TRUE_FALSE_NOT_GIVEN: {
    slug: 'TRUE_FALSE_NOT_GIVEN',
    label: 'True / False / Not Given',
    group: 'true-false',
    skill: ['READING'],
    autoGradable: true,
  },
  YES_NO_NOT_GIVEN: {
    slug: 'YES_NO_NOT_GIVEN',
    label: 'Yes / No / Not Given',
    group: 'true-false',
    skill: ['READING'],
    autoGradable: true,
  },
  SUMMARY_COMPLETION: {
    slug: 'SUMMARY_COMPLETION',
    label: 'Summary Completion',
    group: 'completion',
    skill: ['READING', 'LISTENING'],
    autoGradable: true,
  },
  TABLE_COMPLETION: {
    slug: 'TABLE_COMPLETION',
    label: 'Table Completion',
    group: 'completion',
    skill: ['READING', 'LISTENING'],
    autoGradable: true,
  },
  NOTE_COMPLETION: {
    slug: 'NOTE_COMPLETION',
    label: 'Note Completion',
    group: 'completion',
    skill: ['LISTENING'],
    autoGradable: true,
  },
  FORM_COMPLETION: {
    slug: 'FORM_COMPLETION',
    label: 'Form Completion',
    group: 'completion',
    skill: ['LISTENING'],
    autoGradable: true,
  },
  SENTENCE_COMPLETION: {
    slug: 'SENTENCE_COMPLETION',
    label: 'Sentence Completion',
    group: 'completion',
    skill: ['READING', 'LISTENING'],
    autoGradable: true,
  },
  SHORT_ANSWER: {
    slug: 'SHORT_ANSWER',
    label: 'Short Answer',
    group: 'short-answer',
    skill: ['READING', 'LISTENING'],
    autoGradable: true,
  },
  AUDIO_RESPONSE: {
    slug: 'AUDIO_RESPONSE',
    label: 'Audio Response',
    group: 'speaking',
    skill: ['LISTENING'],
    autoGradable: false,
  },
  DIAGRAM_LABEL: {
    slug: 'DIAGRAM_LABEL',
    label: 'Diagram Labelling',
    group: 'label',
    skill: ['READING'],
    autoGradable: true,
  },
  MAP_LABEL: {
    slug: 'MAP_LABEL',
    label: 'Map Labelling',
    group: 'label',
    skill: ['LISTENING'],
    autoGradable: true,
  },
  MATCHING_HEADING: {
    slug: 'MATCHING_HEADING',
    label: 'Matching Headings',
    group: 'matching',
    skill: ['READING'],
    autoGradable: true,
  },
  MATCHING_INFORMATION: {
    slug: 'MATCHING_INFORMATION',
    label: 'Matching Information',
    group: 'matching',
    skill: ['READING'],
    autoGradable: true,
  },
  MATCHING_FEATURES: {
    slug: 'MATCHING_FEATURES',
    label: 'Matching Features',
    group: 'matching',
    skill: ['READING', 'LISTENING'],
    autoGradable: true,
  },
  MATCHING_ENDINGS: {
    slug: 'MATCHING_ENDINGS',
    label: 'Matching Sentence Endings',
    group: 'matching',
    skill: ['READING', 'LISTENING'],
    autoGradable: true,
  },
  CLASSIFICATION: {
    slug: 'CLASSIFICATION',
    label: 'Classification',
    group: 'matching',
    skill: ['READING', 'LISTENING'],
    autoGradable: true,
  },
  FLOW_CHART: {
    slug: 'FLOW_CHART',
    label: 'Flow Chart (Ordering)',
    group: 'flow-chart',
    skill: ['READING', 'LISTENING'],
    autoGradable: true,
  },
  FLOW_CHART_COMPLETION: {
    slug: 'FLOW_CHART_COMPLETION',
    label: 'Flow Chart Completion',
    group: 'flow-chart',
    skill: ['READING', 'LISTENING'],
    autoGradable: true,
  },
};

assertMetadataKeys();

export function metadataFor(slug: QuestionTypeSlug): QuestionTypeMetadata {
  return QUESTION_TYPE_METADATA[slug];
}
