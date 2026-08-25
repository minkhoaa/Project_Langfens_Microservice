import { z } from 'zod';
import {
  BasePayloadSchema,
  GapSchema,
  LocalIdSchema,
  NormalizationSchema,
  OptionSchema,
  ScoringModeSchema,
} from './shared';

/* --------------------------------------------------------------------- */
/* Helpers shared across many types                                       */
/* --------------------------------------------------------------------- */

const imageOptionSchema = OptionSchema.extend({
  mediaUrl: z.string().url().describe('Image URL for this option.'),
  altText: z.string().min(1).describe('Alt text describing the image, required for accessibility.'),
}).strict();

const normalizedBoxSchema = z
  .object({
    x: z.number().min(0).max(1).describe('Top-left X in normalized coordinates.'),
    y: z.number().min(0).max(1).describe('Top-left Y in normalized coordinates.'),
    w: z.number().min(0).max(1).describe('Width in normalized coordinates.'),
    h: z.number().min(0).max(1).describe('Height in normalized coordinates.'),
  })
  .strict();

const flowChartNodeSchema = z
  .object({
    id: LocalIdSchema.describe('Stable identifier for this node.'),
    label: z.string().min(1).describe('Node label shown to the learner.'),
    position: z
      .object({
        x: z.number().describe('X coordinate in arbitrary units.'),
        y: z.number().describe('Y coordinate in arbitrary units.'),
      })
      .strict()
      .describe('Layout position for rendering the flow chart.'),
  })
  .strict();

const flowChartEdgeSchema = z
  .object({
    from: LocalIdSchema.describe('Id of the source node.'),
    to: LocalIdSchema.describe('Id of the destination node.'),
  })
  .strict()
  .describe('Directed edge between two nodes.');

/* --------------------------------------------------------------------- */
/* 1. MULTIPLE_CHOICE_SINGLE                                              */
/* --------------------------------------------------------------------- */
export const multipleChoiceSinglePayloadSchema = BasePayloadSchema.extend({
  type: z.literal('MULTIPLE_CHOICE_SINGLE'),
  options: z
    .array(OptionSchema)
    .min(2)
    .max(6)
    .refine((arr) => new Set(arr.map((o) => o.id)).size === arr.length, {
      message: 'option ids must be unique',
    })
    .describe('Exactly one of these options is correct.'),
});

/* --------------------------------------------------------------------- */
/* 2. MULTIPLE_CHOICE_SINGLE_IMAGE                                        */
/* --------------------------------------------------------------------- */
export const multipleChoiceSingleImagePayloadSchema = BasePayloadSchema.extend({
  type: z.literal('MULTIPLE_CHOICE_SINGLE_IMAGE'),
  options: z
    .array(imageOptionSchema)
    .min(2)
    .max(6)
    .refine((arr) => new Set(arr.map((o) => o.id)).size === arr.length, {
      message: 'option ids must be unique',
    })
    .describe('Image options; each must carry a mediaUrl and altText.'),
});

/* --------------------------------------------------------------------- */
/* 3. MULTIPLE_CHOICE_MULTIPLE                                            */
/* --------------------------------------------------------------------- */
/** Object form used both by the discriminated union and by the deprecated alias extension. */
const multipleChoiceMultiplePayloadObject = BasePayloadSchema.extend({
  type: z.literal('MULTIPLE_CHOICE_MULTIPLE'),
  options: z
    .array(OptionSchema)
    .min(2)
    .max(8)
    .refine((arr) => new Set(arr.map((o) => o.id)).size === arr.length, {
      message: 'option ids must be unique',
    })
    .describe('Candidate options; one or more are correct.'),
  minSelections: z.number().int().min(1).describe('Minimum number of options the learner must select.'),
  maxSelections: z.number().int().min(1).describe('Maximum number of options the learner may select.'),
});

export const multipleChoiceMultiplePayloadSchema = multipleChoiceMultiplePayloadObject.refine(
  (d) => d.minSelections <= d.maxSelections && d.maxSelections <= d.options.length,
  { message: 'min/max selections must satisfy 1 <= min <= max <= options.length' },
);

/** Object form (without the cross-field refine) for extension by deprecated aliases / the discriminated union. */
export const multipleChoiceMultiplePayloadObjectSchema = multipleChoiceMultiplePayloadObject;


