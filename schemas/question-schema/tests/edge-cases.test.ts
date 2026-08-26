import { describe, it, expect } from 'vitest';
import {
  AnswerSchemaBySlug,
  PayloadSchemaBySlug,
  diagramLabelPayloadSchema,
  diagramLabelPayloadValidatedSchema,
  flowChartCompletionAnswerSchema,
  flowChartCompletionEnvelopeSchema,
  flowChartCompletionPayloadSchema,
  flowChartEnvelopeSchema,
  flowChartPayloadSchema,
  flowChartPayloadValidatedSchema,
  mapLabelPayloadValidatedSchema,
  matchingHeadingEnvelopeSchema,
  matchingHeadingPayloadSchema,
  matchingInformationEnvelopeSchema,
  multipleChoiceMultipleEnvelopeSchema,
  multipleChoiceMultiplePayloadSchema,
  multipleChoiceSinglePayloadSchema,
  sentenceCompletionPayloadValidatedSchema,
  shortAnswerPayloadSchema,
  audioResponsePayloadSchema,
  summaryCompletionPayloadSchema,
  summaryCompletionPayloadValidatedSchema,
  trueFalseNotGivenPayloadSchema,
} from '../src';
import { samples } from './samples';

/** Deep-clone a sample, then mutate it. structuredClone avoids shallow-copy
 * aliasing between tests (e.g. when a prior test reassigned `payload.options`). */
function mutate<T>(obj: T, mutator: (draft: Record<string, unknown>) => void): T {
  const draft = structuredClone(obj as unknown);
  mutator(draft as Record<string, unknown>);
  return draft as T;
}

