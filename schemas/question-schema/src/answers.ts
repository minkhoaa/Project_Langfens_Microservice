import { z } from 'zod';
import { LocalIdSchema, RubricSchema, ScoringModeSchema } from './shared';

/* --------------------------------------------------------------------- */
/* 1. MULTIPLE_CHOICE_SINGLE                                              */
/* --------------------------------------------------------------------- */
export const multipleChoiceSingleAnswerSchema = z
  .object({
    type: z.literal('MULTIPLE_CHOICE_SINGLE'),
    correctOptionId: LocalIdSchema.describe('Id of the single correct option.'),
  })
  .strict();

/* --------------------------------------------------------------------- */
/* 2. MULTIPLE_CHOICE_SINGLE_IMAGE                                        */
/* --------------------------------------------------------------------- */
export const multipleChoiceSingleImageAnswerSchema = z
  .object({
    type: z.literal('MULTIPLE_CHOICE_SINGLE_IMAGE'),
    correctOptionId: LocalIdSchema.describe('Id of the single correct image option.'),
  })
  .strict();

/* --------------------------------------------------------------------- */
/* 3. MULTIPLE_CHOICE_MULTIPLE                                            */
/* --------------------------------------------------------------------- */
export const multipleChoiceMultipleAnswerSchema = z
  .object({
    type: z.literal('MULTIPLE_CHOICE_MULTIPLE'),
    correctOptionIds: z
      .array(LocalIdSchema)
      .min(1)
      .max(8)
      .refine((arr) => new Set(arr).size === arr.length, { message: 'correctOptionIds must be unique' })
      .describe('Ids of all correct options.'),
    scoring: ScoringModeSchema,
  })
  .strict();

/* --------------------------------------------------------------------- */
/* 4. TRUE_FALSE_NOT_GIVEN                                                */
/* --------------------------------------------------------------------- */
export const trueFalseNotGivenAnswerSchema = z
  .object({
    type: z.literal('TRUE_FALSE_NOT_GIVEN'),
    choice: z.enum(['TRUE', 'FALSE', 'NOT_GIVEN']).describe('The correct judgment for the statement.'),
  })
  .strict();

/* --------------------------------------------------------------------- */
/* 5. YES_NO_NOT_GIVEN                                                    */
/* --------------------------------------------------------------------- */
export const yesNoNotGivenAnswerSchema = z
  .object({
    type: z.literal('YES_NO_NOT_GIVEN'),
    choice: z.enum(['YES', 'NO', 'NOT_GIVEN']).describe('The correct judgment for the statement.'),
  })
  .strict();

/* --------------------------------------------------------------------- */
/* Shared completion answer shape                                         */
/* --------------------------------------------------------------------- */
const gapAnswersRecordSchema = z
  .record(
    z.string(),
    z
      .array(z.string().min(1))
      .min(1)
      .refine((arr) => new Set(arr).size === arr.length, { message: 'accepted answers must be unique' }),
  )
  .describe('Map of gap id to accepted answers. Keys are gap ids; values are accepted answer strings.');

/* --------------------------------------------------------------------- */
/* 6. SUMMARY_COMPLETION                                                  */
/* --------------------------------------------------------------------- */
export const summaryCompletionAnswerSchema = z
  .object({
    type: z.literal('SUMMARY_COMPLETION'),
    answers: gapAnswersRecordSchema,
  })
  .strict();

/* --------------------------------------------------------------------- */
/* 7. TABLE_COMPLETION                                                    */
/* --------------------------------------------------------------------- */
export const tableCompletionAnswerSchema = z
  .object({
    type: z.literal('TABLE_COMPLETION'),
    answers: gapAnswersRecordSchema,
  })
  .strict();

/* --------------------------------------------------------------------- */
/* 8. NOTE_COMPLETION                                                     */
/* --------------------------------------------------------------------- */
export const noteCompletionAnswerSchema = z
  .object({
    type: z.literal('NOTE_COMPLETION'),
    answers: gapAnswersRecordSchema,
  })
  .strict();