/* --------------------------------------------------------------------- */
/* 4. TRUE_FALSE_NOT_GIVEN                                                */
/* --------------------------------------------------------------------- */
export const trueFalseNotGivenPayloadSchema = BasePayloadSchema.extend({
  type: z.literal('TRUE_FALSE_NOT_GIVEN'),
  statement: z.string().min(1).describe('Statement the learner must judge as TRUE, FALSE, or NOT GIVEN.'),
  options: z
    .array(
      z
        .object({
          id: z.enum(['t', 'f', 'ng']).describe('Canonical id for TRUE (t), FALSE (f), NOT GIVEN (ng).'),
          idx: z.number().int().min(0).max(2).describe('Zero-based display index of the option.'),
          contentMd: z.string().min(1).describe('Label rendered for this option.'),

        })
        .strict(),
    )
    .length(3)
    .refine((arr) => new Set(arr.map((o) => o.id)).size === arr.length, {
      message: 'option ids must be unique',
    })
    .describe('Exactly three options with ids constrained to t, f, ng.'),
});

/* --------------------------------------------------------------------- */
/* 5. YES_NO_NOT_GIVEN                                                    */
/* --------------------------------------------------------------------- */
export const yesNoNotGivenPayloadSchema = BasePayloadSchema.extend({
  type: z.literal('YES_NO_NOT_GIVEN'),
  statement: z.string().min(1).describe('Statement the learner must judge as YES, NO, or NOT GIVEN.'),
  options: z
    .array(
      z
        .object({
          id: z.enum(['y', 'n', 'ng']).describe('Canonical id for YES (y), NO (n), NOT GIVEN (ng).'),
          idx: z.number().int().min(0).max(2).describe('Zero-based display index of the option.'),
          contentMd: z.string().min(1).describe('Label rendered for this option.'),
        })
        .strict(),
    )
    .length(3)
    .refine((arr) => new Set(arr.map((o) => o.id)).size === arr.length, {
      message: 'option ids must be unique',
    })
    .describe('Exactly three options with ids constrained to y, n, ng.'),
});

/* --------------------------------------------------------------------- */
/* 6. SUMMARY_COMPLETION                                                  */
/* --------------------------------------------------------------------- */
export const summaryCompletionPayloadSchema = BasePayloadSchema.extend({
  type: z.literal('SUMMARY_COMPLETION'),
  gaps: z
    .array(GapSchema)
    .min(1)
    .max(10)
    .refine((arr) => new Set(arr.map((g) => g.id)).size === arr.length, { message: 'gap ids must be unique' })
    .describe('Gaps embedded in the summary passage.'),
});

/* --------------------------------------------------------------------- */
/* 7. TABLE_COMPLETION                                                    */
/* --------------------------------------------------------------------- */
export const tableCompletionPayloadSchema = BasePayloadSchema.extend({
  type: z.literal('TABLE_COMPLETION'),
  cells: z
    .array(
      z
        .object({
          rowId: LocalIdSchema.describe('Id of the row containing the cell.'),
          colId: LocalIdSchema.describe('Id of the column containing the cell.'),
          gapId: LocalIdSchema.describe('Id of the gap occupying the cell.'),
        })
        .strict(),
    )
    .min(1)
    .max(50)
    .refine((arr) => new Set(arr.map((c) => `${c.rowId}/${c.colId}`)).size === arr.length, {
      message: 'cell rowId/colId pairs must be unique',
    })
    .describe('Cells that contain a gap; one entry per gap.'),
  gaps: z
    .array(GapSchema)
    .min(1)
    .max(30)
    .refine((arr) => new Set(arr.map((g) => g.id)).size === arr.length, { message: 'gap ids must be unique' })
    .describe('Gap definitions referenced by cell gapIds.'),
});

/* --------------------------------------------------------------------- */
/* 8. NOTE_COMPLETION                                                     */
/* --------------------------------------------------------------------- */
export const noteCompletionPayloadSchema = BasePayloadSchema.extend({
  type: z.literal('NOTE_COMPLETION'),
  gaps: z
    .array(GapSchema)
    .min(1)
    .max(10)
    .refine((arr) => new Set(arr.map((g) => g.id)).size === arr.length, { message: 'gap ids must be unique' })
    .describe('Gaps embedded in the notes passage.'),
});

/* --------------------------------------------------------------------- */
/* 9. FORM_COMPLETION                                                     */
/* --------------------------------------------------------------------- */
export const formCompletionPayloadSchema = BasePayloadSchema.extend({
  type: z.literal('FORM_COMPLETION'),
  gaps: z
    .array(GapSchema)
    .min(1)
    .max(10)
    .refine((arr) => new Set(arr.map((g) => g.id)).size === arr.length, { message: 'gap ids must be unique' })
    .describe('Gaps embedded in form fields. Setting expectedKind is recommended for date/number fields.'),
});