describe('edge cases per type', () => {
  it('MULTIPLE_CHOICE_MULTIPLE: rejects when minSelections > maxSelections', () => {
    const sample = mutate(samples.MULTIPLE_CHOICE_MULTIPLE.payload, (d) => {
      d['minSelections'] = 3;
      d['maxSelections'] = 2;
    });
    expect(multipleChoiceMultiplePayloadSchema.safeParse(sample).success).toBe(false);
  });

  it('MULTIPLE_CHOICE_MULTIPLE: rejects when maxSelections > options.length', () => {
    const sample = mutate(samples.MULTIPLE_CHOICE_MULTIPLE.payload, (d) => {
      d['maxSelections'] = 99;
    });
    expect(multipleChoiceMultiplePayloadSchema.safeParse(sample).success).toBe(false);
  });

  it('MULTIPLE_CHOICE_SINGLE: rejects duplicate option ids', () => {
    const sample = mutate(samples.MULTIPLE_CHOICE_SINGLE.payload, (d) => {
      const options = d['options'] as Array<Record<string, unknown>>;
      options[1]['id'] = 'opt_1';
    });
    expect(multipleChoiceSinglePayloadSchema.safeParse(sample).success).toBe(false);
  });

  it('MULTIPLE_CHOICE_SINGLE: rejects when fewer than 2 options', () => {
    const sample = mutate(samples.MULTIPLE_CHOICE_SINGLE.payload, (d) => {
      const options = d['options'] as Array<unknown>;
      d['options'] = [options[0]];
    });
    expect(multipleChoiceSinglePayloadSchema.safeParse(sample).success).toBe(false);
  });

  it('MULTIPLE_CHOICE_SINGLE: rejects when more than 6 options', () => {
    const sample = mutate(samples.MULTIPLE_CHOICE_SINGLE.payload, (d) => {
      d['options'] = [
        { id: 'opt_1', idx: 0, contentMd: 'A' },
        { id: 'opt_2', idx: 1, contentMd: 'B' },
        { id: 'opt_3', idx: 2, contentMd: 'C' },
        { id: 'opt_4', idx: 3, contentMd: 'D' },
        { id: 'opt_5', idx: 4, contentMd: 'E' },
        { id: 'opt_6', idx: 5, contentMd: 'F' },
        { id: 'opt_7', idx: 6, contentMd: 'G' },
      ];
    });
    expect(multipleChoiceSinglePayloadSchema.safeParse(sample).success).toBe(false);
  });

  it('SUMMARY_COMPLETION: rejects empty gaps', () => {
    const sample = mutate(samples.SUMMARY_COMPLETION.payload, (d) => {
      d['gaps'] = [];
    });
    expect(summaryCompletionPayloadSchema.safeParse(sample).success).toBe(false);
  });

  it('SENTENCE_COMPLETION: requires a gap', () => {
    const sample = mutate(samples.SENTENCE_COMPLETION.payload, (d) => {
      delete d['gap'];
    });
    const result = PayloadSchemaBySlug.SENTENCE_COMPLETION.safeParse(sample);
    expect(result.success).toBe(false);
  });

  it('SHORT_ANSWER: rejects wordLimit = 0', () => {
    const sample = mutate(samples.SHORT_ANSWER.payload, (d) => {
      d['wordLimit'] = 0;
    });
    expect(shortAnswerPayloadSchema.safeParse(sample).success).toBe(false);
  });

  it('AUDIO_RESPONSE: rejects maxDurationSec = 0', () => {
    const sample = mutate(samples.AUDIO_RESPONSE.payload, (d) => {
      d['maxDurationSec'] = 0;
    });
    expect(audioResponsePayloadSchema.safeParse(sample).success).toBe(false);
  });

  it('AUDIO_RESPONSE: rejects maxDurationSec > 600', () => {
    const sample = mutate(samples.AUDIO_RESPONSE.payload, (d) => {
      d['maxDurationSec'] = 601;
    });
    expect(audioResponsePayloadSchema.safeParse(sample).success).toBe(false);
  });

  it('FLOW_CHART: rejects duplicate node ids', () => {
    const sample = mutate(samples.FLOW_CHART.payload, (d) => {
      const nodes = d['nodes'] as Array<Record<string, unknown>>;
      nodes[1]['id'] = 'n_1';
    });
    expect(flowChartPayloadSchema.safeParse(sample).success).toBe(false);
  });

  it('FLOW_CHART: rejects edges referencing unknown nodes', () => {
    const sample = mutate(samples.FLOW_CHART.payload, (d) => {
      const edges = d['edges'] as Array<unknown>;
      (edges as Array<Record<string, unknown>>).push({ from: 'n_1', to: 'n_unknown' });
    });
    expect(flowChartPayloadValidatedSchema.safeParse(sample).success).toBe(false);
  });

  it('FLOW_CHART_COMPLETION: rejects duplicate node ids', () => {
    const sample = mutate(samples.FLOW_CHART_COMPLETION.payload, (d) => {
      const nodes = d['nodes'] as Array<Record<string, unknown>>;
      nodes[1]['id'] = 'n_1';
    });
    expect(flowChartCompletionPayloadSchema.safeParse(sample).success).toBe(false);
  });

  it('FLOW_CHART_COMPLETION: rejects gaps referencing unknown nodes', () => {
    const sample = mutate(samples.FLOW_CHART_COMPLETION.payload, (d) => {
      const gaps = d['gaps'] as Array<Record<string, unknown>>;
      gaps.push({ nodeId: 'n_unknown' });
    });
    expect(flowChartCompletionPayloadSchema.safeParse(sample).success).toBe(false);
  });

  it('DIAGRAM_LABEL: rejects region w > 1', () => {
    const sample = mutate(samples.DIAGRAM_LABEL.payload, (d) => {
      const labels = d['labels'] as Array<{ region: Record<string, unknown> }>;
      labels[0].region['w'] = 1.5;
    });
    expect(diagramLabelPayloadSchema.safeParse(sample).success).toBe(false);
  });

  it('DIAGRAM_LABEL: rejects region h > 1', () => {
    const sample = mutate(samples.DIAGRAM_LABEL.payload, (d) => {
      const labels = d['labels'] as Array<{ region: Record<string, unknown> }>;
      labels[0].region['h'] = 2;
    });
    expect(diagramLabelPayloadSchema.safeParse(sample).success).toBe(false);
  });

  it('TRUE_FALSE_NOT_GIVEN: rejects non-canonical 3 options', () => {
    const sample = mutate(samples.TRUE_FALSE_NOT_GIVEN.payload, (d) => {
      d['options'] = [(d['options'] as Array<unknown>)[0]];
    });
    expect(trueFalseNotGivenPayloadSchema.safeParse(sample).success).toBe(false);
  });

  it('TRUE_FALSE_NOT_GIVEN: accepts the canonical 3 options', () => {
    expect(trueFalseNotGivenPayloadSchema.safeParse(samples.TRUE_FALSE_NOT_GIVEN.payload).success).toBe(true);
  });

  it('MATCHING_HEADING: rejects paragraphs with only 1 entry', () => {
    const sample = mutate(samples.MATCHING_HEADING.payload, (d) => {
      d['paragraphs'] = [(d['paragraphs'] as Array<unknown>)[0]];
    });
    expect(matchingHeadingPayloadSchema.safeParse(sample).success).toBe(false);
  });
});