/* --------------------------------------------------------------------- */
/* 9. FORM_COMPLETION                                                     */
/* --------------------------------------------------------------------- */
export const formCompletionAnswerSchema = z
  .object({
    type: z.literal('FORM_COMPLETION'),
    answers: gapAnswersRecordSchema,
  })
  .strict();

/* --------------------------------------------------------------------- */
/* 10. SENTENCE_COMPLETION                                                */
/* --------------------------------------------------------------------- */
export const sentenceCompletionAnswerSchema = z
  .object({
    type: z.literal('SENTENCE_COMPLETION'),
    acceptedTexts: z
      .array(z.string().min(1))
      .min(1)
      .max(10)
      .refine((arr) => new Set(arr).size === arr.length, { message: 'acceptedTexts must be unique' })
      .describe('Literal answers accepted for the gap.'),
    acceptedRegexes: z
      .array(z.string().min(1))
      .max(5)
      .refine((arr) => new Set(arr).size === arr.length, { message: 'acceptedRegexes must be unique' })
      .optional()
      .describe('Optional regex patterns accepted for the gap.'),
  })
  .strict();

/* --------------------------------------------------------------------- */
/* 11. SHORT_ANSWER                                                       */
/* --------------------------------------------------------------------- */
export const shortAnswerAnswerSchema = z
  .object({
    type: z.literal('SHORT_ANSWER'),
    acceptedTexts: z
      .array(z.string().min(1))
      .min(1)
      .max(10)
      .refine((arr) => new Set(arr).size === arr.length, { message: 'acceptedTexts must be unique' })
      .describe('Literal answers accepted for this question.'),
    acceptedRegexes: z
      .array(z.string().min(1))
      .max(5)
      .refine((arr) => new Set(arr).size === arr.length, { message: 'acceptedRegexes must be unique' })
      .optional()
      .describe('Optional regex patterns accepted for this question.'),
  })
  .strict();

/* --------------------------------------------------------------------- */
/* 12. AUDIO_RESPONSE                                                     */
/* --------------------------------------------------------------------- */
export const audioResponseAnswerSchema = z
  .object({
    type: z.literal('AUDIO_RESPONSE'),
    acceptedTranscriptions: z
      .array(z.string().min(1))
      .min(1)
      .max(5)
      .refine((arr) => new Set(arr).size === arr.length, { message: 'acceptedTranscriptions must be unique' })
      .describe('Whitelisted reference transcriptions the learner response is matched against.'),
    modelTranscription: z
      .string()
      .optional()
      .describe('Optional canonical model transcription used as a reference answer.'),
    scoring: z
      .enum(['ai', 'human', 'ai+human'])
      .default('ai')
      .describe('Who scores the response: AI, human, or both.'),
    rubric: RubricSchema.optional().describe('Optional rubric used by AI or human raters.'),
  })
  .strict();

/* --------------------------------------------------------------------- */
/* 13. DIAGRAM_LABEL                                                      */
/* --------------------------------------------------------------------- */
export const diagramLabelAnswerSchema = z
  .object({
    type: z.literal('DIAGRAM_LABEL'),
    answers: z
      .record(
        z.string(),
        z
          .array(z.string().min(1))
          .min(1)
          .max(6)
          .refine((arr) => new Set(arr).size === arr.length, { message: 'accepted answers must be unique' }),
      )
      .describe('Map of gap id to accepted answers. Keys are gap ids.'),
  })
  .strict();

/* --------------------------------------------------------------------- */
/* 14. MAP_LABEL                                                          */
/* --------------------------------------------------------------------- */
export const mapLabelAnswerSchema = z
  .object({
    type: z.literal('MAP_LABEL'),
    answers: gapAnswersRecordSchema,
  })
  .strict();

/* --------------------------------------------------------------------- */
/* 15. MATCHING_HEADING                                                   */
/* --------------------------------------------------------------------- */
export const matchingHeadingAnswerSchema = z
  .object({
    type: z.literal('MATCHING_HEADING'),
    pairs: z
      .array(
        z
          .object({
            paragraphId: LocalIdSchema.describe('Id of the paragraph.'),
            headingId: LocalIdSchema.describe('Id of the heading that matches the paragraph.'),
          })
          .strict(),
      )
      .min(1)
      .max(14)
      .refine((arr) => new Set(arr.map((p) => `${p.paragraphId}|${p.headingId}`)).size === arr.length, {
        message: 'paragraph/heading pairs must be unique',
      })
      .describe('Correct paragraph-heading pairs.'),
    scoring: ScoringModeSchema,
  })
  .strict();