/* --------------------------------------------------------------------- */
/* 10. SENTENCE_COMPLETION                                                */
/* --------------------------------------------------------------------- */
export const sentenceCompletionPayloadSchema = BasePayloadSchema.extend({
  type: z.literal('SENTENCE_COMPLETION'),
  gap: GapSchema.describe('Single gap definition for the sentence.'),
});

/* --------------------------------------------------------------------- */
/* 11. SHORT_ANSWER                                                       */
/* --------------------------------------------------------------------- */
export const shortAnswerPayloadSchema = BasePayloadSchema.extend({
  type: z.literal('SHORT_ANSWER'),
  wordLimit: z.number().int().min(1).optional().describe('Maximum number of words allowed in the response.'),
  normalization: NormalizationSchema.optional().describe('Normalization applied to the response before matching.'),
});

/* --------------------------------------------------------------------- */
/* 12. AUDIO_RESPONSE                                                     */
/* --------------------------------------------------------------------- */
export const audioResponsePayloadSchema = BasePayloadSchema.extend({
  type: z.literal('AUDIO_RESPONSE'),
  maxDurationSec: z
    .number()
    .int()
    .min(1)
    .max(600)
    .describe('Maximum recording length, in seconds (1 second to 10 minutes).'),
  promptAudioUrl: z
    .string()
    .url()
    .optional()
    .describe('Optional audio prompt the learner hears before recording.'),
});

/* --------------------------------------------------------------------- */
/* 13. DIAGRAM_LABEL                                                      */
/* --------------------------------------------------------------------- */
export const diagramLabelPayloadSchema = BasePayloadSchema.extend({
  type: z.literal('DIAGRAM_LABEL'),
  diagramImageUrl: z.string().url().describe('URL of the diagram image.'),
  diagramAltText: z.string().min(1).describe('Alt text describing the diagram for screen readers.'),
  labels: z
    .array(
      z
        .object({
          id: LocalIdSchema.describe('Stable identifier for this label.'),
          text: z.string().min(1).describe('Pre-printed label text shown on the diagram.'),
          region: normalizedBoxSchema.describe('Bounding box of the label as a fraction of the image.'),
        })
        .strict(),
    )
    .min(1)
    .max(12)
    .refine((arr) => new Set(arr.map((l) => l.id)).size === arr.length, { message: 'label ids must be unique' })
    .describe('Pre-printed labels on the diagram.'),
  gaps: z
    .array(GapSchema)
    .min(1)
    .max(12)
    .refine((arr) => new Set(arr.map((g) => g.id)).size === arr.length, { message: 'gap ids must be unique' })
    .describe('Gaps the learner must fill in for each label region.'),
});

/* --------------------------------------------------------------------- */
/* 14. MAP_LABEL                                                          */
/* --------------------------------------------------------------------- */
export const mapLabelPayloadSchema = BasePayloadSchema.extend({
  type: z.literal('MAP_LABEL'),
  diagramImageUrl: z.string().url().describe('URL of the map image.'),
  diagramAltText: z.string().min(1).describe('Alt text describing the map for screen readers.'),
  labels: z
    .array(
      z
        .object({
          id: LocalIdSchema.describe('Stable identifier for this label.'),
          text: z.string().min(1).describe('Pre-printed label text shown on the map.'),
          region: normalizedBoxSchema.describe('Bounding box of the label as a fraction of the image.'),
        })
        .strict(),
    )
    .min(1)
    .max(12)
    .refine((arr) => new Set(arr.map((l) => l.id)).size === arr.length, { message: 'label ids must be unique' })
    .describe('Pre-printed labels on the map.'),
  gaps: z
    .array(GapSchema)
    .min(1)
    .max(12)
    .refine((arr) => new Set(arr.map((g) => g.id)).size === arr.length, { message: 'gap ids must be unique' })
    .describe('Gaps the learner must fill in for each label region.'),
});

/* --------------------------------------------------------------------- */
/* 15. MATCHING_HEADING                                                   */
/* --------------------------------------------------------------------- */
const romanNumeralSchema = z
  .enum(['i', 'ii', 'iii', 'iv', 'v', 'vi', 'vii', 'viii', 'ix', 'x', 'xi', 'xii', 'xiii', 'xiv'])
  .describe('Roman numeral label shown next to the paragraph.');