describe('FLOW_CHART_COMPLETION security regression tests', () => {
  it('REJECTS payload.gaps with acceptedTexts (must NOT be allowed post-fix)', () => {
    const sample = mutate(samples.FLOW_CHART_COMPLETION.payload, (d) => {
      const gaps = d['gaps'] as Array<Record<string, unknown>>;
      gaps[0]['acceptedTexts'] = ['leaked-text'];
    });
    expect(flowChartCompletionPayloadSchema.safeParse(sample).success).toBe(false);
  });

  it('REJECTS payload.gaps with acceptedRegexes (must NOT be allowed post-fix)', () => {
    const sample = mutate(samples.FLOW_CHART_COMPLETION.payload, (d) => {
      const gaps = d['gaps'] as Array<Record<string, unknown>>;
      gaps[0]['acceptedRegexes'] = ['^.*$'];
    });
    expect(flowChartCompletionPayloadSchema.safeParse(sample).success).toBe(false);
  });

  it('REJECTS legacy Record<string, string[]> shape for CorrectAnswer.gapAnswers', () => {
    const sample = mutate(samples.FLOW_CHART_COMPLETION.correctAnswer, (d) => {
      d['gapAnswers'] = { n_1: ['photosynthesis'] };
    });
    expect(flowChartCompletionAnswerSchema.safeParse(sample).success).toBe(false);
  });

  it('ACCEPTS object-form { k: { acceptedTexts: [...] } } for CorrectAnswer.gapAnswers', () => {
    const sample = mutate(samples.FLOW_CHART_COMPLETION.correctAnswer, (d) => {
      d['gapAnswers'] = { n_1: { acceptedTexts: ['photosynthesis'] } };
    });
    expect(flowChartCompletionAnswerSchema.safeParse(sample).success).toBe(true);
  });

  it('ACCEPTS acceptedRegexes on the object-form gapAnswers', () => {
    const sample = mutate(samples.FLOW_CHART_COMPLETION.correctAnswer, (d) => {
      d['gapAnswers'] = {
        n_1: { acceptedTexts: ['photosynthesis'], acceptedRegexes: ['^[a-z]+$'] },
      };
    });
    expect(flowChartCompletionAnswerSchema.safeParse(sample).success).toBe(true);
  });
});

describe('per-type answer rejections', () => {
  it('MULTIPLE_CHOICE_MULTIPLE: rejects empty correctOptionIds', () => {
    const sample = mutate(samples.MULTIPLE_CHOICE_MULTIPLE.correctAnswer, (d) => {
      d['correctOptionIds'] = [];
    });
    expect(AnswerSchemaBySlug.MULTIPLE_CHOICE_MULTIPLE.safeParse(sample).success).toBe(false);
  });

  it('SHORT_ANSWER: rejects empty acceptedTexts', () => {
    const sample = mutate(samples.SHORT_ANSWER.correctAnswer, (d) => {
      d['acceptedTexts'] = [];
    });
    expect(AnswerSchemaBySlug.SHORT_ANSWER.safeParse(sample).success).toBe(false);
  });
});