/* --------------------------------------------------------------------- */
/* 16. MATCHING_INFORMATION                                               */
/* --------------------------------------------------------------------- */
export const matchingInformationAnswerSchema = z
  .object({
    type: z.literal('MATCHING_INFORMATION'),
    pairs: z
      .array(
        z
          .object({
            questionId: LocalIdSchema.describe('Id of the question item.'),
            paragraphId: LocalIdSchema.describe('Id of the paragraph that contains the answer.'),
          })
          .strict(),
      )
      .min(1)
      .max(14)
      .refine((arr) => new Set(arr.map((p) => `${p.questionId}|${p.paragraphId}`)).size === arr.length, {
        message: 'question/paragraph pairs must be unique',
      })
      .describe('Correct question-paragraph pairs.'),
    scoring: ScoringModeSchema,
  })
  .strict();

/* --------------------------------------------------------------------- */
/* 17. MATCHING_FEATURES                                                  */
/* --------------------------------------------------------------------- */
export const matchingFeaturesAnswerSchema = z
  .object({
    type: z.literal('MATCHING_FEATURES'),
    pairs: z
      .array(
        z
          .object({
            itemId: LocalIdSchema.describe('Id of the item.'),
            featureId: LocalIdSchema.describe('Id of the matching feature.'),
          })
          .strict(),
      )
      .min(1)
      .max(20)
      .refine((arr) => new Set(arr.map((p) => `${p.itemId}|${p.featureId}`)).size === arr.length, {
        message: 'item/feature pairs must be unique',
      })
      .describe('Correct item-feature pairs.'),
    scoring: ScoringModeSchema,
  })
  .strict();

/* --------------------------------------------------------------------- */
/* 18. MATCHING_ENDINGS                                                   */
/* --------------------------------------------------------------------- */
export const matchingEndingsAnswerSchema = z
  .object({
    type: z.literal('MATCHING_ENDINGS'),
    pairs: z
      .array(
        z
          .object({
            beginId: LocalIdSchema.describe('Id of the sentence beginning.'),
            endId: LocalIdSchema.describe('Id of the matching sentence ending.'),
          })
          .strict(),
      )
      .min(1)
      .max(10)
      .refine((arr) => new Set(arr.map((p) => `${p.beginId}|${p.endId}`)).size === arr.length, {
        message: 'begin/end pairs must be unique',
      })
      .describe('Correct begin-end pairs.'),
    scoring: ScoringModeSchema,
  })
  .strict();

/* --------------------------------------------------------------------- */
/* 19. CLASSIFICATION                                                     */
/* --------------------------------------------------------------------- */
export const classificationAnswerSchema = z
  .object({
    type: z.literal('CLASSIFICATION'),
    pairs: z
      .array(
        z
          .object({
            itemId: LocalIdSchema.describe('Id of the classified item.'),
            categoryId: LocalIdSchema.describe('Id of the category the item belongs to.'),
          })
          .strict(),
      )
      .min(1)
      .max(20)
      .refine((arr) => new Set(arr.map((p) => `${p.itemId}|${p.categoryId}`)).size === arr.length, {
        message: 'item/category pairs must be unique',
      })
      .describe('Correct item-category assignments.'),
    scoring: ScoringModeSchema,
  })
  .strict();

/* --------------------------------------------------------------------- */
/* 20. FLOW_CHART                                                         */
/* --------------------------------------------------------------------- */
export const flowChartAnswerSchema = z
  .object({
    type: z.literal('FLOW_CHART'),
    order: z
      .array(LocalIdSchema)
      .min(2)
      .max(12)
      .refine((arr) => new Set(arr).size === arr.length, { message: 'order must be unique' })
      .describe('Correct node id sequence.'),
    scoring: z
      .enum(['exact', 'lcs', 'adjacent-swap-count'])
      .default('lcs')
      .describe('Algorithm used to score the learner ordering.'),
  })
  .strict();