export const matchingHeadingPayloadSchema = BasePayloadSchema.extend({
  type: z.literal('MATCHING_HEADING'),
  paragraphs: z
    .array(
      z
        .object({
          id: LocalIdSchema.describe('Stable identifier for this paragraph.'),
          romanNumeral: romanNumeralSchema,
        })
        .strict(),
    )
    .min(2)
    .max(14)
    .refine((arr) => new Set(arr.map((p) => p.id)).size === arr.length, { message: 'paragraph ids must be unique' })
    .describe('Paragraphs to be matched.'),
  headings: z
    .array(
      z
        .object({
          id: LocalIdSchema.describe('Stable identifier for this heading.'),
          text: z.string().min(1).describe('Heading text.'),
        })
        .strict(),
    )
    .min(2)
    .max(14)
    .refine((arr) => new Set(arr.map((h) => h.id)).size === arr.length, { message: 'heading ids must be unique' })
    .describe('Candidate headings.'),
  arity: z
    .enum(['1-1', '1-many'])
    .default('1-1')
    .describe('Whether each heading may be used at most once or may be reused across paragraphs.'),
});

/* --------------------------------------------------------------------- */
/* 16. MATCHING_INFORMATION                                               */
/* --------------------------------------------------------------------- */
export const matchingInformationPayloadSchema = BasePayloadSchema.extend({
  type: z.literal('MATCHING_INFORMATION'),
  paragraphs: z
    .array(
      z
        .object({
          id: LocalIdSchema.describe('Stable identifier for this paragraph.'),
          label: z.string().min(1).describe("Display label shown next to the paragraph (e.g. 'A', 'B')."),
        })
        .strict(),
    )
    .min(2)
    .max(14)
    .refine((arr) => new Set(arr.map((p) => p.id)).size === arr.length, { message: 'paragraph ids must be unique' })
    .describe('Candidate paragraphs.'),
  questions: z
    .array(
      z
        .object({
          id: LocalIdSchema.describe('Stable identifier for this question item.'),
          prompt: z.string().min(1).describe('Prompt text describing what information to locate.'),
        })
        .strict(),
    )
    .min(1)
    .max(14)
    .refine((arr) => new Set(arr.map((q) => q.id)).size === arr.length, { message: 'question ids must be unique' })
    .describe('Question items to be matched to paragraphs.'),
  allowReuse: z
    .boolean()
    .default(false)
    .describe('Whether a paragraph may be the correct answer for more than one question.'),
});

/* --------------------------------------------------------------------- */
/* 17. MATCHING_FEATURES                                                  */
/* --------------------------------------------------------------------- */
export const matchingFeaturesPayloadSchema = BasePayloadSchema.extend({
  type: z.literal('MATCHING_FEATURES'),
  items: z
    .array(
      z
        .object({
          id: LocalIdSchema.describe('Stable identifier for this item.'),
          text: z.string().min(1).describe('Item text shown to the learner.'),
        })
        .strict(),
    )
    .min(1)
    .max(20)
    .refine((arr) => new Set(arr.map((i) => i.id)).size === arr.length, { message: 'item ids must be unique' })
    .describe('Items to be matched to features.'),
  features: z
    .array(
      z
        .object({
          id: LocalIdSchema.describe('Stable identifier for this feature.'),
          label: z.string().min(1).describe('Feature label shown to the learner.'),
        })
        .strict(),
    )
    .min(2)
    .max(10)
    .refine((arr) => new Set(arr.map((f) => f.id)).size === arr.length, { message: 'feature ids must be unique' })
    .describe('Candidate features.'),
  allowReuse: z
    .boolean()
    .default(true)
    .describe('Whether a feature may be matched to more than one item.'),
});

/* --------------------------------------------------------------------- */
/* 18. MATCHING_ENDINGS                                                   */
/* --------------------------------------------------------------------- */
export const matchingEndingsPayloadSchema = BasePayloadSchema.extend({
  type: z.literal('MATCHING_ENDINGS'),
  beginnings: z
    .array(
      z
        .object({
          id: LocalIdSchema.describe('Stable identifier for this sentence beginning.'),
          text: z.string().min(1).describe('Sentence beginning text.'),
        })
        .strict(),
    )
    .min(1)
    .max(10)
    .refine((arr) => new Set(arr.map((b) => b.id)).size === arr.length, {
      message: 'beginning ids must be unique',
    })
    .describe('Sentence beginnings to be completed.'),
  endings: z
    .array(
      z
        .object({
          id: LocalIdSchema.describe('Stable identifier for this sentence ending.'),
          text: z.string().min(1).describe('Sentence ending text.'),
        })
        .strict(),
    )
    .min(2)
    .max(10)
    .refine((arr) => new Set(arr.map((e) => e.id)).size === arr.length, { message: 'ending ids must be unique' })
    .describe('Candidate sentence endings.'),
});