/* --------------------------------------------------------------------- */
/* Phase 3: cross-reference invariants                                    */
/* --------------------------------------------------------------------- */
describe('cross-reference invariants (superRefine)', () => {
  /** Build a deep clone of the canonical envelope `{type, payload, correctAnswer}`. */
  function envelope<T extends keyof typeof samples>(slug: T): Record<string, unknown> {
    const s = samples[slug] as unknown as { type: string; payload: Record<string, unknown>; correctAnswer: Record<string, unknown> };
    return structuredClone({ type: s.type, payload: s.payload, correctAnswer: s.correctAnswer });
  }

  it('FCC envelope: payload.gaps[].nodeId must exist in nodes[].id — error lists available ids', () => {
    const good = envelope('FLOW_CHART_COMPLETION');
    (good['payload'] as Record<string, unknown>)['gaps'] = [{ nodeId: 'n_unknown', wordLimit: 1 }];
    const r = flowChartCompletionEnvelopeSchema.safeParse(good);
    expect(r.success).toBe(false);
    if (!r.success) {
      const msg = r.error.issues.map((i) => i.message).join('\n');
      expect(msg).toMatch(/gaps\[0\]\.nodeId 'n_unknown'/);
      expect(msg).toMatch(/Available node ids:.*n_1/);
    }
    const clean = envelope('FLOW_CHART_COMPLETION');
    expect(flowChartCompletionEnvelopeSchema.safeParse(clean).success).toBe(true);
  });

  it('FCC envelope: correctAnswer.order must be a permutation of payload.nodes[].id', () => {
    const good = envelope('FLOW_CHART_COMPLETION');
    ((good['correctAnswer'] as Record<string, unknown>)['order'] as string[]).push('n_unknown');
    const r = flowChartCompletionEnvelopeSchema.safeParse(good);
    expect(r.success).toBe(false);
    if (!r.success) {
      const msg = r.error.issues.map((i) => i.message).join('\n');
      expect(msg).toMatch(/correctAnswer\.order/);
      expect(msg).toMatch(/unknown node id.*'n_unknown'/);
      expect(msg).toMatch(/Available node ids/);
    }
  });

  it('MATCHING_HEADING envelope: pairs.{paragraphId, headingId} must resolve — error lists available ids', () => {
    const good = envelope('MATCHING_HEADING');
    const pairs = (good['correctAnswer'] as Record<string, unknown>)['pairs'] as Array<Record<string, unknown>>;
    pairs[0]['paragraphId'] = 'p_unknown';
    pairs[0]['headingId'] = 'h_unknown';
    const r = matchingHeadingEnvelopeSchema.safeParse(good);
    expect(r.success).toBe(false);
    if (!r.success) {
      const msg = r.error.issues.map((i) => i.message).join('\n');
      expect(msg).toMatch(/paragraphId 'p_unknown'/);
      expect(msg).toMatch(/headingId 'h_unknown'/);
    }
    expect(matchingHeadingEnvelopeSchema.safeParse(envelope('MATCHING_HEADING')).success).toBe(true);
  });

  it('MATCHING_INFORMATION envelope: duplicates allowed when allowReuse=true; flagged when false', () => {
    const bad = envelope('MATCHING_INFORMATION');
    const pairs = (bad['correctAnswer'] as Record<string, unknown>)['pairs'] as Array<Record<string, unknown>>;
    pairs[1]['paragraphId'] = pairs[0]['paragraphId'];
    (bad['payload'] as Record<string, unknown>)['allowReuse'] = false;
    const r = matchingInformationEnvelopeSchema.safeParse(bad);
    expect(r.success).toBe(false);
    if (!r.success) {
      const msg = r.error.issues.map((i) => i.message).join('\n');
      expect(msg).toMatch(/allowReuse is false/);
    }
    const ok = envelope('MATCHING_INFORMATION');
    (ok['payload'] as Record<string, unknown>)['allowReuse'] = true;
    const okPairs = (ok['correctAnswer'] as Record<string, unknown>)['pairs'] as Array<Record<string, unknown>>;
    okPairs[1]['paragraphId'] = okPairs[0]['paragraphId'];
    expect(matchingInformationEnvelopeSchema.safeParse(ok).success).toBe(true);
  });

  it('DIAGRAM_LABEL payload: gaps[].id must be one of labels[].id', () => {
    const good = structuredClone(samples.DIAGRAM_LABEL.payload);
    (good as Record<string, unknown>)['gaps'] = [{ id: 'gap_unbound', wordLimit: 1 }];
    const r = diagramLabelPayloadValidatedSchema.safeParse(good);
    expect(r.success).toBe(false);
    if (!r.success) {
      const msg = r.error.issues.map((i) => i.message).join('\n');
      expect(msg).toMatch(/gap_unbound/);
      expect(msg).toMatch(/Available label ids/);
    }
    expect(diagramLabelPayloadValidatedSchema.safeParse(structuredClone(samples.DIAGRAM_LABEL.payload)).success).toBe(true);
  });

  it('MAP_LABEL payload: gaps[].id must be one of labels[].id', () => {
    const good = structuredClone(samples.MAP_LABEL.payload);
    (good as Record<string, unknown>)['gaps'] = [{ id: 'gap_unbound', wordLimit: 1 }];
    expect(mapLabelPayloadValidatedSchema.safeParse(good).success).toBe(false);
    expect(mapLabelPayloadValidatedSchema.safeParse(structuredClone(samples.MAP_LABEL.payload)).success).toBe(true);
  });

  it('SUMMARY_COMPLETION payload: promptMd placeholders must reference defined gap ids', () => {
    const good = structuredClone(samples.SUMMARY_COMPLETION.payload);
    (good as Record<string, unknown>)['promptMd'] = 'The {{gap:gap_99}} is missing.';
    const r = summaryCompletionPayloadValidatedSchema.safeParse(good);
    expect(r.success).toBe(false);
    if (!r.success) {
      const msg = r.error.issues.map((i) => i.message).join('\n');
      expect(msg).toMatch(/gap_99/);
      expect(msg).toMatch(/Available gap ids/);
    }
    expect(summaryCompletionPayloadValidatedSchema.safeParse(structuredClone(samples.SUMMARY_COMPLETION.payload)).success).toBe(true);
  });

  it('SENTENCE_COMPLETION payload: promptMd placeholder must match the singular gap.id', () => {
    const good = structuredClone(samples.SENTENCE_COMPLETION.payload);
    (good as Record<string, unknown>)['promptMd'] = 'He arrived at {{gap:gap_99}}.';
    const r = sentenceCompletionPayloadValidatedSchema.safeParse(good);
    expect(r.success).toBe(false);
    if (!r.success) {
      const msg = r.error.issues.map((i) => i.message).join('\n');
      expect(msg).toMatch(/gap_99/);
    }
    expect(sentenceCompletionPayloadValidatedSchema.safeParse(structuredClone(samples.SENTENCE_COMPLETION.payload)).success).toBe(true);
  });

  it('MULTIPLE_CHOICE_MULTIPLE envelope: correctOptionIds ⊆ options[].id', () => {
    const good = envelope('MULTIPLE_CHOICE_MULTIPLE');
    ((good['correctAnswer'] as Record<string, unknown>)['correctOptionIds'] as string[]).push('opt_unknown');
    const r = multipleChoiceMultipleEnvelopeSchema.safeParse(good);
    expect(r.success).toBe(false);
    if (!r.success) {
      const msg = r.error.issues.map((i) => i.message).join('\n');
      expect(msg).toMatch(/opt_unknown/);
      expect(msg).toMatch(/Available options/);
    }
    expect(multipleChoiceMultipleEnvelopeSchema.safeParse(envelope('MULTIPLE_CHOICE_MULTIPLE')).success).toBe(true);
  });

  it('FLOW_CHART envelope: correctAnswer.order missing 1 node id is rejected (permutation check)', () => {
    const good = envelope('FLOW_CHART');
    // FLOW_CHART sample has nodes n_1..n_5 and order ['n_1','n_2','n_3','n_4','n_5'].
    // Drop 'n_3' to leave a valid 4-entry order that omits a node.
    (good['correctAnswer'] as Record<string, unknown>)['order'] = ['n_1', 'n_2', 'n_4', 'n_5'];
    const r = flowChartEnvelopeSchema.safeParse(good);
    expect(r.success).toBe(false);
    if (!r.success) {
      const msg = r.error.issues.map((i) => i.message).join('\n');
      expect(msg).toMatch(/correctAnswer\.order is missing node id\(s\)/);
      expect(msg).toMatch(/'n_3'/);
      expect(msg).toMatch(/Available node ids/);
    }
    const clean = envelope('FLOW_CHART');
    expect(flowChartEnvelopeSchema.safeParse(clean).success).toBe(true);
  });

  it('FLOW_CHART_COMPLETION envelope: correctAnswer.order with an extra unknown id is rejected (permutation check)', () => {
    const good = envelope('FLOW_CHART_COMPLETION');
    ((good['correctAnswer'] as Record<string, unknown>)['order'] as string[]).push('n_unknown');
    const r = flowChartCompletionEnvelopeSchema.safeParse(good);
    expect(r.success).toBe(false);
    if (!r.success) {
      const msg = r.error.issues.map((i) => i.message).join('\n');
      expect(msg).toMatch(/correctAnswer\.order/);
      expect(msg).toMatch(/unknown node id.*'n_unknown'/);
      expect(msg).toMatch(/Available node ids/);
    }
  });
});