/* --------------------------------------------------------------------- */
/* 21. FLOW_CHART_COMPLETION — security-fixed                             */
/* --------------------------------------------------------------------- */
const flowChartCompletionGapAnswerSchema = z
  .object({
    acceptedTexts: z
      .array(z.string().min(1))
      .min(1)
      .refine((arr) => new Set(arr).size === arr.length, { message: 'acceptedTexts must be unique' })
      .describe('Literal answers accepted for this gap.'),
    acceptedRegexes: z
      .array(z.string().min(1))
      .max(10)
      .refine((arr) => new Set(arr).size === arr.length, { message: 'acceptedRegexes must be unique' })
      .optional()
      .describe('Optional regex patterns accepted for this gap.'),
  })
  .strict();

export const flowChartCompletionAnswerSchema = z
  .object({
    type: z.literal('FLOW_CHART_COMPLETION'),
    order: z
      .array(LocalIdSchema)
      .min(2)
      .max(12)
      .refine((arr) => new Set(arr).size === arr.length, { message: 'order must be unique' })
      .describe('Correct node id sequence.'),
    gapAnswers: z
      .record(z.string(), flowChartCompletionGapAnswerSchema)
      .describe('Map of gap nodeId to its accepted answer bundle. Values MUST be objects, not bare arrays.'),
  })
  .strict();

/* --------------------------------------------------------------------- */
/* Discriminated union                                                    */
/* --------------------------------------------------------------------- */
export const AnswerSchema = z.discriminatedUnion('type', [
  multipleChoiceSingleAnswerSchema,
  multipleChoiceSingleImageAnswerSchema,
  multipleChoiceMultipleAnswerSchema,
  trueFalseNotGivenAnswerSchema,
  yesNoNotGivenAnswerSchema,
  summaryCompletionAnswerSchema,
  tableCompletionAnswerSchema,
  noteCompletionAnswerSchema,
  formCompletionAnswerSchema,
  sentenceCompletionAnswerSchema,
  shortAnswerAnswerSchema,
  audioResponseAnswerSchema,
  diagramLabelAnswerSchema,
  mapLabelAnswerSchema,
  matchingHeadingAnswerSchema,
  matchingInformationAnswerSchema,
  matchingFeaturesAnswerSchema,
  matchingEndingsAnswerSchema,
  classificationAnswerSchema,
  flowChartAnswerSchema,
  flowChartCompletionAnswerSchema,
]);

/** Lookup an answer schema by slug. */
export const AnswerSchemaBySlug = {
  MULTIPLE_CHOICE_SINGLE: multipleChoiceSingleAnswerSchema,
  MULTIPLE_CHOICE_SINGLE_IMAGE: multipleChoiceSingleImageAnswerSchema,
  MULTIPLE_CHOICE_MULTIPLE: multipleChoiceMultipleAnswerSchema,
  TRUE_FALSE_NOT_GIVEN: trueFalseNotGivenAnswerSchema,
  YES_NO_NOT_GIVEN: yesNoNotGivenAnswerSchema,
  SUMMARY_COMPLETION: summaryCompletionAnswerSchema,
  TABLE_COMPLETION: tableCompletionAnswerSchema,
  NOTE_COMPLETION: noteCompletionAnswerSchema,
  FORM_COMPLETION: formCompletionAnswerSchema,
  SENTENCE_COMPLETION: sentenceCompletionAnswerSchema,
  SHORT_ANSWER: shortAnswerAnswerSchema,
  AUDIO_RESPONSE: audioResponseAnswerSchema,
  DIAGRAM_LABEL: diagramLabelAnswerSchema,
  MAP_LABEL: mapLabelAnswerSchema,
  MATCHING_HEADING: matchingHeadingAnswerSchema,
  MATCHING_INFORMATION: matchingInformationAnswerSchema,
  MATCHING_FEATURES: matchingFeaturesAnswerSchema,
  MATCHING_ENDINGS: matchingEndingsAnswerSchema,
  CLASSIFICATION: classificationAnswerSchema,
  FLOW_CHART: flowChartAnswerSchema,
  FLOW_CHART_COMPLETION: flowChartCompletionAnswerSchema,
} as const;