/* --------------------------------------------------------------------- */
/* 19. CLASSIFICATION                                                     */
/* --------------------------------------------------------------------- */
export const classificationPayloadSchema = BasePayloadSchema.extend({
  type: z.literal('CLASSIFICATION'),
  items: z
    .array(
      z
        .object({
          id: LocalIdSchema.describe('Stable identifier for this item.'),
          text: z.string().min(1).describe('Item text shown to the learner.'),
        })
        .strict(),
    )
    .min(1)
    .max(20)
    .refine((arr) => new Set(arr.map((i) => i.id)).size === arr.length, { message: 'item ids must be unique' })
    .describe('Items to be classified.'),
  categories: z
    .array(
      z
        .object({
          id: LocalIdSchema.describe('Stable identifier for this category.'),
          label: z.string().min(1).describe('Category label shown to the learner.'),
        })
        .strict(),
    )
    .min(2)
    .max(10)
    .refine((arr) => new Set(arr.map((c) => c.id)).size === arr.length, { message: 'category ids must be unique' })
    .describe('Candidate categories.'),
});

/* --------------------------------------------------------------------- */
/* 20. FLOW_CHART                                                         */
/* --------------------------------------------------------------------- */
export const flowChartPayloadSchema = BasePayloadSchema.extend({
  type: z.literal('FLOW_CHART'),
  nodes: z
    .array(flowChartNodeSchema)
    .min(2)
    .max(12)
    .refine((arr) => new Set(arr.map((n) => n.id)).size === arr.length, { message: 'node ids must be unique' })
    .describe('Nodes comprising the flow chart.'),
  edges: z
    .array(flowChartEdgeSchema)
    .max(24)
    .describe('Directed edges between nodes (informational; grading uses the order array).'),
});

/* --------------------------------------------------------------------- */
/* 21. FLOW_CHART_COMPLETION — security-fixed shape                       */
/* --------------------------------------------------------------------- */
const flowChartCompletionGapSchema = z
  .object({
    nodeId: LocalIdSchema.describe('Id of the node containing the gap.'),
    wordLimit: z.number().int().min(1).optional().describe('Maximum number of words allowed in the learner response.'),
    expectedKind: z
      .enum(['text', 'date', 'number'])
      .optional()
      .describe('Expected semantic kind of the accepted answer.'),
    normalization: NormalizationSchema.optional().describe('Normalization applied to learner input before matching.'),
  })
  .strict()
  .describe(
    'Flow-chart-completion payload gap descriptor. Accepted answers live in CorrectAnswer.gapAnswers; the payload gap only describes WHERE the gap is.',
  );

const flowChartCompletionPayloadObject = BasePayloadSchema.extend({
  type: z.literal('FLOW_CHART_COMPLETION'),
  nodes: z
    .array(flowChartNodeSchema)
    .min(2)
    .max(12)
    .refine((arr) => new Set(arr.map((n) => n.id)).size === arr.length, { message: 'node ids must be unique' })
    .describe('Nodes comprising the flow chart.'),
  edges: z.array(flowChartEdgeSchema).max(24).describe('Directed edges between nodes.'),
  gaps: z
    .array(flowChartCompletionGapSchema)
    .min(1)
    .max(12)
    .refine((arr) => new Set(arr.map((g) => g.nodeId)).size === arr.length, { message: 'gap nodeIds must be unique' })
    .describe('Gaps embedded in nodes. Accepted answers live in CorrectAnswer.gapAnswers.'),
});

export const flowChartCompletionPayloadSchema = flowChartCompletionPayloadObject.refine(
  (d) => {
    const nodeIds = new Set(d.nodes.map((n) => n.id));
    for (const gap of d.gaps) {
      if (!nodeIds.has(gap.nodeId)) return false;
    }
    const edgeIds = new Set<string>();
    for (const edge of d.edges) {
      if (!nodeIds.has(edge.from) || !nodeIds.has(edge.to)) return false;
      const key = `${edge.from}>${edge.to}`;
      if (edgeIds.has(key)) return false;
      edgeIds.add(key);
    }
    return true;
  },
  { message: 'edges and gaps must reference existing node ids and edges must be unique' },
);

/** Object form (without the cross-field refine) — used by the discriminated union. */
export const flowChartCompletionPayloadObjectSchema = flowChartCompletionPayloadObject;

/** Ordered list of all 21 payload schemas, used as the payloadSchemas registry.
 *  `multipleChoiceMultiple` and `flowChartCompletion` use the object-form schemas
 *  (no cross-field refine) so Zod's `discriminatedUnion` can read the literal
 *  `type` discriminator directly.
 */
export const payloadSchemas = [
  multipleChoiceSinglePayloadSchema,
  multipleChoiceSingleImagePayloadSchema,
  multipleChoiceMultiplePayloadObjectSchema,
  trueFalseNotGivenPayloadSchema,
  yesNoNotGivenPayloadSchema,
  summaryCompletionPayloadSchema,
  tableCompletionPayloadSchema,
  noteCompletionPayloadSchema,
  formCompletionPayloadSchema,
  sentenceCompletionPayloadSchema,
  shortAnswerPayloadSchema,
  audioResponsePayloadSchema,
  diagramLabelPayloadSchema,
  mapLabelPayloadSchema,
  matchingHeadingPayloadSchema,
  matchingInformationPayloadSchema,
  matchingFeaturesPayloadSchema,
  matchingEndingsPayloadSchema,
  classificationPayloadSchema,
  flowChartPayloadSchema,
  flowChartCompletionPayloadObjectSchema,
];

/** Discriminated union over the 21 question payload schemas. */
export const QuestionPayloadSchema = z.discriminatedUnion('type', [
  multipleChoiceSinglePayloadSchema,
  multipleChoiceSingleImagePayloadSchema,
  multipleChoiceMultiplePayloadObjectSchema,
  trueFalseNotGivenPayloadSchema,
  yesNoNotGivenPayloadSchema,
  summaryCompletionPayloadSchema,
  tableCompletionPayloadSchema,
  noteCompletionPayloadSchema,
  formCompletionPayloadSchema,
  sentenceCompletionPayloadSchema,
  shortAnswerPayloadSchema,
  audioResponsePayloadSchema,
  diagramLabelPayloadSchema,
  mapLabelPayloadSchema,
  matchingHeadingPayloadSchema,
  matchingInformationPayloadSchema,
  matchingFeaturesPayloadSchema,
  matchingEndingsPayloadSchema,
  classificationPayloadSchema,
  flowChartPayloadSchema,
  flowChartCompletionPayloadObjectSchema,
]);

/** Lookup a payload schema by slug. */
export const PayloadSchemaBySlug = {
  MULTIPLE_CHOICE_SINGLE: multipleChoiceSinglePayloadSchema,
  MULTIPLE_CHOICE_SINGLE_IMAGE: multipleChoiceSingleImagePayloadSchema,
  MULTIPLE_CHOICE_MULTIPLE: multipleChoiceMultiplePayloadSchema,
  TRUE_FALSE_NOT_GIVEN: trueFalseNotGivenPayloadSchema,
  YES_NO_NOT_GIVEN: yesNoNotGivenPayloadSchema,
  SUMMARY_COMPLETION: summaryCompletionPayloadSchema,
  TABLE_COMPLETION: tableCompletionPayloadSchema,
  NOTE_COMPLETION: noteCompletionPayloadSchema,
  FORM_COMPLETION: formCompletionPayloadSchema,
  SENTENCE_COMPLETION: sentenceCompletionPayloadSchema,
  SHORT_ANSWER: shortAnswerPayloadSchema,
  AUDIO_RESPONSE: audioResponsePayloadSchema,
  DIAGRAM_LABEL: diagramLabelPayloadSchema,
  MAP_LABEL: mapLabelPayloadSchema,
  MATCHING_HEADING: matchingHeadingPayloadSchema,
  MATCHING_INFORMATION: matchingInformationPayloadSchema,
  MATCHING_FEATURES: matchingFeaturesPayloadSchema,
  MATCHING_ENDINGS: matchingEndingsPayloadSchema,
  CLASSIFICATION: classificationPayloadSchema,
  FLOW_CHART: flowChartPayloadSchema,
  FLOW_CHART_COMPLETION: flowChartCompletionPayloadSchema,
} as const;
